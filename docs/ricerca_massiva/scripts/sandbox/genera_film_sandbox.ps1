<#
.SYNOPSIS
  FILM - genera (sul PC host) la configurazione Windows Sandbox per eseguire Claude Code sulla COPIA
  privata degli archivi, con archivio e capitolato in SOLA LETTURA e risultati persistenti separati.

.DESCRIPTION
  Eseguire sull'HOST, con l'account dell'utente, in PowerShell NON elevato. Non avvia la Sandbox, non
  avvia Claude, non scarica nulla. Non legge ne' mappa l'installazione originale del gioco: -OriginalGameDir
  serve SOLO a verificare che nessuna cartella condivisa coincida, contenga o sia contenuta nel gioco.

  Cartelle condivise nella Sandbox (MappedFolders):
    host ArchiveDir  -> C:\FILM\ARCHIVI_RO   ReadOnly=true   (copia privata, manifest V2 verificato qui)
    host RepoDir     -> C:\FILM\REPO         ReadOnly=true   (clone FILM al commit atteso, pulito)
    host ConfigDir   -> C:\FILM\CONFIG       ReadOnly=true   (configurazione e manifest generati qui)
    host ResultsDir  -> C:\FILM\RISULTATI    ReadOnly=false  (UNICA cartella scrivibile: risultati persistenti)
  La cartella di lavoro di Claude (C:\FILM\LAVORO) vive SOLO dentro la Sandbox e sparisce alla chiusura.

  Controlli (fail-closed): percorsi locali, non radici di unita', senza junction/symlink, tutti separati tra
  loro e dal gioco; manifest V2 della copia con contenuto esatto e SHA256; clone FILM con HEAD = -ExpectedCommit
  e git status vuoto; ConfigDir nuova. -DryRun mostra controlli e file .wsb senza scrivere nulla.

  Scrive SOLO in ConfigDir (FILM_SANDBOX.wsb, FILM_SANDBOX.json, CAPITOLATO_SHA256.txt) e crea ResultsDir se manca.
  Script NON TESTATO SU WINDOWS: vedi TEST_WINDOWS_SANDBOX.md.

.EXAMPLE
  .\genera_film_sandbox.ps1 -OriginalGameDir "D:\Games\Assassin's Creed II" -ArchiveDir "D:\FILM_ARCHIVI_RO" -ResultsDir "D:\FILM_RISULTATI_SANDBOX" -ConfigDir "D:\FILM_SANDBOX_CONFIG" -ExpectedCommit <SHA40> -DryRun
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$OriginalGameDir,
    [Parameter(Mandatory = $true)][string]$ArchiveDir,
    [Parameter(Mandatory = $true)][string]$ResultsDir,
    [Parameter(Mandatory = $true)][string]$ConfigDir,
    [Parameter(Mandatory = $true)][ValidatePattern('^[0-9a-fA-F]{40}$')][string]$ExpectedCommit,
    [string]$RepoDir,
    [ValidateRange(4096, 65536)][int]$MemoryInMB = 8192,
    [ValidateSet('Enable', 'Disable')][string]$ProtectedClient = 'Enable',
    [ValidateSet('Enable', 'Disable')][string]$VGpu = 'Disable',
    [ValidateSet('Enable', 'Disable')][string]$ClipboardRedirection = 'Disable',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

$SandboxPaths = [ordered]@{
    Archive = 'C:\FILM\ARCHIVI_RO'
    Repo    = 'C:\FILM\REPO'
    Config  = 'C:\FILM\CONFIG'
    Results = 'C:\FILM\RISULTATI'
}

function Get-AbsolutePath([string]$p) {
    $full = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
    return [System.IO.Path]::GetFullPath($full).TrimEnd('\')
}
function Assert-LocalPath([string]$p, [string]$label) {
    if ($p -notmatch '^[A-Za-z]:\\.+') { throw "$label deve essere un percorso locale con lettera di unita', non una radice o un percorso UNC: $p" }
    $profileRoot = [System.IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\')
    if ($p.Equals($profileRoot, [System.StringComparison]::OrdinalIgnoreCase)) { throw "$label non puo' essere l'intero profilo utente: $p" }
}
function Assert-NoReparsePoint([string]$path, [string]$label) {
    $cur = $path
    while ($cur) {
        if ((Test-Path -LiteralPath $cur) -and ((Get-Item -LiteralPath $cur -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            throw "$label contiene una junction/symlink: $cur"
        }
        $up = Split-Path -Path $cur -Parent
        if (-not $up -or $up -eq $cur) { break }
        $cur = $up
    }
}
function Assert-Separated([string]$a, [string]$b, [string]$label) {
    $cmp = [System.StringComparison]::OrdinalIgnoreCase
    if ($a.Equals($b, $cmp) -or ($a + '\').StartsWith($b + '\', $cmp) -or ($b + '\').StartsWith($a + '\', $cmp)) {
        throw "Percorsi non separati ($label): '$a' / '$b'."
    }
}
function ConvertTo-XmlText([string]$s) { return [System.Security.SecurityElement]::Escape($s) }

# Costruisce il file .wsb. Funzione pura (nessun accesso a disco): verificata anche dalla suite statica.
function New-FilmWsbXml([string]$archiveHost, [string]$repoHost, [string]$configHost, [string]$resultsHost,
    [string]$commit, [int]$memory, [string]$protected, [string]$vgpu, [string]$clipboard) {
    $maps = @(
        @{ Host = $archiveHost; Box = $SandboxPaths.Archive; Ro = 'true' },
        @{ Host = $repoHost; Box = $SandboxPaths.Repo; Ro = 'true' },
        @{ Host = $configHost; Box = $SandboxPaths.Config; Ro = 'true' },
        @{ Host = $resultsHost; Box = $SandboxPaths.Results; Ro = 'false' }
    )
    $mf = foreach ($m in $maps) {
        "    <MappedFolder>`r`n      <HostFolder>$(ConvertTo-XmlText $m.Host)</HostFolder>`r`n      <SandboxFolder>$(ConvertTo-XmlText $m.Box)</SandboxFolder>`r`n      <ReadOnly>$($m.Ro)</ReadOnly>`r`n    </MappedFolder>"
    }
    $launcher = $SandboxPaths.Repo + '\docs\ricerca_massiva\scripts\sandbox\avvia_claude_sandbox.ps1'
    $logon = "C:\Windows\System32\cmd.exe /c start `"FILM`" powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -File `"$launcher`" -SoloVerifica -ExpectedCommit $commit"
    return @"
<Configuration>
  <!-- FILM - generato da genera_film_sandbox.ps1. Non modificare a mano: rigenerare. -->
  <VGpu>$vgpu</VGpu>
  <Networking>Enable</Networking>
  <AudioInput>Disable</AudioInput>
  <VideoInput>Disable</VideoInput>
  <PrinterRedirection>Disable</PrinterRedirection>
  <ClipboardRedirection>$clipboard</ClipboardRedirection>
  <ProtectedClient>$protected</ProtectedClient>
  <MemoryInMB>$memory</MemoryInMB>
  <MappedFolders>
$($mf -join "`r`n")
  </MappedFolders>
  <LogonCommand>
    <Command>$(ConvertTo-XmlText $logon)</Command>
  </LogonCommand>
</Configuration>
"@
}

# ---------------- Controlli in sola lettura ----------------
Write-Host "== Controlli (sola lettura) =="
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw "Sessione elevata: eseguire da PowerShell NON elevato." }
if (-not $RepoDir) { $RepoDir = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))) }
$game = Get-AbsolutePath $OriginalGameDir
$arch = Get-AbsolutePath $ArchiveDir
$repo = Get-AbsolutePath $RepoDir
$res = Get-AbsolutePath $ResultsDir
$cfg = Get-AbsolutePath $ConfigDir
$all = [ordered]@{ 'gioco originale' = $game; 'copia archivi' = $arch; 'clone FILM' = $repo; 'risultati' = $res; 'configurazione' = $cfg }
foreach ($k in $all.Keys) { Assert-LocalPath $all[$k] $k; Assert-NoReparsePoint $all[$k] $k }
$keys = @($all.Keys)
for ($i = 0; $i -lt $keys.Count; $i++) { for ($j = $i + 1; $j -lt $keys.Count; $j++) { Assert-Separated $all[$keys[$i]] $all[$keys[$j]] "$($keys[$i]) / $($keys[$j])" } }
if (-not (Test-Path -LiteralPath $arch -PathType Container)) { throw "Copia archivi assente: $arch" }
if (-not (Test-Path -LiteralPath $repo -PathType Container)) { throw "Clone FILM assente: $repo" }
if (Test-Path -LiteralPath $cfg) { throw "ConfigDir esiste gia': $cfg. Usare una cartella nuova (nessuna sovrascrittura)." }
if ((Test-Path -LiteralPath $res) -and -not (Test-Path -LiteralPath $res -PathType Container)) { throw "ResultsDir esiste ma non e' una cartella: $res" }

# Copia archivi: manifest V2, contenuto esatto, SHA256.
$mfPath = Join-Path $arch 'MANIFEST_ARCHIVI.json'
if (-not (Test-Path -LiteralPath $mfPath -PathType Leaf)) { throw "Manifest assente: $mfPath" }
$m = Get-Content -LiteralPath $mfPath -Raw | ConvertFrom-Json
if ($m.Format -ne 'FILM_PRIVATE_ACII_COPY_V2') { throw "Manifest non V2 (preparare la copia con prepara_copia_privata_acii.ps1)." }
$expected = @{ 'MANIFEST_ARCHIVI.json' = $true }
foreach ($c in @($m.Copies)) { $expected[[string]$c.RelativePath] = $true }
foreach ($it in @(Get-ChildItem -LiteralPath $arch -Recurse -Force)) {
    if ($it.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { throw "Reparse point nella copia: $($it.FullName)" }
    if (-not $it.PSIsContainer -and -not $expected.ContainsKey($it.FullName.Substring($arch.Length + 1))) { throw "File inatteso nella copia: $($it.FullName)" }
}
foreach ($c in @($m.Copies)) {
    $f = Join-Path $arch ([string]$c.RelativePath)
    if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { throw "File mancante: $f" }
    if ((Get-Item -LiteralPath $f -Force).Length -ne [long]$c.Bytes) { throw "Dimensione diversa: $f" }
    if ((Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash -ne [string]$c.SHA256) { throw "SHA256 diverso: $f" }
    Write-Host "Copia verificata: $($c.RelativePath)"
}
$manifestHash = (Get-FileHash -LiteralPath $mfPath -Algorithm SHA256).Hash

# Clone FILM: commit atteso, pulito; manifest SHA256 dei file versionati (verificato poi dentro la Sandbox, senza git).
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) { throw "git non disponibile sull'host: impossibile certificare il capitolato." }
$head = (& $git.Source -C $repo rev-parse HEAD 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $head) { throw "$repo non e' un clone Git valido." }
$head = $head.Trim().ToLowerInvariant()
if ($head -ne $ExpectedCommit.ToLowerInvariant()) { throw "HEAD $head diverso dal commit atteso $ExpectedCommit." }
$dirty = & $git.Source -C $repo status --porcelain --untracked-files=all
if ($LASTEXITCODE -ne 0 -or $dirty) { throw "Clone FILM non pulito o git status fallito." }
$tracked = @(& $git.Source -C $repo ls-files)
if ($LASTEXITCODE -ne 0 -or $tracked.Count -eq 0) { throw "git ls-files non riuscito." }
$oddNames = @($tracked | Where-Object { $_ -match '[^\x20-\x7E]' -or $_.StartsWith('"') })
if ($oddNames.Count -gt 0) { throw "Nomi di file non ASCII nel clone (non verificabili in modo affidabile): $($oddNames -join ', ')" }
foreach ($req in @('CLAUDE.md', 'README.md', 'docs/ricerca_massiva/scripts/sandbox/avvia_claude_sandbox.ps1')) {
    if ($tracked -notcontains $req) { throw "File richiesto non versionato nel clone: $req" }
}
Write-Host "Clone FILM: commit $head, pulito, $($tracked.Count) file versionati."

$wsb = New-FilmWsbXml $arch $repo $cfg $res $head $MemoryInMB $ProtectedClient $VGpu $ClipboardRedirection
Write-Host ""
Write-Host "== RIEPILOGO =="
Write-Host "Gioco originale (NON condiviso, mai letto da questo script): $game"
Write-Host "Condivisioni: $arch -> $($SandboxPaths.Archive) [sola lettura]; $repo -> $($SandboxPaths.Repo) [sola lettura];"
Write-Host "              $cfg -> $($SandboxPaths.Config) [sola lettura]; $res -> $($SandboxPaths.Results) [SCRIVIBILE, persistente]"
Write-Host "Rete: ABILITATA (necessaria a Claude Code per i modelli Anthropic e per l'installazione). Espone la rete locale alla Sandbox."
Write-Host "ProtectedClient=$ProtectedClient  VGpu=$VGpu  Appunti=$ClipboardRedirection  Memoria=$MemoryInMB MB"
Write-Host ""
Write-Host $wsb
if ($DryRun) { Write-Host "DRY RUN: nessun file scritto, nessuna cartella creata."; return }

if ((Read-Host "Digitare GENERA per creare $cfg (e $res se manca)") -cne 'GENERA') { Write-Host "Annullato. Nessuna modifica."; return }
New-Item -ItemType Directory -Path $cfg -ErrorAction Stop | Out-Null
Assert-NoReparsePoint $cfg 'configurazione'
if (-not (Test-Path -LiteralPath $res)) { New-Item -ItemType Directory -Path $res -ErrorAction Stop | Out-Null }
Assert-NoReparsePoint $res 'risultati'

$capLines = foreach ($t in $tracked) {
    $p = Join-Path $repo ($t -replace '/', '\')
    '{0}  {1}' -f (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash, $t
}
$capLines | Set-Content -LiteralPath (Join-Path $cfg 'CAPITOLATO_SHA256.txt') -Encoding ASCII
$capHash = (Get-FileHash -LiteralPath (Join-Path $cfg 'CAPITOLATO_SHA256.txt') -Algorithm SHA256).Hash
[ordered]@{
    Format                 = 'FILM_SANDBOX_CONFIG_V1'
    Commit                 = $head
    ArchiveManifestSha256  = $manifestHash
    CapitolatoSha256       = $capHash
    SandboxPaths           = $SandboxPaths
    ReadOnlyMaps           = @($SandboxPaths.Archive, $SandboxPaths.Repo, $SandboxPaths.Config)
    WritableMaps           = @($SandboxPaths.Results)
    WorkDir                = 'C:\FILM\LAVORO'
    Networking             = 'Enable'
    OriginalGameMapped     = $false
    Generated              = (Get-Date -Format s)
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $cfg 'FILM_SANDBOX.json') -Encoding ASCII
$wsb | Set-Content -LiteralPath (Join-Path $cfg 'FILM_SANDBOX.wsb') -Encoding UTF8
Write-Host "Creati in ${cfg}: FILM_SANDBOX.wsb, FILM_SANDBOX.json, CAPITOLATO_SHA256.txt."
Write-Host "Avvio: doppio clic su $(Join-Path $cfg 'FILM_SANDBOX.wsb'). Nella Sandbox si apre la VERIFICA (Claude non parte da solo)."
