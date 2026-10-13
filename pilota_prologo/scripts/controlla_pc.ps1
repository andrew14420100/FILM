# Diagnostica soltanto: nessun download, installazione o lavoro remoto.
$ErrorActionPreference = "Stop"
Write-Host "== FILM PILOTA / controllo PC Windows ==" -ForegroundColor Cyan

$gpu = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if ($null -eq $gpu) {
  Write-Warning "nvidia-smi non trovato. Verifica i driver NVIDIA."
} else {
  Write-Host "`nGPU / memoria VRAM:" -ForegroundColor Yellow
  & nvidia-smi --query-gpu=name,memory.total,memory.free,utilization.gpu --format=csv,noheader
}

Write-Host "`nComfyUI Desktop: controlla che sia aperto sulla tua macchina."
try {
  $reply = Invoke-RestMethod -Method Get -Uri "http://127.0.0.1:8188/system_stats" -TimeoutSec 3
  Write-Host "ComfyUI API locale 8188: raggiungibile" -ForegroundColor Green
  if ($reply.devices) { $reply.devices | Format-Table name,type,vram_total,vram_free -AutoSize }
} catch {
  Write-Warning "API ComfyUI sulla porta 8188 non raggiungibile. Avvia ComfyUI Desktop o controlla la porta effettiva nell'app."
}

$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
if ($ffmpeg) { Write-Host "FFmpeg trovato: $($ffmpeg.Source)" -ForegroundColor Green }
else { Write-Warning "FFmpeg non trovato. Servira' solo per montare i video finali." }

$python = Get-Command py -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command python -ErrorAction SilentlyContinue }
if ($python) { Write-Host "Python trovato: $($python.Source)" -ForegroundColor Green }
else { Write-Warning "Python non trovato. Servira' per il comando di montaggio." }

$root = Join-Path $PSScriptRoot "..\assets_privati"
Write-Host "`nCartella reference da mantenere privata: $root"
Write-Host "Questo controllo NON genera immagini/video, NON scarica modelli e NON usa API a pagamento." -ForegroundColor Cyan
