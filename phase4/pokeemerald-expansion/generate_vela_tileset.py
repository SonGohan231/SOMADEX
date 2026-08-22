#!/usr/bin/env python3
"""Generate the first production SOMADEX/Vela overworld tileset directly in GBA format.

This does not try to force a large concept atlas into the ROM. Instead it creates a
compact, deterministic 16-colour core that fits the locked `gTileset_General`
128x256 source sheet, patches selected metatiles, and preserves proven engine
behaviours by copying attributes from known walkable/tall-grass/solid entries.
"""

from __future__ import annotations

import argparse
import binascii
import struct
import zlib
from pathlib import Path

from vela_tileset_ids import (
    MT_CRYSTAL,
    MT_DOOR,
    MT_FENCE,
    MT_FLOWERS,
    MT_GROUND,
    MT_HEDGE,
    MT_LAMP,
    MT_PATH,
    MT_PLAZA,
    MT_ROOF,
    MT_SAND,
    MT_SIGN,
    MT_TALL_GRASS,
    MT_TREE_BL,
    MT_TREE_BR,
    MT_TREE_TL,
    MT_TREE_TR,
    MT_WALL,
    MT_WATER,
    OWNED_METATILES,
)

SHEET_W = 128
SHEET_H = 256
TILE = 8
METATILE = 16
PRIMARY_METATILE_COUNT = 512

# One cohesive Vela palette. Index 0 is also used as the transparent colour in
# the unused upper metatile layer.
PALETTE = [
    (24, 36, 48),     # 0 deep neutral / transparent index
    (35, 76, 66),     # 1 deep vegetation
    (57, 118, 82),    # 2 vegetation
    (104, 168, 104),  # 3 light vegetation
    (112, 82, 58),    # 4 dark earth/wood
    (174, 132, 78),   # 5 path/wood
    (222, 191, 128),  # 6 sand/path highlight
    (30, 68, 78),     # 7 dark teal
    (48, 112, 126),   # 8 teal
    (86, 166, 170),   # 9 light teal
    (25, 82, 126),    # 10 deep water
    (42, 126, 174),   # 11 water
    (105, 198, 214),  # 12 foam/light water
    (122, 132, 140),  # 13 stone
    (194, 92, 58),    # 14 warm roof/accent
    (118, 238, 224),  # 15 resonance crystal/light
]


def png_chunk(kind: bytes, payload: bytes) -> bytes:
    crc = binascii.crc32(kind)
    crc = binascii.crc32(payload, crc) & 0xFFFFFFFF
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", crc)


def write_indexed_png(path: Path, width: int, height: int, pixels: bytearray) -> None:
    if len(pixels) != width * height:
        raise SystemExit("indexed PNG payload size mismatch")
    raw = bytearray()
    for y in range(height):
        raw.append(0)  # PNG filter: none
        raw.extend(pixels[y * width : (y + 1) * width])
    plte = b"".join(bytes(rgb) for rgb in PALETTE)
    data = (
        b"\x89PNG\r\n\x1a\n"
        + png_chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 3, 0, 0, 0))
        + png_chunk(b"PLTE", plte)
        + png_chunk(b"IDAT", zlib.compress(bytes(raw), 9))
        + png_chunk(b"IEND", b"")
    )
    path.write_bytes(data)


def write_palette(path: Path) -> None:
    text = "JASC-PAL\n0100\n16\n" + "".join(f"{r} {g} {b}\n" for r, g, b in PALETTE)
    path.write_text(text, encoding="ascii")


def canvas16(fill: int) -> list[list[int]]:
    return [[fill for _ in range(METATILE)] for _ in range(METATILE)]


def ground_pattern() -> list[list[int]]:
    p = canvas16(2)
    for y in range(2, 16, 5):
        for x in range((y * 3) % 7, 16, 7):
            p[y][x] = 3
    return p


def path_pattern() -> list[list[int]]:
    p = canvas16(5)
    for y in range(16):
        for x in range(16):
            if (x * 5 + y * 3) % 23 == 0:
                p[y][x] = 6
            elif (x + y * 2) % 31 == 0:
                p[y][x] = 4
    return p


def tall_grass_pattern() -> list[list[int]]:
    p = canvas16(2)
    for x in range(1, 16, 3):
        for y in range(5, 15):
            if y >= 14 - ((x * 5) % 5):
                p[y][x] = 1
            if y >= 12 - ((x * 3) % 4) and x + 1 < 16:
                p[y][x + 1] = 3
    return p


def plaza_pattern() -> list[list[int]]:
    p = canvas16(13)
    for i in range(16):
        p[0][i] = 7
        p[15][i] = 7
        p[i][0] = 7
        p[i][15] = 7
    for i in range(3, 13):
        if i % 2 == 0:
            p[8][i] = 9
            p[i][8] = 9
    return p


def flowers_pattern() -> list[list[int]]:
    p = ground_pattern()
    for x, y, c in [(3, 4, 15), (6, 7, 14), (11, 5, 6), (13, 11, 15), (5, 12, 14)]:
        p[y][x] = c
        if x + 1 < 16:
            p[y][x + 1] = 3
        if y + 1 < 16:
            p[y + 1][x] = 1
    return p


def water_pattern() -> list[list[int]]:
    p = canvas16(11)
    for y in (4, 11):
        offset = 0 if y == 4 else 4
        for x in range(offset, 16, 8):
            for dx in range(5):
                if x + dx < 16:
                    p[y][x + dx] = 12
            if x + 2 < 16:
                p[y + 1][x + 2] = 10
    return p


def sand_pattern() -> list[list[int]]:
    p = canvas16(6)
    for x, y in [(2, 3), (7, 6), (12, 2), (4, 12), (14, 10), (9, 14)]:
        p[y][x] = 5
    return p


def fence_pattern() -> list[list[int]]:
    p = ground_pattern()
    for x in range(16):
        if 5 <= x <= 10:
            p[6][x] = 4
            p[7][x] = 5
    for x in (5, 10):
        for y in range(4, 14):
            p[y][x] = 4 if y % 3 else 6
    return p


def crystal_pattern() -> list[list[int]]:
    p = ground_pattern()
    for y in range(3, 14):
        half = min(y - 2, 14 - y, 4)
        if half < 0:
            continue
        for x in range(8 - half, 9 + half):
            p[y][x] = 8 if x < 8 else 15
    p[13][7] = p[13][8] = p[13][9] = 7
    return p


def sign_pattern() -> list[list[int]]:
    p = ground_pattern()
    for y in range(4, 9):
        for x in range(4, 12):
            p[y][x] = 5
    for x in range(5, 11):
        p[5][x] = 6
    for y in range(9, 15):
        p[y][7] = p[y][8] = 4
    return p


def wall_pattern() -> list[list[int]]:
    p = canvas16(13)
    for y in range(0, 16, 4):
        for x in range(16):
            p[y][x] = 7
    for y in range(16):
        for x in range((y // 4) % 2 * 4, 16, 8):
            p[y][x] = 7
    return p


def roof_pattern() -> list[list[int]]:
    p = canvas16(14)
    for y in range(1, 16, 4):
        for x in range(16):
            p[y][x] = 4
    for x in range(0, 16, 4):
        for y in range(16):
            if (x + y) % 8 == 0:
                p[y][x] = 6
    return p


def door_pattern() -> list[list[int]]:
    p = wall_pattern()
    for y in range(3, 16):
        for x in range(4, 12):
            p[y][x] = 4
    for y in range(5, 14):
        for x in range(6, 10):
            p[y][x] = 7
    p[9][9] = 15
    return p


def lamp_pattern() -> list[list[int]]:
    p = ground_pattern()
    for y in range(6, 15):
        p[y][7] = p[y][8] = 7
    for y in range(3, 7):
        for x in range(5, 11):
            p[y][x] = 8
    for y in range(4, 6):
        for x in range(6, 10):
            p[y][x] = 15
    return p


def hedge_pattern() -> list[list[int]]:
    p = canvas16(1)
    for y in range(1, 15):
        for x in range(1, 15):
            p[y][x] = 2 if (x + y) % 3 else 3
    return p


def tree_canvas32() -> list[list[int]]:
    p = [[0 for _ in range(32)] for _ in range(32)]
    # ground under the footprint
    for y in range(32):
        for x in range(32):
            p[y][x] = 2
    # broad canopy
    cx, cy = 16, 12
    for y in range(2, 25):
        for x in range(2, 30):
            dx = (x - cx) / 14.0
            dy = (y - cy) / 11.0
            if dx * dx + dy * dy <= 1.0:
                p[y][x] = 1 if y > 17 or x < 7 or x > 25 else 2
                if (x * 3 + y * 5) % 17 == 0:
                    p[y][x] = 3
    # trunk
    for y in range(20, 31):
        for x in range(13, 19):
            p[y][x] = 4
    for y in range(22, 29):
        p[y][16] = p[y][17] = 5
    return p


def crop16(src: list[list[int]], x0: int, y0: int) -> list[list[int]]:
    return [row[x0 : x0 + 16] for row in src[y0 : y0 + 16]]


def tile_entry(tile_index: int, palette: int = 0) -> int:
    if not 0 <= tile_index < 1024:
        raise ValueError(tile_index)
    return tile_index | (palette << 12)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    root = args.upstream_root.resolve()

    tiles_dir = root / "data/tilesets/primary/general"
    tiles_png = tiles_dir / "tiles.png"
    metatiles_path = tiles_dir / "metatiles.bin"
    attrs_path = tiles_dir / "metatile_attributes.bin"
    palette_path = tiles_dir / "palettes/00.pal"
    for path in (tiles_png, metatiles_path, attrs_path, palette_path):
        if not path.exists():
            raise SystemExit(f"locked general tileset file missing: {path}")

    metatiles = bytearray(metatiles_path.read_bytes())
    attrs = bytearray(attrs_path.read_bytes())
    if len(metatiles) != PRIMARY_METATILE_COUNT * 16:
        raise SystemExit(f"unexpected primary metatile table size: {len(metatiles)}")
    if len(attrs) != PRIMARY_METATILE_COUNT * 2:
        raise SystemExit(f"unexpected primary attribute table size: {len(attrs)}")

    sheet = bytearray([0] * (SHEET_W * SHEET_H))
    next_tile = 1
    registered: dict[int, tuple[int, int, int, int]] = {}

    def put_tile(tile_pixels: list[list[int]]) -> int:
        nonlocal next_tile
        if next_tile >= (SHEET_W // TILE) * (SHEET_H // TILE):
            raise SystemExit("Vela tile source sheet exhausted")
        idx = next_tile
        next_tile += 1
        ox = (idx % (SHEET_W // TILE)) * TILE
        oy = (idx // (SHEET_W // TILE)) * TILE
        for y in range(TILE):
            for x in range(TILE):
                sheet[(oy + y) * SHEET_W + ox + x] = tile_pixels[y][x]
        return idx

    def register(metatile_id: int, pattern: list[list[int]]) -> None:
        if len(pattern) != 16 or any(len(row) != 16 for row in pattern):
            raise SystemExit(f"invalid 16x16 pattern for {metatile_id:#x}")
        tiles = (
            put_tile([row[0:8] for row in pattern[0:8]]),
            put_tile([row[8:16] for row in pattern[0:8]]),
            put_tile([row[0:8] for row in pattern[8:16]]),
            put_tile([row[8:16] for row in pattern[8:16]]),
        )
        registered[metatile_id] = tiles

    register(MT_PATH, path_pattern())
    register(MT_TALL_GRASS, tall_grass_pattern())
    tree = tree_canvas32()
    register(MT_TREE_TL, crop16(tree, 0, 0))
    register(MT_TREE_TR, crop16(tree, 16, 0))
    register(MT_TREE_BL, crop16(tree, 0, 16))
    register(MT_TREE_BR, crop16(tree, 16, 16))
    register(MT_GROUND, ground_pattern())
    register(MT_PLAZA, plaza_pattern())
    register(MT_FLOWERS, flowers_pattern())
    register(MT_WATER, water_pattern())
    register(MT_SAND, sand_pattern())
    register(MT_FENCE, fence_pattern())
    register(MT_CRYSTAL, crystal_pattern())
    register(MT_SIGN, sign_pattern())
    register(MT_WALL, wall_pattern())
    register(MT_ROOF, roof_pattern())
    register(MT_DOOR, door_pattern())
    register(MT_LAMP, lamp_pattern())
    register(MT_HEDGE, hedge_pattern())

    # Patch selected metatile definitions. Four bottom-layer tiles are followed
    # by four blank top-layer tiles using colour index 0.
    for metatile_id, tiles in registered.items():
        entries = [tile_entry(t) for t in tiles] + [tile_entry(0)] * 4
        payload = b"".join(struct.pack("<H", entry) for entry in entries)
        off = metatile_id * 16
        metatiles[off : off + 16] = payload

    def copy_attr(dst: int, src: int) -> None:
        attrs[dst * 2 : dst * 2 + 2] = attrs[src * 2 : src * 2 + 2]

    # Preserve known engine behaviour without hardcoding attribute bitfields.
    for mid in (MT_GROUND, MT_PLAZA, MT_FLOWERS, MT_SAND):
        copy_attr(mid, MT_PATH)
    copy_attr(MT_TALL_GRASS, MT_TALL_GRASS)
    for mid in (
        MT_TREE_TL,
        MT_TREE_TR,
        MT_TREE_BL,
        MT_TREE_BR,
        MT_WATER,
        MT_FENCE,
        MT_CRYSTAL,
        MT_SIGN,
        MT_WALL,
        MT_ROOF,
        MT_DOOR,
        MT_LAMP,
        MT_HEDGE,
    ):
        copy_attr(mid, MT_TREE_TL)

    write_indexed_png(tiles_png, SHEET_W, SHEET_H, sheet)
    write_palette(palette_path)
    metatiles_path.write_bytes(metatiles)
    attrs_path.write_bytes(attrs)

    print(f"VELA TILESET: wrote owned {SHEET_W}x{SHEET_H} indexed primary sheet")
    print(f"VELA TILESET: patched {len(registered)} metatile definitions using {next_tile} source tiles")
    print("VELA TILESET IDS: " + ", ".join(f"{name}={mid:#05x}" for name, mid in OWNED_METATILES.items()))
    print("PHASE4 VELA TILESET PASS: visual core + palette + metatiles + preserved behaviours generated")


if __name__ == "__main__":
    main()
