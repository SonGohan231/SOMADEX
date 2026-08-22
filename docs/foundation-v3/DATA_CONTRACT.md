# SOMADEX — PRODUCTION DATA CONTRACT V1

Status: **BOUND BY FOUNDATION LOCK**  
Applies from: Phase 3 Vertical Slice

## Purpose

The Micro-PoC proved that SOMADEX data can be wired into the selected runtime, but it intentionally reused upstream numeric slots to keep the proof minimal. Production work must not scale that shortcut.

This contract defines how SOMADEX-owned gameplay data enters the locked `pokeemerald-expansion` foundation.

## 1. Ownership rule

Every player-facing production entity added by SOMADEX must have a SOMADEX-owned canonical definition before it is referenced by maps, battles, saves or UI.

Required canonical entity classes include:

- Somaskan family;
- Somaskan form/species;
- move;
- passive/ability;
- item;
- capture device;
- status/reaction;
- trainer archetype and trainer instance;
- NPC;
- map/location;
- quest/event;
- persistent flag/variable;
- equipment item;
- trainer talent;
- battle gadget.

## 2. Identifier rule

Production entities must receive stable SOMADEX identifiers in an explicit registry. They may not be defined by permanently hijacking an unrelated upstream Pokémon, move, item or trainer slot.

The registry must preserve these invariants:

1. identifier meaning is stable after a public save exists;
2. deletion does not silently reassign an old identifier to a different entity;
3. aliases/migrations are explicit when renaming is unavoidable;
4. map scripts and save data reference canonical constants, not magic numbers;
5. tooling can validate duplicate IDs and missing references before build.

The exact numeric layout is an implementation detail to be chosen during Phase 3 only after inspecting the locked upstream tables and save constraints. This document intentionally does not invent arbitrary numeric ranges.

## 3. Somaskan record

A production Somaskan form must minimally define:

- canonical family ID and form/species ID;
- display name;
- evolution relationship and requirements where applicable;
- battle types;
- base stats and growth data;
- learnset;
- passive/ability references;
- encounter/capture metadata where applicable;
- front sprite;
- back sprite;
- icon;
- palettes required by the runtime;
- provenance/source-art reference;
- asset validation status.

Animation targets from the canonical product plan remain product goals, not an excuse to mass-produce before Phase 3 proves the final GBA animation pipeline and budget.

## 4. Move record

A production move must minimally define:

- canonical move ID;
- display name;
- SOMADEX type;
- category/behavior class;
- power where relevant;
- accuracy where relevant;
- PP/resource cost;
- priority where relevant;
- target rules;
- status/reaction effects;
- animation/effect reference;
- localized battle text references.

`Impuls Warstwowy` in the PoC demonstrates integration only. Its use of the upstream Pound slot is not production architecture.

## 5. Item and capture-device record

A production item must minimally define:

- canonical item ID;
- display name;
- category;
- inventory behavior;
- battle/field effect;
- icon/graphics where required;
- localized text;
- price/acquisition metadata where applicable.

`Kula Splotu` in the PoC demonstrates the capture path only. Its temporary use of the upstream Poke Ball slot must be replaced before the corresponding content is considered production-ready.

## 6. Status and reaction contract

Statuses and reactions are separate concepts:

- **status** = persistent or timed state attached to a battler or trainer;
- **reaction** = a rule triggered by a defined combination of state, move, type, environment or timing.

The canonical project currently includes statuses such as MOKRY, NAŁADOWANY, OPARZENIE, NIESTABILNY, OZNACZONY, ZAKŁÓCONY, UKORZENIONY, PĘKNIĘTA OSŁONA, KRWAWIENIE, WYCHŁODZONY, ZAMROŻONY, POKRYTY ŻYWICĄ, SKUPIONY, REGENERACJA, ZACHWIANIE, CISZA, ZATRUTY, PORAŻONY, DEZORIENTACJA and PODATNY.

Phase 3 must implement only the subset needed by the vertical slice and must prove that the chosen representation is extensible before bulk implementation.

## 7. Map/event persistence contract

Persistent world state must use registered flags/variables with documented ownership.

For every persistent event, record:

- owning map/quest/system;
- canonical flag/variable name;
- initial state;
- state transitions;
- save/load expectation;
- migration behavior if changed later.

`FLAG_MET_MIRA` is a PoC proof and must either be promoted into the production registry with an intentional canonical meaning or replaced during Phase 3.

## 8. Save compatibility

Before Phase 3 creates saves intended to survive between builds, the project must define a save schema/version marker and a migration policy.

Rules:

- no silent semantic reuse of saved IDs;
- save-affecting registry changes require a compatibility note and test;
- a clean new-game save and an upgrade save must be distinguishable in QA;
- destructive save resets are acceptable only before the project explicitly declares save compatibility and must be documented in release notes.

## 9. Localization/text

Player-facing production strings must be SOMADEX-owned. Upstream English text discovered in the tested path is removal work, not reusable final copy.

Phase 3 must establish the final character-map policy for Polish text, including whether and how diacritics are supported, before large-scale dialogue production.

## 10. Asset provenance

Every production asset must be classified as one of:

- `SOMADEX_ORIGINAL`;
- `SOMADEX_DERIVED_FROM_OWN_CONCEPT_ART`;
- `TEMPORARY_UPSTREAM_REFERENCE`;
- `TEMPORARY_PLACEHOLDER`.

Only the first two classes may survive into a public SOMADEX release unless separately cleared by legal review.

## 11. Validation gate

Before content is accepted into the Phase 3 slice, automated or scripted validation must be able to detect at least:

- duplicate canonical IDs;
- missing referenced IDs;
- missing required species/move/item fields;
- missing required runtime assets;
- map/event references to undefined persistent flags;
- accidental use of PoC technical remaps as final production definitions.

## 12. Scaling rule

No registry may be bulk-filled merely because the canonical plan contains 150 forms, 180–220 moves or 100 talents. Phase 3 first validates structure, memory cost, tooling and save behavior with a deliberately small dataset.
