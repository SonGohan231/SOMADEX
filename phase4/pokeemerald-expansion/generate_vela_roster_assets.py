#!/usr/bin/env python3
"""Generate deterministic GBA battle assets for the first Vela roster.

The silhouettes are compact pixel-art interpretations of the approved SOMADEX
concept families from the Drive art pack. They intentionally favour runtime
readability and reproducibility now; later art polish can replace the PNGs without
changing species IDs, stats, encounters or save data.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

ROSTERS = {
    "bocznik": {
        "palette": ["#00B0E8", "#102830", "#244850", "#416E58", "#77A83E", "#B9D94E", "#E7F174", "#7AC9D6", "#D7F3F2", "#FFFFFF", "#345E8C", "#4E87B8", "#173642", "#D98E3F", "#E3C35C", "#F800F8"],
        "kind": "axolotl",
    },
    "milimik": {
        "palette": ["#00B0E8", "#141626", "#262343", "#3C3560", "#5C5484", "#8178A8", "#A9A1C7", "#D3CFE2", "#F4F1FA", "#FFFFFF", "#66778E", "#93A8BC", "#28384D", "#6FC6C0", "#C9E0DA", "#F800F8"],
        "kind": "fuzzy_bug",
    },
    "wahlik": {
        "palette": ["#00B0E8", "#101B35", "#20305E", "#2E4D86", "#4772A8", "#6E9FD0", "#9EC4E3", "#CFDFF1", "#F6F4FC", "#FFFFFF", "#5E3E80", "#8E5EAD", "#C58ACB", "#F0A7D4", "#55C9D0", "#F800F8"],
        "kind": "crescent_whale",
    },
    "nucik": {
        "palette": ["#00B0E8", "#171424", "#2C203B", "#49345B", "#68517C", "#8F76A3", "#B59AC0", "#E1D1E3", "#F5EFEA", "#FFFFFF", "#7A4D31", "#A66B36", "#D89B45", "#F2D26A", "#F6E9A7", "#F800F8"],
        "kind": "lantern_owl",
    },
    "dudnik": {
        "palette": ["#00B0E8", "#162238", "#254469", "#3476A4", "#50A7D5", "#82D5EE", "#C4EDF7", "#F4FBFD", "#FFFFFF", "#473226", "#8A542D", "#D48234", "#F2AE49", "#F6D26A", "#EF7643", "#F800F8"],
        "kind": "twin_orbs",
    },
}


def run(*args: str) -> None:
    subprocess.run(args, check=True)


def rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i:i+2], 16) for i in (0, 2, 4))


def write_ppm(path: Path, width: int, height: int, pixels) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as handle:
        handle.write(f"P6\n{width} {height}\n255\n".encode("ascii"))
        for color in pixels:
            handle.write(bytes(color))


def write_jasc(path: Path, colors: list[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    values = [rgb(c) for c in colors]
    path.write_text(
        "JASC-PAL\n0100\n16\n" + "".join(f"{r} {g} {b}\n" for r, g, b in values),
        encoding="ascii",
    )


def palette_strip(colors: list[str], out: Path) -> None:
    args = ["convert"] + [f"xc:{c}" for c in colors] + ["+append", str(out)]
    run(*args)


def canvas(colors: list[str]):
    w = h = 64
    pix = [rgb(colors[0])] * (w * h)
    return w, h, pix


def put(pix, x, y, color, w=64, h=64):
    if 0 <= x < w and 0 <= y < h:
        pix[y * w + x] = color


def ellipse(pix, cx, cy, rx, ry, color, w=64, h=64):
    if rx <= 0 or ry <= 0:
        return
    bound = (rx * ry) ** 2
    for y in range(cy - ry, cy + ry + 1):
        for x in range(cx - rx, cx + rx + 1):
            if ((x - cx) ** 2) * (ry ** 2) + ((y - cy) ** 2) * (rx ** 2) <= bound:
                put(pix, x, y, color, w, h)


def line(pix, x0, y0, x1, y1, color, thickness=1):
    dx = abs(x1 - x0); sx = 1 if x0 < x1 else -1
    dy = -abs(y1 - y0); sy = 1 if y0 < y1 else -1
    err = dx + dy
    while True:
        for oy in range(-thickness + 1, thickness):
            for ox in range(-thickness + 1, thickness):
                put(pix, x0 + ox, y0 + oy, color)
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 >= dy:
            err += dy; x0 += sx
        if e2 <= dx:
            err += dx; y0 += sy


def eye(pix, x, y, dark, light):
    ellipse(pix, x, y, 4, 5, dark)
    ellipse(pix, x - 1, y - 1, 1, 2, light)


def draw_axolotl(colors, rear=False):
    _, _, p = canvas(colors)
    c = [rgb(x) for x in colors]
    ellipse(p, 32, 39, 18, 10, c[3])
    ellipse(p, 32, 37, 16, 8, c[5])
    ellipse(p, 20 if not rear else 29, 31, 10, 9, c[4])
    ellipse(p, 20 if not rear else 29, 30, 8, 7, c[6])
    # tail and lateral fins
    line(p, 45, 39, 57, 32, c[2], 2); line(p, 46, 40, 58, 39, c[6], 2)
    for yy in (24, 29, 34):
        line(p, 13 if not rear else 22, 30, 7 if not rear else 15, yy, c[10], 2)
        line(p, 27 if not rear else 36, 30, 33 if not rear else 43, yy, c[11], 2)
    if not rear:
        eye(p, 17, 29, c[1], c[9]); eye(p, 23, 29, c[1], c[9])
    else:
        line(p, 28, 25, 30, 45, c[2], 1)
    ellipse(p, 23, 47, 6, 3, c[3]); ellipse(p, 39, 47, 6, 3, c[3])
    return p


def draw_fuzzy_bug(colors, rear=False):
    _, _, p = canvas(colors); c=[rgb(x) for x in colors]
    # fuzzy halo
    for dx,dy in [(-13,-4),(-10,-10),(-4,-13),(4,-13),(10,-9),(14,-3),(13,5),(8,10),(0,12),(-8,10),(-14,4)]:
        ellipse(p, 32+dx, 36+dy, 5, 5, c[6])
    ellipse(p,32,36,15,12,c[5]); ellipse(p,32,37,12,9,c[6])
    # segmented back shell
    for x in (26,32,38):
        ellipse(p,x,42,5,4,c[3])
    line(p,26,24,22,10,c[4],1); line(p,38,24,42,9,c[4],1)
    ellipse(p,22,9,2,2,c[7]); ellipse(p,42,8,2,2,c[7])
    if not rear:
        eye(p,27,33,c[1],c[9]); eye(p,37,33,c[1],c[9])
    else:
        line(p,32,27,32,47,c[2],1)
    for x in (22,28,36,42): line(p,x,46,x-2 if x<32 else x+2,51,c[2],1)
    return p


def draw_crescent_whale(colors, rear=False):
    _, _, p=canvas(colors); c=[rgb(x) for x in colors]
    ellipse(p,33,37,18,10,c[3]); ellipse(p,31,35,15,8,c[5])
    # crescent dorsal/tail motif
    for y in range(13,35):
        x=24-int((y-24)**2/28)
        ellipse(p,x, y, 3, 3, c[12])
    line(p,47,38,59,30,c[4],2); line(p,47,39,59,46,c[4],2)
    ellipse(p,58,30,5,4,c[12]); ellipse(p,58,46,5,4,c[11])
    ellipse(p,28,45,10,3,c[10])
    if not rear:
        eye(p,24,34,c[1],c[9])
        ellipse(p,17,38,2,1,c[8])
    else:
        line(p,34,28,34,45,c[2],1)
    return p


def draw_lantern_owl(colors, rear=False):
    _, _, p=canvas(colors); c=[rgb(x) for x in colors]
    ellipse(p,32,37,13,17,c[3]); ellipse(p,32,35,11,15,c[5])
    ellipse(p,32,23,12,10,c[4])
    # ears
    line(p,24,18,21,9,c[2],2); line(p,40,18,43,9,c[2],2)
    # wings
    ellipse(p,20,39,7,13,c[3]); ellipse(p,44,39,7,13,c[3])
    if not rear:
        eye(p,28,22,c[1],c[9]); eye(p,36,22,c[1],c[9])
        # beak and lantern chest
        line(p,32,27,32,31,c[12],2)
        ellipse(p,32,40,7,9,c[12]); ellipse(p,32,40,5,7,c[13]); ellipse(p,32,39,2,4,c[14])
    else:
        for y in range(25,49,4): line(p,27,y,37,y,c[2],1)
    line(p,27,53,24,57,c[10],1); line(p,37,53,40,57,c[10],1)
    return p


def draw_twin_orbs(colors, rear=False):
    _, _, p=canvas(colors); c=[rgb(x) for x in colors]
    centers=((24,36,4,13),(40,36,12,14))
    for cx,cy,tuft,glow in centers:
        # tuft
        line(p,cx,23,cx-5,14,c[tuft],2); line(p,cx,23,cx,11,c[tuft],2); line(p,cx,23,cx+5,15,c[tuft],2)
        ellipse(p,cx,37,10,12,c[6]); ellipse(p,cx,36,8,10,c[7])
        ellipse(p,cx,43,5,5,c[glow]); ellipse(p,cx,43,2,2,c[8])
        if not rear:
            eye(p,cx-3,33,c[1],c[8]); eye(p,cx+3,33,c[1],c[8])
        else:
            line(p,cx,29,cx,47,c[2],1)
    return p


DRAWERS = {
    "axolotl": draw_axolotl,
    "fuzzy_bug": draw_fuzzy_bug,
    "crescent_whale": draw_crescent_whale,
    "lantern_owl": draw_lantern_owl,
    "twin_orbs": draw_twin_orbs,
}


def main() -> None:
    parser=argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args=parser.parse_args()
    root=args.upstream_root.resolve()
    if shutil.which("convert") is None:
        raise SystemExit("ImageMagick 'convert' is required")

    with tempfile.TemporaryDirectory(prefix="somadex-vela-roster-") as td:
        tmp=Path(td)
        for stem,cfg in ROSTERS.items():
            colors=cfg["palette"]
            strip=tmp/f"{stem}-pal.png"
            palette_strip(colors, strip)
            front_ppm=tmp/f"{stem}-front.ppm"
            back_ppm=tmp/f"{stem}-back.ppm"
            write_ppm(front_ppm,64,64,DRAWERS[cfg["kind"]](colors,False))
            write_ppm(back_ppm,64,64,DRAWERS[cfg["kind"]](colors,True))

            out=root/f"graphics/pokemon/{stem}"
            out.mkdir(parents=True, exist_ok=True)
            front=tmp/f"{stem}-front.png"
            back=out/"back.png"
            run("convert",str(front_ppm),"-remap",str(strip),f"PNG8:{front}")
            run("convert",str(back_ppm),"-remap",str(strip),f"PNG8:{back}")
            # Two-frame front strip required by the standard species pipeline.
            run("convert",str(front),str(front),"-append","-remap",str(strip),f"PNG8:{out/'anim_front.png'}")
            shutil.copy2(out/"anim_front.png",out/"anim_front_gba.png")
            shutil.copy2(back,out/"back_gba.png")
            # Two identical icon frames for now; animation polish is a later art pass.
            icon=tmp/f"{stem}-icon.png"
            run("convert",str(front),"-filter","point","-resize","28x28","-gravity","center","-extent","32x32","-remap",str(strip),f"PNG8:{icon}")
            run("convert",str(icon),str(icon),"-append","-remap",str(strip),f"PNG8:{out/'icon.png'}")
            shutil.copy2(out/"icon.png",out/"icon_gba.png")
            write_jasc(out/"normal.pal",colors)
            write_jasc(out/"shiny.pal",colors)
            print(f"VELA ROSTER ART: generated {stem} front/back/icon")

    print("PHASE4 ROSTER ART PASS: Bocznik, Milimik, Wahlik, Nucik and Dudnik runtime sprites generated")


if __name__ == "__main__":
    main()
