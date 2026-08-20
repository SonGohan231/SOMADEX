# SOMADEX Alpha 1 — engine base

## Decision

SOMADEX keeps Godot and migrates its gameplay foundation toward the architecture of `master172/PokemonGodWhite`, pinned for reference at commit `fba69f1710f3d41e6e367539e8e9adb2ab4e551d`.

Why this base:

- Godot 4.5 project, close to our current Godot stack.
- MIT-licensed code.
- Existing battle scene and BattleManager.
- Existing inventory and evolution managers.
- Dialogue system integration.
- Existing Android/mobile TouchInput layer.
- Existing trading systems.
- The upstream project explicitly describes its foundation as ready while content remains to be replaced.
- Upstream contains a dedicated commit making touch input responsive to different screen sizes.

## Legal / asset rule

We use the upstream code architecture and only code that is covered by its MIT license. We do not import or redistribute Pokemon/Nintendo/Game Freak/Creatures assets, names, maps, audio, story content, species, trademarks or other protected content.

All visible SOMADEX content remains original: creatures, names, UI styling, maps, story, mechanics, trainer progression, Resonance system and art.

## Migration order

1. Mobile input and menu controls.
2. Scene manager and screen transitions.
3. BattleManager/state machine.
4. Monster data model and party manager.
5. Inventory/items.
6. Capture flow.
7. Evolution and progression.
8. Dialogue/NPC event layer.
9. Overworld encounters and zones.
10. Save migration and Android QA.

## Current status

The first migration step is active on branch `alpha1-engine-migration`: title-screen touch hitboxes were replaced with real Godot `Button` controls instead of manually comparing raw touch coordinates. This removes the device-resolution mismatch that could make the visible menu completely unclickable on Android.

## SOMADEX-specific extensions retained

- 50 original creatures initially, scalable data-driven roster.
- Trainer level and five talent paths.
- Equipment slots and items.
- Resonance actions for trainer + creature combat.
- Status interactions and combo system.
- Original region Vela and later regions.
- Android-first portrait/touch UX.
