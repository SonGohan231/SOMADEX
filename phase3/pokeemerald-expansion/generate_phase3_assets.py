#!/usr/bin/env python3
import argparse
import base64
import shutil
import struct
import subprocess
import tempfile
from pathlib import Path

LUZIK_COLORS = [
    "#00B0E8", "#081820", "#103040", "#185058",
    "#287880", "#40A8A8", "#70D8D0", "#C0F8E8",
    "#F8F8F8", "#F0E058", "#E89038", "#784830",
    "#607070", "#303840", "#D04040", "#F800F8",
]
PERSON_COLORS = [
    "#73C5A4", "#5B3A29", "#E1A474", "#9A5E49",
    "#19384D", "#102334", "#39D0CD", "#E9F2ED",
    "#768389", "#101010", "#EEC85E", "#C54141",
    "#394A7B", "#293962", "#FFFFFF", "#000000",
]
ICON_COLORS = [
    "#629C83", "#737373", "#BDBDBD", "#FFFFFF",
    "#416A94", "#6294A4", "#94C5DE", "#C5E6EE",
    "#294152", "#E6C54A", "#E68B31", "#8B5231",
    "#DE737B", "#984A52", "#62625A", "#414141",
]
BATTLE_COLORS = [
    (11, 27, 35), (18, 53, 62), (25, 82, 88), (37, 111, 111),
    (51, 145, 137), (77, 178, 158), (112, 216, 190), (176, 242, 218),
    (31, 48, 58), (57, 73, 85), (93, 109, 119), (135, 149, 154),
    (222, 200, 83), (232, 145, 57), (105, 69, 52), (248, 248, 240),
]


def run(*args: str) -> None:
    subprocess.run(args, check=True)


def write_jasc(path: Path, colors) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rgb = []
    for color in colors:
        if isinstance(color, str):
            color = color.lstrip("#")
            rgb.append(tuple(int(color[i:i+2], 16) for i in (0, 2, 4)))
        else:
            rgb.append(tuple(color))
    path.write_text(
        "JASC-PAL\n0100\n" + str(len(rgb)) + "\n" +
        "".join(f"{r} {g} {b}\n" for r, g, b in rgb),
        encoding="ascii",
    )


def write_ppm(path: Path, width: int, height: int, pixels) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as handle:
        handle.write(f"P6\n{width} {height}\n255\n".encode("ascii"))
        for r, g, b in pixels:
            handle.write(bytes((r, g, b)))


def rgb(hex_color: str):
    value = hex_color.lstrip("#")
    return tuple(int(value[i:i+2], 16) for i in (0, 2, 4))


def authored_luzik_back(path: Path) -> None:
    # Separately authored rear silhouette: not a mirror/flip of the front seed.
    w = h = 64
    bg = rgb(LUZIK_COLORS[0])
    dark = rgb(LUZIK_COLORS[1])
    deep = rgb(LUZIK_COLORS[3])
    body = rgb(LUZIK_COLORS[5])
    light = rgb(LUZIK_COLORS[6])
    glow = rgb(LUZIK_COLORS[9])
    pixels = [bg] * (w * h)

    def put(x, y, color):
        if 0 <= x < w and 0 <= y < h:
            pixels[y * w + x] = color

    def ellipse(cx, cy, rx, ry, color):
        for y in range(cy - ry, cy + ry + 1):
            for x in range(cx - rx, cx + rx + 1):
                if ((x - cx) ** 2) * (ry ** 2) + ((y - cy) ** 2) * (rx ** 2) <= (rx * ry) ** 2:
                    put(x, y, color)

    ellipse(32, 39, 16, 13, dark)
    ellipse(32, 37, 14, 11, body)
    ellipse(32, 27, 11, 10, dark)
    ellipse(32, 27, 9, 8, light)
    # Rear ridge and asymmetric resonance fins make the pose explicitly rear-facing.
    for y in range(23, 44):
        put(31, y, deep)
        put(32, y, deep)
    for x, y in [(20, 27), (18, 29), (17, 32), (44, 26), (46, 28), (47, 31)]:
        ellipse(x, y, 2, 3, glow)
    ellipse(24, 49, 5, 4, dark)
    ellipse(40, 49, 5, 4, dark)
    ellipse(24, 48, 3, 2, body)
    ellipse(40, 48, 3, 2, body)
    for x in range(27, 38):
        put(x, 20 + abs(32 - x) // 3, glow)
    write_ppm(path, w, h, pixels)


def kula_splotu_icon(path: Path) -> None:
    w = h = 32
    bg = rgb(ICON_COLORS[0])
    edge = rgb(ICON_COLORS[8])
    shell = rgb(ICON_COLORS[6])
    light = rgb(ICON_COLORS[3])
    core = rgb(ICON_COLORS[9])
    pixels = [bg] * (w * h)

    def put(x, y, color):
        if 0 <= x < w and 0 <= y < h:
            pixels[y * w + x] = color

    for y in range(5, 27):
        for x in range(5, 27):
            d = (x - 15.5) ** 2 + (y - 15.5) ** 2
            if d <= 121:
                put(x, y, edge if d >= 93 else shell)
    for x in range(7, 25):
        put(x, 15, edge)
        put(x, 16, edge)
    for y in range(12, 20):
        for x in range(12, 20):
            d = (x - 15.5) ** 2 + (y - 15.5) ** 2
            if d <= 16:
                put(x, y, core if d > 7 else light)
    write_ppm(path, w, h, pixels)


def battle_tiles(path: Path) -> None:
    w = h = 128
    pixels = []
    for y in range(h):
        for x in range(w):
            band = ((x // 8) + (y // 8)) % 6
            if ((x - 64) ** 2 + (y - 64) ** 2) % 257 < 34:
                band = 12
            pixels.append(BATTLE_COLORS[band])
    write_ppm(path, w, h, pixels)


def make_palette_strip(colors, out: Path) -> None:
    args = ["convert"]
    args.extend(f"xc:{c}" for c in colors)
    args.extend(["+append", str(out)])
    run(*args)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--somadex-root", required=True, type=Path)
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    soma = args.somadex_root.resolve()
    upstream = args.upstream_root.resolve()

    if shutil.which("convert") is None:
        raise SystemExit("ImageMagick 'convert' is required")

    with tempfile.TemporaryDirectory(prefix="somadex-phase3-") as temp_name:
        temp = Path(temp_name)
        for stem, source in [
            ("luzik", soma / "assets/embedded/luzik.b64"),
            ("trainer", soma / "assets/embedded/trainer_walk.b64"),
            ("mira", soma / "assets/embedded/npc_mira.b64"),
        ]:
            (temp / f"{stem}.png").write_bytes(base64.b64decode(source.read_bytes()))

        luzik_strip = temp / "luzik-palette.png"
        person_strip = temp / "person-palette.png"
        icon_strip = temp / "icon-palette.png"
        make_palette_strip(LUZIK_COLORS, luzik_strip)
        make_palette_strip(PERSON_COLORS, person_strip)
        make_palette_strip(ICON_COLORS, icon_strip)

        # Luzik: own production path; front from owned concept seed, rear separately authored.
        mon_dir = upstream / "graphics/pokemon/luzik"
        mon_dir.mkdir(parents=True, exist_ok=True)
        front_indexed = temp / "luzik-indexed.png"
        run("convert", str(temp / "luzik.png"), "-background", LUZIK_COLORS[0], "-alpha", "background", "-flatten",
            "-remap", str(luzik_strip), str(front_indexed))
        run("convert", "-size", "64x128", f"xc:{LUZIK_COLORS[0]}", str(front_indexed), "-geometry", "+8+8", "-composite",
            str(front_indexed), "-geometry", "+8+72", "-composite", "-remap", str(luzik_strip), f"PNG8:{mon_dir / 'anim_front.png'}")
        shutil.copy2(mon_dir / "anim_front.png", mon_dir / "anim_front_gba.png")

        back_ppm = temp / "luzik-back.ppm"
        authored_luzik_back(back_ppm)
        run("convert", str(back_ppm), "-remap", str(luzik_strip), f"PNG8:{mon_dir / 'back.png'}")
        shutil.copy2(mon_dir / "back.png", mon_dir / "back_gba.png")

        icon_frame = temp / "luzik-icon.png"
        run("convert", str(temp / "luzik.png"), "-background", ICON_COLORS[0], "-alpha", "background", "-flatten",
            "-filter", "point", "-resize", "28x28", "-gravity", "center", "-extent", "32x32", "-remap", str(icon_strip), str(icon_frame))
        run("convert", str(icon_frame), str(icon_frame), "-append", "-remap", str(icon_strip), f"PNG8:{mon_dir / 'icon.png'}")
        shutil.copy2(mon_dir / "icon.png", mon_dir / "icon_gba.png")
        write_jasc(mon_dir / "normal.pal", LUZIK_COLORS)
        write_jasc(mon_dir / "shiny.pal", LUZIK_COLORS)

        # Player and Mira use owned SOMADEX pixels while retaining temporary engine graphic slots.
        for frame in range(8):
            run("convert", str(temp / "trainer.png"), "-crop", f"24x24+{frame * 24}+0", "+repage", "-trim",
                "-background", PERSON_COLORS[0], "-alpha", "background", "-flatten", "-gravity", "south", "-extent", "16x32",
                "-remap", str(person_strip), str(temp / f"trainer-{frame}.png"))
        trainer_out = upstream / "graphics/object_events/pics/people/brendan/walking.png"
        run("convert", *(str(temp / f"trainer-{i}.png") for i in [0,1,1,2,3,3,4,5,5]), "+append", "-remap", str(person_strip), f"PNG8:{trainer_out}")
        shutil.copy2(trainer_out, trainer_out.with_name("running.png"))

        for frame in range(2):
            run("convert", str(temp / "mira.png"), "-crop", f"24x24+{frame * 24}+0", "+repage", "-trim",
                "-background", PERSON_COLORS[0], "-alpha", "background", "-flatten", "-gravity", "south", "-extent", "16x32",
                "-remap", str(person_strip), str(temp / f"mira-{frame}.png"))
        mira_out = upstream / "graphics/object_events/pics/people/boy_2.png"
        run("convert", *(str(temp / f"mira-{i}.png") for i in [0,1,1,0,1,1,0,1,1]), "+append", "-remap", str(person_strip), f"PNG8:{mira_out}")

        # Original capture-device icon.
        item_icon_ppm = temp / "kula.ppm"
        kula_splotu_icon(item_icon_ppm)
        item_icon = upstream / "graphics/items/icons/kula_splotu.png"
        item_icon.parent.mkdir(parents=True, exist_ok=True)
        run("convert", str(item_icon_ppm), "-remap", str(icon_strip), f"PNG8:{item_icon}")
        write_jasc(upstream / "graphics/items/icon_palettes/kula_splotu.pal", ICON_COLORS)

        # Replace the reachable tall-grass battle environment with original resonance art.
        battle_ppm = temp / "battle.ppm"
        battle_tiles(battle_ppm)
        battle_dir = upstream / "graphics/battle_environment/tall_grass"
        battle_strip = temp / "battle-palette.png"
        battle_hex = ["#%02X%02X%02X" % c for c in BATTLE_COLORS]
        make_palette_strip(battle_hex, battle_strip)
        run("convert", str(battle_ppm), "-remap", str(battle_strip), f"PNG8:{battle_dir / 'tiles.png'}")
        run("convert", str(battle_ppm), "-roll", "+8+0", "-remap", str(battle_strip), f"PNG8:{battle_dir / 'anim_tiles.png'}")
        write_jasc(battle_dir / "palette.pal", BATTLE_COLORS)
        # Keep exact binary dimensions expected by the engine, but use an original deterministic tile layout.
        with (battle_dir / "map.bin").open("wb") as handle:
            for i in range(2048):
                handle.write(struct.pack("<H", (i + (i // 32)) % 64))
        with (battle_dir / "anim_map.bin").open("wb") as handle:
            for i in range(1024):
                handle.write(struct.pack("<H", (i * 3) % 64))

    print("PHASE3 ASSETS PASS: Luzik front/back/icon, player, Mira, Kula Splotu and battle environment generated")


if __name__ == "__main__":
    main()
