# CHANGELOG — HEXAGRAM

Wersje odlewu publicznego. Format: co się zmieniło dla **odbiorcy**, nie dla warsztatu.
Warsztat ma własną pamięć (`kanon/ksiegi/BLEDY.md`, `kanon/ksiegi/KANON_LOG.md`) i nie wychodzi na zewnątrz.

Numeracja: `MAJOR.MINOR.PATCH`. MINOR rośnie, gdy przybywa warstwy albo znika próg wejścia;
PATCH — gdy poprawiamy to, co już jest.

---

## [1.8.2] — PRZYGOTOWANE, NIE wydane (PATCH; baza U2 `prywatna` `7a7d93fd`)

Poprawki tego, co już jest. Odbiorca dostaje:
- **Strefa przy zepsutym `instancja.json`**: skrypty powłoki nie podstawiają już po cichu Europe/Warsaw — stempel nosi
  `STREFA?`, a powód (plik nieparsowalny) widać na ekranie. Jeden wspólny fragment `narzedzia/silniki/strefa_st.sh`
  zamiast dwunastu kopii (U1-14c).
- **Jeden narząd czytelników ciała** `narzedzia/przyrzady/mapa_ciala.js` zamiast trzech przyrządów (`anatomia.js`,
  `przed_cieciem.js`, `pomiar_ksiag.sh` — zniknęły z odlewu): kto czyta każdy plik, co jest kompostem, mosty zerwane.
- **`MOSTY.md`**: numery wierszy bez dubletów; straż mostów oblewa, gdy numer się powtórzy.
- **Straż deklaracji modelu**: notą jest też tekst „przed …” zapisany w chwili mówienia, nie tylko litera.
- Bateria straży i mutacje bez zmian kontraktu; `strefa_st.sh` ma własny tor i mutację.

## [1.8.1] — wydane 09.10.2026 (PATCH; `main` KRONOS `653e53ca`, HEXAGRAM `c5460e5`; odlew z `prywatna` `d2cee581`)

Poprawki tego, co już jest, pod pierwszego gościa z zewnątrz. Odbiorca dostaje:
- **Godzina sprzed 1996** liczy się ze strefy Europe/Warsaw (tzdata), nie z reguły UE; wynik nosi etykietę
  `UTC+N` i linię o źródle strefy. Bez danych strefy silnik kończy rc=2 zamiast zgadywać.
- **Narodziny**: KOTWICA NIEBA bierze godzinę z bloku obliczeń, nie z zegara; pełnia `0 0` zostaje `0 0`.
- **Drzwi**: `AGENTS.md` i `CLAUDE.md` w odlewie to krótkie szablony PL+EN (jedna kolejność: wstań → KROK 0 →
  pierwszy odczyt → domknij → narodziny); prywatna tabela modeli i imiona rodziny nie wchodzą do odlewu.
- **Wstanie** przy `⟠ ZALĄŻEK` mówi następny ruch („NOWA INSTANCJA → KROK 0”) zamiast menu postaci.
- **Imię** nadaje osoba, w relacji (instancja je przyjmuje i spisuje akt), po pierwszym domknięciu sesji; README liczy 13 skilli i woła Orkiestratora.
- **Księgi `BLEDY.md` i `MOSTY.md`** w odlewie są destylatami (z notą na początku), nie pełnymi księgami warsztatu:
  361798 → 153713 B i 84282 → 70714 B. Wstanie u gościa (zmierzone na kopii odlewu): 228 ✓ · 0 ✗ · 0 ⚠ —
  dwa znane ✗ z poprzedniej wersji znikają. `0_WYWOLANIA.md` odsyła tylko do plików, które odbiorca ma (lint ścieżek
  obejmuje ten plik: 5 → 0 złamanych odsyłaczy).
- **`gotowosc.sh`**: bramka 7 (odlew mierzony jak odbiorca) przy porażce `npm ci` drukuje powód zamiast pustego
  nawiasu; u gościa, który sam jest odlewem, mówi „nie dotyczy”.
- **Próg wejścia (cięcia A–G)**: README wylicza wszystko, co robi `wstan.sh` (pull, sonda zapisu `git push --dry-run`, tożsamość git,
  hooki, `npm ci`, weryfikacja i zapis `0_MELDUNEK.txt`) · z promptu startowego zdjęto zdanie o cięciu na turę ·
  README odróżnia blok obliczony od bloku soczewek · nagłówek bloku OBLICZONE w odczycie nazywa dwa źródła (niebo i tabele Thun/MATRYCA),
  a linie z tabel niosą przedrostek źródła · `DUSZA.md` oznacza fragmenty drogi twórcy, więc zalążek nie niesie jego życia i cytatów ·
  komunikat po odmowie zapisu (403) wylicza właściciela i repo z `origin`, nie z literału · imię nadaje osoba, w relacji (jedno brzmienie
  w `START_TU.md`, `DUSZA.md` i `0_WYWOLANIA.md`).
- **Profil i testy mutacyjne**: `PROFIL.md` nie twierdzi już, że pisze go „wyłącznie ręką twórcy”, skoro onboarding każe instancji zapisać w nim język, imię i datę ·
  przyrząd `mutacje.sh` po zabiciu w trakcie mutacji (SIGKILL) przywraca plik przy następnym biegu z zapasu trwałego i mówi o tym wprost.
- **Zalążki**: `kanon/tozsamosc/ARCHITEKT_istnienie.md` nie niesie już drogi twórcy pierwotnego (imienia, daty ani zapisu rozmowy), a warsztatowy tor sprawdza zalążek każdego pliku z listy zalążkowanych, nie tylko `DUSZA.md`.
- **Autotest `plan_okien.js`** używa fikstury syntetycznej (punkty „natalne” wyliczane względem nieba chwili testu), a przykład w nagłówku niesie okrągłe liczby przykładowe.
- **Zamek markerów** obejmuje teraz datę i miejsce urodzenia (generator wyprowadza wzorce z karty urodzenia, z granicami liczb); przykłady i argumenty testów w `kronos_natal.js` i `testy_rdzen.js` niosą współrzędne neutralne.
- **Strefa instancji**: silniki liczą czas lokalny w strefie z `instancja.json` (pole `strefa`, domyślnie `Europe/Warsaw`; `KRONOS_TZ` ma pierwszeństwo), a miejsce — z pola `miejsce`;
  pytanie o strefę i miejsce z powodem stoi w onboardingu, flaga `--strefa` w `kronos_natal.js` ustala strefę godziny urodzenia, a strefy z niepełnogodzinnym offsetem są odrzucane z poleceniem podania godziny w UTC.
  Gość bez miejsca dostaje komunikat zamiast współrzędnych cudzego miasta, stemple czasu w powłoce idą przez tę samą strefę.
- **Poprawki czasu**: martwa zmienna etykiety w `scan_dwarfs.js`, liczona z numeru miesiąca (błędnie w 63 dniach roku, w wyjściu niewidoczna), zdjęta; `wezownik.js` używa wspólnej reguły czasu (własna myliła się w dobie przełączenia).
- **Naprawy po przeglądzie U1 (08.10.2026)** — część dla odbiorcy i dla gościa, który zakłada własną instancję:
  - **A1** `rodowod.sh` drukuje godzinę pomiaru w każdej z czterech gałęzi świeżości (także przy braku `origin` i przy drzewie za `origin`), więc test stempla czasu nie zależy od cudzego pushu.
  - **A2** tor `mutacje.sh --test` obejmuje ofiarę w podkatalogu po SIGKILL (plik wraca bajt w bajt, bez sieroty w korzeniu).
  - **A3** testy rdzenia nie zależą od strefy instancji: gość w Nowym Jorku albo Tokio dostaje 49 z 49 (wcześniej 40), a `zapis_git.sh` przechodzi bramkę baterii.
  - **A4** granice Wężownika liczone w układzie ekliptyki daty (223,787°–242,387°, stałe w latach 1900–2100) zamiast w układzie J2000; okna Księżyca w Wężowniku przesuwają się o ok. 45 minut, a z kodu znika rok jako osobna liczba.
  - **A5** `_STRAZ_wzorzec.txt` nie niesie daty, a `zaloz_goscia.sh` zdejmuje z ciała gościa pliki `_STRAZ_wzorzec.txt` i `_STRAZ_wyjatki.txt` (listy z `publikuj.sh --lista NARZEDZIA_MAIN_TAJNE`) razem z ich wierszami w `_HASHE.txt`.
  - **A6** generator markerów daje tę samą listę pod locale POSIX i UTF-8 (sesje w chmurze), obejmuje argumenty `Date.UTC` z miesiącem od zera oraz współrzędne z przecinkiem dziesiętnym; fikstury toru karty wniosków używają neutralnego imienia.
  - **A7** nazwa strefy sprowadzana do kanonicznej (`europe/warsaw`, `Poland` → `Europe/Warsaw`); `kronos_natal.js` i `kronos_pelnia.js` podają prawdziwy powód odmowy (np. offset niepełnogodzinny w danym roku), a `kronos_lens.js` kończy rc=2 z powodem zamiast stosu.
  - **A8** autotest `plan_okien.js` liczy na stałej chwili, nie na zegarze (w kilku dniach 2027 oblewał i blokował zapis).
  - **B1** `zapis_git.sh --kontynuuj` przechodzi przez te same bezpieczniki co rebase automatyczny (rejestry dopisane przez obie ręce dostają świeży odcisk).
  - **B2** `zapis_git.sh --wycofaj` zdejmuje wszystkie ślady trybu ręcznego jednym poleceniem.
  - **B3** tryb ręczny, scalając bez konfliktu plik zmieniony przez obie ręce, mówi o tym głośno i zapisuje pole `scalone=` w wierszu biegu.
  - **B4** odzysk po ubitym biegu `mutacje.sh` nie nadpisuje zmiany zrobionej po ubiciu (kończy się rc=14 z nazwą pliku).
  - **Z1–Z2** mapa ciała `anatomia.js` liczy `kanon/archiwum/` jako skład (nie tkankę), a w klonie płytkim podaje wiek plików jako „niezmierzone” zamiast mediany z przyciętej historii.
  - **Porządki (AUTOFAGIA)** wykonane plany i prompty warsztatu przeniesione do `kanon/archiwum/2026-10/` (wraz ze spisem dowodów); lista plików odlewu bez zmian.

Odlew czeka na słowo twórcy „odlewaj” i na zliczenie rzutu #016.

Wydanie 1.8.0 niosło księgi `BLEDY.md` i `MOSTY.md` w pełnej postaci — granica eksportu nie miała czytnika treści; od 1.8.1 idą jako destylaty, a skan markerów osobowych przechodzi także przez ciało gościa.
---

## [1.8.0] — wydane 05.10.2026 (MINOR), odlew `3dd9ae0` na publicznym HEXAGRAM

Od 1.7.1 (stan z 23.09, `2feb869`) zmieniło się **51 plików z listy odlewu** (4 nowe, 47 zmienionych; liczone
`git diff 2feb869..HEAD` po liście `publikuj.sh --lista MAIN`). MINOR, bo przybywa warstwy: ruchy wsteczne nieba
w kanonie gwiezdnym i jedno miejsce dla szukania chwili po stronie silników, a po stronie warsztatu — praca wielu
okien naraz (tablica kartek, rebase z białą listą rejestrów, dwa oddechy zapisu). Odbiorca dostaje to jako
narzędzia i prawa, nie jako obowiązek. Elementy warsztatu, których nie ma na liście odlewu (kanał wniosków
gościa, `siatki.js`, `udzial_projekty.sh`, `zaloz_goscia.sh`), z tym wydaniem nie wychodzą.

### Dodane — silniki
- **`kronos_retro.js` — stacje i okresy wsteczne z cieniem** (☿♀♂♃♄⛢♆♇). Punkty zaciszenia i ruch wsteczny
  wchodzą do kanonu gwiezdnego (słowo twórcy 29.09, K2): suchy silnik, zero interpretacji — znaczenie żyje
  w soczewkach. `scan_aspekty.js` liczy stacje przez ten silnik (jedna miara zamiast dwóch).
- **`szukaj.js` — jedno źródło dla dwóch algorytmów szukania chwili** (zero: połowienie na zmianie znaku;
  ekstremum: trójpodział). W silnikach rodziny astronomy-engine żyło sześć kopii pod czterema nazwami, żadna
  bez własnego toru; teraz `kronos_eter.js`, `kronos_impuls.js` i `scan_aspekty.js` biorą je z jednego pliku,
  który ma własny tor.
- **`scan_outer.js`, `scan_dwarfs.js`:** ostrzeżenie na stderr dla lat < 1996 (poza zakresem prawa stref czasowych).
- **`kronos_lens.js`:** zależność opcjonalna ładowana literalnym `require` ze znacznikiem `ZALEZNOSC-OPCJONALNA`
  — brak pliku to brak linii, nie błąd (zamek grafu w `publikuj.sh` czyta ten znacznik).

### Dodane — warsztat, który odbiorca dostaje razem z ciałem
- **`rodowod.sh` — rodowód przed radą:** zanim zarekomendujesz zmianę przyrządu, jedno wyjście pokazuje
  świeżość drzewa, bliznę, która przyrząd ustanowiła, i ostatni wątek o nim. Hak `pre-commit` ostrzega
  (nie blokuje), gdy przyrząd jest zmieniany bez świeżego stempla rodowodu.
- **Praca wielu okien naraz.** `straz_feromonow.sh` v2: **kartka = plik sesji**, tablica składana przy czytaniu
  (`--tablica`, `--inne`), `--biore` odmawia tylko przy kolizji tematu. `zapis_git.sh`: rebase auto z białą
  listą rejestrów dopisywanych (sterownik `merge_hashe.sh` po ścieżce pliku + bezpieczniki B1–B5), ponowienie
  pushu po wyścigu o origin (do trzech prób, nigdy force), **dwa oddechy** (zapis z ruchem wyłącznie w zamkniętej
  liście ścieżek neutralnych nie płaci baterii torów), **bramka przyrządów** (cięcie `zapis_git.sh`,
  `straz_feromonow.sh`, `tory_strazy.sh` albo `.githooks/` wymaga kartki o temacie `BRAMKA`; rc=8) i wiersz
  pomiaru na każdy bieg (`kanon/pomiary/ZAPIS_biegi/<SESJA>.txt`).
- **`wstan.sh`:** przyrząd, którego nie ma w drzewie odbiorcy (`udzial_projekty.sh`, `czytaj_wnioski.sh`), daje jedną
  cichą linię „poza odlewem”, a nie „niedostępny” — odlew nie mówi, że narzędzie nie działa, gdy go po prostu nie ma.

### Zmienione
- **`wstan.sh` nie niesie imienia instancji.** Menu wstania czyta imię pełni z aktu w `DUSZA.md` (nadaje je twórca przez
  `narodziny.sh`); przed aktem stoi samo słowo PEŁNIA. Sekcja pytań asystenta nazywa się `⟐ PYTANIA PEŁNI`, a czytnik
  przyjmuje `⟐ PYTANIA <dowolne imię>` — tor i mutacja pilnują, żeby nie był przywiązany do jednego.
- **`weryfikacja.js` §6** czyta linie z glifem znaku i trzy daty (265 ✓ w dniu przygotowania).
- **`hashuj.sh`:** tkanka obejmuje `WATKI_OTWARTE`, `LOG_SESJI` i `MOSTY`.
- **Straże i hak:** `straz_hooka.sh` (fikstury karteczki z jawną sesją, bateria Windows 76/2 → 79/0),
  `straz_czystosci.sh`, `straz_odlewu.sh` (siedem rozstrzygnięć listy), `straz_powtorzen.sh`, `straz_wstania.sh`;
  `.githooks/pre-commit` przepuszcza nowe linie kartki i wymaga jednego `STATUS` na wpis.
- **Prawa i soczewki:** `PROTOKOL_GLOSU.md` (pełnia = głos naczelny, maski są jej trybami; ratyfikacja pięter),
  `0_WYWOLANIA.md` (karteczka sesji w kroku zamknięcia), echa w `doradcy/DB` i `doradcy/DR`; `skills/README.md`
  liczby zgodne z pomiarem (13 skilli = 11 `ai-` + 2 `astro-`).
- **`MOSTY.md` #61:** `merge_hashe.sh` ∥ `hashuj.sh` ∥ `zapis_git.sh` — brak tego wiersza oblewał
  `straz_dojrzalosci` w odlewie.

### Dla wydawcy (warsztat)
- `kanon/ksiegi/ODLEWY.md` jest **śledzony** (rejestr wydań, nie podróżuje — nie ma go na liście odlewu):
  `publikuj.sh` dopisuje do niego wiersz po przejściu skanu PII, a po biegu wiersz idzie do repo osobnym commitem,
  inaczej drugi bieg stanie na „drzewo brudne”.
- Numer wydania czyta `gotowosc.sh` z jednego źródła, `package.json` (i `package-lock.json`): **1.8.0**.

---

## [1.7.1] — wydane 22.09.2026 (PATCH)

Poprawia to, co w 1.7.0 już było: pierwsze wrażenie odbiorcy na świeżym klonie. Świeży klon
publicznego repo (v1.7.0) pokazywał `212 ✓ · 0 ✗ · 1 ⚠`, linię `ROZJAZD: 70 — prawo #22 naruszone`
i pod nią `(lint niedostępny)` — a wszystkie trzy to STAN NORMALNY ciała przed narodzinami, mierzony
miarą ciała po nich. Ta wersja nazywa te stany zamiast je alarmować. **Nic nie wyciszono:** każdy
komunikat drukuje liczbę i nazwy, a to, co jest prawdziwą usterką, nadal jest ✗.

### Naprawione — pierwsze wrażenie na świeżym klonie
- **`lint_bledy`: krata destylatu to ⓘ, nie ✗.** Indeks księgi błędów jedzie w całości, opis tylko
  lekcji z mechanizmem w kodzie — to zaprojektowane. Generator dopisuje do nagłówka
  `zakres destylatu: #1–#NNN`; luki w tym zakresie lint melduje jako ⓘ z liczbą i numerami. Twoje
  własne wpisy (numer > NNN) podlegają prawu #22 w całości, od pierwszego. Zakres pisze generator,
  nie Ty — nie da się go „uciszyć" edycją.
- **Ciało przed narodzinami nazwane, nie ostrzegane.** Póki w `DUSZA.md` stoi `⟠ ZALĄŻEK`:
  `weryfikacja.js` melduje brak `_STRAZ_APPEND.txt` jako ⓘ „powstanie przy narodzinach", a
  `lint_sciezek` odwołania `START_TU.md` do ksiąg zakładanych przez akt — też jako ⓘ. Lista plików
  aktu ma jedno źródło (`# PLIKI_AKTU:` w `narodziny.sh`), a jej zgodność z aktem sprawdza tor.
- **`weryfikacja.js`: zielone „STRUKTURA CAŁA" przy zalążkowych `PROFIL`/`7_NATAL` niesie ⓘ** —
  „pliki są" nie znaczy „odczyty mają z czego liczyć". Kod wyjścia i liczniki bez zmian.
- **`wstan.sh` nie mówi „niedostępny" o lincie, który działa.** Sprostowanie do wpisu 1.7.0: tamto
  zdanie było prawdziwe dla trzech narzędzi warsztatowych, nieprawdziwe dla trzech lintów. Teraz
  brak pliku i czerwony wynik to dwa różne zdania („brak pliku w tym ciele" / „rc=N — lint działa i
  zgłasza rozjazd"). Dłuższy wycinek wyniku lintów, żeby ⓘ nie ginęły.

### Zmienione — straże
- **`straz_zalazkow`:** wykrywa daty w formacie RRRR-MM-DD i lata 19xx (wcześniej tylko `DD.MM.20xx`);
  granica formatów zadeklarowana w kodzie.
- **`straz_swiezosci`:** `--wiek` ma tor; każda alternatywa wzorców klasyfikacji pulla ma własną
  fiksturę. Rejestr mutacji: +34 świadków (mutanty przeżyte z audytu zewnętrznego, `weryfikacja`,
  `lint_bledy`, `lint_sciezek`, `narodziny`, `destyluj_ksiege`, bramka odlewu).

### Dla wydawcy (warsztat)
- **`gotowosc.sh` bramka 7 — odlew testowany jako odlew.** Etap A (przed pushem): klon lokalnego odlewu
  → `npm ci` → `wstan.sh`; ✓ tylko przy 0 ✗, 0 ⚠, zerze „niedostępn…" i braku nieśledzonego `node_modules` w klonie (to łapie
  brak `.gitignore`); brak odlewu albo brak sieci = „?", nie ✓. Etap B (po pushu):
  `bash gotowosc.sh --po-pushu` — drzewo publicznego remote = drzewo odlewu.

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
- `wektory.js` — asercja T9b czytała `ROOT/wektory.js` (nazwa historyczna) po tym, jak przyrząd przeniesiono do
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
