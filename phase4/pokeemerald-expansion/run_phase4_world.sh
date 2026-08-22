#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 /path/to/SOMADEX /path/to/pokeemerald-expansion" >&2
  exit 2
fi

SOMADEX_ROOT=$(cd "$1" && pwd)
UPSTREAM_ROOT=$(cd "$2" && pwd)
PINNED=bb6f399bce71db7e82a4bfa40e72b29498ef1de6

actual=$(git -C "$UPSTREAM_ROOT" rev-parse HEAD)
if [[ "$actual" != "$PINNED" ]]; then
  echo "foundation drift: expected $PINNED, got $actual" >&2
  exit 1
fi

python3 "$SOMADEX_ROOT/phase3/pokeemerald-expansion/validate_registry.py" \
  "$SOMADEX_ROOT/phase3/pokeemerald-expansion/registry.json"

cd "$UPSTREAM_ROOT"
git reset --hard "$PINNED"
git clean -fdx

# Recreate the accepted Phase 3 SOMADEX slice first.
git apply --binary "$SOMADEX_ROOT/poc/pokeemerald-expansion/upstream.patch"
python3 "$SOMADEX_ROOT/phase3/pokeemerald-expansion/apply_phase3.py" \
  --upstream-root "$UPSTREAM_ROOT"

# Phase 0 patch uses a battle-position constant without this include in the locked TU.
if ! grep -Fxq '#include "constants/battle.h"' src/battle_main.c; then
  sed -i '/#include "constants\/abilities.h"/a #include "constants/battle.h"' src/battle_main.c
fi

python3 "$SOMADEX_ROOT/phase3/pokeemerald-expansion/generate_phase3_assets.py" \
  --somadex-root "$SOMADEX_ROOT" \
  --upstream-root "$UPSTREAM_ROOT"

# First reachable battle surface: keep the proven controller, replace player-facing
# Pokémon terminology/action copy with the SOMADEX language used in Vela.
python3 "$SOMADEX_ROOT/phase4/pokeemerald-expansion/apply_vela_battle_ui.py" \
  --upstream-root "$UPSTREAM_ROOT"

# Phase 4 visual core: replace the reachable Vela terrain vocabulary before
# composing the maps that reference those owned metatile IDs.
python3 "$SOMADEX_ROOT/phase4/pokeemerald-expansion/generate_vela_tileset.py" \
  --upstream-root "$UPSTREAM_ROOT"

# Phase 4 connected world block: three Vela areas, no reachable legacy story hooks.
python3 "$SOMADEX_ROOT/phase4/pokeemerald-expansion/apply_vela_world.py" \
  --upstream-root "$UPSTREAM_ROOT"
python3 "$SOMADEX_ROOT/phase4/pokeemerald-expansion/generate_vela_world_maps.py" \
  --upstream-root "$UPSTREAM_ROOT"

sha256sum \
  data/tilesets/primary/general/tiles.png \
  data/tilesets/primary/general/palettes/00.pal \
  data/tilesets/primary/general/metatiles.bin \
  data/tilesets/primary/general/metatile_attributes.bin \
  | tee "$SOMADEX_ROOT/phase4-vela-tileset.sha256"

# Lightweight source assertions for the two production surfaces in this block.
grep -Fq 'Atak{CLEAR_TO 56}Plecak' src/battle_message.c
grep -Fq 'Stworki{CLEAR_TO 56}Ucieczka' src/battle_message.c
grep -Fq '_("STWORKI")' src/strings.c

# Keep the same production identity guard while expanding the world.
if git diff --unified=0 HEAD | grep '^+' | grep -E 'SPECIES_TREECKO|MOVE_POUND|ITEM_POKE_BALL' | grep -vE '^\+\+\+'; then
  echo "forbidden PoC identity remap found in Phase 4 additions" >&2
  exit 1
fi

make -j2 2>&1 | tee "$SOMADEX_ROOT/phase4-world-build.log"

ROM="$UPSTREAM_ROOT/pokeemerald.gba"
ELF="$UPSTREAM_ROOT/pokeemerald.elf"
[[ -f "$ROM" && -f "$ELF" ]]

sha256sum "$ROM" | tee "$SOMADEX_ROOT/phase4-world-rom.sha256"
stat -c '%s' "$ROM" | tee "$SOMADEX_ROOT/phase4-world-rom.bytes"
arm-none-eabi-size "$ELF" | tee "$SOMADEX_ROOT/phase4-world-memory.txt"

echo "PHASE4 WORLD BUILD PASS: connected Vela starter world + owned visual core + SOMADEX battle UI built locally; ROM is intentionally not published"
