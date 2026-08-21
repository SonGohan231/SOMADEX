# SOMADEX — MICRO-PoC REPORT

Data: 2026-08-21 UTC  
Fundament: `rh-hideout/pokeemerald-expansion` `bb6f399bce71db7e82a4bfa40e72b29498ef1de6`  
Wynik bramki: **CONDITIONAL PASS**  
Stan procesu: **PHASE 1 zakończona; pełna migracja nie została wykonana.**

## Werdykt

Wymagany loop wykonuje się od uruchomienia do twardego restartu i odczytu zapisu. Nie znaleziono strukturalnej przeszkody dla map, eventów, własnych gatunków, ruchów ani zapisu. Fundament może przejść do osobnego **PHASE 2 — FOUNDATION LOCK**, lecz niniejszy PoC nie zatwierdza jeszcze skalowania zawartości.

Wynik jest warunkowy, ponieważ ekran tytułowy, część angielskiego UI, nazwa gracza i tła walki pochodzą jeszcze z upstreamu; tył Luzika jest technicznym lustrzanym wariantem seeda, a test na fizycznym telefonie pozostaje do wykonania. Są to ograniczone zadania content/polish, nie defekty rdzenia.

## Macierz akceptacji

| # | Kryterium | Wynik | Dowód runtime |
|---:|---|---|---|
| 1 | Boot do własnego obszaru | PASS | Start bezpośrednio na oryginalnym układzie 20×20 `VELA TEST` |
| 2 | Własna postać i kolizja | PASS | Pozycja zmienia się 10,15 → 10,16; ściana/obiekt blokuje ruch; użyty seed SOMADEX |
| 3 | NPC/event/dialog | PASS | Mira wyświetla polski dialog i ustawia `FLAG_MET_MIRA` |
| 4 | Encounter zone | PASS | Pole zdarzenia uruchamia spotkanie |
| 5 | Własny Somaskan i realny art/data | PASS | Dziki Luzik poziomu 3; front, ikona, paleta i dane z seeda SOMADEX |
| 6 | Wejście do walki | PASS | Pełne przejście świata do sceny walki |
| 7 | Wykonanie ruchu | PASS | `Impuls Warstw.` (ELECTRIC, 45 mocy, 96% trafienia, 20 PP) wykonany wielokrotnie |
| 8 | Rozstrzygnięcie | PASS | Dziki Luzik pokonany, bez soft-locka |
| 9 | Powrót do świata | PASS | Powrót na 10,16 z drużyną i flagą |
| 10 | Save/restart/load | PASS | Natywny save, drugi proces mGBA, przywrócone 10,16, drużyna=1 i dialog Miry „Flaga przetrwała w zapisie.” |

## Kontrole jakości

| Kontrola | Wynik | Uwagi |
|---|---|---|
| Brak crasha/blokera | PASS | Pełny przebieg i ponowne uruchomienie zakończone |
| Spójna skala mapy/postaci/walki | PASS dla bramki | Natywne 240×160; czytelne sylwetki i hitboxy |
| Czytelność tekstu | PASS dla bramki | Polski tekst bez znaków diakrytycznych z powodu obecnego charmapu |
| Brak uniknionych placeholderów | CONDITIONAL | Użyto dostępnych seedów; pozostają elementy upstreamu i techniczny back-sprite |
| Udokumentowany pipeline | PASS | Skrypty mapy i assetów oraz instrukcja aplikacji/builda |
| Powtarzalny build | PASS | Czysty przypięty upstream + patch + generatory + `make` |
| Telefon | PENDING POLISH QA | Docelowy ROM GBA działa w emulatorze; fizyczne urządzenie nie było dostępne |

## Artefakty i pomiary

- Finalny lokalny ROM testowy: 33,554,432 B; SHA-256 `f1ca18cfcf62ec3d498430e92afe443df46ffa86f967ce2278217e1c16e3ba7b`.
- Plik zapisu po teście: 131,088 B; SHA-256 `cf67cfea0c0dd10d0bf7478b066546bea3e20938a6b054a87f4ea590a3699455`.
- Pamięć po linkowaniu: EWRAM 226,588/262,144 B (86.44%), IWRAM 28,392/32,768 B (86.65%), ROM 26,514,832/33,554,432 B (79.02%).
- Toolchain: xPack GNU Arm Embedded GCC 14.2.1-1.1; mGBA 0.10.5; ImageMagick 6.9.12-98.
- Symbole sprawdzane przez runner: `gSaveBlock1Ptr=0x030051d4`, `gPartiesCount=0x02031bf8`.

ROM i save są wyłącznie dowodami lokalnymi i nie są publikowane. Pakiet źródłowy zawiera tylko własne skrypty, dokumentację i diff wymagający samodzielnego pobrania przypiętego upstreamu.

## Zakres PoC

- oryginalna kompozycja polany `VELA TEST` z natywnymi metatile'ami i kolizją;
- Mira, pierwszy/powtórny dialog i trwała flaga;
- Luzik w technicznie przepiętym slocie Treecko, tylko w tabeli spotkań testowego obszaru;
- starter Luzik poziomu 5 i dziki Luzik poziomu 3;
- ruch `Impuls Warstwowy` w technicznie przepiętym slocie Pound;
- `Kula Splotu` w technicznie przepiętym slocie Poke Ball;
- generator mapy, generator grafiki oraz headless runner mGBA.

Techniczne przepięcie istniejących identyfikatorów jest świadomym ograniczeniem najmniejszego PoC. W produkcji gatunki, ruchy i przedmioty mają dostać własne identyfikatory i w pełni data-driven pipeline.

## Otwarta lista warunków przed skalowaniem

1. Zastąpić tytuł, branding, angielskie komunikaty, domyślną nazwę gracza, tła/UI i pozostałe widoczne treści Pokémon.
2. Wykonać prawdziwy back-sprite Luzika i zatwierdzony komplet animacji; nie skalować 150 form z technicznego seeda.
3. Przeprowadzić ręczne QA na fizycznym telefonie w co najmniej jednym emulatorze Android.
4. Zmierzyć budżet palet/ROM/RAM po małej pionowej próbce, nie ekstrapolować z jednego gatunku.
5. Utrzymać politykę dystrybucji patch-only i przeprowadzić osobny przegląd prawny przed publicznym wydaniem.

## Następny dozwolony krok

**PHASE 2 — FOUNDATION LOCK** z przypięciem upstreamu, polityką patch-only, kontraktem danych i listą treści do usunięcia. Dopiero potem można rozpocząć mały Phase 3 Vertical Slice. Pełna migracja ani masowa produkcja treści nie została rozpoczęta.
