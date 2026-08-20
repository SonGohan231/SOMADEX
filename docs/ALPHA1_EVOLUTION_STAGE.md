# Alpha 1 evolution stage

Scope implemented on `alpha1/evolution-art-pipeline`:

- catalog-driven evolution thresholds: level 12 and 28;
- case-safe canonicalization of historical `uczek` → `Uczek`;
- all 150 catalog forms resolve to valid runtime battle records;
- existing authored Vela species retain their designed stats/moves and evolved forms scale from those records;
- not-yet-authored families receive deterministic placeholder runtime stats/moves instead of silently falling back to Luzik;
- party XP progression can rename a member into its evolved form while preserving UID, XP, bond, moves and HP continuity;
- evolved forms are added to Seen/Caught registries;
- `last_evolutions` records the most recent evolution event for later UI presentation;
- dedicated CI smoke test validates all 150 records and two-step evolution;
- source-card portrait normalization pipeline and Vela atlas ordering are now documented and reproducible.

Transparent animated battle sprites remain a separate art-production gate. Runtime evolution data is intentionally decoupled from the final animation assets so mechanics can be tested without blocking the art pipeline.
