<#
.SYNOPSIS
  Staging manuale e NON distruttivo di archivi AC II dal gioco originale a una copia privata.
.DESCRIPTION
  Eseguire PRIMA di avviare Claude, dall'account Windows che gia' legge i file Ubisoft Connect.
  Default: copia soltanto DataPC_Abstergo.forge. Gli archivi audio e Hideout sono
  opzionali e richiedono consenso separato. Nessuna copia automatica di EXE o DRM.
  -DryRun stampa il piano, senza creare cartelle o copiare file.
  I file del gioco vengono SOLO letti; nessuna modifica a permessi, file o registro.
  Manifest JSON locale con SHA256 e dimensioni; ripetere il confronto prima dell'uso.
  Questo script NON imposta ACL sulla copia: farlo manualmente prima di Claude.
  Script non eseguito/testato su Windows in questa sessione.
.EXAMPLE
  .\prepara_copia_privata_acii.ps1 -GameDir "D:\Games\Assassin's Creed II" -ArchiveDir "D:\FILM_ARCHIVI_RO" -DryRun
  .\prepara_copia_privata_acii.ps1 -GameDir "D:\Games\Assassin's Creed II" -ArchiveDir "D:\FILM_ARCHIVI_RO"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$GameDir,
    [Parameter(Mandatory=$true)][string]$ArchiveDir,
    [switch]$IncludeHideout,
    [switch]$IncludeItalianVoices,
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

function Absolute([string]$p) {
    $full = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
    return [System.IO.Path]::GetFullPath($full).TrimEnd('\')
}
function Assert-NoReparse([string]$path) {
    $q = $path
    while ($q) {
        if (Test-Path -LiteralPath $q) {
            $it = Get-Item -LiteralPath $q -Force
            if ($it.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                throw "Junction/symlink non consentito: $q"
            }
        }
        $up = Split-Path -Path $q -Parent
        if (-not $up -or $up -eq $q) { break }
        $q = $up
    }
}
function Assert-Independent([string]$a,[string]$b) {
    $cmp = [StringComparison]::OrdinalIgnoreCase
    if ($a.Equals($b,$cmp) -or ($a+'\').StartsWith($b+'\',$cmp) -or ($b+'\').StartsWith($a+'\',$cmp)) {
        throw "Le due cartelle devono essere separate, senza inclusione reciproca: $a / $b"
    }
}
$game = Absolute $GameDir
$dest = Absolute $ArchiveDir
if (-not (Test-Path -LiteralPath $game -PathType Container)) { throw "GameDir non trovato: $game" }
if (Test-Path -LiteralPath $dest) { throw "Destinazione gia' esistente: $dest. Non sovrascrivo mai copie o manifest precedenti." }
Assert-NoReparse $game
Assert-NoReparse $dest
Assert-Independent $game $dest

$relative = @('DataPC_Abstergo.forge')
if ($IncludeHideout) { $relative += 'DataPC_Hideout.forge' }
if ($IncludeItalianVoices) { $relative += 'SoundData\pc\sounds_ita.pck' }
$files = @()
foreach ($name in $relative) {
    $from = Join-Path $game $name
    Assert-NoReparse $from
    if (-not (Test-Path -LiteralPath $from -PathType Leaf)) { throw "File assente nella copia Ubisoft Connect: $from" }
    $item = Get-Item -LiteralPath $from -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { throw "File link, non accettato: $from" }
    $files += [pscustomobject]@{ Name=$name; Path=$from; Bytes=[long]$item.Length }
}
$needed = [long](($files | Measure-Object -Property Bytes -Sum).Sum)
$drive = [System.IO.DriveInfo]::new([System.IO.Path]::GetPathRoot($dest))
if (-not $drive.IsReady -or $drive.AvailableFreeSpace -lt ($needed + 100MB)) { throw "Spazio insufficiente nella destinazione." }
Write-Host "ORIGINALE SOLO LETTURA: $game"
Write-Host "DESTINAZIONE PRIVATA:  $dest"
foreach($f in $files) { Write-Host ("COPIA PROPOSTA  {0}  ({1:N0} byte)" -f $f.Name,$f.Bytes) }
Write-Host "Spazio minimo dei dati: $needed byte"
if ($DryRun) { Write-Host "DRY RUN: nulla creato, nulla copiato."; return }
$answer = Read-Host "Digitare COPIA per creare la cartella privata e copiare soltanto questi archivi"
if ($answer -cne 'COPIA') { Write-Host "Annullato, nessuna scrittura."; return }
if (Test-Path -LiteralPath $dest) { throw "Destinazione creata da un altro processo: stop." }
New-Item -ItemType Directory -Path $dest -ErrorAction Stop | Out-Null
Assert-NoReparse $dest
Assert-Independent $game $dest

$manifestFiles = @()
foreach ($f in $files) {
    $from = $f.Path
    Assert-NoReparse $from
    $target = Join-Path $dest $f.Name
    $parent = Split-Path -Path $target -Parent
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop | Out-Null
    }
    Assert-NoReparse $parent
    if (Test-Path -LiteralPath $target) { throw "File gia' presente: $target" }
    $before = (Get-FileHash -LiteralPath $from -Algorithm SHA256).Hash
    Copy-Item -LiteralPath $from -Destination $target -ErrorAction Stop
    if (Test-Path -LiteralPath $target -PathType Leaf) {
        $copy = Get-Item -LiteralPath $target -Force
        $after = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
    } else { throw "La copia non e' stata creata: $target" }
    if ($before -ne $after -or $copy.Length -ne $f.Bytes) { throw "HASH/DIMENSIONE NON CORRISPONDENTE: $($f.Name). Non utilizzare la copia." }
    $manifestFiles += [pscustomobject]@{RelativePath=$f.Name; Bytes=[long]$f.Bytes; SHA256=$after}
    Write-Host "Verificato SHA256: $($f.Name)"
}
$manifest = [ordered]@{
    Format = 'FILM_PRIVATE_ACII_COPY_V1'
    GameEdition = 'Assassins Creed II PC Ubisoft Connect - attribuzione utente, file verificati da script'
    Copies = @($manifestFiles)
    WindowsAclReadOnly = 'NON VERIFICATO: configurare ACL della copia per account Claude dedicato'
    OriginalChanged = "Non e' stata invocata alcuna operazione di scrittura sul percorso GameDir"
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $dest 'MANIFEST_ARCHIVI.json') -Encoding UTF8
Write-Host "COPIA CONCLUSa: $dest"
Write-Warning "La cartella copia e' ancora modificabile dall'account che l'ha creata. Proteggere l'accesso del diverso account Claude con ACL Windows (sola lettura) prima di usare il launcher. NON toccare le ACL del gioco."
