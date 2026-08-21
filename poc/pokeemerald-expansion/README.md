# SOMADEX Foundation V3 Micro-PoC

This source-only package reproduces the Phase 1 proof on top of:

`rh-hideout/pokeemerald-expansion@bb6f399bce71db7e82a4bfa40e72b29498ef1de6`

It does **not** contain or authorize distribution of a ROM. Build only from a lawful local setup; publish SOMADEX as source/assets plus a BPS/UPS patch requiring the proper base ROM, never as a completed ROM containing third-party game content.

## Apply

1. Clone the exact upstream commit.
2. From the upstream root, apply `upstream.patch` from the publication package with `git apply --binary`.
3. Run `python3 somadex_poc/generate_map.py`.
4. Run `somadex_poc/generate_assets.sh /path/to/current/SOMADEX` to convert the real Luzik/player/Mira seeds. This requires ImageMagick 6 and the seed files under `assets/embedded`.
5. Install an ARM GNU toolchain compatible with pokeemerald-expansion; the audited build used xPack GNU Arm Embedded GCC 14.2.1-1.1.
6. Run `make -j2`.

Expected audited output: a 32 MiB local test ROM with SHA-256 `f1ca18cfcf62ec3d498430e92afe443df46ffa86f967ce2278217e1c16e3ba7b` when using the same toolchain, converters and inputs.

## Content pipeline demonstrated

- **Map:** `generate_map.py` writes a 20×20 native metatile layout; `map.json` defines collision-aware objects and a trigger; `scripts.inc` owns transition, Mira, landmark and battle scripts.
- **Event/NPC:** add an object event to map JSON, define its script and dialogue, and reserve a persistent flag. The PoC uses `FLAG_MET_MIRA`.
- **Somaskan:** define the species record, graphics paths/palettes/icon, encounter entry and optional overworld graphics. The PoC reuses Treecko's numeric slot only to minimize proof size; production must allocate SOMADEX-owned IDs.
- **Move:** add the move record and learnset. The PoC reuses Pound's numeric slot for `Impuls Warstwowy`; production must allocate its own move IDs.
- **Save:** ordinary engine flags, party state, inventory and player position are saved through the native save system.

## Automated runtime evidence

`headless_poc_runner.c` runs the built ROM with libmGBA, drives the full loop, captures native 240×160 frames and logs player position plus party count. Run it twice with the same save file; the second process proves hard-restart persistence. Symbol addresses are build-specific—obtain them from `arm-none-eabi-nm -n pokeemerald.elf` before recompiling the runner.

The runner is a gate harness, not production game code.
