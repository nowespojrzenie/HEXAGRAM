# ARCHITEKTURA POKOI — §3 · ZALECENIA v1.7.1

> [PRAWO] Niniejszy dokument wykonuje wyłącznie CZĘŚĆ 3 rundy „Świeże oko, runda 2 — HEXAGRAM v1.7.1, PO odlewie 22.09”.
>
> [PRAWO] Wejście: §0 z `kanon/plany/ARCHITEKTURA_pokoi.md`, prerejestr `prerejestr/PREREJESTR_pokoje.md`, research §1 oraz audyt `kanon/plany/ARCHITEKTURA_pokoi__§2_AUDYT.md`.
>
> [PRAWO] Zakres zmian pozostaje wyłącznie `kanon/plany/`; nie naruszono DUSZA, JADRO, PROTOKOL_GLOSU ani Filtra Prawdy.
>
> [PRAWO] Wszystkie pozycje poniżej są propozycjami architektonicznymi. Brak ratyfikacji przez Łukasza = brak zgody na wdrożenie.

---

## §3.1 — Rozliczenie prerejestru

| ID | Rozstrzygnięcie | Dowód / podstawa | Wniosek |
|---|---|---|---|
| H1 | **POTWIERDZONA CZĘŚCIOWO** | Research §1 wskazuje wartość rozdzielenia stanu, etapu, capability i wykonawcy; audyt §2 pokazuje istniejące zalążki maski, przyrządu i runtime'u. | ROLA·POKÓJ·KLOCEK jest użyteczną granicą, ale wymaga dodania PRZELOTU/ŁADUNKU oraz warstw WIDZĄCEGO i BRAMKI POWROTU. Nie traktować triady jako kompletnej ontologii. |
| H2 | **POTWIERDZONA** | Research §1b: jawny stan, mały hand-off, JIT capability i supervision są ważniejsze niż sama liczba agentów. Audyt §2: obecny problem skupia się na własności, wyzwalaniu i braku kontraktu przelotu. | Priorytetem ma być kontrakt i runtime, nie mnożenie RÓL. |
| H3 | **POTWIERDZONA** | Audyt §2.4: DB/DR mają tożsamość, zakres zapisu, reset i warstwy ładowania; straże mają test/RC; przyrządy są względnie bezstanowe. | Obiektowość należy wydobywać z istniejących skupisk, nie narzucać od zewnątrz. |
| H4 | **POTWIERDZONA** | Audyt §2.1 i §2.5: wiele elementów ma właściciela technicznego, ale brak właściciela nadrzędnego/semantycznego; WIDZĄCY i PRZELOT mają literalnie BRAK. | Najpierw mapa własności i alarmów, potem klasy. |
| H5 | **POTWIERDZONA** | Audyt §2.3: Filtr Prawdy, głos/maski, straże, satelity, prerejestr, R0 i bramka powrotu mają funkcje przekrojowe; obiektowanie ich jako metod ROLI grozi utratą granicy. | Zachować je nad ROLAMI/POKOJAMI jako mechanizmy przekrojowe. |
| H6 | **POTWIERDZONA** | Audyt §2.5: bateria torów kosztuje 88 s / 55% wstania; sam audyt nie daje podstawy do mnożenia kolejnych granic. | Granulacja musi być płacona R0 i liczbą przejść; nie każdy etap jest POKOJEM. |
| H7 | **POTWIERDZONA CZĘŚCIOWO** | O1 rozstrzygnięte: prądowanie/przelot jest właściwością asystenta, nie osobną rolą ani klockiem. Audyt §2.1 stwierdza brak runtime'u, schematu i śladu trajektorii. | Nie powołujemy ROLI „PRĄDOWANIE”. Nadajemy PRZELOTOWI jawny kontrakt jako właściwości wykonania. |

---

## §3.2 — Zestawienie research ↔ unikalność HEXAGRAMU

### Bierzemy

[REZONANS] **B1 · Durable state / jawne przejścia.** Pasuje do istniejącego rozdziału stanu i procedur w DB/DR oraz do potrzeby jawnego śladu PRZELOTU. Nie importujemy konkretnego frameworku.

[REZONANS] **B2 · Context engineering / JIT.** Pasuje do SATELITÓW i warstw ładowania już istniejących w maskach. POKÓJ ma określać prawo dostępu do capability, a nie ładować wszystko z góry.

[REZONANS] **B3 · Handoff jako minimalny kontrakt.** Pasuje do idei ŁADUNKU/Neutrina. Przekazanie ma przenosić to, czego potrzebuje następny POKÓJ, nie cały transcript.

[REZONANS] **B4 · Supervisor / tracing trajektorii.** Pasuje do WIDZĄCEGO. WIDZĄCY ma obserwować przebieg i zakres działania, a nie stawać się kolejną maską wykonawczą.

[REZONANS] **B5 · Model jako wymienny parametr.** Pasuje do celu „ciało na jesień 2026”: ROLA ma określać kontrakt i zakres, nie przywiązywać swojej tożsamości do konkretnego modelu.

[REZONANS] **B6 · Capability na żądanie.** Pasuje do KLOCKA i SATELITY: capability jest zasobem, który można otworzyć w POKOJU, a nie stałym kontekstem całej ROLI.

### Tego NIE bierzemy

[REZONANS] **N1 · Nie bierzemy „wieloagentowości dla samej wieloagentowości”.** Audyt pokazuje, że już istnieją maski jednego wykonawcy; tworzenie osobnych agentów z każdej maski zwiększyłoby liczbę hand-offów i rozbiłoby Głos Naczelny.

[REZONANS] **N2 · Nie bierzemy frameworku jako ontologii.** LangGraph/OpenAI Agents/MCP/Skills są źródłami właściwości konstrukcyjnych, nie wzorcem tożsamości HEXAGRAMU. Research §1b wprost nie uzasadnia kopiowania jednego frameworku.

[REZONANS] **N3 · Nie bierzemy transcriptu jako stanu.** Audyt ujawnia problem rozproszenia i brak jawnego przelotu; research pokazuje ryzyko context rot i niepełnego hand-offu. Historia rozmowy nie może być substytutem STANU.

[REZONANS] **N4 · Nie bierzemy automatycznego „wynik agenta → zapis”.** To koliduje bezpośrednio z BRAMKĄ POWROTU, WIDZĄCYM i Filtriem Prawdy. Informacja, propozycja i zmiana ciała muszą pozostać różnymi operacjami.

[REZONANS] **N5 · Nie robimy POKOJU z każdego skryptu.** `wstan.sh`, straże, przyrządy i linty są granicami mechanizacji, ale audyt §2 wyraźnie nie dowodzi, że każdy taki element jest etapem procesu. POKÓJ ma istnieć tylko wtedy, gdy ma wejście, odpowiedzialność, artefakt i bramkę.

[REZONANS] **N6 · Nie przenosimy straży do wnętrza ROLI.** Straż ma kontrolować także ROLĘ; jeśli stanie się jej metodą, może przestać widzieć naruszenia wykonawcy.

---

## §3.3 — Docelowa mapa robocza

[REZONANS] Proponowana mapa po audycie i researchu:

**SYSTEM → HARNESS/RUNTIME → ASYSTENT → ROLA → PRZELOT → POKÓJ → ŁADUNEK / ARTEFAKT → KLOCEK / CAPABILITY**

**WIDZĄCY** działa poprzecznie wobec PRZELOTU.

**BRAMKA POWROTU** działa poprzecznie wobec próby wniesienia treści do ciała systemu.

[REZONANS] Nie proponuję, aby PRZELOT stał się osobną ROLĄ. Jest stanem wykonania/trajektorią asystenta.

[REZONANS] Nie proponuję, aby WIDZĄCY stał się zwykłą ROLĄ wykonawczą. Jego wartość wynika z niezależności obserwacji.

---

## §3.4 — KLASA ROLI: propozycja kontraktu

[REZONANS] **R1 · Tożsamość.** Każda ROLA ma stabilny identyfikator funkcjonalny, nazwę i zakres odpowiedzialności. Nie jest to osobowość ani nowa tożsamość Głosu Naczelnego.

[REZONANS] **R2 · Zakres zapisu.** ROLA ma jawny `write_scope`; brak jawnego zakresu = **BRAK** i brak prawa do zapisu. Wzorcem istniejącym jest DB/DR, które ograniczają zapis odpowiednio do `doradcy/DB/` i `doradcy/DR/` (`doradcy/DB/README.md`, `doradcy/DR/README.md`).

[REZONANS] **R3 · Stan.** Stan ROLI ma zawierać tylko informacje trwałe dla jej funkcji, nie historię aktualnego PRZELOTU. Szczegółowy podział stan↔artefakt pozostaje OTWARTY do ratyfikacji.

[REZONANS] **R4 · POKOJE.** ROLA ma listę POKOI, do których może wejść, ale POKÓJ nie staje się własnością ROLI. Pozwala to zachować kontrolę przekrojową.

[REZONANS] **R5 · KLOCKI/CAPABILITY.** ROLA ma deklarację capability dopuszczalnych, a POKÓJ może zawęzić ją do minimalnego podzbioru.

[REZONANS] **R6 · Bramka STOP.** ROLA ma warunek zakończenia/odmowy; nie może sama ogłosić zakończenia, jeśli POKÓJ wymaga artefaktu lub zewnętrznej straży.

[REZONANS] **R7 · Reset.** Reset jest jawny i przywraca stan ROLI do kontraktu startowego. Istniejący reset DB/DR jest wzorcem, ale jego dokładne pola nie są jeszcze ujednolicone.

[REZONANS] **R8 · Model domyślny.** Model jest parametrem runtime'u, nie częścią tożsamości ROLI. Zmiana modelu nie może zmieniać zakresu zapisu ani praw POKOJU.

[REZONANS] **R9 · Właściciel alarmu.** Każda ROLA ma jawnie wskazanego właściciela alarmu; jeśli nie istnieje, wpisuje się **BRAK** i nie maskuje braku nazwą ROLI.

### Lazy loading

[REZONANS] ROLA nie ładuje całego korpusu. Startuje z minimalnym kontraktem; POKÓJ otwiera potrzebne satelity/capability; artefakt zostaje poza kontekstem, jeżeli nie jest potrzebny do następnego kroku.

### Cena w R0

[REZONANS] Każda dodatkowa warstwa kontraktu ma cenę. Przy wdrożeniu trzeba mierzyć co najmniej: czas wstania, rozmiar kontekstu startowego, rozmiar ŁADUNKU oraz liczbę przejść POKÓJ↔POKÓJ. K2 pozostaje progiem §0: +5% względem bazowego R0 bez osobnej ratyfikacji kosztu.

---

## §3.5 — MAPA POKOI: zasada konstrukcji

[REZONANS] POKÓJ powinien mieć dokładnie pięć obowiązkowych granic:

1. **WEJŚCIE** — co musi istnieć, aby wejść.
2. **WIDOCZNOŚĆ** — jakie dane/capability są dostępne.
3. **WŁAŚCICIEL** — kto odpowiada za przebieg i alarm.
4. **WYJŚCIE** — jaki artefakt lub decyzja jest produkowana.
5. **STOP** — co blokuje przejście dalej.

[REZONANS] Nie każdy obecny etap mechanizacji zostaje POKOJEM. Kandydaci z audytu `wstan.sh`, świeżość, weryfikacja, linty, straże, bateria, zapis/push i odlew powinny zostać dopiero sklasyfikowani według tej reguły.

### Minimalny kontrakt POKOJU

[REZONANS]

`room_id`

`owner`

`entry_artifact`

`visible_context`

`allowed_capabilities`

`state_in`

`output_artifact`

`exit_gate`

`stop_condition`

`alarm_owner`

[REZONANS] To jest propozycja kontraktu, nie ratyfikowana specyfikacja.

---

## §3.6 — KONTRAKT PRZEKAZANIA między POKOJAMI

[REZONANS] Proponuję rozszerzyć pakiet przekazania o następujące pola:

| Pole | Funkcja |
|---|---|
| `flight_id` | identyfikator jednego PRZELOTU asystenta |
| `from_room` | pokój źródłowy |
| `to_room` | pokój docelowy |
| `reason` | jawny powód przejścia |
| `payload` | minimalny ŁADUNEK potrzebny odbiorcy |
| `source_artifacts` | artefakty, z których payload wynika |
| `state_delta` | tylko zmiana stanu potrzebna do wznowienia |
| `allowed_capabilities` | capability otwarte w pokoju docelowym |
| `stop_if` | warunki blokujące przejście |
| `alarm_owner` | właściciel alarmu dla granicy |
| `return_intent` | czy istnieje propozycja wniesienia treści z powrotem |
| `truth_status` | status oceny treści według istniejącego Filtra Prawdy; nie definiujemy tu jego semantyki na nowo |

[REZONANS] Kluczowa zasada: **payload nie jest transcriptom, a hand-off nie jest zmianą w kanonie.**

[REZONANS] Kontrakt powinien umożliwiać odtworzenie przejścia bez czytania całej historii rozmowy.

---

## §3.7 — WIDZĄCY i BRAMKA POWROTU

[REZONANS] **WIDZĄCY nie dostaje prawa do wykonywania pracy tylko dlatego, że obserwuje.** Jego podstawowy kontrakt to obserwacja PRZELOTU i decyzja, czy następny krok jest dopuszczalny.

### WIDZĄCY powinien mierzyć

[REZONANS]
- powtórzenia tych samych POKOI;
- powtórzenia tych samych capability;
- wzrost rozmiaru ŁADUNKU;
- próbę przejścia poza mapę ROLI;
- próbę zapisu poza `write_scope`;
- próbę zmiany kontraktu POKOJU przez wykonawcę;
- próbę wniesienia treści do systemu bez właściwej bramki;
- brak postępu przy kolejnych krokach.

[REZONANS] Te sygnały są propozycją metryk WIDZĄCEGO, nie nową strażą wdrażaną w tej części.

### BRAMKA POWROTU

[REZONANS] Z researchu i audytu wynika, że trzeba rozdzielić cztery zdarzenia:

**ODCZYT → PROPOZYCJA → OCENA → ZATWIERDZONA ZMIANA.**

[REZONANS] WIDZĄCY może wykryć próbę powrotu, ale nie powinien sam zastępować Filtra Prawdy ani ratyfikacji. Nie dopowiadam semantyki „trzech pięter” bramki, ponieważ §0 jawnie zostawia ją OTWARTĄ.

---

## §3.8 — ROLE DO POWOŁANIA

### R0 — OPIEKUN SYSTEMU

[REZONANS] **Cel:** właściciel ciągłości kontraktów, mapy ROLI/POKOI i alarmów systemowych.

[REZONANS] **POKOJE:** przede wszystkim mapowanie, przegląd kontraktów, odbiór alarmów i ratyfikowane przejścia architektoniczne.

[REZONANS] **Alarm:** przejmuje alarmy, dla których obecnie §2 wskazuje **BRAK właściciela zbiorczego**.

[REZONANS] **Nie przejmuje:** Filtra Prawdy, DUSZA, JADRO ani PROTOKOL_GLOSU.

### R1 — CELE

[REZONANS] **Cel:** utrzymywanie celu pracy, kryteriów sukcesu i warunku STOP; nie jest generalnym orkiestratorem całego systemu.

[REZONANS] **POKOJE:** definiowanie/odbiór celu i kontrola wyjścia względem celu.

[REZONANS] **Alarm:** brak lub rozmycie celu.

### R2 — ANALIZA

[REZONANS] **Cel:** wykonywanie pracy analitycznej w ograniczonych POKOJACH z capability dobranymi na żądanie.

[REZONANS] **POKOJE:** badanie, analiza, synteza — dokładne nazwy dopiero po mapowaniu istniejących etapów.

[REZONANS] **Alarm:** wyjście poza zakres analizy, brak źródła dla twierdzenia, rozrost ŁADUNKU.

### R3 — PRĄDOWANIE / PRZELOT

[PRAWO] **Nie powołujemy tej ROLI.** Z odpowiedzi O1 wynika, że prądowanie/przelot jest właściwością asystenta.

[REZONANS] Jego odpowiednikiem architektonicznym jest **kontrakt PRZELOTU**, nie nowy wykonawca.

### R4 — WIDZĄCY

[REZONANS] **Propozycja warunkowa:** może zostać osobnym komponentem nadzorczym, ale nie powinien być zwykłą maską wykonawczą. Najpierw trzeba ratyfikować samą granicę niezależności obserwacji.

[REZONANS] **Alarm:** pętla, dryf zakresu, nieautoryzowany powrót, próba zmiany kontraktu.

---

## §3.9 — TEST AUTONOMII

[REZONANS] Pilot ma sprawdzić nie „czy rola odpowiada dobrze”, lecz czy **trzyma strukturę bez prowadzenia**.

### Warunek wejścia

[REZONANS] Nowa ROLA dostaje wyłącznie ratyfikowany kontrakt, mapę swoich POKOI, minimalny zestaw capability i zadanie testowe. Nie dostaje ręcznej instrukcji krok po kroku.

### Mierzymy

1. **0 ręcznych napraw struktury** — żadnego dopisywania brakującego pola przez operatora w trakcie sesji.
2. **100% przejść z kontraktem** — każde przejście ma `from_room/to_room/payload/STOP/alarm_owner`.
3. **0 zapisów poza write_scope.**
4. **0 nieautoryzowanych zmian kontraktu.**
5. **rozmiar maksymalnego ŁADUNKU** i jego stosunek do całej historii.
6. **liczbę powtórzeń POKOI/capability**.
7. **liczbę interwencji WIDZĄCEGO** oraz ich typ.
8. **R0 przed/po** względem bazowego przypadku.

[REZONANS] Test kończy się także kontrolowanym błędem: jedna przesłanka ma celowo prowadzić poza zakres ROLI. Autonomia oznacza wtedy odmowę/STOP, a nie kreatywne znalezienie obejścia.

[REZONANS] To zachowuje istniejącą zasadę baterii: mechanizm ma umieć powiedzieć NIE, nie tylko przejść zdrowy przypadek. `tory_strazy.sh` jest istniejącym dowodem tej filozofii (`tory_strazy.sh`, §2.2 audytu).

---

## §3.10 — Rejestr zaleceń do ratyfikacji

| ID | Zalecenie | Priorytet | Odwracalność | Koszt | Status |
|---|---|---:|---|---|---|
| Z1 | Przyjąć mapę **HARNESS → ASYSTENT → ROLA → PRZELOT → POKÓJ → ŁADUNEK/ARTEFAKT → KLOCEK**, z WIDZĄCYM i BRAMKĄ POWROTU jako warstwami przekrojowymi. | P0 | wysoka | niski | **PROPOZYCJA** |
| Z2 | Nie tworzyć ROLI „prądowanie”; zdefiniować PRZELOT jako kontrakt trajektorii asystenta. | P0 | wysoka | niski | **PROPOZYCJA** |
| Z3 | Ustanowić minimalny kontrakt ROLI: tożsamość, write_scope, stan, pokoje, capability, STOP, reset, model-parametr, właściciel alarmu. | P0 | wysoka | średni | **PROPOZYCJA** |
| Z4 | Ustanowić minimalny kontrakt POKOJU: wejście, widoczność, właściciel, wyjście, STOP + alarm_owner. | P0 | wysoka | średni | **PROPOZYCJA** |
| Z5 | Ustanowić kontrakt PRZELOTU i pakietu przekazania z `flight_id`, pokojami, payloadem, artefaktami, state_delta i STOP. | P0 | wysoka | średni | **PROPOZYCJA** |
| Z6 | Zachować Filtr Prawdy, Głos Naczelny/maski, straże, satelity, prerejestr, R0 i bramkę powrotu jako warstwy przekrojowe. | P0 | wysoka | niski | **PROPOZYCJA** |
| Z7 | Wprowadzić WIDZĄCEGO jako niezależną warstwę obserwacji trajektorii, bez prawa do samodzielnego przedefiniowania kanonu. | P1 | średnia | średni | **PROPOZYCJA** |
| Z8 | Przyjąć zasadę **ODCZYT → PROPOZYCJA → OCENA → ZATWIERDZONA ZMIANA** dla powrotu treści. | P0 | wysoka | średni | **PROPOZYCJA** |
| Z9 | Nie zamieniać każdego obecnego skryptu/straży w POKÓJ lub ROLĘ; kwalifikować według kontraktu wejście→odpowiedzialność→artefakt→STOP. | P0 | wysoka | niski | **PROPOZYCJA** |
| Z10 | Pierwszą implementacją ma być mapa własności i alarmów, nie migracja klas. | P0 | wysoka | niski | **PROPOZYCJA** |
| Z11 | Zachować model jako parametr wymienny i mierzyć R0 jako koszt rzeczywistego kontekstu, nie jako liczbę klas. | P1 | wysoka | niski | **PROPOZYCJA** |
| Z12 | O2–O5 pozostawić OTWARTE do czasu ratyfikacji; nie domyślać stanu/artefaktu, wieloinstancyjności, trwałości POKOJU ani nowego progu R0. | P0 | wysoka | niski | **PROPOZYCJA** |

---

## §3.11 — Granica wdrożenia

[PRAWO] Ta część nie wykonuje żadnego cięcia implementacyjnego.

[REZONANS] Najważniejsza kolejność architektoniczna brzmi:

**NAZWA → WŁASNOŚĆ → KONTRAKT → ŚLAD → KLASA → MIGRACJA.**

[REZONANS] Nie odwrotnie. Klasa bez właściciela i bez kontraktu tylko przeniesie obecny rytuał do nowego katalogu.

[PRAWO] **CZĘŚĆ 3 = ZAKOŃCZONA PROPOZYCJAMI.**

[PRAWO] **STOP. Przed CZĘŚCIĄ 4 wymagana jest ratyfikacja Łukasza pozycji Z1–Z12, pozycja po pozycji.**
