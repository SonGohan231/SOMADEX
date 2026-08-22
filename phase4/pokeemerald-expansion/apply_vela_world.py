#!/usr/bin/env python3
"""Connect the first three Vela maps and remove reachable legacy Hoenn events.

This intentionally keeps upstream map IDs/layout IDs as engine slots. Player-facing map
names remain hidden until the SOMADEX region-map naming pass.
"""

import argparse
import json
import subprocess
from pathlib import Path

PINNED = "bb6f399bce71db7e82a4bfa40e72b29498ef1de6"


def git(root: Path, *args: str) -> str:
    return subprocess.check_output(["git", "-C", str(root), *args], text=True).strip()


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def connection(map_id: str, direction: str) -> dict:
    return {"map": map_id, "offset": 0, "direction": direction}


def configure_outer_map(path: Path, *, expected_id: str, connections: list[dict]) -> None:
    data = load_json(path)
    if data.get("id") != expected_id:
        raise SystemExit(f"unexpected map id in {path}: {data.get('id')} != {expected_id}")

    data["music"] = "MUS_ROUTE101"
    data["requires_flash"] = False
    data["allow_cycling"] = False
    data["allow_escaping"] = False
    data["allow_running"] = True
    data["show_map_name"] = False
    data["connections"] = connections

    # Phase 4 map block owns only traversal here. Remove all reachable legacy story/NPC/warp hooks.
    data["object_events"] = []
    data["warp_events"] = []
    data["coord_events"] = []
    data["bg_events"] = []
    save_json(path, data)


def configure_vela_center(path: Path) -> None:
    data = load_json(path)
    if data.get("id") != "MAP_ROUTE101":
        raise SystemExit(f"unexpected Vela center slot in {path}")

    data["music"] = "MUS_ROUTE101"
    data["allow_cycling"] = False
    data["allow_running"] = True
    data["show_map_name"] = False
    data["connections"] = [
        connection("MAP_OLDALE_TOWN", "up"),
        connection("MAP_LITTLEROOT_TOWN", "down"),
    ]

    # The Phase 3 patch must already have reduced this map to the SOMADEX path.
    objects = data.get("object_events", [])
    coords = data.get("coord_events", [])
    bgs = data.get("bg_events", [])
    if len(objects) != 1 or objects[0].get("script") != "VelaTest_EventScript_Mira":
        raise SystemExit("Vela center no longer has the expected single Mira event")
    if len(coords) != 1 or coords[0].get("script") != "VelaTest_EventScript_EncounterZone":
        raise SystemExit("Vela center no longer has the expected controlled encounter event")
    if len(bgs) != 1 or bgs[0].get("script") != "VelaTest_EventScript_Landmark":
        raise SystemExit("Vela center no longer has the expected SOMADEX landmark event")

    save_json(path, data)


def replace_map_scripts(path: Path, label: str) -> None:
    path.write_text(
        f"{label}_MapScripts::\n"
        "\t.byte 0\n",
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--upstream-root", required=True, type=Path)
    args = parser.parse_args()
    root = args.upstream_root.resolve()

    if git(root, "rev-parse", "HEAD") != PINNED:
        raise SystemExit("foundation drift: Vela world block requires the locked upstream commit")

    configure_outer_map(
        root / "data/maps/LittlerootTown/map.json",
        expected_id="MAP_LITTLEROOT_TOWN",
        connections=[connection("MAP_ROUTE101", "up")],
    )
    configure_vela_center(root / "data/maps/Route101/map.json")
    configure_outer_map(
        root / "data/maps/OldaleTown/map.json",
        expected_id="MAP_OLDALE_TOWN",
        connections=[connection("MAP_ROUTE101", "down")],
    )

    # With no events on the two outer maps, their old story scripts must not remain reachable.
    replace_map_scripts(root / "data/maps/LittlerootTown/scripts.inc", "LittlerootTown")
    replace_map_scripts(root / "data/maps/OldaleTown/scripts.inc", "OldaleTown")

    # Verify the intended three-map chain in source after writing.
    south = load_json(root / "data/maps/LittlerootTown/map.json")
    center = load_json(root / "data/maps/Route101/map.json")
    north = load_json(root / "data/maps/OldaleTown/map.json")
    if south["connections"] != [connection("MAP_ROUTE101", "up")]:
        raise SystemExit("Vela South connection verification failed")
    if center["connections"] != [connection("MAP_OLDALE_TOWN", "up"), connection("MAP_LITTLEROOT_TOWN", "down")]:
        raise SystemExit("Vela Center connection verification failed")
    if north["connections"] != [connection("MAP_ROUTE101", "down")]:
        raise SystemExit("Vela Grove connection verification failed")

    print("PHASE4 VELA WORLD PASS: south <-> center <-> resonance grove connected; legacy outer-map events removed")


if __name__ == "__main__":
    main()
