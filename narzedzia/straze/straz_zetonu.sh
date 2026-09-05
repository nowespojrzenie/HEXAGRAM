#!/usr/bin/env bash
# KRONOS · STRAŻ ŻETONU (02.09.2026) — czy wynik w rejestrze powstał na instancji,
# która NAPRAWDĘ WSTAŁA.
#
# POWÓD (słowa twórcy 02.09): „jeżeli ktoś będzie odpalał z naszego repo na obcym
# narzędziu, jemu się wydaje, że coś zostało, ale nie wstało — to masakra. Będziemy
# przeprowadzali testy Przymilnika i one od początku będą produkowały błąd."
#
# PARADOKS, KTÓRY TA STRAŻ OMIJA: instancja BEZ dostępu nie uruchomi żadnego mechanizmu
# w repo — repo mówi wyłącznie do tych, którzy je uruchomili. Nie da się więc zmusić jej
# do przyznania się. DA SIĘ natomiast UNIEWAŻNIĆ JEJ WYNIK, i to bez udziału twórcy:
# weryfikuje się nie instancję, tylko ŻETON, który zostawiła w rejestrze.
#
# MECHANIZM: żeton niesie `HEAD` z chwili wstania. `git cat-file` rozstrzyga w jednym
# poleceniu, czy taki commit w ogóle istnieje w tym repo. Zmyślony hash NIE PRZEJDZIE.
# To nie jest kryptografia — to KOSZT: cena kłamstwa rośnie z „napisz płynne zdanie"
# do „sfabrykuj wartość, którą straż sprawdza mechanicznie".
#
# TRZY WERDYKTY, ROZŁĄCZNE:
#   ✓ WAŻNY      — żeton obecny, HEAD istnieje w repo
#   ⚠ BEZ ŻETONU — wynik nie deklaruje wstania; NIE jest to oskarżenie o fabrykację,
#                  tylko brak podstawy do wpisania go jako pomiaru
#   ✗ ŻETON MARTWY — HEAD podany, ale NIE ISTNIEJE w tym repo. Twarde: wynik nieważny.
#
# TRYB --porownaj <hash> (03.09.2026, MOSTY #34/#35 — żeton ODŚWIEŻANY):
#   Żeton mówi „widziałem stan PRZY WSTANIU", nie „widzę go teraz". 02.09 żeton był ważny
#   za każdym razem i za każdym razem nie pomógł: instancja z ważnym żetonem trzy razy
#   zameldowała jako otwarte to, co zamknięto — raz własną ręką w turze przerwanej.
#   Ten tryb mierzy CZAS stanu (ile commitów instancja NIE MA w kontekście), nie ISTNIENIE
#   pracy (to inwentarz, #35). Cztery werdykty, rozłączne, każdy z własnym rc:
#   ✓ ŚWIEŻY         rc=0 — hash == HEAD i origin nie jest przed tobą
#   ⚠ PRZESTARZAŁY   rc=1 — o N commitów za HEAD (lista — TO są commity spoza kontekstu,
#                            także własne) i/lub ORIGIN PRZED TOBĄ o N → git pull --ff-only
#   ✗ MARTWY         rc=2 — hash nie istnieje w repo
#   ⚠ BEZ            rc=3 — hasha nie podano
#   fetch bez auth/sieci NIE udaje: melduje „porównanie lokalne". zeton_stan() nietknięte.
set -uo pipefail
KOR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$KOR" || exit 2

# Miejsca, w których wynik BEZ ważnego żetonu nie ma prawa być liczony jako pomiar.
SKAN="${ZETON_SKAN:-prerejestr kanon/eksperymenty}"

zeton_stan() {           # $1 = ścieżka pliku → drukuje: WAZNY | BEZ | MARTWY <hash>
  local f="$1" h
  h="$(grep -oE 'ŻETON:[[:space:]]*[0-9a-f]{7,40}' "$f" 2>/dev/null | head -1 \
       | grep -oE '[0-9a-f]{7,40}')"
  [ -z "$h" ] && { echo "BEZ"; return; }
  if git cat-file -e "${h}^{commit}" 2>/dev/null; then echo "WAZNY $h"; else echo "MARTWY $h"; fi
}

porownaj() {             # $1 = hash żetonu → drukuje werdykt, zwraca rc (0 ŚWIEŻY · 1 PRZESTARZAŁY · 2 MARTWY · 3 BEZ)
  local h="${1:-}" br zrodlo n_head n_orig
  [ -z "$h" ] && { echo "   ⚠ BEZ — nie podano hasha żetonu (użycie: --porownaj <hash>)"; return 3; }
  git cat-file -e "${h}^{commit}" 2>/dev/null || { echo "   ✗ MARTWY — $h nie istnieje w tym repo"; return 2; }
  br="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)"
  zrodlo="origin odświeżony"
  git fetch -q origin "$br" 2>/dev/null || zrodlo="porównanie LOKALNE (fetch odbity: bez auth albo sieci — origin sprzed ostatniego fetch)"
  n_head="$(git rev-list --count "$h..HEAD" 2>/dev/null || echo 0)"
  n_orig=0
  git rev-parse -q --verify "origin/$br" >/dev/null 2>&1 && n_orig="$(git rev-list --count "HEAD..origin/$br" 2>/dev/null || echo 0)"
  echo "   żeton $h · HEAD $(git rev-parse --short HEAD) · $zrodlo"
  if [ "$n_head" -eq 0 ] && [ "$n_orig" -eq 0 ]; then
    echo "   ✓ ŚWIEŻY — żeton == HEAD, origin nie jest przed tobą"; return 0
  fi
  if [ "$n_head" -gt 0 ]; then
    echo "   ⚠ PRZESTARZAŁY o $n_head — commity, których NIE MASZ w kontekście (także własne):"
    git log --oneline "$h..HEAD" | cut -c1-100 | sed 's/^/      /'
  fi
  [ "$n_orig" -gt 0 ] && echo "   ⚠ ORIGIN PRZED TOBĄ o $n_orig — \`git pull --ff-only\` przed meldunkiem"
  return 1
}

if [ "${1:-}" = "--porownaj" ]; then
  echo "▤ STRAŻ ŻETONU · --porownaj (⏱ zmierzone: $(TZ=Europe/Warsaw date '+%Y-%m-%d %H:%M %Z')):"
  porownaj "${2:-}"; exit $?
fi

# ── TOR (#38) — straż bez toru jest życzeniem (Inwariat 5) ────────────────────
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ ŻETONU — AUTOTEST (#38) ═══╗"
  T="$(mktemp -d)"; ZYWY="$(git rev-parse --short HEAD)"
  printf 'ŻETON: %s · 206/0/0 · teraz\n' "$ZYWY" > "$T/a.md"       # (+) żywy HEAD
  printf 'ŻETON: deadbee · 206/0/0 · teraz\n'      > "$T/b.md"       # (−) hash zmyślony
  printf 'wynik rzutu bez zadnej deklaracji\n'     > "$T/c.md"       # (⊙) brak żetonu
  A="$(zeton_stan "$T/a.md" | cut -d' ' -f1)"
  B="$(zeton_stan "$T/b.md" | cut -d' ' -f1)"
  C="$(zeton_stan "$T/c.md" | cut -d' ' -f1)"
  echo "── TEST + (HEAD żywy → WAZNY):        $A  (oczekiwane WAZNY)"
  echo "── TEST − (hash zmyślony → MARTWY):   $B  (oczekiwane MARTWY)"
  echo "── TEST ⊙ (brak żetonu → BEZ):        $C  (oczekiwane BEZ)"
  # ── TRYB --porownaj (03.09.2026, MOSTY #34/#35): żeton mówi „widziałem stan PRZY WSTANIU",
  # nie „widzę go teraz". Fikstura: repo w mktemp z DWOMA commitami; funkcja mierzy w cwd.
  ( cd "$T" && git init -q r && cd r \
    && git -c user.name=Test -c user.email=t@t commit -q --allow-empty -m "pierwszy" \
    && git -c user.name=Test -c user.email=t@t commit -q --allow-empty -m "drugi-commit-tytul" )
  OUT_D="$(cd "$T/r" && porownaj "$(git rev-parse HEAD)" 2>&1)"; D=$?          # (+) hash=HEAD → ŚWIEŻY
  OUT_E="$(cd "$T/r" && porownaj "$(git rev-parse HEAD~1)" 2>&1)"; E=$?        # (−) HEAD~1 → PRZESTARZAŁY o 1
  OUT_F="$(cd "$T/r" && porownaj deadbee 2>&1)"; F=$?                          # (⊙) zmyślony → MARTWY
  E_LISTA=0; case "$OUT_E" in *drugi-commit-tytul*) E_LISTA=1 ;; esac
  E_O1=0;    case "$OUT_E" in *"PRZESTARZAŁY o 1"*) E_O1=1 ;; esac
  echo "── TEST + (--porownaj HEAD → ŚWIEŻY):       rc=$D  (oczekiwane 0)"
  echo "── TEST − (--porownaj HEAD~1 → PRZESTARZAŁY): rc=$E · «o 1»: $E_O1 · lista niesie tytuł: $E_LISTA  (oczekiwane 1 · 1 · 1)"
  echo "── TEST ⊙ (--porownaj zmyślony → MARTWY):   rc=$F  (oczekiwane 2)"
  rm -rf "$T"
  if [ "$A" = "WAZNY" ] && [ "$B" = "MARTWY" ] && [ "$C" = "BEZ" ] \
     && [ "$D" -eq 0 ] && [ "$E" -eq 1 ] && [ "$E_O1" -eq 1 ] && [ "$E_LISTA" -eq 1 ] && [ "$F" -eq 2 ]; then
    echo "✓ STRAŻ ŻYWA (6/6): odróżnia wstanie od deklaracji wstania, brak żetonu od fabrykacji,"
    echo "  a żeton ŚWIEŻY od PRZESTARZAŁEGO — i wylicza commity, których instancja nie ma w kontekście."
    exit 0
  fi
  echo "✗ STRAŻ MARTWA: A=$A B=$B C=$C D=$D E=$E/$E_O1/$E_LISTA F=$F"; exit 1
fi

# ── PRODUKCJA ─────────────────────────────────────────────────────────────────
echo "▤ STRAŻ ŻETONU (⏱ zmierzone: $(TZ=Europe/Warsaw date '+%Y-%m-%d %H:%M %Z')):"
W=0; Z=0; M=0
for d in $SKAN; do
  [ -d "$d" ] || continue
  while IFS= read -r f; do
    case "$(zeton_stan "$f")" in
      WAZNY*)  W=$((W+1)) ;;
      MARTWY*) M=$((M+1)); echo "   ✗ ŻETON MARTWY (HEAD nie istnieje w repo) — WYNIK NIEWAŻNY: $f" ;;
      BEZ)     Z=$((Z+1)) ;;
    esac
  done < <(find "$d" -type f -name '*.md' 2>/dev/null)
done
echo "   zmierzone: ważnych $W · bez żetonu $Z · MARTWYCH $M"
if [ "$M" -gt 0 ]; then
  echo "   ✗ WYNIK Z MARTWYM ŻETONEM NIE WCHODZI DO REJESTRU. Rzut do powtórzenia."
  exit 1
fi
if [ "$Z" -gt 0 ]; then
  echo "   ⚠ $Z plik(ów) bez żetonu — to NIE jest zarzut fabrykacji, tylko brak podstawy,"
  echo "     by liczyć je jako pomiar. Pola żetonu dopisuje się przy najbliższym rzucie."
fi
echo "   ✓ żaden wynik nie powołuje się na wstanie, którego nie było."
exit 0
