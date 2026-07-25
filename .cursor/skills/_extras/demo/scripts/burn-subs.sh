#!/usr/bin/env bash
# Burn an SRT subtitle track into a video with styled English captions.
#
# Usage: burn-subs.sh <raw_mp4> <srt> <out_mp4>
#
# DEFAULT path = Pillow PNG-overlay (burn-subs.py). Renders each cue to a
# transparent caption PNG (Helvetica, dark rounded box, white stroke text) and
# composites with ffmpeg's `overlay` filter. Works WITHOUT libass/freetype —
# this is the path verified on a stock homebrew `ffmpeg` (no --enable-libass).
# Output is true burned-in captions (not soft subs).
#
# OPT-IN fast path: if you later install a libass-enabled ffmpeg (e.g. the
# homebrew-ffmpeg/ffmpeg tap with --with-libass), set DEMO_USE_LIBASS=1 to use
# ffmpeg's `subtitles` filter (one pass, fastest).
set -euo pipefail

raw="${1:?usage: burn-subs.sh <raw_mp4> <srt> <out_mp4>}"
srt="${2:?usage: burn-subs.sh <raw_mp4> <srt> <out_mp4>}"
out="${3:?usage: burn-subs.sh <raw_mp4> <srt> <out_mp4>}"

[[ -f "$raw" ]] || { echo "raw mp4 not found: $raw" >&2; exit 1; }
[[ -f "$srt" ]] || { echo "srt not found: $srt" >&2; exit 1; }

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${DEMO_USE_LIBASS:-0}" == "1" ]] && \
   ffmpeg -hide_banner -filters 2>/dev/null | grep -qE "(^| ).. subtitles "; then
  style="FontName=Helvetica,FontSize=22,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,BorderStyle=1,Outline=2,Shadow=1,MarginV=44,Alignment=2"
  esc_srt="${srt//:/\\:}"
  ffmpeg -y -hide_banner -loglevel error \
    -i "$raw" \
    -vf "subtitles='${esc_srt}':force_style='${style}'" \
    -c:a copy "$out"
else
  python3 "${script_dir}/burn-subs.py" "$raw" "$srt" "$out"
fi

echo "$out"
