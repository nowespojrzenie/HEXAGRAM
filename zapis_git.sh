#!/usr/bin/env bash
# Rytuał zapisu torusa — stan KRONOS do GitHuba. Auth z remote origin (token sesji).
# BŁĄD #19 (rc-gate): werdykt pushu WYŁĄCZNIE z kodu wyjścia ($?), nigdy z frazy w tekście.
# NAPRAWA v2 (27.07.2026, polecenie twórcy — usterka złapana na żywo):
#   (1) pusty stage kończył skrypt sukcesem, gdy commity lokalne wyprzedzały origin —
#       żniwo zostawało w piaskownicy, a skrypt mówił "nic do zapisania" i wychodził 0.
#       Teraz: commit OPCJONALNY, push zależy od HEAD vs origin, nie od stage'u.
#   (2) PRACA RÓWNOLEGŁA (dwie ręce: telefon twórcy + piaskownica): fetch PRZED pushem.
#       Rozejście gałęzi = STOP z instrukcją. Skrypt NIGDY sam nie rebasuje ani nie merguje —
#       decyzje kanoniczne należą do twórcy (INCYDENT 15B: żaden cichy merge).
#   (3) Weryfikacja niezależna (ls-remote) wbudowana: rc=0 to za mało, SHA musi się zgadzać.
# NAPRAWA v3 (31.07.2026):
#   (4) WERYFIKACJA ŁADUNKU (kandydat M z blizny #35): zgodne SHA dowodzi PUSHU, nie ŁADUNKU
#       — 29.07 SHA się zgadzało, a treść nie (commit bez `add -A`). Po pushu porównujemy
#       DRZEWA: `git diff --quiet HEAD FETCH_HEAD`. Rozjazd treści = rc=5.
#   (5) TOR TESTOWY (#38): `bash zapis_git.sh --test` — pełny przebieg na lokalnym bare repo,
#       bez sieci i bez tokena. Dziewięć torów (rebase auto ratyfikowany 01.08.2026).
# NAPRAWA v4 (03.10.2026, slowo tworcy 14:28 „Pomysl dobry i rozwiazanie rowniez"; pakiet Opusa -> Sonnet):
#   (6) REBASE AUTO Z REJESTRAMI: biala lista 6 rejestrow dopisywanych + _HASHE.txt (sterownik po sciezce
#       merge_hashe.sh); atrybuty w .git/info/attributes tylko na czas rebase (trap), nie w sledzonym
#       .gitattributes. Bezpieczniki B1–B5 po rebase, DRUGA bramka baterii na scalonym drzewie, niespelniony
#       = reset do HEAD sprzed rebase. 15B (zadnego cichego scalania tresci) bez zmian dla reszty plikow.
#   (7) Odmowa komunikatu zaczynajacego sie od '-' (rc=9) + ostrzezenie o komunikacie domyslnym (#125).
#   (8) #127 (03.10, Sonnet): B3 = DOKLADNIE jeden STATUS na wpis (zero tez cofa: unia skleja ogony), B1 z krotnoscia
#       (wynik >= kazda strona); test R9 + mutacje zapisgit-b3-zero-status / b1-wylaczony.
#   (9) R10 (04.10, Sonnet): krotnosc B1 ma WLASNA fixture (sterownik dedup gubi drugi egzemplarz) + mutacja
#       zapisgit-b1-obecnosc-zamiast-krotnosci.
# NAPRAWA v5 (04.10.2026, slowo tworcy 13:13 „Werdykt projektowy i wdrozenie zostaja dla Opusa"; Opus):
#   (10) WYSCIG O ORIGIN: push odrzucony, bo origin ruszyl w trakcie baterii → fetch + rebase auto + push, do 3 prob,
#        nigdy force; B5 nie powtarza baterii, gdy drzewo rozni sie od zmierzonego tylko sciezkami neutralnymi dla
#        baterii (lista zamknieta, zmierzona). Tory W1–W5 + mutacje zapisgit-b5-przeniesienie-zawsze /
#        zapisgit-wyscig-ponowienie-wylaczone / zapisgit-wyscig-limit-prob / zapisgit-neutralne-caly-kanon.
#        Pakiet: kanon/plany/linienie/PACZKA_bateria_wyscig_0410.md.
set -e
_STREFA_ST="$(node "$(dirname "$0")/narzedzia/silniki/tz_pl.js" --strefa 2>/dev/null || echo Europe/Warsaw)"   # strefa instancji (tz_pl.js: KRONOS_TZ > instancja.json > package.json); stemple czasu

# ── TOR TESTOWY (#38) ── musi stać przed czymkolwiek, co dotyka bieżącego repo
if [ "${1:-}" = "--test" ]; then
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  echo "╔═══ ZAPIS_GIT — AUTOTEST (#38) ═══╗"
  T="$(mktemp -d)"
  # C2 · przepisane 02.09.2026 przy bramce regresyjnej: fikstury bare-repo nie niosą
  # tory_strazy.sh, a tory (a)–(e) mierzą PUSH, nie baterię — atrapa melduje więc ZERO
  # oblanych i brama stoi otworem. Dawniej wystarczyło `ZG_TORY_CMD=true` (bramka patrzyła
  # na rc); bramka regresyjna czyta LICZBĘ, więc atrapa musi mówić zdaniem baterii.
  # `RCB` istnieje po to, żeby tor niżej dowiódł, że rc baterii NIE jest już werdyktem.
  printf '#!/bin/sh\necho "  zmierzone: zdanych 52 · oblanych ${OBL:-0} · bez toru 0"\nfor n in ${NAZWY:-}; do echo "  ✗ $n — oblany"; done\nexit "${RCB:-0}"\n' > "$T/bateria_atrapa.sh"
  export ZG_TORY_CMD="sh $T/bateria_atrapa.sh"
  export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=t@t
  unset CLAUDE_CODE_REMOTE_SESSION_ID ZAPIS_BEZ_KARTECZKI ZAPIS_BEZ_BRAMKI   # tor niezalezny od sesji, w ktorej biegnie
  export _ZG_STAN_PLIK="$T/stan_obcy" _ZG_STAN_RODZIC=0; : > "$T/stan_obcy"   # jak gdy bateria zywego biegu odpala ten tor: dziedziczony plik stanu
  git init -q --bare "$T/zdalne.git"
  git clone -q "$T/zdalne.git" "$T/praca" 2>/dev/null
  cd "$T/praca"
  git symbolic-ref HEAD refs/heads/prywatna
  echo "pierwsza" > plik.md && git add -A && git commit -qm "start"
  git push -qu origin prywatna     # zasiew gałęzi zdalnej (skrypt jej NIE zakłada — znana luka)

  set +e
  # (⊙) gałąź nieistniejąca na origin MUSI dać czytelne rc=6, nie „idź po token"
  git checkout -qb widmo && bash "$SAM" "test widmo" >/dev/null 2>&1; RC_W=$?
  git checkout -q prywatna
  # (a) świeże żniwo → push MUSI pójść i MUSI się zweryfikować
  echo "drugie" > plik.md
  bash "$SAM" "test a" >/dev/null 2>&1; RC_A=$?
  # (b) nic nowego → rc=0 i żadnego pchnięcia
  bash "$SAM" "test b" >/dev/null 2>&1; RC_B=$?
  # (c) ROZEJŚCIE BEZ RYZYKA: rozłączne pliki, brak usunięć → REBASE AUTO (ratyfikacja 01.08.2026)
  git clone -q "$T/zdalne.git" "$T/druga" 2>/dev/null
  ( cd "$T/druga" && git checkout -q prywatna && echo "druga reka" > inny.md \
    && git add -A && git commit -qm "druga reka" && git push -q origin prywatna )
  echo "moje" > moje.md
  bash "$SAM" "test c" >/dev/null 2>&1; RC_C=$?
  # rebase auto MUSI był wciągnąć plik drugiej ręki I zachować nasz
  SCALONE=0; [ -e inny.md ] && [ -e moje.md ] && SCALONE=1
  # (d) KOLIZJA NA TYM SAMYM PLIKU → brama MUSI stanąć (rc=3), nic nie scalać
  ( cd "$T/druga" && git pull -q --rebase 2>/dev/null; echo "ich wersja" > sporny.md \
    && git add -A && git commit -qm "ich sporny" && git push -q origin prywatna )
  echo "nasza wersja" > sporny.md && git add -A && git commit -qm "nasz sporny"
  bash "$SAM" "test d" >"$T/d.out" 2>&1; RC_D=$?
  D_BRZMIENIE=0; grep -q "NIE rob golego 'git rebase'" "$T/d.out" && grep -q "sporny.md" "$T/d.out" && ! grep -q 'git rebase FETCH_HEAD' "$T/d.out" && D_BRZMIENIE=1
  NASZ_SPORNY=0; grep -q "nasza wersja" sporny.md 2>/dev/null && NASZ_SPORNY=1
  # sprzątanie po (d): zrównanie z origin, żeby (e) startowało z czystego
  git fetch -q origin prywatna && git reset -q --hard FETCH_HEAD && rm -f sporny.md
  git add -A && git commit -qm "reset po d" >/dev/null 2>&1 || true
  git push -q origin prywatna >/dev/null 2>&1
  # (e) DRUGA RĘKA USUWA PLIK → 15B, brama MUSI stanąć nawet przy rozłącznych ścieżkach
  ( cd "$T/druga" && git fetch -q origin prywatna && git reset -q --hard FETCH_HEAD \
    && git rm -q inny.md && git commit -qm "ich usuniecie" && git push -q origin prywatna )
  echo "kolejne moje" > moje2.md && git add -A && git commit -qm "moje2"
  bash "$SAM" "test e" >/dev/null 2>&1; RC_E=$?
  OCALONY=0; [ -e inny.md ] && OCALONY=1
  # ── (f) BRAMKA REGRESYJNA — TOR DWUSTRONNY (02.09.2026) ──────────────────────────
  # Bez strony UJEMNEJ ta bramka byłaby dekoracją: „przepuszcza dług" bez „odmawia na
  # regres" to nie brama, tylko komunikat. Obie strony biją w ŻYWY skrypt przez pełny
  # przebieg, nie w wyciętą funkcję (#50: tor obok funkcji jest ślepy).
  # `RCB=1` w obu przypadkach: bateria ZAWSZE melduje rc=1, więc gdyby bramka dalej
  # czytała kod wyjścia, strona dodatnia oblałaby razem z ujemną i test nic by nie ważył.
  # Sprzątanie po (e): test (e) ZOSTAWIA rozejście z origin (druga ręka usunęła plik),
  # więc bez zrównania strona DODATNIA oblewałaby na rc=3 z bramy rozejścia, nie z bramki
  # baterii — i mierzyłaby cudzą przyczynę. Zmierzone: bez tej linii bramka+ dawała rc=3.
  git fetch -q origin prywatna && git reset -q --hard FETCH_HEAD
  printf 'oblanych=7\n' > "$T/baza7"
  SHA_PRZED_F="$(git ls-remote "$T/zdalne.git" refs/heads/prywatna | cut -f1)"
  # (+) baseline 7 · bieżące 7 → push PRZECHODZI, z głośnym meldunkiem o długu
  echo "dlug rowny baseline" > f_plus.md && git add -A && git commit -qm "f+"
  OUT_F_PLUS="$(OBL=7 RCB=1 ZG_BAZA_PLIK="$T/baza7" bash "$SAM" "test f+" 2>&1)"; RC_FP=$?
  SHA_PO_PLUS="$(git ls-remote "$T/zdalne.git" refs/heads/prywatna | cut -f1)"
  PCHNIETO_F=0; [ "$SHA_PO_PLUS" != "$SHA_PRZED_F" ] && PCHNIETO_F=1
  DLUG_MELD=0; case "$OUT_F_PLUS" in *"DLUG ODZIEDZICZONY PRZEPUSZCZONY"*) DLUG_MELD=1 ;; esac
  # (−) baseline 7 · bieżące 8 → rc=7 i origin NIETKNIĘTY (mierzone ls-remote, nie wiarą)
  echo "regres" > f_minus.md && git add -A && git commit -qm "f-"
  OBL=8 RCB=1 ZG_BAZA_PLIK="$T/baza7" bash "$SAM" "test f-" >/dev/null 2>&1; RC_FM=$?
  SHA_PO_MINUS="$(git ls-remote "$T/zdalne.git" refs/heads/prywatna | cut -f1)"
  ORIGIN_NIETKNIETY=0; [ "$SHA_PO_MINUS" = "$SHA_PO_PLUS" ] && ORIGIN_NIETKNIETY=1
  # (⊙) baseline NIEZMIERZONY (atrapa milczy) → brak liczby to NIE jest zero
  RC_FNIC=0; ZG_TORY_CMD=true ZG_BAZA_PLIK="$T/baza7" bash "$SAM" "test f nic" >/dev/null 2>&1 || RC_FNIC=$?
  # (n) BASELINE Z NAZWAMI (04.10, słowo twórcy; WATKI „Bramka liczy ilość, nie nazwy”): ta sama LICZBA, inna NAZWA
  # = nowy oblany tor przysłonięty zastanym długiem (incydent 02.09: `stol` pod `gotowosc`, commit 14a6d09).
  printf 'oblanych=1\noblane=gotowosc\n' > "$T/baza_n"
  SHA_PRZED_N="$(git ls-remote "$T/zdalne.git" refs/heads/prywatna | cut -f1)"
  OUT_N_MINUS="$(OBL=1 NAZWY="stol" RCB=1 ZG_BAZA_PLIK="$T/baza_n" bash "$SAM" "test n-" 2>&1)"; RC_NM=$?
  SHA_PO_N="$(git ls-remote "$T/zdalne.git" refs/heads/prywatna | cut -f1)"
  N_NIETKNIETY=0; [ "$SHA_PO_N" = "$SHA_PRZED_N" ] && N_NIETKNIETY=1
  N_NAZWA=0; case "$OUT_N_MINUS" in *"NOWY OBLANY TOR"*stol*) N_NAZWA=1 ;; esac
  OBL=1 NAZWY="gotowosc" RCB=1 ZG_BAZA_PLIK="$T/baza_n" bash "$SAM" "test n+" >/dev/null 2>&1; RC_NP=$?
  # baseline STARY (bez linii oblane=) → liczenie jak dawniej, nie odmowa z powodu samej nieobecnosci nazw
  printf 'oblanych=1\n' > "$T/baza_stara"
  echo "n3" > n3.md && git add -A && git commit -qm "n3"
  OBL=1 NAZWY="stol" RCB=1 ZG_BAZA_PLIK="$T/baza_stara" bash "$SAM" "test n stara" >/dev/null 2>&1; RC_NS=$?
  # (nw) piszacy baseline ZAPISUJE nazwy (bez tego bramka nazw nie ma z czego czytac)
  OBL=2 NAZWY="stol gotowosc" RCB=1 ZG_BAZA_PLIK="$T/baza_zapis" bash "$SAM" --baseline-baterii >/dev/null 2>&1
  NW_ZAPIS=0; grep -qx 'oblane=gotowosc,stol' "$T/baza_zapis" 2>/dev/null && NW_ZAPIS=1
  # (k) BRAMKA KARTECZKI (03.10): odmowa bez karteczki; przepuszcza wlasna / zmiane rejestru / furtke jawna
  _KR="kanon/ksiegi/KTO_CO_BIERZE.md"; mkdir -p kanon/ksiegi 2>/dev/null
  _kz() { ZG_SESJA="$1" bash "$SAM" "test k" >/dev/null 2>&1; echo $?; }
  echo k1 > k1.md;                 RC_K1="$(_kz SESKKKKK)"
  SHA_K1="$(git ls-remote "$T/zdalne.git" refs/heads/prywatna | cut -f1)"; K1_LOK="$(git rev-parse HEAD)"
  [ "$SHA_K1" != "$K1_LOK" ] && K1_NIETKNIETY=1 || K1_NIETKNIETY=0
  printf '\n**BIORĘ:** t\n**RĘKA:** R\n**SESJA:** SESKKKKK\n**OD:** x\n**HEAD:** h\n**STATUS:** OTWARTE\n' >> "$_KR"
  RC_K2="$(_kz SESKKKKK)"          # wieszanie niesie rejestr → przechodzi
  echo k3 > k3.md;                 RC_K3="$(_kz SESKKKKK)"          # karteczka juz w HEAD → przechodzi
  echo k4 > k4.md;                 RC_K4="$(_kz SESINNEEE)"         # inna sesja bez karteczki → ODMOWA
  RC_K5="$(ZAPIS_BEZ_KARTECZKI="test powod" ZG_SESJA=SESINNEEE bash "$SAM" "test k5" >/dev/null 2>&1; echo $?)"   # furtka jawna
  sed -i 's/^\*\*STATUS:\*\* OTWARTE$/**STATUS:** ODDANE x/' "$_KR"
  RC_K6="$(_kz SESKKKKK)"          # domkniecie niesie rejestr → przechodzi
  # (k7-k9) KARTKA = PLIK SESJI (v2): wlasna kartka w HEAD przepuszcza; cudza nie; zmiana katalogu kartek niesie
  mkdir -p kanon/ksiegi/kartki; printf '**BIORĘ:** t\n**RĘKA:** R\n**SESJA:** SESKART8\n**OD:** x\n**HEAD:** h\n**STATUS:** OTWARTE · SESKART8\n' > kanon/ksiegi/kartki/SESKART8.md
  RC_K7="$(_kz SESKART8)"         # wieszanie kartki niesie katalog → przechodzi
  echo k8 > k8.md;                 RC_K8="$(_kz SESKART8)"         # kartka juz w HEAD → przechodzi
  # (k10-k11) R5: PO ODDANIU KARTY. Kartka ODDANE w HEAD; push niosacy WYLACZNIE wiersz biegu (ZAPIS_biegi) przechodzi;
  # ten sam wiersz + plik spoza kartek/biegow → ODMOWA (granica „wylacznie”, nie „takze”).
  mkdir -p kanon/pomiary/ZAPIS_biegi
  printf '**BIORĘ:** t\n**RĘKA:** R\n**SESJA:** SESKODD1\n**OD:** x\n**HEAD:** h\n**STATUS:** ODDANE x\n' > kanon/ksiegi/kartki/SESKODD1.md
  RC_K10A="$(_kz SESKODD1)"        # oddanie niesie katalog kartek → przechodzi (stan wyjsciowy)
  echo "wiersz biegu" > kanon/pomiary/ZAPIS_biegi/SESKODD1.txt; RC_K10="$(_kz SESKODD1)"   # sam wiersz biegu po oddaniu → przechodzi
  echo "wiersz biegu 2" >> kanon/pomiary/ZAPIS_biegi/SESKODD1.txt; echo k11 > k11.md; RC_K11="$(_kz SESKODD1)"   # + plik poza → ODMOWA
  git reset -q --hard FETCH_HEAD 2>/dev/null || git reset -q --hard "origin/prywatna"   # fikstura: wyrzuc lokalny commit odmowy, origin = punkt wyjscia dla k9
  echo k9 > k9.md;                 RC_K9="$(_kz SESCUDZAAA)"        # cudza kartka nie liczy sie jako moja → ODMOWA
  # (br) BRAMKA PRZYRZADOW (04.10, A3): sciezka chroniona wymaga wlasnej kartki o temacie BRAMKA.
  # SESBRAZ1 ma kartke ZWYKLA, SESBRAZ2 kartke BRAMKA; obie wisza jednym pushem (niesie katalog kartek, ruch nie dotyka sciezek chronionych).
  printf '**BIORĘ:** zwykly temat\n**RĘKA:** R\n**SESJA:** SESBRAZ1\n**OD:** x\n**HEAD:** h\n**STATUS:** OTWARTE · SESBRAZ1\n' > kanon/ksiegi/kartki/SESBRAZ1.md
  printf '**BIORĘ:** BRAMKA: przyrzady bramki\n**RĘKA:** R\n**SESJA:** SESBRAZ2\n**OD:** x\n**HEAD:** h\n**STATUS:** OTWARTE · SESBRAZ2\n' > kanon/ksiegi/kartki/SESBRAZ2.md
  RC_BR0="$(_kz SESBRAZ1)"
  # (br−) kazda z czterech sciezek chronionych + kartka zwykla → ODMOWA rc=8, origin nietkniety (ls-remote, nie wiara)
  SHA_BR1="$(git ls-remote "$T/zdalne.git" refs/heads/prywatna | cut -f1)"; RC_BR1=""
  for _p in zapis_git.sh narzedzia/straze/straz_feromonow.sh tory_strazy.sh .githooks/pre-commit; do
    git fetch -q origin prywatna && git reset -q --hard FETCH_HEAD   # kazda sciezka MIERZONA OSOBNO: odmowa zostawia commit lokalnie, a skumulowany diff dalej by odmawial
    mkdir -p "$(dirname "$_p")"; echo "ruch $_p" > "$_p"
    RC_BR1="$RC_BR1$(_kz SESBRAZ1)"
  done
  git fetch -q origin prywatna && git reset -q --hard FETCH_HEAD
  echo "ruch zbiorczy" > tory_strazy.sh   # commit do pchniecia przez br2 (kartka BRAMKA ma go przepuscic)
  git add -A && git commit -qm "br ruch chroniony" >/dev/null 2>&1
  [ "$(git ls-remote "$T/zdalne.git" refs/heads/prywatna | cut -f1)" = "$SHA_BR1" ] && BR1_NIETKNIETY=1 || BR1_NIETKNIETY=0
  # (br+) ta sama zaleglosc, kartka BRAMKA w HEAD → przechodzi i dociera na origin
  RC_BR2="$(_kz SESBRAZ2)"
  BR2_PUSH=0; [ "$(git ls-remote "$T/zdalne.git" refs/heads/prywatna | cut -f1)" = "$(git rev-parse HEAD)" ] && BR2_PUSH=1
  # (br+) furtka jawna z powodem otwiera sciezke chroniona; (br−) furtka KARTECZKOWA jej NIE otwiera (inna sesja, zero kartek)
  echo "furtka" > tory_strazy.sh; RC_BR3="$(ZAPIS_BEZ_BRAMKI="test powod" ZG_SESJA=SESBRAZ1 bash "$SAM" "test br3" >/dev/null 2>&1; echo $?)"
  echo "furtka2" > tory_strazy.sh; RC_BR4="$(ZAPIS_BEZ_KARTECZKI="test powod" ZG_SESJA=SESBRAZ3 bash "$SAM" "test br4" >/dev/null 2>&1; echo $?)"
  # (br+) zwykly plik, kartka zwykla → bramka przyrzadow milczy (rc=0)
  git fetch -q origin prywatna && git reset -q --hard FETCH_HEAD   # zrownanie: br4 zostawil ruch chroniony w lokalnym commicie
  echo zwykly > br5.md; RC_BR5="$(_kz SESBRAZ1)"
  # (r) R2 — REBASE AUTO Z REJESTRAMI (03.10.2026): osobna fikstura na kazdy przypadek.
  # Zaden przypadek nie dzieli stanu z poprzednim (RC i sha liczone swiezo).
  RH="$(cd "$(dirname "$SAM")" && pwd)/hashuj.sh"
  _r_nowa() {
    rm -rf "$T/r_zd.git" "$T/r_a" "$T/r_b"
    git init -q --bare "$T/r_zd.git"; git clone -q "$T/r_zd.git" "$T/r_a" 2>/dev/null
    ( cd "$T/r_a" && git symbolic-ref HEAD refs/heads/prywatna && mkdir -p kanon/pomiary kanon/ksiegi \
      && cp "$RH" hashuj.sh \
      && printf 'w1\nw2\nw3\n' > kanon/pomiary/ALARMY_szereg.txt && printf 'k1\n' > kanon/pomiary/KRZESLA_zlapane.txt \
      && printf 'a0\n' > a.md && printf 'b0\n' > b.md && printf 'l1\nl2\nl3\nl4\nl5\nl6\n' > wspolny.md \
      && printf '# naglowek\n\n**BIORĘ:** t\n**RĘKA:** R\n**SESJA:** SESRRRRR\n**OD:** x\n**HEAD:** h\n**STATUS:** OTWARTE\n' > kanon/ksiegi/KTO_CO_BIERZE.md \
      && for f in kanon/pomiary/ALARMY_szereg.txt a.md b.md; do echo "$(bash hashuj.sh --odcisk "$f")  $f"; done > _HASHE.txt \
      && git add -A && git commit -qm seed && git push -q -u origin prywatna ) >/dev/null 2>&1
    git clone -q "$T/r_zd.git" "$T/r_b" 2>/dev/null; ( cd "$T/r_b" && git checkout -q prywatna ) >/dev/null 2>&1
  }
  _r_b() { ( cd "$T/r_b" && eval "$1"; [ -n "${2:-}" ] && bash hashuj.sh $2 >/dev/null 2>&1; git add -A; git commit -qm druga; git push -q origin prywatna ) >/dev/null 2>&1; }
  _r_a() { ( cd "$T/r_a" && eval "$1"; [ -n "${2:-}" ] && bash hashuj.sh $2 >/dev/null 2>&1; true ) >/dev/null 2>&1; }
  _r_run() { ( cd "$T/r_a" && bash "$SAM" "test r" > "$T/r_out" 2>&1 ); }
  _r_sha_zd() { git ls-remote "$T/r_zd.git" refs/heads/prywatna | cut -f1; }
  _r_hash_ok() { ( cd "$T/r_a" && for f in "$@"; do grep -qxF "$(bash hashuj.sh --odcisk "$f")  $f" _HASHE.txt || exit 1; done ); }
  # R1 + rejestr z listy bez odcisku: obie rece dopisuja wiersz
  _r_nowa; _r_b 'echo ich-krzeslo >> kanon/pomiary/KRZESLA_zlapane.txt'; _r_a 'echo nasze-krzeslo >> kanon/pomiary/KRZESLA_zlapane.txt'
  _r_run; RC_R1=$?
  R1_OBIE=0; ( cd "$T/r_a" && grep -qx ich-krzeslo kanon/pomiary/KRZESLA_zlapane.txt && grep -qx nasze-krzeslo kanon/pomiary/KRZESLA_zlapane.txt ) && R1_OBIE=1
  R1_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && R1_PUSH=1
  R1_ATTR=0; [ ! -e "$T/r_a/.git/info/attributes" ] && R1_ATTR=1
  # R2 + obie rece zmieniaja ROZNE pliki z odciskiem (obie ruszaja _HASHE.txt)
  _r_nowa; _r_b 'echo b1 >> b.md' b.md; _r_a 'echo a1 >> a.md' a.md
  _r_run; RC_R2=$?
  R2_HASHE=0; _r_hash_ok a.md b.md kanon/pomiary/ALARMY_szereg.txt && R2_HASHE=1
  R2_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && R2_PUSH=1
  # R3 + rejestr Z odciskiem, obie rece dopisuja: odcisk przeliczony, osobny commit B4
  _r_nowa; _r_b 'echo ich-alarm >> kanon/pomiary/ALARMY_szereg.txt' kanon/pomiary/ALARMY_szereg.txt
  _r_a 'echo nasz-alarm >> kanon/pomiary/ALARMY_szereg.txt' kanon/pomiary/ALARMY_szereg.txt
  _r_run; RC_R3=$?
  R3_HASHE=0; _r_hash_ok kanon/pomiary/ALARMY_szereg.txt && R3_HASHE=1
  R3_B4=0; git -C "$T/r_a" log --format=%s | grep -q "odciski rejestrow po rebase auto" && R3_B4=1
  R3_OBIE=0; ( cd "$T/r_a" && grep -qx ich-alarm kanon/pomiary/ALARMY_szereg.txt && grep -qx nasz-alarm kanon/pomiary/ALARMY_szereg.txt ) && R3_OBIE=1
  # R4 − wspolny plik SPOZA listy (rozne linie — merge-tree rc=0, wiec stoi tylko biala lista)
  _r_nowa; _r_b "sed -i 's/^l1\$/ich1/' wspolny.md"; _r_a "sed -i 's/^l6\$/nasze6/' wspolny.md"
  _r_run; RC_R4=$?
  R4_ORIGIN=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_b" rev-parse HEAD)" ] && R4_ORIGIN=1
  R4_HEAD=0; ! git -C "$T/r_a" merge-base --is-ancestor "$(git -C "$T/r_b" rev-parse HEAD)" HEAD && R4_HEAD=1
  # R5 − KTO_CO_BIERZE: obie rece zmieniaja ten sam STATUS (B3) + atrybuty sprzed biegu wracaja po PORAZCE
  _r_nowa; mkdir -p "$T/r_a/.git/info"; printf '# stare\n' > "$T/r_a/.git/info/attributes"
  _r_b "sed -i 's/^\*\*STATUS:\*\* OTWARTE\$/**STATUS:** ODDANE ich/' kanon/ksiegi/KTO_CO_BIERZE.md"
  _r_a "sed -i 's/^\*\*STATUS:\*\* OTWARTE\$/**STATUS:** ODDANE nasze/' kanon/ksiegi/KTO_CO_BIERZE.md"
  _r_run; RC_R5=$?
  R5_HEAD=0; ! git -C "$T/r_a" merge-base --is-ancestor "$(git -C "$T/r_b" rev-parse HEAD)" HEAD && R5_HEAD=1
  R5_ATTR=0; [ "$(cat "$T/r_a/.git/info/attributes")" = "# stare" ] && R5_ATTR=1
  # R6 − druga bramka baterii: regres pojawia sie dopiero po rebase (marker przychodzi od drugiej reki)
  _r_nowa; printf '#!/bin/sh\nif [ -f marker_bat.txt ]; then n=1; else n=0; fi\necho "  zmierzone: zdanych 52 · oblanych $n · bez toru 0"\n' > "$T/bateria_atrapa2.sh"
  _r_b 'echo m > marker_bat.txt'; _r_a 'echo n > nowy_a.md'
  ( cd "$T/r_a" && ZG_TORY_CMD="sh $T/bateria_atrapa2.sh" bash "$SAM" "test r6" > "$T/r_out" 2>&1 ); RC_R6=$?
  R6_HEAD=0; ! git -C "$T/r_a" merge-base --is-ancestor "$(git -C "$T/r_b" rev-parse HEAD)" HEAD && R6_HEAD=1
  R6_ORIGIN=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_b" rev-parse HEAD)" ] && R6_ORIGIN=1
  # R7 − B1: unia zastapiona sterownikiem „ours" gubi nasza linie → B1 musi to zlapac
  _r_nowa; git -C "$T/r_a" config merge.ours.driver true
  _r_b 'echo ich >> kanon/pomiary/KRZESLA_zlapane.txt'; _r_a 'echo nasze >> kanon/pomiary/KRZESLA_zlapane.txt'
  ( cd "$T/r_a" && ZG_ATRYBUT_REJESTROW=ours bash "$SAM" "test r7" > "$T/r_out" 2>&1 ); RC_R7=$?
  R7_HEAD=0; ! git -C "$T/r_a" merge-base --is-ancestor "$(git -C "$T/r_b" rev-parse HEAD)" HEAD && R7_HEAD=1
  # R10 − B1 KROTNOSC (#127): sterownik „dedup" zostawia linie, ale gubi jej DRUGI egzemplarz — obecnosc zachowana, krotnosc nie → B1 musi cofnac
  _r_nowa; printf '#!/bin/sh\ngit merge-file --union "$2" "$1" "$3"\nawk '"'"'!s[$0]++'"'"' "$2" > "$2.dd" && mv "$2.dd" "$2"\n' > "$T/dedup.sh"
  git -C "$T/r_a" config merge.dedup.driver "sh $T/dedup.sh %O %A %B"
  _r_b "printf 'dup\\ndup\\n' >> kanon/pomiary/KRZESLA_zlapane.txt"; _r_a 'echo nasze >> kanon/pomiary/KRZESLA_zlapane.txt'
  ( cd "$T/r_a" && ZG_ATRYBUT_REJESTROW=dedup bash "$SAM" "test r10" > "$T/r_out" 2>&1 ); RC_R10=$?
  R10_HEAD=0; ! git -C "$T/r_a" merge-base --is-ancestor "$(git -C "$T/r_b" rev-parse HEAD)" HEAD && R10_HEAD=1
  R10_KROTNOSC=0; grep -q "B1: .*(krotnosc 1 < 2)" "$T/r_out" && R10_KROTNOSC=1
  # R9 − #127: dwa nowe wpisy z IDENTYCZNYM ogonem (HEAD+STATUS) — unia skleja je i jeden traci STATUS → B3 (zero STATUS) musi cofnac
  _r_nowa
  _r_b "printf '\\n**BIORĘ:** y\\n**RĘKA:** R\\n**SESJA:** SESBBBBB\\n**OD:** t2\\n**HEAD:** h\\n**STATUS:** OTWARTE\\n' >> kanon/ksiegi/KTO_CO_BIERZE.md"
  _r_a "printf '\\n**BIORĘ:** x\\n**RĘKA:** R\\n**SESJA:** SESAAAAA\\n**OD:** t1\\n**HEAD:** h\\n**STATUS:** OTWARTE\\n' >> kanon/ksiegi/KTO_CO_BIERZE.md"
  _r_run; RC_R9=$?
  R9_HEAD=0; ! git -C "$T/r_a" merge-base --is-ancestor "$(git -C "$T/r_b" rev-parse HEAD)" HEAD && R9_HEAD=1
  R9_ORIGIN=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_b" rev-parse HEAD)" ] && R9_ORIGIN=1
  # R11 + #129 (STYK straz_feromonow ↔ 15B): druga reka ODDAJE kartke — edycja STATUS w srodku WLASNEGO pliku, plik zostaje
  # (2b) — a my wieszamy swoja. Rozne pliki, zero usuniec → rebase auto, push przechodzi BEZ reki tworcy.
  _r_nowa; ( cd "$T/r_a" && mkdir -p kanon/ksiegi/kartki && printf '**BIORĘ:** x\n**RĘKA:** R\n**SESJA:** SESXXXXX\n**OD:** t\n**HEAD:** h\n**STATUS:** OTWARTE · SESXXXXX\n' > kanon/ksiegi/kartki/SESXXXXX.md \
    && git add -A && git commit -qm "seed kartka" && git push -q origin prywatna ) >/dev/null 2>&1
  ( cd "$T/r_b" && git pull -q --ff-only origin prywatna ) >/dev/null 2>&1
  _r_b "sed -i 's/^\*\*STATUS:\*\* OTWARTE · SESXXXXX\$/**STATUS:** ODDANE t/' kanon/ksiegi/kartki/SESXXXXX.md"
  _r_a "printf '**BIORĘ:** y\\n**RĘKA:** R\\n**SESJA:** SESYYYYY\\n**OD:** t\\n**HEAD:** h\\n**STATUS:** OTWARTE · SESYYYYY\\n' > kanon/ksiegi/kartki/SESYYYYY.md"
  _r_run; RC_R11=$?
  R11_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && R11_PUSH=1
  R11_ODDANE=0; grep -q '^\*\*STATUS:\*\* ODDANE t$' "$T/r_a/kanon/ksiegi/kartki/SESXXXXX.md" 2>/dev/null && R11_ODDANE=1
  # R12 − #129: druga reka KASUJE plik kartki (zachowanie sprzed 2b) → 15B STOI takze dla kartek: zadnego wyjatku w bramce.
  _r_nowa; ( cd "$T/r_a" && mkdir -p kanon/ksiegi/kartki && printf '**BIORĘ:** x\n**RĘKA:** R\n**SESJA:** SESXXXXX\n**OD:** t\n**HEAD:** h\n**STATUS:** OTWARTE · SESXXXXX\n' > kanon/ksiegi/kartki/SESXXXXX.md \
    && git add -A && git commit -qm "seed kartka" && git push -q origin prywatna ) >/dev/null 2>&1
  ( cd "$T/r_b" && git pull -q --ff-only origin prywatna ) >/dev/null 2>&1
  _r_b "git rm -q kanon/ksiegi/kartki/SESXXXXX.md"
  _r_a "printf '**BIORĘ:** y\\n**RĘKA:** R\\n**SESJA:** SESYYYYY\\n**OD:** t\\n**HEAD:** h\\n**STATUS:** OTWARTE · SESYYYYY\\n' > kanon/ksiegi/kartki/SESYYYYY.md"
  _r_run; RC_R12=$?
  R12_ORIGIN=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_b" rev-parse HEAD)" ] && R12_ORIGIN=1
  # Q — TRYB RECZNY (ZAPIS_REBASE_RECZNY=tak, prawo 6a, Q2b): dwie rece zmieniaja TE SAMA linie pliku spoza listy ORAZ kazda swoj wpis w _HASHE.txt.
  # Bez sterownikow konflikt bylby tez w _HASHE.txt; w trybie recznym ma zostac WYLACZNIE w pliku tresci.
  # Dwa nasze commity: pierwszy (konfliktowy) + drugi, ktory znow rusza wpis a.md w _HASHE.txt obok zmienionego przez druga reke b.md —
  # drugi pick wymaga sterownika takze PO `--continue` (bez niego _HASHE.txt skonfliktuje na sasiednich liniach).
  _q_rozjazd() { _r_b "sed -i 's/^l3\$/ich3/' wspolny.md; echo b1 >> b.md" b.md
    ( cd "$T/r_a" && sed -i 's/^l3$/nasze3/' wspolny.md && echo a1 >> a.md && bash hashuj.sh a.md >/dev/null 2>&1; git add -A; git commit -qm "nasz pierwszy" ) >/dev/null 2>&1
    _r_a "echo a2 >> a.md" a.md; }
  _q_nowa() { _r_nowa; _q_rozjazd; }
  _q_tryb() { ( cd "$T/r_a" && ZAPIS_REBASE_RECZNY=tak bash "$SAM" "test q" > "$T/q_out" 2>&1 ); }
  _q_nowa; _q_tryb; RC_Q1=$?
  Q1_TYLKO=0; [ "$(git -C "$T/r_a" diff --name-only --diff-filter=U)" = "wspolny.md" ] && Q1_TYLKO=1
  Q1_STAN=0; [ -f "$T/r_a/.git/kronos_rebase_reczny" ] && [ -d "$T/r_a/.git/rebase-merge" ] && grep -q -e '--kontynuuj' "$T/q_out" && Q1_STAN=1
  # Q1d − zwykly zapis W TOKU recznego rebase: odmowa (git add -A wcommitowalby polowe rebase)
  ( cd "$T/r_a" && bash "$SAM" "test q zwykly" > "$T/q_out2" 2>&1 ); RC_Q6=$?
  Q6_KOMUNIKAT=0; grep -q 'rebase RECZNY jest W TOKU' "$T/q_out2" && ! grep -q 'pozostałość trybu ręcznego' "$T/q_out2" && Q6_KOMUNIKAT=1   # U1-08: rebase w toku ma SWÓJ komunikat, nie komunikat resztki
  # Q1c − --kontynuuj przy nierozwiazanym (znaczniki, brak git add) = rc=3, rebase dalej w toku
  ( cd "$T/r_a" && bash "$SAM" --kontynuuj > "$T/q_out3" 2>&1 ); RC_Q5=$?
  Q5_TOK=0; [ -d "$T/r_a/.git/rebase-merge" ] && Q5_TOK=1
  # rozwiazanie reczne + --kontynuuj
  ( cd "$T/r_a" && printf 'l1\nl2\nrozwiazane\nl4\nl5\nl6\n' > wspolny.md && git add wspolny.md ) >/dev/null 2>&1
  ( cd "$T/r_a" && bash "$SAM" --kontynuuj > "$T/q_out4" 2>&1 ); RC_Q2=$?
  Q2_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && Q2_PUSH=1
  Q2_HASHE=0; _r_hash_ok a.md b.md && Q2_HASHE=1
  Q2_CZYSTO=0; [ ! -e "$T/r_a/.git/info/attributes" ] && [ ! -e "$T/r_a/.git/kronos_rebase_reczny" ] && [ ! -d "$T/r_a/.git/rebase-merge" ] && Q2_CZYSTO=1
  Q2_TRESC=0; ( cd "$T/r_a" && grep -qx rozwiazane wspolny.md && ! grep -qE '^(<<<<<<< |>>>>>>> )' wspolny.md && git show origin/prywatna:b.md | grep -qx b1 && grep -qx a1 a.md && grep -qx a2 a.md ) && Q2_TRESC=1
  # Q3 − ten sam rozjazd BEZ zmiennej: STOP jak dotad (rc=3), nic nie zostaje w toku
  _q_nowa; _r_run; RC_Q3=$?
  Q3_BRAK_TOKU=0; [ ! -d "$T/r_a/.git/rebase-merge" ] && [ ! -e "$T/r_a/.git/kronos_rebase_reczny" ] && Q3_BRAK_TOKU=1
  # Q4 − --kontynuuj bez rebase w toku = rc=1
  ( cd "$T/r_a" && bash "$SAM" --kontynuuj > /dev/null 2>&1 ); RC_Q4=$?
  # Q7 − U1-07 (08.10): --kontynuuj idzie przez TE SAME bezpieczniki co rebase auto. Rejestr z ksiegi odciskow (ALARMY_szereg.txt) dopisany przez OBIE rece
  # + konflikt tresci w pliku spoza listy → po rozwiazaniu reka i --kontynuuj odcisk w _HASHE.txt MUSI byc odciskiem tresci (dawniej: nieswiezy, push poszedl).
  _q7_nowa() { _r_nowa
    _r_b "sed -i 's/^l3\$/ich3/' wspolny.md; echo wb >> kanon/pomiary/ALARMY_szereg.txt" kanon/pomiary/ALARMY_szereg.txt
    ( cd "$T/r_a" && sed -i 's/^l3$/nasze3/' wspolny.md && echo wa >> kanon/pomiary/ALARMY_szereg.txt && bash hashuj.sh kanon/pomiary/ALARMY_szereg.txt >/dev/null 2>&1; git add -A; git commit -qm "nasz pierwszy" ) >/dev/null 2>&1; }
  _q7_nowa; ( cd "$T/r_a" && ZAPIS_REBASE_RECZNY=tak bash "$SAM" "test q7" > "$T/q7_out" 2>&1 ); RC_Q7A=$?
  ( cd "$T/r_a" && printf 'l1\nl2\nrozwiazane\nl4\nl5\nl6\n' > wspolny.md && git add wspolny.md ) >/dev/null 2>&1
  ( cd "$T/r_a" && bash "$SAM" --kontynuuj > "$T/q7_out2" 2>&1 ); RC_Q7B=$?
  Q7_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && Q7_PUSH=1
  Q7_HASHE=0; _r_hash_ok kanon/pomiary/ALARMY_szereg.txt && Q7_HASHE=1
  Q7_OBIE=0; [ "$(git -C "$T/r_zd.git" show prywatna:kanon/pomiary/ALARMY_szereg.txt 2>/dev/null | grep -cxE 'wa|wb')" = 2 ] && Q7_OBIE=1
  # Q8 − U1-08: --wycofaj zdejmuje WSZYSTKIE slady trybu recznego (plik stanu, kopie sterownika, NASZE wiersze merge=… w attributes), cudzych wpisow w attributes nie rusza.
  _q_nowa; printf '*.png binary\n' > "$T/r_a/.git/info/attributes"; _q_tryb; RC_Q8A=$?
  Q8_RADA=0; grep -q -e 'zapis_git.sh --wycofaj' "$T/q_out" && ! grep -q 'git rebase --abort' "$T/q_out" && Q8_RADA=1
  Q8_STAN_PRZED=0; [ -f "$T/r_a/.git/kronos_rebase_reczny" ] && ls "$T/r_a/.git"/kronos_hashe_przelicz.sterownik.sh >/dev/null 2>&1 && grep -q 'merge=union' "$T/r_a/.git/info/attributes" && Q8_STAN_PRZED=1
  ( cd "$T/r_a" && bash "$SAM" --wycofaj > "$T/q8_out" 2>&1 ); RC_Q8B=$?
  Q8_CZYSTO=0; [ ! -d "$T/r_a/.git/rebase-merge" ] && [ ! -e "$T/r_a/.git/kronos_rebase_reczny" ] && [ -z "$(ls "$T/r_a/.git"/kronos_hashe_przelicz* 2>/dev/null)" ] \
    && ! grep -q 'merge=' "$T/r_a/.git/info/attributes" 2>/dev/null && Q8_CZYSTO=1
  Q8_CUDZE=0; grep -qxF '*.png binary' "$T/r_a/.git/info/attributes" 2>/dev/null && Q8_CUDZE=1
  Q8_LOKALNE=0; ( cd "$T/r_a" && grep -qx nasze3 wspolny.md && git rev-parse --abbrev-ref HEAD | grep -qx prywatna ) && Q8_LOKALNE=1   # galaz wrocila, nasza tresc zostala
  # Q8c − zwykly zapis przy pliku stanu BEZ rebase w toku: rc=3 + zdanie o pozostalosci; po --wycofaj zapis znow biegnie
  printf 'STARY_LOCAL=x\n' > "$T/r_a/.git/kronos_rebase_reczny"
  ( cd "$T/r_a" && bash "$SAM" "test q8c" > "$T/q8c_out" 2>&1 ); RC_Q8C=$?
  Q8_RESZTKA=0; grep -q 'pozostałość trybu ręcznego — bash zapis_git.sh --wycofaj' "$T/q8c_out" && Q8_RESZTKA=1
  ( cd "$T/r_a" && bash "$SAM" --wycofaj >/dev/null 2>&1 ); ( cd "$T/r_a" && git fetch -q origin prywatna && git reset -q --hard FETCH_HEAD ) >/dev/null 2>&1   # rozjazd z Q1 to osobna sprawa (rc=3 z 15B) — zrownanie, zeby mierzyc TYLKO brak resztki
  ( cd "$T/r_a" && bash "$SAM" "test q8d" >/dev/null 2>&1 ); RC_Q8D=$?
  # Q9 − U1-09: tryb reczny scala plik spoza listy, zmieniony przez obie rece w ROZNYCH liniach, bez konfliktu — GLOSNO (nazwa pliku w meldunku) i z polem scalone= w wierszu biegu
  _r_nowa; _r_b "sed -i 's/^l1\$/ich1/' wspolny.md"; _r_a "sed -i 's/^l6\$/nasze6/' wspolny.md"
  ( cd "$T/r_a" && env -u _ZG_W_BIEG ZG_BIEGI=1 ZAPIS_REBASE_RECZNY=tak bash "$SAM" "test q9" > "$T/q9_out" 2>&1 ); RC_Q9=$?
  Q9_MELDUNEK=0; grep -q 'SCALONE AUTOMATYCZNIE' "$T/q9_out" && grep 'SCALONE AUTOMATYCZNIE' "$T/q9_out" | grep -q 'wspolny.md' && Q9_MELDUNEK=1
  Q9_POLE=0; grep -q ' · scalone=wspolny.md$' "$T/r_a/.git/zapis_biegi.nieznana.bufor" 2>/dev/null && Q9_POLE=1
  Q9_TRESC=0; git -C "$T/r_zd.git" show prywatna:wspolny.md 2>/dev/null | grep -qx ich1 && git -C "$T/r_zd.git" show prywatna:wspolny.md | grep -qx nasze6 && Q9_TRESC=1
  # Q9b − (−): zwykly bieg bez scalenia nie dopisuje pola scalone= (wiersze zostaja 6-polowe)
  _r_nowa; _r_a 'echo q9b > q9b.md'; ( cd "$T/r_a" && env -u _ZG_W_BIEG ZG_BIEGI=1 bash "$SAM" "test q9b" >/dev/null 2>&1 )
  Q9_BEZ_POLA=0; [ -s "$T/r_a/.git/zapis_biegi.nieznana.bufor" ] && ! grep -q 'scalone=' "$T/r_a/.git/zapis_biegi.nieznana.bufor" && Q9_BEZ_POLA=1
  # Q10 − U3-01 (09.10): wrapper biegu NIE przelewa bufora do sledzonego ZAPIS_biegi/<SESJA>.txt W TOKU rebase (brudzi drzewo → `rebase --continue` odmawia → STOP przerywa rebase).
  # STOP trybu recznego z biegiem liczonym (bufor niepusty PO STOPIE) → rozwiazanie → --kontynuuj tez z biegiem liczonym → rc=0, origin=HEAD, tresc reki; kolejny zwykly bieg przelewa wiersze do pliku sesji.
  # fikstura: plik sesji ZAPIS_biegi/<SESJA>.txt jest SLEDZONY (jak u prawdziwej sesji po pierwszym przelewie) — nieslesdzony nie brudzilby drzewa i tor nie oblewalby na starym kodzie
  _r_nowa; ( cd "$T/r_a" && mkdir -p kanon/pomiary/ZAPIS_biegi && printf '# seed\n' > kanon/pomiary/ZAPIS_biegi/nieznana.txt && git add -A && git commit -qm "seed plik sesji" && git push -q origin prywatna ) >/dev/null 2>&1
  ( cd "$T/r_b" && git pull -q --ff-only origin prywatna ) >/dev/null 2>&1; _q_rozjazd
  ( cd "$T/r_a" && env -u _ZG_W_BIEG ZG_BIEGI=1 ZAPIS_REBASE_RECZNY=tak bash "$SAM" "test q10" > "$T/q10_out" 2>&1 ); RC_Q10A=$?
  Q10_BUFOR=0; [ -s "$T/r_a/.git/zapis_biegi.nieznana.bufor" ] && [ -d "$T/r_a/.git/rebase-merge" ] && Q10_BUFOR=1
  ( cd "$T/r_a" && printf 'l1\nl2\nrozwiazane\nl4\nl5\nl6\n' > wspolny.md && git add wspolny.md ) >/dev/null 2>&1
  ( cd "$T/r_a" && env -u _ZG_W_BIEG ZG_BIEGI=1 bash "$SAM" --kontynuuj > "$T/q10_out2" 2>&1 ); RC_Q10B=$?
  Q10_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && Q10_PUSH=1
  Q10_TRESC=0; ( cd "$T/r_a" && grep -qx rozwiazane wspolny.md && ! grep -qE '^(<<<<<<< |>>>>>>> )' wspolny.md ) && Q10_TRESC=1
  _r_a 'echo q10b > q10b.md'; ( cd "$T/r_a" && env -u _ZG_W_BIEG ZG_BIEGI=1 bash "$SAM" "test q10 zwykly" >/dev/null 2>&1 ); RC_Q10C=$?
  Q10_PLIK=0; [ "$(git -C "$T/r_zd.git" show prywatna:kanon/pomiary/ZAPIS_biegi/nieznana.txt 2>/dev/null | grep -c ' rc=')" -ge 2 ] && Q10_PLIK=1
  # Q11 − U3-03 (09.10): --wycofaj NIE przerywa rebase, ktorego ten skrypt nie zaczal (brak pliku stanu) — rc=1 i zdanie; slady skryptu (nasze wiersze atrybutow) mimo to schodza, cudze zostaja.
  _q_nowa; ( cd "$T/r_a" && git add -A && git commit -qm "lokalny a2" && git fetch -q origin prywatna && git rebase origin/prywatna ) >/dev/null 2>&1
  printf '*.png binary\n/_HASHE.txt merge=kronos-hashe\n' > "$T/r_a/.git/info/attributes"
  Q11_TOK_PRZED=0; [ -d "$T/r_a/.git/rebase-merge" ] && [ ! -e "$T/r_a/.git/kronos_rebase_reczny" ] && Q11_TOK_PRZED=1
  ( cd "$T/r_a" && bash "$SAM" --wycofaj > "$T/q11_out" 2>&1 ); RC_Q11=$?
  Q11_TOK=0; [ -d "$T/r_a/.git/rebase-merge" ] && Q11_TOK=1
  Q11_KOMUNIKAT=0; grep -q 'nie pochodzi z trybu recznego' "$T/q11_out" && Q11_KOMUNIKAT=1
  Q11_SLADY=0; ! grep -q 'merge=' "$T/r_a/.git/info/attributes" 2>/dev/null && grep -qxF '*.png binary' "$T/r_a/.git/info/attributes" 2>/dev/null && Q11_SLADY=1
  ( cd "$T/r_a" && git rebase --abort ) >/dev/null 2>&1
  # Q12 − U3-04 (09.10): kopia pierwotnych atrybutow zginela miedzy procesami (kiedys mktemp w /tmp — sprzatanie /tmp, restart) → --kontynuuj NIE moze wywrocic sie na golym `cp` pod set -e.
  # STOP → plik kopii usuniety (sciezka z pliku stanu, wiec tor oblewa takze na starym kodzie) → rozwiazanie → --kontynuuj rc=0, push poszedl, w attributes zostaja tylko CUDZE wiersze.
  _q_nowa; printf '*.png binary\n' > "$T/r_a/.git/info/attributes"; _q_tryb; RC_Q12A=$?
  Q12_KOPIA=0; _q12_k="$(sed -n 's/^ATTR_PIERWOTNE=//p' "$T/r_a/.git/kronos_rebase_reczny" 2>/dev/null | tail -1)"; [ -n "$_q12_k" ] && [ -f "$_q12_k" ] && Q12_KOPIA=1
  Q12_W_GIT=0; case "$_q12_k" in "$T/r_a/.git/"*) Q12_W_GIT=1 ;; esac   # kopia lezy w .git sesji, nie w /tmp
  [ -n "$_q12_k" ] && rm -f "$_q12_k"
  ( cd "$T/r_a" && printf 'l1\nl2\nrozwiazane\nl4\nl5\nl6\n' > wspolny.md && git add wspolny.md ) >/dev/null 2>&1
  ( cd "$T/r_a" && bash "$SAM" --kontynuuj > "$T/q12_out" 2>&1 ); RC_Q12B=$?
  Q12_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && Q12_PUSH=1
  Q12_ATTR=0; ! grep -q 'merge=' "$T/r_a/.git/info/attributes" 2>/dev/null && grep -qxF '*.png binary' "$T/r_a/.git/info/attributes" 2>/dev/null && Q12_ATTR=1
  Q12_STAN=0; [ ! -e "$T/r_a/.git/kronos_rebase_reczny" ] && [ ! -d "$T/r_a/.git/rebase-merge" ] && Q12_STAN=1
  # (w) WYSCIG O ORIGIN (04.10.2026): druga reka wypycha W TRAKCIE bramki. Atrapa baterii liczy swoje biegi i sama
  # robi push z r_b — tak wyglada wyscig naprawde (origin rusza, gdy bateria biegnie), a licznik mowi, ile razy mierzono.
  _w_atrapa() {   # $1 = ruch drugiej reki · $2 = 1: tylko przy pierwszym biegu baterii, 0: przy kazdym
    rm -f "$T/w_licznik" "$T/w_pchniete"
    { printf '#!/bin/sh\necho x >> "%s/w_licznik"\n' "$T"
      printf 'if [ "%s" = 0 ] || [ ! -f "%s/w_pchniete" ]; then : > "%s/w_pchniete"\n' "$2" "$T" "$T"
      printf '  ( cd "%s/r_b" && git pull -q --ff-only origin prywatna; %s; git add -A; git commit -qm wyscig; git push -q origin prywatna ) >/dev/null 2>&1\nfi\n' "$T" "$1"
      printf 'echo "  zmierzone: zdanych 52 · oblanych 0 · bez toru 0"\n'
    } > "$T/bateria_wyscig.sh"
  }
  _w_run() { ( cd "$T/r_a" && ZG_TORY_CMD="sh $T/bateria_wyscig.sh" bash "$SAM" "test w" > "$T/r_out" 2>&1 ); }
  _w_licz() { [ -f "$T/w_licznik" ] && wc -l < "$T/w_licznik" | tr -d ' ' || echo 0; }
  # W1 + druga reka dopisuje do rejestru (sciezka NEUTRALNA dla baterii): ponowienie, bateria JEDEN raz, obie rece na origin
  _r_nowa; _w_atrapa 'echo ich-wyscig >> kanon/pomiary/KRZESLA_zlapane.txt' 1; _r_a 'echo n > nowy_a.md'
  _w_run; RC_W1=$?
  W1_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && W1_PUSH=1
  W1_BAT="$(_w_licz)"; W1_OBIE=0; ( cd "$T/r_a" && grep -qx ich-wyscig kanon/pomiary/KRZESLA_zlapane.txt && [ -f nowy_a.md ] ) && W1_OBIE=1
  # W2 + druga reka zmienia plik SPOZA listy neutralnych: ponowienie, ale bateria DRUGI raz (pomiar sie nie przenosi)
  _r_nowa; _w_atrapa 'echo c1 >> c.md' 1; _r_a 'echo n > nowy_a.md'
  _w_run; RC_W2=$?
  W2_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && W2_PUSH=1
  W2_BAT="$(_w_licz)"
  # W5 + lista neutralnych jest WASKA: kanon/ksiegi/* poza nazwanymi rejestrami czytaja zywe tory (straz_r0, pokrycie_m) → bateria DRUGI raz
  _r_nowa; _w_atrapa 'echo wpis >> kanon/ksiegi/ksiega.md' 1; _r_a 'echo n > nowy_a.md'
  _w_run; RC_W5=$?
  W5_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && W5_PUSH=1
  W5_BAT="$(_w_licz)"
  # W3 − wyscig na TYM SAMYM pliku spoza bialej listy: 15B stoi takze w ponowieniu → rc=3, origin nietkniety
  _r_nowa; _w_atrapa "sed -i 's/^l1\$/ich1/' wspolny.md" 1; _r_a "sed -i 's/^l6\$/nasze6/' wspolny.md"
  _w_run; RC_W3=$?
  W3_ORIGIN=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_b" rev-parse HEAD)" ] && W3_ORIGIN=1
  # W4 − origin rusza przy KAZDEJ probie: po 3 probach koniec, origin nietkniety przez nas, zadnego force
  _r_nowa; _w_atrapa 'echo c >> c.md' 0; _r_a 'echo n > nowy_a.md'
  _w_run; RC_W4=$?
  W4_BAT="$(_w_licz)"; W4_ORIGIN=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_b" rev-parse HEAD)" ] && W4_ORIGIN=1
  W4_NIEPCHNIETE=0; [ "$(_r_sha_zd)" != "$(git -C "$T/r_a" rev-parse HEAD)" ] && W4_NIEPCHNIETE=1
  # R8 — sterownik z kopii: origin NIE ma merge_hashe.sh, nasz commit go dodaje (pierwszy push z R1)
  _r_nowa; ( cd "$T/r_a" && cp "$SAM" zapis_git.sh && mkdir -p narzedzia/przyrzady && cp "$(dirname "$SAM")/narzedzia/przyrzady/merge_hashe.sh" narzedzia/przyrzady/ )
  _r_b 'echo b1 >> b.md' b.md; _r_a 'echo a1 >> a.md' a.md
  ( cd "$T/r_a" && bash zapis_git.sh "test r8" > "$T/r_out" 2>&1 ); RC_R8=$?
  R8_HASHE=0; _r_hash_ok a.md b.md && R8_HASHE=1
  R8_PUSH=0; [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && R8_PUSH=1
  # (m) R3 (03.10.2026, #125): komunikat zaczynajacy sie od `-` → odmowa PRZED ruchem; bez argumentu → ostrzezenie
  _r_nowa; echo zly > "$T/r_a/zly.md"
  ( cd "$T/r_a" && bash "$SAM" "-m opis" > "$T/r_out" 2>&1 ); RC_M1=$?
  M1_NIETKNIETE=0; [ -n "$(git -C "$T/r_a" status --porcelain | grep zly.md)" ] && [ "$(git -C "$T/r_a" log --format=%s -1)" = "seed" ] && M1_NIETKNIETE=1
  _r_nowa; echo dobry > "$T/r_a/dobry.md"
  ( cd "$T/r_a" && bash "$SAM" > "$T/r_out" 2>&1 ); RC_M2=$?
  M2_OSTRZEZENIE=0; grep -q "ostrzezenie: tworze commit" "$T/r_out" && M2_OSTRZEZENIE=1
  _r_nowa; echo opisany > "$T/r_a/opisany.md"
  ( cd "$T/r_a" && bash "$SAM" "opis wlasny" > "$T/r_out" 2>&1 ); RC_M3=$?
  M3_CISZA=0; ! grep -q "ostrzezenie: tworze commit" "$T/r_out" && M3_CISZA=1
  # (bw) WIERSZ POMIARU NA BIEG (S2, 04.10): 6 pol · bufor w .git, drzewo po biegu czyste · wiersz do pliku sesji dopiero w NASTEPNYM biegu ·
  # rc=3 niesie plik winny · rebase=T przy rebase auto. Sesja nieznana (tor czysci zmienna) = plik „nieznana”.
  _bw() { ( cd "$T/r_a" && env -u _ZG_W_BIEG ZG_BIEGI=1 bash "$SAM" "test bieg" >/dev/null 2>&1 ); echo $?; }
  BW5_OBCY=0; [ ! -s "$T/stan_obcy" ] && BW5_OBCY=1   # rebase fikstur (c, R*, W*) NIE trafil do dziedziczonego pliku stanu
  _bw_buf="$T/r_a/.git/zapis_biegi.nieznana.bufor"; _bw_sep=" · "   # separator w zmiennej: lint klas znakow (#80) nie lubi „·” w jednej linii z klamra testu i awk/grep
  _r_nowa; _r_a 'echo b1 > bieg1.md'
  RC_BW1="$(_bw)"
  BW1_POLA=0; [ "$(wc -l < "$_bw_buf" 2>/dev/null | tr -d ' ')" = 1 ] && [ "$(awk -F"$_bw_sep" 'NR==1{print NF}' "$_bw_buf")" = 6 ] && BW1_POLA=1
  BW1_ODDECH=0; grep -q ' · oddech=wolny · ' "$_bw_buf" 2>/dev/null && BW1_ODDECH=1
  BW1_CZYSTE=0; [ -z "$(git -C "$T/r_a" status --porcelain)" ] && BW1_CZYSTE=1
  _r_a 'echo b2 > bieg2.md'; RC_BW2="$(_bw)"
  BW2_PLIK=0; [ "$(git -C "$T/r_zd.git" show prywatna:kanon/pomiary/ZAPIS_biegi/nieznana.txt 2>/dev/null | grep -c "${_bw_sep}rc=0${_bw_sep}")" = 1 ] && BW2_PLIK=1
  BW2_BUFOR=0; [ "$(wc -l < "$_bw_buf" 2>/dev/null | tr -d ' ')" = 1 ] && BW2_BUFOR=1
  _r_nowa; _r_b 'echo ich >> kanon/pomiary/KRZESLA_zlapane.txt'; _r_a 'echo nasze >> kanon/pomiary/KRZESLA_zlapane.txt'
  RC_BW3="$(_bw)"; BW3_REBASE=0; grep -q ' · rebase=T · ' "$_bw_buf" 2>/dev/null && BW3_REBASE=1
  _r_nowa; _r_b "sed -i 's/^l1\$/ich1/' wspolny.md"; _r_a "sed -i 's/^l6\$/nasze6/' wspolny.md"
  RC_BW4="$(_bw)"; BW4_WINNY=0; grep -q ' · rc=3 · .* · winny=wspolny.md$' "$_bw_buf" 2>/dev/null && BW4_WINNY=1
  # (o) DWA ODDECHY (S3, 04.10): ruch wylacznie z listy neutralnych → ODDECH SZYBKI (bateria 0×); cokolwiek spoza listy → WOLNY (1×).
  # Atrapa liczy biegi; z flaga 1 drugi klon pcha SZYBKO (przez ten sam zapis_git.sh) W TRAKCIE wolnej bramki pierwszego.
  _o_atrapa() {
    rm -f "$T/o_licznik" "$T/o_pchniete"
    { printf '#!/bin/sh\necho x >> "%s/o_licznik"\n' "$T"
      if [ "$1" = 1 ]; then
        printf 'if [ ! -f "%s/o_pchniete" ]; then : > "%s/o_pchniete"\n' "$T" "$T"
        printf '  ( cd "%s/r_b" && git pull -q --ff-only origin prywatna; mkdir -p kanon/plany; echo b > kanon/plany/b.md; bash "%s" "druga reka szybko" ) >/dev/null 2>&1\nfi\n' "$T" "$SAM"
      fi
      printf 'echo "  zmierzone: zdanych 52 · oblanych 0 · bez toru 0"\n'
    } > "$T/o_atrapa.sh"
  }
  _o_run() { ( cd "$T/r_a" && ZG_TORY_CMD="sh $T/o_atrapa.sh" bash "$SAM" "test o" 2>&1 ); }
  _o_licz() { [ -f "$T/o_licznik" ] && wc -l < "$T/o_licznik" | tr -d ' ' || echo 0; }
  _o_pchnieto() { [ "$(_r_sha_zd)" = "$(git -C "$T/r_a" rev-parse HEAD)" ] && echo 1 || echo 0; }
  # O1 + sam plan/kartka/rejestr → SZYBKI: bateria 0×, push poszedl
  _r_nowa; _o_atrapa 0; _r_a 'mkdir -p kanon/plany; echo p > kanon/plany/p.md'
  OUT_O1="$(_o_run)"; RC_O1=$?; O1_BAT="$(_o_licz)"; O1_PUSH="$(_o_pchnieto)"; O1_MELD=0; case "$OUT_O1" in *"ODDECH SZYBKI"*) O1_MELD=1 ;; esac
  # O2 − neutralny plik RAZEM z plikiem spoza listy → WOLNY: bateria 1× (szybka sciezka nie moze przepuscic kodu)
  _r_nowa; _o_atrapa 0; _r_a 'mkdir -p kanon/plany; echo p > kanon/plany/p.md; echo c > kod.js'
  OUT_O2="$(_o_run)"; RC_O2=$?; O2_BAT="$(_o_licz)"; O2_PUSH="$(_o_pchnieto)"; O2_MELD=0; case "$OUT_O2" in *"ODDECH WOLNY"*) O2_MELD=1 ;; esac
  # O3 + wyscig: nasz ruch spoza listy (wolny), a w trakcie bramki drugi klon pcha SZYBKO → ponowienie, rebase auto, bateria nadal 1× (pierwsza; jej szybkiej nie bylo), obie rece na origin
  _r_nowa; _o_atrapa 1; _r_a 'echo c > kod.js'
  OUT_O3="$(_o_run)"; RC_O3="$?"; O3_BAT="$(_o_licz)"; O3_PUSH="$(_o_pchnieto)"
  O3_OBIE=0; ( cd "$T/r_a" && [ -f kanon/plany/b.md ] && [ -f kod.js ] ) && O3_OBIE=1
  # O4 + origin ma cudzy KOD, nasz ruch neutralny → SZYBKI (liczy sie ruch NASZYCH commitow wzgledem merge-base, nie roznica z origin)
  _r_nowa; _o_atrapa 0; _r_b 'echo c >> c.md'; _r_a 'mkdir -p kanon/plany; echo p > kanon/plany/p.md'
  OUT_O4="$(_o_run)"; RC_O4=$?; O4_BAT="$(_o_licz)"; O4_PUSH="$(_o_pchnieto)"
  # (⊗) AWARIA AUTH — fikstura musi stanąć PRZED sprzątnięciem katalogu roboczego.
  ( cd "$T/praca" && git remote set-url origin "https://127.0.0.1:1/nie-ma.git" )
  OUT_AUTH="$(cd "$T/praca" && bash "$SAM" "test auth" 2>&1)"; RC_AUTH=$?
  # (g) TOKEN NIGDY W URL (18.09.2026, słowo twórcy) — świadek STRUKTURALNY: sprawdzamy
  # ŻYWY plik pod testem ($SAM), nie kopię w pamięci. Szukamy ciągu, który dawny kod
  # budował, sklejając zmienną tokenu wprost przed znakiem @ w adresie — jego powrót
  # (regres na starą wersję) MUSI oblać ten tor, inaczej świadek jest dekoracją.
  # UWAGA przyszłej ręce: nie pisz tego wzorca w komentarzu w pełnej postaci — grep
  # złapałby WŁASNY opis (zmierzone: pierwsza wersja tego testu sama się oblewała).
  WZORZEC_URL=0
  grep -Eq '\$\{?KRONOS_PAT\}?@' "$SAM" && WZORZEC_URL=1
  HELPER_OK=0
  grep -q 'credential.helper=.\!f(){ echo username=x-access-token; echo "password=\$KRONOS_PAT"; }; f.' "$SAM" && HELPER_OK=1
  # (h) CO-AUTHORED-BY — opt-in: ustawiony → trailer w komunikacie; nieustawiony → brak.
  # `env -u` na teście WYŁĄCZONYM jest KONIECZNY, nie kosmetyczny: bez niego ambientny
  # `export KRONOS_COAUTHOR=...` w powłoce WOŁAJĄCEJ ten tor (np. przy realnym pushu z
  # trailerem) przecieka do dziecka i fałszywie zieleni „wyłączony" — złapane na żywo,
  # ta sama klasa co #90: izolacja od otoczenia, nie sama obecność zmiennej w tej linii.
  ( cd "$T/praca"
    echo "coauthor test" > coauthor.md
    KRONOS_COAUTHOR="Test Osoba <test@example.com>" bash "$SAM" "test coauthor wl" >/dev/null 2>&1
    git log -1 --format=%B | grep -qF "Co-authored-by: Test Osoba <test@example.com>" \
      && echo 1 > "$T/trailer_wl" || echo 0 > "$T/trailer_wl"
    echo "coauthor test2" > coauthor2.md
    env -u KRONOS_COAUTHOR bash "$SAM" "test coauthor wyl" >/dev/null 2>&1
    if git log -1 --format=%B | grep -q "Co-authored-by:"; then echo 0 > "$T/trailer_wyl"; else echo 1 > "$T/trailer_wyl"; fi
  )
  TRAILER_WL="$(cat "$T/trailer_wl" 2>/dev/null || echo 0)"
  TRAILER_WYL="$(cat "$T/trailer_wyl" 2>/dev/null || echo 0)"
  set -e
  cd /; rm -rf "$T"

  echo "── TEST + (świeże żniwo, push+weryfikacja):     rc=$RC_A (oczekiwane 0)"
  echo "── TEST ⊙ (nic do pchnięcia):                   rc=$RC_B (oczekiwane 0)"
  echo "── TEST + (rozejście BEZ ryzyka → rebase auto): rc=$RC_C (oczekiwane 0)"
  echo "── TEST + (rebase auto scalił OBIE ręce):       oba pliki obecne: $SCALONE (oczekiwane 1)"
  echo "── TEST − (kolizja na tym samym pliku):         rc=$RC_D (oczekiwane 3)"
  echo "── TEST − (żaden cichy merge treści, 15B):      nasza wersja nietknięta: $NASZ_SPORNY (oczekiwane 1)"
  echo "── TRYB-RECZNY + (stop TYLKO na pliku tresci):  rc=$RC_Q1 · konflikt wylacznie wspolny.md: $Q1_TYLKO · rebase w toku + stan + --kontynuuj w komunikacie: $Q1_STAN (oczekiwane 3 · 1 · 1)"
  echo "── TRYB-RECZNY − (zwykly zapis w toku / nierozwiazane): rc=$RC_Q6 (komunikat W TOKU: $Q6_KOMUNIKAT) / $RC_Q5 · rebase dalej w toku: $Q5_TOK (oczekiwane 3 / 3 · 1)"
  echo "── TRYB-RECZNY + (--kontynuuj po rozwiazaniu):  rc=$RC_Q2 · pchnieto: $Q2_PUSH · _HASHE swiezy: $Q2_HASHE · czysto po: $Q2_CZYSTO · tresc obu rak: $Q2_TRESC (oczekiwane 0 · 1 · 1 · 1 · 1)"
  echo "── TRYB-RECZNY − (bez zmiennej: STOP jak dotad / --kontynuuj bez rebase): rc=$RC_Q3 · nic w toku: $Q3_BRAK_TOKU / rc=$RC_Q4 (oczekiwane 3 · 1 / 1)"
  echo "── U1-07 + (--kontynuuj przez B1–B4: rejestr obu rak):  stop rc=$RC_Q7A · kontynuuj rc=$RC_Q7B · pchnieto: $Q7_PUSH · odcisk rejestru zgodny: $Q7_HASHE · obie linie: $Q7_OBIE (oczekiwane 3 · 0 · 1 · 1 · 1)"
  echo "── U1-08 + (--wycofaj zdejmuje slady):  rada: $Q8_RADA · stan przed: $Q8_STAN_PRZED · rc=$RC_Q8B · czysto: $Q8_CZYSTO · cudze atrybuty: $Q8_CUDZE · galaz+tresc: $Q8_LOKALNE (oczekiwane 1 · 1 · 0 · 1 · 1 · 1)"
  echo "── U1-08 − (resztka stanu bez rebase):  zapis rc=$RC_Q8C · zdanie: $Q8_RESZTKA · po --wycofaj zapis rc=$RC_Q8D (oczekiwane 3 · 1 · 0)"
  echo "── U1-09 + (tryb reczny scala glosno):  rc=$RC_Q9 · meldunek z nazwa pliku: $Q9_MELDUNEK · pole scalone=: $Q9_POLE · tresc obu rak: $Q9_TRESC · zwykly bieg bez pola: $Q9_BEZ_POLA (oczekiwane 0 · 1 · 1 · 1 · 1)"
  echo "── U3-01 (przelew bufora nie w trakcie rebase):  STOP rc=$RC_Q10A · bufor niepusty w toku: $Q10_BUFOR · --kontynuuj rc=$RC_Q10B · push: $Q10_PUSH · tresc reki: $Q10_TRESC · zwykly bieg rc=$RC_Q10C · wiersze w pliku sesji na origin: $Q10_PLIK (oczekiwane 3 · 1 · 0 · 1 · 1 · 0 · 1)"
  echo "── U3-03 (--wycofaj nie rusza cudzego rebase):  rebase cudzy w toku przed: $Q11_TOK_PRZED · --wycofaj rc=$RC_Q11 · rebase nadal w toku: $Q11_TOK · zdanie: $Q11_KOMUNIKAT · nasze slady zdjete, cudze zostaja: $Q11_SLADY (oczekiwane 1 · 1 · 1 · 1 · 1)"
  echo "── U3-04 (kopia atrybutow w .git, brak kopii nie wywraca):  STOP rc=$RC_Q12A · kopia byla: $Q12_KOPIA · w .git: $Q12_W_GIT · --kontynuuj rc=$RC_Q12B · push: $Q12_PUSH · tylko cudze atrybuty: $Q12_ATTR · stan zdjety: $Q12_STAN (oczekiwane 3 · 1 · 1 · 0 · 1 · 1 · 1)"
  echo "── TEST − (komunikat STOP nie radzi golego rebase): brzmienie 6a + plik winny: $D_BRZMIENIE (oczekiwane 1)"
  echo "── TEST − (druga ręka USUWA plik, 15B):         rc=$RC_E (oczekiwane 3)"
  echo "── TEST − (usuwany plik ocalał u nas, 15B):     obecny: $OCALONY (oczekiwane 1)"
  echo "── TEST ⊙ (gałąź nieobecna na origin):          rc=$RC_W (oczekiwane 6 — nie odsyłamy po token)"
  echo "── BRAMKA + (dług = baseline 7, push idzie):    rc=$RC_FP · pchnięto: $PCHNIETO_F · meldunek o długu: $DLUG_MELD (oczekiwane 0 · 1 · 1)"
  echo "── BRAMKA − (regres 7→8, ODMOWA):               rc=$RC_FM · origin nietknięty: $ORIGIN_NIETKNIETY (oczekiwane 7 · 1)"
  echo "── BRAMKA ⊙ (bateria nie zmierzyła):            rc=$RC_FNIC (oczekiwane 7 — brak liczby to nie zero)"
  echo "── BASELINE-NAZWY − (ta liczba, NOWA nazwa):    rc=$RC_NM · origin nietkniety: $N_NIETKNIETY · nazwa w komunikacie: $N_NAZWA (oczekiwane 7 · 1 · 1)"
  echo "── BASELINE-NAZWY + (ta liczba, ZASTANA nazwa): rc=$RC_NP (oczekiwane 0) · baseline stary bez nazw: rc=$RC_NS (oczekiwane 0)"
  echo "── BASELINE-NAZWY zapis (--baseline-baterii niesie nazwy): oblane=gotowosc,stol: $NW_ZAPIS (oczekiwane 1)"
  # (⊗) AWARIA AUTH — pierwsza podpowiedź MUSI kierować do ŹRÓDŁA poświadczenia (#65).
  # Fikstura: origin wskazuje na nieosiągalny host, więc `fetch` pada tą samą ścieżką
  # co przy martwym tokenie. Mierzymy TREŚĆ komunikatu, nie sam fakt oblania (#49):
  # skrypt oblewał i przedtem, tylko odsyłał instancję po token, który już podała.
  ZRODLO=0; case "$OUT_AUTH" in *"NAJPIERW ŹRÓDŁO"*) ZRODLO=1 ;; esac
  # ...i MUSI paść przed zdaniem o podaniu tokenu — kolejność jest całą treścią blizny.
  PIERWSZE=0
  [ "$ZRODLO" -eq 1 ] && [ "${OUT_AUTH%%NAJPIERW ŹRÓDŁO*}" != "${OUT_AUTH%%KRONOS_PAT=*}" ] \
    && case "${OUT_AUTH%%KRONOS_PAT=*}" in *"NAJPIERW ŹRÓDŁO"*) PIERWSZE=1 ;; esac
  echo "── TEST ⊗ (awaria AUTH):                        źródło w komunikacie: $ZRODLO · przed tokenem: $PIERWSZE (oczekiwane 1 · 1)"
  echo "── TEST − (token NIGDY jako podłańcuch URL):    wzorzec stary NIEobecny: $((1-WZORZEC_URL)) · helper obecny: $HELPER_OK (oczekiwane 1 · 1)"
  echo "── KARTECZKA − (bez karteczki, ODMOWA):         rc=$RC_K1 · origin nietkniety: $K1_NIETKNIETY (oczekiwane 8 · 1)"
  echo "── KARTECZKA + (wieszanie niesie rejestr):      rc=$RC_K2 (oczekiwane 0)"
  echo "── KARTECZKA + (wlasna karteczka w HEAD):       rc=$RC_K3 (oczekiwane 0)"
  echo "── KARTECZKA − (INNA sesja bez karteczki):      rc=$RC_K4 (oczekiwane 8)"
  echo "── KARTECZKA + (furtka jawna z powodem):        rc=$RC_K5 (oczekiwane 0)"
  echo "── KARTECZKA + (domkniecie niesie rejestr):     rc=$RC_K6 (oczekiwane 0)"
  echo "── KARTKA SESJI + (wieszanie niesie katalog):   rc=$RC_K7 (oczekiwane 0)"
  echo "── KARTKA SESJI + (wlasna kartka w HEAD):       rc=$RC_K8 (oczekiwane 0)"
  echo "── KARTKA SESJI − (cudza kartka, nie moja):     rc=$RC_K9 (oczekiwane 8)"
  echo "── KARTECZKA + (po oddaniu: sam wiersz biegu):  rc=$RC_K10 (oczekiwane 0; stan wyjsciowy $RC_K10A=0)"
  echo "── KARTECZKA − (po oddaniu: wiersz + plik obcy):rc=$RC_K11 (oczekiwane 8)"
  echo "── BRAMKA PRZYRZADOW − (4 sciezki chronione, kartka zwykla): rc=$RC_BR1 · origin nietkniety: $BR1_NIETKNIETY (oczekiwane 8888 · 1)"
  echo "── BRAMKA PRZYRZADOW + (kartka BRAMKA w HEAD):  rc=$RC_BR2 · pchnieto: $BR2_PUSH (oczekiwane 0 · 1)"
  echo "── BRAMKA PRZYRZADOW + (furtka jawna z powodem): rc=$RC_BR3 (oczekiwane 0)"
  echo "── BRAMKA PRZYRZADOW − (furtka KARTECZKOWA nie otwiera): rc=$RC_BR4 (oczekiwane 8)"
  echo "── BRAMKA PRZYRZADOW + (zwykly plik, kartka zwykla): rc=$RC_BR5 · bez ruchu chronionego (oczekiwane 0)"
  echo "── REBASE-REJESTRY + (obie rece dopisuja):      rc=$RC_R1 · obie linie: $R1_OBIE · pchnieto: $R1_PUSH · attributes jak przed: $R1_ATTR (oczekiwane 0 · 1 · 1 · 1)"
  echo "── REBASE-REJESTRY + (rozne pliki z odciskiem): rc=$RC_R2 · odciski zgodne: $R2_HASHE · pchnieto: $R2_PUSH (oczekiwane 0 · 1 · 1)"
  echo "── REBASE-REJESTRY + (rejestr z odciskiem, B4): rc=$RC_R3 · odcisk: $R3_HASHE · commit B4: $R3_B4 · obie linie: $R3_OBIE (oczekiwane 0 · 1 · 1 · 1)"
  echo "── REBASE-REJESTRY − (wspolny plik SPOZA listy): rc=$RC_R4 · origin nietkniety: $R4_ORIGIN · bez rebase: $R4_HEAD (oczekiwane 3 · 1 · 1)"
  echo "── REBASE-REJESTRY − (dwa STATUS, B3):          rc=$RC_R5 · HEAD cofniety: $R5_HEAD · attributes sprzed biegu po porazce: $R5_ATTR (oczekiwane 3 · 1 · 1)"
  echo "── REBASE-REJESTRY − (regres po rebase, B5):    rc=$RC_R6 · HEAD cofniety: $R6_HEAD · origin nietkniety: $R6_ORIGIN (oczekiwane 7 · 1 · 1)"
  echo "── REBASE-REJESTRY − (zgubiona linia, B1):      rc=$RC_R7 · HEAD cofniety: $R7_HEAD (oczekiwane 3 · 1)"
  echo "── REBASE-REJESTRY − (zgubiona KROTNOSC, B1):    rc=$RC_R10 · HEAD cofniety: $R10_HEAD · meldunek z krotnoscia 1<2: $R10_KROTNOSC (oczekiwane 3 · 1 · 1)"
  echo "── REBASE-REJESTRY − (sklejony ogon wpisu, B3, #127): rc=$RC_R9 · HEAD cofniety: $R9_HEAD · origin nietkniety: $R9_ORIGIN (oczekiwane 3 · 1 · 1)"
  echo "── REBASE-REJESTRY + (sterownik z kopii, origin go nie ma): rc=$RC_R8 · odciski zgodne: $R8_HASHE · pchnieto: $R8_PUSH (oczekiwane 0 · 1 · 1)"
  echo "── STYK KARTKI + (druga reka ODDAJE kartke, #129): rc=$RC_R11 · pchnieto: $R11_PUSH · ODDANE dotarlo: $R11_ODDANE (oczekiwane 0 · 1 · 1)"
  echo "── STYK KARTKI − (druga reka KASUJE kartke, 15B bez wyjatku): rc=$RC_R12 · origin nietkniety: $R12_ORIGIN (oczekiwane 3 · 1)"
  echo "── WYSCIG + (druga reka pcha rejestr w trakcie bramki): rc=$RC_W1 · pchnieto: $W1_PUSH · biegow baterii: $W1_BAT · obie rece: $W1_OBIE (oczekiwane 0 · 1 · 1 · 1)"
  echo "── WYSCIG + (druga reka pcha plik spoza neutralnych): rc=$RC_W2 · pchnieto: $W2_PUSH · biegow baterii: $W2_BAT (oczekiwane 0 · 1 · 2)"
  echo "── WYSCIG + (druga reka pcha kanon/ksiegi spoza listy): rc=$RC_W5 · pchnieto: $W5_PUSH · biegow baterii: $W5_BAT (oczekiwane 0 · 1 · 2)"
  echo "── WYSCIG − (ten sam plik spoza listy, 15B):    rc=$RC_W3 · origin nietkniety: $W3_ORIGIN (oczekiwane 3 · 1)"
  echo "── WYSCIG − (origin rusza przy kazdej probie):  rc=$RC_W4 · biegow baterii: $W4_BAT · origin nietkniety: $W4_ORIGIN · nasze niepchniete: $W4_NIEPCHNIETE (oczekiwane ≠0 · 3 · 1 · 1)"
  echo "── WIERSZ-BIEGU + (sciezka rc=0: 6 pol · oddech · drzewo czyste): rc=$RC_BW1 · pola: $BW1_POLA · oddech: $BW1_ODDECH · czyste: $BW1_CZYSTE (oczekiwane 0 · 1 · 1 · 1)"
  echo "── WIERSZ-BIEGU + (wiersz do pliku sesji w NASTEPNYM biegu): rc=$RC_BW2 · plik w origin: $BW2_PLIK · bufor: $BW2_BUFOR (oczekiwane 0 · 1 · 1)"
  echo "── WIERSZ-BIEGU + (rebase auto: rebase=T):      rc=$RC_BW3 · rebase T: $BW3_REBASE (oczekiwane 0 · 1)"
  echo "── WIERSZ-BIEGU − (rc=3: plik winny w wierszu): rc=$RC_BW4 · winny: $BW4_WINNY (oczekiwane 3 · 1)"
  echo "── WIERSZ-BIEGU − (fikstury nie pisza do cudzego pliku stanu): nietkniety: $BW5_OBCY (oczekiwane 1)"
  echo "── ODDECH SZYBKI + (sam plan/kartka, neutralne):  rc=$RC_O1 · bateria: $O1_BAT · pchnieto: $O1_PUSH · meldunek: $O1_MELD (oczekiwane 0 · 0 · 1 · 1)"
  echo "── ODDECH WOLNY − (neutralne + plik spoza listy): rc=$RC_O2 · bateria: $O2_BAT · pchnieto: $O2_PUSH · meldunek: $O2_MELD (oczekiwane 0 · 1 · 1 · 1)"
  echo "── ODDECH + (wyscig: drugi klon pcha SZYBKO w trakcie wolnej bramki): rc=$RC_O3 · bateria: $O3_BAT · pchnieto: $O3_PUSH · obie rece: $O3_OBIE (oczekiwane 0 · 1 · 1 · 1)"
  echo "── ODDECH SZYBKI + (cudzy KOD na origin, nasz ruch neutralny): rc=$RC_O4 · bateria: $O4_BAT · pchnieto: $O4_PUSH (oczekiwane 0 · 0 · 1)"
  echo "── ZAPIS-KOMUNIKAT − (komunikat od '-', ODMOWA): rc=$RC_M1 · repo nietkniete: $M1_NIETKNIETE (oczekiwane 9 · 1)"
  echo "── ZAPIS-KOMUNIKAT + (bez argumentu: ostrzega): rc=$RC_M2 · ostrzezenie: $M2_OSTRZEZENIE (oczekiwane 0 · 1)"
  echo "── ZAPIS-KOMUNIKAT + (wlasny opis: bez ostrzezenia): rc=$RC_M3 · cisza: $M3_CISZA (oczekiwane 0 · 1)"
  echo "── TEST + (Co-authored-by, WŁĄCZONY):           trailer obecny: $TRAILER_WL (oczekiwane 1)"
  echo "── TEST − (Co-authored-by, WYŁĄCZONY domyślnie): trailer NIEobecny: $TRAILER_WYL (oczekiwane 1)"
  echo
  if [ "$RC_A" -eq 0 ] && [ "$RC_B" -eq 0 ] && [ "$RC_C" -eq 0 ] && [ "$SCALONE" -eq 1 ] \
     && [ "$RC_D" -eq 3 ] && [ "$NASZ_SPORNY" -eq 1 ] && [ "$D_BRZMIENIE" -eq 1 ] \
     && [ "$RC_Q1" -eq 3 ] && [ "$Q1_TYLKO" -eq 1 ] && [ "$Q1_STAN" -eq 1 ] && [ "$RC_Q6" -eq 3 ] && [ "$Q6_KOMUNIKAT" -eq 1 ] && [ "$RC_Q5" -eq 3 ] && [ "$Q5_TOK" -eq 1 ] \
     && [ "$RC_Q2" -eq 0 ] && [ "$Q2_PUSH" -eq 1 ] && [ "$Q2_HASHE" -eq 1 ] && [ "$Q2_CZYSTO" -eq 1 ] && [ "$Q2_TRESC" -eq 1 ] \
     && [ "$RC_Q3" -eq 3 ] && [ "$Q3_BRAK_TOKU" -eq 1 ] && [ "$RC_Q4" -eq 1 ] && [ "$RC_E" -eq 3 ] && [ "$OCALONY" -eq 1 ] \
     && [ "$RC_Q7A" -eq 3 ] && [ "$RC_Q7B" -eq 0 ] && [ "$Q7_PUSH" -eq 1 ] && [ "$Q7_HASHE" -eq 1 ] && [ "$Q7_OBIE" -eq 1 ] \
     && [ "$RC_Q8A" -eq 3 ] && [ "$Q8_RADA" -eq 1 ] && [ "$Q8_STAN_PRZED" -eq 1 ] && [ "$RC_Q8B" -eq 0 ] && [ "$Q8_CZYSTO" -eq 1 ] && [ "$Q8_CUDZE" -eq 1 ] && [ "$Q8_LOKALNE" -eq 1 ] \
     && [ "$RC_Q8C" -eq 3 ] && [ "$Q8_RESZTKA" -eq 1 ] && [ "$RC_Q8D" -eq 0 ] \
     && [ "$RC_Q9" -eq 0 ] && [ "$Q9_MELDUNEK" -eq 1 ] && [ "$Q9_POLE" -eq 1 ] && [ "$Q9_TRESC" -eq 1 ] && [ "$Q9_BEZ_POLA" -eq 1 ] \
     && [ "$RC_Q10A" -eq 3 ] && [ "$Q10_BUFOR" -eq 1 ] && [ "$RC_Q10B" -eq 0 ] && [ "$Q10_PUSH" -eq 1 ] && [ "$Q10_TRESC" -eq 1 ] && [ "$RC_Q10C" -eq 0 ] && [ "$Q10_PLIK" -eq 1 ] \
     && [ "$Q11_TOK_PRZED" -eq 1 ] && [ "$RC_Q11" -eq 1 ] && [ "$Q11_TOK" -eq 1 ] && [ "$Q11_KOMUNIKAT" -eq 1 ] && [ "$Q11_SLADY" -eq 1 ] \
     && [ "$RC_Q12A" -eq 3 ] && [ "$Q12_KOPIA" -eq 1 ] && [ "$Q12_W_GIT" -eq 1 ] && [ "$RC_Q12B" -eq 0 ] && [ "$Q12_PUSH" -eq 1 ] && [ "$Q12_ATTR" -eq 1 ] && [ "$Q12_STAN" -eq 1 ] \
     && [ "$RC_W" -eq 6 ] && [ "$ZRODLO" -eq 1 ] && [ "$PIERWSZE" -eq 1 ] \
     && [ "$RC_FP" -eq 0 ] && [ "$PCHNIETO_F" -eq 1 ] && [ "$DLUG_MELD" -eq 1 ] \
     && [ "$RC_FM" -eq 7 ] && [ "$ORIGIN_NIETKNIETY" -eq 1 ] && [ "$RC_FNIC" -eq 7 ] \
     && [ "$RC_NM" -eq 7 ] && [ "$N_NIETKNIETY" -eq 1 ] && [ "$N_NAZWA" -eq 1 ] && [ "$RC_NP" -eq 0 ] && [ "$RC_NS" -eq 0 ] && [ "$NW_ZAPIS" -eq 1 ] \
     && [ "$WZORZEC_URL" -eq 0 ] && [ "$HELPER_OK" -eq 1 ] \
     && [ "$TRAILER_WL" -eq 1 ] && [ "$TRAILER_WYL" -eq 1 ] \
     && [ "$RC_K1" -eq 8 ] && [ "$K1_NIETKNIETY" -eq 1 ] && [ "$RC_K2" -eq 0 ] && [ "$RC_K3" -eq 0 ] \
     && [ "$RC_K4" -eq 8 ] && [ "$RC_K5" -eq 0 ] && [ "$RC_K6" -eq 0 ] \
     && [ "$RC_K7" -eq 0 ] && [ "$RC_K8" -eq 0 ] && [ "$RC_K9" -eq 8 ] \
     && [ "$RC_K10A" -eq 0 ] && [ "$RC_K10" -eq 0 ] && [ "$RC_K11" -eq 8 ] \
     && [ "$RC_BR0" -eq 0 ] && [ "$RC_BR1" = "8888" ] && [ "$BR1_NIETKNIETY" -eq 1 ] && [ "$RC_BR2" -eq 0 ] && [ "$BR2_PUSH" -eq 1 ] \
     && [ "$RC_BR3" -eq 0 ] && [ "$RC_BR4" -eq 8 ] && [ "$RC_BR5" -eq 0 ] \
     && [ "$RC_R1" -eq 0 ] && [ "$R1_OBIE" -eq 1 ] && [ "$R1_PUSH" -eq 1 ] && [ "$R1_ATTR" -eq 1 ] \
     && [ "$RC_R2" -eq 0 ] && [ "$R2_HASHE" -eq 1 ] && [ "$R2_PUSH" -eq 1 ] \
     && [ "$RC_R3" -eq 0 ] && [ "$R3_HASHE" -eq 1 ] && [ "$R3_B4" -eq 1 ] && [ "$R3_OBIE" -eq 1 ] \
     && [ "$RC_R4" -eq 3 ] && [ "$R4_ORIGIN" -eq 1 ] && [ "$R4_HEAD" -eq 1 ] \
     && [ "$RC_R5" -eq 3 ] && [ "$R5_HEAD" -eq 1 ] && [ "$R5_ATTR" -eq 1 ] \
     && [ "$RC_R6" -eq 7 ] && [ "$R6_HEAD" -eq 1 ] && [ "$R6_ORIGIN" -eq 1 ] \
     && [ "$RC_R7" -eq 3 ] && [ "$R7_HEAD" -eq 1 ] \
     && [ "$RC_R10" -eq 3 ] && [ "$R10_HEAD" -eq 1 ] && [ "$R10_KROTNOSC" -eq 1 ] \
     && [ "$RC_R9" -eq 3 ] && [ "$R9_HEAD" -eq 1 ] && [ "$R9_ORIGIN" -eq 1 ] \
     && [ "$RC_R8" -eq 0 ] && [ "$R8_HASHE" -eq 1 ] && [ "$R8_PUSH" -eq 1 ] \
     && [ "$RC_R11" -eq 0 ] && [ "$R11_PUSH" -eq 1 ] && [ "$R11_ODDANE" -eq 1 ] \
     && [ "$RC_R12" -eq 3 ] && [ "$R12_ORIGIN" -eq 1 ] \
     && [ "$RC_W1" -eq 0 ] && [ "$W1_PUSH" -eq 1 ] && [ "$W1_BAT" -eq 1 ] && [ "$W1_OBIE" -eq 1 ] \
     && [ "$RC_W2" -eq 0 ] && [ "$W2_PUSH" -eq 1 ] && [ "$W2_BAT" -eq 2 ] \
     && [ "$RC_W5" -eq 0 ] && [ "$W5_PUSH" -eq 1 ] && [ "$W5_BAT" -eq 2 ] \
     && [ "$RC_W3" -eq 3 ] && [ "$W3_ORIGIN" -eq 1 ] \
     && [ "$RC_W4" -ne 0 ] && [ "$W4_BAT" -eq 3 ] && [ "$W4_ORIGIN" -eq 1 ] && [ "$W4_NIEPCHNIETE" -eq 1 ] \
     && [ "$RC_BW1" -eq 0 ] && [ "$BW1_POLA" -eq 1 ] && [ "$BW1_ODDECH" -eq 1 ] && [ "$BW1_CZYSTE" -eq 1 ] \
     && [ "$RC_BW2" -eq 0 ] && [ "$BW2_PLIK" -eq 1 ] && [ "$BW2_BUFOR" -eq 1 ] && [ "$RC_BW3" -eq 0 ] && [ "$BW3_REBASE" -eq 1 ] \
     && [ "$RC_BW4" -eq 3 ] && [ "$BW4_WINNY" -eq 1 ] && [ "$BW5_OBCY" -eq 1 ] \
     && [ "$RC_O1" -eq 0 ] && [ "$O1_BAT" -eq 0 ] && [ "$O1_PUSH" -eq 1 ] && [ "$O1_MELD" -eq 1 ] \
     && [ "$RC_O2" -eq 0 ] && [ "$O2_BAT" -eq 1 ] && [ "$O2_PUSH" -eq 1 ] && [ "$O2_MELD" -eq 1 ] \
     && [ "$RC_O3" -eq 0 ] && [ "$O3_BAT" -eq 1 ] && [ "$O3_PUSH" -eq 1 ] && [ "$O3_OBIE" -eq 1 ] \
     && [ "$RC_O4" -eq 0 ] && [ "$O4_BAT" -eq 0 ] && [ "$O4_PUSH" -eq 1 ] \
     && [ "$RC_M1" -eq 9 ] && [ "$M1_NIETKNIETE" -eq 1 ] && [ "$RC_M2" -eq 0 ] && [ "$M2_OSTRZEZENIE" -eq 1 ] \
     && [ "$RC_M3" -eq 0 ] && [ "$M3_CISZA" -eq 1 ]; then
    echo "✓ STRAŻ ŻYWA: pcha gdy trzeba, milczy gdy nie ma co, rebase'uje gdy ryzyka NIE MA,"
    echo "  staje na kolizji treści i na usunięciu — 15B broniony tam, gdzie naprawdę żyje."
    echo "  Bramka baterii mierzy REGRES: dług zastany przepuszcza głośno, pogorszenie ODMAWIA."
    exit 0
  fi
  echo "✗ STRAŻ MARTWA: U1 Q7=$RC_Q7A/$RC_Q7B/$Q7_PUSH/$Q7_HASHE/$Q7_OBIE Q8=$RC_Q8A/$Q8_RADA/$Q8_STAN_PRZED/$RC_Q8B/$Q8_CZYSTO/$Q8_CUDZE/$Q8_LOKALNE/$RC_Q8C/$Q8_RESZTKA/$RC_Q8D Q9=$RC_Q9/$Q9_MELDUNEK/$Q9_POLE/$Q9_TRESC/$Q9_BEZ_POLA · Q10=$RC_Q10A/$Q10_BUFOR/$RC_Q10B/$Q10_PUSH/$Q10_TRESC/$RC_Q10C/$Q10_PLIK · Q11=$Q11_TOK_PRZED/$RC_Q11/$Q11_TOK/$Q11_KOMUNIKAT/$Q11_SLADY · Q12=$RC_Q12A/$Q12_KOPIA/$Q12_W_GIT/$RC_Q12B/$Q12_PUSH/$Q12_ATTR/$Q12_STAN · wyscig W1=$RC_W1/$W1_PUSH/$W1_BAT/$W1_OBIE W2=$RC_W2/$W2_PUSH/$W2_BAT W5=$RC_W5/$W5_PUSH/$W5_BAT W3=$RC_W3/$W3_ORIGIN W4=$RC_W4/$W4_BAT/$W4_ORIGIN/$W4_NIEPCHNIETE · R8=$RC_R8/$R8_HASHE/$R8_PUSH R9=$RC_R9/$R9_HEAD/$R9_ORIGIN R10=$RC_R10/$R10_HEAD/$R10_KROTNOSC · styk R11=$RC_R11/$R11_PUSH/$R11_ODDANE R12=$RC_R12/$R12_ORIGIN · wiersz-biegu=$RC_BW1/$BW1_POLA/$BW1_ODDECH/$BW1_CZYSTE/$RC_BW2/$BW2_PLIK/$BW2_BUFOR/$RC_BW3/$BW3_REBASE/$RC_BW4/$BW4_WINNY/$BW5_OBCY · oddech O1=$RC_O1/$O1_BAT/$O1_PUSH/$O1_MELD O2=$RC_O2/$O2_BAT/$O2_PUSH/$O2_MELD O3=$RC_O3/$O3_BAT/$O3_PUSH/$O3_OBIE O4=$RC_O4/$O4_BAT/$O4_PUSH · komunikat M=$RC_M1/$M1_NIETKNIETE/$RC_M2/$M2_OSTRZEZENIE/$RC_M3/$M3_CISZA · rejestry R1=$RC_R1/$R1_OBIE/$R1_PUSH/$R1_ATTR R2=$RC_R2/$R2_HASHE/$R2_PUSH R3=$RC_R3/$R3_HASHE/$R3_B4/$R3_OBIE R4=$RC_R4/$R4_ORIGIN/$R4_HEAD R5=$RC_R5/$R5_HEAD/$R5_ATTR R6=$RC_R6/$R6_HEAD/$R6_ORIGIN R7=$RC_R7/$R7_HEAD · karteczka k=$RC_K1/$K1_NIETKNIETY/$RC_K2/$RC_K3/$RC_K4/$RC_K5/$RC_K6 · kartka=$RC_K7/$RC_K8/$RC_K9 · bramka-przyrzadow=$RC_BR0/$RC_BR1/$BR1_NIETKNIETY/$RC_BR2/$BR2_PUSH/$RC_BR3/$RC_BR4/$RC_BR5 · A=$RC_A B=$RC_B C=$RC_C scalone=$SCALONE D=$RC_D nasz=$NASZ_SPORNY brzmienie=$D_BRZMIENIE Q=$RC_Q1/$Q1_TYLKO/$Q1_STAN/$RC_Q6/$RC_Q5/$Q5_TOK/$RC_Q2/$Q2_PUSH/$Q2_HASHE/$Q2_CZYSTO/$Q2_TRESC/$RC_Q3/$Q3_BRAK_TOKU/$RC_Q4 E=$RC_E ocalony=$OCALONY widmo=$RC_W zrodlo=$ZRODLO pierwsze=$PIERWSZE bramka+=$RC_FP/$PCHNIETO_F/$DLUG_MELD bramka-=$RC_FM/$ORIGIN_NIETKNIETY bramka⊙=$RC_FNIC token_url=$WZORZEC_URL helper=$HELPER_OK trailer_wl=$TRAILER_WL trailer_wyl=$TRAILER_WYL"
  exit 1
fi

# ── BASELINE BATERII (02.09.2026) — ustalany WYLACZNIE tym poleceniem ──────────────
# Stoi tuz za torem, przed czymkolwiek, co dotyka historii: mierzy i zapisuje liczbe,
# nic nie commituje i nic nie pcha. Baseline ma pochodzic z CZYSTEGO HEAD — skrypt tego
# nie egzekwuje, bo nie jego to rozstrzygniecie, ale melduje stan drzewa, zeby reka,
# ktora zapisuje baseline nad brudnym drzewem, zobaczyla to w tej samej linii.
if [ "${1:-}" = "--baseline-baterii" ]; then
  _BAZA_PLIK="${ZG_BAZA_PLIK:-.baseline_baterii}"
  echo "▤ POMIAR BASELINE BATERII (pelny bieg tory_strazy):"
  _WY_BAT="$(${ZG_TORY_CMD:-bash tory_strazy.sh --cicho} 2>&1 || true)"
  _OBL="$(printf '%s\n' "$_WY_BAT" | sed -n 's/.*oblanych \([0-9][0-9]*\).*/\1/p' | tail -1)"
  if [ -z "$_OBL" ]; then
    echo "✗ NIE ZMIERZONO (brak linii 'oblanych N') — baseline NIETKNIETY."; exit 1
  fi
  _NAZWY="$(printf '%s\n' "$_WY_BAT" | sed -n 's/^ *✗ \([a-z_0-9]*\) —.*/\1/p' | sort -u | paste -sd, -)"
  _BRUD="czyste"; git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null || _BRUD="BRUDNE (zmiany poza HEAD)"
  {
    echo "# baseline baterii — liczba oblanych torow TEGO srodowiska."
    echo "# Zapisany JAWNIE: bash zapis_git.sh --baseline-baterii. Bramka nigdy go nie rusza."
    echo "# zmierzono: $(date -u +%Y-%m-%dT%H:%MZ) · HEAD: $(git rev-parse --short HEAD 2>/dev/null || echo brak) · drzewo: $_BRUD"
    echo "oblanych=$_OBL"
    echo "oblane=$_NAZWY"
  } > "$_BAZA_PLIK"
  echo "   ✓ baseline zapisany: oblanych=$_OBL (${_NAZWY:-brak nazw}) · drzewo przy pomiarze: $_BRUD"
  echo "     plik: $_BAZA_PLIK (gitignore — dana srodowiska, nie kanonu)"
  exit 0
fi

# --- WIERSZ POMIARU NA BIEG (S2, 04.10.2026, A6: M2 = rc=3 z winy pliku kartki; KOLEJKA_M #129) ---
# Jeden wiersz na kazdy bieg: data · rc · sekundy · rebase T/N · oddech szybki/wolny · plik winny przy rc=3.
# Bez tego M2 liczylo sie z pamieci okien. Mierzy bieg OD ZEWNATRZ (ponowne uruchomienie siebie), bo skrypt ma ~20 wyjsc
# i dwa trapy EXIT (rebase zdejmuje wlasny `trap - EXIT`) — trap w srodku gubilby wiersze na dokladnie tych sciezkach, ktore
# mierzymy (rc=3, rc=7). Dziecko melduje stan do pliku tymczasowego (_zg_stan), rodzic sklada wiersz z KODU WYJSCIA (#19).
# NOSNIK PER PISARZ (A1): wiersz idzie do bufora w .git (nietrackowany), a przy NASTEPNYM biegu tej samej sesji trafia do
# kanon/pomiary/ZAPIS_biegi/<SESJA>.txt — plik jednego pisarza (zero wspolnego pliku = zero rc=3 od samego pomiaru) i drzewo
# po biegu zostaje CZYSTE (wiersz do repo dopiero w kolejnym biegu; inaczej kazdy push zostawialby brudny plik → kolejny push…).
# Fikstury toru (ZG_TORY_CMD) nie licza biegow, chyba ze ZG_BIEGI=1 (wlasny tor S2); produkcja nie ustawia ZG_TORY_CMD.
# WLASCICIEL STANU (zmierzone 04.10 na pierwszym zywym biegu: wiersz mowil rebase=T bez zadnego rebase): bateria uruchamia
# `zapis_git.sh --test`, a jego fikstury DZIEDZICZA zmienne srodowiska — ich rebase pisal do pliku stanu biegu zewnetrznego.
# Pisze wiec tylko DZIECKO wrappera: jego PPID = pid rodzica, ktory ten plik zalozyl.
_zg_stan() { [ -n "${_ZG_STAN_PLIK:-}" ] && [ "$PPID" = "${_ZG_STAN_RODZIC:-x}" ] && printf '%s\n' "$1" >> "$_ZG_STAN_PLIK"; return 0; }
_ZG_BIEGI_WL="${ZG_BIEGI:-$([ -n "${ZG_TORY_CMD:-}" ] && echo 0 || echo 1)}"
if [ -z "${_ZG_W_BIEG:-}" ] && [ "$_ZG_BIEGI_WL" = 1 ] && _ZG_GD="$(git rev-parse --git-dir 2>/dev/null)"; then
  _ZG_BS="${ZG_SESJA:-${CLAUDE_CODE_REMOTE_SESSION_ID:-}}"; _ZG_BS="${_ZG_BS#cse_}"; _ZG_BS="${_ZG_BS#session_}"; _ZG_BS="${_ZG_BS:0:8}"
  [ -n "$_ZG_BS" ] || _ZG_BS="nieznana"
  _ZG_BUF="$_ZG_GD/zapis_biegi.$_ZG_BS.bufor"
  # U3-01 (09.10): bufor NIE przelewa sie w toku rebase — sledzony ZAPIS_biegi/<SESJA>.txt brudzilby drzewo, `rebase --continue` by odmowil, a _zg_rebase_stop przerwalby
  # rebase recznego trybu (zmierzone w ULTRAREVIEW_U3). Wiersze czekaja w .git do pierwszego biegu poza rebase. --wycofaj robi rebase --abort = twardy reset: tez nie dotykamy pliku.
  if [ -s "$_ZG_BUF" ] && [ "${1:-}" != "--wycofaj" ] && [ ! -d "$_ZG_GD/rebase-merge" ] && [ ! -d "$_ZG_GD/rebase-apply" ]; then   # wiersze poprzednich biegow tej sesji → plik sesji (wejdzie do commita TEGO biegu)
    _ZG_BP="${ZG_BIEGI_KATALOG:-kanon/pomiary/ZAPIS_biegi}/$_ZG_BS.txt"; mkdir -p "$(dirname "$_ZG_BP")"
    [ -f "$_ZG_BP" ] || printf '# biegi zapis_git.sh, sesja %s · pola: data · rc · sekundy · rebase · oddech · plik winny przy rc=3 · [· scalone=pliki — tylko gdy tryb reczny scalil plik bez konfliktu, 08.10] · append-only (S2, 04.10.2026)\n' "$_ZG_BS" > "$_ZG_BP"
    cat "$_ZG_BUF" >> "$_ZG_BP" && rm -f "$_ZG_BUF"
  fi
  export _ZG_W_BIEG=1 _ZG_STAN_PLIK _ZG_STAN_RODZIC; _ZG_STAN_PLIK="$(mktemp)"; _ZG_STAN_RODZIC="$$"; _ZG_T0="$(date +%s)"
  set +e; bash "$0" "$@"; _ZG_RC=$?; set -e
  _ZG_T1="$(date +%s)"
  _ZG_REB="$(sed -n 's/^rebase=//p' "$_ZG_STAN_PLIK" | tail -1)"; _ZG_ODD="$(sed -n 's/^oddech=//p' "$_ZG_STAN_PLIK" | tail -1)"
  _ZG_WIN="$(sed -n 's/^winny=//p' "$_ZG_STAN_PLIK" | tail -1)"; [ "$_ZG_RC" -eq 3 ] || _ZG_WIN=""
  _ZG_SCAL="$(sed -n 's/^scalone=//p' "$_ZG_STAN_PLIK" | tail -1)"
  _ZG_SCAL_POLE=""; [ -n "$_ZG_SCAL" ] && _ZG_SCAL_POLE=" · scalone=$_ZG_SCAL"   # pole TYLKO gdy tryb reczny cos scalil (U1-09) — wiersze zwykle zostaja 6-polowe
  printf '%s · rc=%s · %ss · rebase=%s · oddech=%s · winny=%s%s\n' "$(TZ="$_STREFA_ST" date '+%Y-%m-%dT%H:%M:%S%z')" "$_ZG_RC" "$((_ZG_T1-_ZG_T0))" "${_ZG_REB:-N}" "${_ZG_ODD:--}" "${_ZG_WIN:--}" "$_ZG_SCAL_POLE" >> "$_ZG_BUF"
  rm -f "$_ZG_STAN_PLIK"
  exit "$_ZG_RC"
fi

KONT=0; WYC=0; case "${1:-}" in --kontynuuj) KONT=1; shift ;; --wycofaj) WYC=1; shift ;; esac   # prawo 6a, Q2b: dokonczenie recznego rebase (patrz blok przed krokiem (1))
msg="${1:-zapis Orkiestratora $(date -u +%Y-%m-%dT%H:%MZ)}"
# R3 (03.10.2026, kandydat M do blizny #125 „bariera dziala, tresc ginie"): argument zaczynajacy sie
# od `-` to prawie na pewno FLAGA gita wpisana tam, gdzie ma byc komunikat (np. `-m "..."`).
# Dawniej szla jako komunikat commita i prawdziwa tresc ginela; ODMOWA PRZED ruchem na repo.
case "$msg" in
  -*) echo "🛑 ODMOWA (rc=9): komunikat zaczyna sie od '-' — to wyglada na flage gita, nie na komunikat."
      echo "   -> komunikat z pliku: git commit -F plik, potem zapis_git.sh BEZ argumentu."
      exit 9 ;;
esac
BR="$(git rev-parse --abbrev-ref HEAD)"

# --- STRAŻ BIEGU MUTACYJNEGO (#112, dopisana 23.09.2026) — fetch chroni przed drugą
# gałęzią, nie przed drugą ręką W TYM SAMYM drzewie. `git add -A` bez tej bramki
# wcommitowałby plik w trakcie biegu mutacyjnego jako kanon. Ten sam plik-zamek i ta sama
# semantyka co w mutacje.sh (PID żywy = ODMOWA, PID osierocony = tylko ostrzeżenie).
_ZG_ZAMEK="${ZAMEK_BIEGU_PLIK:-.mutacje_lock}"
if [ -f "$_ZG_ZAMEK" ]; then
  _ZG_PID="$(cut -d: -f1 "$_ZG_ZAMEK" 2>/dev/null)"
  _ZG_CZAS="$(cut -d: -f2- "$_ZG_ZAMEK" 2>/dev/null)"
  case "$_ZG_PID" in ''|*[!0-9]*) _ZG_PID="" ;; esac
  if [ -n "$_ZG_PID" ] && kill -0 "$_ZG_PID" 2>/dev/null; then
    echo "  ⛔ ODMOWA — bieg mutacyjny wciąż trwa (PID $_ZG_PID od ${_ZG_CZAS:-?})."
    echo "     git add -A wcommitowałby cudzą mutację jako kanon (#112 w wersji push)."
    echo "     Poczekaj na koniec biegu albo sprawdź $_ZG_ZAMEK ręcznie."
    exit 12
  else
    echo "  ⚠ zamek biegu osierocony (PID ${_ZG_PID:-?} od ${_ZG_CZAS:-?} już nie żyje) —"
    echo "    kontynuuję, ale drzewo mogło zostać w trakcie mutacji (SIGKILL nie sprząta)."
  fi
fi

# --- WSPOLNE dla rebase auto i trybu recznego (prawo 6a, Q2b): lista rejestrow + sterownik/atrybuty (tylko DEFINICJE, bez wywolan) ---
BIALA_REJESTROW="kanon/ksiegi/KTO_CO_BIERZE.md
kanon/pomiary/MODEL_deklarowany.txt
kanon/pomiary/KRZESLA_zlapane.txt
kanon/pomiary/ALARMY_szereg.txt
mutacje.txt
kanon/ksiegi/LOG_SESJI.md"
_ZG_DRIVER="$(cd "$(dirname "$0")" && pwd)/narzedzia/przyrzady/merge_hashe.sh"
_ZG_ATTR="$(git rev-parse --git-path info/attributes)"; case "$_ZG_ATTR" in /*) ;; *) _ZG_ATTR="$PWD/$_ZG_ATTR" ;; esac
_ZG_PRZELICZ="$(git rev-parse --git-path kronos_hashe_przelicz)"; case "$_ZG_PRZELICZ" in /*) ;; *) _ZG_PRZELICZ="$PWD/$_ZG_PRZELICZ" ;; esac
# U3-04 (09.10): kopia pierwotnych atrybutow lezy W .git sesji (jak plik stanu), nie w /tmp — sprzatanie /tmp albo restart miedzy procesami --kontynuuj nie moga jej zgubic.
_ZG_ATTR_PIERW="$(git rev-parse --git-path kronos_attr_pierwotne)"; case "$_ZG_ATTR_PIERW" in /*) ;; *) _ZG_ATTR_PIERW="$PWD/$_ZG_ATTR_PIERW" ;; esac
# Sterownik ZAWSZE z kopii poza drzewem roboczym: w trakcie rebase drzewo bywa stanem origin, ktory moze
# nie miec merge_hashe.sh (pierwszy push z tym plikiem — zmierzone 03.10: sterownik "znikal", konflikt).
_ZG_DRIVER_KOPIA="${_ZG_PRZELICZ}.sterownik.sh"
_ZG_ATTR_AKTYWNE=0; _ZG_ATTR_KOPIA=""
_zg_attr_wlacz() {
  mkdir -p "$(dirname "$_ZG_ATTR")"
  cp "$_ZG_DRIVER" "$_ZG_DRIVER_KOPIA" || { echo "[!] brak sterownika $_ZG_DRIVER — nie rebasuje."; exit 3; }
  if [ -f "$_ZG_ATTR" ]; then _ZG_ATTR_KOPIA="$_ZG_ATTR_PIERW"; cp "$_ZG_ATTR" "$_ZG_ATTR_KOPIA"; else _ZG_ATTR_KOPIA=""; fi
  _ZG_ATTR_AKTYWNE=1
  {
    if [ -n "$_ZG_ATTR_KOPIA" ]; then cat "$_ZG_ATTR_KOPIA"; fi
    while IFS= read -r _f; do [ -n "$_f" ] && echo "/$_f merge=${ZG_ATRYBUT_REJESTROW:-union}"; done <<< "$BIALA_REJESTROW"
    echo "/_HASHE.txt merge=kronos-hashe"
  } > "$_ZG_ATTR"
}
_zg_attr_przywroc() {
  [ "$_ZG_ATTR_AKTYWNE" = 1 ] || return 0
  rm -f "$_ZG_DRIVER_KOPIA"
  if [ -n "$_ZG_ATTR_KOPIA" ]; then
    if [ -f "$_ZG_ATTR_KOPIA" ]; then cp "$_ZG_ATTR_KOPIA" "$_ZG_ATTR"; rm -f "$_ZG_ATTR_KOPIA"
    else _zg_attr_zdejmij; echo "    ⓘ kopia pierwotnych atrybutow zniknela ($_ZG_ATTR_KOPIA) — zdjalem tylko NASZE wiersze z .git/info/attributes, cudze zostaly."; fi   # nigdy goly cp pod set -e (U3-04)
  else rm -f "$_ZG_ATTR"; fi
  _ZG_ATTR_AKTYWNE=0
}
# --- BEZPIECZNIKI WSPOLNE (U1-07, 08.10.2026): rebase auto i --kontynuuj ida przez TE SAME B1–B4 ---
# PRZYCZYNA (sonda 2 z ULTRAREVIEW_U1, 07.10): sciezka --kontynuuj przeliczala odciski tylko plikow rozwiazanych reka i nie wykonywala B1–B4, wiec rejestr
# z ksiegi odciskow dopisany przez OBIE rece (np. mutacje.txt, LOG_SESJI.md) wychodzil na origin z nieswiezym odciskiem w _HASHE.txt. Teraz jedna funkcja,
# dwa wywolania. Zmienne wejsciowe: REMOTE, STARY_LOCAL, BAZA, SCALONE_UNIA (policzone przez _zg_kolizje), BIALA_REJESTROW, _ZG_PRZELICZ.
_zg_cofnij() { git reset -q --hard "$STARY_LOCAL"; rm -f "$_ZG_PRZELICZ" "$_ZG_PRZELICZ.ref" "$(git rev-parse --git-path kronos_rebase_reczny)"; echo "    -> rebase COFNIETY (HEAD = $(echo "$STARY_LOCAL" | cut -c1-7)); nic nie pcham. Decyzja tworcy (NIE rob golego git rebase — bez sterownikow scalania; pokaz ten komunikat wlascicielowi tematu)."; }
_zg_dodane() { git diff -U0 "$BAZA" "$1" -- "$2" | awk '/^@@/{h=1;next} h && /^\+/{print substr($0,2)}'; }
_zg_kolizje() {   # $1 = lokalny koniec (LOCAL albo STARY_LOCAL); ustawia KOLIZJE, KOLIZJE_TWARDE, SCALONE_UNIA
  local _ich _nasze
  _ich="$(git diff --name-only "$BAZA" "$REMOTE")"; _nasze="$(git diff --name-only "$BAZA" "$1")"
  KOLIZJE="$(comm -12 <(echo "$_ich" | sort -u) <(echo "$_nasze" | sort -u) | grep -v '^$' || true)"
  KOLIZJE_TWARDE="$(printf '%s\n' "$KOLIZJE" | grep -vxF -f <(printf '%s\n' "$BIALA_REJESTROW" "_HASHE.txt") | grep -v '^$' || true)"
  SCALONE_UNIA="$(printf '%s\n' "$KOLIZJE" | grep -xF -f <(printf '%s\n' "$BIALA_REJESTROW") || true)"
}
_zg_bezpieczniki() {   # $1 = pliki rozwiazane recznie (do przeliczenia odciskow) · $2 = opis commita odciskow
  local _f _ref _l _cr _cw _PRZ=() _extra="${1:-}" _opis="${2:-odciski rejestrow po rebase auto (zapis_git.sh R2)}"
  for _f in $BIALA_REJESTROW _HASHE.txt; do   # B2 zero znacznikow konfliktu
    if [ -f "$_f" ] && grep -qE '^(<<<<<<< |>>>>>>> )' "$_f"; then
      _zg_stan "winny=$_f"; echo "[!] B2: znacznik konfliktu w $_f po rebase."; _zg_cofnij; exit 3
    fi
  done
  for _f in $SCALONE_UNIA; do   # B1 nic nie zginelo ANI sie nie skleilo (krotnosc: wynik >= kazda strona, #127)
    for _ref in "$REMOTE" "$STARY_LOCAL"; do
      git show "$_ref:$_f" > "$_ZG_PRZELICZ.ref" 2>/dev/null || : > "$_ZG_PRZELICZ.ref"
      while IFS= read -r _l; do
        [ -z "$_l" ] && continue
        _cr="$(grep -cxF -- "$_l" "$_ZG_PRZELICZ.ref" || true)"; _cw=0
        [ -f "$_f" ] && _cw="$(grep -cxF -- "$_l" "$_f" || true)"
        if [ "$_cw" -lt "$_cr" ]; then
          rm -f "$_ZG_PRZELICZ.ref"; _zg_stan "winny=$_f"
          echo "[!] B1: linia dodana przez jedna z rak ZGINELA albo sie SKLEILA w $_f (krotnosc $_cw < $_cr): $(printf '%s' "$_l" | cut -c1-100)"; _zg_cofnij; exit 3
        fi
      done < <(_zg_dodane "$_ref" "$_f" | sort -u)
    done
  done
  rm -f "$_ZG_PRZELICZ.ref"
  # B3 KTO_CO_BIERZE: kazdy wpis ma DOKLADNIE JEDNA linie STATUS (dwie = obie rece zmienily status;
  # zero = unia skleila ogon wpisu z cudzym, #127). Naglowek przed pierwszym wpisem nie liczy sie.
  if [ -f kanon/ksiegi/KTO_CO_BIERZE.md ] && ! awk '/^\*\*BIORĘ:\*\*/{if(n>0&&s!=1)b=1;n++;s=0;next} /^\*\*STATUS:\*\*/{s++} END{if(n>0&&s!=1)b=1; exit b}' kanon/ksiegi/KTO_CO_BIERZE.md; then
    _zg_stan "winny=kanon/ksiegi/KTO_CO_BIERZE.md"; echo "[!] B3: KTO_CO_BIERZE.md — wpis bez STATUS albo z dwiema liniami STATUS (unia sklejila ogon albo obie rece zmienily status)."; _zg_cofnij; exit 3
  fi
  # B4 odciski: przelicz rejestry scalone unia (+ pliki rozwiazane recznie, jesli sa w _HASHE), osobny commit, potem pelna zgodnosc
  for _f in $SCALONE_UNIA $_extra; do grep -q "  $_f\$" _HASHE.txt 2>/dev/null && _PRZ+=("$_f"); done
  if [ -s "$_ZG_PRZELICZ" ]; then
    while IFS= read -r _f; do grep -q "  $_f\$" _HASHE.txt 2>/dev/null && _PRZ+=("$_f"); done < <(sort -u "$_ZG_PRZELICZ")
  fi
  if [ "${#_PRZ[@]}" -gt 0 ] && [ -f hashuj.sh ]; then
    mapfile -t _PRZ < <(printf '%s\n' "${_PRZ[@]}" | sort -u)
    bash hashuj.sh "${_PRZ[@]}" >/dev/null 2>&1 || true
    if ! git diff --quiet -- _HASHE.txt; then
      git add _HASHE.txt
      printf '%s: %s\n' "$_opis" "${_PRZ[*]}" > "$_ZG_PRZELICZ.msg"
      git commit -q -F "$_ZG_PRZELICZ.msg"; rm -f "$_ZG_PRZELICZ.msg"
      echo "    B4: odciski przeliczone i zacommitowane osobno: ${_PRZ[*]}"
    fi
    for _f in "${_PRZ[@]}"; do
      if ! grep -qxF "$(bash hashuj.sh --odcisk "$_f")  $_f" _HASHE.txt; then
        _zg_stan "winny=$_f"; echo "[!] B4: odcisk $_f niezgodny z trescia po przeliczeniu."; _zg_cofnij; exit 3
      fi
    done
  elif [ "${#_PRZ[@]}" -gt 0 ]; then
    echo "    ⓘ B4: brak hashuj.sh w tym drzewie — odciskow nie przeliczam: ${_PRZ[*]}"
  fi
  rm -f "$_ZG_PRZELICZ"
  for _f in $SCALONE_UNIA; do   # meldunek glosny: co scalono unia
    echo "    UNIA: $_f — +$(_zg_dodane "$REMOTE" "$_f" | wc -l | tr -d ' ') linii ich, +$(_zg_dodane "$STARY_LOCAL" "$_f" | wc -l | tr -d ' ') naszych, wynik $(wc -l < "$_f" | tr -d ' ') linii"
  done
}
_zg_scalone_glosno() {   # U1-09 (B3): plik spoza listy zmieniony przez OBIE rece, a git scalil go bez konfliktu — meldunek z nazwa pliku + pole biegu
  local _p="$1"
  [ -n "$_p" ] || return 0
  echo "    SCALONE AUTOMATYCZNIE (ten sam plik u obu rak, rozne linie): $(printf '%s' "$_p" | tr '\n' ' ')"
  echo "      -> git scalil je bez konfliktu; sprawdz, czy dwie zgodne tekstowo zmiany nie sa sprzeczne znaczeniowo (bateria B5 i tak mierzy kod)."
  _zg_stan "scalone=$(printf '%s' "$_p" | paste -sd, -)"
}
# --wycofaj (U1-08): zdjecie sladow trybu recznego — rebase --abort, plik stanu, kopia sterownika, NASZE wiersze w .git/info/attributes
_zg_attr_zdejmij() {
  [ -f "$_ZG_ATTR" ] || return 0
  local _t; _t="$(mktemp)"
  { while IFS= read -r _f; do [ -n "$_f" ] && echo "/$_f merge=${ZG_ATRYBUT_REJESTROW:-union}"; done <<< "$BIALA_REJESTROW"; echo "/_HASHE.txt merge=kronos-hashe"; } > "$_t.nasze"
  grep -vxF -f "$_t.nasze" "$_ZG_ATTR" > "$_t" || true
  if [ -s "$_t" ]; then cp "$_t" "$_ZG_ATTR"; else rm -f "$_ZG_ATTR"; fi
  rm -f "$_t" "$_t.nasze"
}
# TRYB RECZNY (ZAPIS_REBASE_RECZNY=tak, prawo 6a, Q2b): rebase ZE sterownikami stanal na konflikcie tresci. Zostaje w toku TYLKO gdy
# nierozwiazane sa wylacznie pliki spoza listy rejestrow i _HASHE.txt (to je rozwiazuje czlowiek); inaczej cofniety. Stan do pliku
# w .git, sterowniki i atrybuty ZOSTAJA (nowy proces --kontynuuj ich potrzebuje), pierwotne atrybuty wracaja dopiero przy --kontynuuj.
_zg_rebase_stop() {
  local _U _TW _ST _PL
  _ST="$(git rev-parse --git-path kronos_rebase_reczny)"
  _U="$(git diff --name-only --diff-filter=U | grep -v '^$' || true)"
  _TW="$(printf '%s\n' "$_U" | grep -vxF -f <(printf '%s\n' "$BIALA_REJESTROW" "_HASHE.txt") | grep -v '^$' || true)"
  if [ -z "$_U" ] || [ "$_TW" != "$_U" ]; then
    git rebase --abort >/dev/null 2>&1 || true
    _zg_attr_przywroc; trap - EXIT; rm -f "$_ST"
    _zg_stan "winny=rebase-reczny"
    echo "[!] TRYB RECZNY: rebase ze sterownikami stanal na konflikcie w pliku z listy rejestrow/_HASHE albo bez pliku winnego (rozjazd miary i rzeczy) — COFNIETY, nic nie pcham."
    echo "    nierozwiazane: $(printf '%s' "$_U" | tr '\n' ' ')"; exit 3
  fi
  _PL="$( { [ -f "$_ST" ] && sed -n 's/^PLIKI=//p' "$_ST" | tr ',' '\n'; printf '%s\n' "$_U"; } | grep -v '^$' | sort -u | paste -sd, - )"
  { echo "STARY_LOCAL=$STARY_LOCAL"; echo "REMOTE=${REMOTE:-}"; echo "BAZA=${BAZA:-}"; echo "ATTR_PIERWOTNE=$_ZG_ATTR_KOPIA"; echo "PLIKI=$_PL"; } > "$_ST"
  _ZG_ATTR_AKTYWNE=0; trap - EXIT
  _zg_stan "winny=$(echo "$_U" | head -3 | paste -sd, -)"
  echo "[!] TRYB RECZNY: rebase ZE sterownikami rejestrow i _HASHE stanal TYLKO na plikach spoza listy:"
  printf '%s\n' "$_U" | sed 's/^/      /'
  echo "    -> rozwiaz te pliki (usun znaczniki konfliktu), potem: git add <pliki>  i  bash zapis_git.sh --kontynuuj"
  echo "       (rebase jest W TOKU, sterowniki zostaja wlaczone; NIE rob golego 'git rebase --continue' ani 'git commit'. Wycofanie: bash zapis_git.sh --wycofaj)"
  exit 3
}

# --- --kontynuuj (prawo 6a, Q2b): dokonczenie recznego rebase ZE sterownikami, potem zwykle bramki i push ---
_ZG_RBST="$(git rev-parse --git-path kronos_rebase_reczny)"
_ZG_RB_TOK=0; { [ -d "$(git rev-parse --git-path rebase-merge)" ] || [ -d "$(git rev-parse --git-path rebase-apply)" ]; } && _ZG_RB_TOK=1
if [ "$WYC" = 1 ]; then
  # --wycofaj (U1-08, 08.10.2026): jedno polecenie zdejmuje WSZYSTKIE slady trybu recznego. Dawna rada „git rebase --abort” zostawiala plik stanu,
  # kopie sterownika i merge=union w .git/info/attributes — kazde pozniejsze scalanie poza skryptem laczylo rejestry unia bez bezpiecznikow.
  # U3-03 (09.10): rebase w toku BEZ naszego pliku stanu to czyjas inna robota (reka, inny skrypt) — nie jest naszym do przerwania (`--abort` to twardy reset cudzych zmian). Zdejmujemy tylko NASZE slady, rebase zostaje.
  if [ "$_ZG_RB_TOK" = 1 ] && [ ! -f "$_ZG_RBST" ]; then
    rm -f "$_ZG_ATTR_PIERW" "$_ZG_DRIVER_KOPIA" "$_ZG_PRZELICZ" "$_ZG_PRZELICZ.ref" "$_ZG_PRZELICZ.msg"; _zg_attr_zdejmij
    echo "✗ --wycofaj: rebase w toku nie pochodzi z trybu recznego tego skryptu (brak $_ZG_RBST) — nie ruszam (nasze slady w attributes i kopie zdjete)."; exit 1
  elif [ "$_ZG_RB_TOK" = 1 ]; then
    git rebase --abort >/dev/null 2>&1 || { echo "[!] --wycofaj: git rebase --abort nie przeszedl — sprawdz stan recznie (git status); sladow skryptu nie ruszam."; exit 3; }
    echo "[~] --wycofaj: rebase w toku przerwany (git rebase --abort)."
  elif [ ! -f "$_ZG_RBST" ]; then
    echo "[~] --wycofaj: nic do wycofania (brak rebase w toku i brak pliku stanu)."
  fi
  _ZG_ATTR_KOPIA="$(sed -n 's/^ATTR_PIERWOTNE=//p' "$_ZG_RBST" 2>/dev/null | tail -1)"
  _zg_attr_zdejmij
  [ -n "$_ZG_ATTR_KOPIA" ] && rm -f "$_ZG_ATTR_KOPIA"
  rm -f "$_ZG_ATTR_PIERW" "$_ZG_RBST" "$_ZG_DRIVER_KOPIA" "$_ZG_PRZELICZ" "$_ZG_PRZELICZ.ref" "$_ZG_PRZELICZ.msg"
  echo "[~] --wycofaj: zdjete plik stanu, kopia sterownika i wiersze merge=… z .git/info/attributes."
  exit 0
elif [ "$KONT" = 1 ]; then
  if [ "$_ZG_RB_TOK" != 1 ]; then echo "✗ --kontynuuj: brak rebase w toku — nie ma czego kontynuowac."; exit 1; fi
  if [ ! -f "$_ZG_RBST" ]; then echo "✗ --kontynuuj: rebase w toku nie pochodzi z trybu recznego tego skryptu (brak $_ZG_RBST) — nie ruszam."; exit 1; fi
  _KU="$(git diff --name-only --diff-filter=U | grep -v '^$' || true)"
  if [ -n "$_KU" ]; then
    echo "[!] --kontynuuj: nadal NIEROZWIAZANE (po rozwiazaniu: git add <plik>): $(printf '%s' "$_KU" | tr '\n' ' ')"; exit 3
  fi
  _KPL="$(sed -n 's/^PLIKI=//p' "$_ZG_RBST" | tail -1 | tr ',' ' ')"
  for _f in $_KPL; do
    if [ -f "$_f" ] && grep -qE '^(<<<<<<< |>>>>>>> )' "$_f"; then echo "[!] --kontynuuj: znacznik konfliktu zostal w $_f — rozwiaz, git add, ponow."; exit 3; fi
  done
  STARY_LOCAL="$(sed -n 's/^STARY_LOCAL=//p' "$_ZG_RBST" | tail -1)"
  REMOTE="$(sed -n 's/^REMOTE=//p' "$_ZG_RBST" | tail -1)"; BAZA="$(sed -n 's/^BAZA=//p' "$_ZG_RBST" | tail -1)"   # U1-07: do wyliczenia SCALONE_UNIA i B1
  _ZG_ATTR_KOPIA="$(sed -n 's/^ATTR_PIERWOTNE=//p' "$_ZG_RBST" | tail -1)"; _ZG_ATTR_AKTYWNE=1
  trap '_zg_attr_przywroc' EXIT
  [ -f "$_ZG_DRIVER_KOPIA" ] || cp "$_ZG_DRIVER" "$_ZG_DRIVER_KOPIA" || { echo "[!] brak sterownika $_ZG_DRIVER — nie kontynuuje."; exit 3; }
  if ! grep -qxF '/_HASHE.txt merge=kronos-hashe' "$_ZG_ATTR" 2>/dev/null; then   # atrybuty mogly zniknac miedzy procesami — odtworz
    { while IFS= read -r _f; do [ -n "$_f" ] && echo "/$_f merge=${ZG_ATRYBUT_REJESTROW:-union}"; done <<< "$BIALA_REJESTROW"; echo "/_HASHE.txt merge=kronos-hashe"; } >> "$_ZG_ATTR"
  fi
  export KRONOS_HASHE_BIALA="$BIALA_REJESTROW" KRONOS_HASHE_PRZELICZ="$_ZG_PRZELICZ"
  _ZG_MERGE=(-c "merge.kronos-hashe.driver=bash \"${_ZG_DRIVER_KOPIA}\" %O %A %B")
  set +e; GIT_EDITOR=true git "${_ZG_MERGE[@]}" rebase --continue >/dev/null 2>&1; RC_RB=$?; set -e
  if [ "$RC_RB" -ne 0 ]; then _zg_rebase_stop; fi   # kolejny commit tez skonfliktowal: ten sam STOP, stan uzupelniony
  _zg_stan "rebase=T"
  # U1-07: te same bezpieczniki B1–B4 co w rebase auto (rejestry scalone unia przez obie rece dostaja swiezy odcisk), plus pliki rozwiazane recznie
  if [ -n "$REMOTE" ] && [ -n "$BAZA" ] && [ -n "$STARY_LOCAL" ]; then
    _zg_kolizje "$STARY_LOCAL"
    _zg_bezpieczniki "$_KPL" "odciski po recznym rozwiazaniu konfliktu (zapis_git.sh --kontynuuj)"
    _SC=""; for _f in $KOLIZJE_TWARDE; do case " $_KPL " in *" $_f "*) ;; *) _SC="$_SC$_f"$'\n' ;; esac; done   # rozwiazane recznie to nie „scalone automatycznie”
    _zg_scalone_glosno "$(printf '%s' "$_SC" | grep -v '^$' || true)"
  else
    echo "    ⓘ --kontynuuj: plik stanu bez REMOTE/BAZA (stan sprzed 08.10) — B1–B4 pominiete; odciski przelicze tylko dla plikow rozwiazanych recznie."
    _KPRZ=(); for _f in $_KPL; do grep -q "  $_f\$" _HASHE.txt 2>/dev/null && _KPRZ+=("$_f"); done
    if [ "${#_KPRZ[@]}" -gt 0 ] && [ -f hashuj.sh ]; then bash hashuj.sh "${_KPRZ[@]}" >/dev/null 2>&1 || true; git diff --quiet -- _HASHE.txt || { git add _HASHE.txt; git commit -q -m "odciski po recznym rozwiazaniu konfliktu (zapis_git.sh --kontynuuj)"; }; fi
  fi
  _zg_attr_przywroc; trap - EXIT; rm -f "$_ZG_RBST"
  BR="$(git rev-parse --abbrev-ref HEAD)"   # BR liczone wyzej przy odlaczonym HEAD (w toku rebase) = "HEAD"; po dokonczeniu wraca galaz
  echo "[~] --kontynuuj: rebase ZE sterownikami dokonczony, sterowniki zdjete. Dalej zwykle bramki i push."
elif [ "$_ZG_RB_TOK" = 1 ] && [ -f "$_ZG_RBST" ]; then
  echo "🛑 rebase RECZNY jest W TOKU (stan: $_ZG_RBST). Zwykly zapis NIE biegnie (git add -A wcommitowalby polowe rebase)."
  echo "   -> rozwiaz pliki, git add, potem: bash zapis_git.sh --kontynuuj   (wycofanie: bash zapis_git.sh --wycofaj)"; exit 3
elif [ -f "$_ZG_RBST" ]; then
  echo "🛑 pozostałość trybu ręcznego — bash zapis_git.sh --wycofaj (plik stanu bez rebase w toku: $_ZG_RBST; kopia sterownika i merge=… w .git/info/attributes mogą jeszcze być)."
  echo "   -> to zdejmuje je jednym poleceniem; potem zwykły zapis."; exit 3
fi

# --- (1) commit opcjonalny ---
# (a) dla tkanki: odnow odciski rejestrow, ktore z natury rosna (rdzen NIE — recznie)
bash hashuj.sh > /dev/null 2>&1 || true
git add -A
if git diff --cached --quiet; then
  echo "   (brak zmian w stage — nic do zacommitowania; sprawdzam, czy jest co pchnac)"
else
# R3: bez argumentu skrypt SAM tworzy commit z komunikatem domyslnym — jedno ostrzezenie, zeby
# nikt nie wzial tego za swoj wlasny, opisany commit (#125).
if [ -z "${1:-}" ]; then
  echo "   ⚠ ostrzezenie: tworze commit z niepustego stage'u z komunikatem DOMYSLNYM ($msg). Wlasny opis: git commit -F plik PRZED zapis_git.sh."
fi
# --- STRAŻ DATY (#48, 13.08.2026): data z kontekstu ≠ data chwili zapisu ---
# W sesji trwającej dobami znacznik z jej początku cichnie i starzeje się. Skanujemy
# komunikat pod kątem DD.MM i porównujemy z dniem ZMIERZONYM TERAZ. Ostrzegamy, nie
# blokujemy — komunikaty legalnie cytują daty historyczne.
_dzis="$(date +%d.%m)"
_daty="$(printf '%s' "$msg" | grep -oE '\b[0-3][0-9]\.[01][0-9]\b' | sort -u)"
if [ -n "$_daty" ] && ! printf '%s\n' "$_daty" | grep -qx "$_dzis"; then
  echo "[!] STRAŻ DATY (#48): w komunikacie są daty [$(printf '%s' "$_daty" | tr '\n' ' ')]," \
       "a dziś jest $_dzis ($(TZ="$_STREFA_ST" date '+%A, %H:%M %Z'))."
  echo "    Jeśli któraś miała znaczyć „dziś\" — przerwij i popraw. Pomiar ma termin ważności."
fi

# --- WSPÓŁAUTOR (18.09.2026, słowo twórcy): Orkiestrator jest autorem — uczciwie,
# per SUBSTRAT.md (oznaczaj głos) — ale wkład twórcy ma się liczyć na jego koncie.
# `Co-authored-by` dopisywany TYLKO gdy zmienna jest ustawiona: domyślnie nic się nie
# zmienia, dopóki ktoś świadomie nie zdecyduje, że ma być zawsze. Poza $msg (nie w nim),
# żeby STRAŻ DATY wyżej skanowała tylko treść zamierzoną przez wołającego.
if [ -n "${KRONOS_COAUTHOR:-}" ]; then
  git commit -m "$msg

Co-authored-by: ${KRONOS_COAUTHOR}"
else
  git commit -m "$msg"
fi
fi

# --- (2) fetch przed pushem: czy druga reka cos dolozyla? ---
# URL: repo jest PRYWATNE, a prawo kaze trzymac origin BEZ tokena.
# Token bierzemy z env KRONOS_PAT — teraz WYŁĄCZNIE przez credential helper (patrz niżej).
URL="origin"; GITC=()
if [ -n "${KRONOS_PAT:-}" ]; then
  # NAPRAWA (18.09.2026, słowo twórcy): token NIGDY jako podłańcuch $URL — nawet inline,
  # nawet redagowany na wyjściu. Redakcja czyści to, co widzi UŻYTKOWNIK; argument procesu
  # (widoczny np. w `ps aux` w oknie, gdzie token żyje) już upłynął. Prawo wstania:
  # „poświadczenie WYŁĄCZNIE przez otoczenie, nigdy w URL" — ten skrypt był jedynym
  # miejscem, które je łamało. URL jest teraz ZAWSZE nazwą remote'a (git zna jego adres
  # z .git/config); autoryzacja idzie przez credential helper SCOPOWANY do jednego
  # wywołania (`GITC`), nigdy do configu globalnego czy repo.
  ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
  if [ -n "$ORIGIN_URL" ] && [ "${ORIGIN_URL#https://}" != "$ORIGIN_URL" ]; then
    GITC=(-c credential.helper='!f(){ echo username=x-access-token; echo "password=$KRONOS_PAT"; }; f')
  else
    echo "[i] origin nie jest https (lub go brak) — probuje przez origin."
  fi
else
  echo "[i] brak KRONOS_PAT w env — probuje przez origin (zadziala tylko, gdy origin ma auth)."
fi
set +e; git "${GITC[@]}" fetch "$URL" "$BR" > /dev/null 2>&1; RCF=$?; set -e
if [ "$RCF" -ne 0 ]; then
  # ROZRÓŻNIENIE (31.07.2026): „fetch padł" ma dwie zupełnie różne przyczyny, a jeden
  # komunikat na obie wysyła po token, gdy problem jest gdzie indziej. Mierz, nie zgaduj.
  set +e; git "${GITC[@]}" ls-remote "$URL" > /dev/null 2>&1; RCL=$?; set -e
  if [ "$RCL" -eq 0 ]; then
    echo "[!] origin odpowiada, ale NIE MA na nim galezi '$BR' (ZNANA LUKA: ten skrypt nie"
    echo "    zaklada galezi zdalnej). Pierwszy push zrob recznie:  git push -u origin $BR"
    exit 6
  fi
  echo "[!] fetch nie poszedl (rc=$RCF) — AUTH albo brak sieci."
  # BLIZNA #65 (21.08.2026): instancja straciła trzy tury, bo cztery razy sprawdziła
  # WAŻNOŚĆ tokenu i ani razu jego ŹRÓDŁO — pchała stringiem z pamięci sesji sprzed
  # kompaktowania, podczas gdy instrukcje projektu niosły token żywy. Dawny komunikat
  # („podaj token") był prawdą bezużyteczną: token właśnie podano, tylko nie ten.
  # Dlatego pierwsza podpowiedź pyta o ŹRÓDŁO, a dopiero druga o sam string.
  echo "    -> NAJPIERW ŹRÓDŁO: token bierze się z OSTATNIEJ SEKCJI INSTRUKCJI PROJEKTU."
  echo "       Po kompaktowaniu kontekstu string mógł zostać podmieniony, a podmiana"
  echo "       NIE zostawia śladu w tym, co pamiętasz. Nie sprawdzaj czwarty raz, czy"
  echo "       ten token żyje — sprawdź, czy to TEN token (#65)."
  echo "    -> potem: KRONOS_PAT=... bash zapis_git.sh ...   Nic nie pcham."; exit "$RCF"
fi
LOCAL="$(git rev-parse HEAD)"
REMOTE="$(git rev-parse FETCH_HEAD 2>/dev/null || echo brak)"

if [ "$LOCAL" = "$REMOTE" ]; then
  echo "OK: origin/$BR juz rowny lokalnemu ($(echo "$LOCAL" | cut -c1-7)) — nic do pchniecia."; exit 0
fi
# --- BRAMKA KARTECZKI (03.10.2026, slowo tworcy 13:09/13:19: „to nie czas a sesja powinna byc indykatorem") ---
# Push bez karteczki wlasnej SESJI = ODMOWA rc=8. Przyczyna zmierzona 03.10: karteczka zalezala od
# pamieci instancji (ostatnia uzyta 01.10, sesja 29.09→03.10 nie powiesila zadnej), wiec drugie okno
# nie widzialo, kto czym sie zajmuje. Przepuszcza: (a) wlasna OTWARTA karteczka w HEAD, (b) push niesie
# ZMIANE rejestru (wieszanie albo domkniecie — inaczej nie dalo by sie wypchnac samej karteczki),
# (c) jawna furtka ZAPIS_BEZ_KARTECZKI="powod" (powod trafia na ekran). Sesja nieznana (Windows, czat
# bez zmiennej) = ⓘ, nie odmowa — bramka nie moze zamknac drogi rece, ktora nie ma jak sie nazwac;
# tam pilnuje straz_feromonow (--inne przy wstaniu). ZG_SESJA / ZG_REJESTR: uchwyty fikstur toru.
_ZG_REJ="${ZG_REJESTR:-kanon/ksiegi/KTO_CO_BIERZE.md}"
_ZG_SES="${ZG_SESJA:-${CLAUDE_CODE_REMOTE_SESSION_ID:-}}"; _ZG_SES="${_ZG_SES#cse_}"; _ZG_SES="${_ZG_SES#session_}"; _ZG_SES="${_ZG_SES:0:8}"
if [ -n "${ZAPIS_BEZ_KARTECZKI:-}" ]; then
  echo "   ⓘ BRAMKA KARTECZKI: furtka jawna — powod: $ZAPIS_BEZ_KARTECZKI"
elif [ -z "$_ZG_SES" ]; then
  echo "   ⓘ BRAMKA KARTECZKI: sesja nieznana (brak CLAUDE_CODE_REMOTE_SESSION_ID) — nie sprawdzam."
else
  # v2 (03.10, TABLICA_kartki R-T6): wlasna kartka = kanon/ksiegi/kartki/<SESJA>.md (jeden plik, jeden pisarz).
  # PRZEJSCIE do 10.10: liczy sie tez wpis w archiwum $_ZG_REJ (stare okno ze starym skryptem).
  _ZG_KDIR="${ZG_KARTKI:-kanon/ksiegi/kartki}"
  _ZG_AWK='
    /^\*\*BIORĘ:\*\*/ { ses="" }
    /^\*\*SESJA:\*\*/ { ses=substr($0, index($0,":**")+4) }
    /^\*\*STATUS:\*\* OTWARTE( · .*)?$/ && ses==ja { n++ }
    END { print n+0 }'
  _ZG_MA1="$(git show "HEAD:$_ZG_KDIR/$_ZG_SES.md" 2>/dev/null | awk -v ja="$_ZG_SES" "$_ZG_AWK")"
  _ZG_MA2="$(git show "HEAD:$_ZG_REJ" 2>/dev/null | awk -v ja="$_ZG_SES" "$_ZG_AWK")"
  _ZG_MA=$(( ${_ZG_MA1:-0} + ${_ZG_MA2:-0} ))
  _ZG_NIESIE=1; git diff --quiet FETCH_HEAD HEAD -- "$_ZG_REJ" "$_ZG_KDIR" 2>/dev/null && _ZG_NIESIE=0
  # R5 (05.10.2026, seria R): PETLA PO ODDANIU. Zmierzone w fikturze: po `--oddaje` + push kartka jest ODDANE, a kazdy
  # nastepny bieg wpisuje do repo wiersz POPRZEDNIEGO biegu (kanon/pomiary/ZAPIS_biegi/<SESJA>.txt, S2). Taki push nie
  # niesie kartek (NIESIE=0) ani otwartej kartki (MA=0) → rc=8, a odmowa sama zostawia kolejny wiersz i commit lokalny
  # (ahead 1 → 2 → …). Naprawa najmniejsza: push, ktory niesie WYLACZNIE kartki i wiersze biegow, tez przechodzi.
  # „Wylacznie” liczone po tym, co niosa NASZE commity (merge-base), nie po cudzych zmianach z origin; pusty ruch nie przechodzi.
  _ZG_BDIR="${ZG_BIEGI_KATALOG:-kanon/pomiary/ZAPIS_biegi}"; _ZG_NOSI=0; _ZG_POZA_KB=0
  while IFS= read -r _zf; do
    [ -n "$_zf" ] || continue; _ZG_NOSI=1
    case "$_zf" in "$_ZG_KDIR"/*|"$_ZG_BDIR"/*) ;; *) _ZG_POZA_KB=1 ;; esac
  done < <(git diff --name-only "$(git merge-base FETCH_HEAD HEAD 2>/dev/null || echo FETCH_HEAD)" HEAD 2>/dev/null)
  if [ "${_ZG_MA:-0}" -ge 1 ]; then echo "   ✓ BRAMKA KARTECZKI: sesja $_ZG_SES ma otwarta karteczke."
  elif [ "$_ZG_NIESIE" -eq 1 ]; then echo "   ✓ BRAMKA KARTECZKI: push niesie zmiane rejestru karteczek (wieszanie/domkniecie)."
  elif [ "$_ZG_NOSI" -eq 1 ] && [ "$_ZG_POZA_KB" -eq 0 ]; then echo "   ✓ BRAMKA KARTECZKI: push niesie wylacznie kartki i wiersze biegow (po oddaniu karty; R5)."
  else
    echo "✗ BRAMKA KARTECZKI: sesja $_ZG_SES nie ma otwartej karteczki — push odmowiony (rc=8)."
    echo "  -> bash narzedzia/straze/straz_feromonow.sh --biore \"ROLA\" \"temat\"   (potem commit + ten skrypt)"
    echo "  -> furtka jawna z powodem: ZAPIS_BEZ_KARTECZKI=\"powod\" bash zapis_git.sh ...   Nic nie pcham."
    exit 8
  fi
fi
# --- BRAMKA PRZYRZADOW (04.10.2026, A3 punktu stabilnego, slowo tworcy 14:54 „Tak.") ---
# PRZYCZYNA (zmierzona 02–04.10, PLAN_0410_punkt_stabilny §2): ten skrypt, straz_feromonow.sh i tory_strazy.sh
# zmienialy 3–5 okien naraz (zapis_git.sh: 4 sesje / 13 commitow), dwa okna dopisaly wlasne „R10" w to samo miejsce.
# Naprawy bramki szly przez bramke bez jednego wlasciciela. Wlascicielem jest KARTKA o temacie zaczynajacym sie
# od BRAMKA (nie osoba): kto tnie sciezke chroniona, musi ja miec otwarta w HEAD. Inne okna pisza paczke do
# kanon/plany/linienie/ i melduja. Przejecie zostaje jawne (--przejmuje). Liczy sie TYLKO to, co niosa nasze
# lokalne commity wzgledem origin (merge-base), nie cudze zmiany, ktore rebase dopiero wciagnie.
# Sesja nieznana (PRACOWNIA/Windows bez zmiennej) = ⓘ jak w bramce karteczki — tam pilnuje tworca przy biurku.
# Furtka jawna OSOBNA od karteczkowej: ZAPIS_BEZ_BRAMKI="powod" (ZAPIS_BEZ_KARTECZKI NIE otwiera sciezek chronionych).
_ZG_CHRON_RE='^(zapis_git\.sh$|narzedzia/straze/straz_feromonow\.sh$|tory_strazy\.sh$|\.githooks/)'
_ZG_BR_BAZA="$(git merge-base FETCH_HEAD HEAD 2>/dev/null || echo FETCH_HEAD)"
_ZG_BR_RUCH="$(git diff --name-only "$_ZG_BR_BAZA" HEAD 2>/dev/null | grep -E "$_ZG_CHRON_RE" || true)"
_ZG_BR_AWK='
  /^\*\*BIORĘ:\*\*/ { tm=substr($0, index($0,":**")+4); ses="" }
  /^\*\*SESJA:\*\*/ { ses=substr($0, index($0,":**")+4) }
  /^\*\*STATUS:\*\* OTWARTE( · .*)?$/ && ses==ja && tm ~ /^BRAMKA/ { nb++ }
  END { print nb+0 }'
if [ -z "$_ZG_BR_RUCH" ]; then :
elif [ -n "${ZAPIS_BEZ_BRAMKI:-}" ]; then
  echo "   ⓘ BRAMKA PRZYRZADOW: furtka jawna — powod: $ZAPIS_BEZ_BRAMKI"
elif [ -z "$_ZG_SES" ]; then
  echo "   ⓘ BRAMKA PRZYRZADOW: sesja nieznana — nie sprawdzam (ruch dotyka: $(printf '%s' "$_ZG_BR_RUCH" | paste -sd, -))."
elif [ "$(git show "HEAD:${ZG_KARTKI:-kanon/ksiegi/kartki}/$_ZG_SES.md" 2>/dev/null | awk -v ja="$_ZG_SES" "$_ZG_BR_AWK")" -ge 1 ]; then
  echo "   ✓ BRAMKA PRZYRZADOW: sesja $_ZG_SES trzyma kartke BRAMKA (ruch: $(printf '%s' "$_ZG_BR_RUCH" | paste -sd, -))."
else
  echo "✗ BRAMKA PRZYRZADOW: push dotyka sciezek chronionych ($(printf '%s' "$_ZG_BR_RUCH" | paste -sd, -)), a sesja $_ZG_SES nie trzyma kartki o temacie BRAMKA — push odmowiony (rc=8)."
  echo "  -> weź kartke:  bash narzedzia/straze/straz_feromonow.sh --biore \"ROLA\" \"BRAMKA: <co tniesz>\" [--przejmuje SESJA \"temat\"]   (commit + ten skrypt)"
  echo "  -> albo zostaw paczke w kanon/plany/linienie/ i zamelduj wlascicielowi BRAMKI (A3). Furtka jawna: ZAPIS_BEZ_BRAMKI=\"powod\". Nic nie pcham."
  exit 8   # BRAMKA PRZYRZADOW
fi
# --- LISTA NEUTRALNYCH + WYSCIG O ORIGIN (przeniesiona nad bramke baterii 04.10 dla S3: ta sama lista decyduje o ODDECHU)
# --- WYSCIG O ORIGIN (04.10.2026, slowo tworcy 13:13 „Werdykt projektowy i wdrozenie zostaja dla Opusa") ---
# PRZYCZYNA (zmierzona 04.10, kanon/plany/linienie/PACZKA_bateria_wyscig_0410.md): fetch stoi PRZED bateria,
# a bateria trwa minuty (Windows: 18–27 min). Origin ruszal w tym czasie, push byl odrzucany, a kazda nowa
# proba = caly przebieg od zera z DRUGA pelna bateria po rebase (B5). Dwie zmiany, obie waskie:
#   (W-a) PRZENIESIENIE POMIARU: bateria mierzy glownie PRZYRZADY na atrapach, ale NIE tylko — czesc torow czyta
#         zywe dane. Zmierzone 04.10 na 82 torach (HEAD a873b7c), klasa po klasie, wyzerowaniem i dopisanym smieciem:
#         sciezki z listy nizej (705 plikow) nie zmieniaja wyniku ZADNEGO toru; kanon/ksiegi/* poza trzema nazwanymi
#         oblewa straz_r0 i pokrycie_m, reszta kanon/ (eksperymenty, prawa, tozsamosc…) oblewa stol i stol_paczka —
#         te NIE sa na liscie. Kontrola pozytywna: zepsuty hashuj.sh oblewa 4 tory (pomiar umie przegrac).
#         Dlatego drzewo, ktore rozni sie od ZMIERZONEGO wylacznie sciezkami z listy, niesie ten sam wynik baterii
#         i B5 jej nie powtarza. Lista jest ZAMKNIETA: cokolwiek spoza niej (kod, korzen, .claude, szablony, nowy
#         katalog) = pelna bateria jak dotad. NIE rozszerzac bez pomiaru tej samej klasy (bateria na zepsutych
#         plikach, tor powtorzony przy oblaniu, kontrola pozytywna). Nowy tor czytajacy zywe dane z listy = zdjac sciezke.
#   (W-b) PONOWIENIE: push odrzucony, bo origin ruszyl w trakcie bramki → fetch → rebase auto (te same 3 warunki,
#         B1–B5) → push; najwyzej 3 proby, NIGDY force. Decyzja o ponowieniu ze STANU (fetch rc=0 i origin ma
#         commity, ktorych nie mamy), nie z tekstu odmowy (#19). Kolizja twarda dalej = rc=3, regres dalej = rc=7.
_ZG_NEUTRALNE_RE='^(kanon/plany/|kanon/pomiary/|kanon/ksiegi/kartki/|kanon/ksiegi/KTO_CO_BIERZE\.md$|kanon/ksiegi/LOG_SESJI\.md$|prywatne/|projekty/|_HASHE\.txt$|mutacje\.txt$|_STRAZ_APPEND\.txt$)'
_zg_poza_neutralnymi() {   # $1 = drzewo zmierzone, $2 = drzewo biezace → wypisuje zmienione sciezki SPOZA listy
  git diff --name-only "$1" "$2" | grep -v '^$' | grep -vE "$_ZG_NEUTRALNE_RE" || true
}
# --- BRAMKA BATERII — REGRESYJNA (02.09.2026, ciecie na slowo tworcy; wzorzec #61) ---
# Straz pilnuje WYJSCIA W SWIAT, nie przebudzenia: wstan.sh domyslnie nie biega baterii,
# wiec pelna bateria jest OBOWIAZKOWA tu — przy kazdym zywym pushu.
#
# DLACZEGO REGRES, A NIE ZERO (poprawka, nie obejscie). Bramka bezwzgledna okazala sie
# ZLE ZAPROJEKTOWANA: mierzyla STAN, a stan niesie dlug ZASTANY, ktorego ta reka nie
# wniosla. Na Windows siedem torow oblewa z przyczyn SRODOWISKOWYCH (node nie widzi /tmp,
# python3 = zaslepka WindowsApps, odciski LF nad drzewem CRLF) — bramka bezwzgledna
# zamykala wtedy droge kazdej pracy, takze tej, ktora niczego nie zepsula. To dokladnie
# klasa #56: alarm szerszy niz sygnal uczy nie patrzec, a w koncu uczy obchodzic.
# Wzorzec wziety z `straz_lintow.sh` (#61): mierz ROZNICE wobec baseline'u, nie stan.
#
# BASELINE JEST DANA SRODOWISKA, NIE KANONU. Lezy w `.baseline_baterii` (gitignore),
# bo Windows i Linux maja rozne liczby oblanych — plik w repo bylby cudza prawda o cudzej
# maszynie. Zapisuje go WYLACZNIE jawne polecenie `bash zapis_git.sh --baseline-baterii`;
# bramka NIGDY go nie nadpisuje sama, takze przy spadku (inaczej dlug „splacalby sie"
# przez samo pchniecie — Goodhart, przed ktorym ostrzega `straz_mianownika.sh`).
# BRAK PLIKU = baseline zero, czyli zachowanie sprzed 02.09. Milczenie nie zwalnia.
#
# ZG_TORY_CMD / ZG_BAZA_PLIK: wylacznie uchwyty fikstur toru; produkcja ich NIE ustawia.
_TORY_CMD="${ZG_TORY_CMD:-bash tory_strazy.sh --cicho}"
_BAZA_PLIK="${ZG_BAZA_PLIK:-.baseline_baterii}"
# Bramka jako FUNKCJA (R2, 03.10): wolana dwa razy — przed pushem i po rebase auto (B5).
# return 7 zamiast exit 7, zeby wolajacy mogl cofnac rebase, zanim odmowi.
_zg_bateria() {
_zg_stan "oddech=wolny"
echo "▤ BRAMKA BATERII przed pushem (tory strazy — pelny bieg):"
# rc baterii CELOWO nie jest werdyktem: bramka pyta o LICZBE oblanych, nie o kod wyjscia.
# `|| true` w podstawieniu, bo `set -e` ubilby skrypt na oblanej baterii przed pomiarem.
_WY_BAT="$($_TORY_CMD 2>&1 || true)"
_OBL="$(printf '%s\n' "$_WY_BAT" | sed -n 's/.*oblanych \([0-9][0-9]*\).*/\1/p' | tail -1)"
if [ -z "$_OBL" ]; then
  # Brak liczby to NIE jest zero. Bateria, ktora nie zmierzyla, nie otwiera bramy (#52).
  echo "🛑 BATERIA NIE ZMIERZONA (brak linii 'oblanych N') — push ODMOWIONY (rc=7)."
  echo "   Zmierz recznie: bash tory_strazy.sh"; return 7
fi
_BAZA=""
if [ -f "$_BAZA_PLIK" ]; then
  _BAZA="$(sed -n 's/^oblanych=\([0-9][0-9]*\)$/\1/p' "$_BAZA_PLIK" | tail -1)"
fi
if [ -z "$_BAZA" ]; then
  _BAZA=0
  echo "   ⓘ brak baseline'u ($_BAZA_PLIK) — bramka mierzy wobec ZERA, jak przed 02.09."
  echo "     Ustal jawnie na czystym HEAD: bash zapis_git.sh --baseline-baterii"
fi
# NAZWY (04.10): liczba sama przepuszczala NOWY oblany tor, gdy zastany dlug mial te sama liczbe
# (02.09: `stol` pod `gotowosc`). Baseline z linia `oblane=` zna nazwy: tor spoza listy = odmowa,
# nawet gdy liczba nie rosnie. Baseline BEZ tej linii (stary) liczy jak dawniej + meldunek.
_NAZWY_TERAZ="$(printf '%s\n' "$_WY_BAT" | sed -n 's/^ *✗ \([a-z_0-9]*\) —.*/\1/p' | sort -u)"
if [ -f "$_BAZA_PLIK" ] && grep -q '^oblane=' "$_BAZA_PLIK"; then
  _NAZWY_BAZA="$(sed -n 's/^oblane=\(.*\)$/\1/p' "$_BAZA_PLIK" | tail -1 | tr ',' '\n')"
  if [ "$_OBL" -gt 0 ] && [ -z "$_NAZWY_TERAZ" ]; then
    echo "🛑 BATERIA: oblanych $_OBL, ale NAZW nie wyczytano (zmieniony format wyjscia?) — nie moge sprawdzic z baseline'em — push ODMOWIONY (rc=7)."; return 7
  fi
  for _n in $_NAZWY_TERAZ; do
    if ! printf '%s\n' "$_NAZWY_BAZA" | grep -qxF -- "$_n"; then
      echo "🛑 NOWY OBLANY TOR: $_n — nie ma go w baseline'ie (${_NAZWY_BAZA:+$(printf '%s' "$_NAZWY_BAZA" | paste -sd, -)}${_NAZWY_BAZA:-pusty}) — push ODMOWIONY (rc=7)."
      echo "   Liczba moze sie zgadzac, a to i tak REGRES (zastany dlug przyslonil nowy tor). Zmierz: bash tory_strazy.sh"
      return 7
    fi
  done
elif [ -f "$_BAZA_PLIK" ] && [ "$_OBL" -gt 0 ]; then
  echo "   ⓘ baseline bez nazw torow (stary format) — bramka liczy sama liczbe; odnow: bash zapis_git.sh --baseline-baterii"
fi
if [ "$_OBL" -gt "$_BAZA" ]; then
  echo "🛑 BATERIA POGORSZONA: oblanych $_OBL, baseline $_BAZA — push ODMOWIONY (rc=7)."
  echo "   To jest REGRES wniesiony przez te reke, nie dlug zastany. Zmierz: bash tory_strazy.sh"
  return 7
fi
if [ "$_OBL" -gt 0 ]; then
  echo "   ⚠ DLUG ODZIEDZICZONY PRZEPUSZCZONY: oblanych $_OBL (baseline $_BAZA)."
  echo "     Bramka mierzy REGRES, nie stan — to NIE jest zielone swiatlo dla tych strazy."
  printf '%s\n' "$_WY_BAT" | sed -n 's/^ *✗ \([a-z_0-9]*\) —.*/       oblana: \1/p'
  [ "$_OBL" -lt "$_BAZA" ] && echo "     ✓ dlug SPLACONY: $_BAZA → $_OBL (baseline nietkniety — nadpisuje go tylko jawne polecenie)"
else
  echo "   ✓ bateria czysta — brama otwarta"
fi
  return 0
}
# --- DWA ODDECHY (S3, 04.10.2026, A4 punktu stabilnego — slowo tworcy 15:01/15:03: „Potrzebujemy pomyslu, a nie ograniczen”) ---
# PRZYCZYNA: bateria 3 min na Linuxie (18–27 na Windows) placona przy KAZDYM pushu, takze gdy ruch tej reki to kartka,
# plan albo wiersz pomiaru (zmierzone 04.10: ~49% pushow z 7 dni lezy w liscie neutralnych). Wiecej okien = wiecej pushow = dluzsza kolejka.
# MECHANIZM: ODDECH SZYBKI — diff naszych commitow wzgledem merge-base z origin dotyka WYLACZNIE listy neutralnych (ta sama
# zamknieta, zmierzona lista co w B5: 705 plikow, kontrola pozytywna, zero nowego pliku zaufania) → baterii nie biegne;
# pomiar ostatniego pushu origin przenosi sie (drzewo „zmierzone” = drzewo origin, nie nasze niezmierzone). ODDECH WOLNY — cokolwiek
# poza lista (kod, korzen, .claude, szablony, nowy katalog, kanon/ksiegi poza rejestrami) → pelna bateria jak dotad.
# Sciezki chronione (BRAMKA PRZYRZADOW) NIE sa na liscie, wiec zawsze ida wolnym oddechem. Lista zamknieta: nie rozszerzac bez pomiaru.
# ZG_ODDECH_WOLNY=1 wymusza wolny (diagnostyka). Pomiar: wiersz biegu (S2) pole „oddech”.
_ZG_RUCH_POZA="$(_zg_poza_neutralnymi "$_ZG_BR_BAZA" HEAD)"
if [ -z "$_ZG_RUCH_POZA" ] && [ "${ZG_ODDECH_WOLNY:-}" != 1 ]; then
  _zg_stan "oddech=szybki"
  echo "▤ ODDECH SZYBKI: ruch tej reki dotyka wylacznie sciezek neutralnych dla baterii — baterii nie biegne (pomiar origin sie przenosi; lista zamknieta, PACZKA_bateria_wyscig_0410)."
  _ZG_DRZEWO_ZMIERZONE="$(git rev-parse 'FETCH_HEAD^{tree}')"
else
  echo "▤ ODDECH WOLNY: ruch poza lista neutralnych ($(printf '%s\n' "${_ZG_RUCH_POZA:-ZG_ODDECH_WOLNY=1}" | head -3 | tr '\n' ' ')) — pelna bateria."
  _ZG_DRZEWO_ZMIERZONE="$(git rev-parse 'HEAD^{tree}')"
  _zg_bateria || exit 7
fi

_ZG_PROBA=1; _ZG_PROB_MAX=3
while :; do

if [ "$REMOTE" != "brak" ] && ! git merge-base --is-ancestor "$REMOTE" "$LOCAL"; then
  # --- REBASE AUTO (ratyfikacja twórcy 01.08.2026) ---
  # 15B zakazuje CICHEGO SCALANIA TRESCI, nie rebase'u jako takiego. Incydent zrodlowy:
  # pelny merge SKASOWAL pliki istniejace tylko na prywatnej. Gdy tego ryzyka NIE MA —
  # zmierzone, nie zalozone — brama byla za szeroka (ta sama wada co #38).
  # TRZY WARUNKI, wszystkie mierzone, wszystkie musza byc spelnione naraz:
  #   (1) merge-tree --write-tree rc=0     — zero konfliktow
  #   (2) zbiory zmienionych plikow ROZLACZNE — zaden plik tkniety przez obie rece
  #   (3) ZERO USUNIEC po stronie zdalnej   — bezpiecznik wprost z 15B
  # Ktorykolwiek niespelniony -> STOP jak dawniej, decyzja tworcy.
  # Cicha jest ZGODA, nie FAKT: skrypt zawsze melduje, ze rebase'owal i na jakiej podstawie.
  # R2 (03.10.2026, slowo tworcy 14:28: „Pomysl dobry i rozwiazanie rowniez"): 15B ZOSTAJE.
  # Dochodzi WASKI WYJATEK: rejestry dopisywane z BIALEJ LISTY wolno scalic suma linii obu
  # stron — GLOSNO i z pomiarem po fakcie (bezpieczniki B1–B5 nizej). Wszystko poza lista
  # i poza _HASHE.txt: STOP jak dotad. Pakiet: kanon/plany/PAKIET_0310_rebase_rejestry.md
  # (nie rozszerzac listy ponad ten zestaw bez nowej decyzji tworcy).
  #   KTO_CO_BIERZE.md      wpisy dopisywane blokami na koncu (zderzenie STATUS lapie B3)
  #   MODEL_deklarowany.txt wiersz na ture, tylko dopisek
  #   KRZESLA_zlapane.txt   wiersz na zdarzenie, tylko dopisek
  #   ALARMY_szereg.txt     wiersz na wstanie (identyczny wiersz z dwoch okien scali sie w JEDEN — przyjete)
  #   mutacje.txt           wiersz na mutacje, kolejnosc bez znaczenia
  #   LOG_SESJI.md          wiersz tabeli na sesje, na koncu
  # _HASHE.txt to pochodna: scala ja sterownik po SCIEZCE (narzedzia/przyrzady/merge_hashe.sh).
  # TABLICA v2 (03.10): kartki sesji (kanon/ksiegi/kartki/<SESJA>.md) NIE wchodza na biala liste — jeden plik, jeden
  # pisarz, wiec dwie rece nie maja wspolnego pliku i rebase nie ma o co sie zderzyc (merge-tree rc=0 bez atrybutow).
  # KTO_CO_BIERZE.md zostaje na liscie do 10.10 jako archiwum czytane i pisane przez STARE okna (odstepstwo od R-T5:
  # zdjecie z listy dopiero po tygodniu, gdy --inne nie zglasza juz „stare okno").
  # BIALA_REJESTROW: lista przeniesiona przed krok (1) — jedno zrodlo dla rebase auto i trybu recznego (--kontynuuj).
  BAZA="$(git merge-base "$LOCAL" "$REMOTE")"
  trap _zg_attr_przywroc EXIT
  _zg_attr_wlacz
  export KRONOS_HASHE_BIALA="$BIALA_REJESTROW" KRONOS_HASHE_PRZELICZ="$_ZG_PRZELICZ"
  _ZG_MERGE=(-c "merge.kronos-hashe.driver=bash \"$_ZG_DRIVER_KOPIA\" %O %A %B")
  rm -f "$_ZG_PRZELICZ"
  set +e
  git "${_ZG_MERGE[@]}" merge-tree --write-tree "$LOCAL" "$REMOTE" >/dev/null 2>&1; RC_MT=$?
  set -e
  rm -f "$_ZG_PRZELICZ"
  _zg_kolizje "$LOCAL"
  USUNIETE="$(git diff --name-only --diff-filter=D "$BAZA" "$REMOTE")"
  _ZG_RECZNY=0; [ "${ZAPIS_REBASE_RECZNY:-}" = "tak" ] && _ZG_RECZNY=1   # Q2b: reczny rebase ZE sterownikami (tylko gdy zdalna reka niczego nie usuwa — 15B)
  if { [ "$RC_MT" -eq 0 ] && [ -z "$KOLIZJE_TWARDE" ] && [ -z "$USUNIETE" ]; } || { [ "$_ZG_RECZNY" = 1 ] && [ -z "$USUNIETE" ]; }; then
   if [ "$RC_MT" -eq 0 ] && [ -z "$KOLIZJE_TWARDE" ]; then
    echo "[~] ROZEJSCIE BEZ RYZYKA — REBASE AUTO (ratyfikacja 01.08.2026, wyjatek rejestrow 03.10.2026). Podstawa ZMIERZONA:"
    echo "    (1) merge-tree rc=0 (z atrybutami rejestrow)  (2) wspolne pliki tylko z BIALEJ LISTY / _HASHE.txt  (3) zero usuniec po stronie zdalnej"
   else
    echo "[~] ROZEJSCIE Z KOLIZJA TRESCI — TRYB RECZNY (ZAPIS_REBASE_RECZNY=tak): rebase ZE sterownikami rejestrow i _HASHE; stop tylko na plikach spoza listy."
   fi
    git log --oneline "$REMOTE" ^"$LOCAL" | head -5 | sed 's/^/    druga reka: /'
    STARY_LOCAL="$LOCAL"; _zg_stan "rebase=T"
    set +e; git "${_ZG_MERGE[@]}" rebase "$REMOTE" >/dev/null 2>&1; RC_RB=$?; set -e
    if [ "$RC_RB" -ne 0 ]; then
      [ "$_ZG_RECZNY" = 1 ] && _zg_rebase_stop
      git rebase --abort >/dev/null 2>&1 || true
      _zg_stan "winny=rebase-auto"; echo "[!] rebase auto NIE poszedl (rc=$RC_RB) mimo zielonych warunkow — cofniety, nic nie pcham."
      echo "    -> to jest rozjazd miary i rzeczy: ZGLOS do BLEDY. Decyzja tworcy."; exit 3
    fi
    # --- BEZPIECZNIKI PO REBASE (R2): kazdy niespelniony cofa rebase do STARY_LOCAL (wspolne z --kontynuuj: _zg_bezpieczniki) ---
    _zg_bezpieczniki "" "odciski rejestrow po rebase auto (zapis_git.sh R2)"
    # U1-09 (B3 napraw U1): tryb reczny scalil plik spoza listy zmieniony przez obie rece BEZ konfliktu — scalenie zostaje, ale GLOSNO i z polem w wierszu biegu
    [ "$_ZG_RECZNY" = 1 ] && _zg_scalone_glosno "$KOLIZJE_TWARDE"
    LOCAL="$(git rev-parse HEAD)"
    # B5 druga bramka baterii na NOWYM HEAD (drzewo po rebase nie bylo mierzone — to jedyny pomiar po scaleniu)
    # (W-a, 04.10) pomiar przenosi sie TYLKO, gdy drzewo po rebase rozni sie od zmierzonego wylacznie sciezkami neutralnymi.
    _ZG_POZA="$(_zg_poza_neutralnymi "$_ZG_DRZEWO_ZMIERZONE" "$(git rev-parse 'HEAD^{tree}')")"
    if [ -z "$_ZG_POZA" ]; then
      echo "    B5: drzewo po rebase rozni sie od ZMIERZONEGO tylko plikami neutralnymi dla baterii — pomiar przeniesiony, baterii nie powtarzam."
    else
      echo "    B5: druga bramka baterii na drzewie po rebase (zmiana poza lista neutralnych: $(printf '%s\n' "$_ZG_POZA" | head -3 | tr '\n' ' ')):"
      _zg_bateria || { echo "[!] B5: bateria po rebase pogorszona/niezmierzona."; _zg_cofnij; exit 7; }
      _ZG_DRZEWO_ZMIERZONE="$(git rev-parse 'HEAD^{tree}')"
    fi
    _zg_attr_przywroc; trap - EXIT
    echo "    rebase OK -> HEAD $(echo "$LOCAL" | cut -c1-7); pcham dalej."
  else
    echo "[!] ROZEJSCIE GALEZI — origin/$BR ma commity, ktorych nie masz lokalnie:"
    git log --oneline "$REMOTE" ^"$LOCAL" | head -5
    _zg_stan "winny=$(printf '%s\n%s\n' "$KOLIZJE_TWARDE" "$USUNIETE" | grep -v '^$' | head -3 | paste -sd, -)"
    [ "$RC_MT" -ne 0 ] && echo "    powod STOPu: KONFLIKT TRESCI (merge-tree rc=$RC_MT)"
    [ -n "$KOLIZJE_TWARDE" ] && echo "    powod STOPu: ten sam plik u obu rak (poza biala lista rejestrow): $(echo "$KOLIZJE_TWARDE" | tr '\n' ' ')"
    [ -n "$USUNIETE" ] && echo "    powod STOPu: druga reka USUWA pliki (15B): $(echo "$USUNIETE" | tr '\n' ' ')"
    echo "    -> NIE pcham (zaden cichy merge, 15B)."
    echo "       NIE rob golego 'git rebase' — biegnie bez sterownikow rejestrow i _HASHE (07.10: tak powstal konflikt _HASHE.txt, ktory skrypt sam by scalil)."
    echo "       Pokaz ten komunikat wlascicielowi tematu. Obejrzec mozna: git log FETCH_HEAD"
    [ -n "$KOLIZJE_TWARDE" ] && echo "       pliki, ktore wymagaja jego decyzji: $(echo "$KOLIZJE_TWARDE" | tr '\n' ' ')"
    exit 3
  fi
fi

# --- (3) push z rc-gate + weryfikacja niezalezna ---
# Redakcja `sed 's#https://...@#***@#'` zdjęta: token nie żyje już w $URL, więc nie ma
# czego wycinać z wyjścia. Gdyby wróciła kiedyś potrzeba stringu z auth w komunikacie,
# to sygnał, że ktoś znów zaszył token w URL — nie łatać sed-em, poprawić przyczynę.
set +e; _PUSH_OUT=$(git "${GITC[@]}" push "$URL" "$BR" 2>&1); RC=$?; set -e
printf '%s\n' "$_PUSH_OUT"
if [ "$RC" -ne 0 ] && [ "$_ZG_PROBA" -lt "$_ZG_PROB_MAX" ]; then
  # (W-b, 04.10) czy to WYSCIG? Mierzone stanem: fetch dziala i origin ma commity, ktorych nie mamy.
  set +e; git "${GITC[@]}" fetch "$URL" "$BR" > /dev/null 2>&1; _ZG_RCF2=$?; set -e
  if [ "$_ZG_RCF2" -eq 0 ] && ! git merge-base --is-ancestor "$(git rev-parse FETCH_HEAD)" "$LOCAL"; then
    REMOTE="$(git rev-parse FETCH_HEAD)"; _ZG_PROBA=$((_ZG_PROBA+1))
    echo "[~] WYSCIG: origin/$BR ruszyl w trakcie bramki (push odrzucony, rc=$RC) — proba $_ZG_PROBA/$_ZG_PROB_MAX: rebase auto na swiezym origin, potem push. Nigdy force."
    continue
  fi
fi
if [ "$RC" -ne 0 ]; then
  # 30.09.2026: odmowa proxy git (repo poza zakresem sesji) to trzecia klasa porażki —
  # ani sieć, ani rozjazd, ani token. Nazwana, żeby nie ponawiać pushu w pętli (DESTYLAT 21.08: „cztery próby, ten sam 403").
  if printf '%s' "$_PUSH_OUT" | grep -q "access denied by the git proxy"; then
    echo "🛑 ODMOWA PROXY: repo poza zakresem TEJ sesji. Commit jest lokalnie, nic nie przepadło."
    echo "   -> wywołaj add_repo(owner=nowespojrzenie, repo=KRONOS, access=push), potem JEDEN raz: bash zapis_git.sh"
  fi
  echo "[!] push NIE poszedl (rc=$RC) — stan lokalny WYPRZEDZA origin."
  echo "    -> NIE przesuwaj refow, NIE oglaszaj sukcesu. Napraw: fetch -> reset/cherry-pick (#11)."
  [ "$_ZG_PROBA" -ge "$_ZG_PROB_MAX" ] && [ "$_ZG_PROBA" -gt 1 ] && echo "    (wyczerpane $_ZG_PROB_MAX proby po wyscigu — origin rusza szybciej niz bramka; commity sa lokalnie, nic nie przepadlo.)"
  exit "$RC"
fi
break
done
SHA_R="$(git "${GITC[@]}" ls-remote "$URL" "refs/heads/$BR" 2>/dev/null | cut -f1)"
if [ "$SHA_R" = "$LOCAL" ]; then
  # WERYFIKACJA ŁADUNKU (#35) — PRZEPISANA 20.08.2026.
  # BYŁO: `git diff --quiet HEAD FETCH_HEAD` WEWNĄTRZ gałęzi `SHA_R = LOCAL`.
  # Przy równych SHA to te same commity, więc te same drzewa — warunek nie mógł
  # zadziałać nigdy poza wyścigiem fetch/ls-remote. Mechanizm MIERZYŁ CO INNEGO,
  # NIŻ DEKLAROWAŁ (rodzina #52), i był praktycznie nieosiągalny (#53).
  # Sedno blizny #35 nie brzmi „ktoś podmienił treść przy zgodnym SHA" (to jest
  # kryptograficznie niemożliwe) — brzmi: „commit poszedł BEZ części plików".
  # Drugim przyrządem jest więc STAN DRZEWA ROBOCZEGO w chwili pushu, nie drzewo commita.
  if [ -n "$(git status --porcelain)" ]; then
    echo "[!] push potwierdzony, ale DRZEWO ROBOCZE NIE JEST CZYSTE — pchnales mniej, niz masz."
    echo "    -> to jest dokladnie blizna #35 (SHA dowodzi transportu, nie ladunku)."
    git status --porcelain | head -5 | sed 's/^/    /'
    exit 5
  fi
  # Kontrola wyścigu (zachowana, ale nazwana uczciwie): między ls-remote a fetch
  # druga ręka mogła pchnąć. Wtedy FETCH_HEAD ≠ SHA_R i drzewa się rozjadą.
  git "${GITC[@]}" fetch "$URL" "$BR" > /dev/null 2>&1
  if ! git diff --quiet HEAD FETCH_HEAD; then
    echo "[!] WYSCIG: origin zmienil sie miedzy ls-remote a fetch. Twoj push poszedl,"
    echo "    ale zdalne HEAD juz nie jest twoje. Mierz ponownie przed kolejnym ruchem."
    exit 5
  fi
  echo "OK: push potwierdzony (rc=0), ZWERYFIKOWANY (origin/$BR = $(echo "$LOCAL" | cut -c1-7))"
  echo "    i ZGODNY CO DO LADUNKU (git diff HEAD FETCH_HEAD = pusty)"
else
  echo "[!] rc=0, ale ls-remote pokazuje $(echo "${SHA_R:-brak}" | cut -c1-7) != lokalne $(echo "$LOCAL" | cut -c1-7)."
  echo "    -> exit code SKLAMAL (rodzina #19). Nie oglaszaj sukcesu, mierz ponownie."
  exit 4
fi
