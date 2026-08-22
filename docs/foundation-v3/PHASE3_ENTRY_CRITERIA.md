# SOMADEX — PHASE 3 ENTRY CRITERIA

Status: **GATE DEFINITION**  
Next stage: small Vertical Slice only

Phase 3 may start only when every Phase 2 foundation-control item below is present and internally consistent.

## A. Foundation lock

- [x] Selected foundation is `rh-hideout/pokeemerald-expansion`.
- [x] Upstream is pinned to `bb6f399bce71db7e82a4bfa40e72b29498ef1de6`.
- [x] Runtime target is GBA ROM in an emulator.
- [x] Machine-readable lock exists at `poc/pokeemerald-expansion/foundation.lock.yml`.
- [x] Upstream changes require explicit re-review; foundation changes reopen Phase 0.

## B. Evidence baseline

- [x] Phase 0 scorecard exists.
- [x] Phase 0 foundation decision exists.
- [x] Phase 0 evidence log exists.
- [x] Phase 1 Micro-PoC report exists.
- [x] All 10 functional PoC acceptance steps passed.
- [x] PoC build/runtime hashes and memory measurements are recorded.
- [x] PoC result is recorded as `CONDITIONAL PASS`, not overstated as a finished game.

## C. Distribution and legal boundary

- [x] Public distribution is source/assets plus BPS/UPS patch only.
- [x] Publishing a completed ROM containing third-party game content is forbidden.
- [x] Separate legal review is required before public release.
- [x] Upstream-visible content is treated as removal/replacement work rather than SOMADEX final content.

## D. Production data boundary

- [x] Production data contract exists.
- [x] PoC numeric slot hijacks are explicitly classified as temporary proof shortcuts.
- [x] Production entities require stable SOMADEX-owned canonical IDs/registries.
- [x] Persistent flags/variables require documented ownership and save expectations.
- [x] Save compatibility/versioning must be defined before persistent cross-build saves are promised.
- [x] Bulk population of 150 forms / 180–220 moves / full campaign is prohibited before the slice proves structure and budgets.

## E. Upstream-content boundary

- [x] Category-level upstream content removal register exists.
- [x] Title/branding, English UI, player naming and battle presentation from the PoC are explicitly tracked.
- [x] Phase 3 requires a reachable-path audit.
- [x] Public release requires an exhaustive provenance/legal disposition audit.

## F. Conditions that carry into Phase 3

The following are **not required to declare the foundation locked**, but are mandatory acceptance work for the vertical slice or later release gates:

- [ ] real separately authored Luzik back sprite and approved production animation approach;
- [ ] physical Android phone emulator QA;
- [ ] original title/branding and removal of upstream-visible content from the Phase 3 player path;
- [ ] final Polish text/charmap decision, including diacritics policy;
- [ ] ROM/EWRAM/IWRAM/palette measurements after the slice is expanded;
- [ ] validator for canonical IDs/references and accidental PoC-slot reuse;
- [ ] legal review before any public release.

## Phase 3 scope rule

Passing this gate authorizes only a deliberately small, coherent vertical slice built on the locked foundation. It does **not** authorize full migration or mass asset/content production.

Phase 3 must end with its own PASS / CONDITIONAL PASS / FAIL report. Only that report may decide whether broader production is unlocked.
