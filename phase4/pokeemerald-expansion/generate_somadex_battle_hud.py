#!/usr/bin/env python3
"""Reskin the reachable singles battle HUD into the SOMADEX/Vela visual language.

The engine geometry, sprite sizes, HP logic and text placement remain untouched.
We only replace indexed-PNG palette chunks for the first reachable battle surface,
which keeps the proven GBA layouts while changing their visible identity.
"""

from __future__ import annotations

import argparse
import binascii
import struct
from pathlib import Path

PNG_SIG = b"\x89PNG\r\n\x1a\n"

# Vela/SOMADEX HUD ramp: deep slate -> teal -> pale cyan. Saturated semantic
# colours (HP/EXP accents) are handled separately so readability is preserved.
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

TARGETS = (
    "graphics/battle_interface/healthbox_singles_player.png",
    "graphics/battle_interface/healthbox_singles_opponent.png",
    "graphics/battle_interface/textbox.png",
    "graphics/battle_interface/move_info_window_l.png",
    "graphics/battle_interface/move_info_window_r.png",
)


def png_chunk(kind: bytes, payload: bytes) -> bytes:
    crc = binascii.crc32(kind)
    crc = binascii.crc32(payload, crc) & 0xFFFFFFFF
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", crc)


def map_colour(rgb: tuple[int, int, int], index: int) -> tuple[int, int, int]:
    r, g, b = rgb
    # Index zero is normally transparent/background in these indexed assets.
    if index == 0:
        return (0, 0, 0)

    # Preserve semantic saturated accents in a SOMADEX-compatible form.
    if r > 180 and g > 140 and b < 110:
        return (242, 198, 74)   # EXP / warm accent
    if r > 160 and g < 115 and b < 115:
        return (224, 79, 88)    # danger / critical
    if g > 140 and r < 130 and b < 150:
        return (67, 194, 119)   # healthy/status green
    if b > 150 and r < 130:
        return (79, 183, 221)   # active cyan/blue

    # Convert neutral/legacy colours to the coherent teal luminance ramp.
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

    while pos < len(data):
        if pos + 12 > len(data):
            raise SystemExit(f"truncated PNG chunk in {path}")
        length = struct.unpack(">I", data[pos : pos + 4])[0]
        kind = data[pos + 4 : pos + 8]
        payload = data[pos + 8 : pos + 8 + length]
        pos += 12 + length

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
            break

    if not saw_plte:
        raise SystemExit(f"reachable HUD PNG is not indexed / missing PLTE: {path}")
    path.write_bytes(bytes(out))
    return changed


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    root = args.upstream_root.resolve()

    total = 0
    for rel in TARGETS:
        path = root / rel
        if not path.is_file():
            raise SystemExit(f"locked HUD source missing: {path}")
        changed = reskin_indexed_png(path)
        if changed == 0:
            raise SystemExit(f"HUD reskin made no palette changes: {path}")
        total += changed
        print(f"SOMADEX HUD: {rel}: {changed} palette entries remapped")

    print(f"PHASE4 BATTLE HUD PASS: {len(TARGETS)} reachable assets reskinned, {total} palette entries changed")


if __name__ == "__main__":
    main()
