#!/usr/bin/env python3
"""Give MOVE_IMPULS_WARSTWOWY its own battle-animation script.

We deliberately reuse stable low-level animation primitives from the engine while
owning the sequence/timing and move symbol. This is much safer than implementing
new sprite callbacks and removes the reachable ThunderShock identity dependency.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path

LABEL = "gBattleAnimMove_ImpulsWarstwowy"

SCRIPT = r'''gBattleAnimMove_ImpulsWarstwowy::
	# SOMADEX: charge the resonance field around the attacker.
	createvisualtask AnimTask_BlendBattleAnimPal, 10, F_PAL_BG, 0, 0, 3, RGB_BLACK
	createvisualtask AnimTask_BlendBattleAnimPal, 10, F_PAL_ATTACKER, 0, 0, 6, RGB(6, 25, 27)
	waitforvisualfinish
	delay 4

	# Three asymmetric impulses converge on the target instead of a single
	# inherited ThunderShock strike.
	createvisualtask AnimTask_ElectricBolt, 5, -20, -44, 0
	playsewithpan SE_M_THUNDER_WAVE, SOUND_PAN_TARGET
	delay 5
	createvisualtask AnimTask_ElectricBolt, 5, 20, -44, 1
	delay 5
	createvisualtask AnimTask_ElectricBolt, 5, 0, -52, 0
	delay 6

	# Short target resonance pulse, then release both palettes cleanly.
	createvisualtask AnimTask_BlendBattleAnimPal, 10, F_PAL_TARGET, 0, 0, 8, RGB(4, 29, 29)
	waitforvisualfinish
	createvisualtask AnimTask_BlendBattleAnimPal, 10, F_PAL_TARGET, 0, 8, 0, RGB(4, 29, 29)
	createvisualtask AnimTask_BlendBattleAnimPal, 10, F_PAL_ATTACKER, 0, 6, 0, RGB(6, 25, 27)
	createvisualtask AnimTask_BlendBattleAnimPal, 10, F_PAL_BG, 0, 3, 0, RGB_BLACK
	waitforvisualfinish
	delay 4
	end

'''


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text(encoding="utf-8")
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: {label}: expected one anchor, found {count}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    root = args.upstream_root.resolve()

    header = root / "include/battle_anim_scripts.h"
    scripts = root / "data/battle_anim_scripts.s"
    moves = root / "src/data/moves_info.h"
    for path in (header, scripts, moves):
        if not path.is_file():
            raise SystemExit(f"locked animation source missing: {path}")

    if LABEL not in header.read_text(encoding="utf-8"):
        replace_once(
            header,
            "extern const u8 gBattleAnimMove_ThunderShock[];",
            "extern const u8 gBattleAnimMove_ImpulsWarstwowy[];\nextern const u8 gBattleAnimMove_ThunderShock[];",
            "animation extern",
        )

    script_text = scripts.read_text(encoding="utf-8")
    if f"{LABEL}::" not in script_text:
        replace_once(
            scripts,
            "gBattleAnimMove_ThunderShock::\n",
            SCRIPT + "gBattleAnimMove_ThunderShock::\n",
            "animation script insertion",
        )

    move_text = moves.read_text(encoding="utf-8")
    pattern = re.compile(
        r"(?P<head>\[MOVE_IMPULS_WARSTWOWY\]\s*=\s*\{.*?\.battleAnimScript\s*=\s*)"
        r"gBattleAnimMove_ThunderShock(?P<tail>\s*,.*?\n\s*\},)",
        re.DOTALL,
    )
    if "gBattleAnimMove_ImpulsWarstwowy" not in move_text:
        move_text, count = pattern.subn(
            lambda m: m.group("head") + LABEL + m.group("tail"),
            move_text,
            count=1,
        )
        if count != 1:
            raise SystemExit("MOVE_IMPULS_WARSTWOWY: expected one ThunderShock animation dependency")
        moves.write_text(move_text, encoding="utf-8")

    # Strong source assertions: the custom move must point to its own label and
    # the old ThunderShock pointer must no longer occur inside this move block.
    final_moves = moves.read_text(encoding="utf-8")
    start = final_moves.find("[MOVE_IMPULS_WARSTWOWY]")
    end = final_moves.find("[MOVE_POUND]", start)
    if start < 0 or end < 0:
        raise SystemExit("cannot isolate Impuls Warstwowy move block")
    block = final_moves[start:end]
    if f".battleAnimScript = {LABEL}," not in block:
        raise SystemExit("Impuls Warstwowy does not use its custom animation")
    if "gBattleAnimMove_ThunderShock" in block:
        raise SystemExit("ThunderShock dependency survived in Impuls Warstwowy block")
    if f"{LABEL}::" not in scripts.read_text(encoding="utf-8"):
        raise SystemExit("custom Impuls Warstwowy script label missing")

    print("PHASE4 IMPULS PASS: MOVE_IMPULS_WARSTWOWY uses its own resonance animation sequence")


if __name__ == "__main__":
    main()
