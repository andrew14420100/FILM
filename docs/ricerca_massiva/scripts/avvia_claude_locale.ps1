<#
.SYNOPSIS
  Launcher PROPOSTO per delegare a Claude Code locale il lavoro dell'incarico #12 (progetto FILM),
  con accesso limitato. Vedi docs/ricerca_massiva/CLAUDE_CODE_LOCALE_DELEGA.md.

.DESCRIPTION
  Fase 1 - controlli in SOLA LETTURA: GPU (nvidia-smi), cartella del gioco, cartella privata,
  presenza della CLI 'claude'. Nessuna scrittura.
  Fase 2 - SOLO con conferma digitata dall'utente: crea WorkDir (fuori dal gioco) e, se assenti,
  WorkDir\.claude\settings.json (permessi restrittivi) e WorkDir\CLAUDE.md (regole). Non sovrascrive.
  Fase 3 - SOLO con conferma: avvia 'claude --permission-mode plan' in WorkDir.
  Non avvia il gioco, non scarica nulla, non modifica la cartella del gioco.
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
function Confirm-Step([string]$question) {
    $answer = Read-Host "$question  Digitare SI per procedere"
    return ($answer -ceq 'SI')
}

$game = Get-AbsolutePath $GameDir
$work = Get-AbsolutePath $WorkDir
$cmp = [System.StringComparison]::OrdinalIgnoreCase

Write-Host "== Fase 1: controlli in sola lettura =="
if (-not (Test-Path -LiteralPath $game -PathType Container)) { throw "Cartella del gioco non trovata: $game" }
if ($work.Equals($game, $cmp) -or ($work + '\').StartsWith($game + '\', $cmp) -or ($game + '\').StartsWith($work + '\', $cmp)) {
    throw "WorkDir non deve coincidere con la cartella del gioco, ne' contenerla o esserne contenuta."
}
Write-Host "Cartella gioco (sola lettura): $game"
Write-Host "Cartella privata di lavoro   : $work"

$smi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if ($smi) { & $smi.Source --query-gpu=name,memory.total,driver_version --format=csv,noheader }
else { Write-Warning "nvidia-smi non trovato: GPU NVIDIA non verificabile." }

$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) { Write-Host "CLI claude trovata: $($claude.Source)"; & $claude.Source --version }
else { Write-Warning "CLI 'claude' non trovata. Installare Claude Code seguendo la documentazione ufficiale, poi rieseguire." }

foreach ($n in @('DataPC_Abstergo.forge', 'SoundData\pc\sounds_ita.pck')) {
    if (Test-Path -LiteralPath (Join-Path $game $n)) { Write-Host "TROVATO  $n" } else { Write-Host "MANCANTE $n" }
}

Write-Host "== Fase 2: configurazione della cartella privata =="
if (-not (Confirm-Step "Creare (se mancanti) $work, .claude\settings.json e CLAUDE.md al suo interno?")) {
    Write-Host "Interrotto dall'utente. Nessun file creato."; return
}
New-Item -ItemType Directory -Force -Path (Join-Path $work '.claude') | Out-Null

# Percorso del gioco in forma POSIX per le regole dei permessi (es. C:\A B -> c/A B). DA VERIFICARE con /permissions.
$posix = ($game.Substring(0, 1).ToLowerInvariant() + $game.Substring(2)).Replace('\', '/')
$settingsPath = Join-Path $work '.claude\settings.json'
if (-not (Test-Path -LiteralPath $settingsPath)) {
    $settings = [ordered]@{
        permissions = [ordered]@{
            defaultMode = 'plan'
            deny        = @("Edit(//$posix/**)", "Write(//$posix/**)", 'Bash(git push:*)', 'Bash(curl:*)', 'Bash(Invoke-WebRequest:*)', 'WebFetch')
            ask         = @('Bash', 'Edit', 'Write')
        }
    }
    $settings | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $settingsPath -Encoding UTF8
    Write-Host "Creato $settingsPath"
} else { Write-Host "Esistente, non modificato: $settingsPath" }

$rulesPath = Join-Path $work 'CLAUDE.md'
if (-not (Test-Path -LiteralPath $rulesPath)) {
    @"
# FILM - Claude Code locale (accesso limitato)
- Seguire docs/ricerca_massiva/CLAUDE_CODE_LOCALE_DELEGA.md e LIMITI_E_DIRITTI.md del repository FILM.
- Cartella del gioco: $game -> SOLA LETTURA. Mai scrivere, patchare, avviare il gioco o il launcher.
- Lavorare solo in: $work. Nessuna rete, nessun download, nessun push su GitHub di file del gioco.
- Fasi L0-L6 con STOP e consenso esplicito; prima dry-run. Non dichiarare risultati senza prova.
- Voci: solo registrazioni originali italiane, mai sintesi/clonazione/modifica.
- Un solo frame finale FILM_PREVIEW_01_ABSTERGO.png con Desmond e Lucy, privato. Niente primi 15 minuti.
"@ | Set-Content -LiteralPath $rulesPath -Encoding UTF8
    Write-Host "Creato $rulesPath"
} else { Write-Host "Esistente, non modificato: $rulesPath" }

Write-Host "== Fase 3: avvio =="
if (-not $claude) { Write-Host "CLI claude assente: avvio saltato."; return }
if (Confirm-Step "Avviare Claude Code in modalita' plan in $work? Controllare subito /permissions.") {
    Push-Location -LiteralPath $work
    try { & $claude.Source --permission-mode plan } finally { Pop-Location }
} else { Write-Host "Avvio annullato." }
