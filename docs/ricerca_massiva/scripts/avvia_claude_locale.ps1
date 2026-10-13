<#
.SYNOPSIS
  Launcher PROPOSTO per delegare a Claude Code locale il lavoro dell'incarico #12 (progetto FILM),
  con accesso limitato. Vedi docs/ricerca_massiva/CLAUDE_CODE_LOCALE_DELEGA.md.

.DESCRIPTION
  Principio: FAIL-CLOSED. Ogni controllo che non si puo' completare blocca il launcher.

  Fase 1 - controlli in SOLA LETTURA (nessuna scrittura):
    a. GameDir esiste; WorkDir non coincide con GameDir, non lo contiene e non ne e' contenuto;
       nessun componente esistente dei due percorsi e' una junction/symlink.
    b. Account: token non elevato E utente NON membro di Administrators (nemmeno come gruppo
       "deny-only" di un amministratore non elevato), letto da 'whoami /groups'.
       Il launcher NON puo' accertare che l'account sia "dedicato": e' un requisito documentale.
    c. Accesso EFFETTIVO di Windows: per la cartella del gioco e per OGNI file e sottocartella
       al suo interno, AccessCheck (advapi32) con il token di questo processo e MAXIMUM_ALLOWED.
       Se risulta anche un solo diritto di scrittura, aggiunta, cancellazione, cancellazione
       figli, modifica attributi, modifica DACL o cambio proprietario -> STOP.
       Qualsiasi reparse point dentro la cartella del gioco -> STOP.
       E' lo stesso token con cui verra' avviato Claude (il launcher lo avvia direttamente).
    d. Configurazione Claude: rifiuta configurazioni preesistenti non verificate:
       WorkDir\.claude, WorkDir\CLAUDE.md, CLAUDE.local.md, .mcp.json, capitolato;
       CLAUDE.md/CLAUDE.local.md/.claude nelle cartelle superiori di WorkDir;
       %USERPROFILE%\.claude\settings.json con regole 'allow', 'hooks', 'mcpServers'
       o defaultMode diverso da default/plan.
    e. Capitolato: la copia locale di FILM deve essere un clone Git con HEAD uguale a
       -ExpectedCommit e senza modifiche locali (git status vuoto); README.md, CLAUDE.md e docs/
       devono esistere.
    f. Informativi: GPU (nvidia-smi), CLI 'claude', file chiave del gioco.
  Fase 2 - SOLO con conferma digitata: crea WorkDir (ricontrollando dopo la creazione), copia il
    capitolato con manifest SHA256, crea .claude\settings.json e CLAUDE.md.
  Fase 3 - SOLO con conferma: avvia 'claude --permission-mode plan' in WorkDir.
  Non avvia il gioco, non scarica nulla, non modifica ACL ne' la cartella del gioco.
  Script NON ancora eseguito ne' testato: rileggerlo prima dell'uso.

.PARAMETER ExpectedCommit
  Hash Git completo (40 caratteri) della revisione di FILM che l'utente ha controllato.

.EXAMPLE
  .\avvia_claude_locale.ps1 -GameDir "C:\...\Assassin's Creed II" -WorkDir "D:\FILM_PRIVATO" -ExpectedCommit <hash>
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$GameDir,
    [Parameter(Mandatory = $true)][string]$WorkDir,
    [Parameter(Mandatory = $true)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$ExpectedCommit
)
$ErrorActionPreference = 'Stop'

Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

public static class FilmAccess {
    [StructLayout(LayoutKind.Sequential)]
    public struct GENERIC_MAPPING { public uint GenericRead, GenericWrite, GenericExecute, GenericAll; }

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    static extern bool GetFileSecurity(string lpFileName, uint requested, IntPtr pSD, uint nLength, out uint needed);
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool OpenProcessToken(IntPtr process, uint access, out IntPtr token);
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool DuplicateToken(IntPtr existing, int level, out IntPtr duplicate);
    [DllImport("advapi32.dll", SetLastError = true)]
    static extern bool AccessCheck(IntPtr pSD, IntPtr token, uint desired, ref GENERIC_MAPPING mapping,
        IntPtr privilegeSet, ref uint privilegeSetLength, out uint granted, out bool status);
    [DllImport("kernel32.dll")]
    static extern IntPtr GetCurrentProcess();
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool CloseHandle(IntPtr handle);

    // Diritti EFFETTIVI concessi al token del processo corrente (valutazione di Windows:
    // ordine degli ACE, ereditarieta', gruppi abilitati/deny-only, proprietario, livello di integrita').
    public static uint MaximumAllowed(string path) {
        const uint INFO = 0x1 | 0x2 | 0x4; // OWNER | GROUP | DACL
        uint needed;
        GetFileSecurity(path, INFO, IntPtr.Zero, 0, out needed);
        if (needed == 0) throw new Win32Exception(Marshal.GetLastWin32Error(), "GetFileSecurity: " + path);
        IntPtr sd = Marshal.AllocHGlobal((int)needed);
        IntPtr token = IntPtr.Zero, imp = IntPtr.Zero, ps = IntPtr.Zero;
        try {
            if (!GetFileSecurity(path, INFO, sd, needed, out needed))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "GetFileSecurity: " + path);
            if (!OpenProcessToken(GetCurrentProcess(), 0x0002 | 0x0008, out token)) // DUPLICATE | QUERY
                throw new Win32Exception(Marshal.GetLastWin32Error(), "OpenProcessToken");
            if (!DuplicateToken(token, 2, out imp)) // SecurityImpersonation
                throw new Win32Exception(Marshal.GetLastWin32Error(), "DuplicateToken");
            GENERIC_MAPPING map = new GENERIC_MAPPING {
                GenericRead = 0x120089, GenericWrite = 0x120116, GenericExecute = 0x1200A0, GenericAll = 0x1F01FF };
            uint psLen = 1024;
            ps = Marshal.AllocHGlobal((int)psLen);
            uint granted; bool status;
            if (!AccessCheck(sd, imp, 0x02000000, ref map, ps, ref psLen, out granted, out status)) // MAXIMUM_ALLOWED
                throw new Win32Exception(Marshal.GetLastWin32Error(), "AccessCheck: " + path);
            return status ? granted : 0u;
        } finally {
            if (ps != IntPtr.Zero) Marshal.FreeHGlobal(ps);
            Marshal.FreeHGlobal(sd);
            if (imp != IntPtr.Zero) CloseHandle(imp);
            if (token != IntPtr.Zero) CloseHandle(token);
        }
    }
}
'@

# FILE_WRITE_DATA/ADD_FILE 0x2, FILE_APPEND_DATA/ADD_SUBDIRECTORY 0x4, FILE_WRITE_EA 0x10,
# FILE_DELETE_CHILD 0x40, FILE_WRITE_ATTRIBUTES 0x100, DELETE 0x10000, WRITE_DAC 0x40000, WRITE_OWNER 0x80000
$WriteMask = [uint32]0xD0156

function Get-AbsolutePath([string]$p) {
    $full = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
    return [System.IO.Path]::GetFullPath($full).TrimEnd('\')
}
function Test-IsReparse([string]$p) {
    $item = Get-Item -LiteralPath $p -Force
    return [bool]($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}
function Assert-NoReparsePoint([string]$path, [string]$label) {
    $cur = $path
    while ($cur) {
        if ((Test-Path -LiteralPath $cur) -and (Test-IsReparse $cur)) {
            throw "$label contiene una junction/symlink ($cur). Usare un percorso reale senza collegamenti."
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
function Confirm-Step([string]$question) {
    $answer = Read-Host "$question  Digitare SI per procedere"
    return ($answer -ceq 'SI')
}

$game = Get-AbsolutePath $GameDir
$work = Get-AbsolutePath $WorkDir

Write-Host "== Fase 1a: percorsi =="
if (-not (Test-Path -LiteralPath $game -PathType Container)) { throw "Cartella del gioco non trovata: $game" }
if ((Test-Path -LiteralPath $work) -and -not (Test-Path -LiteralPath $work -PathType Container)) { throw "WorkDir esiste ma non e' una cartella: $work" }
Assert-NoReparsePoint $game 'GameDir'
Assert-NoReparsePoint $work 'WorkDir'
Assert-Separated $game $work
Write-Host "Cartella gioco (sola lettura): $game"
Write-Host "Cartella privata di lavoro   : $work"

Write-Host "== Fase 1b: account =="
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Token elevato (amministratore). Usare un account Windows standard, non elevato."
}
$groupsCsv = & "$env:SystemRoot\System32\whoami.exe" /groups /fo csv /nh
if ($LASTEXITCODE -ne 0 -or -not $groupsCsv) { throw "Impossibile leggere i gruppi con whoami: controllo dell'account non completabile." }
$groups = $groupsCsv | ConvertFrom-Csv -Header 'Name', 'Type', 'SID', 'Attributes'
if ($groups | Where-Object { $_.SID -eq 'S-1-5-32-544' }) {
    throw "L'account corrente appartiene ad Administrators (anche se non elevato). Usare un account Windows STANDARD dedicato (CLAUDE_CODE_LOCALE_DELEGA.md par. 2)."
}
Write-Host "Account: token non elevato e non membro di Administrators. (Che sia 'dedicato' resta un requisito da rispettare a cura dell'utente.)"

Write-Host "== Fase 1c: accesso effettivo di Windows alla cartella del gioco =="
$items = @(Get-Item -LiteralPath $game -Force)
$scanErrors = @()
$items += Get-ChildItem -LiteralPath $game -Recurse -Force -ErrorAction SilentlyContinue -ErrorVariable scanErrors
if ($scanErrors.Count -gt 0) {
    $scanErrors | Select-Object -First 5 | ForEach-Object { Write-Warning $_.ToString() }
    throw "Scansione della cartella del gioco incompleta ($($scanErrors.Count) errori): controllo dell'accesso non completabile."
}
$violations = @()
$n = 0
foreach ($it in $items) {
    $n++
    if ($n % 200 -eq 0) { Write-Host "  controllati $n / $($items.Count)" }
    if ($it.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        $violations += "REPARSE POINT dentro il gioco: $($it.FullName)"; continue
    }
    $granted = [FilmAccess]::MaximumAllowed($it.FullName)
    $w = $granted -band $WriteMask
    if ($w -ne 0) { $violations += ('{0} : diritti di modifica 0x{1:X}' -f $it.FullName, $w) }
}
if ($violations.Count -gt 0) {
    $violations | Select-Object -First 20 | ForEach-Object { Write-Warning $_ }
    throw "Windows CONSENTE a questo account di modificare $($violations.Count) elementi del gioco. Avvio rifiutato: rendere la cartella di sola lettura per l'account dedicato (par. 2) e ripetere."
}
Write-Host "Accesso effettivo: nessun diritto di modifica su $($items.Count) elementi (cartella, sottocartelle e file)."
Write-Host "Conferma manuale consigliata: Esplora risorse -> Proprieta' -> Sicurezza -> Avanzate -> Accesso effettivo, per questo stesso account."

Write-Host "== Fase 1d: configurazioni preesistenti =="
foreach ($n2 in @('.claude', 'CLAUDE.md', 'CLAUDE.local.md', '.mcp.json', 'capitolato')) {
    $p = Join-Path $work $n2
    if (Test-Path -LiteralPath $p) {
        throw "Trovato '$p' preesistente e non verificato. Usare una WorkDir nuova o vuota (il launcher non riusa configurazioni esistenti)."
    }
}
$anc = Split-Path -Path $work -Parent
while ($anc) {
    foreach ($n2 in @('CLAUDE.md', 'CLAUDE.local.md', '.claude')) {
        if (Test-Path -LiteralPath (Join-Path $anc $n2)) { throw "Trovato '$(Join-Path $anc $n2)' in una cartella superiore: Claude lo caricherebbe. Spostare WorkDir altrove." }
    }
    $next = Split-Path -Path $anc -Parent
    if (-not $next -or $next -eq $anc) { break }
    $anc = $next
}
$userSettings = Join-Path $env:USERPROFILE '.claude\settings.json'
if (Test-Path -LiteralPath $userSettings) {
    try { $us = Get-Content -LiteralPath $userSettings -Raw | ConvertFrom-Json }
    catch { throw "Impossibile leggere $userSettings: configurazione utente non verificabile." }
    $problems = @()
    if ($us.permissions -and $us.permissions.allow -and @($us.permissions.allow).Count -gt 0) { $problems += 'regole allow' }
    if ($us.permissions -and $us.permissions.defaultMode -and @('default', 'plan') -notcontains $us.permissions.defaultMode) { $problems += "defaultMode=$($us.permissions.defaultMode)" }
    if ($us.hooks) { $problems += 'hooks' }
    if ($us.mcpServers) { $problems += 'mcpServers' }
    if ($problems.Count -gt 0) { throw "La configurazione utente $userSettings contiene: $($problems -join ', '). Usare l'account dedicato senza configurazioni permissive." }
}
Write-Host "Nessuna configurazione preesistente in WorkDir, nelle cartelle superiori o nell'utente. (Eventuali impostazioni 'managed' di sistema non sono verificate.)"

Write-Host "== Fase 1e: capitolato (copia locale di FILM) =="
$docsDir = Split-Path -Parent $PSScriptRoot                 # ...\docs\ricerca_massiva
$repoRoot = Split-Path -Parent (Split-Path -Parent $docsDir) # radice del repository FILM
$required = @('README.md', 'CLAUDE.md', 'docs', 'docs\ricerca_massiva\CLAUDE_CODE_LOCALE_DELEGA.md')
foreach ($r in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $r))) { throw "Capitolato incompleto: manca $r in $repoRoot." }
}
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) { throw "git non disponibile: impossibile certificare la revisione del capitolato." }
$head = (& $git.Source -C $repoRoot rev-parse HEAD 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $head) { throw "$repoRoot non e' un clone Git valido." }
$head = $head.Trim().ToLowerInvariant()
if ($head -ne $ExpectedCommit.ToLowerInvariant()) { throw "HEAD locale $head diverso dal commit atteso $ExpectedCommit." }
$dirty = & $git.Source -C $repoRoot status --porcelain --untracked-files=all
if ($LASTEXITCODE -ne 0) { throw "git status non riuscito." }
if ($dirty) { throw "La copia locale di FILM ha modifiche non committate: il capitolato non corrisponde al commit $head." }
Write-Host "Capitolato: $repoRoot al commit $head, nessuna modifica locale."

Write-Host "== Fase 1f: informazioni =="
$smi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if ($smi) { & $smi.Source --query-gpu=name,memory.total,driver_version --format=csv,noheader }
else { Write-Warning "nvidia-smi non trovato: GPU NVIDIA non verificabile." }
$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) { Write-Host "CLI claude trovata: $($claude.Source)"; & $claude.Source --version }
else { Write-Warning "CLI 'claude' non trovata. Installare Claude Code seguendo la documentazione ufficiale." }
foreach ($k in @('DataPC_Abstergo.forge', 'SoundData\pc\sounds_ita.pck')) {
    if (Test-Path -LiteralPath (Join-Path $game $k)) { Write-Host "TROVATO  $k" } else { Write-Host "MANCANTE $k" }
}

Write-Host "== Fase 2: configurazione della cartella privata =="
if (-not (Confirm-Step "Creare $work, copiarvi il capitolato e creare .claude\settings.json e CLAUDE.md?")) {
    Write-Host "Interrotto dall'utente. Nessun file creato."; return
}
New-Item -ItemType Directory -Force -Path $work | Out-Null
Assert-NoReparsePoint $work 'WorkDir'
Assert-Separated $game ((Get-Item -LiteralPath $work -Force).FullName.TrimEnd('\'))

$cap = Join-Path $work 'capitolato'
$claudeDir = Join-Path $work '.claude'
foreach ($d in @($cap, $claudeDir)) {
    New-Item -ItemType Directory -Path $d | Out-Null    # senza -Force: fallisce se esiste gia'
    if (Test-IsReparse $d) { throw "$d e' un reparse point: interrotto." }
}
Copy-Item -LiteralPath (Join-Path $repoRoot 'docs') -Destination (Join-Path $cap 'docs') -Recurse
Copy-Item -LiteralPath (Join-Path $repoRoot 'README.md') -Destination (Join-Path $cap 'README.md')
Copy-Item -LiteralPath (Join-Path $repoRoot 'CLAUDE.md') -Destination (Join-Path $cap 'CLAUDE_REPOSITORY_FILM.md')
$manifest = Get-ChildItem -LiteralPath $cap -Recurse -File -Force | ForEach-Object {
    '{0}  {1}' -f (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash, $_.FullName.Substring($cap.Length + 1)
}
@("Revisione Git del capitolato: $head (working tree pulito)", "Copiato il: $(Get-Date -Format s)", '') + $manifest |
    Set-Content -LiteralPath (Join-Path $cap 'MANIFEST_SHA256.txt') -Encoding UTF8
Write-Host "Capitolato copiato in $cap (manifest: MANIFEST_SHA256.txt)"

# Percorso del gioco in forma POSIX per le regole (C:\A B -> /c/A B; nella regola: //c/A B/**).
$posix = ($game.Substring(0, 1).ToLowerInvariant() + $game.Substring(2)).Replace('\', '/')
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
$settingsPath = Join-Path $claudeDir 'settings.json'
$settings | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $settingsPath -Encoding UTF8
Write-Host "Creato $settingsPath"

$rulesPath = Join-Path $work 'CLAUDE.md'
@"
# FILM - Claude Code locale (accesso limitato)
PRIMA DI L0: leggere capitolato\CLAUDE_REPOSITORY_FILM.md (istruzioni vincolanti del progetto), capitolato\README.md,
capitolato\docs\05_DECISIONI.md, capitolato\docs\preproduzione\REGOLA_ADATTAMENTO_CINEMATOGRAFICO.md e
integralmente capitolato\docs\ricerca_massiva\ (in particolare CLAUDE_CODE_LOCALE_DELEGA.md, LIMITI_E_DIRITTI.md,
PIPELINE_E_STATO_ANTEPRIMA.md, BENCHMARK_TOOLCHAIN.md, VOCE_ITALIANA_ORIGINALE_CATALOGO.md); il resto di capitolato\docs
e' consultabile quando serve. Poi dichiarare all'utente la revisione $head indicata in capitolato\MANIFEST_SHA256.txt
e attendere conferma. Le istruzioni del capitolato prevalgono su questo file in caso di dubbio.
Documenti presenti solo in altre PR (es. PR #11, pilota_prologo) NON sono nel capitolato: non presumerne il contenuto.
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

Write-Host "== Fase 3: avvio =="
if (-not $claude) { Write-Host "CLI claude assente: avvio saltato."; return }
if (Confirm-Step "Avviare Claude Code in modalita' plan in $work? Controllare subito /permissions.") {
    Push-Location -LiteralPath $work
    try { & $claude.Source --permission-mode plan } finally { Pop-Location }
} else { Write-Host "Avvio annullato." }
