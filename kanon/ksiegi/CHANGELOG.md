# CHANGELOG — HEXAGRAM

Wersje odlewu publicznego. Format: co się zmieniło dla **odbiorcy**, nie dla warsztatu.
Warsztat ma własną pamięć (`kanon/ksiegi/BLEDY.md`, `kanon/ksiegi/KANON_LOG.md`) i nie wychodzi na zewnątrz.

Numeracja: `MAJOR.MINOR.PATCH`. MINOR rośnie, gdy przybywa warstwy albo znika próg wejścia;
PATCH — gdy poprawiamy to, co już jest.

---

## [1.5.0] — numer zatwierdzony 30.08.2026, wyjście po bramkach

**WYDANE 05.09.2026 · `nowespojrzenie/HEXAGRAM` `bd0b727` · tag `v1.5.0` · 180 plików · 12 skilli.** Zweryfikowane z zewnątrz (klon bez tokena): `package.json` 1.5.0, CHANGELOG w odlewie, skan PII czysty na tym, co widzi świat. Droga do wyjścia = sześć pętli rozciętych 04–05.09 (zapis: DESTYLATY sesja 11 i 12).

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
