# Vela visual core — implementation contract

This file is intentionally short and implementation-facing. The actual source of truth is the generator code in this directory.

## Engine fit

- primary GBA source sheet: 128x256 px, indexed, 16 colours;
- selected metatiles: 18 owned/replaced definitions inside the 512-entry primary `general` tileset;
- all new Vela metatiles use palette 0;
- map cells preserve known Phase 3 collision/elevation encodings;
- metatile behaviour bytes are copied from proven walkable, tall-grass or solid entries instead of hardcoding undocumented attribute bits.

## Visual vocabulary now available

Walkable: ground grass, dirt path, stone plaza, flower ground, sand, tall grass.

Solid/obstacle: water, 2x2 tree, fence, resonance crystal, sign, building wall, roof, door facade, lamp, hedge.

## Current reachable Vela block

1. Vela South — starter approach, small water pocket, stone staging plaza, flowers, fencing, sign.
2. Vela Center — central plaza, resonance landmark, lamps, two building facades, Mira and controlled first encounter belt.
3. Resonance Grove — denser tall grass, pool, crystal clearing and exploration space.

The large concept atlas is a direction/reference source only. The ROM build uses the compact deterministic GBA generator so the game is reproducible and does not depend on manually slicing a concept image.
