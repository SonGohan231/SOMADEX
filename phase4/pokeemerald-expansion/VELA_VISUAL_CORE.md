# Vela visual core — production contract

This Phase 4 block owns the visual language reachable in the first SOMADEX slice.
The goal is not to redraw the entire upstream engine at once. We replace the assets
the player actually sees first while retaining proven GBA geometry, memory layouts,
collision semantics and battle controllers.

## Overworld core

The Vela world generator supplies a deterministic 128×256 indexed source sheet,
a 16-colour palette and selected primary metatiles used by the three starter maps.
The currently owned vocabulary covers:

- grass ground and dirt paths;
- tall encounter grass;
- stone plaza;
- flowers, sand and water;
- 2×2 trees;
- fences and hedges;
- resonance crystals and signs;
- building wall / roof / door facade modules;
- lamps.

The three starter maps are Vela South, Vela Center and Resonance Grove. Technical
map slots inherited from the locked engine remain an implementation detail.

## First battle surface

The same visual rule now applies to the first reachable wild battle:

- player and opponent singles healthboxes keep their proven dimensions and HP
  mechanics but receive a SOMADEX teal/slate/cyan palette treatment;
- the battle textbox and left/right move-information windows use the same visual
  family instead of the legacy cream/olive presentation;
- battle text and PP palette sources are remapped while preserving semantic danger,
  healthy, EXP and active-state colours for readability;
- visible action/capture language is SOMADEX-facing (`Atak`, `Plecak`, `Stworki`,
  `Ucieczka`, Kula Splotu and SOMADEX capture copy);
- Kula Splotu owns the reachable thrown/open capture-device art;
- `MOVE_IMPULS_WARSTWOWY` owns a dedicated `gBattleAnimMove_ImpulsWarstwowy`
  animation sequence. It reuses low-level battle-animation primitives for safety,
  but no longer points to the ThunderShock animation script.

## Constraints retained intentionally

- No battle controller rewrite.
- No HP/EXP calculation rewrite.
- No new sprite callback code for the first custom move.
- No global replacement of inaccessible upstream screens in this block.
- ASCII-safe Polish remains temporary until the dedicated charmap/font pass.
- Deferred CI/build failures remain cleanup work and do not block content production.

This keeps the fastest production path: own the visible SOMADEX identity while
reusing the mature engine underneath it.
