# SOMADEX — KANON PRODUKTOWY I INWENTARZ USTALEŃ

Data rekonsyliacji: 2026-08-21 UTC  
Źródła: aktualna dyrektywa V3, `PRODUCT_VISION.txt`, historia planowania, zweryfikowane dane bieżącego repozytorium i paczka 255 grafik.  
Zasada: poniżej oddzielono **ustalony cel/backlog** od **zweryfikowanego wykonania**. Stare etykiety Godot/Foundation/Alpha nie stanowią obecnie autorytetu implementacyjnego.

## 1. Tożsamość gry

- Oryginalny, jednoosobowy, turowy monster-collector RPG w retro pixel-arcie, wygodny na telefonie.
- Wzorzec jakości: czytelność, tempo, mapy/eventy i prezentacja klasycznych gier GBA/DS; bez kopiowania map, postaci, nazw, fabuły, UI ani finalnych assetów Pokémon.
- Rdzeń pętli: eksploracja → NPC/eventy → odkrycia → spotkanie → walka/chwyt → drużyna → fabuła/świat → rozwój Somaskana i trenera.
- Finalny świat, historia, stworki, grafika, nazwy, mechaniki i UI należą do IP SOMADEX.
- Platforma wynikowa może być ROM-em GBA uruchamianym w emulatorze; natywne APK nie jest wymagane.

## 2. Zakres docelowy — backlog, nie stan ukończenia

| Obszar | Ustalony cel |
|---|---:|
| Główna fabuła | 18–25 h |
| Spokojne przejście | 25–35 h |
| Pełniejsza zawartość | 35–50 h |
| Miasta pierwszego regionu | 8–10 |
| Obszary terenowe | 12–18 |
| Główni bossowie | co najmniej 8 |
| Fabularni NPC | 30–50 |
| Rodziny / formy pierwszej wersji | 50 / 150 (3 formy na rodzinę) |
| Ruchy | 180–220 |
| Pasywki | co najmniej 50 |
| Statusy / kombinacje | 15–20 / 20–30 |
| Talenty trenera | 100; 5 ścieżek × 20; limit poziomu 50 |
| Ekwipunek / przedmioty / gadżety bojowe | 80–120 / co najmniej 100 / 25–40 |
| Drużyna / aktywne ruchy / ruch specjalny | 6 / 4 / 1 |

Architektura ma umożliwiać późniejsze 51., 100. czy 500. stworzenie przez dane i grafiki, bez przepisywania systemu walki. Dyrektywa zabrania masowego generowania backlogu przed zaakceptowanym vertical slice.

## 3. Świat i kampania regionu Vela

### Miasta

Vela, Brama Orin, Marea, Ferrum, Nivra, Lumen, Aster, Koral, Zenith.

### Obszary terenowe

Obrzeża Veli, Szlak Rezonansu, Gaj Szeptów, Szkliste Wybrzeże, Jaskinia Echa, Północna Brama, Mokradła Stroików, Linia Ferrum, Elektrownia Cewkowa, Przełęcz Nivra, Głęboki Uskok, Ruiny Lumen, Las Aster, Rafa Koral, Cicha Niecka, Podejście Zenith.

### Kolejność głównej kampanii

Vela i pierwsze próby → Brama Orin/Mokradła → Marea → Linia Ferrum/Ferrum/Elektrownia → Przełęcz Nivra/Nivra/Głęboki Uskok → Ruiny Lumen/Lumen → Las Aster/Aster/Cicha Niecka → Koral/Rafa → Podejście Zenith/Zenith.

### Osiem bossów i ich mechaniki

1. Strażnik Eron — `Próba Warstw`: łamanie stabilności.
2. Mistrzyni Sora — `Przypływ Sory`: cykl przypływu, MOKRY i reakcje prądu/chłodu.
3. Konstruktor AX-7 — `Przeciążenie AX-7`: overclock kosztem własnej stabilności.
4. Warden Hail — `Biała Blokada`: wychłodzenie, zamrożenie i rozkruszenie.
5. Opiekun Sol — `Pamięć Sol`: oznaczanie, odczyt słabości i kontry.
6. Warden Elow — `Korony Elow`: zarodniki, trucizna i regeneracja.
7. Kapitan Veya — `Próba Prądu`: odpływ/przypływ/sztorm i kombinacje.
8. Arcyrezonator Veyr — `Rdzeń Veyra`: trzyfazowy finał pełnego pojedynku trenerów.

### Post-game

Głębie Echa, Laboratorium Rezonansu i Zewnętrzna Rafa; rzadkie formy, dłuższe kombinacje, zadania badawcze i przygotowanie kolejnych regionów.

### Pierwszy mały vertical slice Vela

Fragment Veli + wnętrze + fragment trasy, własne mapy i landmarki, NPC/dialog/event, encounter, walka/chwyt, drużyna, EXP/poziom, save/load i spójne UI/audio/grafika. Historyczny plan Veli zakładał dalej 8–12 dzikich bazowych gatunków, trio startowe z pierwszymi ewolucjami, co najmniej 12 NPC, 4–6 trenerów, rywala, bossa, zadania poboczne, sekret, leczenie i otwarcie dalszej drogi; zakres musi zostać ponownie zatwierdzony po Phase 2.

## 4. Walka i rozwój

- Tryby: standardowy, rezonansowy i pełny pojedynek trenerów.
- Turowe menu docelowe: Atak / Stworki / Plecak / Ucieczka; HP, poziom, statusy, EXP.
- Sekwencje wizualne: wejście, idle, atak, trafienie/flash/shake/particles, zmiana HP, omdlenie, EXP, poziom i ewolucja.
- Typy z aktualnego projektu: REZONANS, ŚLIZG, NAPIĘCIE, OSC, KIERUNEK, TORSJA, STABIL, CZUCIE, WAVE oraz techniczne ELECTRIC, ICE, FIRE i PHYSICAL. Tabela typów ma dawać łagodne przewagi (projektowo około 1.20/0.85), a większa głębia pochodzi ze statusów i reakcji.
- Statusy zapisane w danych: MOKRY, NAŁADOWANY, OPARZENIE, NIESTABILNY, OZNACZONY, ZAKŁÓCONY, UKORZENIONY, PĘKNIĘTA OSŁONA, KRWAWIENIE, WYCHŁODZONY, ZAMROŻONY, POKRYTY ŻYWICĄ, SKUPIONY, REGENERACJA, ZACHWIANIE, CISZA, ZATRUTY, PORAŻONY, DEZORIENTACJA, PODATNY.
- Reakcje obejmują m.in. przewodzenie (MOKRY+ELECTRIC), szok termiczny (MOKRY+ICE), zapłon (ŻYWICA+FIRE), przełamanie/skręcenie pękniętej osłony, rezonans niestabilnego celu, zamrożenie/rozkruszenie, sprzężenie naładowanego pola i atak w podatną gardę.
- W trybach rezonansowych działają zasoby Focus i Stabilność trenera; chwyt i ucieczka są tam wyłączone.

### Rozwój trenera

Pięć ścieżek: Taktyk, Strażnik, Badacz, Technik i Awangarda. Każda ma 20 progów/talentów do poziomu 50. Ich role obejmują tempo i kombinacje, więź/leczenie/ochronę, skan/łowy/chwyt, crafting/gadżety oraz przechwyty/tarcze/kontry. Sześć slotów sprzętu: głowa, strój, rękawice, buty, moduł i relikt.

### Przedmioty i aktywność świata

Moduły chwytu (w Micro-PoC: Kula Splotu), regeneratory, Sonda Vela, komórki rezonansu, materiały, crafting i gadżety. Stary prototyp zawiera katalogi częściowe, lecz docelowe liczby pozostają backlogiem.

## 5. Wszystkie 50 rodzin Somaskanów

Nazwy poniżej są wiernym zapisem danych; diakrytyka i literówki w późnych formach wymagają oddzielnej redakcji, nie cichej zmiany kanonu.

| # | Forma bazowa | Ewolucja I | Ewolucja finalna |
|---:|---|---|---|
| 1 | Luzik | Warstwin | Synkronaut |
| 2 | Bocznik | Slizgogon | Horyzontor |
| 3 | Milimik | Drobnoskok | Kwantomruk |
| 4 | Pufek | Pulsopuch | Falomamut |
| 5 | Wahlik | Oscylot | Fazoryb |
| 6 | Kompasik | Oktantor | Kartografon |
| 7 | Srubik | Torsys | Spiralion |
| 8 | uczek | Obiegnik | Labiryntaur |
| 9 | Kotwiczek | Bramnik | Fundamentor |
| 10 | Nasuch | Echouszek | Sensoryks |
| 11 | Dwumik | Synchroap | Chorogrif |
| 12 | Fazik | Kontrafal | Antyfonix |
| 13 | Tropiciel | Dalekoskok | Sieciowid |
| 14 | Przeskok | Wezowiec | Portalnik |
| 15 | Nucik | Wibrospiew | Rezonar |
| 16 | Petelka | Sprzezyk | Cyberwibr |
| 17 | Dudnik | Fazodud | Interferon |
| 18 | Wirutek | Spirydrz | Galaktylion |
| 19 | Hercek | Akceler | Metronotron |
| 20 | Szewik | Blizgacz | Regenerion |
| 21 | Tchnik | Ruchodmuch | Autonomir |
| 22 | Wedrus | Czujokrok | Flowmancer |
| 23 | Iskrokol | Piezousk | Elektrokoral |
| 24 | Spiriskra | Obwodzik | Helikoswietl |
| 25 | Ciezulek | Zawiasaur | Grawititan |
| 26 | Koysik | Bezwadek | Orbitalos |
| 27 | Kropelka | Osemnik | Hydrainfinity |
| 28 | Mostek | Cisnieniak | Pneumost |
| 29 | Echonerw | Synapsik | Neurogryf |
| 30 | Kafelek | Mozaur | Anatomorf |
| 31 | Cieplik | Termopuls | Solarion |
| 32 | Sekundzik | Lepkoskok | Chronozel |
| 33 | Tuipu | Kanaek | Smok_Szlaku |
| 34 | Gunku | Rolobak | Jadeitowy_Walec |
| 35 | Rouru | Kragap | Cynobrowy_Wir |
| 36 | Naku | Unoszek | Zuraw_Chmur |
| 37 | Chanek | Jednopuls | Medytacyjny_Kilin |
| 38 | Mofu | Ksiezycap | Nefrytowy_Ksiezyc |
| 39 | Anan | Punktuspokoj | Straznik_Qi |
| 40 | Dianek | Igopuch | Gwiezdny_Punktor |
| 41 | Hegus | Metalowa_Brama | Biay_Tygrys_Doliny |
| 42 | Neinek | Ognisty_Straznik | Feniks_Wewnetrznej_Bramy |
| 43 | Zuzu | Ziemiomil | Zoty_Kilin_Ziemi |
| 44 | Taierek | Potokrzew | Zielony_Smok_Drewna |
| 45 | Qiwach | Auralis | Smok_Tysiaca_Wachlarzy |
| 46 | Peciutek | Wuxingon | Chimera_Pieciu_Przemian |
| 47 | Orbitka | Ren_Dun | Taotyczny_Waz_Nieba |
| 48 | Danek | Kotwiczan | Straznik_Dolnego_Pola |
| 49 | Lampik | Uwaznik | Latarnik_Ciszy |
| 50 | Mantrik | Tonolotos | Rezonansowy_Garuda |

## 6. Postacie

### Vela i pierwsze próby

- Mira — przewodniczka, później Rezonatorka Bramy.
- Toma — technik; Lina — mieszkanka; Jaro — kurier; Nela — uczennica.
- Bor — hodowca; Sena — zbieraczka; Ivo — badacz; Eni — kartografka.
- Karo i Vera — trenerzy pierwszych prób; Syl — strażnik gaju; Maro — rybak; Tess — technik terenowy; Orin — opiekun Jaskini Echa.
- Kael — rywal; Rhea — strażniczka Północnej Bramy; Eron — główny strażnik/próba Veli.

### Główni fabularni NPC dalszej kampanii

Alda, Jem, Rilo, Ossa, Korn, Vika, Hev, Meya, Siv, Rin, Eli, Tor, Nami, Dey, Ilya, Oren, Kae, Dr. Sen i Ara — odpowiednio archiwum/medycyna Orin, port Marea, Ferrum/crafting, Nivra, Lumen, Aster, Koral, Zenith i post-game.

### Zapisany roster trenerów kampanii

- Orin/Mokradła/Marea: Nari, Savel, Mira, Yra, Daro, Hesh, Pell, Liva, Keli, Sora.
- Ferrum/Elektrownia: Teren, Nox, Jax, Eris, Bram, Olin, Volt, Mirax, Sorn, AX-7.
- Nivra/Uskok: Iven, Sena, Varr, Rud, Isha, Kess, Ona, Rask, Hail.
- Lumen: Arel, Noe, Ena, Talia, Pax, Veli, Sol.
- Aster: Fenn, Roa, Moss, Mori, Tessan, Lorn, Elow.
- Cicha Niecka/Koral: Siel, Umi, Nemm, Caro, Mirae, Marn, Lune, Perr, Veya.
- Zenith: Rhen, Aeon, Kira, Sey, Ora, Veyr.

Roster istnieje jako dane/historyczny dorobek i podlega migracji oraz quality pass; nie oznacza gotowych map, scen ani finalnych sprite'ów każdej postaci.

## 7. Grafika i animacja

- Paczka V3 ma 255 JPG: 50 plansz rodzin 1800×579, 150 kart form 960×720, 50 miniaturek 420×260 oraz 5 plansz spisu/zagadek. To ilustracje koncepcyjne/reference cards, nie gotowe sprite'y runtime.
- Zweryfikowane realne seedy w starym repo: transparentne 48×48 dla Luzika, Bocznika, Milimika, Wahlika, Nucika i Dudnika; sheet gracza 192×24, Mira 48×24 i tileset 192×24.
- Docelowy standard portretu: 128×128, transparentny, bottom-center, sylwetka około 70–85% wysokości.
- Docelowy zestaw na formę: idle 4, attack 6, hurt 3, faint 5, special/REZONANS 6 = 21 klatek; dla 150 form byłoby 3150 klatek. To cel pipeline'u, nie wykonany zasób.
- Świat: postać i NPC w czterech kierunkach z animacją chodu; realne tilemapy, kolizja, occlusion, warstwy, przejścia, wnętrza i landmarki.
- Walka: osobne front/back, ikony, tła biomów, efekty ruchów/statusów, czyste UI i spójna paleta. Placeholder techniczny nie może być raportowany jako finalna animacja.

## 8. Aktualny stan procesu

- Phase 0: ukończony; zwyciężył `pokeemerald-expansion` 123/145.
- Phase 1: MICRO-PoC zakończony wynikiem CONDITIONAL PASS.
- Godot pozostaje zamrożonym źródłem danych, testów i seedów; jego stary renderer/mapy nie są fundamentem.
- Pełna migracja: **nie rozpoczęta i nadal zabroniona**.
- Następny dozwolony krok: Foundation Lock, a następnie mały produkcyjny Vertical Slice z pełnym quality pass.
