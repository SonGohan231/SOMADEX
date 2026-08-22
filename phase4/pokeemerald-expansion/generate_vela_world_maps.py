#!/usr/bin/env python3
"""Generate the first connected SOMADEX overworld block on three 20x20 GBA layouts.

Technical slots:
- LittlerootTown -> Vela South
- Route101      -> Vela Center
- OldaleTown    -> Vela Resonance Grove

The player-facing content is SOMADEX. The upstream map IDs remain technical engine slots.
"""

import argparse
import struct
from pathlib import Path

WIDTH = 20
HEIGHT = 20
PATH = 0x3001
GRASS = 0x300D
TREE = ((0x05D4, 0x05D5), (0x05DC, 0x05DD))


def blank() -> list[list[int]]:
    return [[PATH for _ in range(WIDTH)] for _ in range(HEIGHT)]


def stamp_tree(grid: list[list[int]], x: int, y: int) -> None:
    if x < 0 or y < 0 or x + 1 >= WIDTH or y + 1 >= HEIGHT:
        return
    grid[y][x] = TREE[0][0]
    grid[y][x + 1] = TREE[0][1]
    grid[y + 1][x] = TREE[1][0]
    grid[y + 1][x + 1] = TREE[1][1]


def frame(grid: list[list[int]], *, top_exit: bool, bottom_exit: bool) -> None:
    for x in range(0, WIDTH, 2):
        if not (top_exit and 8 <= x <= 10):
            stamp_tree(grid, x, 0)
        if not (bottom_exit and 8 <= x <= 10):
            stamp_tree(grid, x, HEIGHT - 2)
    for y in range(2, HEIGHT - 2, 2):
        stamp_tree(grid, 0, y)
        stamp_tree(grid, WIDTH - 2, y)


def grass_rect(grid: list[list[int]], x0: int, y0: int, x1: int, y1: int) -> None:
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            grid[y][x] = GRASS


def path_vertical(grid: list[list[int]], x0: int = 8, x1: int = 11) -> None:
    for y in range(HEIGHT):
        for x in range(x0, x1 + 1):
            grid[y][x] = PATH


def build_vela_south() -> list[list[int]]:
    """Calm southern approach and starter plaza."""
    g = blank()
    frame(g, top_exit=True, bottom_exit=False)
    grass_rect(g, 3, 4, 6, 8)
    grass_rect(g, 13, 4, 16, 8)
    grass_rect(g, 3, 13, 5, 15)
    grass_rect(g, 14, 13, 16, 15)
    path_vertical(g)
    # Starter plaza: open readable space before entering Vela Center.
    for y in range(9, 14):
        for x in range(5, 15):
            g[y][x] = PATH
    stamp_tree(g, 3, 10)
    stamp_tree(g, 15, 10)
    return g


def build_vela_center() -> list[list[int]]:
    """Main Vela slice: Mira, landmark and first controlled encounter."""
    g = blank()
    frame(g, top_exit=True, bottom_exit=True)
    grass_rect(g, 3, 4, 7, 8)
    grass_rect(g, 12, 4, 16, 8)
    grass_rect(g, 3, 12, 6, 15)
    grass_rect(g, 13, 12, 16, 15)
    path_vertical(g)
    # Cross-shaped plaza around the landmark and Mira.
    for y in range(9, 13):
        for x in range(4, 16):
            g[y][x] = PATH
    # Keep the Phase 3 controlled encounter coordinate readable and reachable.
    for x in range(7, 14):
        g[16][x] = GRASS
    g[16][9] = PATH
    g[16][11] = PATH
    return g


def build_vela_grove() -> list[list[int]]:
    """Denser northern resonance grove for exploration after the first encounter."""
    g = blank()
    frame(g, top_exit=False, bottom_exit=True)
    grass_rect(g, 3, 3, 7, 7)
    grass_rect(g, 12, 3, 16, 7)
    grass_rect(g, 3, 11, 7, 15)
    grass_rect(g, 12, 11, 16, 15)
    path_vertical(g)
    # Small ring clearing as the first exploration reward space.
    for y in range(7, 12):
        for x in range(6, 14):
            g[y][x] = PATH
    stamp_tree(g, 4, 8)
    stamp_tree(g, 14, 8)
    return g


def write_map(root: Path, layout: str, grid: list[list[int]]) -> None:
    if len(grid) != HEIGHT or any(len(row) != WIDTH for row in grid):
        raise SystemExit(f"{layout}: invalid grid dimensions")
    output = root / "data/layouts" / layout / "map.bin"
    if not output.parent.is_dir():
        raise SystemExit(f"missing locked layout directory: {output.parent}")
    payload = b"".join(struct.pack("<H", cell) for row in grid for cell in row)
    expected = WIDTH * HEIGHT * 2
    if len(payload) != expected:
        raise SystemExit(f"{layout}: unexpected payload size {len(payload)} != {expected}")
    output.write_bytes(payload)
    print(f"VELA MAP: {layout} -> {len(payload)} bytes")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    root = args.upstream_root.resolve()

    write_map(root, "LittlerootTown", build_vela_south())
    write_map(root, "Route101", build_vela_center())
    write_map(root, "OldaleTown", build_vela_grove())
    print("PHASE4 VELA WORLD MAPS PASS: 3 connected 20x20 layouts generated")


if __name__ == "__main__":
    main()
