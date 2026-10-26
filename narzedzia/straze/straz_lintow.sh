#!/usr/bin/env bash
# ── ŚRODOWISKO GITA ZDJĘTE Z DZIEDZICZENIA (13.09.2026, zmierzone dwustronnie) ──────
# Hook `pre-commit` eksportuje GIT_INDEX_FILE (bywa też GIT_DIR). Straż wołana Z HOOKA
# dziedziczyła je i przekazywała dalej: (1) `git worktree add` brał cudzy indeks dla NOWEGO
# drzewa i padał („index file open failed: Not a directory"); (2) gdy już wstał, `node`
# lintów uruchomiony w worktree widział GIT_DIR wskazujący gdzie indziej, `git ls-files`
# padało i `lint_artefaktow.js` wychodził jako `?` — BRAK POMIARU udający ciszę.
# Zdejmujemy raz, u góry, żeby objęło też procesy potomne. Git odnajduje repo po `cwd`,
# a każdy tryb tej straży i tak zaczyna od `cd` do korzenia.
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE GIT_OBJECT_DIRECTORY 2>/dev/null || true
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
  local kat="$1" n out rc
  # BRAK POMIARU ≠ ZERO NARUSZEŃ (04.09.2026, rekomendacja A + jawny meldunek, decyzja twórcy).
  # Stan HEAD zdejmowany jest `git archive` (#50), więc w kopii NIE MA `.git`. Lint, który
  # pyta o pliki ŚLEDZONE (`lint_artefaktow`), kończy tam rc=2 i melduje „pominięty" — a pętla
  # liczyła to jak 0 naruszeń. Skutek zmierzony na main 04.09: baseline 0 (brak pomiaru) wobec
  # 17 (pomiar) = REGRES, KTÓREGO NIE BYŁO; naruszeń ubyło szesnaście, nie przybyło ani jedno.
  # Gałąź stawała się niecommitowalna dla każdej ręki, a jedynym lekarstwem `--no-verify` —
  # czyli zamek uczył się omijać. To wada POMIARU, nie prawa: przyrząd mówił „zero" tam, gdzie
  # miał powiedzieć „nie wiem". Prawo „brak w HEAD = 0" (patrz `porownaj`) zostaje NIETKNIĘTE —
  # rozstrzygnięcie twórcy 04.09: naprawiamy mówienie, prawa nie ruszamy.
  # Zasada nie jest nowa: pętla LINTY_LICZBA niżej stosuje ją od początku („to BRAK POMIARU,
  # nie zero naruszeń"). Była w kodzie, ale tylko w jednej z trzech pętli.
  # CISZA MUSI BYĆ WIDOCZNA (zarzut przeciw rekomendacji A): pominięty lint nie znika po cichu —
  # emitujemy wiersz-znacznik `nazwa ?`, który `porownaj` czyta jako BRAK POMIARU po tej stronie
  # i melduje go człowiekowi. Inaczej lint milczący z powodu WADY byłby nieodróżnialny od zdrowego.
  for n in $LINTY_NODE; do
    if [ -f "$kat/$n" ]; then
      out="$(cd "$kat" && node "$n" 2>&1)"; rc=$?
      case "$rc|$out" in
        2\|*|*"poza repo git"*|*"pominięty"*) echo "$n ?" ;;
        *) echo "$n $(policz_naruszenia "$out")" ;;
      esac
    fi
  done
  for n in $LINTY_BASH; do
    if [ -f "$kat/$n" ]; then
      out="$(cd "$kat" && bash "$n" 2>&1)"; rc=$?
      case "$rc|$out" in
        2\|*|*"poza repo git"*|*"pominięty"*) echo "$n ?" ;;
        *) echo "$n $(policz_naruszenia "$out")" ;;
      esac
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
    # POTWIERDZONE 04.09.2026 (decyzja twórcy): prawo ZOSTAJE. „Brak w HEAD = 0" wymusza
    # kolejność, która się sprawdziła: spłać dług, POTEM wepnij licznik (tak weszło
    # `lint_klas_znakow` 03.09 — dziewięć zastanych spłaconych, potem „10 → 0"). Przyrząd
    # wchodzący na trwale żółty to #56: alarm, na który nikt nie patrzy.
    [ -z "$a" ] && a=0
    # ZNACZNIK BRAKU POMIARU (04.09.2026): `?` po którejkolwiek stronie znaczy „lint nie mógł
    # biec tutaj" — a brak pomiaru NIGDY nie jest wynikiem, więc nie może być ani regresem, ani
    # spłatą. Melduj cisze JAWNIE (żeby lint milczący z powodu WADY nie był nieodróżnialny od
    # zdrowego) i nie licz jej do werdyktu. To wada pomiaru naprawiona bez dotykania prawa wyżej.
    if [ "$b" = "?" ] || [ "$a" = "?" ]; then
      echo "   ⓘ $nazwa: $a → $b — BRAK POMIARU po jednej ze stron (lint nie mógł biec; nie regres, nie spłata)"
      continue
    fi
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

  # (12) BRAK POMIARU W PĘTLI NODE/BASH = znacznik `?`, nie zero (04.09.2026, decyzja twórcy).
  # Strona (+): lint, który MÓGŁ biec, daje liczbę jak dotąd. Strona (−): lint kończący rc=2
  # z meldunkiem pominięcia daje `?` — bo „nie wiem" nie jest „zero".
  printf '#!/usr/bin/env bash\necho "  ⓘ poza repo git — lint pominięty (rc=2, nie melduję sukcesu)"\nexit 2\n' > "$ZL/atrapa_niemierzy.sh"
  printf '#!/usr/bin/env bash\necho "  ✗ jedno naruszenie"\nexit 1\n' > "$ZL/atrapa_mierzy.sh"
  chmod +x "$ZL/atrapa_niemierzy.sh" "$ZL/atrapa_mierzy.sh"
  wynik_bn="$(LINTY_NODE="" LINTY_LICZBA="" LINTY_BASH="atrapa_niemierzy.sh" zmierz_katalog "$ZL")"
  spr "lint ktory NIE MOGL biec daje ? zamiast zera" "$wynik_bn" "atrapa_niemierzy.sh ?"
  wynik_bm="$(LINTY_NODE="" LINTY_LICZBA="" LINTY_BASH="atrapa_mierzy.sh" zmierz_katalog "$ZL")"
  spr "lint ktory ZMIERZYL dalej daje liczbe" "$wynik_bm" "atrapa_mierzy.sh 1"

  # (13) `?` po którejkolwiek stronie NIE jest ani regresem, ani spłatą — i JEST widoczne.
  wynik_p="$(porownaj "x.js ?" "x.js 17" 2>&1)"; rcp=$?
  case "$wynik_p" in (*"BRAK POMIARU"*) : ;; (*) o=$((o+1)); echo "  ✗ ? w HEAD nie zameldowane jawnie";; esac
  [ "$rcp" -eq 0 ] && { z=$((z+1)); echo "  ✓ ? w HEAD nie jest regresem, cisza zameldowana"; } \
                   || { o=$((o+1)); echo "  ✗ ? w HEAD potraktowane jak zero — falszywy regres wraca"; }
  wynik_r="$(porownaj "x.js 3" "x.js 9" 2>&1)"; porownaj "x.js 3" "x.js 9" >/dev/null 2>&1
  [ $? -eq 1 ] && { z=$((z+1)); echo "  ✓ prawdziwy wzrost dalej oblewa (zamek nieoslepiony)"; } \
                || { o=$((o+1)); echo "  ✗ prawdziwy wzrost przeszedl — zamek oslepiony"; }
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
  KOR="$(pwd)"
  H=".githooks/pre-commit"
  [ -f "$H" ] || { echo "  ⓘ brak $H — nie ma czego testować"; exit 0; }
  # ── IZOLACJA TORU (13.09.2026, naprawa pokrycia POZORNEGO) ─────────────────────────
  # POWÓD ZMIERZONY: tor uruchamiał hook na ŻYWYM repo, a hook zaczyna od ZAMKA #35
  # („pliki ŚLEDZONE mają zmiany poza tym commitem") i ZAMKA #67 (odcisk nieświeży).
  # Oba stoją PRZED zamkiem #61. Skutek: ilekroć drzewo było brudne — a w biegu
  # `mutacje.sh` jest brudne ZAWSZE, bo mutacja to zmiana pliku na dysku — hook oblewał
  # z cudzego powodu, tor melduł rc=1, a rejestr liczył to jako ZŁAPANĄ. Pozycja
  # `zamek61-regres-nie-blokuje` miała więc pokrycie POZORNE STRUKTURALNIE: nie dało się
  # go zdobyć, dopóki tor mierzył na żywym drzewie. Komentarz #53 niżej przewidział to
  # słowami „wypadał dobrze wyłącznie dlatego, że biegał na czystym drzewie — czyli przez
  # okoliczność, nie konstrukcję"; okoliczność wreszcie ustąpiła konstrukcji.
  # ROZWIĄZANIE: hook biegnie w WORKTREE na czystym HEAD (tam `git diff` jest puste, więc
  # #35 i #67 milczą z prawdziwego powodu, nie z ułaskawienia), ale PLIK HOOKA kopiujemy
  # z drzewa roboczego — bo to jego zachowanie jest przedmiotem pomiaru i to on bywa
  # zmutowany. Żywe repo nie jest dotykane w ogóle: żadnego `git add`, żadnego stage'a.
  T="$(mktemp -d)"; rm -rf "$T"
  if ! git worktree add --detach "$T" HEAD >/dev/null 2>&1; then
    echo "  ⓘ worktree niedostępny — BRAK POMIARU, nie zielone światło (rc=2)"; exit 2
  fi
  sprzatnij() { cd "$KOR" 2>/dev/null; git worktree remove --force "$T" >/dev/null 2>&1; }
  trap sprzatnij EXIT INT TERM
  cp "$H" "$T/$H"                       # testujemy ŻYWY hook, nie ten z HEAD
  CEL="kanon/ksiegi/MOSTY.md"
  # FIKSTURA (rodowód 21.08): obietnica bez pokrycia musi trafić do rejestru, KTÓRY
  # `lint_artefaktow.js` NAPRAWDĘ CZYTA — wcześniej szła do KOLEJKA_M.md, spoza jego listy,
  # więc licznik nie rósł i zamek #61 nie miał czego złapać. MOSTY.md jest na liście.
  cd "$T"
  printf '\n- prototyp: `tor_zamka_61_atrapa.js` — gotowy\n' >> "$CEL"
  # HOOK TEŻ IDZIE DO STAGE'A (13.09.2026): skopiowany hook RÓŻNI SIĘ od HEAD, więc bez tego
  # zamek #35 zobaczyłby własny plik jako „zmianę poza commitem" i zatrzymał bieg PRZED #61 —
  # tor mierzyłby wtedy swoją własną fikstura, nie zamek. Odciski odnawiane dla obu plików,
  # inaczej to samo zrobiłby #67. Wszystko wyłącznie w worktree; żywe repo nietknięte.
  bash hashuj.sh "$CEL" "$H" >/dev/null 2>&1 || true
  git add "$CEL" "$H" _HASHE.txt >/dev/null 2>&1 || true
  WY="$(bash "$H" 2>&1)"; RCH=$?
  cd "$KOR"; sprzatnij; trap - EXIT INT TERM
  # #53 DOMKNIĘTE 21.08: sam rc NIE wystarcza. Zmierzone — przy zmutowanym zamku #61 hook
  # nadal oblewał, ale z powodu ZAMKA #35 („ładunek niepełny", brudne drzewo robocze),
  # więc mutacja `zamek61-regres-nie-blokuje` przechodziła jako ŚLEPA. Tor mierzył
  # „czy hook oblał", a pytanie brzmi „czy oblał Z TEGO POWODU".
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
# ── STRONA HEAD = WORKTREE, NIE ARCHIWUM (13.09.2026) ─────────────────────────────
# POWÓD ZMIERZONY: `git archive HEAD | tar -x` daje katalog BEZ `.git`. Każdy lint, który
# pyta gita o zbiór plików (`lint_artefaktow.js` → `git ls-files`), wychodzi tam rc=2
# ze słowem „poza repo git", co `zmierz_katalog` klasyfikuje jako `?` — BRAK POMIARU.
# Skutek zmierzony na żywym repo: `lint_artefaktow.js: ? → 0` i zielone „żaden licznik
# nie wzrósł". Czyli zamek #61 NIE PILNOWAŁ lintu, DLA KTÓREGO POWSTAŁ — blizna #61 to
# dokładnie „lint_artefaktow urósł 1→2 i PRZEŻYŁ COMMIT". Zamek z odciętym wejściem:
# strona HEAD była nie do zmierzenia od początku, a `?` po cichu znaczyło „przepuść".
# WORKTREE niesie `.git`, więc obie strony są mierzone tym samym przyrządem. Gdy worktree
# się nie uda — rc=2 i jawne „NIE ZMIERZYŁA", nigdy cicha degradacja do archiwum (#52).
_WT=0
if git worktree add --detach "$TMP/head" HEAD >/dev/null 2>&1; then
  _WT=1; TMPH="$TMP/head"
else
  echo "   ⚠ nie dało się wystawić HEAD jako worktree — STRAŻ NIE ZMIERZYŁA, nie zieleni się."
  exit 2
fi
sprzatnij_wt() { [ "$_WT" -eq 1 ] && git worktree remove --force "$TMPH" >/dev/null 2>&1; rm -rf "$TMP"; }
trap sprzatnij_wt EXIT INT TERM
# moduły z bieżącego drzewa — HEAD ich nie niesie (node_modules poza gitem)
[ -d node_modules ] && ln -s "$(pwd)/node_modules" "$TMPH/node_modules" 2>/dev/null

PRZED="$(zmierz_katalog "$TMPH")"
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
