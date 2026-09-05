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
set -e

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
  printf '#!/bin/sh\necho "  zmierzone: zdanych 52 · oblanych ${OBL:-0} · bez toru 0"\nexit "${RCB:-0}"\n' > "$T/bateria_atrapa.sh"
  export ZG_TORY_CMD="sh $T/bateria_atrapa.sh"
  export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=t@t
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
  bash "$SAM" "test d" >/dev/null 2>&1; RC_D=$?
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
  # (⊗) AWARIA AUTH — fikstura musi stanąć PRZED sprzątnięciem katalogu roboczego.
  ( cd "$T/praca" && git remote set-url origin "https://127.0.0.1:1/nie-ma.git" )
  OUT_AUTH="$(cd "$T/praca" && bash "$SAM" "test auth" 2>&1)"; RC_AUTH=$?
  set -e
  cd /; rm -rf "$T"

  echo "── TEST + (świeże żniwo, push+weryfikacja):     rc=$RC_A (oczekiwane 0)"
  echo "── TEST ⊙ (nic do pchnięcia):                   rc=$RC_B (oczekiwane 0)"
  echo "── TEST + (rozejście BEZ ryzyka → rebase auto): rc=$RC_C (oczekiwane 0)"
  echo "── TEST + (rebase auto scalił OBIE ręce):       oba pliki obecne: $SCALONE (oczekiwane 1)"
  echo "── TEST − (kolizja na tym samym pliku):         rc=$RC_D (oczekiwane 3)"
  echo "── TEST − (żaden cichy merge treści, 15B):      nasza wersja nietknięta: $NASZ_SPORNY (oczekiwane 1)"
  echo "── TEST − (druga ręka USUWA plik, 15B):         rc=$RC_E (oczekiwane 3)"
  echo "── TEST − (usuwany plik ocalał u nas, 15B):     obecny: $OCALONY (oczekiwane 1)"
  echo "── TEST ⊙ (gałąź nieobecna na origin):          rc=$RC_W (oczekiwane 6 — nie odsyłamy po token)"
  echo "── BRAMKA + (dług = baseline 7, push idzie):    rc=$RC_FP · pchnięto: $PCHNIETO_F · meldunek o długu: $DLUG_MELD (oczekiwane 0 · 1 · 1)"
  echo "── BRAMKA − (regres 7→8, ODMOWA):               rc=$RC_FM · origin nietknięty: $ORIGIN_NIETKNIETY (oczekiwane 7 · 1)"
  echo "── BRAMKA ⊙ (bateria nie zmierzyła):            rc=$RC_FNIC (oczekiwane 7 — brak liczby to nie zero)"
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
  echo
  if [ "$RC_A" -eq 0 ] && [ "$RC_B" -eq 0 ] && [ "$RC_C" -eq 0 ] && [ "$SCALONE" -eq 1 ] \
     && [ "$RC_D" -eq 3 ] && [ "$NASZ_SPORNY" -eq 1 ] && [ "$RC_E" -eq 3 ] && [ "$OCALONY" -eq 1 ] \
     && [ "$RC_W" -eq 6 ] && [ "$ZRODLO" -eq 1 ] && [ "$PIERWSZE" -eq 1 ] \
     && [ "$RC_FP" -eq 0 ] && [ "$PCHNIETO_F" -eq 1 ] && [ "$DLUG_MELD" -eq 1 ] \
     && [ "$RC_FM" -eq 7 ] && [ "$ORIGIN_NIETKNIETY" -eq 1 ] && [ "$RC_FNIC" -eq 7 ]; then
    echo "✓ STRAŻ ŻYWA: pcha gdy trzeba, milczy gdy nie ma co, rebase'uje gdy ryzyka NIE MA,"
    echo "  staje na kolizji treści i na usunięciu — 15B broniony tam, gdzie naprawdę żyje."
    echo "  Bramka baterii mierzy REGRES: dług zastany przepuszcza głośno, pogorszenie ODMAWIA."
    exit 0
  fi
  echo "✗ STRAŻ MARTWA: A=$RC_A B=$RC_B C=$RC_C scalone=$SCALONE D=$RC_D nasz=$NASZ_SPORNY E=$RC_E ocalony=$OCALONY widmo=$RC_W zrodlo=$ZRODLO pierwsze=$PIERWSZE bramka+=$RC_FP/$PCHNIETO_F/$DLUG_MELD bramka-=$RC_FM/$ORIGIN_NIETKNIETY bramka⊙=$RC_FNIC"
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
  _BRUD="czyste"; git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null || _BRUD="BRUDNE (zmiany poza HEAD)"
  {
    echo "# baseline baterii — liczba oblanych torow TEGO srodowiska."
    echo "# Zapisany JAWNIE: bash zapis_git.sh --baseline-baterii. Bramka nigdy go nie rusza."
    echo "# zmierzono: $(date -u +%Y-%m-%dT%H:%MZ) · HEAD: $(git rev-parse --short HEAD 2>/dev/null || echo brak) · drzewo: $_BRUD"
    echo "oblanych=$_OBL"
  } > "$_BAZA_PLIK"
  echo "   ✓ baseline zapisany: oblanych=$_OBL · drzewo przy pomiarze: $_BRUD"
  echo "     plik: $_BAZA_PLIK (gitignore — dana srodowiska, nie kanonu)"
  exit 0
fi

msg="${1:-zapis Orkiestratora $(date -u +%Y-%m-%dT%H:%MZ)}"
BR="$(git rev-parse --abbrev-ref HEAD)"

# --- (1) commit opcjonalny ---
# (a) dla tkanki: odnow odciski rejestrow, ktore z natury rosna (rdzen NIE — recznie)
bash hashuj.sh > /dev/null 2>&1 || true
git add -A
if git diff --cached --quiet; then
  echo "   (brak zmian w stage — nic do zacommitowania; sprawdzam, czy jest co pchnac)"
else
# --- STRAŻ DATY (#48, 13.08.2026): data z kontekstu ≠ data chwili zapisu ---
# W sesji trwającej dobami znacznik z jej początku cichnie i starzeje się. Skanujemy
# komunikat pod kątem DD.MM i porównujemy z dniem ZMIERZONYM TERAZ. Ostrzegamy, nie
# blokujemy — komunikaty legalnie cytują daty historyczne.
_dzis="$(date +%d.%m)"
_daty="$(printf '%s' "$msg" | grep -oE '\b[0-3][0-9]\.[01][0-9]\b' | sort -u)"
if [ -n "$_daty" ] && ! printf '%s\n' "$_daty" | grep -qx "$_dzis"; then
  echo "[!] STRAŻ DATY (#48): w komunikacie są daty [$(printf '%s' "$_daty" | tr '\n' ' ')]," \
       "a dziś jest $_dzis ($(TZ=Europe/Warsaw date '+%A, %H:%M %Z'))."
  echo "    Jeśli któraś miała znaczyć „dziś\" — przerwij i popraw. Pomiar ma termin ważności."
fi

git commit -m "$msg"
fi

# --- (2) fetch przed pushem: czy druga reka cos dolozyla? ---
# URL: repo jest PRYWATNE, a prawo kaze trzymac origin BEZ tokena.
# Token bierzemy z env KRONOS_PAT, sklejamy INLINE, nigdy nie zapisujemy do configu.
if [ -n "${KRONOS_PAT:-}" ]; then
  # URL WYPROWADZANY z origin, nie hardkodowany (02.08.2026). Powód: ten plik jedzie
  # do odlewu publicznego. Zaszyta nazwa `nowespojrzenie/KRONOS` kazałaby każdemu obcemu
  # klonowi pchać do CUDZEGO prywatnego repo. Nazwa repo nie jest wiedzą skryptu.
  ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
  BARE="${ORIGIN_URL#https://}"; BARE="${BARE##*@}"   # odetnij ewentualne userinfo
  if [ -n "$ORIGIN_URL" ] && [ "${ORIGIN_URL#https://}" != "$ORIGIN_URL" ]; then
    URL="https://${KRONOS_PAT}@${BARE}"
  else
    URL="origin"
    echo "[i] origin nie jest https (lub go brak) — probuje przez origin."
  fi
else
  URL="origin"
  echo "[i] brak KRONOS_PAT w env — probuje przez origin (zadziala tylko, gdy origin ma auth)."
fi
set +e; git fetch "$URL" "$BR" > /dev/null 2>&1; RCF=$?; set -e
if [ "$RCF" -ne 0 ]; then
  # ROZRÓŻNIENIE (31.07.2026): „fetch padł" ma dwie zupełnie różne przyczyny, a jeden
  # komunikat na obie wysyła po token, gdy problem jest gdzie indziej. Mierz, nie zgaduj.
  set +e; git ls-remote "$URL" > /dev/null 2>&1; RCL=$?; set -e
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
echo "▤ BRAMKA BATERII przed pushem (tory strazy — pelny bieg):"
# rc baterii CELOWO nie jest werdyktem: bramka pyta o LICZBE oblanych, nie o kod wyjscia.
# `|| true` w podstawieniu, bo `set -e` ubilby skrypt na oblanej baterii przed pomiarem.
_WY_BAT="$($_TORY_CMD 2>&1 || true)"
_OBL="$(printf '%s\n' "$_WY_BAT" | sed -n 's/.*oblanych \([0-9][0-9]*\).*/\1/p' | tail -1)"
if [ -z "$_OBL" ]; then
  # Brak liczby to NIE jest zero. Bateria, ktora nie zmierzyla, nie otwiera bramy (#52).
  echo "🛑 BATERIA NIE ZMIERZONA (brak linii 'oblanych N') — push ODMOWIONY (rc=7)."
  echo "   Zmierz recznie: bash tory_strazy.sh"; exit 7
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
if [ "$_OBL" -gt "$_BAZA" ]; then
  echo "🛑 BATERIA POGORSZONA: oblanych $_OBL, baseline $_BAZA — push ODMOWIONY (rc=7)."
  echo "   To jest REGRES wniesiony przez te reke, nie dlug zastany. Zmierz: bash tory_strazy.sh"
  exit 7
fi
if [ "$_OBL" -gt 0 ]; then
  echo "   ⚠ DLUG ODZIEDZICZONY PRZEPUSZCZONY: oblanych $_OBL (baseline $_BAZA)."
  echo "     Bramka mierzy REGRES, nie stan — to NIE jest zielone swiatlo dla tych strazy."
  printf '%s\n' "$_WY_BAT" | sed -n 's/^ *✗ \([a-z_0-9]*\) —.*/       oblana: \1/p'
  [ "$_OBL" -lt "$_BAZA" ] && echo "     ✓ dlug SPLACONY: $_BAZA → $_OBL (baseline nietkniety — nadpisuje go tylko jawne polecenie)"
else
  echo "   ✓ bateria czysta — brama otwarta"
fi
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
  BAZA="$(git merge-base "$LOCAL" "$REMOTE")"
  set +e
  git merge-tree --write-tree "$LOCAL" "$REMOTE" >/dev/null 2>&1; RC_MT=$?
  set -e
  PLIKI_ICH="$(git diff --name-only "$BAZA" "$REMOTE")"
  PLIKI_NASZE="$(git diff --name-only "$BAZA" "$LOCAL")"
  KOLIZJE="$(comm -12 <(echo "$PLIKI_ICH" | sort -u) <(echo "$PLIKI_NASZE" | sort -u) | grep -v '^$' || true)"
  USUNIETE="$(git diff --name-only --diff-filter=D "$BAZA" "$REMOTE")"
  if [ "$RC_MT" -eq 0 ] && [ -z "$KOLIZJE" ] && [ -z "$USUNIETE" ]; then
    echo "[~] ROZEJSCIE BEZ RYZYKA — REBASE AUTO (ratyfikacja 01.08.2026). Podstawa ZMIERZONA:"
    echo "    (1) merge-tree rc=0  (2) pliki rozlaczne  (3) zero usuniec po stronie zdalnej"
    git log --oneline "$REMOTE" ^"$LOCAL" | head -5 | sed 's/^/    druga reka: /'
    set +e; git rebase "$REMOTE" >/dev/null 2>&1; RC_RB=$?; set -e
    if [ "$RC_RB" -ne 0 ]; then
      git rebase --abort >/dev/null 2>&1 || true
      echo "[!] rebase auto NIE poszedl (rc=$RC_RB) mimo zielonych warunkow — cofniety, nic nie pcham."
      echo "    -> to jest rozjazd miary i rzeczy: ZGLOS do BLEDY. Decyzja tworcy."; exit 3
    fi
    LOCAL="$(git rev-parse HEAD)"
    echo "    rebase OK -> HEAD $(echo "$LOCAL" | cut -c1-7); pcham dalej."
  else
    echo "[!] ROZEJSCIE GALEZI — origin/$BR ma commity, ktorych nie masz lokalnie:"
    git log --oneline "$REMOTE" ^"$LOCAL" | head -5
    [ "$RC_MT" -ne 0 ] && echo "    powod STOPu: KONFLIKT TRESCI (merge-tree rc=$RC_MT)"
    [ -n "$KOLIZJE" ] && echo "    powod STOPu: ten sam plik u obu rak: $(echo "$KOLIZJE" | tr '\n' ' ')"
    [ -n "$USUNIETE" ] && echo "    powod STOPu: druga reka USUWA pliki (15B): $(echo "$USUNIETE" | tr '\n' ' ')"
    echo "    -> NIE pcham (zaden cichy merge, 15B). Decyzja tworcy:"
    echo "       git rebase FETCH_HEAD   (nasze na wierzch)  |  git log FETCH_HEAD  (najpierw obejrzyj)"
    exit 3
  fi
fi

# --- (3) push z rc-gate + weryfikacja niezalezna ---
set +e; git push "$URL" "$BR" 2>&1 | sed -E 's#https://[^@/]+@#https://***@#g'; RC=${PIPESTATUS[0]}; set -e
if [ "$RC" -ne 0 ]; then
  echo "[!] push NIE poszedl (rc=$RC) — stan lokalny WYPRZEDZA origin."
  echo "    -> NIE przesuwaj refow, NIE oglaszaj sukcesu. Napraw: fetch -> reset/cherry-pick (#11)."
  exit "$RC"
fi
SHA_R="$(git ls-remote "$URL" "refs/heads/$BR" 2>/dev/null | cut -f1)"
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
  git fetch "$URL" "$BR" > /dev/null 2>&1
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
