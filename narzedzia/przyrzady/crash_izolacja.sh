#!/usr/bin/env bash
# KRONOS · CRASH_IZOLACJA v1.0 (20.08.2026)
# Mechanizm do kanon/prawa/PROTOKOL_crash_izolacja.md (NOŚNA RAMA, ratyfikowana 13.08 na SHA 85e544f).
#
# CO TO ROBI: prowadzi crash test w klonie poza repo i produkuje DOWÓD SZCZELNOŚCI,
# bez którego znalezisko jest blizną (protokół §2 warunek 2). Skrypt NIE klasyfikuje
# znaleziska — klasyfikacja należy do twórcy (§3 krok 7). Skrypt dostarcza wyłącznie
# fakty, na których twórca może ją oprzeć.
#
# CZEGO NIE ROBI — nazwane wprost, bo protokół §5 żąda mierzenia luki:
#   · nie pisze prerejestru (§3 krok 1) — treść testów należy do człowieka; skrypt
#     WYMAGA gotowego pliku prerejestru i go haszuje PRZED klonem,
#   · nie naprawia niczego w klonie (§3 krok 6, zakaz twardy — egzekwowany zamkiem),
#   · nie decyduje „znalezisko czy blizna" (§3 krok 7).
#
# Użycie:
#   bash crash_izolacja.sh --bieg <plik_prerejestru> "<komenda testowa>"
#   bash crash_izolacja.sh --suma          (sama suma kontrolna katalogu roboczego)
#   bash crash_izolacja.sh --test          (tor +/− — straż musi umieć NIE przejść)
#
# KODY WYJŚCIA (werdykt z rc, nigdy z frazy — #19):
#   0 = bieg odbyty, szczelność DOWIEDZIONA (wynik testu osobno, w logu)
#   2 = złe użycie
#   3 = brak prerejestru albo żywe repo brudne PRZED biegiem — bieg nieważny
#   5 = SZCZELNOŚĆ ZŁAMANA: żywe repo zmienione w trakcie → wynik jest BLIZNĄ (#54)
set -uo pipefail

SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
LOG="kanon/ksiegi/KRONOS_CRASH_LOG.md"

# ── SUMA KONTROLNA KATALOGU ROBOCZEGO ──
# Rozstrzyga pytanie otwarte protokołu §6. Zmierzone 20.08.2026 na żywym repo:
#   bez node_modules: 716 plików, 526 ms  ·  z node_modules: 1986 plików, 907 ms
#   licznik: find . -type f -not -path "./.git/*" -not -path "./node_modules/*" | wc -l
# WYBRANE: wariant BEZ node_modules i BEZ .git.
#   node_modules — zarządzane przez npm, `npm install` w wstan.sh legalnie je zmienia;
#     wliczanie ich dawałoby fałszywe alarmy szczelności (klasa #56: alarm szerszy niż sygnał).
#   .git — zmienia się przy samym czytaniu (refs, logs, index); nie jest materią pracy.
# Suma widzi pliki NIEŚLEDZONE — czego `git status --porcelain` w trybie domyślnym nie
# gwarantuje. Oba przyrządy są potrzebne: git widzi zamiar, suma widzi bajty.
suma_katalogu() {
  find . -type f -not -path "./.git/*" -not -path "./node_modules/*" \
    | LC_ALL=C sort | xargs sha256sum 2>/dev/null | sha256sum | cut -d' ' -f1
}

if [ "${1:-}" = "--suma" ]; then suma_katalogu; exit 0; fi

# ── TOR WŁASNY (#38: reguła bez toru obowiązuje tylko w dokumentacji;
#    #47: każdy tor musi mieć przypadek −, który MUSI oblać) ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ CRASH_IZOLACJA — AUTOTEST (#38) ═══╗"
  zle=""
  T="$(mktemp -d)"
  export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=t@t

  # atrapa repo — pracujemy na niej, nie na żywym ciele (#50: tor nie mierzy własnej kopii,
  # ale też nie wolno mu tykać materii, którą wycenia — #54)
  mkdir -p "$T/repo" && cd "$T/repo"
  git init -q . && echo "tresc" > plik.md && echo "prerejestr" > pre.md
  git add -A && git commit -qm start
  cp "$SAM" ./crash_izolacja.sh
  git add -A && git commit -qm skrypt

  # (⊙) SUMA jest funkcją TREŚCI: ta sama treść → ta sama suma
  S1="$(bash ./crash_izolacja.sh --suma)"; S2="$(bash ./crash_izolacja.sh --suma)"
  [ "$S1" = "$S2" ] || zle="$zle suma-niestabilna-na-niezmienionej-materii"

  # (−) SUMA MUSI ZAUWAŻYĆ ZMIANĘ TREŚCI — bez tego cały dowód szczelności jest dekoracją
  echo "inna" > plik.md
  S3="$(bash ./crash_izolacja.sh --suma)"
  [ "$S3" != "$S1" ] || zle="$zle suma-slepa-na-zmiane-tresci"

  # (−) SUMA MUSI ZAUWAŻYĆ PLIK NIEŚLEDZONY — tego `git status --porcelain` nie dowozi tak samo
  git checkout -q -- plik.md
  echo "podrzucony" > nieslledzony.tmp
  S4="$(bash ./crash_izolacja.sh --suma)"
  [ "$S4" != "$S1" ] || zle="$zle suma-slepa-na-plik-niesledzony"
  rm -f nieslledzony.tmp

  # (−) BIEG BEZ PREREJESTRU MUSI ODMÓWIĆ (§3 krok 1: bez prerejestru bieg jest nieważny)
  bash ./crash_izolacja.sh --bieg brak_takiego_pliku.md "true" >/dev/null 2>&1; RC_NP=$?
  [ "$RC_NP" -eq 3 ] || zle="$zle bieg-bez-prerejestru-przeszedl(rc=$RC_NP)"

  # (−) BRUDNE ŻYWE REPO PRZED BIEGIEM MUSI ODMÓWIĆ (§3 krok 3)
  echo "brud" > brud.md
  bash ./crash_izolacja.sh --bieg pre.md "true" >/dev/null 2>&1; RC_BR=$?
  [ "$RC_BR" -eq 3 ] || zle="$zle brudne-repo-przeszlo(rc=$RC_BR)"
  rm -f brud.md

  # (+) BIEG CZYSTY: test nieszkodliwy → rc=0 i log powstaje
  bash ./crash_izolacja.sh --bieg pre.md "true" >/dev/null 2>&1; RC_OK=$?
  [ "$RC_OK" -eq 0 ] || zle="$zle czysty-bieg-oblal(rc=$RC_OK)"
  [ -f "$LOG" ] || zle="$zle log-nie-powstal"
  # log musi NIEŚĆ SHA i sumy — inaczej jest opowieścią, nie dowodem
  grep -q "SHA:" "$LOG" 2>/dev/null || zle="$zle log-bez-sha"
  grep -q "suma PRZED" "$LOG" 2>/dev/null || zle="$zle log-bez-sumy"
  git add -A && git commit -qm "log po biegu czystym" >/dev/null 2>&1

  # (−−−) TOR BIJĄCY WPROST W WARUNEK SUMY (#53: zamek musi mieć drogę do siebie).
  # Poprzedni tor łapie skażenie DWOMA przyrządami naraz, więc mutacja samego warunku
  # sumy przechodziła — drugi przyrząd ją maskował. Tu skażenie jest widoczne WYŁĄCZNIE
  # dla sumy: plik ignorowany przez git. To jest dokładnie powód, dla którego suma istnieje.
  echo "*.ignorowany" > .gitignore
  git add -A && git commit -qm gitignore >/dev/null 2>&1
  bash ./crash_izolacja.sh --bieg pre.md "echo skazenie > $T/repo/podrzut.ignorowany" >/dev/null 2>&1; RC_IG=$?
  [ "$RC_IG" -eq 5 ] || zle="$zle skazenie-niewidoczne-dla-git-nie-dalo-rc5(rc=$RC_IG)"
  rm -f podrzut.ignorowany
  git add -A && git commit -qm "log po biegu ignorowanym" >/dev/null 2>&1

  # (−−) NAJWAŻNIEJSZY TOR: TEST, KTÓRY DOTKNĄŁ ŻYWEGO REPO, MUSI DAĆ rc=5.
  # To jest zamek chroniący całą konstrukcję: bez niego skrypt wystawiałby dowód
  # szczelności biegowi, który szczelny nie był (klasa #54).
  bash ./crash_izolacja.sh --bieg pre.md "echo skazenie >> $T/repo/plik.md" >/dev/null 2>&1; RC_SK=$?
  [ "$RC_SK" -eq 5 ] || zle="$zle skazenie-zywego-repo-nie-dalo-rc5(rc=$RC_SK)"

  cd /; rm -rf "$T"
  if [ -z "$zle" ]; then
    echo "  ✓ IZOLACJA ŻYWA: suma widzi treść i pliki nieśledzone, bieg bez prerejestru"
    echo "    i na brudnym repo odmawia, a skażenie żywej materii daje rc=5 (nie dowód)."
    exit 0
  fi
  echo "  ✗ IZOLACJA MARTWA:$zle"
  exit 1
fi

# ── BIEG ──
[ "${1:-}" = "--bieg" ] || { echo "użycie: --bieg <prerejestr> \"<komenda>\" | --suma | --test"; exit 2; }
PRE="${2:-}"; KOMENDA="${3:-}"
[ -n "$PRE" ] && [ -n "$KOMENDA" ] || { echo "✗ brak prerejestru albo komendy"; exit 2; }

# §3 krok 1 — PREREJESTR PRZED KLONEM, zahaszowany. Bez pliku bieg jest nieważny:
# kryteria dostrojone po zobaczeniu wyniku nie są kryteriami.
[ -f "$PRE" ] || { echo "✗ PREREJESTR nie istnieje: $PRE — bieg NIEWAŻNY (§3 krok 1)"; exit 3; }
HASH_PRE="$(sha256sum "$PRE" | cut -c1-12)"

# §3 krok 3 — DOWÓD SZCZELNOŚCI PRZED. Dwa przyrządy, nie jeden (#46: pomiar
# jednoźródłowy to nadal wnioskowanie). git widzi ZAMIAR, suma widzi BAJTY.
BRUD="$(git status --porcelain 2>/dev/null)"
if [ -n "$BRUD" ]; then
  echo "✗ ŻYWE REPO BRUDNE PRZED BIEGIEM — bieg NIEWAŻNY (§3 krok 3):"
  printf '%s\n' "$BRUD" | head -5 | sed 's/^/    /'
  exit 3
fi
SUMA_PRZED="$(suma_katalogu)"
SHA="$(git rev-parse HEAD 2>/dev/null | cut -c1-12)"
STEMPEL="$(TZ=Europe/Warsaw date '+%Y-%m-%d %H:%M:%S %Z')"
KAT="/tmp/crash_${SHA}_$(TZ=Europe/Warsaw date '+%Y%m%d_%H%M%S')"

# §3 krok 2 — KLON z konkretnego SHA, poza katalog repo
git clone -q . "$KAT" 2>/dev/null || { echo "✗ klon nie powstał"; exit 3; }

# §3 krok 4 — BIEG wyłącznie w klonie
echo "▶ bieg w izolacji: $KAT (SHA $SHA)"
( cd "$KAT" && eval "$KOMENDA" ) > "$KAT/_wyjscie.txt" 2>&1; RC_TESTU=$?
echo "  komenda zakończyła się rc=$RC_TESTU (to NIE jest werdykt szczelności)"

# ZAMEK #54
# §3 krok 5 — DOWÓD SZCZELNOŚCI PO. Suma musi się zgadzać CO DO ZNAKU.
SUMA_PO="$(suma_katalogu)"
BRUD_PO="$(git status --porcelain 2>/dev/null)"
SZCZELNY=1
[ "$SUMA_PRZED" = "$SUMA_PO" ] || SZCZELNY=0
[ -z "$BRUD_PO" ] || SZCZELNY=0

# §3 krok 6 — ZAPIS. Log niesie fakty, nie ocenę: klasyfikacja należy do twórcy (krok 7).
mkdir -p "$(dirname "$LOG")"   # log mieszka w kanon/ksiegi/ (Ciecie 5) — w swiezym klonie/fiksturze domu moze nie byc (#64)
[ -f "$LOG" ] || printf '# KRONOS — LOG BIEGÓW W IZOLACJI\n\n> Rejestr znalezisk z crash testów. Klasyfikację znalezisko/blizna czyta TWÓRCA\n> (`PROTOKOL_crash_izolacja` §3 krok 7) — ten plik jej NIE zawiera, niesie fakty.\n\n' > "$LOG"
{
  echo "## Bieg $STEMPEL"
  echo "- SHA: \`$SHA\` · prerejestr: \`$PRE\` (sha256 \`$HASH_PRE\`)"
  echo "- klon: \`$KAT\`"
  echo "- komenda: \`$KOMENDA\`"
  echo "- rc komendy: **$RC_TESTU**"
  echo "- suma PRZED: \`$SUMA_PRZED\`"
  echo "- suma PO:    \`$SUMA_PO\`"
  if [ "$SZCZELNY" = 1 ]; then
    echo "- **SZCZELNOŚĆ: DOWIEDZIONA** — żywe repo nietknięte (dwa przyrządy zgodne)."
    echo "- KLASYFIKACJA (twórca, §3 krok 7): \`[ ]\` znalezisko  \`[ ]\` blizna"
  else
    echo "- **SZCZELNOŚĆ: ZŁAMANA** — żywe repo zmieniło się w trakcie biegu."
    echo "- Wynik tego biegu jest **BLIZNĄ**, nie znaleziskiem (§2, klasa #54)."
  fi
  echo "- wyjście testu: \`$KAT/_wyjscie.txt\` (klon kasuje się po odczycie — §3 krok 6)"
  echo ""
} >> "$LOG"

if [ "$SZCZELNY" = 1 ]; then
  echo "✓ SZCZELNOŚĆ DOWIEDZIONA — suma i git zgodne przed i po. Wpis w $LOG."
  echo "  Klasyfikacja znalezisko/blizna NALEŻY DO TWÓRCY — skrypt jej nie proponuje."
  echo "  ZAKAZ NAPRAWIANIA W KLONIE (§3 krok 6): naprawa idzie osobnym cięciem do żywego repo."
  exit 0
fi
echo "✗ SZCZELNOŚĆ ZŁAMANA — żywe repo zmienione w trakcie biegu."
echo "  Wynik jest BLIZNĄ, nie znaleziskiem. Zegar bramki 1 zeruje się."
printf '%s\n' "$BRUD_PO" | head -5 | sed 's/^/    /'
exit 5
