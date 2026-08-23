#!/usr/bin/env python3
"""Reskin the reachable singles battle HUD into the SOMADEX/Vela visual language.

The engine geometry, sprite sizes, HP logic and text placement remain untouched.
We replace only player-facing indexed palettes / palette sources for the first
reachable battle surface. This keeps the proven GBA layout while changing its
visible identity.
"""

from __future__ import annotations

import argparse
import binascii
import re
import struct
from pathlib import Path

PNG_SIG = b"\x89PNG\r\n\x1a\n"

# Vela/SOMADEX HUD ramp: deep slate -> teal -> pale cyan. Saturated semantic
# colours (HP/EXP/status accents) stay recognisable for gameplay readability.
RAMP = [
    (12, 27, 35),
    (18, 44, 53),
    (25, 63, 72),
    (34, 84, 91),
    (47, 109, 112),
    (69, 139, 137),
    (98, 171, 162),
    (137, 203, 188),
    (183, 229, 214),
    (224, 247, 238),
]

PNG_TARGETS = (
    "graphics/battle_interface/healthbox_singles_player.png",
    "graphics/battle_interface/healthbox_singles_opponent.png",
    "graphics/battle_interface/textbox.png",
    "graphics/battle_interface/move_info_window_l.png",
    "graphics/battle_interface/move_info_window_r.png",
)

PAL_TARGETS = (
    "graphics/battle_interface/text.pal",
    "graphics/battle_interface/text_pp.pal",
)


def png_chunk(kind: bytes, payload: bytes) -> bytes:
    crc = binascii.crc32(kind)
    crc = binascii.crc32(payload, crc) & 0xFFFFFFFF
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", crc)


def map_colour(rgb: tuple[int, int, int], index: int) -> tuple[int, int, int]:
    r, g, b = rgb
    if index == 0:
        return (0, 0, 0)
    if r > 180 and g > 140 and b < 110:
        return (242, 198, 74)
    if r > 160 and g < 115 and b < 115:
        return (224, 79, 88)
    if g > 140 and r < 130 and b < 150:
        return (67, 194, 119)
    if b > 150 and r < 130:
        return (79, 183, 221)
    lum = (r * 299 + g * 587 + b * 114) // 1000
    slot = min(len(RAMP) - 1, lum * len(RAMP) // 256)
    return RAMP[slot]


def reskin_indexed_png(path: Path) -> int:
    data = path.read_bytes()
    if not data.startswith(PNG_SIG):
        raise SystemExit(f"not a PNG: {path}")

    out = bytearray(PNG_SIG)
    pos = len(PNG_SIG)
    changed = 0
    saw_plte = False
    saw_iend = False

    while pos < len(data):
        if pos + 12 > len(data):
            raise SystemExit(f"truncated PNG chunk in {path}")
        length = struct.unpack(">I", data[pos : pos + 4])[0]
        chunk_end = pos + 12 + length
        if chunk_end > len(data):
            raise SystemExit(f"invalid PNG chunk length in {path}")
        kind = data[pos + 4 : pos + 8]
        payload = data[pos + 8 : pos + 8 + length]
        pos = chunk_end

        if kind == b"PLTE":
            saw_plte = True
            if len(payload) % 3:
                raise SystemExit(f"invalid PLTE size in {path}: {len(payload)}")
            palette = bytearray()
            for i in range(len(payload) // 3):
                old = tuple(payload[i * 3 : i * 3 + 3])
                new = map_colour(old, i)
                palette.extend(new)
                changed += int(old != new)
            payload = bytes(palette)

        out.extend(png_chunk(kind, payload))
        if kind == b"IEND":
            saw_iend = True
            break

    if not saw_plte:
        raise SystemExit(f"reachable HUD PNG is not indexed / missing PLTE: {path}")
    if not saw_iend:
        raise SystemExit(f"reachable HUD PNG is missing IEND: {path}")
    path.write_bytes(bytes(out))
    return changed


def reskin_jasc_palette(path: Path) -> int:
    text = path.read_text(encoding="ascii")
    lines = text.splitlines()
    if len(lines) < 4 or lines[0] != "JASC-PAL" or lines[1] != "0100":
        raise SystemExit(f"unsupported palette format: {path}")
    try:
        count = int(lines[2])
    except ValueError as exc:
        raise SystemExit(f"invalid palette count: {path}") from exc
    if len(lines[3:]) < count:
        raise SystemExit(f"truncated palette: {path}")

    changed = 0
    out = lines[:3]
    for i, line in enumerate(lines[3 : 3 + count]):
        m = re.fullmatch(r"\s*(\d+)\s+(\d+)\s+(\d+)\s*", line)
        if not m:
            raise SystemExit(f"invalid palette row in {path}: {line!r}")
        old = tuple(map(int, m.groups()))
        if any(not 0 <= component <= 255 for component in old):
            raise SystemExit(f"palette component outside 0..255 in {path}: {line!r}")
        new = map_colour(old, i)
        out.append(f"{new[0]} {new[1]} {new[2]}")
        changed += int(old != new)
    out.extend(lines[3 + count :])
    path.write_text("\n".join(out) + "\n", encoding="ascii")
    return changed


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    root = args.upstream_root.resolve()

    total = 0
    touched = 0
    for rel in PNG_TARGETS:
        path = root / rel
        if not path.is_file():
            raise SystemExit(f"locked HUD source missing: {path}")
        changed = reskin_indexed_png(path)
        if changed == 0:
            raise SystemExit(f"HUD reskin made no palette changes: {path}")
        total += changed
        touched += 1
        print(f"SOMADEX HUD: {rel}: {changed} palette entries remapped")

    for rel in PAL_TARGETS:
        path = root / rel
        if not path.is_file():
            raise SystemExit(f"locked HUD palette source missing: {path}")
        changed = reskin_jasc_palette(path)
        if changed == 0:
            raise SystemExit(f"HUD palette reskin made no changes: {path}")
        total += changed
        touched += 1
        print(f"SOMADEX HUD: {rel}: {changed} palette entries remapped")

    print(f"PHASE4 BATTLE HUD PASS: {touched} reachable HUD assets/palettes reskinned, {total} entries changed")


if __name__ == "__main__":
    main()
