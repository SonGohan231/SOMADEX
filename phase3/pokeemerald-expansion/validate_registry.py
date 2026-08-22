#!/usr/bin/env python3
import json
import sys
from pathlib import Path

EXPECTED_FOUNDATION = "bb6f399bce71db7e82a4bfa40e72b29498ef1de6"
FORBIDDEN_RUNTIME_IDS = {
    "SPECIES_TREECKO",
    "MOVE_POUND",
    "ITEM_POKE_BALL",
}
ALLOWED_PROVENANCE = {
    "SOMADEX_ORIGINAL",
    "SOMADEX_DERIVED_FROM_OWN_CONCEPT_ART",
    "TEMPORARY_UPSTREAM_REFERENCE",
    "TEMPORARY_PLACEHOLDER",
}


def fail(message: str) -> None:
    print(f"REGISTRY FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def require_keys(record, keys, label):
    for key in keys:
        if key not in record or record[key] in (None, "", []):
            fail(f"{label}: missing required field {key}")


def unique(records, key, label):
    seen = set()
    for rec in records:
        value = rec.get(key)
        if not value:
            fail(f"{label}: missing {key}")
        if value in seen:
            fail(f"{label}: duplicate {key} {value}")
        seen.add(value)
    return seen


def main() -> None:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).with_name("registry.json"))
    data = json.loads(path.read_text(encoding="utf-8"))

    if data.get("schema_version") != 1:
        fail("unsupported schema_version")
    foundation = data.get("foundation", {})
    if foundation.get("repository") != "rh-hideout/pokeemerald-expansion":
        fail("foundation repository drift")
    if foundation.get("commit") != EXPECTED_FOUNDATION:
        fail("foundation commit drift")
    if data.get("save_compatibility_declared") is not False:
        fail("Phase 3 must not declare long-term save compatibility")

    families = data.get("families", [])
    species = data.get("species", [])
    moves = data.get("moves", [])
    items = data.get("items", [])
    flags = data.get("flags", [])
    locations = data.get("locations", [])

    family_ids = unique(families, "id", "families")
    species_ids = unique(species, "id", "species")
    move_ids = unique(moves, "id", "moves")
    item_ids = unique(items, "id", "items")
    unique(flags, "id", "flags")
    unique(locations, "id", "locations")

    runtime_records = species + moves + items + flags + locations
    runtime_ids = unique(runtime_records, "runtime_id", "runtime entities")
    bad = sorted(runtime_ids & FORBIDDEN_RUNTIME_IDS)
    if bad:
        fail("PoC technical remaps are forbidden in production registry: " + ", ".join(bad))

    for rec in species:
        require_keys(rec, ["id", "runtime_id", "family_id", "name", "types", "moves", "assets"], "species")
        if rec["family_id"] not in family_ids:
            fail(f"species {rec['id']}: unresolved family {rec['family_id']}")
        for move_id in rec["moves"]:
            if move_id not in move_ids:
                fail(f"species {rec['id']}: unresolved move {move_id}")
        assets = rec["assets"]
        require_keys(assets, ["front", "back", "icon", "provenance"], f"species {rec['id']} assets")
        if assets["provenance"] not in ALLOWED_PROVENANCE:
            fail(f"species {rec['id']}: invalid asset provenance")
        if assets["provenance"].startswith("TEMPORARY_"):
            fail(f"species {rec['id']}: Phase 3 accepted species art cannot be temporary")

    for rec in moves:
        require_keys(rec, ["id", "runtime_id", "name", "type", "power", "accuracy", "pp"], "move")
        if not 0 <= int(rec["accuracy"]) <= 100:
            fail(f"move {rec['id']}: invalid accuracy")
        if int(rec["pp"]) <= 0:
            fail(f"move {rec['id']}: pp must be positive")

    for rec in items:
        require_keys(rec, ["id", "runtime_id", "name", "purpose", "assets"], "item")
        provenance = rec["assets"].get("provenance")
        if provenance not in ALLOWED_PROVENANCE:
            fail(f"item {rec['id']}: invalid asset provenance")
        if provenance.startswith("TEMPORARY_"):
            fail(f"item {rec['id']}: accepted item art cannot be temporary")

    if "SOMADEX_SPECIES_LUZIK" not in species_ids:
        fail("vertical slice requires Luzik")
    if "SOMADEX_MOVE_IMPULS_WARSTWOWY" not in move_ids:
        fail("vertical slice requires Impuls Warstwowy")
    if "SOMADEX_ITEM_KULA_SPLOTU" not in item_ids:
        fail("vertical slice requires Kula Splotu")

    print(
        "REGISTRY PASS: "
        f"families={len(families)} species={len(species)} moves={len(moves)} "
        f"items={len(items)} flags={len(flags)} locations={len(locations)}"
    )


if __name__ == "__main__":
    main()
