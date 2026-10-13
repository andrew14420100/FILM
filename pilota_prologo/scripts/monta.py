#!/usr/bin/env python3
"""Compone quattro clip locali Abstergo in un MP4 silenzioso. Solo libreria standard + ffmpeg."""
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUTS = ROOT / "outputs"
CLIPS = [
    "01_desmond_cella.mp4",
    "02_lucy_ingresso.mp4",
    "03_incontro.mp4",
    "04_corridoio.mp4",
]


def main() -> int:
    parser = argparse.ArgumentParser(description="Monta quattro clip video locali del pilota Abstergo.")
    parser.add_argument("--upscale-4k", action="store_true",
                        help="Esporta 3840x2160 da clip a risoluzione inferiore: NON crea dettagli 4K nativi.")
    parser.add_argument("--seconds-per-shot", type=float, default=5.0,
                        help="Durata massima per clip, default 5 secondi.")
    parser.add_argument("--fps", type=int, default=16,
                        help="Frame rate del montaggio. Per la prova iniziale: 16.")
    args = parser.parse_args()

    ffmpeg = shutil.which("ffmpeg")
    if not ffmpeg:
        print("ERRORE: ffmpeg non trovato nel PATH. Installalo da https://ffmpeg.org/download.html",
              file=sys.stderr)
        return 2
    missing = [str(OUTPUTS / name) for name in CLIPS if not (OUTPUTS / name).is_file()]
    if missing:
        print("Mancano i video da generare prima del montaggio:\n- " + "\n- ".join(missing),
              file=sys.stderr)
        return 3
    if args.seconds_per_shot <= 0 or args.fps <= 0:
        print("ERRORE: i valori di durata e fps devono essere positivi.", file=sys.stderr)
        return 4

    OUTPUTS.mkdir(exist_ok=True)
    target = OUTPUTS / ("PILOTA_ABSTERGO_4K_UPSCALED.mp4" if args.upscale_4k
                        else "PILOTA_ABSTERGO_1080p.mp4")
    filters = []
    for i in range(len(CLIPS)):
        filters.append(
            f"[{i}:v]trim=duration={args.seconds_per_shot},setpts=PTS-STARTPTS,"
            f"fps={args.fps},scale=1920:1080:force_original_aspect_ratio=decrease:"
            "flags=lanczos,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,"
            f"setsar=1,format=yuv420p[v{i}]"
        )
    inputs = "".join(f"[v{i}]" for i in range(len(CLIPS)))
    filters.append(f"{inputs}concat=n={len(CLIPS)}:v=1:a=0[joined]")
    if args.upscale_4k:
        filters.append("[joined]scale=3840:2160:flags=lanczos[out]")
    else:
        filters.append("[joined]null[out]")

    cmd = [ffmpeg, "-hide_banner", "-y"]
    for name in CLIPS:
        cmd += ["-i", str(OUTPUTS / name)]
    cmd += [
        "-filter_complex", ";".join(filters),
        "-map", "[out]", "-an", "-c:v", "libx264",
        "-preset", "medium", "-crf", "18",
        "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(target)
    ]
    print("Montaggio locale in corso, senza audio e senza upload...", flush=True)
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as exc:
        print(f"ERRORE FFmpeg (codice {exc.returncode}). Controlla durata e formato delle clip.",
              file=sys.stderr)
        return exc.returncode or 1
    print("Creato:", target)
    print("Nota: il risultato è un provino. La scala a 1080p/4K non aumenta il dettaglio nativo.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
