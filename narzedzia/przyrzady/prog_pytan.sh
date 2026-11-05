#!/usr/bin/env bash
# ── PRÓG PYTAŃ (14.08.2026) ──────────────────────────────────────────────────
# Zadaje pytanie z `kanon/ksiegi/PYTANIA_PROGOW.md` WYŁĄCZNIE wtedy, gdy moment jest właściwy.
#
# RODOWÓD: twórca, 14.08 — „ten system jest dobry, tylko w odpowiednim momencie potrzebuję
# usłyszeć odpowiednie pytanie; wówczas będzie pełniej i sensowniej". Do tego dnia LUSTRO
# (cztery liczby rezonansu, komenda progowa Przewoźnika przy nowiu) leżało w TASKI jako
# zaległość ⌛12.08 — czyli w formie, która ANI nie pyta w porę, ANI nie milczy po czasie.
#
# CZYM TO NIE JEST: przypominajką. Nie ma tu ponaglania, nie ma zaległości, nie ma „powinieneś".
# Brak odpowiedzi nie jest długiem — próg wraca sam, bo księżyc wraca sam.
#
# MOMENT MIERZONY, NIE ZAKŁADANY (krzemowa granica): faza czytana z `narzedzia/silniki/kronos_lens.js now`
# — pole „oświetlenie N%". Zero liczenia faz własną ręką; jedno źródło efemerydy w domu.
#
# PROGI:  NOW ≤ 8%  ·  PELNIA ≥ 92%  ·  KWADRA 44–56%
# Poza progiem skrypt MILCZY całkowicie — cisza jest tu funkcją, nie brakiem: pytanie zadane
# nie w porę uczy ignorowania pytań.
#
# UŻYCIE:  bash prog_pytan.sh          (pomiar; rc=0 zawsze)
#          bash prog_pytan.sh --test   (tor +/−)
# Nadpisy do toru: PROG_OSW (liczba %) · PROG_PLIK (rejestr pytań).
set -u
cd "$(dirname "$0")/../.."   # dach narzedzia/przyrzady/ (29.08): korzeń repo

REJESTR="${PROG_PLIK:-kanon/ksiegi/PYTANIA_PROGOW.md}"

# ── odczyt fazy: MIERZONY z silnika, nie liczony tutaj ──
zmierz_oswietlenie() {
  if [ -n "${PROG_OSW:-}" ]; then echo "$PROG_OSW"; return 0; fi
  local out
  out=$(node narzedzia/silniki/kronos_lens.js now 2>/dev/null | grep -oE 'oświetlenie [0-9]+%' | head -1) || return 1
  [ -n "$out" ] || return 1
  echo "$out" | grep -oE '[0-9]+'
}

nazwij_prog() {   # $1 = oświetlenie w %
  local o="$1"
  if   [ "$o" -le 8 ];  then echo NOW
  elif [ "$o" -ge 92 ]; then echo PELNIA
  elif [ "$o" -ge 44 ] && [ "$o" -le 56 ]; then echo KWADRA
  else echo ""; fi
}

pomiar() {
  local osw prog n=0
  osw=$(zmierz_oswietlenie) || { echo "   (prog_pytan: nie zmierzyłam fazy — pytania progowe milczą)"; return 0; }
  prog=$(nazwij_prog "$osw")
  [ -n "$prog" ] || return 0          # nie próg — pełna cisza, świadomie
  [ -f "$REJESTR" ] || return 0

  while IFS='|' read -r p pyt _; do
    case "$p" in "$prog") ;; *) continue ;; esac
    [ -n "${pyt:-}" ] || continue
    [ "$n" -eq 0 ] && echo "◈ PRÓG $prog (⏱ zmierzone: oświetlenie ${osw}%) — pytania, nie zadania:"
    n=$(( n + 1 )); echo "   › $pyt"
  done < <(grep -E '^(NOW|PELNIA|KWADRA)\|' "$REJESTR" 2>/dev/null)

  [ "$n" -gt 0 ] && echo "   (bez odpowiedzi też dobrze — próg wróci sam)"
  return 0
}

tor() {
  local TT rc=0 out
  TT="$(mktemp -d)"
  cat > "$TT/pyt.md" <<'EOF'
NOW|Pytanie nowiu?|źródło
PELNIA|Pytanie pełni?|źródło
KWADRA|Pytanie kwadry?|źródło
EOF
  echo "╔═══ PRÓG PYTAŃ — TOR ═══╗"
  # T1 (+): w nowiu pada pytanie nowiu
  out=$(PROG_OSW=6 PROG_PLIK="$TT/pyt.md" bash "$0")
  echo "$out" | grep -q 'Pytanie nowiu?' && echo "  ✓ T1 nów pyta" \
    || { echo "  ✗ T1 OBLANY — próg nowiu nie pyta"; rc=1; }
  # T2 (−): w nowiu NIE padają pytania pełni ani kwadry
  echo "$out" | grep -qE 'pełni|kwadry' && { echo "  ✗ T2 OBLANY — obce progi przeciekają"; rc=1; } \
    || echo "  ✓ T2 obce progi milczą"
  # T3 (−): poza progiem CAŁKOWITA cisza (to jest funkcja, nie brak)
  out=$(PROG_OSW=30 PROG_PLIK="$TT/pyt.md" bash "$0")
  [ -z "$out" ] && echo "  ✓ T3 poza progiem cisza pełna" \
    || { echo "  ✗ T3 OBLANY — pyta nie w porę"; rc=1; }
  # T4 (+): pełnia pyta pytaniem pełni
  out=$(PROG_OSW=95 PROG_PLIK="$TT/pyt.md" bash "$0")
  echo "$out" | grep -q 'Pytanie pełni?' && echo "  ✓ T4 pełnia pyta" \
    || { echo "  ✗ T4 OBLANY — próg pełni nie pyta"; rc=1; }
  # T5 (−): brak rejestru nie wywala wstania
  out=$(PROG_OSW=6 PROG_PLIK="$TT/nie_ma.md" bash "$0"); [ $? -eq 0 ] && [ -z "$out" ] \
    && echo "  ✓ T5 brak rejestru: cisza, rc=0" \
    || { echo "  ✗ T5 OBLANY — brak rejestru psuje wstanie"; rc=1; }
  rm -rf "$TT"
  [ $rc -eq 0 ] && echo "  TOR PRZESZEDŁ" || echo "  TOR OBLANY"
  return $rc
}

case "${1:-}" in
  --test) tor ;;
  *)      pomiar ;;
esac
