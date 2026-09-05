#!/usr/bin/env bash
# STRAŻ DUSZY (28.07.2026) — inwariant 5: MAPA CIAŁA bez strażnika = życzenie.
# Pilnuje dwóch rzeczy:
#  (1) każda ścieżka plikowa wymieniona w DUSZA.md ISTNIEJE na dysku (mapa nie kłamie),
#  (2) każda księga *.md w korzeniu jest w DUSZY zmapowana albo świadomie pominięta
#      (lista WYJATKI) — żeby nowe księgi nie rodziły się niewidzialne dla mapy.
# Werdykt z kodu wyjścia (#19): 0 = mapa spójna; 1 = mapa wskazuje nieistniejące.
#
# TOR TESTOWY + SPROSTOWANIE DEKLAMATORA (31.07.2026, prawo #38):
#   Reguła (2) była DEKLAROWANA, ale nie bramkowała rc — i, co gorsze, przy NIEZM>0
#   zdanie o wyniku zaczynało się od „OK". Werdykt stał obok pomiaru (#34). Naprawione:
#   przy niezmapowanych księgach mówi „⚠ MAPA NIEPELNA", nie „OK". Twarde bramkowanie
#   reguły (2) jest ŚWIADOMIE opcjonalne (--scisle) — domyślna miękkość to decyzja
#   twórcy do rozstrzygnięcia, nie moja do cichego zmienienia.
#
# UŻYCIE:
#   bash straz_duszy.sh              # rc=1 tylko za nieistniejące ścieżki
#   bash straz_duszy.sh --scisle     # rc=1 także za niezmapowane księgi
#   bash straz_duszy.sh --kat <dir>  # ta sama analiza w innym katalogu (używa jej tor)
#   bash straz_duszy.sh --test       # tor +/− — straż musi umieć NIE przejść

set -u
SCISLE=0
LICZBA=0
KAT=""
TEST=0
while [ $# -gt 0 ]; do
  case "$1" in
    --scisle) SCISLE=1 ;;
    --kat)    shift; KAT="${1:-}" ;;
    --test)   TEST=1 ;;
    --liczba) LICZBA=1 ;;
    *) echo "użycie: [--scisle] [--kat <dir>] [--liczba] | --test"; exit 2 ;;
  esac
  shift
done

GENEROWANE="0_MELDUNEK.txt"   # tworzone przy wstaniu — nie sa czescia ciala
WYJATKI="0_MELDUNEK.txt README.md README_KRONOS.md START_TU.md kanon/ksiegi/6_ROLA_ARCHITEKTA.md kanon/prawa/TEST_DUSZY.md"

# ── ANALIZA (w katalogu $1) — znaleziska na stdout, ostatnia linia: "MISS NIEZM" ──
analiza() {
  ( cd "$1" || { echo "  x katalog nieosiagalny: $1"; echo "9 0"; return; }
    MISS=0; NIEZM=0
    if [ ! -f DUSZA.md ]; then echo "  x brak DUSZA.md — nie ma czego mierzyc"; echo "9 0"; return; fi
    # (1) ścieżki z DUSZY -> dysk
    for f in $(grep -oE '`[A-Za-z0-9_/.-]+[.](md|js|sh|txt)`' DUSZA.md | tr -d '`' | sort -u); do
      case " $GENEROWANE " in *" $f "*) continue;; esac
      if [ ! -e "$f" ]; then echo "  x DUSZA wskazuje nieistniejacy plik: $f"; MISS=1; fi
    done
    # (2) księgi z dysku -> MAPA (po nazwie bazowej, bez rozszerzenia)
    # MAPA = DUSZA.md + kanon/ksiegi/SPIS_CIALA.md (21.08.2026). Powód: §IV przestało być spisem
    # i zostało dwoma adresami — spis ciała jest GENEROWANY (`node narzedzia/przyrzady/spis_ciala.js`).
    # Ta reguła NIE stała się przez to martwa: generator gwarantuje kompletność tylko
    # w chwili biegu, więc gdy ktoś doda księgę i NIE zregeneruje spisu, straż zapala
    # się dokładnie tak jak dawniej. To drugi, niezależny czytnik świeżości obok
    # `narzedzia/przyrzady/spis_ciala.js --sprawdz` — dwa różne przyrządy nad tą samą luką (#39: cisza
    # jednego nie jest nie do odróżnienia od zdrowia, bo drugi mówi osobno).
    MAPA="$(cat DUSZA.md 2>/dev/null; cat kanon/ksiegi/SPIS_CIALA.md 2>/dev/null)"
    if [ ! -f kanon/ksiegi/SPIS_CIALA.md ]; then
      echo "  x brak kanon/ksiegi/SPIS_CIALA.md — mapa ciala nie istnieje (node narzedzia/przyrzady/spis_ciala.js)"; MISS=1
    fi
    for f in *.md; do
      [ -e "$f" ] || continue
      case " $WYJATKI " in *" $f "*) continue;; esac
      base="${f%.md}"
      if ! printf '%s' "$MAPA" | grep -q "$base"; then echo "  ! niezmapowana: $f"; NIEZM=$((NIEZM+1)); fi
    done
    echo "$MISS $NIEZM"
  )
}

# ── RAPORT: werdykt WYPROWADZONY z liczb, nie postawiony obok (#34) ──
raport() {
  wynik="$(analiza "$1")"
  echo "$wynik" | sed '$d'                      # wszystko poza ostatnią linią = znaleziska
  licz="$(echo "$wynik" | tail -1)"
  MISS="${licz%% *}"; NIEZM="${licz##* }"
  if [ "$MISS" -eq 0 ] && [ "$NIEZM" -eq 0 ]; then
    echo "  OK straz duszy: mapa spojna z cialem (sciezki istnieja, ksiegi zmapowane)"
    return 0
  fi
  if [ "$MISS" -ne 0 ]; then
    echo "  ✗ MAPA KLAMIE: DUSZA wskazuje sciezki, ktorych nie ma na dysku."
    return 1
  fi
  echo "  ⚠ MAPA NIEPELNA: sciezki istnieja, ale niezmapowanych ksiag: $NIEZM (zmapuj albo dodaj do WYJATKI)"
  if [ "$SCISLE" -eq 1 ]; then return 1; fi
  return 0
}

# ── TOR TESTOWY (#38) ──
if [ "$TEST" -eq 1 ]; then
  echo "╔═══ STRAŻ DUSZY — AUTOTEST (#38) ═══╗"
  BAZA="$(mktemp -d)"
  # + zdrowy: mapa wskazuje istniejące pliki, każda księga zmapowana
  # dach narzedzia/silniki/ (29.08): mapa w fiksturze wskazuje ścieżkę pod dachem,
  # więc atrapa MUSI ją odtworzyć — plik położony płasko czynił „+ zdrowy" kłamiącym.
  mkdir -p "$BAZA/zdrowy/kanon/ksiegi" "$BAZA/zdrowy/narzedzia/silniki"
  printf 'DUSZA — mapa: `JADRO.md` i `narzedzia/silniki/kronos_v4.js`, cialo: `kanon/ksiegi/SPIS_CIALA.md`\n' > "$BAZA/zdrowy/DUSZA.md"
  : > "$BAZA/zdrowy/JADRO.md"; : > "$BAZA/zdrowy/narzedzia/silniki/kronos_v4.js"
  # ksiega obecna WYLACZNIE w spisie — po ciecu §IV to norma, nie wyjatek.
  # Bez niej mutacja zdejmujaca SPIS_CIALA z MAPY przechodzila SLEPO (#50).
  : > "$BAZA/zdrowy/TYLKO_W_SPISIE.md"
  printf '# SPIS CIALA\n- `JADRO.md`\n- `TYLKO_W_SPISIE.md`\n' > "$BAZA/zdrowy/kanon/ksiegi/SPIS_CIALA.md"
  # − mapa kłamie: DUSZA wskazuje plik, którego nie ma
  mkdir -p "$BAZA/klamie/kanon/ksiegi"
  printf 'DUSZA — mapa: `WIDMO.md`, cialo: `kanon/ksiegi/SPIS_CIALA.md`\n' > "$BAZA/klamie/DUSZA.md"
  printf '# SPIS CIALA\n' > "$BAZA/klamie/kanon/ksiegi/SPIS_CIALA.md"
  # ⊙ mapa niepełna: księga na dysku, nieobecna w DUSZY
  mkdir -p "$BAZA/niepelna/kanon/ksiegi"
  printf 'DUSZA — mapa: `JADRO.md`, cialo: `kanon/ksiegi/SPIS_CIALA.md`\n' > "$BAZA/niepelna/DUSZA.md"
  : > "$BAZA/niepelna/JADRO.md"; : > "$BAZA/niepelna/SIEROTA.md"
  # spis JEST, ale ODSTAJE — nie wymienia SIEROTY: dokladnie stan po dodaniu ksiegi
  # bez regeneracji. Straz ma to zlapac jako niepelnosc (drugi czytnik swiezosci).
  printf '# SPIS CIALA\n- `JADRO.md`\n' > "$BAZA/niepelna/kanon/ksiegi/SPIS_CIALA.md"
  # ⊙ wyjątek: księga z listy WYJATKI nie jest zarzutem
  mkdir -p "$BAZA/wyjatek/kanon/ksiegi"
  printf 'DUSZA — mapa: `JADRO.md`, cialo: `kanon/ksiegi/SPIS_CIALA.md`\n' > "$BAZA/wyjatek/DUSZA.md"
  : > "$BAZA/wyjatek/JADRO.md"; : > "$BAZA/wyjatek/README.md"
  printf '# SPIS CIALA\n- `JADRO.md`\n' > "$BAZA/wyjatek/kanon/ksiegi/SPIS_CIALA.md"
  # ⊗ brak spisu ciala = mapa ciala nie istnieje, MUSI oblac (nie milczec)
  mkdir -p "$BAZA/bezspisu"
  printf 'DUSZA — mapa: `JADRO.md`, cialo: `kanon/ksiegi/SPIS_CIALA.md`\n' > "$BAZA/bezspisu/DUSZA.md"
  : > "$BAZA/bezspisu/JADRO.md"

  # TEST + musi trafić w gałąź „OK", nie w miękkie ⚠ — samo rc=0 nie odróżnia tych dwóch.
  echo "── TEST + (mapa spójna, MUSI przejść gałęzią OK) ──"
  out_plus="$(raport "$BAZA/zdrowy")"; rc_plus=$?
  echo "$out_plus"
  case "$out_plus" in *"OK straz duszy"*) ;; *) rc_plus=99 ;; esac
  echo "── TEST − (mapa wskazuje widmo, MUSI oblać) ──";   raport "$BAZA/klamie";   rc_klam=$?
  echo "── TEST ⊙ (księga niezmapowana, miękko: rc=0) ──"; raport "$BAZA/niepelna"; rc_niep=$?
  echo "── TEST ⊙ (ta sama, --scisle: rc=1) ──"
  SCISLE=1; raport "$BAZA/niepelna" >/dev/null; rc_sc=$?; SCISLE=0
  echo "   rc(--scisle)=$rc_sc"
  echo "── TEST ⊙ (WYJATKI honorowane, MUSI przejść) ──";  raport "$BAZA/wyjatek";  rc_wyj=$?
  echo "── TEST ⊗ (BRAK SPIS_CIALA, MUSI oblać) ──";        raport "$BAZA/bezspisu" >/dev/null; rc_bez=$?
  echo "   rc(bez spisu)=$rc_bez"
  # TEST ⊗ (21.08.2026) — tryb `--liczba` musi PODAWAĆ sumę, nie stałą.
  # Powód: `straz_lintow.sh` zlicza naruszenia po liniach z ✗/⚠, a ta straż drukuje jedną
  # zbiorczą linię przy dowolnej liczbie niezmapowanych ksiąg — bez tego trybu jej licznik
  # w tamtej straży byłby stale równy 1. Tor sprawdza DWA katalogi o różnym długu:
  # stała przeszłaby przez jeden, nie przez oba.
  l_zdrowy="$(LICZBA=1 KAT="$BAZA/zdrowy" bash "$0" --liczba --kat "$BAZA/zdrowy" 2>/dev/null)"
  l_niepelna="$(bash "$0" --liczba --kat "$BAZA/niepelna" 2>/dev/null)"
  echo "   --liczba: zdrowy=$l_zdrowy niepelna=$l_niepelna"
  rc_licz=1
  [ "$l_zdrowy" = "0" ] && [ "$l_niepelna" -gt 0 ] 2>/dev/null && rc_licz=0
  rm -rf "$BAZA"
  echo
  if [ "$rc_plus" -eq 0 ] && [ "$rc_klam" -eq 1 ] && [ "$rc_niep" -eq 0 ] && [ "$rc_sc" -eq 1 ] \
     && [ "$rc_wyj" -eq 0 ] && [ "$rc_licz" -eq 0 ] && [ "$rc_bez" -eq 1 ]; then
    echo "✓ STRAŻ ŻYWA: obie deklarowane reguły mają tor, --scisle bramkuje drugą, WYJATKI działają,"
    echo "  a tryb --liczba podaje SUMĘ (zdrowy 0 · niepełna >0), nie stałą."
    exit 0
  fi
  echo "✗ STRAŻ MARTWA: rc_plus=$rc_plus rc_klam=$rc_klam rc_niep=$rc_niep rc_scisle=$rc_sc rc_wyj=$rc_wyj rc_liczba=$rc_licz rc_bezspisu=$rc_bez"
  exit 1
fi

# ── BIEG WŁAŚCIWY ──
# --liczba: SAMA suma naruszeń (MISS + NIEZM) na stdout, bez znalezisk i bez glifów.
# BLIZNA 21.08.2026: `straz_lintow.sh` (#61) zlicza naruszenia po LINIACH z ✗/⚠, a ta straż
# drukuje JEDNĄ zbiorczą linię przy dowolnej liczbie niezmapowanych ksiąg. Wpięcie jej tam
# bez tego trybu dałoby licznik stale równy 1 — pozór pokrycia nad rosnącym długiem.
# Przyrząd, który zna swoją liczbę, ma ją PODAWAĆ, a nie dawać się zgadywać z wyglądu wyjścia.
if [ "$LICZBA" -eq 1 ]; then
  wynik="$(analiza "${KAT:-$(cd "$(dirname "$0")/../.." && pwd)}")"
  licz="$(echo "$wynik" | tail -1)"
  echo $(( ${licz%% *} + ${licz##* } ))
  exit 0
fi
raport "${KAT:-$(cd "$(dirname "$0")/../.." && pwd)}"
exit $?
