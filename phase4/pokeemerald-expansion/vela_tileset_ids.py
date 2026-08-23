#!/usr/bin/env python3
"""Canonical metatile IDs used by the first SOMADEX/Vela overworld block.

The values deliberately live in the locked primary `general` tileset range.  The
engine-facing map/layout identifiers remain technical slots, but the visual
composition and the selected metatile definitions are SOMADEX-owned.
"""

# Existing low IDs retained because Phase 3 scripts already rely on their
# movement semantics. Their artwork/metatile composition is replaced by the
# Vela tileset generator.
MT_PATH = 0x001
MT_TALL_GRASS = 0x00D

# Existing four-metatile tree footprint used by the Phase 3 map generator.
MT_TREE_TL = 0x1D4
MT_TREE_TR = 0x1D5
MT_TREE_BL = 0x1DC
MT_TREE_BR = 0x1DD

# Vela-specific visual vocabulary. 0x1E0..0x1EF stays inside the 512-entry
# primary tileset and is intentionally treated as owned by the Vela block.
MT_GROUND = 0x1E0
MT_PLAZA = 0x1E1
MT_FLOWERS = 0x1E2
MT_WATER = 0x1E3
MT_SAND = 0x1E4
MT_FENCE = 0x1E5
MT_CRYSTAL = 0x1E6
MT_SIGN = 0x1E7
MT_WALL = 0x1E8
MT_ROOF = 0x1E9
MT_DOOR = 0x1EA
MT_LAMP = 0x1EB
MT_HEDGE = 0x1EC

# Map-block templates copied from already proven Phase 3 cells.  The lower
# 10 bits are the metatile ID; upper bits preserve the known walkable/solid
# collision/elevation encoding instead of inventing a new one.
WALKABLE_TEMPLATE = 0x3001
SOLID_TEMPLATE = 0x05D4


def with_metatile(template: int, metatile_id: int) -> int:
    if not 0 <= metatile_id < 0x400:
        raise ValueError(f"metatile id outside GBA map-block range: {metatile_id:#x}")
    return (template & 0xFC00) | metatile_id


def walkable(metatile_id: int) -> int:
    return with_metatile(WALKABLE_TEMPLATE, metatile_id)


def solid(metatile_id: int) -> int:
    return with_metatile(SOLID_TEMPLATE, metatile_id)


GROUND = walkable(MT_GROUND)
PATH = walkable(MT_PATH)
TALL_GRASS = walkable(MT_TALL_GRASS)
PLAZA = walkable(MT_PLAZA)
FLOWERS = walkable(MT_FLOWERS)
SAND = walkable(MT_SAND)
WATER = solid(MT_WATER)
FENCE = solid(MT_FENCE)
CRYSTAL = solid(MT_CRYSTAL)
SIGN = solid(MT_SIGN)
WALL = solid(MT_WALL)
ROOF = solid(MT_ROOF)
DOOR = solid(MT_DOOR)
LAMP = solid(MT_LAMP)
HEDGE = solid(MT_HEDGE)

TREE = (
    (solid(MT_TREE_TL), solid(MT_TREE_TR)),
    (solid(MT_TREE_BL), solid(MT_TREE_BR)),
)

OWNED_METATILES = {
    "path": MT_PATH,
    "tall_grass": MT_TALL_GRASS,
    "tree_tl": MT_TREE_TL,
    "tree_tr": MT_TREE_TR,
    "tree_bl": MT_TREE_BL,
    "tree_br": MT_TREE_BR,
    "ground": MT_GROUND,
    "plaza": MT_PLAZA,
    "flowers": MT_FLOWERS,
    "water": MT_WATER,
    "sand": MT_SAND,
    "fence": MT_FENCE,
    "crystal": MT_CRYSTAL,
    "sign": MT_SIGN,
    "wall": MT_WALL,
    "roof": MT_ROOF,
    "door": MT_DOOR,
    "lamp": MT_LAMP,
    "hedge": MT_HEDGE,
}
