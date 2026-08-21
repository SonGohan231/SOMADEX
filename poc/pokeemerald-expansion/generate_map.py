#!/usr/bin/env python3
"""Generate the original 20x20 Vela Test micro-PoC map layout."""

from pathlib import Path
import struct


WIDTH = 20
HEIGHT = 20
PATH = 0x3001
GRASS = 0x300D
TREE = ((0x05D4, 0x05D5), (0x05DC, 0x05DD))


def main() -> None:
    grid = [[PATH for _ in range(WIDTH)] for _ in range(HEIGHT)]

    # A two-metatile tree wall encloses the SOMADEX test clearing.
    for x in range(0, WIDTH, 2):
        for y in (0, HEIGHT - 2):
            grid[y][x] = TREE[0][0]
            grid[y][min(x + 1, WIDTH - 1)] = TREE[0][1]
            grid[y + 1][x] = TREE[1][0]
            grid[y + 1][min(x + 1, WIDTH - 1)] = TREE[1][1]
    for y in range(2, HEIGHT - 2, 2):
        for x in (0, WIDTH - 2):
            grid[y][x] = TREE[0][0]
            grid[y][x + 1] = TREE[0][1]
            grid[y + 1][x] = TREE[1][0]
            grid[y + 1][x + 1] = TREE[1][1]

    # Symmetric grass banks and a lower Resonance strip make the composition
    # distinct from the upstream Route 101 layout while retaining native GBA
    # collision and encounter behavior.
    for y in range(4, 9):
        for x in range(3, 8):
            grid[y][x] = GRASS
        for x in range(12, 17):
            grid[y][x] = GRASS
    for y in range(11, 14):
        for x in range(4, 7):
            grid[y][x] = GRASS
        for x in range(13, 16):
            grid[y][x] = GRASS
    for x in range(7, 14):
        grid[16][x] = GRASS

    output = Path(__file__).resolve().parents[1] / "data/layouts/Route101/map.bin"
    output.write_bytes(b"".join(struct.pack("<H", cell) for row in grid for cell in row))
    print(f"wrote {output} ({WIDTH}x{HEIGHT})")


if __name__ == "__main__":
    main()
