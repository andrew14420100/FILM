<#
.SYNOPSIS
  Launcher PROPOSTO per delegare a Claude Code locale il lavoro dell'incarico #12 (progetto FILM),
  con accesso limitato. Vedi docs/ricerca_massiva/CLAUDE_CODE_LOCALE_DELEGA.md.

.DESCRIPTION
  Fase 1 - controlli in SOLA LETTURA:
    - GameDir esiste; WorkDir non coincide con GameDir, non lo contiene e non ne e' contenuto;
    - nessun componente esistente di GameDir o WorkDir e' una junction/symlink (reparse point),
      cosi' un WorkDir "deviato" verso il gioco viene rifiutato PRIMA di creare qualsiasi file;
    - il processo NON deve essere elevato (amministratore);
    - analisi in sola lettura delle ACL NTFS della cartella del gioco e dei file principali:
      se Windows consente all'utente corrente di scrivere, cancellare o cambiare permessi,
      il launcher SI FERMA (protezione reale del sistema, non solo regole di Claude);
    - GPU (nvidia-smi), presenza della CLI 'claude', presenza dei file chiave del gioco.
  Fase 2 - SOLO con conferma digitata: crea WorkDir, copia il capitolato (questa cartella
    TUTTE le istruzioni di FILM: README.md, CLAUDE.md e l'intera cartella docs) in
    WorkDir\capitolato con manifest SHA256 e revisione Git, poi crea (se assenti)
    WorkDir\.claude\settings.json e WorkDir\CLAUDE.md. Non sovrascrive file esistenti.
    Dopo la creazione ricontrolla che WorkDir sia ancora un percorso reale senza reparse point.
  Fase 3 - SOLO con conferma: avvia 'claude --permission-mode plan' in WorkDir.
  Non avvia il gioco, non scarica nulla, non scrive nella cartella del gioco.
  Script NON ancora eseguito ne' testato: rileggerlo prima dell'uso.

.EXAMPLE
  .\avvia_claude_locale.ps1 -GameDir "C:\...\Assassin's Creed II" -WorkDir "D:\FILM_PRIVATO"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$GameDir,
    [Parameter(Mandatory = $true)][string]$WorkDir
)
$ErrorActionPreference = 'Stop'

function Get-AbsolutePath([string]$p) {
    $full = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
    return [System.IO.Path]::GetFullPath($full).TrimEnd('\')
}
function Assert-NoReparsePoint([string]$path, [string]$label) {
    $cur = $path
    while ($cur) {
        if (Test-Path -LiteralPath $cur) {
            $item = Get-Item -LiteralPath $cur -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                throw "$label contiene una junction/symlink ($cur). Usare un percorso reale senza collegamenti."
            }
        }
        $parent = Split-Path -Path $cur -Parent
        if (-not $parent -or $parent -eq $cur) { break }
        $cur = $parent
    }
}
function Assert-Separated([string]$game, [string]$work) {
    $cmp = [System.StringComparison]::OrdinalIgnoreCase
    if ($work.Equals($game, $cmp) -or ($work + '\').StartsWith($game + '\', $cmp) -or ($game + '\').StartsWith($work + '\', $cmp)) {
        throw "WorkDir non deve coincidere con la cartella del gioco, ne' contenerla o esserne contenuta."
    }
}
function Get-WriteAccessFindings([string]$path) {
    # Analisi in SOLA LETTURA delle ACL NTFS: elenca i motivi per cui l'utente corrente
    # potrebbe scrivere/cancellare/cambiare permessi su $path. Approccio prudente:
    # un falso positivo blocca il launcher, un falso negativo e' il rischio da evitare.
    $findings = @()
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $sids = @($id.User.Value) + @($id.Groups | ForEach-Object { $_.Value })
    # Sessione non elevata (verificata prima): con UAC il gruppo Administrators e' solo "deny-only".
    $sids = $sids | Where-Object { $_ -ne 'S-1-5-32-544' }
    $writeMask = [System.Security.AccessControl.FileSystemRights]'WriteData, AppendData, WriteExtendedAttributes, WriteAttributes, Delete, DeleteSubdirectoriesAndFiles, ChangePermissions, TakeOwnership'
    $acl = Get-Acl -LiteralPath $path
    try { $owner = (New-Object Security.Principal.NTAccount($acl.Owner)).Translate([Security.Principal.SecurityIdentifier]).Value }
    catch { $owner = ''; $findings += "$path : proprietario non risolvibile ($($acl.Owner)), verifica manuale necessaria" }
    if ($owner -eq $id.User.Value) { $findings += "$path : l'utente corrente e' PROPRIETARIO (puo' cambiare i permessi)" }
    $rules = $acl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])
    $denied = [System.Security.AccessControl.FileSystemRights]0
    foreach ($r in $rules) {
        if ($r.AccessControlType -eq 'Deny' -and $sids -contains $r.IdentityReference.Value) { $denied = $denied -bor $r.FileSystemRights }
    }
    foreach ($r in $rules) {
        if ($r.AccessControlType -ne 'Allow') { continue }
        $sid = $r.IdentityReference.Value
        $applies = ($sids -contains $sid) -or ($sid -eq 'S-1-3-0' -and $owner -eq $id.User.Value)
        if (-not $applies) { continue }
        $granted = ($r.FileSystemRights -band $writeMask) -band (-bnot $denied)
        if ($granted -ne 0) { $findings += "$path : consentito '$granted' a $sid" }
    }
    return $findings
}
function Confirm-Step([string]$question) {
    $answer = Read-Host "$question  Digitare SI per procedere"
    return ($answer -ceq 'SI')
}

$game = Get-AbsolutePath $GameDir
$work = Get-AbsolutePath $WorkDir

Write-Host "== Fase 1: controlli in sola lettura =="
if (-not (Test-Path -LiteralPath $game -PathType Container)) { throw "Cartella del gioco non trovata: $game" }
if ((Test-Path -LiteralPath $work) -and -not (Test-Path -LiteralPath $work -PathType Container)) { throw "WorkDir esiste ma non e' una cartella: $work" }
Assert-NoReparsePoint $game 'GameDir'
Assert-NoReparsePoint $work 'WorkDir'
Assert-Separated $game $work
Write-Host "Cartella gioco (sola lettura): $game"
Write-Host "Cartella privata di lavoro   : $work"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "PowerShell e' elevato (amministratore). Rieseguire da una sessione NON elevata: la protezione della cartella del gioco si basa sui permessi dell'utente standard."
}
$pf = @($env:ProgramFiles, ${env:ProgramFiles(x86)}) | Where-Object { $_ }
$underPf = $false
foreach ($p in $pf) { if (($game + '\').StartsWith(($p.TrimEnd('\') + '\'), [System.StringComparison]::OrdinalIgnoreCase)) { $underPf = $true } }
if ($underPf) { Write-Host "Il gioco e' sotto Program Files: per un utente standard non elevato Windows nega di norma la scrittura (DA VERIFICARE)." }
else { Write-Warning "Il gioco NON e' sotto Program Files: la scrittura potrebbe essere permessa dall'utente corrente. Leggere CLAUDE_CODE_LOCALE_DELEGA.md par. 2 (utente Windows dedicato) prima di procedere." }

# Protezione REALE di Windows: il launcher si ferma se le ACL consentono all'utente corrente di
# scrivere nella cartella del gioco o nei file principali. Nessuna modifica alle ACL.
$aclTargets = @($game) + (@('AssassinsCreedIIGame.exe', 'DataPC.forge', 'DataPC_Abstergo.forge', 'SoundData\pc\sounds_ita.pck') |
    ForEach-Object { Join-Path $game $_ } | Where-Object { Test-Path -LiteralPath $_ })
$aclFindings = @()
foreach ($t in $aclTargets) { $aclFindings += Get-WriteAccessFindings $t }
if ($aclFindings.Count -gt 0) {
    $aclFindings | ForEach-Object { Write-Warning $_ }
    throw "Windows NON impedisce la scrittura nella cartella del gioco per questo utente. Usare un utente Windows standard dedicato con sola lettura sul gioco (CLAUDE_CODE_LOCALE_DELEGA.md par. 2). Avvio rifiutato."
}
Write-Host "ACL: nessun diritto di scrittura/cancellazione/modifica permessi trovato per l'utente corrente sui percorsi controllati (analisi statica, DA VERIFICARE con prova manuale dell'utente)."

$smi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if ($smi) { & $smi.Source --query-gpu=name,memory.total,driver_version --format=csv,noheader }
else { Write-Warning "nvidia-smi non trovato: GPU NVIDIA non verificabile." }

$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) { Write-Host "CLI claude trovata: $($claude.Source)"; & $claude.Source --version }
else { Write-Warning "CLI 'claude' non trovata. Installare Claude Code seguendo la documentazione ufficiale, poi rieseguire." }

foreach ($n in @('DataPC_Abstergo.forge', 'SoundData\pc\sounds_ita.pck')) {
    if (Test-Path -LiteralPath (Join-Path $game $n)) { Write-Host "TROVATO  $n" } else { Write-Host "MANCANTE $n" }
}

# Capitolato da copiare: TUTTE le istruzioni di FILM (README.md, CLAUDE.md, intera cartella docs).
$docsDir = Split-Path -Parent $PSScriptRoot                 # ...\docs\ricerca_massiva
$repoRoot = Split-Path -Parent (Split-Path -Parent $docsDir) # radice del repository FILM
$extra = @(
    @{ src = Join-Path $repoRoot 'CLAUDE.md'; dst = 'CLAUDE_REPOSITORY_FILM.md' },
    @{ src = Join-Path $repoRoot 'README.md'; dst = 'README.md' }
)
$repoDocs = Join-Path $repoRoot 'docs'
if (-not (Test-Path -LiteralPath (Join-Path $docsDir 'CLAUDE_CODE_LOCALE_DELEGA.md'))) {
    throw "Capitolato non trovato in $docsDir. Eseguire il launcher dalla copia locale del branch con docs/ricerca_massiva."
}
$revision = 'SCONOSCIUTA (git non disponibile o cartella non e'' un clone)'
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) {
    $r = & $git.Source -C $repoRoot rev-parse HEAD 2>$null
    if ($LASTEXITCODE -eq 0 -and $r) { $revision = $r.Trim() }
}
Write-Host "Capitolato: $docsDir (revisione Git: $revision)"

Write-Host "== Fase 2: configurazione della cartella privata =="
if (-not (Confirm-Step "Creare $work (se manca), copiare il capitolato in $work\capitolato e creare .claude\settings.json e CLAUDE.md se assenti?")) {
    Write-Host "Interrotto dall'utente. Nessun file creato."; return
}
New-Item -ItemType Directory -Force -Path $work | Out-Null
# Ricontrollo dopo la creazione: il percorso reale deve restare fuori dal gioco e senza reparse point.
Assert-NoReparsePoint $work 'WorkDir'
Assert-Separated $game ((Get-Item -LiteralPath $work -Force).FullName.TrimEnd('\'))

$cap = Join-Path $work 'capitolato'
if (Test-Path -LiteralPath $cap) {
    throw "$cap esiste gia'. Rinominarlo o rimuoverlo manualmente per copiare una revisione nuova (il launcher non sovrascrive)."
}
New-Item -ItemType Directory -Path $cap | Out-Null
Copy-Item -LiteralPath $repoDocs -Destination (Join-Path $cap 'docs') -Recurse
foreach ($e in $extra) {
    if (Test-Path -LiteralPath $e.src) { Copy-Item -LiteralPath $e.src -Destination (Join-Path $cap $e.dst) }
    else { Write-Warning "Non trovato, non copiato: $($e.src)" }
}
$manifest = Get-ChildItem -LiteralPath $cap -Recurse -File | ForEach-Object {
    '{0}  {1}' -f (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash, $_.FullName.Substring($cap.Length + 1)
}
@("Revisione Git del capitolato: $revision", "Copiato il: $(Get-Date -Format s)", '') + $manifest |
    Set-Content -LiteralPath (Join-Path $cap 'MANIFEST_SHA256.txt') -Encoding UTF8
Write-Host "Capitolato copiato in $cap (manifest: MANIFEST_SHA256.txt)"

New-Item -ItemType Directory -Force -Path (Join-Path $work '.claude') | Out-Null
# Percorso del gioco in forma POSIX per le regole (C:\A B -> /c/A B; nella regola: //c/A B/**).
$posix = ($game.Substring(0, 1).ToLowerInvariant() + $game.Substring(2)).Replace('\', '/')
$settingsPath = Join-Path $work '.claude\settings.json'
if (-not (Test-Path -LiteralPath $settingsPath)) {
    $settings = [ordered]@{
        permissions = [ordered]@{
            defaultMode                  = 'plan'
            disableBypassPermissionsMode = 'disable'
            disableAutoMode              = 'disable'
            # Solo Edit(path) e Read(path) sono consultate per i file: Edit copre anche Write.
            deny                         = @(
                "Edit(//$posix/**)",
                'Bash(git push *)', 'Bash(curl *)', 'Bash(wget *)',
                'PowerShell(git push *)', 'PowerShell(Invoke-WebRequest *)', 'PowerShell(Invoke-RestMethod *)',
                'PowerShell(Start-BitsTransfer *)', 'PowerShell(Remove-Item *)',
                'WebFetch'
            )
            ask                          = @('Bash', 'PowerShell', 'Edit')
        }
    }
    $settings | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $settingsPath -Encoding UTF8
    Write-Host "Creato $settingsPath"
} else { Write-Host "Esistente, non modificato: $settingsPath" }

$rulesPath = Join-Path $work 'CLAUDE.md'
if (-not (Test-Path -LiteralPath $rulesPath)) {
    @"
# FILM - Claude Code locale (accesso limitato)
PRIMA DI L0: leggere capitolato\CLAUDE_REPOSITORY_FILM.md (istruzioni vincolanti del progetto), capitolato\README.md,
capitolato\docs\05_DECISIONI.md, capitolato\docs\preproduzione\REGOLA_ADATTAMENTO_CINEMATOGRAFICO.md e
integralmente capitolato\docs\ricerca_massiva\ (in particolare CLAUDE_CODE_LOCALE_DELEGA.md, LIMITI_E_DIRITTI.md,
PIPELINE_E_STATO_ANTEPRIMA.md, BENCHMARK_TOOLCHAIN.md, VOCE_ITALIANA_ORIGINALE_CATALOGO.md); il resto di capitolato\docs
e' consultabile quando serve. Poi dichiarare all'utente la revisione indicata in capitolato\MANIFEST_SHA256.txt
($revision) e attendere conferma. Le istruzioni del capitolato prevalgono su questo file in caso di dubbio.
- Cartella del gioco: $game -> SOLA LETTURA. Mai scrivere, patchare, avviare il gioco o il launcher.
- Lavorare solo in: $work. Nessuna rete, nessun download, nessun push su GitHub di file del gioco.
- Restare in modalita' plan: nessun file scritto finche' l'utente non approva un piano e un cambio di modalita'.
  Mai bypassPermissions o auto mode.
- Fasi L0-L6 con STOP e consenso esplicito; prima dry-run. Non dichiarare risultati senza prova.
- Voci: solo registrazioni originali italiane, mai sintesi/clonazione/modifica.
- Nessun 4K della stanza vuota. Un solo frame finale FILM_PREVIEW_01_ABSTERGO.png con Desmond e Lucy, privato.
  Niente primi 15 minuti.
"@ | Set-Content -LiteralPath $rulesPath -Encoding UTF8
    Write-Host "Creato $rulesPath"
} else { Write-Host "Esistente, non modificato: $rulesPath" }

Write-Host "== Fase 3: avvio =="
if (-not $claude) { Write-Host "CLI claude assente: avvio saltato."; return }
if (Confirm-Step "Avviare Claude Code in modalita' plan in $work? Controllare subito /permissions.") {
    Push-Location -LiteralPath $work
    try { & $claude.Source --permission-mode plan } finally { Pop-Location }
} else { Write-Host "Avvio annullato." }
