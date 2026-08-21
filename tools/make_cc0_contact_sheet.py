#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

TILE = 16
SCALE = 3
LABEL_H = 12
PAD = 2
SOURCES = {
    "tileset_floor": Path("assets/external/ninja_adventure/map/tileset_floor.png"),
    "tileset_village": Path("assets/external/ninja_adventure/map/tileset_village.png"),
    "tileset_animated": Path("assets/external/ninja_adventure/map/tileset_animated.png"),
    "tileset_wall": Path("assets/external/ninja_adventure/map/tileset_wall.png"),
    "player_base": Path("assets/external/ninja_adventure/character/player_base.png"),
}
OUT_DIR = Path("build/visual_qa")


def make_sheet(name: str, src: Path) -> None:
    if not src.exists():
        raise SystemExit(f"missing fetched CC0 source: {src}")
    image = Image.open(src).convert("RGBA")
    cols = image.width // TILE
    rows = image.height // TILE
    if cols <= 0 or rows <= 0:
        raise SystemExit(f"invalid 16px atlas: {src} ({image.width}x{image.height})")

    cell_w = TILE * SCALE + PAD * 2
    cell_h = TILE * SCALE + LABEL_H + PAD * 2
    sheet = Image.new("RGBA", (cols * cell_w, rows * cell_h), (17, 24, 28, 255))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()

    for y in range(rows):
        for x in range(cols):
            crop = image.crop((x*TILE, y*TILE, (x+1)*TILE, (y+1)*TILE))
            crop = crop.resize((TILE*SCALE, TILE*SCALE), Image.Resampling.NEAREST)
            px = x * cell_w + PAD
            py = y * cell_h + PAD
            sheet.alpha_composite(crop, (px, py))
            label = f"{x},{y}"
            draw.rectangle(
                (px, py + TILE*SCALE, px + TILE*SCALE - 1, py + TILE*SCALE + LABEL_H - 1),
                fill=(3, 8, 12, 235),
            )
            draw.text((px + 1, py + TILE*SCALE + 1), label, font=font, fill=(235, 250, 248, 255))
            draw.rectangle(
                (px-1, py-1, px + TILE*SCALE, py + TILE*SCALE + LABEL_H),
                outline=(72, 128, 132, 255),
            )

    out = OUT_DIR / f"cc0_{name}_contact.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print(f"CC0 CONTACT SHEET: {name} {cols}x{rows} cells -> {out} ({sheet.width}x{sheet.height})")


for atlas_name, atlas_path in SOURCES.items():
    make_sheet(atlas_name, atlas_path)
