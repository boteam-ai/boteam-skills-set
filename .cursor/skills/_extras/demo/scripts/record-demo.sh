#!/usr/bin/env bash
# Record the screen for <duration> seconds via macOS screencapture, then
# transcode to a web-friendly mp4 (yuv420p, even dimensions).
#
# Usage: record-demo.sh <out_dir> <duration_sec>
#
# Prereqs:
#   - macOS (screencapture is built-in)
#   - Screen Recording permission granted to the calling app (Cursor)
#   - ffmpeg on PATH  (brew install ffmpeg)
#
# Notes:
#   - This blocks for <duration> seconds. Launch in the background and drive
#     the browser in parallel; await completion when the flow ends.
#   - Bring the target browser to the front and fullscreen it before running.
set -euo pipefail

out_dir="${1:?usage: record-demo.sh <out_dir> <duration_sec>}"
dur="${2:?usage: record-demo.sh <out_dir> <duration_sec>}"

[[ "$dur" =~ ^[0-9]+$ ]] || { echo "duration must be an integer (seconds)" >&2; exit 2; }
[[ "$dur" -ge 1 ]] || { echo "duration must be >= 1s" >&2; exit 2; }

mkdir -p "$out_dir"
raw_mov="$out_dir/raw.mov"
raw_mp4="$out_dir/raw.mp4"

# -v  video mode   -C  show cursor   -V <sec>  auto-stop after N seconds
screencapture -v -C -V "$dur" "$raw_mov"

# Transcode to a broadly compatible mp4. Force even dimensions (some encoders
# reject odd height) and yuv420p for QuickTime / browser playback.
ffmpeg -y -hide_banner -loglevel error \
  -i "$raw_mov" \
  -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
  -pix_fmt yuv420p \
  "$raw_mp4"

rm -f "$raw_mov"
echo "$raw_mp4"
