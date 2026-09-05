#!/usr/bin/env bash
# ═══ STRAŻ LINTÓW — egzekutor blizny #61 (RÓŻNICA, nie stan) ═══
#
# RODOWÓD: blizna #61 (20.08.2026). Przyjmując żniwo drugiej instancji sprawdziłem
# wszystkie ZADEKLAROWANE liczby i żadnej niezadeklarowanej — `lint_artefaktow` urósł
# 1→2 i PRZEŻYŁ COMMIT. Kandydat M zapisany tego wieczoru do `KOLEJKA_M`:
#   „rc≠0 gdy licznik któregokolwiek lintu WZRÓSŁ względem poprzedniego commitu".
#
# DLACZEGO RÓŻNICA, A NIE STAN: bramka na stan („zero naruszeń albo nie wpuszczam")
# karałaby zastany dług i wymuszałaby wyjątki — dokładnie ta pętla, która zabiła
# bramkę 1 (aparat wyjątków większy niż reguła). Bramka na RÓŻNICĘ przepuszcza dług
# odziedziczony i zatrzymuje wyłącznie POGORSZENIE. Nie trzeba jej żadnego wyjątku.
#
# CO MIERZY: liczbę linii sygnalizujących naruszenie (✗ / ⚠) w wyjściu każdego lintu,
# osobno dla DRZEWA ROBOCZEGO i dla HEAD. Licznik jest ślepy na format konkretnego
# lintu — celowo: straż, która zna wewnętrzny format czterech narzędzi, psuje się
# przy każdej zmianie druku i uczy tego samego co cisza (#56).
#
# UWAGA #50 (tor mierzący własną kopię): stan HEAD zdejmowany jest `git archive`,
# czyli z OBIEKTÓW gita, nie z żadnej kopii trzymanej przez ten skrypt.
#
# UŻYCIE:  bash straz_lintow.sh          (rc=1 przy wzroście któregokolwiek licznika)
#          bash straz_lintow.sh --test   (tor +/− — straż musi umieć NIE przejść)
set -u

LINTY_NODE="${LINTY_NODE:-narzedzia/linty/lint_bledy.js narzedzia/linty/lint_artefaktow.js narzedzia/linty/lint_sciezek.js narzedzia/linty/lint_klas_znakow.js}"
LINTY_BASH="${LINTY_BASH:-narzedzia/straze/straz_interpolacji.sh}"
# LINTY_LICZBA (21.08.2026) — przyrządy, które SAME podają licznik przez `--liczba`.
# POWÓD: `straz_duszy.sh` była sierotą tej straży. Dopisanie jej do LINTY_BASH dałoby
# licznik stale równy 1, bo `policz_naruszenia()` zlicza LINIE z ✗/⚠, a ta straż drukuje
# jedną zbiorczą linię przy 18, 19 czy 40 niezmapowanych księgach — regres byłby
# NIEWIDOCZNY, a straż meldowałaby zielono. Zliczanie po glifach mierzy WYGLĄD WYJŚCIA;
# ta kategoria mierzy to, co przyrząd naprawdę policzył.
#
# UZBROJONA 21.08 wieczorem, gdy licznik zszedł do zera: §IV przestało być spisem
# (przejął go generowany `kanon/ksiegi/SPIS_CIALA.md`), więc `straz_duszy` zmierzyła 19 → 0
# i wpięcie przeszło CZYSTO — bez `--no-verify` i bez zmiany reguły `porownaj()`.
# Ta kolejność była celowa. Wpięcie PRZED spłatą dawało `0 → 19` i zatrzymywało
# commit zamkiem #61, bo `porownaj` czyta brak wpisu w HEAD jako zero, a tor tej
# straży ratyfikuje takie zachowanie („nowy lint z naruszeniem oblewa"). Reguła jest
# słuszna dla długu WNIESIONEGO i myląca dla ZASTANEGO; tego rozróżnienia w kanonie
# nadal nie ma i czeka na decyzję twórcy — ale nie musiało blokować tej roboty.
LINTY_LICZBA="${LINTY_LICZBA:-straz_duszy.sh}"

# ── licznik naruszeń jednego przebiegu: linie z ✗ albo ⚠, nigdy ✓ ani ⓘ ──
policz_naruszenia() {   # $1 = tekst wyjścia
  printf '%s\n' "$1" | grep -c '✗\|⚠' || true
}

# ── zmierz komplet lintów w KATALOGU $1; drukuje "nazwa liczba" po jednej na linię ──
zmierz_katalog() {
  local kat="$1" n out
  for n in $LINTY_NODE; do
    if [ -f "$kat/$n" ]; then
      out="$(cd "$kat" && node "$n" 2>&1)"
      echo "$n $(policz_naruszenia "$out")"
    fi
  done
  for n in $LINTY_BASH; do
    if [ -f "$kat/$n" ]; then
      out="$(cd "$kat" && bash "$n" 2>&1)"
      echo "$n $(policz_naruszenia "$out")"
    fi
  done
  for n in $LINTY_LICZBA; do
    if [ -f "$kat/$n" ]; then
      out="$(cd "$kat" && bash "$n" --liczba 2>/dev/null | tail -1)"
      case "$out" in
        (""|*[!0-9]*)
          # wersja bez trybu `--liczba` (np. z HEAD) odpowiada tekstem użycia —
          # to BRAK POMIARU, nie zero naruszeń. Nie emitujemy wiersza.
          : ;;
        (*) echo "$n $out" ;;
      esac
    fi
  done
}

# ── porównaj dwa pomiary; rc=1 gdy KTÓRYKOLWIEK licznik wzrósł ──
porownaj() {          # $1 = pomiar PRZED (HEAD), $2 = pomiar PO (drzewo)
  local przed="$1" po="$2" zle=0 nazwa a b
  while read -r nazwa b; do
    [ -z "$nazwa" ] && continue
    a="$(printf '%s\n' "$przed" | awk -v k="$nazwa" '$1==k {print $2; exit}')"
    # UWAGA 21.08.2026: kusiło, żeby „brak w HEAD" traktować jako BRAK PODSTAWY zamiast
    # zera — bo pierwsze wpięcie licznika nad ZASTANYM długiem melduje regres, którego
    # nikt nie wniósł. Zmiana COFNIĘTA: tor tej straży ratyfikuje wprost przeciwne
    # zachowanie („nowy lint z naruszeniem oblewa (brak w HEAD = 0)"), a przepisywanie
    # ratyfikowanej reguły nie należy do ręki, która akurat się o nią potknęła.
    # Rozstrzygnięcie — czy odróżniać dług WNIESIONY od ZASTANEGO — należy do twórcy.
    [ -z "$a" ] && a=0
    if [ "$b" -gt "$a" ]; then
      echo "   ✗ $nazwa: $a → $b — LICZNIK WZRÓSŁ (regres wchodzi do historii)"
      zle=$((zle+1))
    elif [ "$b" -lt "$a" ]; then
      echo "   ✓ $nazwa: $a → $b — dług spłacony"
    fi
  done <<EOF
$po
EOF
  [ "$zle" -eq 0 ]
}

# ═══ TOR WŁASNY (#38) — przyrząd nie jest świadkiem własnej poprawności ═══
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ LINTÓW — AUTOTEST (#38) ═══╗"
  z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (było '$2', miało '$3')"; o=$((o+1)); fi; }

  # (1) licznik nie liczy zieleni ani informacji
  spr "zielone i ⓘ nie są naruszeniem" \
      "$(policz_naruszenia '  ✓ KSIĘGA SPÓJNA
  ⓘ #7: jawnie pusty — OK')" "0"
  # (2) licznik widzi ✗ i ⚠
  spr "✗ i ⚠ liczone co do sztuki" \
      "$(policz_naruszenia '  ✗ jeden
  ⚠ dwa
  ✓ trzy')" "2"

  # (3) STAN RÓWNY — nie alarmuje (zastany dług przechodzi)
  porownaj "a.js 3
b.sh 1" "a.js 3
b.sh 1" >/dev/null 2>&1
  spr "równy stan przechodzi (dług zastany nie karany)" "$?" "0"

  # (4) SPADEK — nie alarmuje
  porownaj "a.js 3" "a.js 1" >/dev/null 2>&1
  spr "spadek licznika przechodzi" "$?" "0"

  # (5) WZROST — MUSI oblać (ścieżka, dla której straż istnieje)
  porownaj "a.js 1" "a.js 2" >/dev/null 2>&1
  spr "WZROST oblewa (blizna #61)" "$?" "1"

  # (6) NOWY LINT z naruszeniem — brak w HEAD traktowany jak 0, więc wzrost
  porownaj "a.js 0" "a.js 0
nowy.js 1" >/dev/null 2>&1
  spr "nowy lint z naruszeniem oblewa (brak w HEAD = 0)" "$?" "1"

  # (7) NOWY LINT czysty — nie alarmuje
  porownaj "a.js 0" "a.js 0
nowy.js 0" >/dev/null 2>&1
  spr "nowy lint czysty przechodzi" "$?" "0"

  # (8) WZROST JEDNEGO przy spadku drugiego — MUSI oblać (nie sumujemy!)
  porownaj "a.js 5
b.sh 0" "a.js 0
b.sh 1" >/dev/null 2>&1
  spr "wzrost jednego mimo spadku drugiego oblewa (bez sumowania)" "$?" "1"

  # (9) ZERO ZNALEZIONYCH LINTÓW — MUSI oblać, nie zielenić się (#52)
  # Rodowód: ta sama klasa złapana torem 21.08 w równolegle budowanej straży drugiej ręki;
  # przeniesiona tutaj przy złożeniu dwóch przyrządów o tej samej funkcji.
  # dach narzedzia/straze/ (29.08): ścieżka do SIEBIE ustalana absolutnie PRZED cd do atrapy —
  # $OLDPWD wskazywał korzeń, gdzie ten plik już nie leży (klasa #70: fikstura z zaszytą ścieżką).
  JA_LINTOW="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  ZT="$(mktemp -d)"
  # FIKSTURA ODTWARZA TOPOLOGIĘ PRODUKCJI (29.08, dach narzedzia/straze/): straż robi
  # `cd dirname/../..`, więc w atrapie musi leżeć DWA poziomy pod korzeniem atrapy —
  # kopia w korzeniu wyprowadzała `cd` POZA atrapę i tor mierzył cudze ciało (#66 ods. 8).
  ( cd "$ZT" && git init -q . && git config user.email z@z.z && git config user.name Z \
    && mkdir -p narzedzia/straze && cp "$JA_LINTOW" narzedzia/straze/ ; \
    echo x > x.md && git add -A && git commit -qm init >/dev/null 2>&1 ; \
    LINTY_NODE="nie_ma_takiego.js" LINTY_BASH="" bash narzedzia/straze/straz_lintow.sh >/dev/null 2>&1; echo $? ) > "$ZT/rc"
  spr "ZERO znalezionych lintow oblewa, nie zieleni sie (#52)" "$(cat "$ZT/rc")" "1"
  rm -rf "$ZT"

  # (10) KATEGORIA LINTY_LICZBA — przyrząd SAM podaje licznik przez `--liczba`.
  # Powód istnienia: `policz_naruszenia()` zlicza LINIE z ✗/⚠, więc straż drukująca
  # jedną zbiorczą linię („niezmapowanych: N") dawałaby stałe 1 przy dowolnym N.
  # Fikstura MUSI oblać, gdyby kategorii nie było: atrapa drukuje 7 przez `--liczba`
  # i ani jednego glifu — zliczanie po glifach dałoby 0, ta kategoria daje 7.
  ZL="$(mktemp -d)"
  printf '#!/usr/bin/env bash\n[ "${1:-}" = "--liczba" ] && { echo 7; exit 0; }\necho "  bez glifow"\n' \
    > "$ZL/atrapa_licznik.sh"
  chmod +x "$ZL/atrapa_licznik.sh"
  wynik_l="$(LINTY_NODE="" LINTY_BASH="" LINTY_LICZBA="atrapa_licznik.sh" zmierz_katalog "$ZL")"
  spr "LINTY_LICZBA czyta licznik przyrzadu, nie glify" "$wynik_l" "atrapa_licznik.sh 7"

  # (11) STARA WERSJA bez `--liczba` = BRAK POMIARU, nie zero — inaczej milczenie
  # przyrządu wyglądałoby jak czystość i regres przeszedłby niezauważony (#39).
  printf '#!/usr/bin/env bash\necho "uzycie: [--scisle]"\nexit 2\n' > "$ZL/atrapa_stara.sh"
  chmod +x "$ZL/atrapa_stara.sh"
  wynik_s="$(LINTY_NODE="" LINTY_BASH="" LINTY_LICZBA="atrapa_stara.sh" zmierz_katalog "$ZL")"
  spr "przyrzad bez trybu --liczba nie udaje zera" "$wynik_s" ""
  rm -rf "$ZL"


  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] && { echo "  ✓ STRAŻ LINTÓW ŻYWA — umie przepuścić dług i zatrzymać regres."; exit 0; }
  echo "  ✗ TOR OBLANY"; exit 1
fi

# ═══ TOR ZAMKA #61 (#53: zamek nieosiągalny przez własną fasadę jest dekoracją) ═══
# Sam wiersz w rejestrze mutacji NIE dowodzi, że zamek działa — `straz_zamkow.sh` czyta
# deklaracje, nie zachowanie. Ten tor URUCHAMIA hook na sztucznie wywołanym regresie
# i wymaga rc=1. Mutacja `if false` w hooku musi go oblać.
if [ "${1:-}" = "--test-zamek" ]; then
  cd "$(dirname "$0")/../.."
  H=".githooks/pre-commit"
  [ -f "$H" ] || { echo "  ⓘ brak $H — nie ma czego testować"; exit 0; }
  # FIKSTURA NAPRAWIONA 21.08 — PIĄTE wystąpienie #51 tego dnia i najkosztowniejsze.
  # Tor wstrzykiwał obietnicę bez pokrycia do `kanon/ksiegi/KOLEJKA_M.md`, którego `lint_artefaktow.js`
  # NIE CZYTA (jego lista rejestrów liczy 9 pozycji i tej nie zawiera). Licznik nie rósł,
  # zamek #61 nie miał czego złapać, a hook oblewał wyłącznie z powodu ZAMKA #35 na brudnym
  # drzewie. Zamek uchodził za żywy dwie godziny — NIE TOR BYŁ ZA SŁABY, TYLKO DANE.
  # Odsłoniło to dopiero wymaganie, by hook NAZWAŁ powód (zmiana kilka linii wyżej).
  CEL="kanon/ksiegi/MOSTY.md"
  ZAP="$(mktemp)"; cp "$CEL" "$ZAP"
  przywroc_cel() { cp "$ZAP" "$CEL"; rm -f "$ZAP"; }
  trap przywroc_cel EXIT INT TERM
  printf '\n- prototyp: `tor_zamka_61_atrapa.js` — gotowy\n' >> "$CEL"
  # SZÓSTE #51 TEGO DNIA, ostatnie ogniwo łańcucha: hook zaczyna od
  # `files="$(git diff --cached ...)"; [ -n "$files" ] || exit 0`. Uruchomiony przy PUSTYM
  # stage'u wychodzi rc=0 ZANIM dojdzie do zamka #61 — więc tor mierzył ścieżkę pustą
  # i meldował „MARTWY" niezależnie od stanu zamka. Fikstura musi ZASTAGOWAĆ zmianę,
  # bo bez wpisu w stage hook z definicji nie robi nic. Rozłożone na ogniwa i zmierzone
  # osobno: lint ✗ (łapie) → straz_lintow rc=1 (widzi wzrost) → hook rc=0 (nie dochodzi).
  BYL_W_STAGE=0
  git diff --cached --name-only 2>/dev/null | grep -qx "$CEL" && BYL_W_STAGE=1
  # #54 W STAGE'U (29.08.2026, złapane przy zapisie A1): gdy CEL BYŁ już w stage'u z cudzą
  # treścią, `git add` niżej NADPISYWAŁ ją zatrutą fikstura, a gałąź „BYL_W_STAGE=1" nic
  # nie przywracała — dysk wracał, stage NIE. Zatruty wiersz wchodził do commita cicho.
  # Naprawa: zapamiętaj blob ze stage'u i wróć do niego po torze, nie do wersji z dysku.
  ZAPSTAGE=""
  if [ "$BYL_W_STAGE" -eq 1 ]; then ZAPSTAGE="$(mktemp)"; git show ":$CEL" > "$ZAPSTAGE" 2>/dev/null || true; fi
  git add "$CEL" >/dev/null 2>&1 || true
  WY="$(bash "$H" 2>&1)"; RCH=$?
  if [ "$BYL_W_STAGE" -eq 1 ] && [ -s "$ZAPSTAGE" ]; then
    cp "$ZAPSTAGE" "$CEL"; git add "$CEL" >/dev/null 2>&1 || true; rm -f "$ZAPSTAGE"
  else
    git restore --staged "$CEL" >/dev/null 2>&1 || true
  fi
  przywroc_cel; trap - EXIT INT TERM
  # #53 DOMKNIĘTE 21.08: sam rc NIE wystarcza. Zmierzone — przy zmutowanym zamku #61 hook
  # nadal oblewał, ale z powodu ZAMKA #35 („ładunek niepełny", brudne drzewo robocze),
  # więc mutacja `zamek61-regres-nie-blokuje` przechodziła jako ŚLEPA. Tor mierzył
  # „czy hook oblał", a pytanie brzmi „czy oblał Z TEGO POWODU". Wcześniej wypadał dobrze
  # wyłącznie dlatego, że biegał na czystym drzewie — czyli przez okoliczność, nie konstrukcję.
  if [ "$RCH" -ne 0 ] && printf '%s' "$WY" | grep -q 'ZAMEK #61'; then
    echo "  ✓ ZAMEK #61 ŻYWY — hook zatrzymał commit i nazwał POWÓD (rc=$RCH)"; exit 0
  fi
  if [ "$RCH" -ne 0 ]; then
    echo "  ✗ ZAMEK #61 NIEDOWIEDZIONY — hook oblał (rc=$RCH), ale NIE z powodu tego zamka."
    echo "    Oblanie z cudzego powodu jest nieodróżnialne od działania (#53). Pierwsze linie:"
    printf '%s\n' "$WY" | head -3 | sed 's/^/      /'
    exit 1
  fi
  echo "  ✗ ZAMEK #61 MARTWY — hook przepuścił regres (rc=0). Deklaracja bez zachowania (#53)."
  exit 1
fi

# ═══ PRZEBIEG ŻYWY ═══
cd "$(dirname "$0")/../.."
echo "▤ STRAŻ LINTÓW (#61) — czy któryś licznik naruszeń WZRÓSŁ względem HEAD:"

if ! git rev-parse --verify -q HEAD >/dev/null 2>&1; then
  echo "   ⓘ brak HEAD (pierwszy commit) — nie ma z czym porównać, przepuszczam."
  exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM
if ! git archive HEAD | tar -x -C "$TMP" 2>/dev/null; then
  echo "   ⚠ nie dało się zdjąć HEAD (git archive) — STRAŻ NIE ZMIERZYŁA, nie zieleni się."
  exit 2
fi
# moduły z bieżącego drzewa — HEAD ich nie niesie (node_modules poza gitem)
[ -d node_modules ] && ln -s "$(pwd)/node_modules" "$TMP/node_modules" 2>/dev/null

PRZED="$(zmierz_katalog "$TMP")"
PO="$(zmierz_katalog ".")"

# ── ZAMEK #52: ZERO ZNALEZIONYCH LINTÓW NIE JEST ZDROWIEM ──────────────────────
# `porownaj` iteruje po wierszach POMIARU: pusty pomiar = pusta pętla = zle=0 = rc=0.
# Przemianowany, skasowany albo przeniesiony lint sprawiłby, że straż milczy NA ZIELONO,
# a jej zdanie „żaden licznik nie wzrósł" byłoby prawdziwe i bezużyteczne jednocześnie.
# Rodzina #52 (zielono nad pustym zbiorem) · #49 (tor na alarm to nie tor na miarę).
# Różnica wobec ZERA ZNACZĄCEGO ze straży tropu: tam pusty zbiór jest legalnym stanem
# odbiorcy odlewu; tutaj oznacza, że przyrząd stracił materię i przestał cokolwiek mierzyć.
if [ -z "$(printf '%s' "$PO" | tr -d '[:space:]')" ]; then
  echo "   ✗ NIE ZNALAZŁAM ŻADNEGO LINTU (szukane: $LINTY_NODE $LINTY_BASH)."
  echo "     Cisza tutaj byłaby zielenią nad pustym zbiorem (#52) — przemianowany lint"
  echo "     musi ZAPALIĆ, nie zniknąć. Popraw listę albo przywróć plik."
  exit 1
fi

if porownaj "$PRZED" "$PO"; then
  echo "   ✓ ŻADEN LICZNIK NIE WZRÓSŁ — regres nie wchodzi do historii (#61)."
  exit 0
fi
echo "   ✗ REGRES: licznik wzrósł względem poprzedniego commitu."
echo "     Nie chodzi o zero naruszeń — chodzi o to, byś nie zostawił WIĘCEJ, niż zastałeś."
exit 1
