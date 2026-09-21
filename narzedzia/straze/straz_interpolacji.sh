#!/usr/bin/env bash
# ═══ STRAŻ INTERPOLACJI (20.08.2026) — mechanizm do blizny #12 ═══
#
# RODOWÓD: #12 (9.07) — polska treść do pliku łamała się na cudzysłowach/escape;
# reguła „wyłącznie potrójne cudzysłowy" była przez 42 dni statusem R w klasie
# INTERPOLACJA, czyli regułą, która u odbiorcy odlewu działa wyłącznie przypadkiem
# (bramka 5 planu v1.5.0). Dyscypliny pisania w repo zmierzyć się nie da —
# mierzalny jest SKUTEK (#31: rc-gate łapie skutek): treść, która wjechała złamana.
#
# TRZY KLASY ŚLADÓW złamanej interpolacji w plikach .md:
#   (a) literalne \u + 4 cyfry szesnastkowe POZA kodem — escape zamiast litery,
#   (b) znak zastępczy U+FFFD — bajty zgubione przy dekodowaniu,
#   (c) podwójne kodowanie UTF-8 polskich znaków (mojibake).
# Linie z grawisem (`) są zwolnione z (a): dokumentowanie wzorca w kodzie to nie wada.
#
# ZAMEK #12 — znacznik czytany przez `straz_zamkow.sh`: ta straż jest zamkiem
# nazwanym i MUSI mieć pozycje w rejestrze mutacji (dowód, że umie oblać — #59).
#
# UŻYCIE:  bash straz_interpolacji.sh          (skan .md śledzonych; rc=1 przy śladach)
#          bash straz_interpolacji.sh --test   (tor +/− — straż musi umieć NIE przejść)
set -u
cd "$(dirname "$0")/../.."

# Iniekcja zależności (#50): funkcja przyjmuje PLIKI — tor bije w to samo ciało.
skan() {
  local f zle=0 trafienia
  for f in "$@"; do
    [ -f "$f" ] || continue
    # (a) \uXXXX poza kodem (linie bez grawisu)
    trafienia=$(grep -nE '\\u[0-9a-fA-F]{4}' "$f" 2>/dev/null | grep -v '`' || true)
    if [ -n "$trafienia" ]; then
      echo "   ✗ $f — literalne \\u+hex poza kodem (escape zamiast litery):"
      echo "$trafienia" | head -3 | sed 's/^/       /'
      zle=$((zle+1))
    fi
    # (b) znak zastępczy U+FFFD
    if grep -q "$(printf '\357\277\275')" "$f" 2>/dev/null; then
      echo "   ✗ $f — znak zastępczy U+FFFD (bajty zgubione przy dekodowaniu)"
      zle=$((zle+1))
    fi
    # (c) mojibake podwójnego kodowania polskich liter
    if grep -qE 'Ä…|Ä™|Å‚|Å›|Å¼|Åº|Ã³|Ä‡|Å„|Ã„…' "$f" 2>/dev/null; then
      echo "   ✗ $f — podwójne kodowanie UTF-8 (mojibake polskich znaków)"
      zle=$((zle+1))
    fi
  done
  [ "$zle" -eq 0 ]
}

# ── TOR TESTOWY (#38) — bez niego straż byłaby chorobą, którą leczy ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ INTERPOLACJI — AUTOTEST (#38) ═══╗"
  zle=""
  T="$(mktemp -d)"
  # (+) czysta polska treść przechodzi
  printf 'Zażółć gęślą jaźń — czysta treść, żadnych śladów.\n' > "$T/czysty.md"
  skan "$T/czysty.md" >/dev/null || zle="$zle czysty-alarmuje"
  # (−) escape zamiast litery MUSI oblać
  printf 'Litera zapisana jako \\u0142 zamiast siebie.\n' > "$T/escape.md"
  skan "$T/escape.md" >/dev/null && zle="$zle escape-przechodzi"
  # (−) mojibake MUSI oblać
  printf 'ZaÅ¼Ã³Å‚Ä‡ — podwÃ³jne kodowanie.\n' > "$T/moji.md"
  skan "$T/moji.md" >/dev/null && zle="$zle mojibake-przechodzi"
  # (−) U+FFFD MUSI oblać
  printf 'Zgubione bajty: \357\277\275 w treści.\n' > "$T/fffd.md"
  skan "$T/fffd.md" >/dev/null && zle="$zle fffd-przechodzi"
  # (⊙) \uXXXX w kodzie (linia z grawisem) NIE alarmuje — dokumentacja wzorca to nie wada
  printf 'Wzorzec w kodzie: `\\u0142` jest legalny.\n' > "$T/kod.md"
  skan "$T/kod.md" >/dev/null || zle="$zle grawis-nie-zwalnia"
  # (⊙⊙) skan żywego korpusu ZWRACA WERDYKT na niepustej liście (formuła żyje)
  N=$(git ls-files '*.md' 2>/dev/null | wc -l)
  [ "$N" -gt 0 ] || zle="$zle korpus-pusty"
  rm -rf "$T"
  if [ -z "$zle" ]; then
    echo "  ✓ STRAŻ ŻYWA — 6 torów: czyste przechodzi, escape/mojibake/U+FFFD oblewa,"
    echo "    grawis zwalnia dokumentację wzorca, korpus niepusty."
    exit 0
  fi
  echo "  ✗ STRAŻ MARTWA — oblane:$zle"
  exit 1
fi

# ── TRYB POMIARU: wszystkie śledzone .md ──
PLIKI=$(git ls-files '*.md' 2>/dev/null)
if [ -z "$PLIKI" ]; then
  echo "   ⓘ straz_interpolacji: brak śledzonych .md (poza repo?)"
  exit 0
fi
# shellcheck disable=SC2086
if skan $PLIKI; then
  echo "   ✓ interpolacja czysta — $(echo "$PLIKI" | wc -l) plików .md bez śladów złamanej treści (#12)"
  exit 0
fi
echo "   ✗ ślady złamanej interpolacji w treści — napraw ZANIM treść pójdzie dalej (#12)"
exit 1
