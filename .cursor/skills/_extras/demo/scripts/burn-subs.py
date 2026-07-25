#!/usr/bin/env python3
"""Burn an SRT subtitle track into a video WITHOUT libass/freetype.

Renders each cue to a transparent caption PNG (Pillow + Helvetica) and composites
them onto the video with ffmpeg's `overlay` filter (enable=between(t,start,end)).
Use this when the local ffmpeg lacks the `subtitles`/`drawtext` filters.

Usage: burn-subs.py <raw_mp4> <srt> <out_mp4>
"""
import os
import re
import subprocess
import sys
import tempfile


FONT_CANDIDATES = [
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/HelveticaNeue.ttc",
    "/System/Library/Fonts/SFNS.ttf",
]


def run(cmd):
    return subprocess.run(cmd, check=True, capture_output=True, text=True)


def ffprobe_dims(path):
    out = subprocess.check_output(
        [
            "ffprobe", "-v", "error",
            "-select_streams", "v:0",
            "-show_entries", "stream=width,height",
            "-of", "default=nw=1:nk=1",
            path,
        ]
    )
    w, h = out.decode().strip().splitlines()
    return int(w), int(h)


def parse_srt(path):
    with open(path, encoding="utf-8") as f:
        data = f.read()
    cues = []
    for block in re.split(r"\n\s*\n", data.strip()):
        lines = [ln for ln in block.splitlines() if ln.strip()]
        if len(lines) < 2:
            continue
        tline = next((ln for ln in lines if "-->" in ln), None)
        if not tline:
            continue
        m = re.match(
            r"(\d+):(\d+):(\d+)[,.](\d+)\s*-->\s*(\d+):(\d+):(\d+)[,.](\d+)",
            tline,
        )
        if not m:
            continue
        g = list(map(int, m.groups()))
        start = g[0] * 3600 + g[1] * 60 + g[2] + g[3] / 1000
        end = g[4] * 3600 + g[5] * 60 + g[6] + g[7] / 1000
        text = " ".join(lines[lines.index(tline) + 1:]).strip()
        text = re.sub(r"\s+", " ", text)
        if text:
            cues.append((start, end, text))
    return cues


def load_font(size):
    for p in FONT_CANDIDATES:
        if os.path.exists(p):
            from PIL import ImageFont
            return ImageFont.truetype(p, size)
    from PIL import ImageFont
    return ImageFont.load_default()


def wrap_text(text, font, max_w):
    from PIL import ImageFont
    words = text.split()
    lines, cur = [], ""
    for w in words:
        trial = w if not cur else cur + " " + w
        if font.getlength(trial) <= max_w:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines or [""]


def render_caption(text, vw, font):
    from PIL import Image, ImageDraw
    max_w = int(vw * 0.86)
    pad_x, pad_y, radius = 18, 12, 12
    line_h = font.size + 10
    lines = wrap_text(text, font, max_w)
    widths = [font.getbbox(ln)[2] for ln in lines]
    box_w = max(widths) if widths else 0
    img_w = box_w + pad_x * 2
    img_h = line_h * len(lines) + pad_y * 2
    img = Image.new("RGBA", (img_w, img_h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, img_w - 1, img_h - 1], radius=radius, fill=(0, 0, 0, 170))
    y = pad_y
    for ln, lw in zip(lines, widths):
        x = (img_w - lw) // 2
        d.text((x, y), ln, font=font, fill=(255, 255, 255, 255),
               stroke_width=2, stroke_fill=(0, 0, 0, 255))
        y += line_h
    return img


def main():
    if len(sys.argv) != 4:
        print("usage: burn-subs.py <raw_mp4> <srt> <out_mp4>", file=sys.stderr)
        sys.exit(2)
    raw, srt, out = sys.argv[1], sys.argv[2], sys.argv[3]
    if not os.path.isfile(raw):
        sys.exit(f"raw mp4 not found: {raw}")
    if not os.path.isfile(srt):
        sys.exit(f"srt not found: {srt}")

    cues = parse_srt(srt)
    if not cues:
        print("no cues parsed from srt; copying video as-is", file=sys.stderr)
        run(["ffmpeg", "-y", "-hide_banner", "-loglevel", "error", "-i", raw,
             "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p", out])
        return

    vw, vh = ffprobe_dims(raw)
    font = load_font(max(20, vh // 32))

    tmp = tempfile.mkdtemp(prefix="burnsubs-")
    try:
        pngs = []
        for i, (start, end, text) in enumerate(cues):
            p = os.path.join(tmp, f"c{i:03d}.png")
            render_caption(text, vw, font).save(p)
            pngs.append((start, end, p))

        inputs = ["-i", raw]
        for _, _, p in pngs:
            inputs += ["-i", p]

        parts, prev = [], "0:v"
        for i, (start, end, _) in enumerate(pngs):
            label = f"v{i}"
            parts.append(
                f"[{prev}][{i+1}:v]overlay=(W-w)/2:H-h-{max(40, vh // 18)}"
                f":enable='between(t,{start:.3f},{end:.3f})'[{label}]"
            )
            prev = label
        last = len(pngs) - 1
        filter_complex = ";".join(parts) + f";[v{last}]scale=trunc(iw/2)*2:trunc(ih/2)*2[vf]"

        cmd = [
            "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
            *inputs,
            "-filter_complex", filter_complex,
            "-map", "[vf]",
            "-an",
            "-c:v", "libx264", "-pix_fmt", "yuv420p",
            out,
        ]
        run(cmd)
    finally:
        import shutil
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
