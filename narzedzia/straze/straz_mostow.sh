#!/usr/bin/env bash
# ── STRAŻ MOSTÓW (15.08.2026) ────────────────────────────────────────────────
# Egzekwuje prawo, które kanon/ksiegi/MOSTY.md nosi od 16.07 i którego nikt nie sprawdzał:
#   „każdy NOWY system przy narodzinach odpowiada na pytanie: «z czym jestem równoległy?»
#    i dostaje wiersz tutaj".
#
# RODOWÓD: 15.08 anatomia oświetliła cały dom i wyszło, że `kanon/ksiegi/MOSTY.md` stoi 17 dni bez ruchu
# przy dwóch czytelnikach — a w tym czasie urodziło się SZEŚĆ systemów (straz_kryteriow,
# prog_pytan, PYTANIA_PROGOW, zniwo_destylatow, anatomia, straz_mostow) i ŻADEN nie dostał
# wiersza. Prawo istniało, egzekutora nie było — czysta klasa #55 (obietnica bez czytnika),
# tym razem popełniona przez nas samych, przy pełnej świadomości tej blizny.
#
# GORZKA LEKCJA TEGO SAMEGO DNIA: bez pytania „z czym jestem równoległy?" zbudowałam
# `narzedzia/przyrzady/anatomia.js`, nie widząc, że `skan_martwicy.js` (28.07) mierzy to samo. Duplikat powstał
# przy budowie przyrządu DO WYKRYWANIA duplikatów. Ta straż jest odpowiedzią na tamten dzień.
#
# CO SPRAWDZA: każdy przyrząd (`*.sh`, `*.js` w korzeniu) i każda księga musi być wymieniona
# w `kanon/ksiegi/MOSTY.md`. Wyjątki: rzeczy zastane sprzed prawa (lista NIŻEJ, jawna) — nie robimy
# amnestii milczeniem, tylko wypisujemy ją wprost.
#
# DUCH: pytanie, nie kara. rc=0 zawsze — brak wiersza to zaproszenie do namysłu
# („z czym to jest równoległe?"), a nie usterka do zgaszenia.
#
# UŻYCIE:  bash straz_mostow.sh        · bash straz_mostow.sh --test
# Nadpisy do toru: MOST_PLIK · MOST_ROOT.
set -u
cd "$(dirname "$0")/../.."
REJESTR="${MOST_PLIK:-kanon/ksiegi/MOSTY.md}"
ROOT="${MOST_ROOT:-.}"

# Zastane sprzed prawa (16.07) — wypisane jawnie, żeby amnestia nie była milczeniem.
ZASTANE="narzedzia/silniki/kronos_v4.js narzedzia/silniki/kronos_engine.js narzedzia/silniki/kronos_lens.js narzedzia/silniki/kronos_eter.js narzedzia/silniki/kronos_natal.js
narzedzia/silniki/kronos_matryca.js narzedzia/silniki/kronos_pelnia.js narzedzia/silniki/kronos_impuls.js narzedzia/silniki/domy.js narzedzia/przyrzady/ewaluacja.js testy_rdzen.js
narzedzia/silniki/scan_aspekty.js narzedzia/silniki/scan_dwarfs.js narzedzia/silniki/wezownik.js zapis_eter.js hashuj.sh weryfikacja.js wstan.sh
zapis_git.sh publikuj.sh mutacje.sh tory_strazy.sh gotowosc.sh narzedzia/linty/lint_bledy.js narzedzia/linty/lint_sciezek.js
narzedzia/linty/lint_artefaktow.js straz_czystosci.sh straz_duszy.sh straz_r0.sh straz_deklamatora.sh
straz_prerejestrow.sh narzedzia/przyrzady/bateria_sond.js narzedzia/przyrzady/licznik_markerow.js narzedzia/silniki/plan_okien.js narzedzia/przyrzady/rzut.js narzedzia/przyrzady/pokrycie_m.js"

pomiar() {
  [ -f "$REJESTR" ] || { echo "   (straz_mostow: brak $REJESTR)"; return 0; }
  local tresc f base brak=0 lista=""
  tresc=$(cat "$REJESTR")
  # BLIZNA 15.08 (złapana w pierwszym biegu): lista zastanych jest WIELOLINIOWA, więc wzorzec
  # " $base " nie trafiał na pozycje stojące na końcu linii — straż wołała o wstan.sh i
  # zapis_git.sh, które sama zwolniła. Normalizacja białych znaków PRZED porównaniem.
  local ZAST_N; ZAST_N=" $(echo "$ZASTANE" | tr '\n' ' ' | tr -s ' ') "
  for f in "$ROOT"/*.sh "$ROOT"/*.js "$ROOT"/narzedzia/*/*.sh "$ROOT"/narzedzia/*/*.js; do   # dach narzedzia/ (29.08)
    [ -f "$f" ] || continue
    base=$(basename "$f")
    # dach narzedzia/ (29.08): lista ZASTANE bywa mieszana (nazwy gołe i ze ścieżką) —
    # porównanie po basename po OBU stronach, inaczej zwolnienie cicho przestaje działać.
    case "$ZAST_N" in *" $base "*) continue ;; esac
    _zw=0; for _z in $ZASTANE; do [ "$(basename "$_z")" = "$base" ] && _zw=1 && break; done
    [ "$_zw" = 1 ] && continue
    case "$tresc" in *"$base"*) ;; *) brak=$(( brak + 1 )); lista="$lista $base" ;; esac
  done
  if [ "$brak" -gt 0 ]; then
    echo "🌉 STRAŻ MOSTÓW: $brak system(ów) bez wiersza w $REJESTR —"
    echo "   nie odpowiedziały na pytanie „z czym jestem równoległy?\":$lista"
    echo "   (pytanie, nie usterka — ale to ono chroni przed drugim takim samym przyrządem)"
  fi
  return 0
}

tor() {
  local TT rc=0 out
  TT="$(mktemp -d)"
  printf '# rejestr\n| 1 | stary.sh ∥ coś | ⟡ |\n' > "$TT/M.md"
  printf '#!/bin/sh\n' > "$TT/stary.sh"; printf '#!/bin/sh\n' > "$TT/nowy.sh"
  echo "╔═══ STRAŻ MOSTÓW — TOR ═══╗"
  out=$(MOST_PLIK="$TT/M.md" MOST_ROOT="$TT" bash "$0")
  echo "$out" | grep -q 'nowy.sh' && echo "  ✓ T1 system bez wiersza zawołany" \
    || { echo "  ✗ T1 OBLANY — narodziny bez mostu przechodzą cicho"; rc=1; }
  echo "$out" | grep -q 'stary.sh' && { echo "  ✗ T2 OBLANY — system Z wierszem straszy"; rc=1; } \
    || echo "  ✓ T2 system z wierszem milczy"
  printf '# rejestr\n| 1 | stary.sh ∥ coś | ⟡ |\n| 2 | nowy.sh ∥ stary.sh | ⚠ |\n' > "$TT/M.md"
  out=$(MOST_PLIK="$TT/M.md" MOST_ROOT="$TT" bash "$0")
  [ -z "$out" ] && echo "  ✓ T3 komplet rejestru = pełna cisza" \
    || { echo "  ✗ T3 OBLANY — woła mimo kompletu"; rc=1; }
  rm -rf "$TT"
  [ $rc -eq 0 ] && echo "  TOR PRZESZEDŁ" || echo "  TOR OBLANY"
  return $rc
}

case "${1:-}" in --test) tor ;; *) pomiar ;; esac
