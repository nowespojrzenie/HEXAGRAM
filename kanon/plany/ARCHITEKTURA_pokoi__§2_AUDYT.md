# ARCHITEKTURA POKOI — §2 · AUDYT v1.7.1

> [PRAWO] Audyt wykonano na tagu `v1.7.1` / SHA `6f3c3ca76da9e6204a9e049d4d5a29d298c2d2d9`. Audyt zamknięto przed korzystaniem z researchu jako podstawy oceny systemu.
>
> [PRAWO] Zakres: inwentarz RÓL/etapów/KLOCKÓW, dowody działania, unikalność, zalążki obiektów, punkty bólu. Nie naruszono DUSZA, JADRO, PROTOKOL_GLOSU ani Filtra Prawdy.

---

## §2.1 — Inwentarz: ROLĘ, etapy, klocki

[NOŚNA RAMA] W `v1.7.1` nie istnieje jeszcze jedna deklaratywna tabela ROLA→POKOJE→KLOCKI→WŁAŚCICIEL. Dlatego inwentarz poniżej rozróżnia elementy jawnie nazwane od elementów wyprowadzonych z istniejących plików. Tam, gdzie repo nie wskazuje właściciela, wpisuję **BRAK**.

### ROLA / wykonawca

| Element | Adres | Wywołuje / uruchamia | Przyjmuje | Zostawia | Właściciel |
|---|---|---|---|---|---|
| ORKIESTRATOR | `wstan.sh:1–120` + `README.md` | komenda `bash wstan.sh` | świeże repo, pamięć systemu, stan Git | meldunek wstania + uruchomione mechanizmy | **BRAK jawnej deklaracji właściciela ROLI** |
| DB | `doradcy/DB/README.md` | maska wywoływana w Projekcie Orkiestratora | ciekawość + kontekst projektu na żądanie | zapis wyłącznie do `doradcy/DB/` | Orkiestrator jako byt nadrzędny; właściciel operacyjny zapisu: DB |
| DR | `doradcy/DR/README.md` | maska wywoływana w Projekcie Orkiestratora | ciekawość + proces rozwojowy na żądanie | zapis wyłącznie do `doradcy/DR/` | Orkiestrator jako byt nadrzędny; właściciel operacyjny zapisu: DR |
| WIDZĄCY | **BRAK jednego implementacyjnego bytu w tagu**; pojęcie obecne w materiale architektury | **BRAK** | **BRAK jawnego kontraktu** | **BRAK jawnego artefaktu** | **BRAK** |
| PRĄDOWANIE / PRZELOT | właściwość wykonawcy, nie osobny plik/obiekt w `v1.7.1` | **BRAK jawnego runtime'u** | **BRAK jawnego schematu** | **BRAK jawnego śladu trajektorii** | **BRAK** |

[PRAWO] DB i DR jawnie mówią, że są maskami tego samego Orkiestratora, nie osobnymi bytami; DB/DR mają własne zakresy zapisu. fileciteturn222file0L2-L6 fileciteturn223file0L2-L6

### Etapy procesu / POKOJE wykryte w istniejącym ciele

| Etap / pokój roboczy | Adres | Wejście | Wyjście / artefakt | Właściciel |
|---|---|---|---|---|
| ZIMNY START / WSTANIE | `wstan.sh:1–120` | klon/repo + środowisko | `0_MELDUNEK.txt`, wynik weryfikacji | `wstan.sh`; właściciel procesu: **BRAK** |
| ŚWIEŻOŚĆ REPO | `wstan.sh:70–120` | HEAD/origin/pull | klasy: ROZJAZD / POŚWIADCZENIE / OFFLINE + wiek | straż świeżości; właściciel nadrzędny: **BRAK** |
| ZESTAWIENIE PAMIĘĆ×REPO | `wstan.sh:121+` | pamięć systemu + ostatnie commity | decyzja, które fakty są z repo, a które z pamięci | **BRAK** |
| WERYFIKACJA | `wstan.sh:150+`, `weryfikacja.js` | żywe repo | RC weryfikacji | `weryfikacja.js`; właściciel procesu **BRAK** |
| LINTY | `wstan.sh:150+`, `narzedzia/linty/` | korpus | werdykt lintu | każdy lint osobno; właściciel zbiorczy **BRAK** |
| STRAŻE | `wstan.sh:180+`, `narzedzia/straze/` | repo + przypadki testowe | RC / alarm | każda straż; właściciel zbiorczy **BRAK** |
| BATERIA TORÓW | `tory_strazy.sh` | lista torów | tabela ZDANE/OBLANE/BRAK TORU | `tory_strazy.sh`; właściciel **BRAK** |
| ZAPIS / PUSH | `zapis_git.sh` | zmienione ciało | commit/push + bateria przed wyjściem | `zapis_git.sh`; właściciel **BRAK** |
| ODLEW | `narzedzia/przyrzady/odlej_main.sh`, `publikuj.sh` | stan main | publiczny odlew | przyrządy odlewu; właściciel **BRAK** |

[NOŚNA RAMA] Powyższe są **etapami mechanizacji**, nie dowodem, że każdy powinien stać się POKOJEM. Audyt tylko pokazuje istniejące granice wykonania.

### KLOCKI / capability

[PRAWO] W tagu `v1.7.1` drzewo repo ma 21 plików w `narzedzia/przyrzady/`, 25 w `narzedzia/straze/`, 15 w `narzedzia/silniki/`, 12 skills oraz 4 linty. Są to policzalne rodziny mechanizmów, ale ich własność i relacja do ROLI nie są zebrane w jednym kontrakcie.

[NOŚNA RAMA] Przykładowe klocki, które mają własny kontrakt wykonania: `weryfikacja.js`, `tory_strazy.sh`, `zapis_git.sh`, `publikuj.sh`, `straz_r0.sh`, `straz_wywolan.sh`, `straz_przyrzadu.sh`, `straz_lintow.sh`, `straz_swiezosci.sh`, `spis_projektow.js`, `oko_tworcy.js`, `inwentarz.js`, `anatomia.js` i inne elementy rodzin `przyrzady/`, `straze/`, `silniki/`, `linty/`.

[PRAWO] Sama bateria pokazuje, że capability mają jawny test `--test`; brak pliku jest raportowany jako `BRAK TORU`, a nie jako zielony wynik. `tory_strazy.sh` zawiera także test własnej baterii na przypadku +/−. fileciteturn231file0L2-L2

[NOŚNA RAMA] **Właściciel większości klocków na poziomie systemowym: BRAK.** Właścicielem technicznym jest ich plik/skrypt, ale nie jest to jeszcze własność ROLI ani procesu.

---

## §2.2 — Co działa: mechanizmy udowodnione w repo

### 1. Wstanie ma realne uziemienie i ochronę świeżości

[PRAWO] `wstan.sh` mierzy czas maszyny i jawnie rozróżnia czas UTC od `Europe/Warsaw`; sprawdza też gałąź, wykonuje `git pull --ff-only` i rozróżnia ROZJAZD HISTORII, brak poświadczenia oraz sytuację offline. fileciteturn225file0L2-L6

[PRAWO] Mechanizm świeżości ma osobną klasyfikację; repo nie traktuje błędu pulla jako jednego nieokreślonego „offline”. fileciteturn225file0L2-L6

### 2. Repo jest źródłem faktów, pamięć jest zestawiana z repo

[PRAWO] `wstan.sh` pokazuje ostatni ruch repo przed meldunkiem i explicite ustanawia zasadę: przy sprzeczności repo wygrywa co do faktów, a pamięć tylko co do świeższych decyzji, które należy następnie zapisać. fileciteturn226file0L2-L2

[REZONANS] To jest już zalążek zewnętrznego stanu prawdy, którego nie trzeba wymyślać od zera w architekturze obiektowej.

### 3. Mechanizacja ma testy dodatnie i ujemne

[PRAWO] `tory_strazy.sh` wymaga, aby bateria umiała przejść zdrowy tor i oblać chory tor; brak pliku jest widoczny jako `BRAK TORU`. fileciteturn231file0L2-L2

[PRAWO] Księga błędów dokumentuje osobno porażki testów jednostronnych, testów z fiksturą zasłaniającą błąd, torów żyjących tylko w ścieżce testowej i liczników zgodnych mimo niepełnego zbioru. fileciteturn229file0L2-L2

[REZONANS] To jest mocny mechanizm do zachowania przy obiektowaniu: **nie wystarczy kontrakt; kontrakt musi mieć tor, który umie powiedzieć NIE.**

### 4. Reset i zakres zapisu są już rozdzielone w maskach

[PRAWO] DB i DR są czystymi instancjami; mają wyraźny zakres zapisu, reset i warstwy wczytywania wg kosztu. DB zapisuje wyłącznie do `doradcy/DB/`, DR wyłącznie do `doradcy/DR/`. fileciteturn222file0L2-L6 fileciteturn223file0L2-L6

[REZONANS] To jest istniejący zalążek kontraktu ROLI: tożsamość + zakres zapisu + reset + lazy loading.

### 5. System nauczył się nie ufać własnym wcześniejszym pomiarom

[PRAWO] `BLEDY.md` zawiera klasy #49–#79 dotyczące m.in. złego mianownika, torów testujących własne wyobrażenie o ciele, fikstur zasłaniających błąd, mechanizmów żyjących tylko w torze, braku swoistości oraz „werdyktu straży zamiast jego sprawdzenia”. fileciteturn229file0L2-L2

[PRAWO] #71 opisuje konkretną klasę: klon bez poświadczenia mógł starzeć się milcząco i udawać teraźniejszość; `wstan.sh` ma teraz osobną klasyfikację POŚWIADCZENIE. fileciteturn230file0L2-L2

[REZONANS] Najcenniejszą częścią mechaniki nie jest liczba straży, lecz meta-zasada: **pomiar jest osobnym obiektem odpowiedzialności i musi być weryfikowalny na żywym ciele.**

---

## §2.3 — Unikalność: co chronić przed obiektowością

| Mechanizm | Problem, który rozwiązuje | Ryzyko przy obiektowaniu |
|---|---|---|
| Filtr Prawdy | oddziela fakt / ramę / rezonans i ogranicza konfabulację | **wysokie**, jeśli stanie się metodą jednej ROLI |
| Głos naczelny + maski | pozwala zmieniać tryb bez tworzenia nowych bytów | **wysokie**, jeśli każda maska stanie się osobnym agentem |
| Straże | mechanizują inwarianty i alarmy | **średnie**, jeśli straż zostanie własnością POKOJU zamiast warstwą przekrojową |
| Satelity | pozwalają utrzymywać wiedzę poza stałym kontekstem | **średnie**, jeśli lazy loading zamieni się w automatyczne preloadowanie |
| Prerejestr | chroni przed dopasowaniem hipotezy po fakcie | **średnie**, jeśli zostanie lokalnym stanem ROLI zamiast śladem badania |
| Feromony / KTO_CO_BIERZE | chronią przed kolizją pracy wielu instancji/rąk | **średnie**, jeśli zniknie z warstwy procesu i zostanie tylko w Orkiestratorze |
| R0 / budżet | mierzy koszt poznawczy wstania i utrzymania | **wysokie**, jeśli obiektowość zacznie mierzyć tylko klasę zamiast rzeczywistego kontekstu |
| Bramka powrotu | oddziela informację od zmiany ciała systemu | **bardzo wysokie**, jeśli „wynik agenta” stanie się automatycznym zapisem |
| WIDZĄCY | kontrola trajektorii i pętli | **bardzo wysokie**, jeśli zostanie utożsamiony z wykonawcą |
| Właściciel alarmu | zapobiega sygnałowi bez odpowiedzialności | **wysokie**, jeśli właściciel zostanie domniemany z nazwy pliku |

[PRAWO] Istniejące maski DB/DR pokazują, że jeden byt może mieć różne maski bez stawania się wieloma bytami. fileciteturn222file0L2-L6 fileciteturn223file0L2-L6

[PRAWO] `KTO_CO_BIERZE.md` pokazuje z kolei, że wieloinstancyjność jest już rozpoznanym problemem: ślad ma nadawcę, wpis jest czytany maszynowo, a świeży fetch poprzedza budowę. fileciteturn224file0L2-L6

[REZONANS] **Nie wolno obiektować mechanizmów przekrojowych jako metod ROLI.** Filtr, straż, prerejestr, R0 i bramka powrotu muszą pozostać wyżej niż pojedynczy wykonawca.

---

## §2.4 — Zalążki obiektu istnieją już bez nazwy

### Zalążek 1 — Maska jako obiekt konfiguracji

[PRAWO] DB/DR mają już: tożsamość, wartości/konstytucję, zakres zapisu, warstwy kontekstu, reset i procedury. fileciteturn222file0L2-L6 fileciteturn223file0L2-L6

[REZONANS] To jest prawie ROLA; brakuje jawnych POKOI i kontraktu przekazania.

### Zalążek 2 — Straż jako obiekt kontraktu

[PRAWO] Każda straż ma własny test, RC i wejście do baterii; bateria wymaga obecności pliku i obsługi `--test`. fileciteturn231file0L2-L2

[REZONANS] Straż już zachowuje się jak obiekt `check(input) -> verdict`, tylko interfejs jest konwencją plików shellowych.

### Zalążek 3 — Przyrząd jako bezstanowa operacja

[NOŚNA RAMA] Rodziny `narzedzia/przyrzady/` i `narzedzia/silniki/` są bliższe KLOCKOM niż ROLI: uruchomienie, pomiar/transformacja, wynik, RC. Ich stan nie jest opisany jako trwała pamięć instancji.

[REZONANS] To jest najbliższy istniejący odpowiednik „KLOCKA bez stanu”.

### Zalążek 4 — `wstan.sh` jako runtime/harness

[PRAWO] `wstan.sh` wykonuje sekwencję: uziemienie czasu → świeżość repo → zestawienie pamięć×repo → odbudowa zależności → weryfikacja → linty/straże → budżet. fileciteturn225file0L2-L6 fileciteturn226file0L2-L2

[REZONANS] Nie trzeba „wymyślać harnessu” od zera; trzeba wyodrębnić z istniejącego rytuału stan, kolejność, granice i odpowiedzialności.

### Zalążek 5 — `KTO_CO_BIERZE` jako ślad wieloinstancyjny

[PRAWO] Księga ma jawnego nadawcę, semantyczny marker wpisu i regułę fetch-przed-budową. fileciteturn224file0L2-L6

[REZONANS] To jest gotowy zalążek identyfikacji instancji/pracy, ale nie jeszcze kontrakt POKOJU.

---

## §2.5 — Punkty bólu

### P1 — BRAK właściciela dla warstwy przekrojowej

[PRAWO] Repo ma wiele straży i przyrządów, ale ich zbiorczy właściciel nie jest zapisany jako jedna osoba/rola/obiekt. `tory_strazy.sh` zna listę i komendy, lecz nie zna właściciela semantycznego każdego toru. fileciteturn231file0L2-L2

[KOSZT] **niezmierzony jako osobna liczba**. Nie wpisuję liczby z pamięci.

### P2 — Bateria jest listą, więc lista może stać się ślepą granicą

[PRAWO] Sam `tory_strazy.sh` dokumentuje wcześniejszy przypadek: repo miało straże poza listą, a bateria mogła mimo to meldować komplet; mechanizm pokrycia został później rozszerzony. fileciteturn231file0L2-L2

[PRAWO] `BLEDY.md` opisuje także klasy „licznik zgodny mimo niepełnego zbioru” i „mechanizm żyjący wyłącznie w torze”. fileciteturn229file0L2-L2

[KOSZT] W repo zapisany jest koszt **55% wstania / 88 s** dla pełnej baterii, dlatego została wyjęta z domyślnego wstania i przeniesiona jako obowiązkowa bramka przed pushem w `zapis_git.sh`. `wstan.sh` dokumentuje ten stan. fileciteturn226file0L2-L2

### P3 — Rytuał ma właściciela technicznego, ale nie zawsze właściciela decyzji

[PRAWO] `wstan.sh` wie, że ma uruchomić określone narzędzia, ale przy wielu strażach/linach właściciel semantyczny alarmu nie jest deklarowany w jednym miejscu. fileciteturn226file0L2-L2

[KOSZT] **BRAK uczciwej liczby** w v1.7.1. W dalszej architekturze trzeba najpierw zdefiniować jednostkę alarmu, dopiero potem ją liczyć.

### P4 — Maski mają strukturę obiektu, ale kontrakt jest dokumentacyjny

[PRAWO] DB/DR posiadają warstwy „zawsze / na żądanie / archiwum”, reset i zakres zapisu, ale część wskazanych plików (`2_KONTEKST.md`, `3_DIAGNOZA.md`, `5_STAN.md`, `4_WYJSCIA/`) nie istnieje w tagu `v1.7.1`; zapytanie historii Git dla tych ścieżek zwraca pusty zbiór. fileciteturn222file0L2-L6 fileciteturn223file0L2-L6 fileciteturn215file0L1-L12 fileciteturn216file0L1-L12 fileciteturn217file0L1-L12 fileciteturn218file0L1-L12

[NOŚNA RAMA] To jest **rozjazd deklaracji z odlewem**, nie dowód, że projektowana struktura jest zła. Właśnie dlatego jest ważny dla migracji obiektowej: kontrakt ROLI musi mieć mechaniczny test istnienia artefaktów, na które wskazuje.

### P5 — PRZELOT/WIDZĄCY nie ma jeszcze ciała

[PRAWO] W tagu `v1.7.1` nie ma jednego jawnego pliku runtime'u, który utrzymywałby identyfikator trajektorii, aktualny pokój, historię przejść i decyzję o powrocie. `wstan.sh` utrzymuje stan sesji rytuału, ale to inna rzecz niż stan przelotu wykonawcy. fileciteturn225file0L2-L6

[KOSZT] **niezmierzony** — brak obiektu oznacza brak przyrządu mierzącego jego koszt.

### P6 — Powrót treści nie ma osobnego śladu w implementacji

[NOŚNA RAMA] Repo ma mechanizmy zapisu, straży i odlewu, ale nie ma w `v1.7.1` jednego kontraktu typu `propozycja → ocena → write_approval → zapis`. W tym miejscu nie wolno dopowiadać brakujących pięter bramki powrotu.

[KOSZT] **niezmierzony**.

### P7 — Wysoka liczba mechanizmów zwiększa koszt poznawczy inwentaryzacji

[PRAWO] Sam tag ma 182 pliki; rodziny narzędzi obejmują co najmniej 21 przyrządów, 25 straży, 15 silników, 12 skills i 4 linty.

[REZONANS] Problemem nie jest sama liczba. Problemem jest to, że nie ma jeszcze jednej mapy „kto może wywołać co, w jakim pokoju, z jakim stanem i kto odbiera alarm”. To dokładnie ten rodzaj kosztu, który obiektowość może zmniejszyć — pod warunkiem, że nie zrobi z każdego pliku osobnej klasy.

---

## §2.6 — Rozliczenie audytu względem pierwotnego pytania

[NOŚNA RAMA] Audyt nie rozstrzyga jeszcze, **jak** obiektować system. Rozstrzyga natomiast, gdzie ciało już istnieje i gdzie granica odpowiedzialności jest niejawna.

[PRAWO] Potwierdzone: maski mają zalążek stanu i zakresu zapisu; przyrządy są względnie bezstanowe; straże mają kontrakty testowe; `wstan.sh` jest istniejącym harnessowym szkieletem; repo ma ślady wieloinstancyjności i mechanizmy ochronne. fileciteturn222file0L2-L6 fileciteturn231file0L2-L2 fileciteturn225file0L2-L6 fileciteturn224file0L2-L6

[PRAWO] Potwierdzone: największe luki dotyczą jawnej własności, deklaratywnej mapy etapów, kontraktu przelotu, WIDZĄCEGO i bramki powrotu, a także zgodności deklarowanego kontraktu maski z faktycznym odlewem. 

[REZONANS] Wniosek audytowy: **najpierw nazwać istniejące obiekty i ich granice, dopiero potem tworzyć nowe klasy.** Największym ryzykiem byłoby obiektowanie obecnego bałaganu nazw bez przeniesienia własności i śladu.

---

## §2.7 — Granica

[PRAWO] **CZĘŚĆ 2 = zamknięta.**

[PRAWO] Audyt nie korzystał z §1 jako podstawy oceny; research posłuży dopiero w CZĘŚCI 3 do zestawienia z tym audytem.

[PRAWO] **STOP przed CZĘŚCIĄ 3.**
