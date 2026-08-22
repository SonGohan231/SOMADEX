#!/usr/bin/env python3
"""Replace the first reachable battle UI/copy with SOMADEX-facing language.

This deliberately does NOT rewrite the proven battle controller. It changes the
small player-facing surface used by the Vela vertical slice, keeping engine logic
and action slots intact:

    top-left    -> Atak       (use move)
    top-right   -> Plecak     (use item)
    bottom-left -> Stworki    (switch creature)
    bottom-right-> Ucieczka   (run)

Polish text is kept ASCII-only for now because the final production charmap is a
separate visual/font pass. The command words themselves need no diacritics.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def replace_symbol_string(path: Path, symbol: str, replacement_literal: str) -> None:
    text = path.read_text(encoding="utf-8")
    pattern = rf'(?P<prefix>(?:static\s+)?const\s+u8\s+{re.escape(symbol)}(?:\[[^\]]*\])?\s*=\s*_\()(?P<body>"(?:[^"\\]|\\.)*")(?P<suffix>\);)'
    updated, count = re.subn(
        pattern,
        lambda m: m.group("prefix") + replacement_literal + m.group("suffix"),
        text,
        count=1,
        flags=re.MULTILINE | re.DOTALL,
    )
    if count != 1:
        raise SystemExit(f"{path}: expected exactly one string symbol {symbol}, found {count}")
    path.write_text(updated, encoding="utf-8")


def replace_exact(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: {label}: expected one exact anchor, found {count}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    root = args.upstream_root.resolve()

    battle = root / "src/battle_message.c"
    strings = root / "src/strings.c"
    for path in (battle, strings):
        if not path.is_file():
            raise SystemExit(f"locked battle UI source missing: {path}")

    # Main action box. Keep the engine's proven slot order so labels always match
    # the action executed by the existing controller.
    replace_symbol_string(
        battle,
        "gText_BattleMenu",
        '"Atak{CLEAR_TO 56}Plecak\\\nStworki{CLEAR_TO 56}Ucieczka"',
    )

    # First-wild-battle copy reachable from Vela. Short lines are intentional for
    # the original GBA text window dimensions.
    replace_symbol_string(battle, "gText_WhatWillPkmnDo", '"Co zrobi\\\n{B_BUFF1}?"')
    replace_symbol_string(battle, "sText_WildPkmnAppeared", '"Dziki {B_OPPONENT_MON1_NAME} pojawia sie!\\p"')
    replace_symbol_string(battle, "sText_WildPkmnAppearedPause", '"Dziki {B_OPPONENT_MON1_NAME} pojawia sie!{PAUSE 127}"')
    replace_symbol_string(battle, "sText_GotAwaySafely", '"{PLAY_SE SE_FLEE}Udalo sie uciec!\\p"')
    replace_symbol_string(battle, "sText_GoPkmn", '"Naprzod! {B_PLAYER_MON1_NAME}!"')

    # Reachable capture feedback. These are table entries rather than standalone
    # symbols, so replace only their unique string payloads and preserve IDs/audio.
    capture_copy = {
        'COMPOUND_STRING("Oh no! The Pokémon broke free!")': 'COMPOUND_STRING("Somaskan wyrwal sie!")',
        'COMPOUND_STRING("Aww! It appeared to be caught!")': 'COMPOUND_STRING("Prawie zostal schwytany!")',
        'COMPOUND_STRING("Aargh! Almost had it!")': 'COMPOUND_STRING("Jeszcze chwila!")',
        'COMPOUND_STRING("Gah! It was so close, too!")': 'COMPOUND_STRING("Tak blisko!")',
        'COMPOUND_STRING("Gotcha! {B_DEF_NAME} was caught!{WAIT_SE}{PLAY_BGM MUS_CAUGHT}\\p")': 'COMPOUND_STRING("Schwytano {B_DEF_NAME}!{WAIT_SE}{PLAY_BGM MUS_CAUGHT}\\p")',
        'COMPOUND_STRING("Would you like to give {B_DEF_NAME} a nickname?")': 'COMPOUND_STRING("Nadac {B_DEF_NAME} pseudonim?")',
        'COMPOUND_STRING("{B_DEF_NAME}\'s data has been added to the Pokédex!\\p")': 'COMPOUND_STRING("Dane {B_DEF_NAME} zapisano w SOMADEXIE!\\p")',
    }
    for idx, (old, new) in enumerate(capture_copy.items(), start=1):
        replace_exact(battle, old, new, f"capture copy {idx}")

    # Generic party label used by reachable party surfaces. We intentionally do
    # not mass-localise the inaccessible upstream story/encyclopedia here.
    replace_exact(
        strings,
        'const u8 gText_Pokemon[POKEMON_NAME_LENGTH + 1] = _("POKéMON");',
        'const u8 gText_Pokemon[POKEMON_NAME_LENGTH + 1] = _("STWORKI");',
        "generic creature label",
    )

    # Source-level assertions: our primary commands and first-capture language
    # must exist after the transformation.
    final_battle = battle.read_text(encoding="utf-8")
    final_strings = strings.read_text(encoding="utf-8")
    for token in (
        "Atak", "Plecak", "Stworki", "Ucieczka", "Co zrobi", "Dziki",
        "Somaskan wyrwal sie", "Schwytano", "SOMADEXIE",
    ):
        if token not in final_battle:
            raise SystemExit(f"missing SOMADEX battle UI token after patch: {token}")
    if '_("STWORKI")' not in final_strings:
        raise SystemExit("generic STWORKI label missing after patch")

    print("PHASE4 BATTLE UI PASS: action menu + first wild/capture language converted to SOMADEX")


if __name__ == "__main__":
    main()
