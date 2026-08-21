#!/usr/bin/env bash
set -euo pipefail

# Reproducible visual-runtime dependency.
# Ninja Adventure Asset Pack by pixel-boy, CC0-1.0.
PIN="6ac78232d5aedcc85ce5f27d060ea92366f7c24a"
BASE="https://raw.githubusercontent.com/pixel-boy/NinjaAdventure/${PIN}"
OUT="assets/external/ninja_adventure"

mkdir -p "${OUT}/map" "${OUT}/character" "${OUT}/ui"

fetch() {
  local remote="$1"
  local local_path="$2"
  mkdir -p "$(dirname "$local_path")"
  curl --fail --location --silent --show-error --retry 4 --retry-delay 2 \
    "${BASE}/${remote}" -o "$local_path"
  test -s "$local_path"
}

# World tiles: actual hand-authored pixel art, not SOMADEX procedural placeholders.
fetch "content/map/tileset_floor.png" "${OUT}/map/tileset_floor.png"
fetch "content/map/tileset_village_abandoned.png" "${OUT}/map/tileset_village.png"
fetch "content/map/tileset_interior_floor.png" "${OUT}/map/tileset_interior_floor.png"
fetch "content/map/tileset_wall_simple.png" "${OUT}/map/tileset_wall.png"
fetch "content/map/tileset_animated.png" "${OUT}/map/tileset_animated.png"

# Character sheet used only as a CC0 base for the rebuilt trainer/NPC runtime.
fetch "content/character/ninja_blue/sprite.png" "${OUT}/character/player_base.png"

# Pixel UI pieces and font. These replace flat code-drawn placeholder panels.
fetch "theme/nine_path_10.png" "${OUT}/ui/panel_10.png"
fetch "theme/nine_path_11.png" "${OUT}/ui/panel_11.png"
fetch "theme/nine_path_12.png" "${OUT}/ui/panel_12.png"
fetch "theme/font_normal.ttf" "${OUT}/ui/font_normal.ttf"

cat > "${OUT}/SOURCE.txt" <<EOF
Ninja Adventure Asset Pack by pixel-boy
License: CC0-1.0
Pinned source commit: ${PIN}
Source: https://github.com/pixel-boy/NinjaAdventure
Pack: https://pixel-boy.itch.io/ninja-adventure-asset-pack
EOF

echo "Fetched pinned CC0 pixel runtime assets (${PIN})"
find "${OUT}" -type f -maxdepth 3 -print | sort
