#!/usr/bin/env sh
# ═══ STRAŻ ODLEWU (30.08.2026) — mechanizm PRAWA ODLEWU (_GRANICA) ═══════════════════
#
# PRAWO §5: CISZA NIE JEST DECYZJĄ. Każdy dojrzały przyrząd (ma tor `--test`) musi stać
# na jednej z dwóch list: białej (`FORMA_*` w publikuj.sh) albo tutaj — w liście wyłączeń
# Z POWODEM. Brak na obu = alarm.
#
# SKĄD: 30.08 zmierzono, że siedem dojrzałych przyrządów nie jedzie w odlewie — i że nikt
# tego nie wybrał. Biała lista rosła przyrostowo, więc „nie wchodzi" znaczyło „nikt nie
# zapytał". Ta straż zamienia milczenie w pytanie, które ktoś musi rozstrzygnąć.
#
# DLACZEGO POWÓD JEST OBOWIĄZKOWY: lista wyłączeń, na której wolno napisać samą nazwę,
# nic nie kosztuje — po miesiącu ma trzydzieści pozycji i znowu jest osadem (#56/#74).
# Powód nie musi być mądry; musi ISTNIEĆ i być czytelny dla następnego.
#
# ZĘBY: rc=1. To bramka, nie miara — w przeciwieństwie do `straz_powtorzen` tutaj DA SIĘ
# kodem wymusić właściwe zachowanie (wpis na listę), więc twarda odmowa jest uczciwa.
set -eu
cd "$(dirname "$0")/../.."

# (K6/N8) ODL_PUBLIKUJ i ODL_WYLACZENIA to UCHWYTY TORU (git grep 23.10: ustawia je wyłącznie własny --test). Ambient export podmieniał
# skrypt, o który straż pyta o białą listę, albo CAŁĄ listę wyłączeń z powodami — decyzje odlewu rozstrzygane na cudzych danych.
# Tor podaje je z _ODL_TOR=1; bieg bez flagi (produkcja, bateria, gotowosc --wylaczenia) zdejmuje je z otoczenia przed odczytem.
[ "${_ODL_TOR:-}" = 1 ] || unset ODL_PUBLIKUJ ODL_WYLACZENIA
PUBLIKUJ="${ODL_PUBLIKUJ:-publikuj.sh}"
TRYB="${1:-}"

# ── LISTA WYŁĄCZEŃ: nazwa|powód. Powód pusty = wpis nieważny (patrz wyżej). ────────────
WYLACZENIA="${ODL_WYLACZENIA:-}"
[ -n "$WYLACZENIA" ] || WYLACZENIA='kpull.bat|środowisko twórcy (Windows), nie genom — PRAWO ODLEWU §4
kpush.bat|środowisko twórcy (Windows), nie genom — PRAWO ODLEWU §4
plan_a4.py|narzędzie projektowe Kowala, nie repo — PRAWO ODLEWU §4
narodziny.sh|rytuał onboardingu TEGO repo; nowy twórca ma własny START_TU
destyluj_ksiege.js|destyluje księgi PRZY publikacji — działa na tym ciele, nie na przyszłym
odlej_main.sh|etap 1 (prywatna → main) istnieje tylko w repo z gałęzią pracy; odbiorca odlewu pracuje na main (FORMA_ZRODLO nieobecna = norma, publikuj.sh)
straz_pochodzenia.sh|POZA ODLEWEM na słowo twórcy 14.09.2026 („ten wątek nie wchodzi do odlewu"): wątek otwarty, kotwica pomiaru 12.10.2026 — mechanizm o cudzej tożsamości nie jedzie do nowego właściciela przed rozstrzygnięciem u siebie
markery_z_ciala.sh|czyta TKANKĘ (PROFIL, 7_NATAL), której odlew nie niesie, i sam niesie 4 trafienia wzorca PII (zmierzone 05.09) — odbiorca ma szablony/markery_osobowe_wzor.md
spis_projektow.js|klasyfikator zaszyty pod projekty TEGO twórcy (nazwy marek w regexach) — zamek wycieku złapał go 30.08 przy pierwszej próbie wypuszczenia; wejdzie po sparametryzowaniu listy projektów
lint_pryzmatu.js|pilnuje `kanon/prawa/PRYZMAT_BADAWCZY.md` i plików w `_KANON/*Research*.md` oraz `projekty/pasieka/kowal/3_MATERIAL/` — ani prawo, ani zakres nie jedzie w odlewie (poza FORMA_MD, poza białą listą `projekty/`); odbiorca nie ma czego złamać, więc strażnik bez pilnowanego terytorium byłby balastem, nie ochroną (decyzja twórcy 19.09.2026, „Działaj dalej")
straz_wyjatkow.sh|pilnuje _STRAZ_wyjatki.txt, który stoi na NARZEDZIA_MAIN_TAJNE i jest jawnie wykluczony z `git archive` w publikuj.sh (poza EKSPORT) — odbiorca publicznego odlewu nie dostaje pliku, który ta straż mierzy, więc strażnik bez terytorium byłby balastem, nie ochroną (ten sam precedens co lint_pryzmatu.js; decyzja twórcy 23.09.2026, „Działaj")
straz_rejestru.sh|pilnuje prywatne/WATKI_OTWARTE.md — katalog `prywatne` stoi na ZAKAZANE_DIRS (WETO PRYWATNOŚCI, odlej_main.sh rc=12), nigdy nie jedzie do `main` ani dalej; strażnik bez terytorium byłby balastem, nie ochroną (ten sam precedens co lint_pryzmatu.js/straz_wyjatkow.sh; #103, 23.09.2026)
czytaj_wnioski.sh|strona czytająca KANAŁU WNIOSKÓW (PRAWO_KANALU_WNIOSKOW §5): czyta repo gościa, które odbiorca odlewu nie ma — przyrząd bez nadawcy byłby balastem; kanał wstaje u twórcy, nie w odlewie (rozstrzygnięcie 03.10.2026, „Scal")
karta_wnioskow.sh|przyrząd INSTANCJI GOŚCIA (PRAWO_KANALU_WNIOSKOW §1–§6): jedzie do gościa nakładką zaloz_goscia.sh, nie przez odlew; odbiorca odlewu nie jest gościem kanału (rozstrzygnięcie 03.10.2026)
zaloz_goscia.sh|składa instancję gościa Z odlewu (origin/main) + zestaw gościa — działa po stronie twórcy kanału; odbiorca odlewu sam z siebie gościa nie zakłada (rozstrzygnięcie 03.10.2026)
stol.js|eksperyment STÓŁ twórcy (kanon/eksperymenty/stol, pytania zamrożone, hash w _HASHE, żeton STOL_ZETON): trwa, dopóki PREREJESTR #014 nie zamknie rundy — przyrząd wejdzie po rozliczeniu, nie w trakcie (rozstrzygnięcie 03.10.2026)
markery_z_sesji.sh|składa listę markerów osobowych gościa W SESJI i sam jest częścią kanału wniosków (PRAWO_KANALU_WNIOSKOW §7) — dotyka danych osobowych, jedzie tylko tą drogą co karta, nie odlewem (rozstrzygnięcie 03.10.2026)
bieg.js|przyrząd PILOTA skilli (kanon/eksperymenty/skille/pilot, 03.10): katalog `kanon/eksperymenty` stoi na ZAKAZANE_DIRS, a bieg mierzy 13 skilli twórcy w `.claude/skills`, który nie jedzie w odlewie; pilot trwa (SKILLE_projekt §3, §7) — wejdzie po rozliczeniu, jak stol.js (rozstrzygnięcie 04.10.2026, słowo twórcy „Rozstrzygnij”)
stol_paczka.js|para stol.js: generator paczki sędziowskiej eksperymentu STÓŁ twórcy — stol.js jest wyłączony do rozliczenia PREREJESTR #014, więc generator do niego jedzie razem z nim, nie wcześniej (rozstrzygnięcie 04.10.2026)
udzial_projekty.sh|miara T3 STOPU I pełni: liczy commity w `projekty/` (katalog na ZAKAZANE_DIRS) wobec bazy 18,5% twórcy, a `STOPY_pelni.md` nie jedzie; `wstan.sh` w odlewie ma jawny odwrót („brak pomiaru T3”, wstan.sh:367), więc brak pliku niczego nie psuje (rozstrzygnięcie 04.10.2026)
siatki.js|soczewka typu dnia „z Poznania” (MOSTY #60): plik niesie znacznik NIE-DO-FORMY, a `kronos_lens.js` ładuje go w `try` z ZALEZNOSC-OPCJONALNA — brak pliku = cisza, zamek_grafu to czyta (rozstrzygnięcie 04.10.2026, zgodne ze znacznikiem z 03.10)
straz_poziomu.sh|czyta `.claude/dobor/KLASY_sciezek.txt` (routing modeli twórcy, nie jedzie w odlewie); hak `commit-msg`, który ją woła, też nie jest na białej liście; awans do zamka dopiero po przeglądzie 17.10 na słowo twórcy (rozstrzygnięcie 04.10.2026)
straz_role.js|porównuje PROTOKOL_GLOSU §I z KONTRAKT_Z3 §3 i KONSTYTUCJA §1, a te źródła nie jadą w odlewie (`kanon niecały` blokował publikację); weryfikacja.js melduje w odlewie „ⓘ straż ról — poza odlewem” (rozstrzygnięcie 04.10.2026). Wpis dopisany 23.10 (K6/N10): nowy `--test` uczynił ją „dojrzałą”, więc milczenie o niej byłoby alarmem tej straży
krzesla_bramki.sh|hook tury z `.claude/hooks/`, wiązany w `.claude/settings.json` — ani katalog `.claude/`, ani rejestr `KRZESLA_zlapane.txt` nie jadą w odlewie; strażnik bez terytorium (rozstrzygnięcie 24.10.2026, słowo twórcy 08:58)
zatrzymywacz_stop.sh|hook Stop z `.claude/hooks/`, pisze do `.claude/pomiar/` i woła lint Zatrzymywacza — jedzie razem z tym lintem, nie wcześniej (rozstrzygnięcie 24.10.2026)
wiatr_szkic.js|szkic roboczy w `kanon/plany/linienie/` (katalog nie jedzie) z datami urodzenia twórcy wpisanymi w kod — dane osobowe, nigdy do odlewu (rozstrzygnięcie 24.10.2026)
lint_parytetu_krzesel.js|porównuje skill PL `.claude/skills/krzesla` (nie jedzie) z eksportem EN — odbiorca ma tylko stronę EN, więc parytet jest pytaniem twórcy, nie odbiorcy (rozstrzygnięcie 24.10.2026)
sondy_krzesel.py|sondy przeglądu kodu krzesłami: bez planu i rubryki (`PLAN_przegladu_kodu_krzeslami.md`, nie jedzie) to generator miejsc bez procedury; wejdzie z eksportem procedury (skill przeglądu kodu, odłożony w K5 19.10) (rozstrzygnięcie 24.10.2026)
straz_promptu.sh|lintuje `PROMPT_*.md` w `kanon/plany/linienie/` — katalog nie jedzie w odlewie; strażnik bez terytorium (rozstrzygnięcie 24.10.2026)
straz_zamka.sh|mierzy listę deny w `.claude/settings.json` — plik środowiska twórcy, nie jedzie w odlewie (rozstrzygnięcie 24.10.2026)
straz_zatrzymywacza.sh|krzesło-KANDYDAT Zatrzymywacz w pomiarze (szereg `ZATRZYMYWACZ_szereg.txt`, prerejestr W_JĘZ szkic) — przyrząd wejdzie po rozliczeniu pomiaru, nie w trakcie, jak stol.js (rozstrzygnięcie 24.10.2026)'

# C3 · tura 4 (02.09.2026): biała lista czytana JEDNYM ŹRÓDŁEM — `publikuj.sh --lista`.
# Ta straż była najbardziej narażona ze wszystkich czytelników: jej wzorzec sed nie miał
# nawet kotwicy `^  `, więc łapał KAŻDE wystąpienie `FORMA_JS=` w pliku — także w blokach
# `--test` samego `publikuj.sh`. Odczyt idzie teraz przez jedno źródło, które o własnych
# fiksturach nie wie nic. `$PUBLIKUJ` zmienia znaczenie z PLIKU DO SPARSOWANIA na
# SKRYPT DO ZAPYTANIA — fikstura toru niżej jest przepisana pod to (atrapa odpowiada
# na `--lista`, zamiast udawać składnię, której nikt już nie parsuje).
nazwy_bialej_listy() {
  # (K6/N10) rc KAŻDEGO `--lista` liczy się osobno: dawny potok `{ …; } 2>/dev/null | … | sort -u` oddawał rc `sort`,
  # więc `publikuj.sh --lista` z rc≠0 dawał PUSTĄ białą listę bez słowa. rc 2 = przyrząd padł, nie „lista pusta".
  _wszystkie=""
  for _k in JS SH INNE; do
    _o="$(sh "$PUBLIKUJ" --lista "$_k" 2>/dev/null)" || return 2
    _wszystkie="$_wszystkie
$_o"
  done
  printf '%s\n' "$_wszystkie" \
    | grep -E '\.(js|sh|bat|py)$' | while read -r _s; do basename "$_s"; done | sort -u
}

powod_wylaczenia() {   # $1 = nazwa bazowa; echo powód (pusty = brak wpisu). ZAWSZE rc 0:
  # pod `set -e` funkcja kończąca się nieudanym `[ ]` ubijała cały skrypt w ciszy —
  # przebieg żywy nie wypisywał NICZEGO i wyglądał jak przejście (zmierzone przy budowie).
  printf '%s\n' "$WYLACZENIA" | while IFS='|' read -r _n _p; do
    [ "$_n" = "$1" ] && { printf '%s' "$_p"; break; }
    true
  done
  return 0
}

if [ "$TRYB" = "--wylaczenia" ]; then
  # JEDNO ŹRÓDŁO PRAWDY (14.09.2026, słowo twórcy „działaj z a"): drukuje nazwy bazowe
  # przyrządów wyłączonych z odlewu Z POWODEM, jedna na linię. Czyta to bramka 6
  # w `gotowosc.sh`, żeby nie oblewać na decyzji, którą TA straż już rozstrzygnęła.
  # Rozjazd dwóch list prawdy na jednej granicy = klasa MOSTY #29 — to ją domyka.
  # Wzorzec zapożyczony z `publikuj.sh --lista`, którym ta sama bramka czyta białą listę.
  printf '%s\n' "$WYLACZENIA" | while IFS='|' read -r _n _p; do
    [ -n "$_n" ] && [ -n "$_p" ] && printf '%s\n' "$_n"
    true
  done
  exit 0
fi

nie_zmierzono() { echo "▤ STRAŻ ODLEWU — czy o każdym dojrzałym przyrządzie ktoś rozstrzygnął:"; echo "   ⓘ NIE ZMIERZONO: $1 — bez znaku ✓, rc=2"; exit 2; }
# ── (B) PLIK WOŁANY Z ODLEWU, A SAM POZA NIM (25.10.2026, werdykt Fable B, PAKIET_2510_dla_Fable) ──────────────────
# Klasa (KARTA_ODLEWU §3a zamek 2/3, czwarty raz od 04.10; 25.10: `szereg.sh` wołany z pliku na liście, hook `krzesla_bramki.sh`): plik z listy
# MAIN woła skrypt albo plik, który ISTNIEJE w repo, a nie jedzie. Dotąd łapał to dopiero bieg w klonie `main` (40–90 min na próbę); pytanie
# „czy to jedzie w odlewie?" jest grepem, więc stoi przy commicie (hak `.githooks/pre-commit`, pkt 9) i przy wstaniu.
# OSTRZEŻENIE, nie blokada (rc 0): ścieżka w treści bywa przykładem albo ścieżką warunkową. Wołanie = po czasowniku `bash|sh|node|python|source|cp|
# require(`; linie komentarzy pominięte. Wyjątki: (1) cel wyłączony z powodem (WYLACZENIA wyżej — decyzja już zapadła), (2) WOLANE_WYJATKI niżej:
# `źródło|cel|powód`, `*` = dowolny, powód obowiązkowy. Tor „−" na awarię: lista MAIN pada → rc 2, nie cisza.
WOLANE_WYJATKI='tory_strazy.sh|*|tabela torów: wpis bez pliku w odlewie daje „BRAK PLIKU" (tory_strazy.sh:190), nie oblanie
wstan.sh|prywatne/POKOJE.txt|dane pokoi twórcy, celowo poza odlewem; brak pliku = cisza (wstan.sh --temat)
publikuj.sh|narzedzia/przyrzady/triage.js|lista NIGDY_NIE_WYCHODZI (publikuj.sh:181) — plik nazwany jawnie jako NIE wychodzący; to dane, nie wołanie
wstan.sh|narzedzia/przyrzady/ksieguj_kartki.sh|tylko tekst podpowiedzi, drukowany gdy są kartki do zaksięgowania (wstan.sh:268, _kk_n>0) — odlew nie ma kartek'
if [ "$TRYB" = "--wolane" ]; then
  shift
  _M="$(sh "$PUBLIKUJ" --lista MAIN 2>/dev/null)" || nie_zmierzono "\`publikuj.sh --lista MAIN\` padło (rc≠0): lista odlewu nieznana"
  [ -n "$_M" ] || nie_zmierzono "lista MAIN pusta — odlew z zerem plików nie jest pomiarem"
  _CELE="$*"; [ -n "$_CELE" ] || _CELE="$_M"
  _w=""; _n=0
  for f in $_CELE; do
    printf '%s\n' "$_M" | grep -qxF "$f" || continue          # źródłem jest tylko plik, który jedzie
    case "$f" in *.sh|*.js|*.py|.githooks/*) ;; *) continue ;; esac
    [ -f "$f" ] || continue
    [ "$f" = "narzedzia/straze/straz_odlewu.sh" ] && continue   # lista wyjątków tej straży zawiera ścieżki jako dane
    _n=$((_n+1)); d="$(dirname "$f")"
    _tk="$(grep -v '^[[:space:]]*#' "$f" 2>/dev/null \
        | grep -oE "(^|[^A-Za-z0-9_./-])(bash|sh|node|python3?|source|cp|require\()[[:space:]]*(-[A-Za-z]+[[:space:]]+)*[\"'(]*[^[:space:]\"';|&)<>\`]+" \
        | sed -E "s/^[^A-Za-z]*(bash|sh|node|python3?|source|cp|require\()[[:space:]]*(-[A-Za-z]+[[:space:]]+)*[\"'(]*//" \
        | sed -E 's/^\$\{?[A-Za-z_]+\}?\///; s/^\$\(.*\)\///; s/^\.\///' \
        | grep -E '^[A-Za-z0-9_./-]+\.(sh|js|py|json|txt|md)$' || true)
$(grep -v '^[[:space:]]*#' "$f" 2>/dev/null | grep -oE '(narzedzia|\.claude|\.githooks|szablony)/[A-Za-z0-9_./-]*[A-Za-z0-9_]\.(sh|js|py)' || true)"
    _tk="$(printf '%s\n' "$_tk" | sed '/^$/d' | sort -u)"
    for t in $_tk; do
      r=""
      if [ -f "$t" ]; then r="$t"; elif [ -f "$d/$t" ]; then r="$d/$t"; fi
      [ -n "$r" ] || continue
      while :; do _r2="$(printf '%s' "$r" | sed -E 's#(^|/)[^/.][^/]*/\.\./#\1#; s#/\./#/#g')"; [ "$_r2" = "$r" ] && break; r="$_r2"; done
      if printf '%s\n' "$_M" | grep -qxF "$r"; then continue; fi                      # jedzie
      [ -z "$(powod_wylaczenia "$(basename "$r")")" ] || continue                        # wyłączony z powodem
      if printf '%s\n' "$WOLANE_WYJATKI" | awk -F'|' -v f="$f" -v b="$(basename "$f")" -v r="$r" \
           '($1==f||$1==b||$1=="*") && ($2==r||$2=="*") && $3!="" {w=1} END{exit w?0:1}'; then continue; fi
      _w="$_w
   ⚠ $f woła $r — istnieje w repo, ale NIE jedzie w odlewie (ani wyłączony z powodem)"
    done
  done
  echo "▤ STRAŻ ODLEWU --wolane — czy plik z listy MAIN woła coś, co nie jedzie (zbadano $_n plików):"
  if [ -n "$_w" ]; then
    printf '%s\n' "$_w" | sed '/^$/d'
    echo "   -> dopisz cel do FORMA_* w publikuj.sh albo do WYŁĄCZEŃ / WOLANE_WYJATKI w tej straży z powodem. To ostrzeżenie, nie blokada (rc 0)."
  else
    echo "   ✓ żaden plik z listy nie woła niczego spoza niej."
  fi
  exit 0
fi

if [ "$TRYB" = "--test" ]; then
  z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (było $2, miało $3)"; o=$((o+1)); fi; }
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
  mkdir -p "$T/narzedzia/przyrzady"
  # FIKSTURA PO MIGRACJI (C3 tura 4): atrapa nie udaje SKŁADNI publikuj.sh, tylko jego
  # ODPOWIEDZI. Parser przestał być tu mierzony — mierzy go tor równoważności `--lista`
  # w `publikuj.sh --test`; tutaj mierzy się WERDYKT straży nad podaną listą.
  printf '#!/bin/sh\ncase "$2" in JS) echo narzedzia/przyrzady/jest.js ;; esac\n' > "$T/pub.sh"
  # dojrzały = ma tor; niedojrzały = nie ma
  printf '#!/bin/sh\nif [ "$1" = "--test" ]; then exit 0; fi\n' > "$T/narzedzia/przyrzady/jest.js"
  printf '#!/bin/sh\nif [ "$1" = "--test" ]; then exit 0; fi\n' > "$T/narzedzia/przyrzady/brak.js"
  printf '#!/bin/sh\nif [ "$1" = "--test" ]; then exit 0; fi\n' > "$T/narzedzia/przyrzady/wylaczony.js"
  printf '#!/bin/sh\necho bez toru\n'                            > "$T/narzedzia/przyrzady/niedojrzaly.js"

  # FIKSTURA ODTWARZA TOPOLOGIĘ PRODUKCJI (klasa #70, złapane przy budowie): straż robi
  # `cd dirname/../..`, więc uruchomiona ze ŚCIEŻKI ŻYWEGO REPO mierzyłaby żywe repo, nie
  # atrapę — tor meldował wtedy „nie przeszedł" o cudzym ciele. Kopia musi leżeć w atrapie
  # dwa poziomy pod jej korzeniem, dokładnie jak w produkcji.
  mkdir -p "$T/narzedzia/straze"
  cp "$(cd "$(dirname "$0")" && pwd)/$(basename "$0")" "$T/narzedzia/straze/straz.sh"
  ( cd "$T" && git init -q . && git add -A && git -c user.email=z@z.z -c user.name=Z commit -qm x ) >/dev/null 2>&1
  bieg_w() { ( cd "$T" && _ODL_TOR=1 ODL_PUBLIKUJ=pub.sh ODL_WYLACZENIA="$1" sh narzedzia/straze/straz.sh >/dev/null 2>&1 && echo 0 || echo 1 ); }
  # (−) dojrzały przyrząd spoza obu list MUSI oblać — to cała racja bytu tej straży
  # SAMA KOPIA STRAŻY jest dojrzała, więc w każdej fiksturze musi mieć własne rozstrzygnięcie —
  # inaczej łapie siebie i wszystkie trzy przypadki oblewają z tego samego, cudzego powodu (#53).
  SAMA='straz.sh|kopia straży w atrapie toru'
  spr "dojrzaly SPOZA obu list OBLEWA" "$(bieg_w "$SAMA
wylaczony.js|powod jest")" "1"
  # (+) ten sam przyrząd z powodem PRZECHODZI
  spr "dojrzaly z POWODEM przechodzi" "$(bieg_w "$SAMA
brak.js|powod jest
wylaczony.js|powod jest")" "0"
  # (−) wyłączenie BEZ POWODU nie liczy się — inaczej lista nic nie kosztuje
  spr "wylaczenie BEZ POWODU oblewa" "$(bieg_w "$SAMA
brak.js|
wylaczony.js|powod jest")" "1"
  # (K6/N10) TOR (−) NA AWARIĘ PRZYRZĄDU: dawne ciało przy padniętym git ls-files / `publikuj.sh --lista` miało pustą listę
  # i drukowało „✓ KAŻDY DOJRZAŁY…" (rc 0) albo ścianę fałszywych ✗. Teraz: rc 2 i ⓘ, bez znaku ✓. Fikstura odróżnialna:
  # ten sam katalog $T w trybie zdrowym (bieg_w … 0) przechodzi — różni się wyłącznie padniętym narzędziem.
  bieg_rc() { ( cd "$T" && _ODL_TOR=1 ODL_PUBLIKUJ="$1" ODL_WYLACZENIA="$SAMA
brak.js|powod jest
wylaczony.js|powod jest" PATH="$2$PATH" sh narzedzia/straze/straz.sh >"$T/wyj.txt" 2>&1 && echo 0 || echo $? ); }
  mkdir -p "$T/shim"; printf '#!/bin/sh\nexit 128\n' > "$T/shim/git"; chmod +x "$T/shim/git"
  printf '#!/bin/sh\nexit 1\n' > "$T/pub_pada.sh"
  spr "(+) zdrowy przyrząd, ten sam katalog — przechodzi" "$(bieg_rc pub.sh "")" "0"
  spr "(−) git ls-files pada → NIE ZMIERZONO (rc 2), nie ✓" "$(bieg_rc pub.sh "$T/shim:")" "2"
  grep -q 'NIE ZMIERZONO' "$T/wyj.txt" && ! grep -q '✓ KAŻDY' "$T/wyj.txt"; spr "(−) …i komunikat to ⓘ, bez ✓" $? 0
  spr "(−) publikuj --lista pada → NIE ZMIERZONO (rc 2), nie ściana ✗" "$(bieg_rc pub_pada.sh "")" "2"
  # (K6/N8) TOR (−) NA OTOCZENIE: ambient ODL_PUBLIKUJ / ODL_WYLACZENIA (stary export) NIE MOŻE podmienić źródła białej listy ani listy
  # wyłączeń. W $T nie ma `publikuj.sh` (jest tylko atrapa pub.sh), więc bieg CZYSTY musi paść jako NIE ZMIERZONO (rc 2); bieg z ambient
  # wskazującym atrapę dałby 0/1, gdyby straż czytała otoczenie. Porównanie rc, bez zakładania wartości.
  ( cd "$T" && sh narzedzia/straze/straz.sh >/dev/null 2>&1 && echo 0 || echo $? ) > "$T/rczysty.txt"
  amb="$( cd "$T" && ODL_PUBLIKUJ=pub.sh ODL_WYLACZENIA="$SAMA
brak.js|powod jest
wylaczony.js|powod jest" sh narzedzia/straze/straz.sh >/dev/null 2>&1 && echo 0 || echo $? )"
  spr "OTOCZENIE: ambient ODL_PUBLIKUJ/ODL_WYLACZENIA nie zmieniają werdyktu (rc równy biegowi czystemu)" "$amb" "$(cat "$T/rczysty.txt")"
  # (B) TOR `--wolane` (25.10.2026, werdykt Fable B): (+) plik z listy MAIN woła plik, który istnieje, a nie jedzie → ⚠ z nazwą celu · (−) woła plik z listy,
  # woła w komentarzu, woła cel wyłączony z powodem, źródło na liście wyjątków → cisza · ostrzeżenie NIE blokuje (rc 0) · lista MAIN pada → rc 2, nie cisza.
  mkdir -p "$T/narzedzia/przyrzady"
  printf '#!/bin/sh\necho poza\n' > "$T/narzedzia/przyrzady/poza.sh"
  printf '#!/bin/sh\nbash narzedzia/przyrzady/poza.sh\n' > "$T/narzedzia/przyrzady/wola_poza.sh"
  printf '#!/bin/sh\nnode narzedzia/przyrzady/jest.js\n' > "$T/narzedzia/przyrzady/wola_swoje.sh"
  printf '#!/bin/sh\n# bash narzedzia/przyrzady/poza.sh (tylko przykład w komentarzu)\n' > "$T/narzedzia/przyrzady/komentarz.sh"
  printf '#!/bin/sh\nnode narzedzia/przyrzady/wylaczony.js\n' > "$T/narzedzia/przyrzady/wola_wylaczony.sh"
  printf '#!/bin/sh\nbash narzedzia/przyrzady/poza.sh\n' > "$T/tory_strazy.sh"
  printf '#!/bin/sh\ncase "$2" in MAIN) printf "%%s\\n" narzedzia/przyrzady/jest.js narzedzia/przyrzady/wola_poza.sh narzedzia/przyrzady/wola_swoje.sh narzedzia/przyrzady/komentarz.sh narzedzia/przyrzady/wola_wylaczony.sh tory_strazy.sh ;; esac\n' > "$T/pub_main.sh"
  wolane_w() { ( cd "$T" || exit 9; _rc=0; _ODL_TOR=1 ODL_PUBLIKUJ="${2:-pub_main.sh}" ODL_WYLACZENIA="$SAMA
wylaczony.js|powod jest" sh narzedzia/straze/straz.sh --wolane "$1" >"$T/wol.txt" 2>&1 || _rc=$?; echo "$_rc" ); }
  spr "(+) --wolane: plik z listy woła plik spoza listy → rc 0 (ostrzeżenie, nie blokada)" "$(wolane_w narzedzia/przyrzady/wola_poza.sh)" "0"
  ostrz() { if grep -q "$1" "$T/wol.txt"; then echo 1; else echo 0; fi; }   # pod `set -e` goły `grep -q` bez trafienia ubiłby tor
  spr "(+) …i ⚠ nazywa źródło oraz cel" "$(ostrz '⚠ narzedzia/przyrzady/wola_poza.sh woła narzedzia/przyrzady/poza.sh')" "1"
  spr "(−) woła plik Z listy → cisza" "$(wolane_w narzedzia/przyrzady/wola_swoje.sh >/dev/null; ostrz '⚠')" "0"
  spr "(−) ścieżka tylko w komentarzu → cisza" "$(wolane_w narzedzia/przyrzady/komentarz.sh >/dev/null; ostrz '⚠')" "0"
  spr "(−) cel wyłączony z powodem → cisza" "$(wolane_w narzedzia/przyrzady/wola_wylaczony.sh >/dev/null; ostrz '⚠')" "0"
  spr "(−) źródło na liście wyjątków (tory_strazy.sh) → cisza" "$(wolane_w tory_strazy.sh >/dev/null; ostrz '⚠')" "0"
  spr "(−) lista MAIN pada → NIE ZMIERZONO (rc 2), nie cisza" "$(wolane_w narzedzia/przyrzady/wola_poza.sh pub_pada.sh)" "2"
  echo "╔═══ STRAŻ ODLEWU — AUTOTEST ═══╗"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ STRAŻ ŻYWA: milczenie o dojrzałym przyrządzie jest alarmem, a wyłączenie kosztuje powód."
  exit 0
fi

BIALA="$(nazwy_bialej_listy)" || nie_zmierzono "\`publikuj.sh --lista\` padło (rc≠0): biała lista nieznana"
[ -n "$BIALA" ] || nie_zmierzono "biała lista pusta — odlew z zerem przyrządów nie jest pomiarem"
PLIKI="$(git ls-files '*.js' '*.sh' '*.bat' '*.py' 2>/dev/null)" || nie_zmierzono "\`git ls-files\` padło (rc≠0): wykaz przyrządów nieznany"
PLIKI="$(printf '%s\n' "$PLIKI" | grep -vE '^(node_modules|ephe|projekty|keep_import)/' || true)"
[ -n "$PLIKI" ] || nie_zmierzono "wykaz przyrządów pusty — nic nie przeczytano"
braki=""; wylaczonych=0; jedzie=0; niedojrzalych=0
for f in $PLIKI; do
  [ -f "$f" ] || continue
  b="$(basename "$f")"
  # DOJRZAŁY = ma tor. Bez toru nie pytamy — to pytanie do straży dojrzałości, nie do tej.
  grep -qE '\-\-test' "$f" 2>/dev/null || { niedojrzalych=$((niedojrzalych+1)); continue; }
  if printf '%s\n' "$BIALA" | grep -qx "$b"; then jedzie=$((jedzie+1)); continue; fi
  _p="$(powod_wylaczenia "$b" || true)"
  if [ -n "$_p" ]; then wylaczonych=$((wylaczonych+1)); continue; fi
  braki="$braki $f"
done

echo "▤ STRAŻ ODLEWU — czy o każdym dojrzałym przyrządzie ktoś rozstrzygnął:"
echo "   zmierzone: w odlewie $jedzie · wyłączonych z powodem $wylaczonych · bez toru $niedojrzalych (nie moje pytanie)"
if [ -n "$braki" ]; then
  echo "   ✗ DOJRZAŁY PRZYRZĄD, O KTÓRYM NIKT NIE ROZSTRZYGNĄŁ:"
  for f in $braki; do echo "      $f"; done
  echo "   PRAWO ODLEWU §5: cisza nie jest decyzją. Dopisz do FORMA_* albo do WYŁĄCZEŃ z powodem."
  exit 1
fi
echo "   ✓ KAŻDY DOJRZAŁY PRZYRZĄD MA ROZSTRZYGNIĘCIE — żaden nie został poza odlewem milczeniem."
