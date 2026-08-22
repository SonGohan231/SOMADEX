#!/usr/bin/env python3
import argparse
import re
import subprocess
from pathlib import Path

PINNED = "bb6f399bce71db7e82a4bfa40e72b29498ef1de6"
TOKENS = {
    "SPECIES_TREECKO": "SPECIES_LUZIK",
    "MOVE_POUND": "MOVE_IMPULS_WARSTWOWY",
    "ITEM_POKE_BALL": "ITEM_KULA_SPLOTU",
}


def git(root: Path, *args: str) -> str:
    return subprocess.check_output(["git", "-C", str(root), *args], text=True).strip()


def write(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8")


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected exactly one marker, found {count} in {path}")
    write(path, text.replace(old, new, 1))


def append_once(path: Path, marker: str, block: str) -> None:
    text = path.read_text(encoding="utf-8")
    if marker in text:
        return
    write(path, text.rstrip() + "\n\n" + block.rstrip() + "\n")


def migrate_added_diff_lines(root: Path) -> None:
    changed = git(root, "diff", "--name-only", "HEAD").splitlines()
    for rel in changed:
        path = root / rel
        if not path.is_file():
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        diff = git(root, "diff", "--unified=0", "HEAD", "--", rel)
        replacements = []
        for line in diff.splitlines():
            if not line.startswith("+") or line.startswith("+++"):
                continue
            added = line[1:]
            changed_line = added
            for old, new in TOKENS.items():
                changed_line = changed_line.replace(old, new)
            if changed_line != added:
                replacements.append((added, changed_line))
        for old_line, new_line in replacements:
            if old_line not in text:
                raise SystemExit(f"cannot migrate PoC-added runtime reference in {rel}: {old_line}")
            text = text.replace(old_line, new_line, 1)
        write(path, text)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    root = args.upstream_root.resolve()

    if git(root, "rev-parse", "HEAD") != PINNED:
        raise SystemExit("foundation drift: Phase 3 must run on the locked upstream commit")

    # Undo the three deliberate PoC data-slot hijacks before adding real SOMADEX IDs.
    for rel in [
        "src/data/pokemon/species_info/gen_3_families.h",
        "src/data/moves_info.h",
        "src/data/items.h",
    ]:
        subprocess.run(["git", "-C", str(root), "checkout", "HEAD", "--", rel], check=True)

    # Convert only lines introduced by the PoC from temporary upstream IDs to canonical Phase 3 IDs.
    migrate_added_diff_lines(root)

    # Stable custom species ID.
    species_constants = root / "include/constants/species.h"
    replace_once(
        species_constants,
        "    SPECIES_CUSTOM_START = SPECIES_GLIMMORA_MEGA,\n    // Add any custom species between here and SPECIES_CUSTOM_END\n    SPECIES_CUSTOM_END,",
        "    SPECIES_CUSTOM_START = SPECIES_GLIMMORA_MEGA,\n    // SOMADEX production IDs. Do not reuse upstream species slots.\n    SPECIES_LUZIK,\n    SPECIES_CUSTOM_END,",
        "species constants",
    )

    # Stable custom move ID. MOVES_COUNT must advance before Z/Max move ranges begin.
    move_constants = root / "include/constants/moves.h"
    replace_once(
        move_constants,
        "    // Add any custom moves here, not further down!\n\n    MOVES_COUNT = MOVES_COUNT_GEN9,",
        "    // SOMADEX production moves.\n    MOVE_IMPULS_WARSTWOWY = MOVES_COUNT_GEN9,\n\n    MOVES_COUNT,",
        "move constants",
    )

    # Stable custom item ID.
    item_constants = root / "include/constants/items.h"
    replace_once(
        item_constants,
        "    ITEM_GLIMMORANITE = 873,\n\n    ITEMS_COUNT,",
        "    ITEM_GLIMMORANITE = 873,\n\n    // SOMADEX production items.\n    ITEM_KULA_SPLOTU = 874,\n\n    ITEMS_COUNT,",
        "item constants",
    )

    # Graphics symbols for owned Luzik art.
    pokemon_graphics = root / "src/data/graphics/pokemon.h"
    append_once(
        pokemon_graphics,
        "gMonFrontPic_Luzik",
        '''// SOMADEX Phase 3 owned assets.
const u32 gMonFrontPic_Luzik[] = INCGFX_U32("graphics/pokemon/luzik/anim_front.png", ".4bpp.smol");
const u16 gMonPalette_Luzik[] = INCGFX_U16("graphics/pokemon/luzik/normal.pal", ".gbapal");
const u32 gMonBackPic_Luzik[] = INCGFX_U32("graphics/pokemon/luzik/back.png", ".4bpp.smol");
const u16 gMonShinyPalette_Luzik[] = INCGFX_U16("graphics/pokemon/luzik/shiny.pal", ".gbapal");
const u8 gMonIcon_Luzik[] = INCGFX_U8("graphics/pokemon/luzik/icon.png", ".4bpp");''',
    )

    # Minimal learnset and production species record. The rear sprite is separately authored by the Phase 3 asset generator.
    species_info = root / "src/data/pokemon/species_info.h"
    replace_once(
        species_info,
        "const struct SpeciesInfo gSpeciesInfo[] =\n{",
        '''static const struct LevelUpMove sLuzikLevelUpLearnset[] =
{
    {.move = MOVE_IMPULS_WARSTWOWY, .level = 1},
    {.move = LEVEL_UP_MOVE_END, .level = 0},
};

const struct SpeciesInfo gSpeciesInfo[] =
{''',
        "Luzik learnset anchor",
    )
    replace_once(
        species_info,
        "    [SPECIES_EGG] =",
        '''    [SPECIES_LUZIK] =
    {
        .baseHP = 44,
        .baseAttack = 42,
        .baseDefense = 45,
        .baseSpeed = 56,
        .baseSpAttack = 58,
        .baseSpDefense = 50,
        .types = MON_TYPES(TYPE_ELECTRIC),
        .catchRate = 190,
        .expYield = 62,
        .evYield_SpAttack = 1,
        .genderRatio = PERCENT_FEMALE(50),
        .eggCycles = 20,
        .friendship = STANDARD_FRIENDSHIP,
        .growthRate = GROWTH_MEDIUM_SLOW,
        .eggGroups = MON_EGG_GROUPS(EGG_GROUP_FIELD, EGG_GROUP_AMORPHOUS),
        .abilities = { ABILITY_STATIC, ABILITY_NONE, ABILITY_NONE },
        .bodyColor = BODY_COLOR_BLUE,
        .speciesName = _("Luzik"),
        .categoryName = _("Rezonans"),
        .height = 4,
        .weight = 65,
        .description = COMPOUND_STRING("Lekki Somaskan reaguje na\\nlokalny rezonans warstw."),
        .pokemonScale = 356,
        .pokemonOffset = 17,
        .trainerScale = 256,
        .trainerOffset = 0,
        .frontPic = gMonFrontPic_Luzik,
        .frontPicSize = MON_COORDS_SIZE(48, 48),
        .frontPicYOffset = 8,
        .frontAnimFrames = sAnims_TwoFramePlaceHolder,
        .frontAnimId = ANIM_V_SQUISH_AND_BOUNCE,
        .backPic = gMonBackPic_Luzik,
        .backPicSize = MON_COORDS_SIZE(48, 48),
        .backPicYOffset = 8,
        .backAnimId = BACK_ANIM_CONVEX_DOUBLE_ARC,
        .palette = gMonPalette_Luzik,
        .shinyPalette = gMonShinyPalette_Luzik,
        .iconSprite = gMonIcon_Luzik,
        .iconPalIndex = 0,
        .pokemonJumpType = PKMN_JUMP_TYPE_NORMAL,
        .levelUpLearnset = sLuzikLevelUpLearnset,
    },

    [SPECIES_EGG] =''',
        "Luzik species record",
    )

    # Production move record. Reuses an engine battle-effect animation only as a tracked Phase 3 technical dependency.
    moves_info = root / "src/data/moves_info.h"
    replace_once(
        moves_info,
        "    [MOVE_POUND] =",
        '''    [MOVE_IMPULS_WARSTWOWY] =
    {
        .name = COMPOUND_STRING("Impuls Warstwowy"),
        .description = COMPOUND_STRING("Krotki impuls rezonansu\\nuderza w wybrany cel."),
        .effect = EFFECT_HIT,
        .power = 45,
        .type = TYPE_ELECTRIC,
        .accuracy = 96,
        .pp = 20,
        .target = TARGET_SELECTED,
        .priority = 0,
        .category = DAMAGE_CATEGORY_SPECIAL,
        .battleAnimScript = gBattleAnimMove_ThunderShock,
    },

    [MOVE_POUND] =''',
        "Impuls Warstwowy move record",
    )

    # Original Kula Splotu item record. BALL_POKE remains only as the engine capture algorithm selector,
    # not as the item's identity; the thrown-ball presentation remains tracked for de-Pokemonization.
    item_graphics = root / "src/data/graphics/items.h"
    append_once(
        item_graphics,
        "gItemIcon_KulaSplotu",
        '''// SOMADEX Phase 3 owned capture-device icon.
const u32 gItemIcon_KulaSplotu[] = INCGFX_U32("graphics/items/icons/kula_splotu.png", ".4bpp.smol");
const u16 gItemIconPalette_KulaSplotu[] = INCGFX_U16("graphics/items/icon_palettes/kula_splotu.pal", ".gbapal");''',
    )
    items_info = root / "src/data/items.h"
    replace_once(
        items_info,
        "    [ITEM_POKE_BALL] =",
        '''    [ITEM_KULA_SPLOTU] =
    {
        .name = ITEM_NAME("Kula Splotu"),
        .price = 200,
        .description = COMPOUND_STRING("Urzadzenie do chwytania\\nSomaskanow w terenie."),
        .pocket = POCKET_POKE_BALLS,
        .type = ITEM_USE_BAG_MENU,
        .battleUsage = EFFECT_ITEM_THROW_BALL,
        .secondaryId = BALL_POKE,
        .iconPic = gItemIcon_KulaSplotu,
        .iconPalette = gItemIconPalette_KulaSplotu,
    },

    [ITEM_POKE_BALL] =''',
        "Kula Splotu item record",
    )

    # Avoid carrying an upstream default trainer name into Phase 3 saves.
    new_game = root / "src/new_game.c"
    if "SOMADEX_PHASE3_PLAYER_NAME" not in new_game.read_text(encoding="utf-8"):
        replace_once(
            new_game,
            "    InitPlayerTrainerId();",
            '''    InitPlayerTrainerId();
    // SOMADEX_PHASE3_PLAYER_NAME: deterministic test identity; naming UI comes later.
    StringCopy(gSaveBlock2Ptr->playerName, _("SOMA"));''',
            "player name",
        )

    # Guardrail: no PoC remap may survive in an added line after transformation.
    diff = git(root, "diff", "--unified=0", "HEAD")
    for forbidden in TOKENS:
        for line in diff.splitlines():
            if line.startswith("+") and not line.startswith("+++") and forbidden in line:
                # Definitions of the original upstream records are allowed; added production code is not.
                if forbidden in ("SPECIES_TREECKO", "MOVE_POUND", "ITEM_POKE_BALL"):
                    raise SystemExit(f"production diff still adds forbidden PoC runtime ID: {forbidden}: {line}")

    print("PHASE3 APPLY PASS: canonical Luzik/move/item IDs installed on locked foundation")


if __name__ == "__main__":
    main()
