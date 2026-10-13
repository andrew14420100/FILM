<#
.SYNOPSIS
  Inventario IN SOLA LETTURA dell'installazione di Assassin's Creed II (progetto FILM, incarico #12).

.DESCRIPTION
  - Legge soltanto: nomi, dimensioni, date dei file e (facoltativo) hash.
  - NON modifica, sposta, rinomina, cancella o crea file nella cartella del gioco.
  - NON avvia il gioco, il launcher o altri programmi.
  - Scrive il CSV unicamente in -OutDir, che deve stare FUORI dalla cartella del gioco.
  - Il CSV e' un file PRIVATO: non caricarlo su GitHub (contiene percorsi locali).

.PARAMETER GameDir
  Cartella di installazione di AC II (es. la cartella indicata da Ubisoft Connect).

.PARAMETER OutDir
  Cartella privata di output (es. D:\FILM_PRIVATO\inventario).

.PARAMETER Hash
  Se presente, calcola SHA256 dei file elencati (lento sui .forge grandi).
  L'MD5 dell'eseguibile viene sempre calcolato (serve per la compatibilita' di ac2-rtx).

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

$game = (Resolve-Path -LiteralPath $GameDir).Path.TrimEnd('\')
if (-not (Test-Path -LiteralPath $OutDir)) {
    $out = [System.IO.Path]::GetFullPath($OutDir).TrimEnd('\')
} else {
    $out = (Resolve-Path -LiteralPath $OutDir).Path.TrimEnd('\')
}

# Rifiuta un OutDir dentro la cartella del gioco: nessuna scrittura nell'installazione.
if (($out + '\').StartsWith($game + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "OutDir non puo' trovarsi dentro la cartella del gioco. Scegliere una cartella privata esterna."
}
if (-not (Test-Path -LiteralPath $out)) {
    New-Item -ItemType Directory -Path $out | Out-Null
}

$patterns = @('*.forge', '*.pck', '*.bik', '*.exe', '*.dll', '*.ini')
$files = Get-ChildItem -LiteralPath $game -Recurse -File -Include $patterns -ErrorAction SilentlyContinue

$rows = foreach ($f in $files) {
    $sha = ''
    if ($Hash) { $sha = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash }
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
    $md5 = (Get-FileHash -LiteralPath $exe.FullName -Algorithm MD5).Hash.ToLowerInvariant()
    $ref = '2dd4d3c196fa270945826d2faab42007'
    Write-Host "MD5 AssassinsCreedIIGame.exe: $md5"
    if ($md5 -eq $ref) { Write-Host "Coincide con la build testata da ac2-rtx." }
    else { Write-Host "Diversa dalla build testata da ac2-rtx ($ref): le sue patch potrebbero non applicarsi." }
} else {
    Write-Host "AssassinsCreedIIGame.exe non trovato nella cartella principale (verificare il percorso)."
}

$check = @('DataPC_Abstergo.forge', 'DataPC_Hideout.forge', 'DataPC_WhiteRoom.forge', 'DataPC.forge', 'DataPC_Firenze.forge', 'sounds_ita.pck')
foreach ($name in $check) {
    $hit = $rows | Where-Object { $_.RelativePath -like "*$name" } | Select-Object -First 1
    if ($hit) { Write-Host ("TROVATO  {0}  ({1:N0} byte)" -f $hit.RelativePath, $hit.Bytes) }
    else { Write-Host "MANCANTE $name" }
}
Write-Host "CSV privato scritto in: $csv  (non caricarlo su GitHub)"
