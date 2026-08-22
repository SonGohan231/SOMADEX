#!/usr/bin/env python3
"""Install Kula Splotu as the visible capture device for the first Vela slice.

`BALL_POKE` remains the locked engine's internal capture-behaviour selector, but its
reachable sprite art and item mapping are replaced with SOMADEX-owned content.
"""

from __future__ import annotations

import argparse
import binascii
import struct
import zlib
from pathlib import Path

# Index 0 is transparent for the OBJ palette. Remaining colours form a teal/cyan
# resonance device rather than a red/white Poké Ball silhouette.
PAL = [
    (255, 255, 255),
    (17, 35, 45),
    (25, 68, 78),
    (35, 104, 116),
    (54, 151, 157),
    (90, 205, 197),
    (150, 246, 224),
    (222, 255, 247),
    (57, 72, 83),
    (101, 118, 126),
    (181, 194, 194),
    (54, 95, 137),
    (67, 155, 190),
    (116, 218, 230),
    (196, 122, 63),
    (238, 190, 96),
]


def chunk(kind: bytes, payload: bytes) -> bytes:
    crc = binascii.crc32(kind)
    crc = binascii.crc32(payload, crc) & 0xFFFFFFFF
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", crc)


def write_png(path: Path, width: int, height: int, pixels: list[int]) -> None:
    if len(pixels) != width * height:
        raise SystemExit(f"invalid PNG payload for {path}: {len(pixels)}")
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        raw.extend(pixels[y * width : (y + 1) * width])
    plte = b"".join(bytes(rgb) for rgb in PAL)
    payload = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 3, 0, 0, 0))
        + chunk(b"PLTE", plte)
        + chunk(b"tRNS", bytes([0] + [255] * 15))
        + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + chunk(b"IEND", b"")
    )
    path.write_bytes(payload)


def blank16() -> list[list[int]]:
    return [[0 for _ in range(16)] for _ in range(16)]


def closed_frame(glow_shift: int) -> list[list[int]]:
    p = blank16()
    cx, cy = 7.5, 7.5
    for y in range(16):
        for x in range(16):
            dx, dy = x - cx, y - cy
            d2 = dx * dx + dy * dy
            if d2 <= 43:
                p[y][x] = 2
            if d2 <= 34:
                p[y][x] = 3 if y < 8 else 11
            if d2 <= 23:
                p[y][x] = 4 if y < 8 else 12
    # Dark equatorial seam makes the object read as a manufactured device.
    for x in range(3, 13):
        if p[8][x]:
            p[8][x] = 1
    # Central resonance diamond, shifted between frames for a tiny pulse.
    cy2 = 7 + glow_shift
    for dy, width in [(-2, 1), (-1, 3), (0, 5), (1, 3), (2, 1)]:
        y = cy2 + dy
        if not 0 <= y < 16:
            continue
        x0 = 8 - width // 2
        for x in range(x0, x0 + width):
            if 0 <= x < 16:
                p[y][x] = 7 if abs(dy) <= 1 else 6
    # Metallic side latches and warm orientation marks.
    for x in (2, 13):
        for y in (7, 8, 9):
            if p[y][x]:
                p[y][x] = 9
    p[4][5] = p[4][10] = 15
    return p


def open_frame() -> list[list[int]]:
    p = blank16()
    # Two separated shell halves with an exposed cyan resonance core.
    for y in range(2, 7):
        span = 4 + (y - 2)
        for x in range(8 - span, 8 + span):
            if 0 <= x < 16:
                p[y][x] = 3 if y < 5 else 4
    for y in range(10, 15):
        span = 8 - (y - 10)
        for x in range(8 - span, 8 + span):
            if 0 <= x < 16:
                p[y][x] = 11 if y > 11 else 12
    for y in range(5, 12):
        width = max(1, 4 - abs(8 - y))
        for x in range(8 - width, 9 + width):
            if 0 <= x < 16:
                p[y][x] = 7 if abs(8 - y) <= 2 else 6
    p[8][3] = p[8][12] = 15
    return p


def flatten(frame: list[list[int]]) -> list[int]:
    return [px for row in frame for px in row]


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected exactly one anchor in {path}, found {count}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    root = args.upstream_root.resolve()

    balls = root / "graphics/balls"
    poke = balls / "poke.png"
    opened = balls / "open.png"
    source = root / "src/pokeball.c"
    for path in (poke, opened, source):
        if not path.exists():
            raise SystemExit(f"capture presentation anchor missing: {path}")

    frames = flatten(closed_frame(0)) + flatten(closed_frame(1)) + [0] * (16 * 16)
    write_png(poke, 16, 48, frames)
    write_png(opened, 16, 16, flatten(open_frame()))

    # Keep BALL_POKE as behaviour only; make any item lookup return our actual
    # capture device instead of an unreachable Poké Ball item.
    replace_once(
        source,
        "        .itemId = ITEM_POKE_BALL,",
        "        .itemId = ITEM_KULA_SPLOTU,",
        "Kula Splotu BALL_POKE item mapping",
    )

    if poke.read_bytes()[:8] != b"\x89PNG\r\n\x1a\n" or opened.read_bytes()[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit("generated Kula Splotu battle sprites are not valid PNG containers")
    if "[BALL_POKE]" not in source.read_text(encoding="utf-8") or "ITEM_KULA_SPLOTU" not in source.read_text(encoding="utf-8"):
        raise SystemExit("Kula Splotu capture mapping verification failed")

    print("PHASE4 KULA SPLOTU PASS: reachable thrown/open capture-device art + BALL_POKE item mapping replaced")


if __name__ == "__main__":
    main()
