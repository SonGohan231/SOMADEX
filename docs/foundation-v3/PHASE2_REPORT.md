# SOMADEX — PHASE 2 FOUNDATION LOCK REPORT

Data: 2026-08-22 UTC  
Result: **PASS — FOUNDATION LOCKED FOR SMALL PHASE 3 VERTICAL SLICE**

## Scope

Phase 2 was restricted to foundation governance and production-boundary definition. No full migration, mass content import, Godot modification or broad game implementation was performed.

## Verified baseline

- PR #45 remained open and draft at the start of Phase 2.
- Phase 2 was created on a separate branch from PR #45 head `807b444c7890d3aeef26c8594bfcdd79acf0adef`.
- The selected upstream commit `bb6f399bce71db7e82a4bfa40e72b29498ef1de6` was independently resolved from `rh-hideout/pokeemerald-expansion` during Phase 2.
- Phase 1 evidence still reports all 10 functional Micro-PoC criteria as PASS and the overall PoC verdict as `CONDITIONAL PASS`.

## Required Phase 2 outputs

| Requirement | Result | Artifact |
|---|---|---|
| Pin exact upstream | PASS | `poc/pokeemerald-expansion/foundation.lock.yml` |
| Freeze foundation decision | PASS | `docs/foundation-v3/FOUNDATION_LOCK.md` |
| Patch-only distribution policy | PASS | lock manifest + Foundation Lock |
| Production data contract | PASS | `docs/foundation-v3/DATA_CONTRACT.md` |
| Upstream content removal list | PASS | `docs/foundation-v3/CONTENT_REMOVAL_REGISTER.md` |
| Explicit Phase 3 gate | PASS | `docs/foundation-v3/PHASE3_ENTRY_CRITERIA.md` |
| Preserve prohibition on full migration | PASS | lock manifest + Foundation Lock + Phase 3 gate |

## Locked decisions

1. Production foundation: `rh-hideout/pokeemerald-expansion` at exactly `bb6f399bce71db7e82a4bfa40e72b29498ef1de6`.
2. Runtime target: GBA ROM in an emulator, including phone emulators.
3. Public distribution: SOMADEX-owned source/assets plus BPS/UPS patch only.
4. Completed ROM publication containing third-party game content: forbidden.
5. Godot: frozen legacy source of data/assets/tests; not a parallel production runtime.
6. Production entities: SOMADEX-owned canonical identifiers and registries; PoC slot hijacks are not production architecture.
7. Any foundation switch: reopen Phase 0.
8. Any upstream bump: formal change review plus affected acceptance reruns.

## Conditions intentionally not closed in Phase 2

These remain open because they require implementation or device QA rather than governance documents:

- genuine Luzik back sprite and production animation approach;
- physical Android phone emulator test;
- removal/replacement of upstream title, English UI, player naming, battle backgrounds and other visible upstream content from the Phase 3 path;
- Polish charmap/diacritics decision;
- resource-budget measurement after the vertical slice grows;
- production data validator;
- legal review before public release.

None of the above was silently reclassified as complete.

## Gate result

The foundation itself is now locked strongly enough to permit a **small Phase 3 Vertical Slice**. The lock does not authorize full campaign migration, 150-form asset production, full move/status/talent implementation, or public ROM distribution.

**Next allowed implementation work:** Phase 3 Vertical Slice under `PHASE3_ENTRY_CRITERIA.md`, ending in a separate acceptance report before any wider scaling decision.
