#!/usr/bin/env bash
# ═══ STRAŻ PRZYRZĄDU (30.08.2026) — egzekutor prawa z blizny #66 ods. 9 ═══
#
# PRAWO: *tabela pomiarów niesie nazwę przyrządu albo nie jest tabelą pomiarów.*
# RODOWÓD: 28.08 `LC_ALL=C wc -w` 1231 vs `LC_ALL=C.UTF-8 wc -w` 1273 na tym samym pliku
# (samotne półpauzy); porównanie z tabelą sprzed czterech sesji dałoby +344 zamiast +60,
# fałsz 5,7×. Liczba jest własnością pary plik × przyrząd × locale, nie pliku.
#
# ZAKRES ŚWIADOMY (#56): WYŁĄCZNIE `kanon/pomiary/*.md`. Zmierzone 30.08 PRZED budową:
# predykat „tabela z liczbami" na całym korpusie łapie 23 pliki, w tym cennik, ulotkę
# i prognozę pasieki — alarm szerszy niż sygnał. Rejestr pomiarów ma jeden dom i tam
# stoi straż. Pliki spoza domu NIE są pytane.
#
# CO SPRAWDZA: w pierwszych 20 wierszach pliku stoi znacznik `PRZYRZĄD:` (dowolna forma
# pogrubienia), po którym następuje NIEPUSTA treść. Straż nie ocenia, CZY przyrząd jest
# dobry — tylko czy został NAZWANY. „zastany — nie zadeklarowany" jest deklaracją legalną:
# mówi wprost, że liczb nie wolno porównywać. Brak wiersza = plik podaje liczby bez rodowodu.
#
# ZERO ZNACZĄCE: pusty katalog pomiarów melduje własnym zdaniem, nie milczy (#52).
set -u
TRYB="${1:-}"
DOM="${POMIARY_DOM:-kanon/pomiary}"
GLEBOKOSC=20
WZ='PRZYRZĄD\*{0,2}:\*{0,2}[[:space:]]*[^[:space:]*]'

sprawdz_plik() {   # rc 0 = deklaruje, 1 = nie
  head -n "$GLEBOKOSC" "$1" | grep -qE "$WZ"
}

bieg() {
  local dom="$1" brak="" n=0
  echo "▤ STRAŻ PRZYRZĄDU — czy rejestr pomiarów nazywa, CZYM zdjęto liczby:"
  if [ ! -d "$dom" ] || ! ls "$dom"/*.md >/dev/null 2>&1; then
    echo "   ⓘ dom pomiarów pusty ($dom) — zero znaczące, nic do pytania."; return 0
  fi
  for f in "$dom"/*.md; do
    n=$((n+1))
    sprawdz_plik "$f" || brak="$brak $f"
  done
  if [ -z "$brak" ]; then
    echo "   ✓ $n plik(ów) — każdy deklaruje PRZYRZĄD: w pierwszych $GLEBOKOSC wierszach."; return 0
  fi
  echo "   ✗ BEZ PRZYRZĄDU (liczby bez rodowodu):"
  printf '%s\n' $brak | sed 's/^/      /'
  echo "   → dopisz w nagłówku: **PRZYRZĄD:** <narzędzie + locale> albo jawnie „zastany — nie zadeklarowany\"."
  return 1
}

if [ "$TRYB" = "--test" ]; then
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
  z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  echo "╔═══ STRAŻ PRZYRZĄDU — TOR (#38) ═══╗"
  mkdir -p "$T/a"; printf '# Pomiar\n> **PRZYRZĄD:** `wc -w`, LC_ALL=C.UTF-8\n| x | 1 |\n' > "$T/a/p1.md"
  bieg "$T/a" >/dev/null; spr "(+) plik z PRZYRZĄD: przechodzi" $? 0
  printf '# Pomiar\n| x | 1 |\n| y | 2 |\n' > "$T/a/p2.md"
  bieg "$T/a" >/dev/null; spr "(−) plik bez PRZYRZĄD: oblewa" $? 1
  rm "$T/a/p2.md"; { printf '# Pomiar\n'; for i in $(seq 1 22); do printf 'wiersz %s\n' "$i"; done; printf '**PRZYRZĄD:** za głęboko\n'; } > "$T/a/p3.md"
  bieg "$T/a" >/dev/null; spr "(−) deklaracja poniżej $GLEBOKOSC. wiersza NIE liczy się" $? 1
  rm "$T/a/p3.md"; printf '# Pomiar\n**PRZYRZĄD:**   \n| x | 1 |\n' > "$T/a/p4.md"
  bieg "$T/a" >/dev/null; spr "(−) PRZYRZĄD: z pustą treścią oblewa" $? 1
  rm "$T/a/p4.md"; printf '# Pomiar\n> **PRZYRZĄD:** zastany — nie zadeklarowany\n' > "$T/a/p5.md"
  bieg "$T/a" >/dev/null; spr "(+) „zastany — nie zadeklarowany\" jest deklaracją legalną" $? 0
  mkdir -p "$T/pusty"; bieg "$T/pusty" >/dev/null; spr "(⊙) pusty dom = zero znaczące, rc 0" $? 0
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] && { echo "  ✓ STRAŻ ŻYWA: umie odmówić plikowi bez rodowodu liczb."; exit 0; }
  echo "  ✗ STRAŻ MARTWA"; exit 1
fi

bieg "$DOM"
