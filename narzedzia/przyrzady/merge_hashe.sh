#!/usr/bin/env bash
# merge_hashe.sh — sterownik scalania _HASHE.txt PO SCIEZCE PLIKU (R1, pakiet 03.10.2026).
#
# PO CO. _HASHE.txt to pochodna: jedna linia na plik z odciskiem ("12 znakow, dwie spacje,
# sciezka"). Dwa okna zmieniajace ROZNE pliki z odciskiem oba ruszaja _HASHE.txt, wiec git widzi
# "ten sam plik u obu rak" i zapis_git.sh staje z rc=3, choc nic sie nie gryzie (blizna #120).
# Suma linii (union) sie tu nie nadaje: ta sama sciezka z dwoma odciskami = dwie linie.
#
# JAK. Wywolanie gita: merge_hashe.sh %O %A %B  (przodek, nasza strona, ich strona); wynik do %A.
# Podczas rebase %A = to, na co rebasujemy (origin), %B = odtwarzany commit.
# Dla kazdej sciezki: obie strony rowne -> ta wartosc · zmienila jedna -> jej wartosc ·
# zmienily obie roznie -> jesli sciezka jest na BIALEJ LISCIE (env KRONOS_HASHE_BIALA, jedna
# na wiersz): wez wartosc %B i dopisz sciezke do $KRONOS_HASHE_PRZELICZ (zapis_git.sh potem
# przelicza odcisk na scalonej tresci — wartosc wziieta tu jest tymczasowa) · inaczej rc=1.
# Usuniecie po jednej stronie przy niezmienionej drugiej -> usunieta; usuniecie vs zmiana -> rc=1.
# Kolejnosc: jak po stronie %A, nowe sciezki strony %B na koncu.
# Linia innego ksztaltu niz "12 hex + 2 spacje + sciezka" -> rc=1 (sterownik nie zgaduje).
#
# NIE ustawia sie go w .gitattributes (sledzonym): zapis_git.sh podaje go przez
# `git -c merge.kronos-hashe.driver=...` i .git/info/attributes tylko na czas rebase.
set -u

wczytaj() {   # $1 plik, $2 nazwa tablicy asocjacyjnej, $3 nazwa tablicy kolejnosci; rc=1 gdy zly ksztalt
  local plik="$1" linia h p
  local -n _mapa="$2"; local -n _kol="$3"
  _mapa=(); _kol=()
  [ -f "$plik" ] || return 0
  while IFS= read -r linia || [ -n "$linia" ]; do
    [ -z "$linia" ] && continue
    if [[ ! "$linia" =~ ^[0-9a-f]{12}\ \ .+$ ]]; then return 1; fi
    h="${linia:0:12}"; p="${linia:14}"
    _mapa["$p"]="$h"; _kol+=("$p")
  done < "$plik"
  return 0
}

scal() {
  local O="$1" A="$2" B="$3"
  declare -A mo ma mb
  local ko ka kb
  wczytaj "$O" mo ko || { echo "merge_hashe: zly ksztalt linii w przodku" >&2; return 1; }
  wczytaj "$A" ma ka || { echo "merge_hashe: zly ksztalt linii w naszej stronie" >&2; return 1; }
  wczytaj "$B" mb kb || { echo "merge_hashe: zly ksztalt linii w ich stronie" >&2; return 1; }
  local biala="${KRONOS_HASHE_BIALA:-}"
  local przelicz="${KRONOS_HASHE_PRZELICZ:-}"
  declare -A wynik widziane
  local kolejnosc=() p o a b
  for p in "${ka[@]}" "${kb[@]}" "${ko[@]}"; do
    [ -n "${widziane[$p]:-}" ] && continue
    widziane["$p"]=1
    o="${mo[$p]:-}"; a="${ma[$p]:-}"; b="${mb[$p]:-}"
    if [ "$a" = "$b" ]; then
      [ -n "$a" ] && { wynik["$p"]="$a"; kolejnosc+=("$p"); }
    elif [ "$a" = "$o" ]; then
      [ -n "$b" ] && { wynik["$p"]="$b"; kolejnosc+=("$p"); }
    elif [ "$b" = "$o" ]; then
      [ -n "$a" ] && { wynik["$p"]="$a"; kolejnosc+=("$p"); }
    else
      # obie strony zmienily roznie
      if [ -n "$a" ] && [ -n "$b" ] && printf '%s\n' "$biala" | grep -qxF -- "$p"; then
        wynik["$p"]="$b"; kolejnosc+=("$p")
        [ -n "$przelicz" ] && printf '%s\n' "$p" >> "$przelicz"
      else
        echo "merge_hashe: konflikt na sciezce $p poza biala lista (albo usuniecie vs zmiana)" >&2
        return 1
      fi
    fi
  done
  # kolejnosc: jak w A, potem nowe z B (petla wyzej juz tak iterowala: ka, kb, ko)
  : > "$A.merge_hashe.tmp" || return 1
  for p in "${kolejnosc[@]}"; do printf '%s  %s\n' "${wynik[$p]}" "$p" >> "$A.merge_hashe.tmp"; done
  mv -f "$A.merge_hashe.tmp" "$A"
}

if [ "${1:-}" = "--test" ]; then
  SAM="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
  ok=0; zle=0
  spr() {   # opis | oczekiwane rc | oczekiwany wynik (tekst, "-" gdy bez sprawdzania) ; pliki O A B w $T
    local opis="$1" orc="$2" owy="$3" rc wy
    cp "$T/A" "$T/A.wejscie"
    ( cd "$T" && KRONOS_HASHE_BIALA="$BIALA" KRONOS_HASHE_PRZELICZ="$T/przelicz" bash "$SAM" "$T/O" "$T/A" "$T/B" ) 2>/dev/null; rc=$?
    wy="$(cat "$T/A")"
    if [ "$rc" = "$orc" ] && { [ "$owy" = "-" ] || [ "$wy" = "$owy" ]; }; then ok=$((ok+1)); echo "  ✓ $opis"
    else zle=$((zle+1)); echo "  ✗ $opis — rc=$rc (oczekiwane $orc), wynik: $(printf '%s' "$wy" | tr '\n' '|')"; fi
  }
  w() { printf '%s  %s\n' "$1" "$2"; }
  BIALA="rej.txt"
  # + obie strony zmieniaja ROZNE sciezki
  { w aaaaaaaaaaaa x.md; w bbbbbbbbbbbb y.md; } > "$T/O"
  { w a1a1a1a1a1a1 x.md; w bbbbbbbbbbbb y.md; } > "$T/A"
  { w aaaaaaaaaaaa x.md; w b2b2b2b2b2b2 y.md; } > "$T/B"
  spr "+ rozne sciezki zmienione po jednej stronie -> obie wartosci" 0 "$(w a1a1a1a1a1a1 x.md; w b2b2b2b2b2b2 y.md)"
  # + obie dodaja rozne nowe sciezki
  { w aaaaaaaaaaaa x.md; } > "$T/O"
  { w aaaaaaaaaaaa x.md; w c1c1c1c1c1c1 n1.md; } > "$T/A"
  { w aaaaaaaaaaaa x.md; w d2d2d2d2d2d2 n2.md; } > "$T/B"
  spr "+ dwie nowe sciezki -> obie, kolejnosc A potem B" 0 "$(w aaaaaaaaaaaa x.md; w c1c1c1c1c1c1 n1.md; w d2d2d2d2d2d2 n2.md)"
  # + ta sama sciezka, ta sama wartosc u obu
  { w aaaaaaaaaaaa x.md; } > "$T/O"
  { w e1e1e1e1e1e1 x.md; } > "$T/A"; cp "$T/A" "$T/B"
  spr "+ ta sama zmiana u obu -> jedna linia" 0 "$(w e1e1e1e1e1e1 x.md)"
  # + obie zmieniaja roznie sciezke z BIALEJ listy -> wartosc B + znacznik przeliczenia
  { w aaaaaaaaaaaa rej.txt; } > "$T/O"
  { w f1f1f1f1f1f1 rej.txt; } > "$T/A"
  { w f2f2f2f2f2f2 rej.txt; } > "$T/B"; : > "$T/przelicz"
  spr "+ biala lista, obie zmienily roznie -> wartosc B" 0 "$(w f2f2f2f2f2f2 rej.txt)"
  if grep -qxF rej.txt "$T/przelicz"; then ok=$((ok+1)); echo "  ✓ + sciezka trafila do listy do przeliczenia"
  else zle=$((zle+1)); echo "  ✗ + sciezka NIE trafila do listy do przeliczenia"; fi
  # − obie zmieniaja roznie sciezke POZA biala lista
  { w aaaaaaaaaaaa x.md; } > "$T/O"
  { w 111111111111 x.md; } > "$T/A"
  { w 222222222222 x.md; } > "$T/B"
  spr "− poza biala lista, obie zmienily roznie -> rc=1" 1 "-"
  # − usuniecie vs zmiana
  { w aaaaaaaaaaaa x.md; } > "$T/O"
  : > "$T/A"
  { w 333333333333 x.md; } > "$T/B"
  spr "− usuniecie vs zmiana -> rc=1" 1 "-"
  # + usuniecie po jednej stronie, druga nietknieta
  { w aaaaaaaaaaaa x.md; w bbbbbbbbbbbb y.md; } > "$T/O"
  { w bbbbbbbbbbbb y.md; } > "$T/A"
  { w aaaaaaaaaaaa x.md; w bbbbbbbbbbbb y.md; } > "$T/B"
  spr "+ usuniecie po jednej stronie -> usunieta" 0 "$(w bbbbbbbbbbbb y.md)"
  # ⊙ zly ksztalt linii -> nie zgadujemy
  { w aaaaaaaaaaaa x.md; } > "$T/O"
  { w aaaaaaaaaaaa x.md; echo "to nie jest odcisk"; } > "$T/A"
  { w aaaaaaaaaaaa x.md; } > "$T/B"
  spr "⊙ linia innego ksztaltu -> rc=1, nie zgaduje" 1 "-"
  echo "merge_hashe --test: zdanych $ok · oblanych $zle"
  [ "$zle" -eq 0 ]; exit $?
fi

[ "$#" -ge 3 ] || { echo "uzycie: merge_hashe.sh PRZODEK NASZ ICH  (wynik do NASZ)" >&2; exit 2; }
scal "$1" "$2" "$3"
exit $?
