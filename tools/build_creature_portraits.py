#!/usr/bin/env python3
"""Build normalized SOMADEX battle-portrait assets from the source creature ZIP.

The source package contains 960x720 card-style JPGs. This tool extracts the inner
artwork, removes the card header/footer region, preserves aspect ratio, writes
small deterministic WebP portraits, and packs them into an atlas with a CSV
manifest. It does not pretend the card art is a transparent animation sprite;
those are produced in the later seed/strip pipeline documented in
CREATURE_ART_PIPELINE.md.
"""

from __future__ import annotations

import argparse
import csv
import math
import re
import shutil
import tempfile
import zipfile
from dataclasses import dataclass
from pathlib import Path

try:
    from PIL import Image
except ImportError as exc:  # pragma: no cover - developer tool dependency
    raise SystemExit("Pillow is required: python -m pip install pillow") from exc


FORMS_DIR = "02_OSOBNE_FORMY_150_STWORKOW"
CARD_CROP = (30, 78, 930, 625)
DEFAULT_CELL = (224, 144)
DEFAULT_COLUMNS = 6


@dataclass(frozen=True)
class FormSource:
    family_id: int
    stage: int
    name: str
    path: Path


def canonical_name(name: str) -> str:
    if name.casefold() == "uczek":
        return "Uczek"
    return name


def parse_family_filter(raw: str | None) -> set[int] | None:
    if not raw:
        return None
    result: set[int] = set()
    for token in raw.split(","):
        token = token.strip()
        if not token:
            continue
        if "-" in token:
            start, end = token.split("-", 1)
            result.update(range(int(start), int(end) + 1))
        else:
            result.add(int(token))
    return result


def source_name(path: Path) -> tuple[int, str]:
    stem = path.stem
    parts = stem.split("_")
    if len(parts) < 3:
        raise ValueError(f"Unrecognized form filename: {path.name}")
    stage = int(parts[1])
    markers = ("FORMA_BAZOWA_", "EWOLUCJA_I_", "EWOLUCJA_FINALOWA_")
    for marker in markers:
        if marker in stem:
            return stage, canonical_name(stem.split(marker, 1)[1])
    raise ValueError(f"Could not find creature name in: {path.name}")


def discover_forms(root: Path, families: set[int] | None) -> list[FormSource]:
    forms_root = root / FORMS_DIR
    if not forms_root.is_dir():
        raise FileNotFoundError(f"Missing {FORMS_DIR} in source package")
    result: list[FormSource] = []
    for family_dir in sorted(forms_root.iterdir()):
        if not family_dir.is_dir():
            continue
        match = re.match(r"(\d{3})_", family_dir.name)
        if not match:
            continue
        family_id = int(match.group(1))
        if families is not None and family_id not in families:
            continue
        for source in sorted(family_dir.glob("*.jpg")):
            stage, name = source_name(source)
            result.append(FormSource(family_id, stage, name, source))
    result.sort(key=lambda item: (item.family_id, item.stage, item.name))
    return result


def normalize_card(source: Path, size: tuple[int, int]) -> Image.Image:
    image = Image.open(source).convert("RGB")
    art = image.crop(CARD_CROP)
    art.thumbnail(size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", size, (9, 25, 31))
    x = (size[0] - art.width) // 2
    y = (size[1] - art.height) // 2
    canvas.paste(art, (x, y))
    return canvas


def build(source_zip: Path, out_dir: Path, families: set[int] | None, size: tuple[int, int], columns: int, quality: int) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    portraits_dir = out_dir / "portraits"
    if portraits_dir.exists():
        shutil.rmtree(portraits_dir)
    portraits_dir.mkdir(parents=True)

    with tempfile.TemporaryDirectory(prefix="somadex-art-") as tmp:
        root = Path(tmp)
        with zipfile.ZipFile(source_zip) as archive:
            archive.extractall(root)
        forms = discover_forms(root, families)
        if not forms:
            raise SystemExit("No creature forms matched the requested filter")

        rows = math.ceil(len(forms) / columns)
        atlas = Image.new("RGB", (columns * size[0], rows * size[1]), (9, 25, 31))
        manifest_rows: list[dict[str, object]] = []

        for index, form in enumerate(forms):
            portrait = normalize_card(form.path, size)
            file_name = f"{form.family_id:03d}_{form.stage}_{form.name}.webp"
            portrait.save(portraits_dir / file_name, "WEBP", quality=quality, method=6)
            x = (index % columns) * size[0]
            y = (index // columns) * size[1]
            atlas.paste(portrait, (x, y))
            manifest_rows.append(
                {
                    "name": form.name,
                    "index": index,
                    "family_id": form.family_id,
                    "stage": form.stage,
                    "x": x,
                    "y": y,
                    "width": size[0],
                    "height": size[1],
                    "source": form.path.name,
                }
            )

        atlas_path = out_dir / "creature_portraits.webp"
        atlas.save(atlas_path, "WEBP", quality=quality, method=6)
        with (out_dir / "creature_portraits.csv").open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(manifest_rows[0].keys()))
            writer.writeheader()
            writer.writerows(manifest_rows)

        print(f"Built {len(forms)} portraits")
        print(f"Atlas: {atlas_path} ({atlas.width}x{atlas.height})")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-zip", type=Path, required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    parser.add_argument("--families", help="Example: 1-10,15. Default: all families")
    parser.add_argument("--cell-width", type=int, default=DEFAULT_CELL[0])
    parser.add_argument("--cell-height", type=int, default=DEFAULT_CELL[1])
    parser.add_argument("--columns", type=int, default=DEFAULT_COLUMNS)
    parser.add_argument("--quality", type=int, default=85)
    args = parser.parse_args()
    if args.cell_width <= 0 or args.cell_height <= 0 or args.columns <= 0:
        raise SystemExit("Cell dimensions and columns must be positive")
    build(
        args.source_zip,
        args.out_dir,
        parse_family_filter(args.families),
        (args.cell_width, args.cell_height),
        args.columns,
        max(1, min(100, args.quality)),
    )


if __name__ == "__main__":
    main()
