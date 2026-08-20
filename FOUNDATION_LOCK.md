# SOMADEX Foundation 1.0 — FROZEN

Baseline commit: `fe4f7244f50e80117c2188fb6985e88a42f2946a`

Foundation 1.0 is the frozen production base for SOMADEX Alpha development.

Stable contracts:
- save schema v10 + migration from v2/v8
- party/storage member records and active party slot
- six-slot equipment loadout and inventory registry
- trainer progression, Focus and five trainer actions
- status/reaction system and battle rules
- data-driven zones, transitions and persistent dialogue flags
- Android export pipeline, contract tests and screen-integration tests

Alpha branches may extend these contracts, but should not redesign them without a dedicated migration and regression PR.
