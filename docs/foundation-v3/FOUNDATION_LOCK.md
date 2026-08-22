# SOMADEX — PHASE 2 FOUNDATION LOCK

Data: 2026-08-22 UTC  
Status: **LOCKED FOR PHASE 3 — SMALL VERTICAL SLICE ONLY**

## 1. Locked foundation

SOMADEX uses `rh-hideout/pokeemerald-expansion` pinned to:

`bb6f399bce71db7e82a4bfa40e72b29498ef1de6`

Target runtime: **GBA ROM executed in a phone emulator**.

The lock is based on the completed Phase 0 audit and Phase 1 Micro-PoC. The Micro-PoC passed all 10 functional acceptance steps and received **CONDITIONAL PASS** because remaining problems are content/polish/publication conditions rather than a demonstrated core-runtime blocker.

This document is the authoritative Foundation V3 lock. Any older root-level `FOUNDATION_LOCK.md`, Foundation 1.0 label, Godot-first decision or APK-first assumption is legacy material and does not override this lock.

## 2. What is locked

The following decisions may not drift during Phase 3 without reopening the formal decision process:

- upstream project: `rh-hideout/pokeemerald-expansion`;
- exact upstream commit: `bb6f399bce71db7e82a4bfa40e72b29498ef1de6`;
- runtime class: GBA ROM in emulator;
- source strategy: SOMADEX-owned source/assets layered as a reproducible patch set on the pinned upstream;
- public distribution strategy: source/assets plus BPS/UPS patch only;
- no completed ROM containing third-party game content may be published;
- Godot remains frozen as a legacy data/asset/test source, not a parallel production runtime;
- production data must receive SOMADEX-owned identifiers instead of permanently reusing upstream Pokémon identifiers as done in the minimal PoC.

The machine-readable copy is `poc/pokeemerald-expansion/foundation.lock.yml`.

## 3. Change-control rule

An upstream update is not a routine dependency bump. Changing the pinned commit requires all of the following:

1. written reason for the change;
2. diff/risk review against the currently locked commit;
3. clean rebuild of the affected slice;
4. rerun of the relevant runtime acceptance tests, including save/load when save-affecting code changes;
5. updated evidence and hashes;
6. explicit replacement of this lock.

Changing to another engine/foundation requires reopening **PHASE 0 FOUNDATION AUDIT**. It may not be done inside a content or polish PR.

## 4. Allowed work after this lock

The next permitted implementation stage is a **small Phase 3 Vertical Slice**. Phase 3 may expand the proven loop only far enough to test production architecture, original presentation, data ownership, resource budgets and a coherent player-facing slice.

Phase 3 may include:

- SOMADEX-owned data definitions and registries;
- original UI/text/branding replacement in the tested slice;
- original maps/events/NPCs needed by that slice;
- a small, deliberately limited set of production-quality Somaskans, moves, items and assets;
- save-version and compatibility checks;
- phone-emulator QA;
- measurements of ROM/EWRAM/IWRAM/palette pressure after the slice grows.

## 5. Work still forbidden

Foundation Lock is **not** approval for full migration.

Until Phase 3 has its own acceptance result, the following remain prohibited:

- migrating all 150 forms;
- producing all planned 3150 animation frames;
- implementing the full 180–220 move catalogue;
- mass-porting all towns, routes, NPCs, bosses, quests or items;
- treating technical PoC slot replacements such as Treecko/Pound/Poke Ball as final production identifiers;
- publishing a ROM;
- presenting inherited upstream branding, art, names, dialogue, music, UI or world content as SOMADEX content;
- resuming Godot work in parallel to hedge against the chosen foundation.

## 6. Conditions carried forward from the Micro-PoC

These do not invalidate the foundation lock, but they remain explicit gates for later stages:

- replace upstream title, branding, English UI fragments, default player naming, battle backgrounds and other visible third-party game content;
- create a genuine separately authored Luzik back sprite and production animation set;
- perform manual QA on a physical Android phone in at least one GBA emulator;
- measure memory/ROM/palette budgets after a small vertical slice instead of extrapolating from one species;
- retain patch-only distribution and perform legal review before any public release.

## 7. Foundation invariant

The technical foundation may provide mechanics and tooling. The player-facing product must progressively become SOMADEX-owned IP. Phase 3 must reduce upstream-visible content, not expand dependence on it.

**Result of Phase 2:** foundation choice is frozen for Phase 3; full migration and mass content production remain locked out.
