# SOMADEX — PHASE 0 EVIDENCE LOG

Data: 2026-08-21 UTC

## Materiały dostarczone

- `SOMADEX_WORK_PACKAGE_V3_FINAL.zip`: otworzono 18 wpisów; sprawdzono wszystkie 17 pozycji manifestu. Manifest używa własnego formatu TSV, dlatego standardowe `sha256sum -c` go nie rozpoznaje; niezależna kontrola rozmiaru i SHA-256 zwróciła **PASS 17/17**.
- `pokefirered-somaskan--master.zip`: snapshot `pret/pokefirered` `c75f352304d529f6ba92d4f74b9cf8b5c3810788`; przejrzano strukturę, README, INSTALL, Makefile, mapy, eventy, battle, graphics, sound i narzędzia.
- `SOMADEX_MASTER_PRODUCTION_DIRECTIVE.txt`: starsza dyrektywa; nie użyta jako nadrzędna wobec V3.

## Assety SOMADEX

Archiwum `SOMADEX_STWORKI_001_050_TYLKO_GRAFIKI.zip`:

- 255 plików JPG łącznie;
- 50 plansz pełnych linii ewolucyjnych 1800×579;
- 150 osobnych kart form 960×720;
- 50 miniatur 420×260;
- 5 ilustracji spisu/zagadek;
- wizualnie sprawdzono Luzika i planszę rodziny 001.

Wniosek: materiały potwierdzają wygląd, nazwy i 150 form koncepcyjnych. Nie są to gotowe transparentne sprite’y front/back/overworld ani sprite-sheety animacji.

W aktualnym repo Godot potwierdzono dodatkowo realne transparentne seedy 48×48: Luzik, Bocznik, Milimik, Wahlik, Nucik i Dudnik; `trainer_walk` 192×24; `npc_mira` 48×24; tileset 192×24.

## Google Drive

Przez połączony Dysk wyszukano `SOMADEX` i `Somaskan`. Zidentyfikowano m.in.:

- folder `SOMADEX V2 — Kolekcjonerski FINAL — 2026-08-20`;
- `SOMADEX_V2_Kolekcjonerski_FINAL.pdf` 585,975,560 B;
- tomy metod 001–050, pięć tomów „MEGA EWOLUCJE” i spis stworów;
- `SOMADEX_CHECKLISTA_ODBIORCZA.md`, `AUDYT_FINAL.md`, `START_TUTAJ.txt`;
- starsze sześciotomowe wydanie kolekcjonerskie Somaskan.

Nie pobierano wielkich PDF-ów, ponieważ Phase 0 wymagał inwentaryzacji i przenośności assetów, a paczka V3 zawierała właściwy aktualny zestaw 50/150 grafik.

## Aktualny GitHub SOMADEX

Repo: `SonGohan231/SOMADEX`, `main` `7431669699552422d59ce0013e0a6b818cd0519a`.

Faktycznie otwarto/przeszukano:

- root tree, `project.godot`, `Main.tscn`, workflow Android, `FOUNDATION_LOCK.md`, `docs/ENGINE_BASE.md`;
- `campaign_game.gd`, świat, save, battle/data/test scripts;
- PR-y do #44 oraz stan `main`;
- workflow run #158 (`32460291370`) — conclusion `success`;
- artifact `SOMADEX-Alpha1-Android-debug` — 28,781,006 B, nieprzeterminowany.

Lokalnie Godot 4.7.1:

- uruchomienie main scene: exit 0;
- `foundation_smoke.gd`: PASS;
- `foundation_integration.gd`: PASS;
- `campaign_playthrough_smoke.gd`: PASS.

Ustalony problem strukturalny: `Main.tscn` uruchamia `campaign_game.gd`; świat dziedziczy renderer `_draw_*`, ma stałe 15×23 i `map_rows` z kodami znakowymi. W `scripts/world` nie znaleziono produkcyjnego `TileMap`/`TileMapLayer`.

## Kandydaci zewnętrzni faktycznie sprawdzeni

- [`pret/pokefirered`](https://github.com/pret/pokefirered) `c75f352304d529f6ba92d4f74b9cf8b5c3810788` — README/INSTALL/source snapshot.
- [`rh-hideout/pokeemerald-expansion`](https://github.com/rh-hideout/pokeemerald-expansion) `bb6f399bce71db7e82a4bfa40e72b29498ef1de6` — README, INSTALL, branch metadata, build/tool references.
- [`PokemonWorkshop/PSDKTechnicalDemo`](https://github.com/PokemonWorkshop/PSDKTechnicalDemo) `e105b4200b1df7e17119b6ece4766eb94ae526bf` — README, MIT, requirements and Tiled/Studio workflow.
- [`Maruno17/pokemon-essentials`](https://github.com/Maruno17/pokemon-essentials) `8c5911e4a4b07b07e832e4bb0d5d8859e88b4a9b` — README, CC BY-NC-SA 4.0, incomplete public package note.
- [`master172/PokemonGodWhite`](https://github.com/master172/PokemonGodWhite) `fba69f1710f3d41e6e367539e8e9adb2ab4e551d` — README, MIT, `project.godot`, autoload managers.
- [`Maruno17/godotmon-project`](https://github.com/Maruno17/godotmon-project) `c8d37957cee67573c25ab2ffa3b6747c1ac98e0c` — README, root tree, credits, brak project LICENSE.
- [`Tuxemon/Tuxemon`](https://github.com/Tuxemon/Tuxemon) `59a34164f442ddecbaee4c436e3f1a5ba9474e29` — README, GPLv3, install docs, Android experimental, `pyproject.toml` 0.4.35.

## Próba build-tooling GBA

W dostarczonym FireRed wykonano wyłącznie diagnostyczny dry-run. Wynik:

- brak `arm-none-eabi-gcc`;
- brak `pkg-config`;
- brak `png.h`/`libpng-dev`;
- źródło nie było modyfikowane.

To jest znany, rozwiązywalny problem środowiska PoC, a nie dowód przeciwko silnikowi. Phase 1 musi dostarczyć przypięty i reprodukowalny toolchain.
