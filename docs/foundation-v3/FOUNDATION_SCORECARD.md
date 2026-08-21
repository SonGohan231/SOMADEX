# SOMADEX — FOUNDATION SCORECARD

Data audytu: 2026-08-21 UTC  
Dyrektywa: `SOMADEX_MASTER_DIRECTIVE_V3.txt`  
Skala: 0–5; wynik ważony = ocena × waga. Maksimum: 145.

## Bramki twarde

| Kandydat | Licencja / dystrybucja | Bez konieczności dystrybucji cudzej zawartości | Uruchamialny artefakt przy dostępnych narzędziach | Zapis/odczyt | Własne mapy, stworki, tekst i UI | Wynik bramki |
|---|---|---|---|---|---|---|
| A1. `pret/pokefirered` z dostarczonej paczki | PASS wyłącznie jako własny fork roboczy + dystrybucja patcha BPS/UPS, nigdy ROM-u z zawartością Pokémon | PASS po systematycznej wymianie widocznej zawartości | PASS warunkowo; źródło jest kompletne, lecz lokalnie brakowało toolchainu ARM i `libpng-dev` | PASS — sprawdzony system save gry bazowej | PASS | PASS z obowiązkową polityką patch-only |
| A2. `rh-hideout/pokeemerald-expansion` | PASS wyłącznie jako patch-only; repo nie publikuje pliku licencji obejmującego cudzą zawartość Pokémon | PASS po pełnej wymianie treści; patch nie zawiera bazowego ROM-u | PASS — dokumentowany build `make` tworzy `.gba`; wymagany toolchain ARM | PASS | PASS; Porymap/Poryscript i struktury danych | PASS z obowiązkową polityką patch-only |
| B. PSDK + Pokémon Studio + Tiled | Sam Technical Demo ma MIT, ale RMXP wymaga legalnie nabytej licencji, a pełny łańcuch PSDK wymaga osobnego audytu | PASS po wymianie zawartości | FAIL w tym środowisku — brak RMXP/Studio i brak zweryfikowanego oficjalnego artefaktu Android | PASS według działającego demo | PASS | FAIL dla bieżącego PoC |
| C. Pokémon Essentials + RPG Maker XP | Repo jest CC BY-NC-SA 4.0; tylko niekomercyjnie i share-alike | PASS po wymianie zawartości | FAIL — publiczne repo samo stwierdza, że nie jest pełnym projektem; brak kompletnej paczki Essentials i RMXP | PASS w pełnej paczce Essentials | PASS | FAIL dla bieżącego PoC |
| D. Aktualny SOMADEX / Godot | PASS — własne repo i własne dane; Godot MIT; brak licencji repo trzeba uzupełnić przed publicznym wydaniem | PASS | PASS — Godot 4.7.1 uruchamia projekt; CI #158 utworzyło APK | PASS — lokalny smoke i integracja przeszły | PASS technicznie, lecz obecny workflow map jest nieprodukcyjny | PASS |
| E1. `master172/PokemonGodWhite` | PASS dla kodu MIT; assety Pokémon muszą zostać usunięte | PASS po wymianie treści | PASS — Godot 4.5, ale runtime nie został w tym audycie zweryfikowany end-to-end | Prawdopodobny PASS, lecz niezweryfikowany w runtime | PASS | PASS, z ryzykiem niezweryfikowanej jakości |
| E2. `Maruno17/godotmon-project` | FAIL — repo nie zawiera licencji kodu projektu; obecny `godot_license.txt` licencjonuje silnik, nie projekt | Nieustalone | Technicznie prawdopodobny, ale bez znaczenia po FAIL licencji | Niezweryfikowany | Technicznie możliwe | FAIL |
| F. Tuxemon | PASS — GPL-3.0-or-later, wymaga publikacji odpowiedniego kodu źródłowego przy dystrybucji | PASS | PASS na desktopie; Android oznaczony przez autorów jako eksperymentalny | PASS | PASS — dane JSON, mapy/content data-driven | PASS, z ryzykiem telefonu |

## Oceny 0–5

Skróty kolumn:

- CORE — sprawdzony rdzeń monster-collector ×3
- WORLD — klasyczny overworld/mapy/eventy ×3
- POC — czas do przekonującego Micro-PoC ×3
- IP — wymiana treści na SOMADEX ×3
- LOOP — battle/capture/party/EXP/evolution/save ×3
- AUTHOR — workflow map/event ×2
- ART — zgodność z obecnymi assetami Somaskanów ×2
- PHONE — grywalność na telefonie ×2
- EXT — rozszerzalność mechanik SOMADEX ×2
- TOOL — build/test/debug ×2
- AV — grafika/audio/animacja ×2
- MIG — koszt migracji ×1
- MAINT — utrzymanie/społeczność/dokumentacja ×1

| Kandydat | CORE | WORLD | POC | IP | LOOP | AUTHOR | ART | PHONE | EXT | TOOL | AV | MIG | MAINT | Suma /145 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| A1. `pret/pokefirered` | 5 | 5 | 3 | 2 | 5 | 4 | 2 | 5 | 3 | 3 | 4 | 2 | 4 | **108** |
| A2. `pokeemerald-expansion` | 5 | 5 | 4 | 3 | 5 | 5 | 2 | 5 | 4 | 5 | 4 | 2 | 5 | **123** |
| B. PSDK + Studio + Tiled | 5 | 5 | 4 | 3 | 5 | 5 | 3 | 2 | 4 | 3 | 4 | 3 | 4 | **115** |
| C. Essentials + RMXP | 5 | 5 | 4 | 2 | 5 | 4 | 3 | 1 | 4 | 3 | 4 | 3 | 4 | **108** |
| D. Aktualny SOMADEX / Godot | 4 | 1 | 5 | 5 | 4 | 1 | 4 | 5 | 5 | 5 | 2 | 5 | 4 | **110** |
| E1. PokemonGodWhite | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 4 | 4 | 4 | 3 | 2 | 2 | **91** |
| E2. godotmon-project | 3 | 3 | 3 | 4 | 3 | 3 | 3 | 4 | 4 | 4 | 3 | 2 | 2 | **94 — zdyskwalifikowany** |
| F. Tuxemon | 4 | 4 | 3 | 5 | 4 | 4 | 3 | 2 | 4 | 4 | 3 | 2 | 4 | **106** |

## Uzasadnienie wyników

### A1 — dostarczony FireRed

Dostarczony ZIP jest dokładnym snapshotem `pret/pokefirered` z commita `c75f352304d529f6ba92d4f74b9cf8b5c3810788` z 2026-08-04. Otworzono `README.md`, `INSTALL.md`, `Makefile`, `data/`, `graphics/`, `sound/`, `src/`, makra eventów i dane map. Repo dokumentuje budowę prawidłowego `.gba` i zawiera pełny klasyczny core. W porównaniu z Emerald Expansion ma mniej współczesnych udogodnień i większy koszt dodawania nowoczesnych systemów SOMADEX.

### A2 — pokeemerald-expansion

Sprawdzono `master` na `bb6f399bce71db7e82a4bfa40e72b29498ef1de6` z 2026-08-21, `README.md`, `INSTALL.md`, rekomendowany build, Porymap/Poryscript oraz opis kompletnego toolkitu. Najwyższy wynik wynika z działającego rdzenia, map/eventów, telefonu przez emulator oraz najkrótszej drogi do jakościowego handheldowego loopu. Główne koszty to pełne od-Pokémonizowanie treści, limity GBA i rygor patch-only.

### B — PSDK

Sprawdzono `PokemonWorkshop/PSDKTechnicalDemo` `e105b4200b1df7e17119b6ece4766eb94ae526bf` (Demo 1.0.27), README i MIT. Demo rzeczywiście opisuje 3–4 godziny gry, eventy RMXP, dane Studio i mapy Tiled. Przegrywa bramkę bieżącego PoC: wymaga legalnego RMXP oraz narzędzi, których nie ma w środowisku; nie zweryfikowano oficjalnej, powtarzalnej ścieżki na Androida.

### C — Essentials

Sprawdzono `Maruno17/pokemon-essentials` `8c5911e4a4b07b07e832e4bb0d5d8859e88b4a9b`, README i licencję CC BY-NC-SA 4.0. Repo jest tylko warstwą kodu do pełnej paczki Essentials v21.1 i samo stwierdza, że nie jest pełnym projektem. Wysoka dojrzałość systemów nie kompensuje braku kompletnego środowiska i oficjalnego telefonu.

### D — aktualny SOMADEX/Godot

Sprawdzono `SonGohan231/SOMADEX` `main` `7431669699552422d59ce0013e0a6b818cd0519a`. Godot 4.7.1 uruchomił main scene; `foundation_smoke.gd`, `foundation_integration.gd` i `campaign_playthrough_smoke.gd` zwróciły PASS. GitHub Actions #158 zakończył się sukcesem i zawierał APK 28,781,006 B. Jednocześnie `Main.tscn` uruchamia `campaign_game.gd`, a świat nadal jest zbudowany z 15×23 kodów znakowych i metod `_draw_*`, bez produkcyjnego TileMapLayer. To daje szybki PoC i dobre dane, ale bardzo słaby workflow mapowania i potwierdza strukturalny problem obrazu gry.

### E — Godot references

`PokemonGodWhite` `fba69f1710f3d41e6e367539e8e9adb2ab4e551d` ma MIT oraz autoloady BattleManager, Inventory, EvolutionManager, TouchInput i Dialogic, ale README jest deklaracją, nie testem kompletności. `godotmon-project` `c8d37957cee67573c25ab2ffa3b6747c1ac98e0c` ma kod dla łapania/rozwoju/walki, lecz brak licencji projektu blokuje wybór.

### F — Tuxemon

Sprawdzono `Tuxemon/Tuxemon` development `59a34164f442ddecbaee4c436e3f1a5ba9474e29`, README, GPLv3, `pyproject.toml` 0.4.35 i `docs/installation.md`. To pełny, data-driven open-source monster RPG. Android jest jednak oficjalnie oznaczony jako eksperymentalny, a adaptacja obecnej estetyki i assetów do jego pipeline'u ma wyższy koszt niż Micro-PoC w GBA/Godot.

## Test odporności decyzji

- Gdy wartość całego obecnego kodu Godot zostanie przyjęta jako zero, A2 nadal wygrywa dzięki pełnemu rdzeniowi, workflow map/eventów, narzędziom i emulatorowi.
- Gdy wartość wizualnego podobieństwa do Pokémon zostanie przyjęta jako zero, wynik punktowy przesuwa się w stronę Godota/Tuxemona. To ujawnia realny bias: wybór A2 korzysta z wysokiej wagi **klasycznego handheldowego world/event workflow**, która jest jednak jawnie wymagana przez dyrektywę i wizję produktu. PoC ma sprawdzić, czy korzyść produkcyjna jest rzeczywista, a nie wyłącznie estetyczna.

## Ranking po bramkach

1. **A2 pokeemerald-expansion — 123/145**
2. **D aktualny SOMADEX/Godot — 110/145**
3. **A1 pret/pokefirered — 108/145**
4. **F Tuxemon — 106/145**
5. **E1 PokemonGodWhite — 91/145**

PSDK, Essentials i godotmon nie mogą wygrać bieżącej selekcji z powodu nieprzejścia bramki.
