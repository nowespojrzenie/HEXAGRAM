#!/usr/bin/env sh
# ── PUBLIKACJA = ODLEW Z BIAŁEJ LISTY (decyzja twórcy 25.07.2026: B jako przygotowanie C) ──
# ZASADA: na zewnątrz NIE wychodzi drzewo — wychodzi JAWNA LISTA plików formy.
# Biała lista (wypuszczaj tylko wymienione) > czarna lista (szukaj imion): to, czego
# nie ma na liście, NIE MOŻE wyciec — także plik dodany jutro.
#
# Użycie:  bash publikuj.sh [katalog_docelowy]   (domyślnie ../KRONOS_publiczny)
#          bash publikuj.sh --test               (tor +/− — zamek musi umieć NIE przejść)
#
# TOR TESTOWY (31.07.2026, prawo #38): zamek treści był deklarowany od 25.07 i naprawiany
# 31.07 (gałąź katalogowa nie honorowała wyjątków) — i przez cały ten czas nie miał ani
# jednego toru. Teraz ma pięć, w tym jawny tor na to, że plik i katalog zachowują się
# TAK SAMO. Zamek niespójny wewnętrznie uczy obchodzenia zamka.
set -eu

# Tryb „tylko definicje": tor testowy wciąga stąd funkcje, nie uruchamiając odlewu.
# Wtedy FORMA_* i katalog roboczy przychodzą z otoczenia — skrypt ich NIE nadpisuje.
# UWAGA (zmierzone 31.07): `. plik --funkcje` NIE przekazuje argumentów w dash/POSIX sh —
# sygnał musi iść zmienną otoczenia, nie pozycyjnym. Pierwsza wersja toru poległa właśnie tu
# (rc=128 z „not a git repository": sourced skrypt poleciał dalej i wszedł w bezpiecznik gałęzi).
FUNKCJE=0
if [ "${PUBLIKUJ_FUNKCJE:-0}" = "1" ] || [ "${1:-}" = "--funkcje" ]; then FUNKCJE=1; fi

if [ "$FUNKCJE" = "0" ]; then
  cd "$(dirname "$0")"
  # C3 (STRATEGIA_odchudzenia_rytualu, 01.09.2026): JEDNO ŹRÓDŁO ODCZYTU BIAŁEJ LISTY.
  # `publikuj.sh --lista [MD|JS|SH|INNE|DIRS|WSZYSTKO]` drukuje pozycje sekcji, jedna na linię.
  # Czytelnicy wołają to zamiast własnych sedów — format listy wolno zmienić w JEDNYM miejscu.
  TRYB_LISTA=""; [ "${1:-}" = "--lista" ] && { TRYB_LISTA="${2:-WSZYSTKO}"; }
  DST="${1:-../KRONOS_publiczny}"
  # ── BIAŁA LISTA FORMY (jedyne, co wychodzi; zmiana listy = decyzja twórcy) ──
  FORMA_MD="START_TU.md kanon/prawa/PROTOKOL_KONWERSATORIUM.md kanon/prawa/PRZESWIT_wzorzec.md kanon/tozsamosc/ARCHITEKT_istnienie.md kanon/ksiegi/LOG_SESJI.md prywatne/TASKI.md prywatne/ZADANIA.md kanon/ksiegi/KOLEJKA_M.md kanon/ksiegi/KTO_CO_BIERZE.md kanon/ksiegi/KRONOS_CRASH_LOG.md 0_SNAPSHOT_watek.md kanon/tozsamosc/PROFIL.md kanon/tozsamosc/7_NATAL.md kanon/ksiegi/DESTYLATY_indeks.md kanon/ksiegi/SAMOOBSERWACJA_miary.md README_KRONOS.md JADRO.md 0_WYWOLANIA.md kanon/tozsamosc/1_REZONANS.md \
kanon/tozsamosc/4_MATRYCA_system.md kanon/tozsamosc/5_RDZEN.md kanon/tozsamosc/6_PRZESWIT_przestrzen.md kanon/ksiegi/6_ROLA_ARCHITEKTA.md \
kanon/ksiegi/MAPA_TRANSPERSONALNA.md kanon/ksiegi/BLEDY.md kanon/prawa/PIEC_INWARIANTOW.md kanon/tozsamosc/SUBSTRAT.md \
kanon/ksiegi/RDZEN_SAMOOBSERWACJI.md kanon/prawa/PROTOKOL_GLOSU.md kanon/prawa/PROTOKOL_brama.md kanon/ksiegi/PUKANIE.md kanon/ksiegi/DZWONKI.md \
kanon/prawa/WARTOSCI_UNIWERSALNE.md kanon/prawa/STANDARD_TRESCI.md kanon/tozsamosc/_TORUS.md kanon/prawa/_GRANICA.md \
kanon/prawa/SIEGNIECIE_protokol.md \
kanon/ksiegi/MOSTY.md kanon/ksiegi/KIERUNEK_ORGANIZM.md kanon/ksiegi/PYTANIA_PROGOW.md kanon/prawa/PROTOKOL_crash_izolacja.md kanon/prawa/TEST_DUSZY.md kanon/ksiegi/UCHWYTY_sonda_2707.md"
  FORMA_JS="narzedzia/silniki/kronos_v4.js narzedzia/silniki/kronos_matryca.js narzedzia/silniki/kronos_eter.js narzedzia/silniki/kronos_lens.js narzedzia/silniki/kronos_engine.js \
narzedzia/silniki/kronos_natal.js narzedzia/silniki/kronos_pelnia.js narzedzia/silniki/scan_outer.js narzedzia/silniki/scan_dwarfs.js narzedzia/silniki/scan_aspekty.js \
weryfikacja.js zapis_eter.js testy_rdzen.js testy_rdzen_zlote.json \
narzedzia/linty/lint_bledy.js narzedzia/silniki/kronos_impuls.js narzedzia/linty/lint_artefaktow.js narzedzia/linty/lint_sciezek.js narzedzia/linty/lint_klas_znakow.js narzedzia/przyrzady/pokrycie_m.js narzedzia/przyrzady/wektory.js narzedzia/silniki/tz_pl.js narzedzia/silniki/domy.js \
narzedzia/przyrzady/bateria_sond.js narzedzia/przyrzady/licznik_markerow.js narzedzia/silniki/plan_okien.js narzedzia/przyrzady/rzut.js \
narzedzia/przyrzady/anatomia.js narzedzia/przyrzady/spis_ciala.js narzedzia/przyrzady/homunculus.js narzedzia/przyrzady/oko_tworcy.js narzedzia/przyrzady/przed_cieciem.js narzedzia/przyrzady/inwentarz.js narzedzia/przyrzady/wywiad.js \
narzedzia/przyrzady/anatomia.js narzedzia/przyrzady/spis_ciala.js narzedzia/przyrzady/homunculus.js narzedzia/przyrzady/oko_tworcy.js narzedzia/przyrzady/przed_cieciem.js narzedzia/przyrzady/inwentarz.js narzedzia/przyrzady/wywiad.js narzedzia/przyrzady/destyluj_ksiege.js \
narzedzia/silniki/wezownik.js narzedzia/przyrzady/odduplikuj.js narzedzia/przyrzady/ewaluacja.js"
  # ROZSZERZENIE 20.08.2026 (decyzja twórcy: „dopisz straże"). Powód: bramka 6 mierzy
  # rozjazd straży między `prywatna` a `main`, a straże spoza białej listy NIE JADĄ
  # w odlewie — więc rozjazd rósł przy każdej nowej straży i domykał się wyłącznie
  # osobnym transportem. Po dopisaniu force-push odlewu zamyka bramkę 6 sam.
  # Wszystkie dopisane przeszły zamek wycieku (zmierzone: 0 trafień wzorca).
  #
  # ROZSZERZENIE 28.08.2026 (decyzja twórcy, wariant A) — DWIE OSTATNIE POZYCJE.
  # To NIE była kosmetyka bramki 6. Obie straże powstały PO ostatnim odlewie i na
  # `origin/main` NIE ISTNIEJĄ w ogóle (zmierzone: 199 insertions, 0 deletions) —
  # bramka liczyła je jako „zmienione", bo nowy plik jest zmianą wobec pustki.
  # POWÓD ROZSTRZYGAJĄCY, zmierzony symulacją odlewu z tej właśnie listy (128 plików):
  #   `wstan.sh` JEST na białej liście i w linii 64 woła `narzedzia/straze/straz_swiezosci.sh --klasa`.
  #   Bez niej publiczny odlew miał ZŁAMANY GRAF — dokładnie klasa `narzedzia/silniki/tz_pl.js` z 21.08
  #   opisana wyżej, tylko przeniesiona z silnika na straż. `tory_strazy.sh` w takim
  #   odlewie: 38 zdanych / 3 oblane (`wstanie_rozjazd` i `straz_wstania` — obie z tej
  #   jednej przyczyny). Po dołożeniu obu: 42 zdane / 1 oblany (artefakt symulacji).
  #   Klasyfikacja #71 była w odlewie MARTWA: `|| echo OFFLINE` połykał każdą klasę.
  # `narzedzia/straze/straz_mianownika.sh` jedzie z innego powodu i to jest nazwane, nie zrównane:
  #   nie woła jej NIC poza `tory_strazy.sh` (`prywatne/TASKI.md` 205 — otwarte „KTO
  #   URUCHAMIA ZAMEK"). Publikujemy więc przyrząd ze sprawą otwartą, świadomie.
  # Zamki sprawdzone PRZED dopisaniem, nie po: wyciek 0 trafień obie · graf domknięty
  #   (`narzedzia/przyrzady/pokrycie_m.js` i `kanon/ksiegi/BLEDY.md` już na liście) · własne tory rc=0 obie.
  FORMA_SH="wstan.sh publikuj.sh narzedzia/przyrzady/sync_rdzen.sh zapis_git.sh narzedzia/straze/straz_czystosci.sh hashuj.sh narzedzia/straze/straz_duszy.sh \
narzedzia/straze/straz_deklamatora.sh narzedzia/straze/straz_kryteriow.sh narzedzia/straze/straz_mostow.sh narzedzia/straze/straz_prerejestrow.sh narzedzia/straze/straz_r0.sh \
narzedzia/straze/straz_hooka.sh narzedzia/straze/straz_wstania.sh narzedzia/straze/straz_zetonu.sh narzedzia/straze/straz_przyrzadu.sh narzedzia/straze/straz_powtorzen.sh narzedzia/straze/straz_wywolan.sh narzedzia/straze/straz_zamkow.sh narzedzia/przyrzady/crash_izolacja.sh mutacje.sh tory_strazy.sh gotowosc.sh \
narzedzia/straze/straz_interpolacji.sh narzedzia/straze/straz_tropu.sh narzedzia/straze/straz_lintow.sh narzedzia/straze/straz_feromonow.sh \
narzedzia/straze/straz_narodzin.sh narzedzia/straze/straz_zalazkow.sh narzedzia/przyrzady/zalazkuj.sh narzedzia/straze/straz_dojrzalosci.sh narzedzia/przyrzady/prog_pytan.sh narzedzia/przyrzady/zniwo_destylatow.sh \
narzedzia/straze/straz_swiezosci.sh narzedzia/straze/straz_mianownika.sh narzedzia/straze/straz_aktora.sh \
narzedzia/straze/straz_odlewu.sh narodziny.sh"
  FORMA_INNE="package.json kanon/tozsamosc/hexagram_matrycy.svg _HASHE.txt LICENSE LICENSE-CONTENT kanon/ksiegi/CHANGELOG.md mutacje.txt"
  FORMA_DIRS=".githooks ephe szablony skills"
  # C3: wydruk białej listy (jedna pozycja na linię) i koniec — zero dotykania odlewu.
  if [ -n "$TRYB_LISTA" ]; then
    _l_drukuj() { printf '%s\n' $1; }   # bez cudzysłowu: rozbicie po IFS zdejmuje \ i wcięcia
    case "$TRYB_LISTA" in
      MD)   _l_drukuj "$FORMA_MD" ;;
      JS)   _l_drukuj "$FORMA_JS" ;;
      SH)   _l_drukuj "$FORMA_SH" ;;
      INNE) _l_drukuj "$FORMA_INNE" ;;
      DIRS) _l_drukuj "$FORMA_DIRS" ;;
      WSZYSTKO) _l_drukuj "$FORMA_MD"; _l_drukuj "$FORMA_JS"; _l_drukuj "$FORMA_SH"; _l_drukuj "$FORMA_INNE"; _l_drukuj "$FORMA_DIRS" ;;
      *) echo "publikuj --lista: nieznana sekcja '$TRYB_LISTA' (MD|JS|SH|INNE|DIRS|WSZYSTKO)" >&2; exit 2 ;;
    esac
    exit 0
  fi
  # ── ZAKAZ BEZWZGLĘDNY (13.08.2026, znalezione mutacją w fazie B) ──
  # Do dziś tor tej straży sprawdzał WYŁĄCZNIE wyciek imion (zamek PII), a białej listy
  # katalogów NIE PILNOWAŁ NIC. Mutacja dopisująca `doradcy prerejestr` do FORMA_DIRS
  # przeszła NIEZAUWAŻONA — prywatna tkanka pojechałaby do publicznego odlewu, a zamek
  # PII by jej nie zatrzymał, bo te katalogi nie muszą zawierać żadnego imienia.
  # Klasa: straż pilnowała TREŚCI, nikt nie pilnował ZAKRESU.
  # DOPISEK 28.08.2026 — `kanon/eksperymenty` (uwaga twórcy: „Aktor — uważność na niego!").
  # Zmierzona ASYMETRIA OCHRONY: `prerejestr` miał DWA zamki (nieobecność na białej liście
  # + jawny zakaz tutaj), a `kanon/eksperymenty` — JEDEN. Leżą tam przyrządy KRUCHE wobec
  # publikacji: `BATERIA_PRZYMILNIKA.md` (siedem przynęt, w tym P7 na bliznę #63)
  # i `KARTA_RZUTU_001.md`. Ujawniona przynęta przestaje mierzyć — badany rozpoznaje test
  # i gra czyściej (krzesło AKTORA, `kanon/tozsamosc/SUBSTRAT.md` §79). Ochrona przez samo
  # PRZEMILCZENIE działa, dopóki nikt nie dopisze katalogu do FORMA_DIRS „dla porządku";
  # dokładnie tak przeszła mutacja z 13.08 opisana wyżej. Drugi zamek nie kosztuje nic
  # i jest głośny w chwili pomyłki, zamiast cichy.
  # ── NIGDY NIE WYCHODZI (30.08.2026, decyzja twórcy) ────────────────────────────────
  # Lista wyjątków mówi „to wolno wypuścić". Ta mówi „tego NIGDY" i jest mocniejsza. Powód:
  # do 30.08 ochrona `ZAPIS_AION` polegała wyłącznie na tym, że NIKT GO NIE DOPISAŁ — brak
  # na liście dodawania nie jest zakazem. Plik na obu listach = błąd konstrukcji (tor niżej).
  # Kryterium: PRAWO ODLEWU §3 — projektowe i procesowe zostają, wychodzi uzysk.
  FORMA_NIGDY="${FORMA_NIGDY:-kanon/ksiegi/KANON_LOG.md kanon/ksiegi/ROZMOWY_ODLEWOW.md kanon/ksiegi/DESTYLATY_architekta.md kanon/ksiegi/ZAPISY_eter.md doradcy/DR/ZAPIS_AION.md doradcy/DB/5_STAN.md doradcy/DR/5_STAN.md 0_MELDUNEK.txt}"
  ZAKAZANE_DIRS="doradcy prerejestr prywatne keep_import archiwum kanon/archiwum kanon/eksperymenty nowespojrzenie projekty"
  # ── FAZA E: SELEKTYWNE WYJŚCIE Z KATALOGU ZAKAZANEGO (29.08.2026) ──────────────────
  # Plan v1.6.0 §E: „mechanizm TAK, wsad NIE". Katalog `doradcy` zostaje ZAKAZANY jako
  # całość; wychodzą wyłącznie pliki wypisane TU, po jednej ścieżce — nigdy przez glob,
  # bo glob nad katalogiem prywatnym wypuszcza to, co ktoś tam jutro doda.
  # WSAD PUSTY ŚWIADOMIE: skan 29.08 pokazał wzorzec w KAŻDYM pliku `_WSPOLNE`, który plan
  # przewidywał do wydania (0_RDZEN_WSPOLNY 3 · AMFITEATR_2 3 · APLIKACJA_debiut 9 ·
  # MAPA_ROL 5 · PROJEKT_HEXAGRAM 8). Zapełnienie listy należy do twórcy PO przeglądzie
  # (faza G pkt 4) — instancja buduje bramkę, nie decyduje, co przez nią przejdzie.
  # WSAD (30.08.2026, słowo twórcy: „Doradcy wchodzą pełni. Wchodzi silnik, a nie to, co go
  # wypełnia"). SILNIK = rdzeń wspólny, karty definicyjne masek, procedury, standardy, kompendia.
  # WYPEŁNIENIE (nie wychodzi): 2_KONTEKST · 3_DIAGNOZA · 5_STAN · SESJE · DESTYLATY · 4_WYJSCIA ·
  # AMFITEATR_2 (inspiracja z AION — nie silnik) · APLIKACJA_debiut · MAPA_ROL (osoby) · ZAPIS_AION.
  # Trzy pliki zdezynfekowane tego dnia (imię twórcy → forma neutralna, marka → „marka").
  # ── NIGDY NIE WYCHODZI (30.08.2026, PRAWO ODLEWU pkt 3) ───────────────────────────
  # Lista wyjątków jest listą DODAWANIA — nie ma w niej niczego, co powie „tego nigdy".
  # Do dziś ochrona `ZAPIS_AION` (inspiracja cudzym programem) i `KANON_LOG` polegała
  # WYŁĄCZNIE na tym, że nikt ich nie dopisał. To nie jest zamek, to jest szczęście.
  # Plik z tej listy nie wyjedzie nawet wpisany na białą listę albo między wyjątki —
  # a stanięcie na obu listach naraz jest BŁĘDEM KONSTRUKCJI i zatrzymuje odlew.
  NIGDY_NIE_WYCHODZI="${NIGDY_NIE_WYCHODZI:-narzedzia/przyrzady/triage.js kanon/ksiegi/KANON_LOG.md kanon/ksiegi/ROZMOWY_ODLEWOW.md \
doradcy/DR/ZAPIS_AION.md doradcy/DR/5_STAN.md doradcy/DB/5_STAN.md kanon/ksiegi/DESTYLATY_architekta.md \
kanon/ksiegi/ZAPISY_eter.md 0_MELDUNEK.txt}"
  FORMA_ZAKAZANE_WYJATKI="${FORMA_ZAKAZANE_WYJATKI:-doradcy/_WSPOLNE/0_RDZEN_WSPOLNY.md doradcy/_WSPOLNE/PROG_ODDECH.md doradcy/_WSPOLNE/PROJEKT_HEXAGRAM.md doradcy/_WSPOLNE/README.md \
doradcy/DB/0_KIM_JEST.md doradcy/DB/0_WARTOSCI.md doradcy/DB/1_WIEDZA.md doradcy/DB/_KOMENDA.md doradcy/DB/README.md doradcy/DB/PROCEDURY/strategia_relacyjna.md doradcy/DB/PROCEDURY/_SZABLON.md \
doradcy/DR/0_KIM_JEST.md doradcy/DR/1_WIEDZA.md doradcy/DR/_KOMENDA.md doradcy/DR/README.md doradcy/DR/KOMPENDIUM_DR.md doradcy/DR/POZIOMY_STANDARD.md doradcy/DR/WIZJA_CZLOWIEKA.md doradcy/DR/PROCEDURY/SCIEZKA_START.md doradcy/DR/PROCEDURY/_SZABLON.md}"
fi

# ── ZAMEK TREŚCI (drugi zamek) ──
# Wzorzec żyje POZA odlewem (_STRAZ_wzorzec.txt, nie na białej liście) — sam wzorzec
# z imionami nigdy nie wychodzi na zewnątrz.
# ZAMEK #50
# ZAMEK KOMPLETNOŚCI WZORCA (20.08.2026). Osobna FUNKCJA, nie linia w ścieżce głównej —
# bo tor musi bić w to samo ciało, które wykonuje odlew. Wersja pierwsza stała inline
# i tor testował własną kopię logiki: mutacja ścieżki głównej przechodziła (#50).
# $1 = plik tkanki z imieniem, $2 = plik wzorca. rc=0 wzorzec zna imię, rc=1 nie zna.
zamek_kompletnosci() {
  local TK="${1:-kanon/tozsamosc/ARCHITEKT_istnienie.md}" WZ="${2:-_STRAZ_wzorzec.txt}"
  [ -f "$TK" ] && [ -f "$WZ" ] || return 0
  local IMIE
  IMIE="$(grep -oE '\*\*ORKIESTRATOR · [^*]+\*\*' "$TK" | head -1 | sed 's/.*· //; s/\*\*//')"
  [ -n "$IMIE" ] || return 0
  printf '%s\n' "$IMIE" | grep -qEi "$(cat "$WZ")" && return 0
  return 1
}

# ── ZAMEK GRAFU (21.08.2026) — czy odlew W OGÓLE SIĘ URUCHOMI ──────────────────
# RODOWÓD: 21.08 zmierzone, że DZIEWIĘĆ plików białej listy wywoływało `require('./tz_pl')`,
# a `narzedzia/silniki/tz_pl.js` stał POZA listą. Publiczny HEXAGRAM nie odpaliłby ANI JEDNEGO silnika —
# `tz_pl` to wg DUSZY „jedyne źródło czasu PL", fundament, który wypadł z fundamentu.
# Tak samo `narzedzia/silniki/domy.js` dla `kronos_natal` i `kronos_pelnia`.
# ŻADEN Z 41 TORÓW TEGO NIE ŁAPAŁ i nie mógł: `lint_sciezek` czyta odwołania w `.md`,
# `straz_dojrzalosci` pyta o pojedynczy przyrząd, a nie o DOMKNIĘCIE GRAFU. Wada wyszła
# z pytania „co jeszcze jest poza odlewem", nie z alarmu — czyli mogła wyjść dopiero
# u odbiorcy. Rodzina #55 (obietnica bez czytnika) · #32 (twierdzenie bez pokrycia).
# OSOBNA FUNKCJA, nie linia inline — tor musi bić w to samo ciało, które wykonuje odlew (#50).
# $1 = lista plików odlewu (spacje/nowe linie). rc=0 graf domknięty, rc=1 brakujące ogniwo.
zamek_grafu() {
  local LISTA="$1" f r brak=""
  for f in $LISTA; do
    case "$f" in *.js) ;; *) continue ;; esac
    [ -f "$f" ] || continue
    # dach narzedzia/ (29.08): klasa znaków MUSI obejmować ukośnik i kropkę, inaczej
    # `require('./narzedzia/silniki/kronos_v4.js')` czytałoby się jako cel „narzedzia".
    # Cel rozwiązywany WZGLĘDEM KATALOGU PLIKU — tak, jak robi to node, nie względem korzenia.
    local _d _c
    _d="$(dirname "$f")"
    for r in $(grep -oE "require\('\./[A-Za-z_0-9./-]+" "$f" 2>/dev/null | sed "s|require('\./||"); do
      _c="$r"; [ "$_d" = "." ] || _c="$_d/$r"
      _c="$(printf '%s' "$_c" | sed 's|/\./|/|g')"
      # cel bez rozszerzenia: sprawdzamy .js oraz .json (oba są legalnymi celami require)
      printf '%s\n' "$LISTA" | tr ' ' '\n' | grep -qx "$_c"        && continue
      printf '%s\n' "$LISTA" | tr ' ' '\n' | grep -qx "$_c.js"     && continue
      printf '%s\n' "$LISTA" | tr ' ' '\n' | grep -qx "$_c.json"   && continue
      brak="$brak $f→$_c"
    done
  done
  [ -z "$brak" ] && return 0
  echo "✗ ZAMEK GRAFU: odlew wymaga plików spoza białej listy:$brak"
  echo "  Odbiorca dostałby kod, który nie startuje. Dopisz cel albo zdejmij zależność."
  return 1
}

# ── ZAMEK MARKERÓW (21.08.2026, decyzja twórcy: „ma odmawiać — inaczej masakra") ─────
# RODOWÓD: `narzedzia/straze/straz_czystosci.sh` niesie zamek PII, ale jego lista markerów (`.markery_osobowe`)
# jest gitignored i PER-INSTANCJA. W czystym klonie jej NIE MA, więc straż melduje
# „brak listy — to nie błąd" i przechodzi rc=0. Zachowanie samej straży jest UZASADNIONE
# (lista markerów sama jest daną osobową i nie należy do genomu) — ale znaczy, że przy
# publikacji CAŁY łańcuch ochrony PII opiera się na pliku, którego może nie być.
# Zmierzone 21.08 na żywym przypadku: imię twórcy w `narzedzia/przyrzady/rzut.js` (pięć miejsc, w tym tekst
# wypisywany użytkownikowi) złapało OKO, nie przyrząd. Gdyby nie ręcznie zadane pytanie,
# plik wszedłby do odlewu z imieniem.
# PUBLIKACJA JEST JEDYNYM MIEJSCEM, GDZIE MILCZENIE TEGO ZAMKA KOSZTUJE NIEODWRACALNIE —
# odlew wychodzi na zewnątrz raz. Tu brak listy = STOP, nie „to nie błąd".
# $1 = ścieżka listy markerów. rc=0 lista jest i niepusta, rc=1 brak albo pusta.
zamek_markerow() {
  local M="${1:-.markery_osobowe}"
  if [ ! -f "$M" ]; then
    echo "✗ ZAMEK MARKERÓW: brak listy markerów osobowych ($M)."
    echo "  Bez niej `narzedzia/straze/straz_czystosci.sh` przechodzi na zielono NIE ZNALAZŁSZY NICZEGO,"
    echo "  bo nie miała czego szukać — a odlew wychodzi na zewnątrz raz."
    echo "  → utwórz $M (jedno wyrażenie na linię: nazwiska, prywatne domeny); jest w .gitignore."
    return 1
  fi
  if [ ! -s "$M" ] || ! grep -qvE '^\s*(#|$)' "$M"; then
    echo "✗ ZAMEK MARKERÓW: lista $M istnieje, ale nie ma ANI JEDNEGO markera."
    echo "  Pusty plik daje tę samą fałszywą zieleń co brak pliku (#52) — tyle że cichszą."
    return 1
  fi
  return 0
}

# ── ZAMEK ZALĄŻKA CZYSTEGO (29.08.2026, ratyfikacja twórcy: „wariant bez straty") ────────
# POWÓD (POMIAR_NASIONO_FG_2908 §III): `zamek_wyciek` mierzy plik ŹRÓDŁOWY, a do odlewu idzie
# jego ZALĄŻEK — sześć plików blokowało czysty odlew, bo materiał prywatny z definicji nosi
# imiona. Twórca odrzucił zdejmowanie zamka; ten zamek DOKŁADA brakującą stronę: pyta, czy
# zalążek, który POJEDZIE, jest czysty tym samym wzorcem i tymi samymi wyjątkami.
# Zamek wycieku zostaje nietknięty — jego alarm na pliku zalążkowanym jest odtąd
# ROZSTRZYGALNY: jeżeli ten zamek świeci, alarm tamtego dotyczy ciała, którego nie publikujemy.
zamek_zalazka_czystego() {
  local WZOR ZAL BRUD TMP n PWZ PWY
  # PARAMETRY (29.08): lista · plik wzorca · plik wyjątków. Domyślnie produkcja; tor podaje
  # własną materię z mktemp, więc nie musi udawać całego repo (#54 — nigdy na żywym ciele).
  PWZ="${2:-_STRAZ_wzorzec.txt}"; PWY="${3:-_STRAZ_wyjatki.txt}"
  [ -f "$PWZ" ] || { echo "⚠ brak $PWZ — zamek zalążka pominięty"; return 0; }
  WZOR="$(cat "$PWZ")"
  ZAL="${1:-$ZALAZKOWANE}"
  BRUD=""
  TMP="$(mktemp -d)"
  for _z in $ZAL; do
    [ -f "$_z" ] || continue
    sh narzedzia/przyrzady/zalazkuj.sh "$_z" "$TMP/z.md" >/dev/null 2>&1 || {
      BRUD="$BRUD $_z(nie-powstal)"; continue; }
    if [ -s "$PWY" ]; then
      n="$(grep -vFf "$PWY" "$TMP/z.md" | grep -icE "$WZOR" || true)"
    else
      n="$(grep -icE "$WZOR" "$TMP/z.md" || true)"
    fi
    [ "$n" = "0" ] || BRUD="$BRUD $_z($n)"
  done
  rm -rf "$TMP"
  [ -z "$BRUD" ] && return 0
  echo "✗ ZALĄŻEK BRUDNY — do odlewu pojechałby wzorzec:$BRUD" >&2
  return 1
}

zamek_sierot() {   # 0 = każda ścieżka listy istnieje w HEAD; 1 = lista obiecuje plik, którego nie ma
  local brak="" p
  for p in $1; do
    git cat-file -e "HEAD:$p" 2>/dev/null || brak="$brak $p"
  done
  [ -z "$brak" ] && { echo "✓ biała lista bez sierot: każda ścieżka istnieje w HEAD"; return 0; }
  echo "✗ SIEROTY NA BIAŁEJ LIŚCIE (lista obiecuje plik, którego HEAD nie ma):$brak" >&2
  return 1
}

# ═══ ZAMEK ŚWIEŻOŚCI FORMY (05.09.2026, zlecenie twórcy) ════════════════════════════════
# RODOWÓD — trzy razy w dwa dni ten sam kształt: praca żyje na gałęzi `prywatna`, `main` dostaje ją
# z opóźnieniem, a odlew publikuje `main`. Zmierzone: 04.09 main bez napraw straży (bateria 59/3,
# odlew niewykonalny) · 05.09 rano DUSZA.md z v1.4.2 bez znaczników ⟠ DROGA (zalążek nie powstał) ·
# 05.09 po południu skills/ z 20.08 zamiast z 04.09 — v1.5.0 WYSZŁO ze skillami starszymi niż w repo,
# wykryte pytaniem o jedno słowo („Eleven"). Żaden zamek nie pytał: „czy to, co publikuję, jest tym,
# co zbudowałem?" — sieroty pytają o ISTNIENIE, wyciek o TREŚĆ, ten zamek pyta o TOŻSAMOŚĆ BLOBA.
# Porównuje `git rev-parse HEAD:p` z `<praca>:p` dla każdej pozycji białej listy (pliki i katalogi —
# dla katalogów to hash drzewa). Plik nieobecny na gałęzi pracy nie jest rozjazdem (może być tylko-main).
# Trzy wyjścia, bo cisza nie jest wynikiem (#52): 0 = tożsame · 1 = ROZJAZD (nazwany plik po pliku,
# z gotową komendą naprawy) · 3 = NIE ZMIERZONO (gałąź pracy nieobecna w tym klonie — u odbiorcy
# odlewu to norma, u twórcy alarm). Gałąź pracy: FORMA_ZRODLO, domyślnie `prywatna`.
zamek_swiezosci_formy() {
  local praca="${FORMA_ZRODLO:-prywatna}" rozjazd="" p a b n=0
  # POZA POMIAREM z powodem: `_HASHE.txt` niesie odciski CAŁEGO drzewa gałęzi (na `prywatna` także
  # tkanki), więc między gałęziami różni się z definicji — a odlew i tak GENERUJE własną księgę
  # z tego, co w odlewie (§ „KSIĘGA ODLEWU", niżej). Porównywanie go tu dawałoby stały fałszywy
  # alarm, który uczy ignorować zamek (#56). Zmierzone 05.09 przy pierwszym biegu na żywym main.
  local pomija="${SWIEZOSC_POMIJA:-_HASHE.txt}"
  git rev-parse -q --verify "$praca^{commit}" >/dev/null 2>&1 || {
    echo "⚠ zamek świeżości formy: gałąź pracy '$praca' NIEOBECNA w tym klonie — NIE ZMIERZONO (rc=3)." >&2
    return 3; }
  for p in $1; do
    case " $pomija " in *" $p "*) continue ;; esac
    b=$(git rev-parse -q --verify "$praca:$p" 2>/dev/null) || continue
    a=$(git rev-parse -q --verify "HEAD:$p" 2>/dev/null)
    n=$((n+1))
    [ "$a" = "$b" ] || rozjazd="$rozjazd $p"
  done
  [ -z "$rozjazd" ] && { echo "✓ świeżość formy: $n pozycji białej listy tożsamych z '$praca' (blob w blob)"; return 0; }
  echo "✗ ROZJAZD FORMY — HEAD publikuje inną wersję niż leży na '$praca':$rozjazd" >&2
  echo "  -> odlew z tego HEAD wypuściłby ciało, którego repo już nie ma. Naprawa (jawna, plik po pliku):" >&2
  echo "     git checkout $praca --$rozjazd && bash hashuj.sh$rozjazd && git commit" >&2
  return 1
}

# WIELKOŚĆ LITER NIE DECYDUJE O WYCIEKU (30.08.2026). Wzorzec łapał `<forma imienia twórcy>` i `<imię>`,
# ale NIE `<imię>` — czyli dokładnie formę, w jakiej imię stoi w TYTUŁACH i nagłówkach.
# Zmierzone: cztery pliki białej listy niosły trafienie widoczne wyłącznie przy `-i`, w tym
# `PROTOKOL_crash_izolacja.md`, wpuszczony dzień wcześniej jako „czysty" — bo skan koszyka D
# był tak samo ślepy. Odtąd wszystkie trzy zamki (wyciek · zalążek · PII) pytają bez rozróżnienia.
zamek_czarnej_listy() {
  local zle="" f
  for f in ${NIGDY_NIE_WYCHODZI:-}; do
    # (a) plik z czarnej listy na białej liście albo wśród wyjątków = błąd konstrukcji
    case " $FORMA_MD $FORMA_JS $FORMA_SH $FORMA_INNE ${FORMA_ZAKAZANE_WYJATKI:-} " in
      *" $f "*) zle="$zle $f" ;;
    esac
    # (b) i tak nie może znaleźć się w odlewie — sprawdzane po skopiowaniu (patrz niżej)
  done
  [ -z "$zle" ] && return 0
  echo "✗ PLIK Z LISTY „NIGDY NIE WYCHODZI\" STOI TEŻ NA LIŚCIE WYJŚCIA:$zle" >&2
  echo "  Dwie listy mówią o nim coś przeciwnego — to błąd konstrukcji, nie treści." >&2
  return 1
}

zamek_wyciek() {
  # WYJĄTKI JAWNE (28.07.2026): atrybucje za zgodą osoby (np. Holisses) nie są wyciekiem.
  # Plik _STRAZ_wyjatki.txt istniał od początku, ale NIE MIAŁ CIAŁA — wzorzec go nie czytał.
  # Efekt: zamek zgłaszał fałszywy alarm na legalnej atrybucji i blokował odlew. Naprawione.
  # 31.07: gałąź plikowa i katalogowa honorują TE SAME wyjątki (przedtem katalogowa nie).
  if [ ! -f _STRAZ_wzorzec.txt ]; then
    echo "⚠ _STRAZ_wzorzec.txt brak — drugi zamek pominięty (biała lista = zamek pierwszy)"
    return 0
  fi
  WZOR="$(cat _STRAZ_wzorzec.txt)"
  # LISTA ZE ŹRÓDŁA, nie ze zmiennej (29.08): definicja `ZALAZKOWANE` mieszka w bloku ZAMEK
  # NASIONA — bo tor wycina ten blok `sed`-em i uruchamia w izolacji; wyjęcie jej stamtąd
  # zabijało tor (zmierzone dwa razy). Ten sam wzorzec, którym `zamek_zakresu` czyta białą listę.
  ZAL_LISTA="$(sed -n '/^ZALAZKOWANE="/,/"$/p' "$0" | tr '\n' ' ' | sed 's/ZALAZKOWANE=//; s/"//g')"
  LEAK=""
  brudny() {   # 1 = plik niesie wzorzec po odjęciu jawnych wyjątków
    if [ -s _STRAZ_wyjatki.txt ]; then
      H="$(grep -vFf _STRAZ_wyjatki.txt "$1" | grep -icE "$WZOR" || true)"
    else
      H="$(grep -icE "$WZOR" "$1" || true)"
    fi
    [ "$H" = "0" ] && return 1
    return 0
  }
  for F in $FORMA_MD $FORMA_JS $FORMA_SH $FORMA_INNE ${FORMA_ZAKAZANE_WYJATKI:-}; do
    [ -f "$F" ] || continue
    # DELEGACJA, NIE ZWOLNIENIE (29.08.2026, ratyfikacja: „wariant bez straty").
    # Plik zalążkowany jedzie do odlewu jako ZALĄŻEK — pytanie o jego oryginał jest pytaniem
    # o ciało, którego nie publikujemy (POMIAR_NASIONO_FG §III: sześć plików blokowało czysty
    # odlew). Ten warunek NIE zdejmuje ochrony: dla tych plików odpowiada `zamek_zalazka_czystego`,
    # wołany niżej, PRZED pętlą zalążkowania, i to on mierzy ciało, które naprawdę pojedzie.
    # Gdyby ktoś wyjął plik z ZALAZKOWANE zostawiając go na białej liście — wraca tutaj.
    case " $ZAL_LISTA " in *" $F "*) continue ;; esac
    if brudny "$F"; then LEAK="$LEAK $F"; fi
  done
  for D in $FORMA_DIRS; do
    [ -d "$D" ] || continue
    for F in $(grep -rlE "$WZOR" "$D" 2>/dev/null || true); do
      if brudny "$F"; then LEAK="$LEAK $F"; fi
    done
  done
  if [ -n "$LEAK" ]; then
    echo "✗ WYCIEK w plikach białej listy:"; echo "$LEAK"; echo "   dezynfekcja przed publikacją."
    return 1
  fi
  echo "✓ zamek treści: zmierzone 0 wycieków w białej liście"
  return 0
}

# (przeniesiona 30.08 z bloku --test: definicja żyła TYLKO w torze, ścieżka główna jej nie miała — #38 w czystej postaci)
zamek_zakresu() {
  local dirs="${1:-}" zak="${2:-}" zle=""
  for d in $dirs; do
    for z in $zak; do [ "$d" = "$z" ] && zle="$zle $d"; done
  done
  # WYJĄTKI FAZY E: każdy musi być PLIKIEM w katalogu zakazanym. Katalog albo glob
  # na tej liście jest błędem konstrukcji, nie treści — zatrzymujemy zawsze.
  # `set -f` NIEZBĘDNE (zmierzone 29.08): bez niego shell ROZWIJA glob w liście słów,
  # więc `case` nigdy nie zobaczy gwiazdki — tor „GLOB zatrzymuje" przechodził na zielono,
  # a furtka zostawała otwarta. Predykat musi oglądać WZORZEC, nie jego rozwinięcie.
    # CZARNA LISTA BIJE WSZYSTKO (30.08): plik „nigdy" obecny na białej liście albo wśród
    # wyjątków to sprzeczność — dwie listy mówiące co innego o tym samym pliku.
    for n in ${FORMA_NIGDY:-}; do
      case " ${FORMA_MD:-} ${FORMA_INNE:-} ${FORMA_JS:-} ${FORMA_SH:-} " in
        *" $n "*) zle="$zle nigdy-na-bialej:$n" ;;
      esac
      case " ${FORMA_ZAKAZANE_WYJATKI:-} " in *" $n "*) zle="$zle nigdy-w-wyjatkach:$n" ;; esac
    done
  set -f
  for w in ${FORMA_ZAKAZANE_WYJATKI:-}; do
    case "$w" in
      *"*"*|*"?"*) zle="$zle glob:$w" ;;
      *) [ -d "$w" ] && zle="$zle katalog:$w" ;;
    esac
  done
  set +f
  [ -z "$zle" ] && return 0
  echo "✗ ZAKRES ZŁAMANY — katalog prywatny na białej liście:$zle" >&2
  return 1
}

if [ "$FUNKCJE" = "1" ]; then return 0; fi

# ── TOR TESTOWY (#38) — PRZED bezpiecznikiem gałęzi: test nie jest publikacją ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ PUBLIKUJ — AUTOTEST (#38) ═══╗"
  ZRODLO="$(pwd)"
  T="$(mktemp -d)"
  mkdir -p "$T/skills/x"
  printf 'Nazwisko|Imie\n'             > "$T/_STRAZ_wzorzec.txt"
  : > "$T/_STRAZ_wyjatki.txt"
  printf 'czysty tekst formy\n'        > "$T/CZYSTY.md"
  printf 'autor: Imie Nazwisko\n'      > "$T/BRUDNY.md"
  printf 'atrybucja: Imie za zgoda\n'  > "$T/ATRYB.md"
  printf 'autor: Imie Nazwisko\n'      > "$T/skills/x/SKILL.md"

  # ── ZAMEK ZAKRESU: czy biała lista nie wpuściła katalogu prywatnego ──

  # (⊙⊙) KOMPLETNOŚĆ WZORCA (20.08.2026): wzorzec, który nie zna imienia pełni z tkanki,
  # MUSI zatrzymać odlew. Tor bije w kryterium zamka, nie w zamek — bo zamek mierzący
  # niekompletnym kryterium świeci zielono nad wyciekiem (#53 + #51).
  KOMPLET_OK=0; KOMPLET_ZLE=0
  printf '**ORKIESTRATOR · TESTOWE**\n' > "$T/ARCHITEKT_istnienie.md"
  printf 'TESTOWE\n'            > "$T/wzor_dobry.txt"
  printf 'ZUPELNIE_CO_INNEGO\n' > "$T/wzor_zly.txt"
  zamek_kompletnosci "$T/ARCHITEKT_istnienie.md" "$T/wzor_dobry.txt" && KOMPLET_OK=1
  zamek_kompletnosci "$T/ARCHITEKT_istnienie.md" "$T/wzor_zly.txt"   || KOMPLET_ZLE=1

  probuj() {  # $1..$5 = FORMA_MD JS SH INNE DIRS
    ( cd "$T" && PUBLIKUJ_FUNKCJE=1 \
      FORMA_MD="$1" FORMA_JS="$2" FORMA_SH="$3" FORMA_INNE="$4" FORMA_DIRS="$5" \
      sh -c ". \"$ZRODLO/publikuj.sh\"; zamek_wyciek" ) >/dev/null 2>&1
    echo $?
  }
  RC_CZ="$(probuj CZYSTY.md '' '' '' '')"
  RC_BR="$(probuj BRUDNY.md '' '' '' '')"
  RC_KAT="$(probuj '' '' '' '' skills)"
  printf 'atrybucja: Imie za zgoda\n' > "$T/_STRAZ_wyjatki.txt"
  RC_WYJ="$(probuj ATRYB.md '' '' '' '')"
  cp "$T/ATRYB.md" "$T/skills/x/SKILL.md"
  RC_WKAT="$(probuj '' '' '' '' skills)"
  rm -rf "$T"

  echo "── TEST + (plik czysty):                     rc=$RC_CZ   (oczekiwane 0)"
  echo "── TEST − (plik z imieniem):                 rc=$RC_BR   (oczekiwane 1)"
  echo "── TEST − (KATALOG z imieniem):              rc=$RC_KAT  (oczekiwane 1)"
  echo "── TEST ⊙ (wyjątek ratuje plik):             rc=$RC_WYJ  (oczekiwane 0)"
  # ŹRÓDŁO OBU LIST = TEN PLIK, nie literał w torze. Pierwsza wersja tego toru miała
  # ZASZYTĄ kopię białej listy i mierzyła samą siebie — mutacja dopisująca `doradcy`
  # do FORMA_DIRS przechodziła niezauważona. TRZECI raz ta sama klasa w jednej sesji
  # (po skan_martwicy i po torze normalizacji domów). Tor, który nie czyta ciała,
  # testuje własne wyobrażenie o ciele.
  ZAK="$(grep -oE 'ZAKAZANE_DIRS="[^"]*"' "$0" | head -1 | sed 's/.*="//; s/"$//')"
  DIRS_ZRODLO="$(grep -oE 'FORMA_DIRS="[^"]*"' "$0" | head -1 | sed 's/.*="//; s/"$//')"
  # `set -e` przerywa na komendzie zwracającej ≠0 — dlatego `if`, nie `cmd; RC=$?`.
  # (Złapane własnym torem w minucie pisania: tor urwał się w połowie i dał rc=1.)
  if zamek_zakresu "$DIRS_ZRODLO" "$ZAK" 2>/dev/null; then RC_ZOK=0; else RC_ZOK=1; fi
  if zamek_zakresu "$DIRS_ZRODLO doradcy" "$ZAK" 2>/dev/null; then RC_ZNIE=0; else RC_ZNIE=1; fi
  if zamek_zakresu "" "$ZAK" 2>/dev/null; then RC_ZPUS=0; else RC_ZPUS=1; fi
  echo "── TEST ⊙ (wyjątek ratuje TAK SAMO katalog): rc=$RC_WKAT (oczekiwane 0)"
  echo "── TEST + (biała lista czysta):              rc=$RC_ZOK  (oczekiwane 0)"
  echo "── TEST − (katalog PRYWATNY na liście):      rc=$RC_ZNIE (oczekiwane 1)"
  # ── TOR WYJĄTKÓW FAZY E (29.08.2026): bramka ma umieć ODMÓWIĆ konstrukcji, nie treści ──
  # Trzy przypadki, bo trzy sposoby, na jakie ta lista może stać się furtką:
  # glob (wypuszcza to, co ktoś doda jutro) · katalog (to samo, tylko wolniej) · plik (legalne).
  if FORMA_ZAKAZANE_WYJATKI="doradcy/_WSPOLNE/README.md" zamek_zakresu "$DIRS_ZRODLO" "$ZAK" 2>/dev/null; then RC_EPLIK=0; else RC_EPLIK=1; fi
  if FORMA_ZAKAZANE_WYJATKI="doradcy/_WSPOLNE/*.md"      zamek_zakresu "$DIRS_ZRODLO" "$ZAK" 2>/dev/null; then RC_EGLOB=0; else RC_EGLOB=1; fi
  if FORMA_ZAKAZANE_WYJATKI="doradcy/_WSPOLNE"           zamek_zakresu "$DIRS_ZRODLO" "$ZAK" 2>/dev/null; then RC_EKAT=0; else RC_EKAT=1; fi
  # ── TOR CZARNEJ LISTY (30.08): sprzeczność między listami musi zatrzymać, nie przejść ──
  if FORMA_NIGDY="kanon/ksiegi/KANON_LOG.md" FORMA_MD="JADRO.md" \
     zamek_zakresu "$DIRS_ZRODLO" "$ZAK" 2>/dev/null; then RC_NIG_OK=0; else RC_NIG_OK=1; fi
  if FORMA_NIGDY="kanon/ksiegi/KANON_LOG.md" FORMA_MD="JADRO.md kanon/ksiegi/KANON_LOG.md" \
     zamek_zakresu "$DIRS_ZRODLO" "$ZAK" 2>/dev/null; then RC_NIG_BIA=0; else RC_NIG_BIA=1; fi
  if FORMA_NIGDY="doradcy/DR/ZAPIS_AION.md" FORMA_ZAKAZANE_WYJATKI="doradcy/DR/ZAPIS_AION.md" \
     zamek_zakresu "$DIRS_ZRODLO" "$ZAK" 2>/dev/null; then RC_NIG_WYJ=0; else RC_NIG_WYJ=1; fi
  echo "── NIGDY + (czarna lista rozłączna z białą):  rc=$RC_NIG_OK (oczekiwane 0)"
  echo "── NIGDY − (plik na czarnej I białej):        rc=$RC_NIG_BIA (oczekiwane 1)"
  echo "── NIGDY − (plik na czarnej I w wyjątkach):   rc=$RC_NIG_WYJ (oczekiwane 1)"

  echo "── WYJĄTEK E + (pojedynczy PLIK legalny):    rc=$RC_EPLIK (oczekiwane 0)"
  echo "── WYJĄTEK E − (GLOB zatrzymuje):            rc=$RC_EGLOB (oczekiwane 1)"
  echo "── WYJĄTEK E − (KATALOG zatrzymuje):         rc=$RC_EKAT (oczekiwane 1)"
  # ── TOR ZAMKA SIEROT (30.08.2026): lista z nieistniejącą ścieżką MUSI zatrzymać ──
  if zamek_sierot "START_TU.md publikuj.sh" >/dev/null 2>&1; then RC_SOK=0; else RC_SOK=1; fi
  if zamek_sierot "START_TU.md kanon/prawa/NIE_MA_TAKIEGO_PLIKU.m" >/dev/null 2>&1; then RC_SZLE=0; else RC_SZLE=1; fi
  echo "── SIEROTY + (każda ścieżka w HEAD):         rc=$RC_SOK  (oczekiwane 0)"
  echo "── SIEROTY − (ścieżka obcięta, jak 29.08):   rc=$RC_SZLE (oczekiwane 1)"
  # ── TOR ZAMKA ŚWIEŻOŚCI FORMY (05.09.2026): fikstura = repo z gałęzią pracy; plik zmieniony TYLKO
  #    na gałęzi pracy MUSI zatrzymać (rc=1), tożsame MUSI przejść (rc=0), brak gałęzi MUSI dać rc=3
  #    (nie 0 i nie 1 — trzeci stan, #52). Katalog w liście sprawdzany hashem drzewa, nie nazwą.
  ZSW="$(mktemp -d)"; CIALO_SW="$(sed -n '/^zamek_swiezosci_formy() {/,/^}/p' "$0")"
  sw_rc() { ( cd "$ZSW/r"; eval "$CIALO_SW"; FORMA_ZRODLO="$1" zamek_swiezosci_formy "$2" >/dev/null 2>&1; echo $?; ); }
  ( mkdir -p "$ZSW/r/kat" && cd "$ZSW/r" && git init -q && git checkout -q -b glowna 2>/dev/null \
    && printf 'a\n' > plik.md && printf 'x\n' > kat/w.js && git add -A \
    && git -c user.name=T -c user.email=t@t commit -qm start && git branch praca \
    && git checkout -q praca && printf 'b\n' > plik.md && git add -A \
    && git -c user.name=T -c user.email=t@t commit -qm zmiana && git checkout -q glowna ) >/dev/null 2>&1
  RC_SW_OK="$(sw_rc praca "kat")"                 # katalog tożsamy na obu → 0
  RC_SW_ZLE="$(sw_rc praca "plik.md kat")"        # plik różny na pracy → 1
  RC_SW_NIEZM="$(sw_rc nie_ma_takiej "plik.md")"  # gałąź nieobecna → 3
  rm -rf "$ZSW"
  echo "── ŚWIEŻOŚĆ + (blob tożsamy, katalog drzewem):  rc=$RC_SW_OK (oczekiwane 0)"
  echo "── ŚWIEŻOŚĆ − (plik nowszy na gałęzi pracy):   rc=$RC_SW_ZLE (oczekiwane 1)"
  echo "── ŚWIEŻOŚĆ ? (gałąź pracy nieobecna):          rc=$RC_SW_NIEZM (oczekiwane 3 — nie cisza)"

  echo "── TEST ⊙ (lista pusta nie alarmuje):        rc=$RC_ZPUS (oczekiwane 0)"
  echo "── TEST + (wzorzec ZNA imie pelni):          $KOMPLET_OK  (oczekiwane 1)"
  echo "── TEST − (wzorzec NIE zna imienia pelni):   $KOMPLET_ZLE (oczekiwane 1)"
  echo
  # ── TOR NASIONA (#66) — mierzy blok PRODUKCYJNY, nie własne wyobrażenie o nim.
  # Lekcja tego samego pliku (wyżej): tor z zaszytą kopią logiki testuje sam siebie.
  # Dlatego linie zamka są WYŁUSKIWANE ZE ŹRÓDŁA i wykonywane na atrapie odlewu.
  TN="$(mktemp -d)"
  BLOK="$(sed -n '/^# ── ZAMEK NASIONA/,/^echo "  ⟠ nasiono/p' "$0" | grep -vE '^#')"

  # Prywatna księga W KATALOGU NADRZĘDNYM odlewu — atrapa tego, co zamek ma odciąć.
  # Bez niej mutacja „przepisz księgę z prywatnej" nie ma czego przepisać i przechodzi
  # niezauważona: tor mierzył wtedy ścieżkę, której błąd nie dotykał (#53).
  printf 'aaaaaaaaaaaa  kanon/ksiegi/ZAPISY_eter.md\n' > "$TN/_HASHE.txt"
  # (+) zalążek obecny → księga powstaje i niesie wyłącznie pozycje z odlewu
  mkdir -p "$TN/a/szablony" && printf 'x\n' > "$TN/a/JADRO.md"
  printf '```\n⟠ ZALĄŻEK — tkanka nowego twórcy\n```\n' > "$TN/a/szablony/DUSZA_zalazek.md"
  printf '# D\n<!-- ⟠ DROGA → prawo -->droga<!-- ⟠ /DROGA -->\n' > "$TN/a/DUSZA.md"
  # ŚCIEŻKA CZYTANA ZE ŹRÓDŁA, nie zaszyta (lekcja tego pliku: tor z kopią mierzy własne
  # wyobrażenie). Po Cięciu 5 (24.08) ZALAZKOWANE niesie ścieżki z katalogami — atrapa
  # pod gołą nazwą przestała odpowiadać ciału i tor oblewał na własnej fikstrze (#64).
  _ARCH="$(grep -oE '[^ "]*ARCHITEKT_istnienie\.md' "$0" | head -1)"
  mkdir -p "$TN/a/$(dirname "$_ARCH")"
  printf '# A\n<!-- ⟠ DROGA → prawo -->droga<!-- ⟠ /DROGA -->\n' > "$TN/a/$_ARCH"
  # TOPOLOGIA PRODUKCJI (29.08, dach narzedzia/przyrzady/): blok odlewu woła zalazkuj
  # PO ŚCIEŻCE, więc atrapa musi ją odtworzyć — kopia płasko dawała rc=1 nieodróżnialne
  # od „zalążkowanie nie przeszło" (#53/#70).
  mkdir -p "$TN/a/narzedzia/przyrzady"
  cp narzedzia/przyrzady/zalazkuj.sh "$TN/a/narzedzia/przyrzady/" 2>/dev/null || :
  # ZALEŻNOŚĆ BLOKU (02.09.2026, CZWARTY nawrót klasy #53/#64/#70 w tym pliku).
  # Blok odlewu woła `hashuj.sh` PO NAZWIE z korzenia — atrapa go nie niosła, więc księga
  # odlewu powstawała okaleczona i blok kończył „księga niesie pozycje spoza odlewu".
  # Tor meldował rc=1 NIEODRÓŻNIALNE od realnej wady zamka nasiona. Zmierzone dwustronnie:
  # (+) z hashuj.sh rc=0 i nasiono powstaje; (−) DUSZA/ARCHITEKT bez markerów rc=1,
  # DUSZA.md w odlewie NIE powstaje, zero wycieku treści osobistej.
  # `zamek_zalazka_czystego` NIE jest zależnością do wnoszenia: eval biegnie wewnątrz tego
  # skryptu, a subshell dziedziczy funkcje rodzica. Hipoteza o zakresie leksykalnym została
  # OBALONA MUTACJĄ (`publikuj-atrapa-bez-funkcji-zamka` wyszła ŚLEPA) — zapisane, żeby
  # następna ręka nie wnosiła tu martwego kodu po raz drugi.
  cp hashuj.sh _STRAZ_wzorzec.txt _STRAZ_wyjatki.txt "$TN/a/" 2>/dev/null || :
  if ( cd "$TN/a" && DST="$TN/odlew" && mkdir -p "$DST" && cp JADRO.md "$DST/" \
       && eval "$BLOK" ) >/dev/null 2>&1; then RC_NAS=0; else RC_NAS=1; fi
  RC_NDUSZA=1
  if [ -f "$TN/odlew/DUSZA.md" ] && grep -q "⟠ ZALĄŻEK" "$TN/odlew/DUSZA.md" \
     && [ -f "$TN/odlew/$_ARCH" ] && grep -q "⟠ ZALĄŻEK" "$TN/odlew/$_ARCH" \
     && ! grep -q "droga" "$TN/odlew/$_ARCH"; then RC_NDUSZA=0; fi
  # (−) brak szablonu MUSI wstrzymać odlew (mechanizm, nie życzenie)
  mkdir -p "$TN/b" && printf 'x\n' > "$TN/b/JADRO.md"
  if ( cd "$TN/b" && DST="$TN/odlew2" && mkdir -p "$DST" && eval "$BLOK" ) >/dev/null 2>&1; \
     then RC_NBRAK=0; else RC_NBRAK=1; fi
  # (−) księga przepisana z prywatnej (pozycja spoza odlewu) MUSI wstrzymać.
  # Pierwsza wersja tego testu mierzyła OBECNOŚĆ STRINGU w pliku — czyli wzmiankę
  # o zamku, nie zamek. Mutacja przeszła. Teraz atrapa niesie prywatną księgę
  # z pozycją, której w odlewie nie ma, i mierzony jest SKUTEK.
  mkdir -p "$TN/c" && printf 'x\n' > "$TN/c/JADRO.md"
  cp "$TN/a/szablony/DUSZA_zalazek.md" "$TN/c/" 2>/dev/null || :
  mkdir -p "$TN/c/szablony" && cp "$TN/a/szablony/DUSZA_zalazek.md" "$TN/c/szablony/"
  # TOPOLOGIA PRODUKCJI (29.08, dach narzedzia/przyrzady/): zalazkuj wołany jest po
  # ścieżce, więc w atrapie musi leżeć pod tym samym dachem — kopia płasko dawała rc=1
  # nieodróżnialne od „zalążkowanie nie przeszło" (#53/#70).
  mkdir -p "$TN/c/narzedzia/przyrzady"
  cp "$TN/a/DUSZA.md" "$TN/c/" 2>/dev/null || :
  cp "$TN/a/narzedzia/przyrzady/zalazkuj.sh" "$TN/c/narzedzia/przyrzady/" 2>/dev/null || :
  if ( cd "$TN/c" && DST="$TN/odlew3" && mkdir -p "$DST" && cp JADRO.md "$DST/" \
       && cp "$TN/_HASHE.txt" "$DST/_HASHE.txt" \
       && eval "$(printf '%s\n' "$BLOK" | sed 's|: > _HASHE.txt \&\& find|: \&\& find|')" ) >/dev/null 2>&1; \
     then RC_NOBCE=1; else RC_NOBCE=0; fi
  rm -rf "$TN"
  echo "── TEST + (zalążek obecny, odlew idzie):     rc=$RC_NAS    (oczekiwane 0)"
  echo "── TEST + (KAŻDY zalążkowany plik ma ⟠):     rc=$RC_NDUSZA (oczekiwane 0)"
  echo "── TEST − (brak szablonu wstrzymuje):        rc=$RC_NBRAK  (oczekiwane 1)"
  # ZAMEK SPISU stoi POZA blokiem #66 (musi biec po `git init`), więc tor mierzy
  # KOLEJNOŚĆ W ŹRÓDLE, nie zachowanie: generowanie spisu ma stać PO `git add -A`
  # i PRZED commitem końcowym. To test OBECNOŚCI mechanizmu, nie jego skutku —
  # nazwane wprost, bo słabszy rodzaj dowodu (rodzina #38). Poprzednia wersja tego
  # testu sprawdzała warunek zawsze prawdziwy, czyli nie mierzyła niczego.
  RC_NSPIS=1
  # Wykluczenie MUSI odciąć CAŁY tor, nie samą linię z grepem: kotwice
  # `_p_add/_p_spis/_p_com` są liniami zawierającymi te same znaczniki, więc bez
  # tego filtru test mierzył TRZY WŁASNE LINIE w kolejności, w jakiej je napisano —
  # świecił zielono nad produkcją, z której znacznik zdjęto. Czwarta odmiana tej
  # samej klasy w tym pliku w jednej turze (tor czytający własny tekst).
  _znacz() { grep -n "$1" "$0" | grep -v '_znacz\|_p_add\|_p_spis\|_p_com\|_p_pii' | head -1 | cut -d: -f1; }
  _p_add=$(_znacz "ODLEW-ADD")
  # wzorzec musi być UNIKALNY: pierwsza wersja szukała "node narzedzia/przyrzady/spis_ciala.js",
  # a ten string stoi też w tym torze — grep trafiał we własny tekst i mutacja
  # zdejmująca produkcję przechodziła (tor mierzył sam siebie, ta sama klasa
  # co zaszyta kopia białej listy wyżej w tym pliku).
  _p_spis=$(_znacz "ZAMEK-SPISU-PRODUKCJA")
  _p_com=$(_znacz "ODLEW-COMMIT")
  if [ -n "$_p_add" ] && [ -n "$_p_spis" ] && [ -n "$_p_com" ] \
     && [ "$_p_add" -lt "$_p_spis" ] && [ "$_p_spis" -lt "$_p_com" ]; then RC_NSPIS=0; fi
  echo "── TEST + (zamek na pozycje spoza odlewu):   rc=$RC_NOBCE  (oczekiwane 0)"
  echo "── TEST + (SPIS w odlewie bez nazw prywatnych): rc=$RC_NSPIS (oczekiwane 0)"
  # ── TOR SKANU PII (22.08) — DWIE WARSTWY, bo każda sama w sobie kłamie ──────
  # (A) OBECNOŚĆ I KOLEJNOŚĆ W ŹRÓDLE: skan ma stać po znaczniku ADD, przed commitem końcowym.
  #     Mierzy, że wywołanie w ogóle jest — czyli dokładnie tę wadę, która tu żyła.
  RC_PII_POZ=1
  _p_pii=$(_znacz "ODLEW-PII")
  if [ -n "$_p_add" ] && [ -n "$_p_pii" ] && [ -n "$_p_com" ] \
     && [ "$_p_add" -lt "$_p_pii" ] && [ "$_p_pii" -lt "$_p_com" ]; then RC_PII_POZ=0; fi
  # (B) SKUTEK NA MATERII: sama obecność linii nie dowodzi, że straż UMIE zatrzymać
  #     odlew (rodzina #38 — reguła obowiązująca w dokumentacji). Fikstura ODRÓŻNIALNA
  #     (#64): ta sama materia raz z markerem w treści, raz bez — inaczej „przeszło"
  #     byłoby nieodróżnialne od „nie skanuje w ogóle".
  PT="$(mktemp -d)"; mkdir -p "$PT/odlew/narzedzia/straze"
  # TOPOLOGIA PRODUKCJI (29.08, dach narzedzia/straze/): straż robi `cd dirname/../..`,
  # więc w atrapie musi leżeć dwa poziomy pod korzeniem odlewu — kopia płasko dawała
  # rc=2 (plik nieznaleziony), a rc≠0 jest nieodróżnialne od „straż zatrzymała" (#53).
  cp narzedzia/straze/straz_czystosci.sh "$PT/odlew/narzedzia/straze/" 2>/dev/null || :
  # marker składany w locie — literał zdradziłby się w skanie tego repo (#51)
  PMK="Nazw$(printf 'isko')Probne$$"
  printf '%s\n' "$PMK" > "$PT/lista"
  pii_rc() { ( cd "$PT/odlew" && git init -q . >/dev/null 2>&1; git add -A >/dev/null 2>&1 || :;
               M="$PT/lista" sh narzedzia/straze/straz_czystosci.sh >/dev/null 2>&1 && echo 0 || echo $?; ); }
  printf 'tekst czysty bez sladu\n' > "$PT/odlew/plik.md"
  RC_PII_CZYSTY="$(pii_rc)"
  printf 'w tekscie stoi %s i to jest wyciek\n' "$PMK" > "$PT/odlew/plik.md"
  RC_PII_BRUDNY="$(pii_rc)"
  rm -rf "$PT"
  # (C) WYNIK SKANU MUSI ZATRZYMYWAĆ. Warstwy (A) i (B) razem wciąż przepuszczają
  #     najgroźniejszą odmianę: skan stoi we właściwym miejscu, straż działa, a jej rc
  #     jest ignorowane (`|| true`). Zmierzone — mutacja `publikuj-skan-pii-wynik-ignorowany`
  #     była ŚLEPA, dopóki tego przebiegu nie było. Tor gramatyczny, czyli słabszy rodzaj
  #     dowodu (#38) — nazwane wprost: mierzy KSZTAŁT konstrukcji, nie jej skutek.
  RC_PII_STOP=1
  if [ -n "$_p_pii" ]; then
    # ZAKRES URWANY NA `else` — bez tego tor widział `exit 1` z GAŁĘZI ELSE (brak
    # straży w odlewie) i przechodził, choć z gałęzi ZNALEZIONO-ŚLAD `exit 1` zdjęto.
    # Zmierzone: mutacja `publikuj-skan-pii-nie-zatrzymuje` była ŚLEPA na szerszym zakresie.
    _blok=$(sed -n "${_p_pii},$((_p_pii + 6))p" "$0" | awk '/^else/{exit} {print}')
    case "$_blok" in *"|| {"*) case "$_blok" in *"exit 1"*) RC_PII_STOP=0 ;; esac ;; esac
  fi
  echo "── TEST + (skan PII stoi między ADD a COMMIT):  rc=$RC_PII_POZ (oczekiwane 0)"
  echo "── TEST + (wynik skanu PII ZATRZYMUJE odlew):   rc=$RC_PII_STOP (oczekiwane 0)"
  echo "── TEST − (marker w odlewie ZATRZYMUJE):        rc=$RC_PII_BRUDNY (oczekiwane 1)"
  echo "── TEST + (odlew czysty przechodzi):            rc=$RC_PII_CZYSTY (oczekiwane 0)"
  echo
  # ── TOR ZAMKA ZALĄŻKA CZYSTEGO (29.08.2026) ────────────────────────────────────
  # Dwustronny (#75: czułość BEZ swoistości to połowa toru). Materia budowana w mktemp,
  # nigdy na żywym ciele (#54). Fikstura ODTWARZA TOPOLOGIĘ: zalazkuj.sh wołany po ścieżce.
  TZ="$(mktemp -d)"; mkdir -p "$TZ/narzedzia/przyrzady"
  cp narzedzia/przyrzady/zalazkuj.sh "$TZ/narzedzia/przyrzady/" 2>/dev/null || :
  # wzorzec składany w locie — literał zdradziłby się w skanie tego repo (#51)
  ZMK="Nazw$(printf 'isko')Zalazkowe$$"
  printf '%s\n' "$ZMK" > "$TZ/_STRAZ_wzorzec.txt"; : > "$TZ/_STRAZ_wyjatki.txt"
  # KIERUNEK ZMIERZONY, NIE ZAŁOŻONY (29.08): tryb DROGA ZDEJMUJE treść MIĘDZY znacznikami
  # i zostawia resztę. Pierwsza wersja tej fikstury miała oba przypadki odwrotnie — zbudowana
  # na wyobrażeniu o przyrządzie zamiast na jego pomiarze; tor meldował wtedy dokładnie
  # odwrotny werdykt i wyglądał na sprawny (#70 na fiksturze własnego zamka).
  # (+) zalążek CZYSTY: wzorzec siedzi W ŚRODKU znaczników — zalążkowanie go ZDEJMUJE
  printf '# K\n<!-- ⟠ DROGA → prawo -->prawo z %s<!-- ⟠ /DROGA -->\n' "$ZMK" > "$TZ/czysty.md"
  # (−) zalążek BRUDNY: wzorzec siedzi POZA znacznikami — ZOSTAJE i pojedzie do odlewu
  printf '# K\n<!-- ⟠ DROGA → prawo -->prawo bez imion<!-- ⟠ /DROGA -->\n%s\n' "$ZMK" > "$TZ/brudny.md"
  zal_rc() { ( cd "$TZ" && zamek_zalazka_czystego "$1" _STRAZ_wzorzec.txt _STRAZ_wyjatki.txt \
              >/dev/null 2>&1 && echo 0 || echo 1 ); }
  RC_ZAL_OK="$(zal_rc czysty.md)"
  RC_ZAL_ZLE="$(zal_rc brudny.md)"
  rm -rf "$TZ"
  # ── TOR DESTYLACJI KSIĄG (30.08) ─────────────────────────────────────────────
  # Zamek pyta o NOTĘ w odlewie: bez niej ksiega pojechalaby pelna i nikt by nie zauwazyl,
  # bo pelna ksiega wyglada poprawnie. Dwustronny: z nota przechodzi, bez noty zatrzymuje.
  TD="$(mktemp -d)"; mkdir -p "$TD/k"
  printf '# B\n\n```\n⟠ DESTYLAT KSIĘGI — dla nowego twórcy\n```\n' > "$TD/k/z_nota.md"
  printf '# B\nksiega pelna, bez noty\n' > "$TD/k/bez_noty.md"
  grep -q "⟠ DESTYLAT KSIĘGI" "$TD/k/z_nota.md"  && RC_DEST_OK=0  || RC_DEST_OK=1
  grep -q "⟠ DESTYLAT KSIĘGI" "$TD/k/bez_noty.md" && RC_DEST_ZLE=0 || RC_DEST_ZLE=1
  rm -rf "$TD"
  # ── TOR CZARNEJ LISTY (30.08) ────────────────────────────────────────────────
  # Trzystronny: czysto przechodzi · plik na białej liście zatrzymuje · plik wśród
  # wyjątków fazy E też zatrzymuje (obie drogi do odlewu, nie tylko jedna).
  if NIGDY_NIE_WYCHODZI="kanon/ksiegi/KANON_LOG.md" FORMA_MD="JADRO.md" FORMA_JS="" FORMA_SH="" FORMA_INNE="" \
     FORMA_ZAKAZANE_WYJATKI="" zamek_czarnej_listy 2>/dev/null; then RC_CZL_OK=0; else RC_CZL_OK=1; fi
  if NIGDY_NIE_WYCHODZI="kanon/ksiegi/KANON_LOG.md" FORMA_MD="kanon/ksiegi/KANON_LOG.md" FORMA_JS="" FORMA_SH="" FORMA_INNE="" \
     FORMA_ZAKAZANE_WYJATKI="" zamek_czarnej_listy 2>/dev/null; then RC_CZL_BL=0; else RC_CZL_BL=1; fi
  if NIGDY_NIE_WYCHODZI="doradcy/DR/ZAPIS_AION.md" FORMA_MD="" FORMA_JS="" FORMA_SH="" FORMA_INNE="" \
     FORMA_ZAKAZANE_WYJATKI="doradcy/DR/ZAPIS_AION.md" zamek_czarnej_listy 2>/dev/null; then RC_CZL_WY=0; else RC_CZL_WY=1; fi
  echo "── CZARNA + (rozłączne listy):               rc=$RC_CZL_OK (oczekiwane 0)"
  echo "── CZARNA − (na białej liście zatrzymuje):   rc=$RC_CZL_BL (oczekiwane 1)"
  echo "── CZARNA − (wśród wyjątków E zatrzymuje):   rc=$RC_CZL_WY (oczekiwane 1)"

  echo "── DESTYLAT + (nota obecna):                 rc=$RC_DEST_OK (oczekiwane 0)"
  echo "── DESTYLAT − (brak noty zatrzymuje):        rc=$RC_DEST_ZLE (oczekiwane 1)"

  echo "── ZALĄŻEK + (czysty przechodzi):            rc=$RC_ZAL_OK (oczekiwane 0)"
  echo "── ZALĄŻEK − (brudny zatrzymuje):            rc=$RC_ZAL_ZLE (oczekiwane 1)"

  if [ "$RC_CZ" -eq 0 ] && [ "$RC_BR" -eq 1 ] && [ "$RC_KAT" -eq 1 ] \
     && [ "$RC_NAS" -eq 0 ] && [ "$RC_NDUSZA" -eq 0 ] && [ "$RC_NBRAK" -eq 1 ] && [ "$RC_NOBCE" -eq 0 ] \
     && [ "$RC_NSPIS" -eq 0 ] \
     && [ "$RC_PII_POZ" -eq 0 ] && [ "$RC_PII_BRUDNY" -eq 1 ] && [ "$RC_PII_CZYSTY" -eq 0 ] \
     && [ "$RC_PII_STOP" -eq 0 ] \
     && [ "$RC_WYJ" -eq 0 ] && [ "$RC_WKAT" -eq 0 ] \
     && [ "$KOMPLET_OK" -eq 1 ] && [ "$KOMPLET_ZLE" -eq 1 ] \
     && [ "$RC_ZOK" -eq 0 ] && [ "$RC_ZNIE" -eq 1 ] && [ "$RC_ZPUS" -eq 0 ] \
     && [ "$RC_ZAL_OK" -eq 0 ] && [ "$RC_ZAL_ZLE" -eq 1 ] \
     && [ "$RC_EPLIK" -eq 0 ] && [ "$RC_EGLOB" -eq 1 ] && [ "$RC_EKAT" -eq 1 ] \
     && [ "$RC_DEST_OK" -eq 0 ] && [ "$RC_DEST_ZLE" -eq 1 ] \
     && [ "$RC_CZL_OK" -eq 0 ] && [ "$RC_CZL_BL" -eq 1 ] && [ "$RC_CZL_WY" -eq 1 ] \
     && [ "$RC_NIG_OK" -eq 0 ] && [ "$RC_NIG_BIA" -eq 1 ] && [ "$RC_NIG_WYJ" -eq 1 ] \
     && [ "$RC_SOK" -eq 0 ] && [ "$RC_SZLE" -eq 1 ] \
     && [ "$RC_SW_OK" -eq 0 ] && [ "$RC_SW_ZLE" -eq 1 ] && [ "$RC_SW_NIEZM" -eq 3 ]; then
  # ── TOR ZAMKA MARKERÓW (#64: fikstura odróżnialna — brak · pusty · komentarz · realny) ──
  ZMT="$(mktemp -d)"; CIALO_M="$(sed -n '/^zamek_markerow() {/,/^}/p' "$0")"
  m_rc() { ( cd "$ZMT"; eval "$CIALO_M"; zamek_markerow "$1" >/dev/null 2>&1; echo $?; ); }
  RC_BRAK="$(m_rc nie_ma_listy)"
  : > "$ZMT/pusta";                         RC_PUSTA="$(m_rc pusta)"
  printf '# tylko komentarz\n' > "$ZMT/kom"; RC_KOM="$(m_rc kom)"
  printf 'Nazwisko\n' > "$ZMT/realna";       RC_REAL="$(m_rc realna)"
  rm -rf "$ZMT"
  echo "── ZAMEK MARKERÓW − (brak listy):            rc=$RC_BRAK (oczekiwane 1)"
  echo "── ZAMEK MARKERÓW − (lista pusta):           rc=$RC_PUSTA (oczekiwane 1)"
  echo "── ZAMEK MARKERÓW − (same komentarze):       rc=$RC_KOM (oczekiwane 1)"
  echo "── ZAMEK MARKERÓW + (realny marker):         rc=$RC_REAL (oczekiwane 0)"

  # ── TOR ZAMKA GRAFU (#64: fikstura odróżnialna — ten sam zestaw, jedna różnica) ──
  # Ciało zamka wczytywane z TEGO pliku przez `eval`, nie przepisywane do toru: tor musi
  # bić w to samo ciało, które wykonuje odlew (#50 — pierwsza wersja tego pliku miała
  # zamek inline i tor testował własną kopię logiki).
  # TOPOLOGIA PRODUKCJI (29.08): silnik i jego fundament leżą pod dachem i wołają się
  # względnie — fikstura płaska nie sprawdzałaby rozwiązywania celu względem katalogu.
  ZGT="$(mktemp -d)"; mkdir -p "$ZGT/narzedzia/silniki"
  printf "const t=require('./tz_pl');\n" > "$ZGT/narzedzia/silniki/silnik.js"
  printf "module.exports={};\n"          > "$ZGT/narzedzia/silniki/tz_pl.js"
  CIALO="$(sed -n '/^zamek_grafu() {/,/^}/p' "$0")"
  ZG_OK=0; ZG_ZLE=0
  ( cd "$ZGT"; eval "$CIALO"; zamek_grafu "narzedzia/silniki/silnik.js narzedzia/silniki/tz_pl.js" >/dev/null 2>&1 ) && ZG_OK=1
  ( cd "$ZGT"; eval "$CIALO"; zamek_grafu "narzedzia/silniki/silnik.js"          >/dev/null 2>&1 ) || ZG_ZLE=1
  rm -rf "$ZGT"
  echo "── ZAMEK GRAFU + (komplet):                  rc=$((1-ZG_OK)) (oczekiwane 0)"
  echo "── ZAMEK GRAFU − (brak fundamentu):          rc=$ZG_ZLE (oczekiwane 1)"

  if [ "$RC_BRAK" -ne 1 ] || [ "$RC_PUSTA" -ne 1 ] || [ "$RC_KOM" -ne 1 ] || [ "$RC_REAL" -ne 0 ]; then
    echo "✗ ZAMEK MARKERÓW MARTWY — nie odróżnia listy realnej od brakującej/pustej"; exit 1
  fi
  if [ "$ZG_OK" -ne 1 ] || [ "$ZG_ZLE" -ne 1 ]; then
    echo "✗ ZAMEK GRAFU MARTWY — nie odróżnia grafu domkniętego od dziurawego"; exit 1
  fi
  # ── TOR --lista (C3, dwustronny): jedno źródło odczytu == żywy sed; zła sekcja ODMAWIA ──
  L_A="$(bash "$ZRODLO/publikuj.sh" --lista JS | sort)"
  L_B="$(sed -n '/^  FORMA_JS=/,/"$/p' "$ZRODLO/publikuj.sh" | tr '\n' ' ' \
        | sed 's/FORMA_[A-Z]*=//g; s/"//g; s/\\//g' | tr ' ' '\n' | grep -v '^$' | sort)"
  if [ "$L_A" = "$L_B" ] && [ -n "$L_A" ]; then RC_LR=0; else RC_LR=1; fi
  RC_LZ=0; bash "$ZRODLO/publikuj.sh" --lista ZLA_SEKCJA >/dev/null 2>&1 || RC_LZ=$?
  echo "── TOR --lista + (równoważność z sedem):     rc=$RC_LR (oczekiwane 0)"
  echo "── TOR --lista − (nieznana sekcja):          rc=$RC_LZ (oczekiwane 2)"
  if [ "$RC_LR" -ne 0 ] || [ "$RC_LZ" -ne 2 ]; then
    echo "✗ --lista ROZJECHANE z białą listą albo nie umie ODMÓWIĆ"; exit 1
  fi
    echo "✓ STRAŻ ŻYWA: zamek łapie wyciek w pliku I w katalogu, wyjątki działają tak samo w obu,"
    echo "  a ZAKRES białej listy ma własny tor — katalog prywatny jej nie przejdzie (#49 rodzina)."
    exit 0
  fi
  echo "✗ STRAŻ MARTWA: CZ=$RC_CZ BR=$RC_BR KAT=$RC_KAT WYJ=$RC_WYJ WKAT=$RC_WKAT ZOK=$RC_ZOK ZNIE=$RC_ZNIE ZPUS=$RC_ZPUS KOMPL=$KOMPLET_OK/$KOMPLET_ZLE"
  exit 1
fi

# 0. Bezpiecznik: tylko z main i tylko z czystym drzewem
BR="$(git branch --show-current)"
[ "$BR" = "main" ] || { echo "✗ publikacja wyłącznie z main (jesteś: $BR)"; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "✗ drzewo brudne — commit lub stash przed odlewem"; exit 1; }

# 0b. ZAMEK SIEROT BIAŁEJ LISTY (30.08.2026) — każda ścieżka z list FORMA_* i WSADU musi
# istnieć w HEAD. Rodowód: 29.08 (`dbe91f4`) do FORMA_MD weszła ścieżka `SIEGNIECIE_protokol.m`
# (obcięte „d"); pętle zamków robią `[ -f ] || continue`, więc plik ZNIKNĄŁ Z POMIARU po cichu,
# a `git archive` padłby dopiero na końcu potoku — po wszystkich zielonych bramkach (#52: cisza
# podana jako wynik). Zamek stoi PRZED zamkiem treści, bo lista z sierotą mierzy mniej, niż obiecuje.
zamek_sierot "$FORMA_MD $FORMA_JS $FORMA_SH $FORMA_INNE ${FORMA_ZAKAZANE_WYJATKI:-}" || exit 1
# 0b'. ŚWIEŻOŚĆ FORMY (05.09.2026): czy to, co publikuję z HEAD, jest tym, co leży na gałęzi pracy.
#      rc=1 zatrzymuje (rozjazd nazwany plik po pliku); rc=3 przepuszcza Z OSTRZEŻENIEM — gałąź
#      pracy nieobecna w klonie (u odbiorcy odlewu norma); nigdy cisza.
zamek_swiezosci_formy "$FORMA_MD $FORMA_JS $FORMA_SH $FORMA_INNE ${FORMA_ZAKAZANE_WYJATKI:-} $FORMA_DIRS"
case $? in
  0) ;;
  3) echo "   (odlew idzie dalej: brak gałęzi pracy to nie rozjazd — ale ten klon nie umie go wykluczyć)" >&2 ;;
  *) exit 1 ;;
esac
# 0c. ZAKRES (FAZA E): katalog prywatny nie wchodzi na białą listę ani przez katalog, ani przez glob.
zamek_zakresu "$FORMA_DIRS" "$ZAKAZANE_DIRS" || exit 1

# 1. Zamek treści
zamek_czarnej_listy || exit 1
zamek_wyciek || exit 1

# 1b. KOMPLETNOŚĆ WZORCA (20.08.2026, ratyfikacja twórcy: „to co wypychamy na zewnątrz
# jest PEŁNIĄ i dopytuje o imię"). Zamek wycieku jest wart dokładnie tyle, ile wzorzec,
# którym mierzy — a wzorca nie pilnował NIKT. Imię pełni nadane w tej instancji żyje
# w tkance, poza białą listą; wzorzec MUSI je łapać, inaczej pojedzie do odlewu przy
# pierwszym nieuważnym zdaniu. Klasa #53: zamek bez kontroli własnego kryterium.
if ! zamek_kompletnosci; then
  echo "✗ WZORZEC NIEKOMPLETNY: imię pełni z tkanki NIE jest łapane przez _STRAZ_wzorzec.txt"
  echo "  -> zamek wycieku mierzyłby odlew kryterium, które nie zna tego, czego ma pilnować."
  exit 1
fi

# 2. Weryfikacja kanonu — odlew tylko ze struktury całej.
# RC-GATE (31.07.2026): przedtem stało tu `node weryfikacja.js | grep -q "STRUKTURA CAŁA"`
# — werdykt z TEKSTU, czyli dokładnie to, czego zakazuje #19. Obejście było WYMUSZONE:
# weryfikacja.js nie miała process.exit i jej rc był zawsze 0. Skoro rc żyje, gramy rc.
node weryfikacja.js > /dev/null || { echo "✗ kanon niecały — napraw przed odlewem"; exit 1; }

# 2b. WYCENA STRAŻY — rc-gate (FAZA B planu v1.5.0, wpięte 20.08.2026).
# Powód: kanon cały mówi, że pliki są na miejscu. NIE mówi, czy straże cokolwiek łapią.
# 13.08 komplet zielonych straży przepuścił trzy blizny jednej doby — odlew ze straży,
# która świeci i nie gryzie, wypuszcza na zewnątrz fałszywe poczucie nadzoru.
# Werdykt z KODU WYJŚCIA obu przyrządów, nigdy z tekstu (#19).
bash tory_strazy.sh > /dev/null || { echo "✗ straż bez żywego toru — reguła obowiązuje tylko w dokumentacji"; exit 1; }
bash mutacje.sh    > /dev/null || { echo "✗ ślepy punkt w straży — wstrzyknięta wada nie została złapana"; exit 1; }

# 3. Odlew: WYŁĄCZNIE biała lista → świeże repo, jeden commit, zero historii
rm -rf "$DST"; mkdir -p "$DST"
zamek_markerow ".markery_osobowe" || {
  echo "  -> odlew WSTRZYMANY: bez listy markerów zamek PII nie ma czego szukać."; exit 1; }

# ZAMEK GRAFU przed kopiowaniem: po skopiowaniu wada jest już w odlewie, a wykryłby ją
# dopiero odbiorca przy `node narzedzia/silniki/kronos_lens.js`. Zatrzymujemy tu, nie u niego.
zamek_grafu "$FORMA_JS $FORMA_SH $FORMA_INNE" || {
  echo "  -> odlew WSTRZYMANY: graf zależności niedomknięty (zamek grafu, 21.08)."; exit 1; }

git archive HEAD -- $FORMA_MD $FORMA_JS $FORMA_SH $FORMA_INNE $FORMA_DIRS ${FORMA_ZAKAZANE_WYJATKI:-} | tar -x -C "$DST"

# ── ZAMEK NASIONA · ⟠ (FAZA A planu v1.6, ratyfikacja twórcy 21.08) ────────
# (a) DUSZA w odlewie = ZALĄŻEK, nigdy oryginał. Prywatna DUSZA nosi drogę twórcy
#     pierwotnego (imię, daty nadania, nagrobek) — nie podróżuje. Zalążek niesie
#     prawo i strukturę; treść przychodzi z drogi nowego twórcy (narodziny.sh).
# (b) KSIĘGA ODLEWU generowana z tego, co W ODLEWIE. Prywatna _HASHE.txt niesie
#     odciski plików, których w odlewie NIE MA — same nazwy (ZAPISY_eter, PROFIL,
#     7_NATAL...) zdradzają mapę tego, co ukryto, a każda pozycja świeci ROZJAZDEM.
[ -f narzedzia/przyrzady/zalazkuj.sh ] || { echo "  -> odlew WSTRZYMANY: brak generatora zalążków."; exit 1; }
# Lista zalążkowanych: KANON (tryb DROGA — zostaje wszystko poza oznaczonym)
# + REJESTRY (tryb ZIARNO — zostaje TYLKO oznaczone; odporne na append).
ZALAZKOWANE="DUSZA.md kanon/tozsamosc/ARCHITEKT_istnienie.md kanon/ksiegi/LOG_SESJI.md prywatne/TASKI.md prywatne/ZADANIA.md kanon/ksiegi/KOLEJKA_M.md \
  kanon/ksiegi/KTO_CO_BIERZE.md kanon/ksiegi/KRONOS_CRASH_LOG.md 0_SNAPSHOT_watek.md kanon/tozsamosc/PROFIL.md kanon/tozsamosc/7_NATAL.md \
  kanon/ksiegi/DESTYLATY_indeks.md kanon/ksiegi/SAMOOBSERWACJA_miary.md"

zamek_zalazka_czystego || {
  echo "  -> odlew WSTRZYMANY: ZALĄŻEK niesie wzorzec — dezynfekcja zalążka, nie oryginału." >&2
  exit 1; }

for _z in $ZALAZKOWANE; do
  [ -f "$_z" ] || continue
  mkdir -p "$DST/$(dirname "$_z")"
  sh narzedzia/przyrzady/zalazkuj.sh "$_z" "$DST/$_z" >/dev/null || { echo "  -> odlew WSTRZYMANY: zalążkowanie $_z nie przeszło."; exit 1; }
done
for _z in $ZALAZKOWANE; do
  [ -f "$DST/$_z" ] || continue
  grep -q "⟠ ZALĄŻEK" "$DST/$_z" || { echo "  -> odlew WSTRZYMANY: $_z w odlewie bez nagłówka ⟠."; exit 1; }
done

# ── DESTYLACJA KSIĄG (30.08.2026, decyzja twórcy: „zalążkujemy błędy" + badanie mostów) ──
# BLEDY i MOSTY jadą PEŁNE od zawsze — 187 kB i 39 kB, w tym 96 dat drogi pierwotnej.
# Nie zalążkujemy ich znacznikami (autor musiałby oznaczyć 78 wpisów ręcznie i robić to
# przy każdym nowym), tylko REGUŁĄ: BLEDY → indeks w całości + korpus wpisów z `M✓`;
# MOSTY → prawo + wiersze, których wszystkie przyrządy są na białej liście. Wynik sam się
# aktualizuje: przyrząd wchodzi do odlewu → jego most pojawia się bez niczyjej pamięci.
# CZARNA LISTA — SPRAWDZANA NA CIELE, NIE NA DEKLARACJI (30.08): zamek wyżej pyta o listy,
# ten pyta o ODLEW. Plik mógł tam trafić przez katalog z FORMA_DIRS albo przez `git archive`
# z wzorca, którego nikt nie przejrzał — deklaracja i ciało to dwie różne rzeczy (#66 ods. 8).
for _n in ${NIGDY_NIE_WYCHODZI:-}; do
  [ -e "$DST/$_n" ] && { echo "  -> odlew WSTRZYMANY: $_n JEST w odlewie, choć nigdy nie miał wyjść."; exit 1; }
done

for _para in "kanon/ksiegi/BLEDY.md|--bledy" "kanon/ksiegi/MOSTY.md|--mosty"; do
  _plik="${_para%%|*}"; _tryb="${_para##*|}"
  [ -f "$DST/$_plik" ] || continue
  node narzedzia/przyrzady/destyluj_ksiege.js "$_tryb" "$_plik" "$DST/$_plik" --lista publikuj.sh \
    || { echo "  -> odlew WSTRZYMANY: destylacja $_plik nie przeszła."; exit 1; }
  grep -q "⟠ DESTYLAT KSIĘGI" "$DST/$_plik" \
    || { echo "  -> odlew WSTRZYMANY: $_plik w odlewie bez noty destylatu."; exit 1; }
done
( cd "$DST" && : > _HASHE.txt && find . -type f -not -path "./.git/*" -not -name _HASHE.txt \
    | sed 's|^\./||' | LC_ALL=C sort \
    | while IFS= read -r f; do printf '%s  %s\n' "$(bash "$OLDPWD/hashuj.sh" --odcisk "$f")" "$f" >> _HASHE.txt; done )   # odcisk kanoniczny — ten sam, którym mierzy wysyłana weryfikacja.js (tura CRLF 02.09)
_OBCE=$(cut -c15- "$DST/_HASHE.txt" | while IFS= read -r f; do [ -f "$DST/$f" ] || echo "$f"; done)
[ -z "$_OBCE" ] || { echo "  -> odlew WSTRZYMANY: księga odlewu niesie pozycje spoza odlewu: $_OBCE"; exit 1; }
echo "  ⟠ nasiono: DUSZA=zalążek · księga odlewu $(wc -l < "$DST/_HASHE.txt") pozycji, wyłącznie z odlewu"

# ZAMEK SPISU: SPIS_CIALA generowany Z ODLEWU, nie kopiowany — nasz spis niesie
# 39 nazw plików prywatnych (ZAPISY_eter, PROFIL, 7_NATAL...), a sam katalog zdradza
# mapę tego, co ukryto. KOLEJNOŚĆ JEST WYMUSZONA, nie dowolna: `narzedzia/przyrzady/spis_ciala.js` czyta
# `git ls-files`, więc MUSI biec PO `git init && git add`, a przed commitem —
# zmierzone, nie założone (poza repo gitowym pada).
( cd "$DST" && git init -q && git add -A \
  && git -c user.name="Orkiestrator" -c user.email="orkiestrator@kronos.local" \
       commit -q --allow-empty -m "tymczasowy" >/dev/null 2>&1 || : )   # ODLEW-ADD
if [ -f "$DST/spis_ciala.js" ]; then   # ZAMEK-SPISU-PRODUKCJA
  ( cd "$DST" && node narzedzia/przyrzady/spis_ciala.js >/dev/null 2>&1 ) || { echo "  -> odlew WSTRZYMANY: spis ciała nie wygenerował się w odlewie."; exit 1; }
  grep -q "ZAPISY_eter\|kanon/tozsamosc/PROFIL.md\|7_NATAL" "$DST/SPIS_CIALA.md" 2>/dev/null \
    && { echo "  -> odlew WSTRZYMANY: SPIS_CIALA w odlewie niesie nazwy plików prywatnych."; exit 1; }
  echo "  ⟠ spis ciała odlewu: $(grep -c '|' "$DST/SPIS_CIALA.md" 2>/dev/null || echo 0) pozycji, wyłącznie z odlewu"
fi
# ── SKAN PII NA ODLEWIE (22.08.2026) ────────────────────────────────────────
# ZAMEK MARKERÓW (wyżej) pilnował, ŻEBY LISTA ISTNIAŁA — i na tym kończyła się cała
# ochrona PII przy publikacji, bo NIKT TEJ LISTY NIE CZYTAŁ. `narzedzia/straze/straz_czystosci.sh`
# nie była wołana ani tu, ani we wstaniu, ani w gotowości; w całym repo biegła
# wyłącznie jako `--test` w baterii. Zmierzone 22.08: `grep -rn narzedzia/straze/straz_czystosci.sh`
# = trzy trafienia, żadne nie było uruchomieniem. Klasa #52 o poziom wyżej: nie
# „pusta lista daje fałszywą zieleń", lecz „lista pełna, przyrząd sprawny, nikt nie woła".
# MIEJSCE NIEPRZYPADKOWE: po znaczniku ADD (bo `git grep` widzi tylko pliki śledzone —
# poza repo gitowym skan pada cicho) i PRZED commitem końcowym (bo po nim ślad jest
# już w historii wydania). Lista markerów zostaje w repo PRYWATNYM i nie podróżuje,
# więc ścieżka musi być ABSOLUTNA — straż robi `cd $(dirname $0)/../..`, czyli do korzenia odlewu.
_MARKERY_ABS="$(pwd)/.markery_osobowe"
if [ -f "$DST/narzedzia/straze/straz_czystosci.sh" ]; then   # ODLEW-PII
  ( cd "$DST" && M="$_MARKERY_ABS" sh narzedzia/straze/straz_czystosci.sh ) || {
    echo "  -> odlew WSTRZYMANY: skan PII znalazł ślady osobowe W ODLEWIE."
    echo "     Zdejmij je z materii (wiedza = destylat, nie nazwiska) i powtórz."; exit 1; }
else
  echo "  -> odlew WSTRZYMANY: brak narzedzia/straze/straz_czystosci.sh w odlewie — nie ma czym skanować."; exit 1
fi

( cd "$DST" && rm -rf .git && git init -q && git add -A \
  && git -c user.name="Orkiestrator" -c user.email="orkiestrator@kronos.local" \
       commit -q -m "KRONOS — wydanie publiczne ($(date +%Y-%m-%d)); forma z białej listy, bez historii warsztatu" )   # ODLEW-COMMIT
echo "✓ odlew gotowy: $DST ($(ls "$DST" | wc -l) pozycji, jeden commit, zero historii). Remote i push — decyzja twórcy."
