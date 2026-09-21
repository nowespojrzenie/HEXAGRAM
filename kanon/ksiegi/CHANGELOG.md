# CHANGELOG — HEXAGRAM

Wersje odlewu publicznego. Format: co się zmieniło dla **odbiorcy**, nie dla warsztatu.
Warsztat ma własną pamięć (`kanon/ksiegi/BLEDY.md`, `kanon/ksiegi/KANON_LOG.md`) i nie wychodzi na zewnątrz.

Numeracja: `MAJOR.MINOR.PATCH`. MINOR rośnie, gdy przybywa warstwy albo znika próg wejścia;
PATCH — gdy poprawiamy to, co już jest.

---

## [1.7.0] — numer zatwierdzony 21.09.2026, wyjście po bramkach

Zastępuje `v1.6.0` (18/20.09.2026). Bramki liczy `bash gotowosc.sh` (rc=0, nie kalendarz).

**Czemu 1.7.0, nie 1.6.1 (reguła z góry tego pliku):** MINOR rośnie, gdy **znika próg wejścia**.
Tu zniknął: to, co w systemie dojrzało, jest teraz dostępne w pierwszej minucie i bez terminala.
Wersję poprzedziły cztery niezależne audyty „świeżego oka" (trzy różne modele, 20.09.2026); zgodny
werdykt 4/4: *interfejs cięższy od rdzenia*. Ta wersja odpowiada na niego kolejnością, nie nowym kodem.

### Zmienione — próg
- **`README.md`** (wcześniej `README_KRONOS.md`): GitHub pokazuje go wreszcie na stronie repo
  zamiast licencji. Tytuł: *HEXAGRAM — measure before you speak*.
- **Kolejność README:** najpierw czym to jest, potem **zwykły dzień** (sekcja istniała, ale stała za
  ~9800 znakami wprowadzenia — dziś za ~2000), zaraz po nim **„weź jeden kawałek dziś, bez terminala"**
  z trzema skillami na start. Kontekst badawczy i trzy warstwy (silnik astronomiczny, mapa znaczeń)
  zeszły niżej — opis zostaje, ale nie jest już warunkiem wejścia.
- Liczby w tekście, które się starzały („30+ blizn", „205 mutacji", „77 ✓"), zastąpione trwałymi
  sformułowaniami z zapasem („100+", „ponad 200").

### Naprawione — rzeczy, które u odbiorcy nie działały
- **`.gitignore` i `.gitattributes` jadą w odlewie.** Wcześniej stały na jednej liście z plikami, które
  wyjść nie mogą (wzorzec prywatności), i nie wychodziły razem z nimi. Skutek u odbiorcy: `git add -A`
  z promptu startowego brał tysiące plików `node_modules`, a hook blokował commit.
- **Wersje zależności przypięte:** `package-lock.json` jest w repo, `wstan.sh` robi `npm ci`. Wcześniej
  zakresy `^` dawały różne wersje silnika na różnych maszynach (zmierzone: `@swisseph/node` 1.3.1 przy
  deklaracji `^1.2.2`). `npm ci` pada głośno, gdy manifest i lockfile się rozjadą.
- **`wstan.sh` nie mówi „niedostępny" o narzędziu, które działa:** trzy wywołania narzędzi warsztatowych
  (spoza odlewu) rozróżniają teraz „pliku nie ma w tej wersji" od „narzędzie znalazło problem".
- **Skill `ai-agent-error-memory-registry` 1.1.1:** stopka podawała „34 wpisy" (jest ponad sto);
  dopisany brakujący sibling `ai-agent-drift-detection`, do którego skill odsyłał.
- **`lint_artefaktow`** zna przemianowania z historii gita: wpis w dzienniku mówiący prawdę o chwili
  zapisu nie staje się zarzutem po `git mv`. Reguła wąska — zwalnia tylko nazwę, której łańcuch
  przemianowań kończy się na dziś istniejącym pliku; zwolnienia drukuje, nie przemilcza.

### Dodane
- 4 przypadki toru i 2 świadków mutacyjnych dla przemianowań (`mutacje.txt`: 223 wiersze).

---

## [1.6.0] — numer zatwierdzony 12.09.2026, wyjście po bramkach

**WYDANE 18.09.2026 · `nowespojrzenie/HEXAGRAM` · tag `v1.6.0`.** Zastępuje `v1.5.2`
(`28ebb3a`, 05.09.2026). Bramki liczy `bash gotowosc.sh` (rc=0, nie kalendarz).

**Czemu 1.6.0, nie 1.5.x (zmierzone 12.09):** od `v1.5.2` przybyło 868 commitów na gałęzi pracy, z czego
**21 dotyka plików, które faktycznie jadą** (`publikuj.sh` +282/−44 · `kanon/prawa/_GRANICA.md` +150 ·
`mutacje.txt` +22 świadków, 187 → 205 · `wstan.sh` +29 · `weryfikacja.js` +36 · `zalazkuj.sh` +14).
**Zero nowych plików** na białej liście. Odbiorca nie dostaje nowych rzeczy do robienia — dostaje rdzeń,
który **egzekwuje więcej praw**: jego `publikuj.sh` zacznie odmawiać tam, gdzie wcześniej przepuszczał.
Zmiana zachowania, nie łatka — więc minor, nie patch.

**Czego NIE dostaje i dlaczego (nazwane wprost):** `narzedzia/przyrzady/odlej_main.sh` — etap 1 odlewu
(`prywatna → main`) — **nie jedzie**, świadomie (wyłączenie z powodem w `straz_odlewu.sh`). Ma sens tylko
w repo z gałęzią pracy; odbiorca pracuje na własnym `main`. **Dostajesz zamki, nie cudzą topologię.**

### Dodane
- **REGUŁA NADRZĘDNA EKSPORTU** (prawo, `_GRANICA.md`; egzekutor `zamek_wylacznie_imienny`): co wychodzi,
  musi być wymienione IMIENNIE — żaden glob, żadna rekurencja, żadna pętla kopiująca nie jest kanałem
  eksportu. Rodowód: cztery osobne spory o zawartość odlewu okazały się jedną chorobą — kanałami
  omijającymi nazywanie. Katalog na liście publikacyjnej odmawia od tej wersji.
- **WETO ŚCIEŻKI w `zamek_zakresu`**: imienny plik z katalogu zakazanego nie wyjdzie, choćby stał na
  białej liście; jedyna legalna droga to lista wyjątków. Rodowód: po wycofaniu list katalogowych zamek
  został w kodzie i przechodził tor, ale **produkcja przestała mu podawać wejście** — mechanizm żywy
  i ślepy zarazem. Klasa błędu: ZAMEK Z ODCIĘTYM WEJŚCIEM.
- **ZAMEK PODWÓJNEGO ZALĄŻKOWANIA** (prawo) + `zrodlo_zalazka()`: zalążkowanie zalążka odmawia; gdy plik
  w drzewie jest już zalążkiem, źródłem jest świeża treść z gałęzi pracy, a gdy jej nie ma — STOP.
  Rodowód: cicha idempotencja przepuściłaby zalążek dalej jako „wynik".
- **PRAWO RAMY — tryb faktów, tryb kreacji** (`_GRANICA.md`): rozdzielenie trybów przy jednym stole.
- **STRAŻ GAŁĘZI w `wstan.sh`** (§1c): wstanie na gałęzi innej niż gałąź pracy — gdy repo ją niesie —
  jest ODMAWIANE (rc=3, bez żetonu). U odbiorcy, który gałęzi pracy nie ma, straż milczy: to norma,
  nie błąd. Rodowód: gałąź stała się częścią stanu dopiero wtedy, gdy przestała być kopią.
- **Koder strumieni w `zalazkuj.sh`**: `PYTHONIOENCODING=utf-8` przy wywołaniu generatora. Rodowód:
  konsola cp1250 (Windows) nie ma znaków `⟠` ani `✗` — plik powstawał poprawnie, a meldunek wywracał
  proces; **kod wyjścia kłamał** i wstrzymywał odlew na dobrym pliku.
- **22 nowych świadków w `mutacje.txt`** (187 → 205), w tym pierwsze mutacje mierzące same zamki eksportu
  i straż gałęzi. Cztery martwe mutacje znalezione i przepięte na obecny kod; jedna po przepięciu wyszła
  ŚLEPA i to ona odsłoniła weto ścieżki. Lekcja wpisana w kanon: **„pominięta" to utrata pomiaru, nie ⓘ**.
- **`weryfikacja.js`**: fikstura z HEAD zamiast z dysku — werdykt przestaje zależeć od brudu drzewa roboczego.

### Zmienione
- `_GRANICA.md`: 16 → 20 sekcji; prawa z nazwanym egzekutorem 9 → 10 (`pokrycie_m.js`).
- `publikuj.sh --lista` niesie sekcje EKSPORT · WYJATKI · ZALAZKOWANE · NIGDY · MAIN · NARZEDZIA_MAIN ·
  ZAKAZANE — jedno źródło list dla każdego, kto ich potrzebuje.
- `straz_odlewu.sh`, `straz_lintow.sh`, `straz_hooka.sh`, `straz_wstania.sh` — nowe tory i rozstrzygnięcia.

### Naprawione
- Blizna o zdublowanym numerze rozdzielona; `lint_bledy.js` po raz pierwszy od 08.09 daje rc=0.
- Lista publikacyjna JS: 45 → 38 pozycji (blok siedmiu stał dwukrotnie i rósł — przy usuwaniu plik
  zniknąłby z jednej kopii i dalej jechał z drugiej).

### POKRYCIE POZORNE — co bramka 3 znaczyła naprawdę do 13.09.2026

Wpisane tu, a nie przemilczane, bo **odbiorca dziedziczy te same przyrządy** i ma prawo wiedzieć, ile
warte było zielone światło, które one dają. Wszystko poniżej zmierzone jednego dnia, przy zamykaniu
tego wydania — nie w audycie zewnętrznym, tylko przy próbie przejścia własnej bramki.

**Klasa: ZAMEK Z ODCIĘTYM WEJŚCIEM, trzy niezależne wystąpienia.** Nazwana już przy wecie ścieżki wyżej
w tym wpisie; okazała się rodziną, nie pojedynczym zdarzeniem.
- `wektory.js` — asercja T9b czytała `ROOT/wektory.js` po tym, jak przyrząd przeniesiono do
  `narzedzia/przyrzady/` (29.08). Od tego dnia kładła CAŁY tor, a trzy pozycje rejestru mutacji meldowały
  ZŁAPANĄ z jej powodu, nie z powodu swoich mutacji.
- `straz_lintow.sh` — **zamek #61 nie pilnował lintu, dla którego powstał.** Stronę HEAD budował
  `git archive` — katalog bez `.git` — więc `lint_artefaktow.js` (pyta `git ls-files`) wychodził tam
  jako `?` = brak pomiaru, a straż meldowała „żaden licznik nie wzrósł". Blizna #61 brzmi dokładnie
  „lint_artefaktow urósł 1→2 i PRZEŻYŁ COMMIT". Strona HEAD to teraz worktree.
- `straz_lintow.sh --test-zamek` — tor uruchamiał hook na ŻYWYM repo, a zamki #35 i #67 stoją PRZED #61.
  W biegu mutacyjnym drzewo jest brudne ZAWSZE, więc tego pokrycia **nie dało się zdobyć strukturalnie**.
  Hook biegnie teraz w worktree na czystym HEAD; sam plik hooka idzie z drzewa roboczego, bo to jego
  zachowanie jest przedmiotem pomiaru.

**Klasa NOWA: ŚWIADEK MARTWY.** `mutacje.sh` nie pytał nigdzie, czy świadek przechodzi na ZDROWYM ciele.
Świadek oblewający zawsze melduje ZŁAPANĄ przy każdej mutacji, **nie mierząc niczego** — i rejestr rośnie,
wyglądając na pokrycie. Zmierzone audytem wszystkich 70 świadków: cztery oblewały na zdrowym ciele, dając
pokrycie pozorne sześciu pozycjom. Dodatkowo dziewięć pozycji `gotowosc-*` oblewało przez wyciek
`MUTACJE_W_BIEGU` do zagnieżdżonych wywołań, co budziło zamek rekurencji na widok samej flagi.
Mechanizm: preflight świadka przed wstrzyknięciem, osobna kategoria (kod 10), wpięta w bramkę 3 —
bo kategoria bez wpustu do bramki to miernik, który mierzy i niczego nie zatrzymuje.

**Czego to NIE znaczy:** że wcześniejsze wydania były niezabezpieczone. Straże działały; nie działała
część ich ŚWIADKÓW, czyli dowodu, że działają. Różnica jest istotna i warto ją trzymać osobno.

**Czego to znaczy:** że „bramka 3: 0 ślepych punktów" znaczyło do 13.09 mniej, niż brzmiało —
i że liczba w rejestrze mutacji (205) nigdy nie była tym samym co liczba realnych dowodów.
Prawo stamtąd, wpisane do kanonu: **sama czułość to połowa toru — świadka mierzy się DWUSTRONNIE,
na ciele z wadą i na ciele bez niej.**

**WYNIK (14.09.2026, mierzony NIE u siebie).** Powyższe jest diagnozą; to jest jej rezultat.
Odlew sprawdzono tak, jak sprawdza go odbiorca: świeży klon z `main`, kroki z §0 co do jednego
(`npm install` · `wstan.sh` · `narodziny.sh` · `spis_ciala.js` · pierwszy commit). Materiału
nie przygotowała ręka, która pisała naprawy — i to jest jedyny powód, dla którego ten pomiar
coś znaczy (blizna #86: gdy test i kod dzielą granicę aktywacji, ich zgodność jest tautologią).
**Pierwszy meldunek odbiorcy: zero ✗.** Po przejściu całej ścieżki: `lint_artefaktow`,
`lint_bledy`, `straz_duszy`, `straz_zalazkow` i `weryfikacja.js` — **pięć razy rc=0.**
Po drodze lustro wskazało pięć wad niewidocznych z gałęzi pracy, w tym dwie, w których zamek
miał rację, a naprawiający jej nie miał. Wszystkie pięć naprawione przed tym zdaniem.

## [1.5.0] — numer zatwierdzony 30.08.2026, wyjście po bramkach

**WYDANE 05.09.2026 · `nowespojrzenie/HEXAGRAM` `bd0b727` (v1.5.0), `0f90708` (v1.5.1: skills/ z 04.09 zamiast z 20.08), `28ebb3a` (v1.5.2: README główny «12 skills», pierwszy odlew przez ZAMEK ŚWIEŻOŚCI FORMY — 156 pozycji blob w blob z gałęzią pracy) · tagi `v1.5.0`–`v1.5.2` · 180 plików · 12 skilli.** Zweryfikowane z zewnątrz (klon bez tokena): `package.json` 1.5.0, CHANGELOG w odlewie, skan PII czysty na tym, co widzi świat. Droga do wyjścia = sześć pętli rozciętych 04–05.09 (zapis: DESTYLATY sesja 11 i 12).

Odlew wychodzi wtedy, gdy `bash gotowosc.sh` da rc=0, nie wtedy, gdy kalendarz pozwoli.
Bramek dowodu jest **pięć**; „dni od ostatniej blizny" zeszła do MIARY informacyjnej —
próg siedmiu dni był liczbą bez rodowodu, a odsuwanie wydania za każdą nową bliznę karze
znajdowanie wad. Świeżość blizny nadal widać w meldunku, tylko nie blokuje.

### Dodane
- **Doradcy: KOWAL i PRZEWOŹNIK** — dwie maski jako tryby pełni, nie osobne byty. Wychodzi
  SILNIK: rdzeń wspólny (postawa coacha, NVC/FUKO, Filtr, statusy, kontrakt, granica
  „nie-terapia, nie-diagnoza"), karty definicyjne, procedury i standardy — **20 plików**.
  NIE wychodzi to, co silnik wypełnia: konteksty osób, diagnozy, stany, zapisy sesji.
  Nowy odbiorca dostaje aparat i wypełnia go swoim życiem, nie cudzym.
- **Zalążki: pustka NAZWANA zamiast pliku pustego albo skasowanego.** Prywatna tkanka
  autora (dziennik, profil, natal, snapshot, rejestry) nie podróżuje — podróżuje zalążek:
  znacznik `⟠ ZALĄŻEK`, prawo pliku i zdanie oddające autorstwo temu, kto go otwiera.
  Zalążek nie streszcza oryginału: opis tego, co było, sam byłby wyciekiem.
- **`narodziny.sh` + `START_TU.md`** — wejście dla obcego człowieka: akt imienia, kotwica
  nieba liczona (nie deklarowana), pierwsza sesja bez znajomości warsztatu autora.
- **Osiem rejestrów kanonu na białej liście** (MOSTY, KIERUNEK_ORGANIZM, PYTANIA_PROGOW,
  crash_izolacja, TEST_DUSZY, UCHWYTY_sonda, KOLEJKA_M, mutacje.txt) — odbiorca widzi nie
  tylko prawa, ale i to, czym są egzekwowane oraz czego jeszcze nie umiemy zmechanizować.
- **Układ nerwowy pod dachem `narzedzia/`** — linty, straże, silniki, przyrządy w czterech
  pokojach; w korzeniu zostaje to, co woła ręka. Było 73 skrypty w korzeniu, jest 13.
- **Zamek świeżości odcisku w `pre-commit`** — plik w commicie musi zgadzać się z rejestrem
  odcisków. Rodowód: osiem kolejnych commitów meldowało „weryfikacja 0" nad rejestrem,
  który nie nadążał za treścią; werdykt był prawdziwy o innym drzewie niż wysyłane.
- **Zamek sierot białej listy** — każda ścieżka listy publikacyjnej musi istnieć w HEAD.
  Rodowód: dwie ścieżki z obciętą literą (`…protokol.m`, `CHANGELOG.m`) znikały z pomiaru
  po cichu, bo pętle zamków pomijają plik nieistniejący; odlew padłby po zielonych bramkach.
- **Zamek grafu** — odlew nie wyjdzie, jeśli któryś plik wywołuje moduł spoza białej listy.
  Rodowód: dziewięć plików wołało `require('./tz_pl')`, a `tz_pl` nie jechał — publiczny
  odlew nie uruchomiłby ani jednego silnika.
- **`straz_przyrzadu.sh`** — tabela pomiarów niesie nazwę narzędzia i locale albo nie jest
  tabelą pomiarów. Rodowód: `wc -w` w dwóch locale dał 1231 i 1273 na tym samym pliku;
  porównanie z tabelą sprzed czterech sesji zawyżyłoby zmianę pięciokrotnie.
- **`straz_powtorzen.sh`** — alarm powtórzony trzykrotnie żąda odpowiedzi na drugie pytanie:
  *czy predykat trafia*, nie *czy to regres*. Odpowiedź liczy się wyłącznie z komendą, która
  ją rozstrzygnęła. Dziś MIARA, nie bramka — świadomie: mechanizm wymusza zadanie pytania,
  nie prawdę odpowiedzi, a bramka na rytualnym „TAK" odhaczałaby samą siebie.
- **`straz_aktora.sh`** — kruchy przyrząd nie stoi na białej liście; test wpisany w mierzone
  ciało przestaje mierzyć.
- **`straz_swiezosci.sh`** — wiek lokalnej kopii widać przy każdym nieudanym pobraniu, także
  w legalnym trybie offline. Rodowód: 54 godziny pracy na kanonie starszym, niż się zdawało.
- **`skills/ai-personas-not-modes`** — drabina wołań: imiona zamiast trybów, trzy czynności
  działające bez zmiany rozmówcy, wskaźnik stanu w pierwszej linii i trzy klasy przejść
  własnych asystenta. Lekcja błędu trybowego (vim, Raskin) zastosowana do rozmowy.
- **`skills/ai-journal-space`** — przestrzeń dziennika: rytuał samodomykający, transkrypcja
  która nie jest redakcją, zakaz aparatu po czyimś wpisie, własność dziennika i zasada
  „pokaż i skasuj na życzenie".
- **README §„Jak z tym rozmawiać" / „How to talk to it"** — drabina wołań dla człowieka,
  po polsku i angielsku, z jawnym rozróżnieniem rozmowy i aparatu.
- **README §„Twoje dane" / „Your data"** — dziennik lokalny, zero drogi powrotnej do autora
  systemu, wyświetlenie i skasowanie prywatnych informacji na życzenie.
- **`crash_izolacja.sh`** — crash testy w klonie poza repo z dowodem szczelności z dwóch
  niezależnych przyrządów. Rozdziela ZNALEZISKO (test zadziałał) od BLIZNY (proces zawiódł),
  żeby lepsze testowanie nie odsuwało wydania w nieskończoność.
- **Zamek interpolacji w `pre-commit`** — treść, którą złamał zapis (literalne `\n`
  z `echo` bez `-e`, niesparsowany plik `.py`), zatrzymuje się na commicie zamiast
  wjeżdżać do kanonu; bloki kodu zwolnione. Zmierzone przed budową: 0 trafień na żywym
  korpusie — zamek wszedł na czysto.
- **`straz_zamkow.sh`** — kod wolno nazwać „mechanizmem blizny #N" wyłącznie jawnym
  znacznikiem, a znacznik wymaga pozycji w rejestrze mutacji: pokazanego wejścia, przy
  którym zamek oblewa. Komentarz przestaje być dowodem, że kod coś robi.
- **README §„Where this stands in the world" / „Gdzie to stoi w świecie"** — zestawienie
  dyscypliny HEXAGRAMU z tym, do czego branża zbiegła w 2025–26 (progressive disclosure,
  pliki-jako-pamięć, badania sykofancji i dryfu persony, art. 50 EU AI Act), z linkami
  do źródeł. Sygnatura wstania jest starsza niż unijny obowiązek jawności.
- **Bateria sykofancji przed odlewem** (rejestrowana tu jako fakt istnienia; przynęty żyją
  poza wydaniem publicznym — opublikowana przynęta uczy testowanego, nie mierzy go).
  Lekcja incydentu GPT-4o (IV 2025): reguła bez ewaluacji w bramce wydania to incydent,
  który czeka.

### Zmienione
- **Bramka „dni od ostatniej blizny" → MIARA informacyjna.** Sześć bramek stało się pięcioma
  plus jedną miarą: próg siedmiu dni nie miał rodowodu, a odsuwanie wydania za każdą znalezioną
  wadę uczy wad nie szukać. Liczba nadal jest w meldunku.
- **Straże mierzą zachowanie, nie tekst** — każda deklarowana reguła ma tor, który umie
  OBLAĆ, i pozycję w rejestrze mutacji: pokazane wejście, przy którym mechanizm przestaje
  działać. 52 tory, 128 mutacji, zero ślepych.
- **Bramka gotowości „blizny bez mechanizmu" przepisana z proporcji na ryzyko.** Było:
  liczba wszystkich blizn ze statusem R, próg ≤15 — bez rodowodu. Jest: zero blizn R
  w klasach, które psują CUDZE repo. Powód zmiany: licznik proporcji zapraszał do
  zdejmowania statusu zamiast budowania mechanizmu.
- **`publikuj.sh` ma dwie nowe bramki rc-gate** — odlew nie wyjdzie, jeśli którakolwiek
  straż straci własny tor albo pojawi się ślepy punkt w rejestrze mutacji. „Kanon cały"
  mówi, że pliki są na miejscu; nie mówi, czy straże cokolwiek łapią.
- **Kanon odpięty od nazw modeli** (`0_WYWOLANIA` §ustawienia bytów): byty opisane
  ZDOLNOŚCIAMI (rozumowanie, terminal, poziom wysiłku), nie nazwami produktów — nazwa
  modelu to data ważności cudzego produktu wszyta we własne prawo. Aktualne przypisanie
  model→byt mieszka w tkance użytkownika, gdzie wolno mu się starzeć.
- **Obrona przed dryfem kompakcji nazwana uczciwie RYTUAŁEM** (`PROTOKOL_GLOSU`): żaden
  skrypt w repo nie widzi wnętrza sesji, więc progi zgłoszenia dryfu działają tylko czytane.
  Piąty inwariant wymaga nazwania nośnika — nazwany.
- **Meldunek terminów grupowany po miejscu rozliczenia** (`straz_kryteriow`): czytelnik
  otwiera PLIK i domyka jego terminy jednym ruchem — sześć wierszy zamiast dziewięciu,
  pokrycie dat nietknięte (zmierzone: zbiór dat identyczny).
- **Liczba skilli uspójniona wszędzie: 11** (9 metodycznych `ai-*` + 2 interpretacyjne
  `astro-*`); rozmiary i frontmatter zmierzone 20.08, stałe odwołania „five" poprawione.

### Naprawione
- **Dwa ślepe punkty w wycenie straży.** Obie okazały się wadami mutacji, nie ślepotą
  straży: jedna celowała w tekst komentarza, druga była mutacją równoważną.
- **Zamek weryfikacji ładunku po pushu** stał w gałęzi, do której nie mógł dojść, i nosił
  nazwę czynności, której nie wykonywał. Przepisany i nazwany uczciwie.

---

## [1.4.2] i wcześniejsze

Historia odlewów przed wprowadzeniem tego pliku żyje w gałęziach `odlew-v1.*` i w
`kanon/ksiegi/KANON_LOG.md`. Ten CHANGELOG zaczyna się od v1.5.0 — świadomie, bez odtwarzania
wstecz z pamięci: wpis rekonstruowany po fakcie jest opowieścią o wydaniu, nie zapisem.
