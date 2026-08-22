#!/usr/bin/env python3
"""Generate the original 20x20 Vela vertical-slice map into the locked upstream tree."""

import argparse
import struct
from pathlib import Path

WIDTH = 20
HEIGHT = 20
PATH = 0x3001
GRASS = 0x300D
TREE = ((0x05D4, 0x05D5), (0x05DC, 0x05DD))


def build_grid():
    grid = [[PATH for _ in range(WIDTH)] for _ in range(HEIGHT)]

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

    return grid


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()

    upstream = args.upstream_root.resolve()
    if not (upstream / "data/layouts/Route101").is_dir():
        raise SystemExit(f"locked upstream layout directory not found: {upstream / 'data/layouts/Route101'}")

    output = upstream / "data/layouts/Route101/map.bin"
    grid = build_grid()
    payload = b"".join(struct.pack("<H", cell) for row in grid for cell in row)
    expected_bytes = WIDTH * HEIGHT * 2
    if len(payload) != expected_bytes:
        raise SystemExit(f"unexpected map size: {len(payload)} != {expected_bytes}")

    output.write_bytes(payload)
    print(f"PHASE3 MAP PASS: wrote {output} ({WIDTH}x{HEIGHT}, {len(payload)} bytes)")


if __name__ == "__main__":
    main()
