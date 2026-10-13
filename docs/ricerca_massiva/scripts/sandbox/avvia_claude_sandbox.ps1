<#
.SYNOPSIS
  FILM - modalita' WINDOWS SANDBOX dedicata: verifica l'ambiente e (solo su conferma) prepara e avvia
  Claude Code DENTRO la Sandbox, con archivio e capitolato in sola lettura e risultati persistenti separati.

.DESCRIPTION
  Questo script NON sostituisce e NON indebolisce avvia_claude_locale.ps1 (launcher per l'host, invariato).
  Funziona SOLO dentro Windows Sandbox configurata da genera_film_sandbox.ps1; fuori si rifiuta.

  Perche' controlli diversi: dentro Windows Sandbox l'account WDAGUtilityAccount e' amministratore per
  progetto (documentazione Microsoft), quindi i controlli "account standard / ACL NTFS" dell'host non sono
  applicabili. La protezione qui viene da: macchina usa-e-getta, nessuna cartella dell'host visibile salvo
  quelle mappate, mappature ReadOnly imposte dall'host. Lo script lo VERIFICA in modo empirico:
    S1 identita' Sandbox: utente WDAGUtilityAccount, FILM_SANDBOX.json (V1) presente in C:\FILM\CONFIG,
       percorsi attesi presenti, nessun'altra unita' di file system oltre C:.
    S2 prova di SCRITTURA attesa NEGATA su C:\FILM\ARCHIVI_RO, C:\FILM\REPO, C:\FILM\CONFIG (file temporaneo
       con FileOptions.DeleteOnClose: se la creazione riuscisse verrebbe eliminato alla chiusura e lo script
       si fermerebbe). Prova di scrittura attesa RIUSCITA su C:\FILM\RISULTATI.
    S3 copia archivi: SHA256 del manifest = valore registrato sull'host; contenuto esatto; SHA256 di ogni file.
    S4 capitolato: SHA256 di CAPITOLATO_SHA256.txt = valore registrato; SHA256 di ogni file versionato del
       clone; commit = -ExpectedCommit. (Nessun git necessario nella Sandbox.)
    S5 rete: raggiungibilita' HTTPS di api.anthropic.com e claude.ai (solo informativa; serve a Claude Code).
    S6 Claude Code: presenza della CLI; se assente stampa il comando ufficiale (non lo esegue senza -InstallaClaudeCode
       e conferma digitata INSTALLA).
    S7 area di lavoro C:\FILM\LAVORO (solo Sandbox): non deve contenere configurazioni preesistenti;
       %USERPROFILE%\.claude\settings.json non deve essere permissivo.
  Con -SoloVerifica (usato dal LogonCommand) si ferma dopo S1-S7 senza scrivere nulla.
  Senza -SoloVerifica: conferma PREPARA -> crea C:\FILM\LAVORO con CLAUDE.md e .claude\settings.json
  (plan, bypass/auto disabilitati, Edit negato su archivio/clone/config, niente WebFetch/download), poi
  conferma AVVIA -> claude --permission-mode plan --add-dir per RISULTATI/ARCHIVI_RO/REPO.
  Script NON TESTATO SU WINDOWS: vedi TEST_WINDOWS_SANDBOX.md.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$ExpectedCommit,
    [switch]$SoloVerifica,
    [switch]$InstallaClaudeCode
)
$ErrorActionPreference = 'Stop'
$ConfigDir = 'C:\FILM\CONFIG'
function Stop-Film([string]$msg) { throw "STOP: $msg" }

function Test-WriteDenied([string]$dir) {
    # Ritorna $true se la creazione di un file e' NEGATA (atteso per le cartelle in sola lettura).
    $probe = Join-Path $dir ('.film_probe_' + [guid]::NewGuid().ToString('N'))
    try {
        $fs = New-Object System.IO.FileStream($probe, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::None, 4096, [System.IO.FileOptions]::DeleteOnClose)
        $fs.Dispose()
        return $false
    } catch {
        # Qualsiasi errore di creazione (accesso negato, volume in sola lettura) = scrittura negata.
        # Il percorso e' gia' stato verificato come esistente in S1.
        return $true
    }
}
function Test-WriteAllowed([string]$dir) {
    $probe = Join-Path $dir ('.film_probe_' + [guid]::NewGuid().ToString('N'))
    try {
        $fs = New-Object System.IO.FileStream($probe, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::None, 4096, [System.IO.FileOptions]::DeleteOnClose)
        $fs.Dispose()
        return $true
    } catch { return $false }
}
function Assert-NoReparseTree([string]$root) {
    foreach ($it in @(Get-Item -LiteralPath $root -Force) + @(Get-ChildItem -LiteralPath $root -Recurse -Force)) {
        if ($it.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { Stop-Film "junction/symlink in $($it.FullName)" }
    }
}

# ---------------- S1 identita' Sandbox ----------------
Write-Host "== S1: ambiente Windows Sandbox =="
if ($env:USERNAME -ne 'WDAGUtilityAccount') { Stop-Film "questo script funziona SOLO dentro Windows Sandbox (utente attuale: $env:USERNAME). Sull'host usare avvia_claude_locale.ps1." }
$cfgFile = Join-Path $ConfigDir 'FILM_SANDBOX.json'
if (-not (Test-Path -LiteralPath $cfgFile -PathType Leaf)) { Stop-Film "configurazione assente: $cfgFile (generarla sull'host con genera_film_sandbox.ps1)." }
$cfg = Get-Content -LiteralPath $cfgFile -Raw | ConvertFrom-Json
if ($cfg.Format -ne 'FILM_SANDBOX_CONFIG_V1') { Stop-Film "formato configurazione sconosciuto." }
if ([string]$cfg.Commit -ne $ExpectedCommit.ToLowerInvariant()) { Stop-Film "commit della configurazione ($($cfg.Commit)) diverso da -ExpectedCommit." }
if ($cfg.OriginalGameMapped -ne $false) { Stop-Film "la configurazione non dichiara l'esclusione del gioco originale." }
$P = $cfg.SandboxPaths
$expectedPaths = [ordered]@{ Archive = 'C:\FILM\ARCHIVI_RO'; Repo = 'C:\FILM\REPO'; Config = 'C:\FILM\CONFIG'; Results = 'C:\FILM\RISULTATI' }
foreach ($k in $expectedPaths.Keys) {
    if ([string]$P.$k -ne $expectedPaths[$k]) { Stop-Film "percorso Sandbox inatteso per ${k}: $($P.$k)" }
    if (-not (Test-Path -LiteralPath $expectedPaths[$k] -PathType Container)) { Stop-Film "cartella condivisa assente: $($expectedPaths[$k])" }
}
$drives = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Za-z]:\\$' } | ForEach-Object { $_.Name })
if ($drives.Count -ne 1 -or $drives[0] -ne 'C') { Stop-Film "unita' di file system inattese nella Sandbox: $($drives -join ', ')" }
Write-Host "OK: utente WDAGUtilityAccount, configurazione V1 al commit $($cfg.Commit), solo unita' C:."

# ---------------- S2 sola lettura empirica ----------------
Write-Host "== S2: prove di scrittura =="
foreach ($d in @($expectedPaths.Archive, $expectedPaths.Repo, $expectedPaths.Config)) {
    if (-not (Test-WriteDenied $d)) { Stop-Film "$d NON e' in sola lettura (la creazione di un file e' riuscita; il file di prova e' stato eliminato)." }
    Write-Host "Sola lettura confermata: $d"
}
if (-not (Test-WriteAllowed $expectedPaths.Results)) { Stop-Film "$($expectedPaths.Results) non e' scrivibile: i risultati non sarebbero salvati." }
Write-Host "Scrivibile (persistente sull'host): $($expectedPaths.Results)"

# ---------------- S3 copia archivi ----------------
Write-Host "== S3: copia archivi =="
Assert-NoReparseTree $expectedPaths.Archive
$mfPath = Join-Path $expectedPaths.Archive 'MANIFEST_ARCHIVI.json'
if (-not (Test-Path -LiteralPath $mfPath -PathType Leaf)) { Stop-Film "manifest assente nella copia." }
if ((Get-FileHash -LiteralPath $mfPath -Algorithm SHA256).Hash -ne [string]$cfg.ArchiveManifestSha256) { Stop-Film "manifest della copia diverso da quello verificato sull'host." }
$m = Get-Content -LiteralPath $mfPath -Raw | ConvertFrom-Json
if ($m.Format -ne 'FILM_PRIVATE_ACII_COPY_V2') { Stop-Film "manifest non V2." }
$expected = @{ 'MANIFEST_ARCHIVI.json' = $true }
foreach ($c in @($m.Copies)) { $expected[[string]$c.RelativePath] = $true }
foreach ($it in @(Get-ChildItem -LiteralPath $expectedPaths.Archive -Recurse -File -Force)) {
    $rel = $it.FullName.Substring($expectedPaths.Archive.Length + 1)
    if (-not $expected.ContainsKey($rel)) { Stop-Film "file inatteso nella copia: $rel" }
}
foreach ($c in @($m.Copies)) {
    $f = Join-Path $expectedPaths.Archive ([string]$c.RelativePath)
    if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { Stop-Film "file mancante: $($c.RelativePath)" }
    if ((Get-Item -LiteralPath $f -Force).Length -ne [long]$c.Bytes) { Stop-Film "dimensione diversa: $($c.RelativePath)" }
    if ((Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash -ne [string]$c.SHA256) { Stop-Film "SHA256 diverso: $($c.RelativePath)" }
    Write-Host "Verificato SHA256: $($c.RelativePath)"
}

# ---------------- S4 capitolato ----------------
Write-Host "== S4: capitolato FILM (clone in sola lettura) =="
$capFile = Join-Path $ConfigDir 'CAPITOLATO_SHA256.txt'
if ((Get-FileHash -LiteralPath $capFile -Algorithm SHA256).Hash -ne [string]$cfg.CapitolatoSha256) { Stop-Film "elenco SHA256 del capitolato alterato." }
$n = 0
foreach ($line in @(Get-Content -LiteralPath $capFile)) {
    if (-not $line) { continue }
    if ($line -notmatch '^([0-9A-F]{64})  (.+)$') { Stop-Film "riga non valida nel manifest del capitolato: $line" }
    $h = $Matches[1]; $rel = $Matches[2]
    if ($rel -match '(^|/)\.\.(/|$)' -or $rel -match '^[A-Za-z]:' -or $rel.StartsWith('/')) { Stop-Film "percorso non ammesso: $rel" }
    $f = Join-Path $expectedPaths.Repo ($rel -replace '/', '\')
    if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { Stop-Film "file del capitolato mancante: $rel" }
    if ((Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash -ne $h) { Stop-Film "file del capitolato diverso dal commit atteso: $rel" }
    $n++
}
Write-Host "Capitolato verificato: $n file al commit $($cfg.Commit)."

# ---------------- S5 rete (informativa) ----------------
Write-Host "== S5: rete (informativa) =="
foreach ($h in @('api.anthropic.com', 'claude.ai')) {
    try {
        $c = New-Object System.Net.Sockets.TcpClient
        $ok = $c.ConnectAsync($h, 443).Wait(5000) -and $c.Connected
        $c.Dispose()
        Write-Host ("{0}:443 raggiungibile: {1}" -f $h, $ok)
    } catch { Write-Host ("{0}:443 raggiungibile: False ({1})" -f $h, $_.Exception.Message) }
}
Write-Host "Nota: con la rete attiva la Sandbox vede anche la rete locale. Cio' che Claude legge viene inviato ai modelli Anthropic tramite il tuo account."

# ---------------- S6 Claude Code ----------------
Write-Host "== S6: Claude Code =="
$claude = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claude -and (Test-Path -LiteralPath (Join-Path $env:USERPROFILE '.local\bin\claude.exe'))) {
    $env:Path = (Join-Path $env:USERPROFILE '.local\bin') + ';' + $env:Path
    $claude = Get-Command claude -ErrorAction SilentlyContinue
}
if ($claude) { Write-Host "CLI: $($claude.Source)"; & $claude.Source --version }
elseif ($InstallaClaudeCode -and -not $SoloVerifica) {
    # Installer ufficiale documentato (https://code.claude.com/docs/en/setup): scaricato in un file, mostrato, poi eseguito.
    $installer = Join-Path $env:TEMP ('claude_install_' + [guid]::NewGuid().ToString('N') + '.ps1')
    Invoke-WebRequest -Uri 'https://claude.ai/install.ps1' -OutFile $installer -UseBasicParsing
    Write-Host ("Installer scaricato in {0} ({1} byte, SHA256 {2}). Puoi aprirlo con notepad prima di confermare." -f $installer, (Get-Item -LiteralPath $installer).Length, (Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash)
    if ((Read-Host "Digitare INSTALLA per eseguire l'installer ufficiale di Claude Code (solo in questa Sandbox)") -cne 'INSTALLA') { Stop-Film "installazione annullata." }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer
    if ($LASTEXITCODE -ne 0) { Stop-Film "installer terminato con codice $LASTEXITCODE." }
    $env:Path = (Join-Path $env:USERPROFILE '.local\bin') + ';' + $env:Path
    $claude = Get-Command claude -ErrorAction SilentlyContinue
    if (-not $claude) { Stop-Film "Claude Code non risulta installato dopo l'installer." }
    & $claude.Source --version
} else {
    Write-Host "Claude Code non installato in questa Sandbox. Per installarlo (ogni sessione, la Sandbox e' temporanea):"
    Write-Host "  rieseguire questo script con -InstallaClaudeCode (senza -SoloVerifica), oppure: irm https://claude.ai/install.ps1 | iex"
}

# ---------------- S7 area di lavoro e configurazioni ----------------
Write-Host "== S7: area di lavoro e configurazioni Claude =="
$work = 'C:\FILM\LAVORO'
foreach ($n2 in @('.claude', 'CLAUDE.md', 'CLAUDE.local.md', '.mcp.json')) {
    if (Test-Path -LiteralPath (Join-Path $work $n2)) { Stop-Film "configurazione preesistente in ${work}: $n2 (riaprire una Sandbox nuova)." }
}
foreach ($anc in @('C:\FILM', 'C:\')) {
    foreach ($n2 in @('CLAUDE.md', 'CLAUDE.local.md', '.claude')) {
        if (Test-Path -LiteralPath (Join-Path $anc $n2)) { Stop-Film "istruzioni Claude ereditabili in $(Join-Path $anc $n2)." }
    }
}
$userSettings = Join-Path $env:USERPROFILE '.claude\settings.json'
if (Test-Path -LiteralPath $userSettings) {
    $us = Get-Content -LiteralPath $userSettings -Raw | ConvertFrom-Json
    if (($us.permissions -and $us.permissions.allow -and @($us.permissions.allow).Count -gt 0) -or $us.hooks -or $us.mcpServers -or
        ($us.permissions -and $us.permissions.defaultMode -and @('default', 'plan') -notcontains $us.permissions.defaultMode)) {
        Stop-Film "configurazione utente Claude permissiva in $userSettings."
    }
}
Write-Host "OK: nessuna configurazione preesistente."

if ($SoloVerifica) {
    Write-Host ""
    Write-Host "VERIFICA COMPLETATA (S1-S7). Nulla e' stato scritto, Claude NON e' stato avviato."
    Write-Host "Per proseguire: powershell -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`" -ExpectedCommit $ExpectedCommit [-InstallaClaudeCode]"
    return
}

# ---------------- Preparazione (solo con conferma) ----------------
if ((Read-Host "Digitare PREPARA per creare $work con le istruzioni e i permessi di Claude") -cne 'PREPARA') { Write-Host "Annullato."; return }
New-Item -ItemType Directory -Path $work -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $work '.claude') -ErrorAction Stop | Out-Null
$settings = [ordered]@{
    env         = [ordered]@{ CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = '1' }
    permissions = [ordered]@{
        defaultMode                  = 'plan'
        disableBypassPermissionsMode = 'disable'
        disableAutoMode              = 'disable'
        deny                         = @(
            'Edit(//c/FILM/ARCHIVI_RO/**)', 'Edit(//c/FILM/REPO/**)', 'Edit(//c/FILM/CONFIG/**)',
            'Bash(git push *)', 'Bash(curl *)', 'Bash(wget *)',
            'PowerShell(git push *)', 'PowerShell(Invoke-WebRequest *)', 'PowerShell(Invoke-RestMethod *)',
            'PowerShell(Start-BitsTransfer *)', 'PowerShell(Remove-Item *)', 'WebFetch'
        )
        ask                          = @('Bash', 'PowerShell', 'Edit')
    }
}
$settings | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $work '.claude\settings.json') -Encoding UTF8
@"
# FILM - Claude Code in WINDOWS SANDBOX (commit $($cfg.Commit))
PRIMA DI L0 leggere: C:\FILM\REPO\CLAUDE.md, C:\FILM\REPO\README.md, C:\FILM\REPO\docs\05_DECISIONI.md,
C:\FILM\REPO\docs\ricerca_massiva\ (in particolare SANDBOX_WINDOWS.md, OPZIONE2_ARCHIVI_COPIATI.md,
PIPELINE_E_STATO_ANTEPRIMA.md, LIMITI_E_DIRITTI.md); dichiarare all'utente il commit $($cfg.Commit) e attendere conferma.
- ARCHIVI: C:\FILM\ARCHIVI_RO (SOLA LETTURA). Se un tool deve scrivere accanto all'archivio, copiarlo prima in C:\FILM\LAVORO.
- LAVORO TEMPORANEO: C:\FILM\LAVORO (si perde alla chiusura della Sandbox).
- RISULTATI DA CONSERVARE: SOLO in C:\FILM\RISULTATI (persistenti sull'host). Mai file del gioco destinati a GitHub.
- Il gioco originale NON e' presente nella Sandbox: non cercarlo.
- Nessun download, nessun upload, nessun push. Fasi L0-L6 con STOP e consenso. Restare in plan finche' l'utente non approva.
- Voci solo originali italiane, mai sintesi/clonazione/modifica. Un solo frame finale con Desmond e Lucy; niente 15 minuti.
"@ | Set-Content -LiteralPath (Join-Path $work 'CLAUDE.md') -Encoding UTF8
Write-Host "Preparato $work."
if (-not $claude) { Write-Host "Claude Code non installato: avvio saltato (vedi S6)."; return }
if ((Read-Host "Digitare AVVIA per aprire Claude Code in modalita' plan in $work") -cne 'AVVIA') { Write-Host "Avvio annullato."; return }
Push-Location -LiteralPath $work
try { & $claude.Source --permission-mode plan --add-dir $expectedPaths.Results --add-dir $expectedPaths.Archive --add-dir $expectedPaths.Repo }
finally { Pop-Location }
