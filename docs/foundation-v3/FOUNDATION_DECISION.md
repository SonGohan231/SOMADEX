# SOMADEX — FOUNDATION DECISION

Data: 2026-08-21 UTC  
Stan maszyny procesu po tej decyzji: **PHASE 1 — MICRO-PoC; fundament nie jest jeszcze zablokowany.**

## CHOSEN FOUNDATION

**`rh-hideout/pokeemerald-expansion`, gałąź `master`, przypięta do commita `bb6f399bce71db7e82a4bfa40e72b29498ef1de6`.**

Wybrana platforma wynikowa dla PoC: **ROM GBA uruchamiany w emulatorze**.

Dystrybucja projektu poza prywatnym testem: **wyłącznie własne źródła/zasoby oraz patch BPS/UPS wymagający legalnie pozyskanego zgodnego ROM-u bazowego. Nie publikować gotowego ROM-u zawierającego cudzą zawartość.**

## Dlaczego ten fundament wygrał

1. Ma już pełny, produkcyjnie sprawdzony loop: świat, mapy, eventy, NPC, encountery, walka, łapanie, drużyna, EXP, ewolucja i save.
2. Jego natywny workflow map/eventów rozwiązuje dokładnie problem, którego obecny SOMADEX nie rozwiązał: prawdziwe mapy i warstwy zamiast ręcznie rysowanych ekranów oraz map jako ciągów znaków.
3. Emulator GBA jest wygodną i akceptowaną przez użytkownika ścieżką telefonu; brak Android SDK u użytkownika nie blokuje gry.
4. `pokeemerald-expansion` ma aktywny rozwój, narzędzia Porymap/Poryscript, dokumentację, debug menu i więcej współczesnych mechanik niż czysty FireRed.
5. W Micro-PoC nie trzeba od nowa wymyślać systemów, które obecny prototyp tylko częściowo symuluje. Test dotyczy głównie przenośności IP, assetów, mapy, tekstu, builda i save.

Wybór nie oznacza zgody na prosty reskin. Fundament ma dostarczyć technikę; produkt widoczny dla gracza ma zostać systematycznie od-Pokémonizowany.

## Największe ryzyka

| Ryzyko | Wpływ | Odpowiedź w PoC |
|---|---|---|
| Niejasność prawna kodu/dekompilacji i cudzej zawartości | Krytyczny | Patch-only, lista zależności, żadnego publicznego ROM-u, usunięcie wszystkich widocznych treści Pokémon z PoC w zakresie testowanej ścieżki |
| Lokalnie brak toolchainu ARM i nagłówków `libpng` | Wysoki | Reprodukowalny toolchain w CI/kontenerze; przypięte wersje; build log i hash ROM-u |
| 255 JPG to ilustracje koncepcyjne, nie sprite’y | Wysoki | PoC używa istniejących transparentnych 48×48 seedów Luzika i dostępnego sprite-sheetu gracza/NPC; dokumentuje konwersję do ograniczeń GBA |
| Ograniczenia GBA: palety, rozdzielczość, ROM/RAM | Wysoki | Jeden Somaskan, jeden ruch i mały obszar; pomiar ROM/RAM i kontrola czytelności |
| Koszt pełnego usunięcia Pokémon content | Krytyczny dla pełnej produkcji | PoC ma zmierzyć listę zależności i rzeczywisty koszt wymiany; porażka wraca do PHASE 0 |
| Wymagane zaawansowane systemy SOMADEX mogą przekroczyć limity | Średni/wysoki | Nie implementować ich teraz; sprawdzić tylko data-driven dodanie gatunku/ruchu i miejsce na rozszerzenia |

## Co zostaje użyte z obecnego SOMADEX

- potwierdzone nazwy i dane 50 rodzin oraz 150 form jako katalog projektowy;
- autorskie Somaskany i ich motywy, zaczynając od Luzika;
- transparentne seed-sprite’y 48×48 dla Luzika, Bocznika, Milimika, Wahlika, Nucika i Dudnika;
- sprite-sheet gracza 192×24 oraz NPC Mira 48×24 jako materiał wejściowy PoC;
- teksty świata Vela, postać Miry i kierunek fabularny Kronik Rezonansu;
- zasady typów, ruchów, statusów, progresji, pięciu ścieżek trenera, wyposażenia, questów i REZONANSU jako backlog/specyfikacja;
- zweryfikowane dane projektowe i nazewnictwo, po ręcznym przeglądzie zgodności;
- część testów jako źródło kontraktów zachowania, nie jako kod runtime GBA.

## Co zostaje odrzucone jako fundament

- `FOUNDATION_LOCK.md` i stare etykiety Foundation 1.0/Alpha jako autorytet;
- ręczny renderer świata i UI oparty na `_draw_*`;
- mapy 15×23 kodowane ciągami liter;
- stały panel sterowania zajmujący dużą część pionowego ekranu;
- proceduralne/placeholderowe grafiki uznawane za ukończone animacje;
- obecny układ ekranów walki i przeładowane menu;
- założenie APK-first i automatyczna lojalność wobec Godota;
- deklaracje liczby systemów/animacji bez wizualnej weryfikacji runtime.

Repo Godot pozostaje zamrożonym źródłem danych, testów i assetów do czasu wyniku PoC. Nie będzie dalej naprawiane równolegle.

## Dokładny plan MICRO-PoC

PoC ma być osobnym, małym forkiem przypiętego `pokeemerald-expansion`, bez migracji całej gry.

1. **Build baseline** — uruchomić przypięty upstream i uzyskać powtarzalny `.gba`; zapisać toolchain, commit, log, rozmiar i SHA-256.
2. **Obszar Vela Test** — utworzyć jedną własną małą mapę/room z wyraźnym landmarkiem, warstwami, kolizją, wejściem/wyjściem i polem encounter.
3. **Własny gracz** — skonwertować dostępny sprite-sheet trenera SOMADEX do wymagań GBA; sprawdzić cztery kierunki i kolizję.
4. **Mira/event** — wstawić własny NPC Mira, dialog po polsku i trwałą flagę `FLAG_MET_MIRA`.
5. **Luzik** — dodać własny wpis gatunku, nazwę, podstawowe statystyki, seed front/back, ikonę i paletę; nie używać nazwy ani grafiki gatunku Pokémon w testowanej ścieżce.
6. **Ruch** — dodać jeden własny ruch `IMPULS WARSTW` z prostym, czytelnym efektem i danymi.
7. **Encounter** — tabela obszaru ma wywoływać tylko Luzika w polu testowym.
8. **Battle** — wejść do walki, użyć `IMPULS WARSTW`, rozstrzygnąć walkę, wrócić do świata bez utraty pozycji i flagi Miry.
9. **Save/load** — zapisać po powrocie, zrestartować emulator/ROM, wczytać i potwierdzić flagę, pozycję oraz stan drużyny/zdarzenia.
10. **QA telefonu** — uruchomić ROM w emulatorze Android, sprawdzić czytelność, sterowanie, tempo przejść i brak blokera.
11. **Pipeline** — opisać dokładne dodanie mapy, eventu, Somaskana i ruchu oraz wygenerować `POC_REPORT.md`.

## Kryterium decyzji po PoC

- **PASS**: wszystkie 10 kroków funkcjonalnych z `MICRO_POC_ACCEPTANCE.txt`, reprodukowalny build i brak strukturalnego blokera dla własnych treści.
- **CONDITIONAL PASS**: wyłącznie drobne defekty polish, z konkretną listą poprawek.
- **FAIL**: brak pełnego loopu, niestabilny build/save, nierozwiązywalny pipeline assetów lub wymiany cudzej zawartości, albo ograniczenia GBA sprzeczne z SOMADEX.

## Zakaz pełnej migracji

**Pełna migracja SOMADEX do GBA nie jest zatwierdzona.** Ta decyzja zatwierdza wyłącznie wykonanie Micro-PoC w `pokeemerald-expansion`. Foundation Lock może powstać dopiero po wyniku PASS lub CONDITIONAL PASS i po ocenie rzeczywistego ROM-u w emulatorze.
