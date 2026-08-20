# SOMADEX creature art pipeline

This pipeline converts the supplied 50-family / 150-form source pack into production game assets without treating the 960×720 card images as final animation sprites.

## Stage A — normalized battle portraits

The source package contains separate JPG cards in `02_OSOBNE_FORMY_150_STWORKOW`. `tools/build_creature_portraits.py` crops the card chrome/header/footer, preserves the artwork aspect ratio, writes small WebP portraits, and creates one atlas + CSV manifest.

Example for the currently playable Vela families (1–10 plus starter family 15):

```bash
python -m pip install pillow
python tools/build_creature_portraits.py \
  --source-zip SOMADEX_STWORKI_001_050_TYLKO_GRAFIKI.zip \
  --out-dir build/creature-art/vela \
  --families 1-10,15
```

Target portrait cell: 224×144. The script is deterministic so regenerated atlases keep stable ordering.

## Stage B — approved transparent seed sprite

Portraits are reference material, not transparent battle sprites. For each family/stage, create one approved transparent idle seed that preserves:

- the original creature silhouette and identifying features;
- palette family;
- readable face/key anatomy;
- consistent scale;
- bottom-center anchor;
- no labels, frame, scenery or card background.

Recommended in-game seed frame: 128×128 transparent PNG/WebP, with the creature occupying roughly 70–85% of the frame height.

## Stage C — animation strips

Generate each animation as one complete strip from the approved seed rather than frame-by-frame. Minimum target set:

- idle: 4 frames;
- attack: 6 frames;
- hurt: 3 frames;
- faint: 5 frames;
- special/resonance: 6 frames.

All frames in a strip must use one scale and one bottom-center anchor. Frame 1 of idle should be locked back to the approved seed.

## Stage D — Godot import

Production runtime naming convention:

```text
assets/monsters/<family_id>/<stage>/<name>/idle.webp
assets/monsters/<family_id>/<stage>/<name>/attack.webp
assets/monsters/<family_id>/<stage>/<name>/hurt.webp
assets/monsters/<family_id>/<stage>/<name>/faint.webp
assets/monsters/<family_id>/<stage>/<name>/special.webp
```

The CSV catalog remains the identity/evolution source of truth. Art lookup must use canonical creature names and tolerate the historical lowercase `uczek` source filename by mapping it to runtime `Uczek`.

## Quality gates

Before an art family is marked shippable:

1. no card border, typography or scenery leaks into transparent sprites;
2. no silhouette drift between frames;
3. no scale drift inside a strip;
4. transparent background remains clean;
5. action is readable at actual mobile battle size;
6. frame 1 matches the approved seed;
7. every runtime evolution form has a valid art fallback before it can appear to the player.

The normalized portrait atlas is intentionally an intermediate asset. It can be used for encyclopedia/detail UI immediately, while battle animation remains on the transparent-sprite pipeline.
