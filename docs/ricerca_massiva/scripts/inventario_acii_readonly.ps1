<#
.SYNOPSIS
  Inventario IN SOLA LETTURA della COPIA PRIVATA di Assassin's Creed II (progetto FILM, incarico #12).

.DESCRIPTION
  - Legge soltanto: nomi, dimensioni, date dei file e (facoltativo) hash.
  - NON modifica, sposta, rinomina, cancella o crea file nella copia degli archivi.
  - NON avvia il gioco, il launcher o altri programmi; NON usa la rete.
  - Scrive unicamente in -OutDir, che deve stare FUORI dalla cartella della copia privata:
    lo script si ferma se -OutDir coincide con -ArchiveDir, se e' dentro -ArchiveDir,
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

.PARAMETER ArchiveDir
  Cartella PRIVATA degli archivi copiati di AC II (es. la cartella indicata da Ubisoft Connect).

.PARAMETER OutDir
  Cartella privata di output, esterna al gioco (es. D:\FILM_PRIVATO\inventario).

.PARAMETER Hash
  Se presente, calcola SHA256 dei file elencati (lento sui .forge grandi).

.EXAMPLE
  .\inventario_acii_readonly.ps1 -ArchiveDir "D:\FILM_ARCHIVI_RO" -OutDir "D:\FILM_PRIVATO\inventario"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ArchiveDir,
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
    # potrebbe deviare la scrittura verso la cartella della copia privata.
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

$archive = Get-AbsolutePath $ArchiveDir
$out = Get-AbsolutePath $OutDir

if (-not (Test-Path -LiteralPath $archive -PathType Container)) {
    throw "ArchiveDir non esiste o non e' una cartella: $archive"
}
if ((Test-Path -LiteralPath $out) -and -not (Test-Path -LiteralPath $out -PathType Container)) {
    throw "OutDir esiste ma non e' una cartella: $out"
}

Assert-NoReparsePoint $archive 'ArchiveDir'
Assert-NoReparsePoint $out 'OutDir'

$cmp = [System.StringComparison]::OrdinalIgnoreCase
if ($out.Equals($archive, $cmp)) {
    throw "OutDir coincide con ArchiveDir. Scegliere una cartella privata esterna al gioco."
}
if (($out + '\').StartsWith($archive + '\', $cmp) -or ($archive + '\').StartsWith($out + '\', $cmp)) {
    throw "OutDir non puo' trovarsi dentro la cartella della copia privata. Scegliere una cartella privata esterna."
}

Write-Host "ArchiveDir (copia SOLA LETTURA): $archive"
Write-Host "OutDir  (scrittura)   : $out"

if (-not (Test-Path -LiteralPath $out)) {
    New-Item -ItemType Directory -Path $out | Out-Null
}

$extensions = @('.forge', '.pck')
# Gli errori non bloccano la scansione ma vengono raccolti e riportati (inventario INCOMPLETO).
$files = Get-ChildItem -LiteralPath $archive -Recurse -File -Force -ErrorAction SilentlyContinue -ErrorVariable listErrors |
    Where-Object { $extensions -contains $_.Extension.ToLowerInvariant() }
$readErrors = @($listErrors)

$rows = foreach ($f in $files) {
    if ($f.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { throw "Reparse point nella copia: $($f.FullName)" }
    $sha = ''
    if ($Hash) {
        try { $sha = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash }
        catch { $readErrors += $_; $sha = 'ERRORE_LETTURA' }
    }
    [pscustomobject]@{
        RelativePath  = $f.FullName.Substring($archive.Length + 1)
        Bytes         = $f.Length
        LastWriteTime = $f.LastWriteTime.ToString('s')
        SHA256        = $sha
    }
}

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$csv = Join-Path $out "inventario_acii_$stamp.csv"
$rows | Sort-Object RelativePath | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8

# Per sicurezza NON cerchiamo l'EXE originale e NON apriamo l'installazione.
# L'inventario descrive soltanto gli archivi copiati nel percorso privato.
Write-Host "Inventario limitato alla copia; eseguibile originale e altri file non copiati: NON VERIFICATI."

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
