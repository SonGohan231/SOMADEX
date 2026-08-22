#!/usr/bin/env python3
"""Connect the first three Vela maps and replace reachable Hoenn hooks with SOMADEX content.

The upstream map IDs remain technical engine slots. Player-facing map names stay hidden
until the dedicated region-map naming pass, but all reachable outer-map events/scripts in
this block are now Vela-owned.
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


def sign_event(x: int, y: int, script: str) -> dict:
    return {
        "type": "sign",
        "x": x,
        "y": y,
        "elevation": 0,
        "player_facing_dir": "BG_EVENT_PLAYER_FACING_ANY",
        "script": script,
    }


def configure_outer_map(
    path: Path,
    *,
    expected_id: str,
    connections: list[dict],
    bg_events: list[dict],
) -> None:
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

    # Remove all legacy NPC/story/warp hooks. Only explicitly supplied Vela interactions survive.
    data["object_events"] = []
    data["warp_events"] = []
    data["coord_events"] = []
    data["bg_events"] = bg_events
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


def write_vela_south_scripts(path: Path) -> None:
    path.write_text(
        "LittlerootTown_MapScripts::\n"
        "\t.byte 0\n\n"
        "VelaSouth_EventScript_Sign::\n"
        "\tmsgbox VelaSouth_Text_Sign, MSGBOX_SIGN\n"
        "\tend\n\n"
        "VelaSouth_Text_Sign:\n"
        "\t.string \"VELA - POLUDNIE\\nCentrum: prosto na polnoc.$\"\n",
        encoding="utf-8",
    )


def write_vela_grove_scripts(path: Path) -> None:
    path.write_text(
        "OldaleTown_MapScripts::\n"
        "\t.byte 0\n\n"
        "VelaGrove_EventScript_Crystal::\n"
        "\tmsgbox VelaGrove_Text_Crystal, MSGBOX_SIGN\n"
        "\tend\n\n"
        "VelaGrove_Text_Crystal:\n"
        "\t.string \"Krysztal rezonansu lekko drga.\\nPowietrze wokol niego faluje.$\"\n",
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
        bg_events=[sign_event(5, 8, "VelaSouth_EventScript_Sign")],
    )
    configure_vela_center(root / "data/maps/Route101/map.json")
    configure_outer_map(
        root / "data/maps/OldaleTown/map.json",
        expected_id="MAP_OLDALE_TOWN",
        connections=[connection("MAP_ROUTE101", "down")],
        bg_events=[
            sign_event(7, 9, "VelaGrove_EventScript_Crystal"),
            sign_event(12, 9, "VelaGrove_EventScript_Crystal"),
        ],
    )

    write_vela_south_scripts(root / "data/maps/LittlerootTown/scripts.inc")
    write_vela_grove_scripts(root / "data/maps/OldaleTown/scripts.inc")

    # Verify the intended three-map chain and the two new Vela-only interaction surfaces.
    south = load_json(root / "data/maps/LittlerootTown/map.json")
    center = load_json(root / "data/maps/Route101/map.json")
    north = load_json(root / "data/maps/OldaleTown/map.json")
    if south["connections"] != [connection("MAP_ROUTE101", "up")]:
        raise SystemExit("Vela South connection verification failed")
    if center["connections"] != [connection("MAP_OLDALE_TOWN", "up"), connection("MAP_LITTLEROOT_TOWN", "down")]:
        raise SystemExit("Vela Center connection verification failed")
    if north["connections"] != [connection("MAP_ROUTE101", "down")]:
        raise SystemExit("Vela Grove connection verification failed")
    if south["bg_events"] != [sign_event(5, 8, "VelaSouth_EventScript_Sign")]:
        raise SystemExit("Vela South sign verification failed")
    if len(north["bg_events"]) != 2 or any(e["script"] != "VelaGrove_EventScript_Crystal" for e in north["bg_events"]):
        raise SystemExit("Vela Grove crystal interaction verification failed")

    print("PHASE4 VELA WORLD PASS: south <-> center <-> grove connected; legacy outer events removed; Vela interactions installed")


if __name__ == "__main__":
    main()
