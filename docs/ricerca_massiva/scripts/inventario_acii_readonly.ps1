<#
.SYNOPSIS
  Inventario IN SOLA LETTURA dell'installazione di Assassin's Creed II (progetto FILM, incarico #12).

.DESCRIPTION
  - Legge soltanto: nomi, dimensioni, date dei file e (facoltativo) hash.
  - NON modifica, sposta, rinomina, cancella o crea file nella cartella del gioco.
  - NON avvia il gioco, il launcher o altri programmi; NON usa la rete.
  - Scrive unicamente in -OutDir, che deve stare FUORI dalla cartella del gioco:
    lo script si ferma se -OutDir coincide con -GameDir, se e' dentro -GameDir,
    o se un componente esistente di uno dei due percorsi e' una junction/symlink
    (reparse point), perche' in quel caso la destinazione reale non e' verificabile.
  - Percorsi relativi: vengono risolti rispetto alla cartella corrente di PowerShell
    (Get-Location) e il percorso assoluto risultante viene stampato prima di procedere.
    Si consiglia comunque di passare percorsi assoluti.
  - Gli errori di lettura NON vengono nascosti: sono contati, salvati in un file
    *_errori.txt accanto al CSV e l'inventario viene dichiarato INCOMPLETO.
  - L'MD5 dell'eseguibile serve SOLO a confrontare la build con quella testata da
    ac2-rtx; non e' una verifica di sicurezza o integrita' del binario.
  - Il CSV e' un file PRIVATO: non caricarlo su GitHub (contiene percorsi locali).
  - Script NON ancora eseguito ne' testato (scritto in una sessione senza PowerShell):
    rileggerlo prima dell'uso.

.PARAMETER GameDir
  Cartella di installazione di AC II (es. la cartella indicata da Ubisoft Connect).

.PARAMETER OutDir
  Cartella privata di output, esterna al gioco (es. D:\FILM_PRIVATO\inventario).

.PARAMETER Hash
  Se presente, calcola SHA256 dei file elencati (lento sui .forge grandi).

.EXAMPLE
  .\inventario_acii_readonly.ps1 -GameDir "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games\Assassin's Creed II" -OutDir "D:\FILM_PRIVATO\inventario"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$GameDir,
    [Parameter(Mandatory = $true)][string]$OutDir,
    [switch]$Hash
)

$ErrorActionPreference = 'Stop'

function Get-AbsolutePath([string]$p) {
    # Risolve i relativi rispetto alla posizione di PowerShell (non alla cwd del processo).
    $full = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($p)
    return [System.IO.Path]::GetFullPath($full).TrimEnd('\')
}

function Assert-NoReparsePoint([string]$path, [string]$label) {
    # Controlla ogni componente ESISTENTE del percorso: una junction/symlink
    # potrebbe deviare la scrittura verso la cartella del gioco.
    $cur = $path
    while ($cur) {
        if (Test-Path -LiteralPath $cur) {
            $item = Get-Item -LiteralPath $cur -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                throw "$label contiene una junction/symlink ($cur). Usare un percorso reale senza collegamenti."
            }
        }
        $parent = Split-Path -Path $cur -Parent
        if ($parent -eq $cur) { break }
        $cur = $parent
    }
}

$game = Get-AbsolutePath $GameDir
$out = Get-AbsolutePath $OutDir

if (-not (Test-Path -LiteralPath $game -PathType Container)) {
    throw "GameDir non esiste o non e' una cartella: $game"
}
if ((Test-Path -LiteralPath $out) -and -not (Test-Path -LiteralPath $out -PathType Container)) {
    throw "OutDir esiste ma non e' una cartella: $out"
}

Assert-NoReparsePoint $game 'GameDir'
Assert-NoReparsePoint $out 'OutDir'

$cmp = [System.StringComparison]::OrdinalIgnoreCase
if ($out.Equals($game, $cmp)) {
    throw "OutDir coincide con GameDir. Scegliere una cartella privata esterna al gioco."
}
if (($out + '\').StartsWith($game + '\', $cmp)) {
    throw "OutDir non puo' trovarsi dentro la cartella del gioco. Scegliere una cartella privata esterna."
}

Write-Host "GameDir (sola lettura): $game"
Write-Host "OutDir  (scrittura)   : $out"

if (-not (Test-Path -LiteralPath $out)) {
    New-Item -ItemType Directory -Path $out | Out-Null
}

$extensions = @('.forge', '.pck', '.bik', '.exe', '.dll', '.ini')
# Gli errori non bloccano la scansione ma vengono raccolti e riportati (inventario INCOMPLETO).
$files = Get-ChildItem -LiteralPath $game -Recurse -File -Force -ErrorAction SilentlyContinue -ErrorVariable listErrors |
    Where-Object { $extensions -contains $_.Extension.ToLowerInvariant() }
$readErrors = @($listErrors)

$rows = foreach ($f in $files) {
    $sha = ''
    if ($Hash) {
        try { $sha = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash }
        catch { $readErrors += $_; $sha = 'ERRORE_LETTURA' }
    }
    [pscustomobject]@{
        RelativePath  = $f.FullName.Substring($game.Length + 1)
        Bytes         = $f.Length
        LastWriteTime = $f.LastWriteTime.ToString('s')
        SHA256        = $sha
    }
}

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$csv = Join-Path $out "inventario_acii_$stamp.csv"
$rows | Sort-Object RelativePath | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8

$exe = Get-ChildItem -LiteralPath $game -Filter 'AssassinsCreedIIGame.exe' -File -ErrorAction SilentlyContinue | Select-Object -First 1
if ($exe) {
    try {
        $md5 = (Get-FileHash -LiteralPath $exe.FullName -Algorithm MD5).Hash.ToLowerInvariant()
        $ref = '2dd4d3c196fa270945826d2faab42007'
        Write-Host "MD5 AssassinsCreedIIGame.exe: $md5 (solo confronto di build per ac2-rtx, non verifica di sicurezza)"
        if ($md5 -eq $ref) { Write-Host "Coincide con la build testata da ac2-rtx." }
        else { Write-Host "Diversa dalla build testata da ac2-rtx ($ref): le sue patch potrebbero non applicarsi." }
    } catch { $readErrors += $_; Write-Warning "MD5 dell'eseguibile non calcolabile: $($_.Exception.Message)" }
} else {
    Write-Host "AssassinsCreedIIGame.exe non trovato nella cartella principale (verificare il percorso)."
}

$check = @('DataPC_Abstergo.forge', 'DataPC_Hideout.forge', 'DataPC_WhiteRoom.forge', 'DataPC.forge', 'DataPC_Firenze.forge', 'sounds_ita.pck')
foreach ($name in $check) {
    $hit = $rows | Where-Object { (Split-Path -Leaf $_.RelativePath) -eq $name } | Select-Object -First 1
    if ($hit) { Write-Host ("TROVATO  {0}  ({1:N0} byte)" -f $hit.RelativePath, $hit.Bytes) }
    else { Write-Host "MANCANTE $name" }
}

if ($readErrors.Count -gt 0) {
    $errFile = Join-Path $out "inventario_acii_${stamp}_errori.txt"
    $readErrors | ForEach-Object { $_.ToString() } | Set-Content -LiteralPath $errFile -Encoding UTF8
    Write-Warning "INVENTARIO INCOMPLETO: $($readErrors.Count) errori di lettura. Dettagli in: $errFile"
} else {
    Write-Host "Inventario completo: nessun errore di lettura."
}
Write-Host "CSV privato scritto in: $csv  (non caricarlo su GitHub)"
