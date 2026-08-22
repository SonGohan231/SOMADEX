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
git apply --binary "$SOMADEX_ROOT/poc/pokeemerald-expansion/upstream.patch"
python3 "$SOMADEX_ROOT/poc/pokeemerald-expansion/generate_map.py"

python3 "$SOMADEX_ROOT/phase3/pokeemerald-expansion/apply_phase3.py" \
  --upstream-root "$UPSTREAM_ROOT"
python3 "$SOMADEX_ROOT/phase3/pokeemerald-expansion/generate_phase3_assets.py" \
  --somadex-root "$SOMADEX_ROOT" \
  --upstream-root "$UPSTREAM_ROOT"

# Source-level production guardrails before compiling.
if git diff --unified=0 HEAD | grep '^+' | grep -E 'SPECIES_TREECKO|MOVE_POUND|ITEM_POKE_BALL' | grep -vE '^\+\+\+'; then
  echo "forbidden PoC identity remap found in Phase 3 additions" >&2
  exit 1
fi

make -j2 2>&1 | tee "$SOMADEX_ROOT/phase3-build.log"

ROM="$UPSTREAM_ROOT/pokeemerald.gba"
ELF="$UPSTREAM_ROOT/pokeemerald.elf"
[[ -f "$ROM" && -f "$ELF" ]]

sha256sum "$ROM" | tee "$SOMADEX_ROOT/phase3-rom.sha256"
stat -c '%s' "$ROM" | tee "$SOMADEX_ROOT/phase3-rom.bytes"
arm-none-eabi-size "$ELF" | tee "$SOMADEX_ROOT/phase3-memory.txt"
arm-none-eabi-nm -n "$ELF" | grep -E ' gSaveBlock1Ptr$| gPartiesCount$' | tee "$SOMADEX_ROOT/phase3-symbols.txt"

# Never copy/upload the ROM from this script. It is a local verification output only.
echo "PHASE3 BUILD PASS: source-only pipeline built the local test ROM; ROM is intentionally not published"
