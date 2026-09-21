#!/usr/bin/env bash
# ═══ STRAŻ WYWOŁAŃ (30.08.2026) — mechanizm blizny #79 ═══
#
# PRAWO (#79): *zielony tor nie dowodzi, że produkcja ma dostęp do mechanizmu.*
# RODOWÓD: 29.08 `zamek_zakresu` został zdefiniowany WEWNĄTRZ bloku `--test` w `publikuj.sh`
# i wołany w ścieżce głównej. Tor był zielony, bo uruchamiał się w tym samym bloku, w którym
# mieszkała definicja. Produkcja padła dopiero na pełnym biegu: `zamek_zakresu: command not found`.
# 52 tory, 128 mutacji, pięć bramek i `--test` rc=0 — wszystko zielone nad tą wadą przez dobę.
#
# CO SPRAWDZA: funkcja zdefiniowana WYŁĄCZNIE wewnątrz bloku `--test` nie może być wołana
# poza nim. Odwrotność (definicja poza, użycie w torze) jest legalna i NIE jest pytana.
#
# ZAKRES ŚWIADOMY (#56): pliki `.sh` śledzone przez gita, bez `keep_import`. Zmierzone
# PRZED budową sondą na żywym korpusie: 35 plików, **1 trafienie i było FAŁSZYWE**
# (`npm run outer` w komentarzu `straz_dojrzalosci` wyglądało jak wywołanie funkcji `run`).
# Stąd dwa zawężenia predykatu, oba wymuszone pomiarem, nie przewidywaniem:
#   nazwa musi stać na POZYCJI KOMENDY (początek linii albo po `;`, `&&`, `||`, `(`),
#       a nie gdziekolwiek w zdaniu — to jedno zawężenie wystarcza.
# ODRZUCONY DRUGI FILTR (30.08, zmierzone testem mutacyjnym): osobny warunek „linia komentarza
# nie jest użyciem" był MARTWYM KODEM — mutacja zdejmująca go wyszła ŚLEPA, bo warunek pozycji
# komendy odrzuca komentarz sam (po `#` nazwa nigdy nie stoi na pozycji komendy). Kod bez efektu
# w straży jest gorszy niż jego brak: wygląda jak druga linia obrony i fałszuje poczucie pokrycia.
# Po zawężeniu: 0 trafień na żywym korpusie — zamek wchodzi na czysto (jak #12), pilnuje
# przyszłości, nie karze zastanego.
set -u
TRYB="${1:-}"

skan() {   # $1 = katalog roboczy; wypisuje "plik:funkcja:linia", rc 1 gdy cokolwiek znalazł
  local dir="$1" f wynik=""
  cd "$dir" || return 0
  for f in $(git ls-files '*.sh' 2>/dev/null | grep -v keep_import); do
    [ -f "$f" ] || continue
    wynik="$wynik$(awk '
      # HEREDOC NIE JEST KODEM (30.08.2026): fikstury tej straży wpisują atrapę skryptu
      # przez `cat <<EOF`, a atrapa MUSI nieść literalne `--test` i `fi`. Przy skanie ŻYWEGO
      # repo te linie czytały się jak kod produkcyjny: zagnieżdżony `fi` z atrapy zamykał
      # blok toru w połowie, więc helper `spr` wyglądał na używany poza torem i straż
      # ALARMOWAŁA NA SAMEJ SOBIE (klasa #51 — dane fikstury zdradzają się w skanie repo).
      # Rozbicie literałów w atrapie zabijało fiksturę; poprawka należy do SKANU.
      /<<-?[ \t]*['\''"]?[A-Za-z_][A-Za-z_0-9]*['\''"]?[ \t]*$/ {
        if (match($0, /<<-?[ \t]*['\''"]?[A-Za-z_][A-Za-z_0-9]*/)) {
          hd=substr($0, RSTART, RLENGTH); sub(/^<<-?[ \t]*/,"",hd); gsub(/['\''"]/,"",hd); inhd=1
        }
      }
      inhd { if ($0 == hd) { inhd=0 }; wtest[NR]=intest; L[NR]="#heredoc"; next }
      /^[[:space:]]*if \[ "\$\{?(1:-|TRYB)\}?" ?= ?"--test"/ { intest=1 }
      intest && /^(fi|done|esac)([ \t;]|$)/ { intest=0; wtest[NR]=1; L[NR]=$0; next }   # UWAGA: POSIX awk NIE zna \b (#47) — granica wypisana klasą
      { wtest[NR]=intest; L[NR]=$0 }
      END {
        for (i=1;i<=NR;i++) {
          if (match(L[i], /^[[:space:]]*[A-Za-z_][A-Za-z_0-9]*\(\)[[:space:]]*\{/)) {
            n=L[i]; sub(/^[[:space:]]*/,"",n); sub(/\(\).*/,"",n)
            if (wtest[i]) { deft[n]=1 } else { defp[n]=1 }
          }
        }
        for (n in deft) {
          if (n in defp) continue
          for (i=1;i<=NR;i++) {
            if (wtest[i]) continue
            l=L[i]
            if (l ~ ("(^|;|&&|\\|\\||\\()[[:space:]]*" n "([[:space:]]|;|$|\\|)")) \
              printf "%s:%s:%d\n", FILENAME, n, i
          }
        }
      }' "$f")"
    [ -n "$wynik" ] && wynik="$wynik
"
  done
  printf '%s' "$wynik" | grep -v '^$' || true
  [ -z "$(printf '%s' "$wynik" | grep -v '^$')" ] && return 0
  return 1
}

if [ "$TRYB" = "--test" ]; then
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
  z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  echo "╔═══ STRAŻ WYWOŁAŃ — TOR (#38) ═══╗"
  export GIT_AUTHOR_NAME=S GIT_AUTHOR_EMAIL=s@s GIT_COMMITTER_NAME=S GIT_COMMITTER_EMAIL=s@s
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  ( cd "$T" && git init -q . )
  # (−) ZNANY POZYTYW: odtworzona wada z publikuj.sh 29.08
  cat > "$T/zly.sh" <<'EOF'
if [ "${1:-}" = "--test" ]; then
  zamek() { return 0; }
  zamek "x"
fi
zamek "produkcja"
EOF
  ( cd "$T" && git add -A && git commit -qm x )
  ( skan "$T" >/dev/null ); spr "(−) definicja w --test, użycie w produkcji — ŁAPIE" $? 1
  # (+) ZNANY NEGATYW 1: definicja poza torem, użycie w obu — legalne
  cat > "$T/dobry.sh" <<'EOF'
zamek() { return 0; }
if [ "${1:-}" = "--test" ]; then
  zamek "x"
fi
zamek "produkcja"
EOF
  rm "$T/zly.sh"; ( cd "$T" && git add -A && git commit -qm y )
  ( skan "$T" >/dev/null ); spr "(+) definicja poza torem — przechodzi" $? 0
  # (⊙) ZNANY NEGATYW 2: funkcja tylko w torze i używana tylko w torze
  cat > "$T/dobry.sh" <<'EOF'
if [ "${1:-}" = "--test" ]; then
  pomoc() { return 0; }
  pomoc "x"
fi
echo koniec
EOF
  ( cd "$T" && git add -A && git commit -qm z )
  ( skan "$T" >/dev/null ); spr "(⊙) funkcja żyje i umiera w torze — nie pytamy" $? 0
  # (⊙) ZNANY NEGATYW 3: nazwa w KOMENTARZU poza torem (fałszywy pozytyw zmierzony 30.08)
  cat > "$T/dobry.sh" <<'EOF'
if [ "${1:-}" = "--test" ]; then
  run() { return 0; }
  run "x"
fi
#   run "produkcja"   <- tak wygladalo wywolanie przed naprawa (cytat w komentarzu)
echo koniec
EOF
  ( cd "$T" && git add -A && git commit -qm k )
  ( skan "$T" >/dev/null ); spr "(⊙) nazwa w komentarzu NIE jest użyciem (#56)" $? 0
  # (⊙) ZNANY NEGATYW 4: nazwa w środku zdania, nie na pozycji komendy
  cat > "$T/dobry.sh" <<'EOF'
if [ "${1:-}" = "--test" ]; then
  run() { return 0; }
  run "x"
fi
echo "npm run outer"
EOF
  ( cd "$T" && git add -A && git commit -qm p )
  ( skan "$T" >/dev/null ); spr "(⊙) nazwa w środku zdania nie jest wywołaniem" $? 0
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] && { echo "  ✓ STRAŻ ŻYWA: łapie mechanizm zamknięty w torze, milczy na cytaty."; exit 0; }
  echo "  ✗ STRAŻ MARTWA"; exit 1
fi

KORZEN="$(cd "$(dirname "$0")/../.." && pwd)"
echo "▤ STRAŻ WYWOŁAŃ (#79) — czy produkcja ma dostęp do tego, co woła:"
OUT="$(skan "$KORZEN")"; RC=$?
if [ "$RC" -eq 0 ]; then
  echo "   ✓ żadna funkcja zdefiniowana w bloku --test nie jest wołana w ścieżce głównej."
  exit 0
fi
echo "   ✗ MECHANIZM ZAMKNIĘTY W TORZE (plik : funkcja : linia użycia):"
printf '%s\n' "$OUT" | sed 's/^/      /'
echo "   → przenieś definicję do ciała skryptu; tor mierzy wtedy to samo ciało co produkcja."
exit 1
