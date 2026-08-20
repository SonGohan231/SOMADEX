# SOMADEX — Alpha 1 VELA / Asset Pipeline Stage 2

This layer upgrades visuals without changing the frozen Foundation gameplay contract.

## Source of truth

- Creature source art: Google Drive package `SOMADEX_STWORKI_001_050_TYLKO_GRAFIKI.zip`.
- `assets/creatures_manifest.csv` indexes all 150 forms (50 evolution lines × 3 forms).
- Runtime vertical slice currently uses production-normalized art for Luzik, Bocznik, Nucik, Wahlik, Milimik and Dudnik.

## Runtime integration

`VisualDirector` is a visual-only autoload. It reads the state of the existing main scene and overlays:

- real starter/wild creature artwork on title, starter selection, party/SOMADEX and battle screens,
- a coherent 24 px VELA tileset,
- a 4-direction / 2-frame trainer walk sheet,
- an animated Mira NPC sheet.

The input, save/load, encounter, menu and battle logic remain owned by the existing Foundation scene.

## Expansion contract

The 150-entry manifest uses `atlas_col`/`atlas_row` so the Drive pack can be batch-normalized later into one atlas without changing IDs. New forms must preserve `dex_index`, `line`, `form`, and canonical `name`.

## Quality gates

1. Godot headless import succeeds.
2. Foundation tests succeed.
3. Android debug export succeeds.
4. Title/starter/world/menu/battle state changes remain functional.
5. Missing art never blocks gameplay; the visual layer fails soft and leaves Foundation rendering visible.
