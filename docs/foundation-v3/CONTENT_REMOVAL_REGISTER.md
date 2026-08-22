# SOMADEX — UPSTREAM CONTENT REMOVAL REGISTER V1

Status: **ACTIVE FROM PHASE 2**  
Purpose: track all player-facing upstream content that must be removed, replaced, disabled or legally cleared before public release.

## Rule

The selected foundation is a technical base. Upstream Pokémon IP is not SOMADEX production content.

Any upstream-visible element encountered during implementation must be entered into this register or an equivalent tracked issue before it can be considered intentionally handled.

This register starts from the Micro-PoC evidence and known engine surfaces. It is deliberately conservative and is not yet a claim that every upstream asset/string has been exhaustively inventoried.

## Priority classes

- **P0 — release blocker:** cannot exist in a public SOMADEX build.
- **P1 — vertical-slice blocker:** must be removed from the tested Phase 3 player path.
- **P2 — later audit:** may remain outside the reachable Phase 3 path temporarily, but must be inventoried before content scale-up/public release.

## Register

| Area | Known/expected upstream content | Required action | Priority | Current state |
|---|---|---|---|---|
| Boot/title | Pokémon title/logo/branding and upstream title presentation | Replace with SOMADEX-owned title/branding/intro | P1/P0 | OPEN |
| Player identity | Upstream default player name and naming assumptions | Replace with SOMADEX naming flow/data | P1 | OPEN |
| Core UI text | English/upstream battle/menu/system messages | Replace/localize with SOMADEX-owned strings | P1 | OPEN |
| Battle commands | Pokémon-specific terminology where inherited | Map to SOMADEX terminology and verify all reachable labels | P1 | OPEN |
| Species | Pokémon names, species records, forms and descriptions | Remove from reachable SOMADEX content; use canonical Somaskan registry | P0 | OPEN |
| Species graphics | Front/back sprites, icons, palettes, footprints/auxiliary art | Replace with SOMADEX-owned assets where reachable | P0 | OPEN |
| Moves | Pokémon move names/data/text/animations where player-facing | Replace reachable content with SOMADEX moves; audit reused engine effects separately | P0/P1 | OPEN |
| Abilities/passives | Pokémon ability names/descriptions/data | Replace reachable content with SOMADEX passives or disable | P0 | OPEN |
| Items | Poké Balls, medicine, held items, key items and names/icons | Replace reachable inventory with SOMADEX-owned items/capture devices | P0/P1 | OPEN |
| Pokédex systems | Pokédex names, UI, descriptions, category labels | Replace with SOMADEX encyclopedia and original presentation | P0 | OPEN |
| Trainers | Upstream trainer classes/names/portraits/teams | Replace with SOMADEX trainers and art | P0/P1 | OPEN |
| NPCs | Upstream NPC names/dialogue/quest roles | Replace within reachable slice; later full-world audit | P0/P1 | OPEN |
| Maps | Hoenn/Pokémon map names/layouts/events/world fiction | Use original SOMADEX maps/events/world | P0 | OPEN |
| Tiles/environment art | Upstream tiles, decorative objects, environmental art | Replace or separately clear; do not assume technical availability equals release clearance | P0/P2 | OPEN |
| Battle backgrounds | Upstream battle scenes/background art | Replace in Phase 3 tested encounters | P1/P0 | OPEN |
| UI graphics | Frames, logos, icons, cursor art, fonts/tiles where upstream-specific | Replace/clear and document provenance | P0/P1 | OPEN |
| Intro/cutscenes | Upstream story intro, legendary/character sequences | Disable or replace before reachable player path expands | P0/P2 | OPEN |
| Story/dialogue | Pokémon/Hoenn plot, lore and text | Never port as SOMADEX content | P0 | POLICY-LOCKED |
| Music | Upstream Pokémon compositions/sequences | Replace or separately license/clear before public release | P0 | OPEN |
| Sound effects | Upstream Pokémon-identifying cries and branded/recognizable SFX | Replace/clear; Somaskan cries must be original | P0 | OPEN |
| Credits/legal screens | Upstream credits/trademarks/legal notices | Preserve notices required by source/license where applicable, but build SOMADEX-specific credits/legal presentation after legal review | P0 | OPEN |
| Debug/test menus | Upstream names/data exposed by debug tools | Keep development-only; ensure unavailable in public player path unless sanitized | P2/P0 | OPEN |
| Link/multiplayer naming | Pokémon-specific labels/data if retained | Disable or replace unless intentionally supported and sanitized | P2/P0 | OPEN |
| Save-visible strings | Upstream location/species/item/trainer names persisted to save | Prevent in production saves once Phase 3 save compatibility is declared | P1 | OPEN |

## Micro-PoC-specific removals already identified

The Phase 1 report explicitly confirmed these remaining items:

1. upstream title screen/branding;
2. fragments of English UI;
3. upstream/default player naming;
4. upstream battle backgrounds/UI content;
5. technical Luzik back sprite created from a mirrored seed rather than a separately authored back view.

The fifth item is not third-party IP removal, but it remains a production-asset blocker and is tracked alongside the cleanup because it affects the same Phase 3 presentation gate.

## Phase 3 rule

The Phase 3 vertical slice must maintain a **reachable-path audit**: every screen, battle, map, menu and transition accessible in the slice is checked against this register.

A Phase 3 PASS requires zero untracked upstream-visible content in the tested path. Temporary upstream content may remain only when:

- it is explicitly recorded here;
- it is outside the accepted player-facing path or clearly marked as temporary development content;
- it has an assigned replacement/disable decision;
- it does not get misrepresented as final SOMADEX material.

## Before public release

Before any public SOMADEX release, this register must be converted from category-level tracking into an exhaustive asset/string/source audit with provenance and legal disposition. Public release additionally requires the separate legal review already mandated by the Foundation Lock.
