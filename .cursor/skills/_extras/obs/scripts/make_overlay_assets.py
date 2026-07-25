#!/usr/bin/env python3
"""Generates the two transparent PNGs used for the round-camera-with-ring
overlay: a luma mask (crops the camera feed to a circle) and a solid-color
"ring backer" (a filled circle in the accent color, sized slightly larger
than the camera so only its border peeks out from behind).

Usage:
    python make_overlay_assets.py --color "#2D6CDF" --out-dir <dir> \
        --camera-px 300 --ring-thickness 14
"""

import argparse
from pathlib import Path

from PIL import Image, ImageDraw


def hex_to_rgb(hex_color: str) -> tuple[int, int, int]:
    hex_color = hex_color.lstrip("#")
    if len(hex_color) != 6:
        raise ValueError(f"Expected a 6-digit hex color like #2D6CDF, got: {hex_color!r}")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def make_circle_mask(size: int) -> Image.Image:
    """White filled circle on black — used as an OBS Image Mask/Blend (Luma) filter."""
    img = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(img)
    draw.ellipse((0, 0, size - 1, size - 1), fill=255)
    return img


def make_ring_backer(size: int, rgb: tuple[int, int, int]) -> Image.Image:
    """Filled circle in the accent color on a transparent background."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.ellipse((0, 0, size - 1, size - 1), fill=(*rgb, 255))
    return img


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--color", required=True, help='Ring accent color, e.g. "#2D6CDF"')
    parser.add_argument("--out-dir", required=True, help="Directory to write the PNGs into")
    parser.add_argument("--camera-px", type=int, default=300, help="Final on-canvas camera diameter in pixels")
    parser.add_argument("--ring-thickness", type=int, default=14, help="Ring border thickness in pixels")
    parser.add_argument(
        "--supersample", type=int, default=4, help="Render at N times target size then downscale, for smooth edges"
    )
    args = parser.parse_args()

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    rgb = hex_to_rgb(args.color)

    ss = args.supersample
    mask = make_circle_mask(1000)  # mask resolution is independent of camera-px; OBS scales it to fit
    mask_path = out_dir / "circle-mask.png"
    mask.save(mask_path)

    ring_size = (args.camera_px + 2 * args.ring_thickness) * ss
    ring = make_ring_backer(ring_size, rgb).resize(
        (args.camera_px + 2 * args.ring_thickness, args.camera_px + 2 * args.ring_thickness), Image.LANCZOS
    )
    ring_path = out_dir / "ring-backer.png"
    ring.save(ring_path)

    print(f"circle_mask_path={mask_path}")
    print(f"ring_backer_path={ring_path}")
    print(f"ring_backer_size={ring.size[0]}")


if __name__ == "__main__":
    main()
