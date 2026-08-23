#!/usr/bin/env python3
"""Install the first playable Vela roster on the locked SOMADEX foundation.

Luzik already exists from Phase 3. This block adds five approved base forms from
the SOMADEX art pack, five simple signature moves and real wild encounter tables.
The goal is immediate gameplay variety, not final balance or the full 150-form dex.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

SPECIES = ["BOCZNIK", "MILIMIK", "WAHLIK", "NUCIK", "DUDNIK"]
MOVES = ["SLIZG_BOCZNY", "MIKROSKOK", "FALA_WAHADLA", "NUTA_REZONANSU", "DWUPUNKT"]


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: {label}: expected one anchor, found {count}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def append_once(path: Path, marker: str, block: str) -> None:
    text = path.read_text(encoding="utf-8")
    if marker in text:
        return
    path.write_text(text.rstrip() + "\n\n" + block.rstrip() + "\n", encoding="utf-8")


def install_constants(root: Path) -> None:
    species_h = root / "include/constants/species.h"
    text = species_h.read_text(encoding="utf-8")
    if "SPECIES_BOCZNIK" not in text:
        pattern = re.compile(r"^(?P<i>[ \t]*)SPECIES_LUZIK,[ \t]*\n(?P=i)SPECIES_CUSTOM_END,", re.MULTILINE)
        repl = (
            r"\g<i>SPECIES_LUZIK,\n"
            r"\g<i>SPECIES_BOCZNIK,\n"
            r"\g<i>SPECIES_MILIMIK,\n"
            r"\g<i>SPECIES_WAHLIK,\n"
            r"\g<i>SPECIES_NUCIK,\n"
            r"\g<i>SPECIES_DUDNIK,\n"
            r"\g<i>SPECIES_CUSTOM_END,"
        )
        text, count = pattern.subn(repl, text, count=1)
        if count != 1:
            raise SystemExit("species constants: cannot find Phase 3 custom boundary")
        species_h.write_text(text, encoding="utf-8")

    moves_h = root / "include/constants/moves.h"
    text = moves_h.read_text(encoding="utf-8")
    if "MOVE_SLIZG_BOCZNY" not in text:
        pattern = re.compile(
            r"^(?P<i>[ \t]*)MOVE_IMPULS_WARSTWOWY\s*=\s*MOVES_COUNT_GEN9,[ \t]*\n"
            r"(?P<gap>\s*)MOVES_COUNT,",
            re.MULTILINE,
        )
        repl = (
            r"\g<i>MOVE_IMPULS_WARSTWOWY = MOVES_COUNT_GEN9,\n"
            r"\g<i>MOVE_SLIZG_BOCZNY,\n"
            r"\g<i>MOVE_MIKROSKOK,\n"
            r"\g<i>MOVE_FALA_WAHADLA,\n"
            r"\g<i>MOVE_NUTA_REZONANSU,\n"
            r"\g<i>MOVE_DWUPUNKT,\n\n"
            r"\g<i>MOVES_COUNT,"
        )
        text, count = pattern.subn(repl, text, count=1)
        if count != 1:
            raise SystemExit("move constants: cannot find Phase 3 custom boundary")
        moves_h.write_text(text, encoding="utf-8")


def install_graphics(root: Path) -> None:
    path = root / "src/data/graphics/pokemon.h"
    entries = []
    for proper in ("Bocznik", "Milimik", "Wahlik", "Nucik", "Dudnik"):
        stem = proper.lower()
        entries.extend([
            f'const u32 gMonFrontPic_{proper}[] = INCGFX_U32("graphics/pokemon/{stem}/anim_front.png", ".4bpp.smol");',
            f'const u16 gMonPalette_{proper}[] = INCGFX_U16("graphics/pokemon/{stem}/normal.pal", ".gbapal");',
            f'const u32 gMonBackPic_{proper}[] = INCGFX_U32("graphics/pokemon/{stem}/back.png", ".4bpp.smol");',
            f'const u16 gMonShinyPalette_{proper}[] = INCGFX_U16("graphics/pokemon/{stem}/shiny.pal", ".gbapal");',
            f'const u8 gMonIcon_{proper}[] = INCGFX_U8("graphics/pokemon/{stem}/icon.png", ".4bpp");',
            "",
        ])
    append_once(path, "gMonFrontPic_Bocznik", "// SOMADEX Phase 4 Vela roster assets.\n" + "\n".join(entries))


def learnsets_block() -> str:
    return '''static const struct LevelUpMove sBocznikLevelUpLearnset[] =
{
    {.move = MOVE_SLIZG_BOCZNY, .level = 1},
    {.move = MOVE_IMPULS_WARSTWOWY, .level = 5},
    {.move = LEVEL_UP_MOVE_END, .level = 0},
};
static const struct LevelUpMove sMilimikLevelUpLearnset[] =
{
    {.move = MOVE_MIKROSKOK, .level = 1},
    {.move = MOVE_IMPULS_WARSTWOWY, .level = 6},
    {.move = LEVEL_UP_MOVE_END, .level = 0},
};
static const struct LevelUpMove sWahlikLevelUpLearnset[] =
{
    {.move = MOVE_FALA_WAHADLA, .level = 1},
    {.move = MOVE_SLIZG_BOCZNY, .level = 5},
    {.move = LEVEL_UP_MOVE_END, .level = 0},
};
static const struct LevelUpMove sNucikLevelUpLearnset[] =
{
    {.move = MOVE_NUTA_REZONANSU, .level = 1},
    {.move = MOVE_FALA_WAHADLA, .level = 6},
    {.move = LEVEL_UP_MOVE_END, .level = 0},
};
static const struct LevelUpMove sDudnikLevelUpLearnset[] =
{
    {.move = MOVE_DWUPUNKT, .level = 1},
    {.move = MOVE_IMPULS_WARSTWOWY, .level = 5},
    {.move = LEVEL_UP_MOVE_END, .level = 0},
};

'''


def species_record(name: str, proper: str, stats: tuple[int, int, int, int, int, int], types: str, learnset: str, category: str, description: str, catch: int) -> str:
    hp, atk, defense, speed, spa, spd = stats
    return f'''    [SPECIES_{name}] =
    {{
        .baseHP = {hp},
        .baseAttack = {atk},
        .baseDefense = {defense},
        .baseSpeed = {speed},
        .baseSpAttack = {spa},
        .baseSpDefense = {spd},
        .types = {types},
        .catchRate = {catch},
        .expYield = 62,
        .evYield_Speed = 1,
        .genderRatio = PERCENT_FEMALE(50),
        .eggCycles = 20,
        .friendship = STANDARD_FRIENDSHIP,
        .growthRate = GROWTH_MEDIUM_SLOW,
        .eggGroups = MON_EGG_GROUPS(EGG_GROUP_FIELD, EGG_GROUP_AMORPHOUS),
        .abilities = {{ ABILITY_NONE, ABILITY_NONE, ABILITY_NONE }},
        .bodyColor = BODY_COLOR_BLUE,
        .speciesName = _("{proper}"),
        .categoryName = _("{category}"),
        .height = 4,
        .weight = 60,
        .description = COMPOUND_STRING("{description}"),
        .pokemonScale = 356,
        .pokemonOffset = 17,
        .trainerScale = 256,
        .trainerOffset = 0,
        .frontPic = gMonFrontPic_{proper},
        .frontPicSize = MON_COORDS_SIZE(48, 48),
        .frontPicYOffset = 8,
        .frontAnimFrames = sAnims_TwoFramePlaceHolder,
        .frontAnimId = ANIM_V_SQUISH_AND_BOUNCE,
        .backPic = gMonBackPic_{proper},
        .backPicSize = MON_COORDS_SIZE(48, 48),
        .backPicYOffset = 8,
        .backAnimId = BACK_ANIM_CONVEX_DOUBLE_ARC,
        .palette = gMonPalette_{proper},
        .shinyPalette = gMonShinyPalette_{proper},
        .iconSprite = gMonIcon_{proper},
        .iconPalIndex = 0,
        .pokemonJumpType = PKMN_JUMP_TYPE_NORMAL,
        .levelUpLearnset = {learnset},
    }},

'''


def install_species_data(root: Path) -> None:
    path = root / "src/data/pokemon/species_info.h"
    text = path.read_text(encoding="utf-8")
    if "sBocznikLevelUpLearnset" not in text:
        marker = "const struct SpeciesInfo gSpeciesInfo[] =\n{"
        if text.count(marker) != 1:
            raise SystemExit("species info: gSpeciesInfo anchor changed")
        text = text.replace(marker, learnsets_block() + marker, 1)

    if "[SPECIES_BOCZNIK]" not in text:
        marker = "    [SPECIES_EGG] ="
        records = "".join([
            species_record("BOCZNIK", "Bocznik", (48,50,46,44,42,48), "MON_TYPES(TYPE_WATER, TYPE_ICE)", "sBocznikLevelUpLearnset", "Slizg", "Boczny ruch pozwala mu plynnie\\nomijac opor warstw.", 205),
            species_record("MILIMIK", "Milimik", (38,42,45,58,55,50), "MON_TYPES(TYPE_BUG, TYPE_PSYCHIC)", "sMilimikLevelUpLearnset", "Mikroruch", "Wyczuwalny ledwie ruch potrafi\\nzmienic jego kierunek.", 215),
            species_record("WAHLIK", "Wahlik", (52,43,44,62,58,48), "MON_TYPES(TYPE_WATER, TYPE_PSYCHIC)", "sWahlikLevelUpLearnset", "Oscylacja", "Porusza sie rytmem przypominajacym\\nspokojne wahadlo.", 190),
            species_record("NUCIK", "Nucik", (44,38,42,52,64,55), "MON_TYPES(TYPE_PSYCHIC, TYPE_FLYING)", "sNucikLevelUpLearnset", "Ton", "Jego swiatlo pulsuje zgodnie z\\nrytmem cichej melodii.", 185),
            species_record("DUDNIK", "Dudnik", (46,40,42,55,62,52), "MON_TYPES(TYPE_ELECTRIC, TYPE_FAIRY)", "sDudnikLevelUpLearnset", "Dwa Punkty", "Para rdzeni odpowiada sobie\\nimpulsem z dwoch stron.", 180),
        ])
        if text.count(marker) != 1:
            raise SystemExit("species info: egg anchor changed")
        text = text.replace(marker, records + marker, 1)
    path.write_text(text, encoding="utf-8")


def install_moves(root: Path) -> None:
    path = root / "src/data/moves_info.h"
    text = path.read_text(encoding="utf-8")
    if "[MOVE_SLIZG_BOCZNY]" in text:
        return
    marker = "    [MOVE_POUND] ="
    records = '''    [MOVE_SLIZG_BOCZNY] =
    {
        .name = COMPOUND_STRING("Slizg Boczny"),
        .description = COMPOUND_STRING("Szybki boczny slizg uderza\\ncel z pierwszenstwem."),
        .effect = EFFECT_HIT, .power = 40, .type = TYPE_WATER, .accuracy = 100, .pp = 25,
        .target = TARGET_SELECTED, .priority = 1, .category = DAMAGE_CATEGORY_PHYSICAL,
        .battleAnimScript = gBattleAnimMove_AquaJet,
    },
    [MOVE_MIKROSKOK] =
    {
        .name = COMPOUND_STRING("Mikroskok"),
        .description = COMPOUND_STRING("Nagly drobny skok trafia\\nzanim cel zareaguje."),
        .effect = EFFECT_HIT, .power = 40, .type = TYPE_BUG, .accuracy = 100, .pp = 30,
        .target = TARGET_SELECTED, .priority = 1, .category = DAMAGE_CATEGORY_PHYSICAL,
        .battleAnimScript = gBattleAnimMove_QuickAttack,
    },
    [MOVE_FALA_WAHADLA] =
    {
        .name = COMPOUND_STRING("Fala Wahadla"),
        .description = COMPOUND_STRING("Rytmiczna fala narasta i\\nuderza w wybrany cel."),
        .effect = EFFECT_HIT, .power = 50, .type = TYPE_PSYCHIC, .accuracy = 95, .pp = 20,
        .target = TARGET_SELECTED, .priority = 0, .category = DAMAGE_CATEGORY_SPECIAL,
        .battleAnimScript = gBattleAnimMove_Psywave,
    },
    [MOVE_NUTA_REZONANSU] =
    {
        .name = COMPOUND_STRING("Nuta Rezonansu"),
        .description = COMPOUND_STRING("Krotki ton wzbudza rezonans\\nw celu."),
        .effect = EFFECT_HIT, .power = 45, .type = TYPE_PSYCHIC, .accuracy = 100, .pp = 25,
        .target = TARGET_SELECTED, .priority = 0, .category = DAMAGE_CATEGORY_SPECIAL,
        .battleAnimScript = gBattleAnimMove_Supersonic,
    },
    [MOVE_DWUPUNKT] =
    {
        .name = COMPOUND_STRING("Dwupunkt"),
        .description = COMPOUND_STRING("Dwa zsynchronizowane impulsy\\nzbiegaja sie na celu."),
        .effect = EFFECT_HIT, .power = 50, .type = TYPE_ELECTRIC, .accuracy = 95, .pp = 20,
        .target = TARGET_SELECTED, .priority = 0, .category = DAMAGE_CATEGORY_SPECIAL,
        .battleAnimScript = gBattleAnimMove_ShockWave,
    },

'''
    if text.count(marker) != 1:
        raise SystemExit("moves info: MOVE_POUND anchor changed")
    path.write_text(text.replace(marker, records + marker, 1), encoding="utf-8")


def mon(species: str, lo: int, hi: int) -> dict:
    return {"min_level": lo, "max_level": hi, "species": species}


def install_encounters(root: Path) -> None:
    path = root / "src/data/wild_encounters.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    group = next((g for g in data["wild_encounter_groups"] if g.get("label") == "gWildMonHeaders"), None)
    if group is None:
        raise SystemExit("wild encounters: gWildMonHeaders missing")
    encounters = group["encounters"]

    center = next((e for e in encounters if e.get("map") == "MAP_ROUTE101"), None)
    if center is None:
        raise SystemExit("wild encounters: MAP_ROUTE101 missing")
    center["land_mons"] = {
        "encounter_rate": 22,
        "mons": [
            mon("SPECIES_BOCZNIK",3,4), mon("SPECIES_MILIMIK",3,4),
            mon("SPECIES_LUZIK",3,4), mon("SPECIES_BOCZNIK",4,5),
            mon("SPECIES_MILIMIK",4,5), mon("SPECIES_WAHLIK",4,5),
            mon("SPECIES_NUCIK",4,5), mon("SPECIES_DUDNIK",4,5),
            mon("SPECIES_WAHLIK",5,5), mon("SPECIES_NUCIK",5,5),
            mon("SPECIES_DUDNIK",5,5), mon("SPECIES_LUZIK",5,5),
        ],
    }

    grove = next((e for e in encounters if e.get("map") == "MAP_OLDALE_TOWN"), None)
    if grove is None:
        grove = {"map": "MAP_OLDALE_TOWN", "base_label": "gVelaResonanceGrove"}
        encounters.insert(encounters.index(center) + 1, grove)
    grove["land_mons"] = {
        "encounter_rate": 28,
        "mons": [
            mon("SPECIES_MILIMIK",4,5), mon("SPECIES_NUCIK",4,5),
            mon("SPECIES_DUDNIK",4,5), mon("SPECIES_WAHLIK",4,5),
            mon("SPECIES_MILIMIK",5,6), mon("SPECIES_NUCIK",5,6),
            mon("SPECIES_DUDNIK",5,6), mon("SPECIES_LUZIK",5,6),
            mon("SPECIES_WAHLIK",6,6), mon("SPECIES_BOCZNIK",5,6),
            mon("SPECIES_NUCIK",6,6), mon("SPECIES_DUDNIK",6,6),
        ],
    }

    allowed = {"SPECIES_LUZIK", "SPECIES_BOCZNIK", "SPECIES_MILIMIK", "SPECIES_WAHLIK", "SPECIES_NUCIK", "SPECIES_DUDNIK"}
    for entry in (center, grove):
        mons = entry["land_mons"]["mons"]
        if len(mons) != 12:
            raise SystemExit(f"wild encounters: {entry['map']} must have 12 land slots")
        found = {m["species"] for m in mons}
        if not found <= allowed or len(found) < 5:
            raise SystemExit(f"wild encounters: invalid Vela roster in {entry['map']}: {sorted(found)}")

    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main() -> None:
    parser=argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args=parser.parse_args()
    root=args.upstream_root.resolve()

    install_constants(root)
    install_graphics(root)
    install_species_data(root)
    install_moves(root)
    install_encounters(root)

    # Final identity assertions: all six base forms and all six custom moves are now source-addressable.
    species_text=(root/"include/constants/species.h").read_text(encoding="utf-8")
    moves_text=(root/"include/constants/moves.h").read_text(encoding="utf-8")
    for name in ["LUZIK"] + SPECIES:
        if f"SPECIES_{name}" not in species_text:
            raise SystemExit(f"missing Vela species ID: {name}")
    for name in ["IMPULS_WARSTWOWY"] + MOVES:
        if f"MOVE_{name}" not in moves_text:
            raise SystemExit(f"missing Vela move ID: {name}")

    print("PHASE4 VELA ROSTER PASS: six base Somaskans, six custom moves and two wild encounter pools installed")


if __name__ == "__main__":
    main()
