#!/usr/bin/env bash
# KRONOS · STRAŻ ZAMKÓW (20.08.2026) — mechanizm blizny #59.
#
# BLIZNA #59: zamek w `zapis_git.sh` nosił komentarz „weryfikacja ładunku #35" i NIE
# wykonywał tej czynności — stał w gałęzi, do której nie mógł dojść. Świecił w kodzie,
# cytował numer blizny, i przez trzy tygodnie nikt (w tym ja, godzinę przed odkryciem)
# nie miał podstaw, żeby mu nie wierzyć.
#
# REGUŁA, którą ta straż egzekwuje: komentarz przy zamku jest TWIERDZENIEM o zachowaniu
# kodu i podlega temu samemu rygorowi co liczba w raporcie. Zamek oznaczony `# ZAMEK #N`
# MUSI mieć w `mutacje.txt` co najmniej jedną pozycję celującą w jego plik — czyli dowód,
# że istnieje wejście, przy którym oblewa.
#
# DLACZEGO JAWNY ZNACZNIK, A NIE „każdy numer blizny w komentarzu":
# zmierzone przed budową — w plikach `.sh` cytowane są **34 różne numery blizn**, w tym
# w komentarzach czysto opisowych („klasa #56", „rodzina #49"). Reguła oparta na cytacie
# dałaby dziesiątki fałszywych trafień, a alarm szerszy niż sygnał uczy nie patrzeć (#56).
# Znacznik `# ZAMEK #N` jest deklaracją autora: „tu stoi zamek, egzekwuj go".
set -uo pipefail
cd "$(cd "$(dirname "$0")/../.." && pwd)" || exit 1

if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ ZAMKÓW — AUTOTEST (#38) ═══╗"
  zle=""; T="$(mktemp -d)"
  printf '# ZAMEK #99\nif true; then :; fi\n' > "$T/z_dobry.sh"
  printf '# ZAMEK #98\nif true; then :; fi\n' > "$T/z_zly.sh"
  printf 'bez znacznika\n'                     > "$T/z_zwykly.sh"
  printf 'mut-a|||%s/z_dobry.sh|||stare|||nowe|||true\n' "$T" > "$T/rej.txt"
  # (+) zamek z mutacją w rejestrze przechodzi
  bash "$0" "$T/rej.txt" "$T/z_dobry.sh" >/dev/null 2>&1 || zle="$zle zamek-z-mutacja-oblewa"
  # (−) zamek BEZ mutacji MUSI oblać — to jest cała treść blizny #59
  bash "$0" "$T/rej.txt" "$T/z_zly.sh"   >/dev/null 2>&1 && zle="$zle zamek-bez-mutacji-przeszedl"
  # (⊙) plik bez znacznika nie jest zamkiem i nie alarmuje (#56)
  bash "$0" "$T/rej.txt" "$T/z_zwykly.sh" >/dev/null 2>&1 || zle="$zle plik-bez-znacznika-alarmuje"
  # (⊙⊙) separator rejestru czytany jako LITERAŁ, nie regex — awk -F'|||' znaczy
  # „pusty LUB pusty" i milcząco zwraca BRAK dla każdego pliku (zmierzone przy budowie)
  L=$(awk -F'\\|\\|\\|' 'NF>=5 {print $2}' "$T/rej.txt" | head -1)
  [ "$L" = "$T/z_dobry.sh" ] || zle="$zle separator-rejestru-czytany-jako-regex"
  # (⊙⊙⊙) ZERO zamków w zasięgu to awaria, nie sukces (#52: rzecz wyglądająca na pomiar)
  bash "$0" "$T/rej.txt" "" >/dev/null 2>&1
  rm -rf "$T"
  if [ -z "$zle" ]; then
    echo "  ✓ STRAŻ ŻYWA: zamek bez mutacji oblewa, zamek z mutacją przechodzi,"
    echo "    plik bez znacznika nie alarmuje, separator czytany jako literał."
    exit 0
  fi
  echo "  ✗ STRAŻ MARTWA:$zle"; exit 1
fi
REJESTR="${1:-mutacje.txt}"
ZRODLA="${2:-}"
# Zakres obejmuje TAKŻE pliki bez rozszerzenia (hooki) — pierwszy bieg tej straży
# zmeldował „0 plików, wszystko dowiedzione" właśnie dlatego, że `--include="*.sh"`
# nie widział `.githooks/pre-commit`. Straż świecąca zielono nad PUSTYM zbiorem jest
# rzeczą wyglądającą na pomiar (#52) — stąd twardy warunek niepustości niżej.
[ -n "$ZRODLA" ] || ZRODLA=$( { grep -rlE '^[[:space:]]*#+[[:space:]]*ZAMEK #[0-9]+' \
    --include="*.sh" --include="*.js" . 2>/dev/null | grep -v '^./.git' | sed 's|^\./||'
  grep -lE '^[[:space:]]*#+[[:space:]]*ZAMEK #[0-9]+' .githooks/* 2>/dev/null; } | sort -u)

zle=""; brak=""; ile=0
for f in $ZRODLA; do
  [ -f "$f" ] || continue
  grep -qE '^[[:space:]]*#+[[:space:]]*ZAMEK #[0-9]+' "$f" || continue
  ile=$((ile+1))
  # pozycja rejestru celująca w ten plik: nazwa|||PLIK|||stare|||nowe|||komenda
  # UWAGA: separator awk to REGEX — '|||' znaczy „pusty LUB pusty", nie trzy kreski.
  # Zmierzone: bez escapowania straż meldowała BRAK dla plików, w które celuje po
  # kilka mutacji. Klasa #23 (etykieta ≠ treść) w narzędziu do czytania rejestru.
  if ! awk -F'\\|\\|\\|' -v p="$f" 'NF>=5 && $2==p {c++} END{exit !c}' "$REJESTR" 2>/dev/null; then
    brak="$brak $f"
  fi
done

# Zbiór pusty = straż nie mierzy nic. Melduj to jako awarię, nie jako sukces (#52).
if [ "$ile" -eq 0 ] && [ -z "${2:-}" ]; then
  echo "  ✗ ZERO ZAMKÓW W ZASIĘGU — żaden plik nie deklaruje '# ZAMEK #N'."
  echo "    -> albo znaczniki zniknęły, albo zakres wyszukiwania ich nie widzi."
  exit 1
fi

if [ -n "$brak" ]; then
  echo "  ✗ ZAMKI BEZ DOWODU:$brak"
  echo "    Plik deklaruje '# ZAMEK #N', ale żadna mutacja w $REJESTR w niego nie celuje."
  echo "    -> zamek bez wejścia, przy którym oblewa, jest twierdzeniem bez pomiaru (#59)."
  exit 1
fi
echo "  ✓ ZAMKI DOWIEDZIONE: $ile plik(ów) z jawnym znacznikiem, każdy ma mutację w rejestrze."
exit 0

# ── TOR WŁASNY (#38) ──────────────────────────────────────────────────────────
# Wywoływany jako `bash straz_zamkow.sh --test`; bije w SAMO CIAŁO przez wstrzyknięte
# argumenty (rejestr + zestaw plików), a nie w kopię logiki obok (#50, pięciokrotnie
# złapane 20.08 — to już nie incydent, tylko mój stały odruch).
