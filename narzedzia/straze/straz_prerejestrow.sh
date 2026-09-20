#!/usr/bin/env bash
# STRAŻ PREREJESTRÓW (13.08.2026) — egzekutor dla pól DATY ODCZYTU / KRYTERIUM ŚMIERCI.
#
# PO CO: prerejestr bez egzekutora to obietnica, nie zobowiązanie. Odczyt #006 spóźnił się
# 16 h nie dlatego, że data była nieznana — tylko dlatego, że NIKT JEJ NIE CZYTAŁ. Pole
# istniało (`DATY ODCZYTU:`, `DEATH CRITERION:`), brakowało czytelnika przy wstaniu.
#
# CO ROBI: znajduje w prerejestr/*.md AKAPITY z frazą nośnika i porównuje wszystkie daty
# z tego akapitu z dniem ZMIERZONYM. Świeci: ⚠ po terminie · ◆ w oknie 7 dni.
#
# DLACZEGO AKAPIT, NIE `fraza[^0-9]*data` — BLIZNA 11.08 przejęta ze straz_destylatow.sh:
# między frazą a datą stoi tekst z cyfrą, więc [^0-9]* urywa się i straż mówi „nic do
# pilnowania" nad pełnym rejestrem. DZIAŁA I KŁAMIE. Akapit (awk RS="") jest odporny.
#
# UŻYCIE: bash straz_prerejestrow.sh          (pomiar na żywej materii)
#         bash straz_prerejestrow.sh --test   (tor +/− — straż musi umieć NIE przejść)
set -u
cd "$(dirname "$0")/../.."

KATALOG="prerejestr"
FRAZY='DATY ODCZYTU|DEATH CRITERION|KRYTERIUM ŚMIERCI|KRYTERIUM SMIERCI|DATA DECYZJI'

# dd.mm.rrrr -> rrrr-mm-dd (porównanie leksykalne, bez `date -d`: przenośne)
na_iso() { echo "$1" | awk -F. '{printf "%s-%s-%s", $3, $2, $1}'; }

# Zwraca unikalne daty z AKAPITÓW niosących którąkolwiek z fraz nośnika.
# FILTR METRYCZKI (13.08, znaleziony w pierwszym biegu na żywej materii): akapit niesie też
# daty MÓWIĄCE O SOBIE — „RATYFIKOWANY 09.08", „Zapisany 09.08 ~20:30", „dopisane 11.08".
# To są znaczniki powstania rekordu, nie terminy do dotrzymania. Bez tego filtru straż
# świeciła ⚠ na dacie własnej ratyfikacji — a straż krzycząca na szum zostaje wyciszona
# przez człowieka i przestaje chronić cokolwiek. Linie metryczkowe wypadają PRZED zbiórką dat.
# TRZON ASCII 03.09.2026 (blizna #80): końcówki metryczek są ASCII — zmierzone na żywym
# korpusie: RATYFIKOWANA/E/Y/CH · USTALON/E/Y · Zapisana/e/ie. Klasa z polskimi literami
# rozpadała się pod locale C na bajty; `[A-Za-z]*` daje ten sam wynik niezależnie od locale.
# ROZSZERZENIE 03.09.2026 (korekta twórcy, #010 rozłożony): `USTALONE` dołącza do metryczek.
# PARA, NIE POJEDYNCZA POPRAWKA: sam filtr zamieniłby fałszywy ALARM w fałszywą CISZĘ, bo
# w tym samym nagłówku prawdziwy termin stał jako `30.09` BEZ ROKU i tak nie był widziany.
# Rok dopisano w pliku (append pod nagłówkiem, rekord PRZED nietknięty) — dopiero obie
# zmiany razem dają pomiar. Pilnuje tego tor (⊕): po cięciu ma świecić HORYZONT, nie cisza.
zbierz() {
  local f="$1"
  [ -e "$f" ] || return 0
  awk -v fr="$FRAZY" 'BEGIN{RS=""} $0 ~ fr {print}' "$f" 2>/dev/null |
    sed -E 's/(RATYFIKOWAN[A-Za-z]*|USTALON[A-Za-z]*|[Zz]apisan[A-Za-z]*|dopisane|cross-check)[^0-9]{0,30}[0-3][0-9]\.[01][0-9](\.20[0-9]{2})?//g' |
    grep -oE '[0-3][0-9]\.[01][0-9]\.20[0-9]{2}' | sort -u
}

sprawdz() {
  local kat="${1:-$KATALOG}" dzis="${2:-$(date +%F)}" hor="${3:-}"
  local po=0 blisko=0 wszystkie=0 f d iso
  [ -n "$hor" ] || hor="$(date -d '+7 days' +%F 2>/dev/null || date -v+7d +%F 2>/dev/null || echo '9999-12-31')"
  for f in "$kat"/*.md; do
    [ -e "$f" ] || continue
    for d in $(zbierz "$f"); do
      wszystkie=$((wszystkie+1)); iso="$(na_iso "$d")"
      if [ "$iso" \< "$dzis" ]; then
        # zmierz, nie zakładaj: akapit z TĄ datą może nieść już zapisane ZAMKNIĘTE:
        if awk -v d="$d" -v fr="$FRAZY" 'BEGIN{RS=""} $0 ~ fr && index($0,d) && /ZAMKNIĘTE:|ZAMKNIETE:|ODCZYTANE:/{z=1} END{exit z?0:1}' "$f" 2>/dev/null; then
          continue
        fi
        po=$((po+1)); echo "   ⚠ PREREJESTR po terminie: $d — $(basename "$f") (brak ZAMKNIĘTE:/ODCZYTANE:)"
      elif [ "$iso" \< "$hor" ] || [ "$iso" = "$dzis" ]; then
        blisko=$((blisko+1)); echo "   ◆ PREREJESTR na horyzoncie: $d — $(basename "$f")"
      fi
    done
  done
  if [ "$wszystkie" -eq 0 ]; then
    echo "   ✓ brak pól nośnika w $kat (nic do pilnowania)"; return 0
  fi
  if [ "$po" -gt 0 ]; then
    echo "   → $po termin(ów) minęło bez zapisanego odczytu. Prerejestr bez odczytu to obietnica, nie pomiar."
    return 3
  fi
  echo "   ✓ $wszystkie data(y) w polach nośnika; nic po terminie$([ "$blisko" -gt 0 ] && echo ", $blisko na horyzoncie 7 dni")  (zmierzone: $dzis)"
  return 0
}

# ── TOR +/− : straż musi umieć NIE przejść (#39: werdykt schodzi do kodu wyjścia) ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ PREREJESTRÓW — AUTOTEST ═══╗"
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT; mkdir -p "$T/pr"
  RC_ALL=0

  printf 'tekst\n\n**DATY ODCZYTU:** B1 -> **01.01.2099**\n\nkoniec\n' > "$T/pr/a.md"
  out="$(sprawdz "$T/pr" 2026-08-13 2026-08-20)"; rc=$?
  if [ $rc -eq 0 ]; then echo "── TEST + (data w przyszłości):        rc=0 (oczekiwane 0)"; else echo "── TEST + ZAWIÓDŁ: rc=$rc"; RC_ALL=1; fi

  printf 'tekst\n\n**DATY ODCZYTU:** B1 -> **01.01.2020**\n\nkoniec\n' > "$T/pr/a.md"
  out="$(sprawdz "$T/pr" 2026-08-13 2026-08-20)"; rc=$?
  if [ $rc -eq 3 ]; then echo "── TEST − (data po terminie):          rc=3 (oczekiwane 3)"; else echo "── TEST − ZAWIÓDŁ: rc=$rc"; RC_ALL=1; fi

  printf 'tekst\n\n**DATY ODCZYTU:** B1 -> **01.01.2020** ZAMKNIĘTE: odczyt zrobiony\n\nkoniec\n' > "$T/pr/a.md"
  out="$(sprawdz "$T/pr" 2026-08-13 2026-08-20)"; rc=$?
  if [ $rc -eq 0 ]; then echo "── TEST ⊙ (po terminie, ale ZAMKNIĘTE): rc=0 (oczekiwane 0)"; else echo "── TEST ⊙ ZAWIÓDŁ: rc=$rc"; RC_ALL=1; fi

  # BLIZNA 11.08: data oddalona od frazy tekstem z cyfrą — [^0-9]* by ją zgubił
  printf 'tekst\n\n**DATY ODCZYTU** (dopisane 11.08, blok 3): B1 -> **01.01.2020**\n\nkoniec\n' > "$T/pr/a.md"
  out="$(sprawdz "$T/pr" 2026-08-13 2026-08-20)"; rc=$?
  if [ $rc -eq 3 ]; then echo "── TEST ⊘ (data za tekstem z cyfrą):   rc=3 (oczekiwane 3 — blizna 11.08 broniona)"; else echo "── TEST ⊘ ZAWIÓDŁ: rc=$rc — AKAPIT NIE DZIAŁA"; RC_ALL=1; fi

  # FILTR METRYCZKI: data ratyfikacji w akapicie nosnika NIE jest terminem
  printf 'tekst\n\n## DATY ODCZYTU — RATYFIKOWANE przez tworce 01.01.2020\nB1 -> **01.01.2099**\n\nkoniec\n' > "$T/pr/a.md"
  out="$(sprawdz "$T/pr" 2026-08-13 2026-08-20)"; rc=$?
  if [ $rc -eq 0 ]; then echo "── TEST ◇ (data ratyfikacji w akapicie):  rc=0 (oczekiwane 0 — metryczka nie jest terminem)"; else echo "── TEST ◇ ZAWIÓDŁ: rc=$rc — FALSZYWY ALARM"; RC_ALL=1; fi

  # ── #010 ROZŁOŻONY NA DWA BŁĘDY W JEDNYM NAGŁÓWKU (03.09.2026, korekta twórcy) ──
  # Zmierzone na żywej materii (PREREJESTR_markery_transplant_010.md l.163, akapit = sam nagłówek):
  #   „## KRYTERIUM ŚMIERCI — USTALONE 20.08.2026 (słowo twórcy: »Wstawmy datę śmierci 30.09 i już«)"
  #   (a) `USTALONE` nie było w filtrze metryczki → data USTALENIA szła jako termin (fałszywy alarm);
  #   (b) prawdziwy termin `30.09` stoi BEZ ROKU → `grep -oE '…\.20[0-9]{2}'` go nie widzi.
  # DLACZEGO SAM FILTR TO ZA MAŁO (słowo twórcy): poprawka (a) bez (b) zamienia fałszywy
  # ALARM w fałszywą CISZĘ — żywy termin przestaje być pilnowany, a cisza jest gorsza,
  # bo nie ma jej kto zauważyć. Dlatego tor jest TRÓJSTRONNY i strona (⊕) jest w nim
  # najważniejsza: po cięciu ma świecić HORYZONT, nie cisza.
  # (⊕) metryczka PRZESZŁA + termin PRZYSZŁY w jednym akapicie → horyzont, rc=0, ale NIE cisza
  printf 'tekst\n\n## KRYTERIUM ŚMIERCI — USTALONE 01.01.2020 (slowo tworcy)\n**TERMIN:** 15.08.2026\n\nkoniec\n' > "$T/pr/a.md"
  out="$(sprawdz "$T/pr" 2026-08-13 2026-08-20)"; rc=$?
  if [ $rc -eq 0 ] && printf '%s' "$out" | grep -q 'horyzoncie: 15.08.2026'; then
    echo "── TEST ⊕ (USTALONE przeszłe + termin przyszły): rc=0 i HORYZONT (nie cisza)"
  else echo "── TEST ⊕ ZAWIÓDŁ: rc=$rc · wyjście: $(printf '%s' "$out" | tr '\n' '~' | cut -c1-90)"; RC_ALL=1; fi
  # (⊖) sam termin PRZESZŁY, bez metryczki → alarm musi zostać alarmem
  printf 'tekst\n\n## KRYTERIUM ŚMIERCI\n**TERMIN:** 01.01.2020\n\nkoniec\n' > "$T/pr/a.md"
  out="$(sprawdz "$T/pr" 2026-08-13 2026-08-20)"; rc=$?
  if [ $rc -eq 3 ]; then echo "── TEST ⊖ (sam termin przeszły):       rc=3 (poprawka nie wycisza prawdziwych)"
  else echo "── TEST ⊖ ZAWIÓDŁ: rc=$rc — fałszywa cisza"; RC_ALL=1; fi
  # (⊗) sama metryczka USTALONE, żadnego terminu → cisza, bo nie ma czego pilnować
  printf 'tekst\n\n## KRYTERIUM ŚMIERCI — USTALONE 01.01.2020 (slowo tworcy)\n\nkoniec\n' > "$T/pr/a.md"
  out="$(sprawdz "$T/pr" 2026-08-13 2026-08-20)"; rc=$?
  if [ $rc -eq 0 ] && ! printf '%s' "$out" | grep -q '01.01.2020'; then
    echo "── TEST ⊗ (sama metryczka USTALONE):   rc=0, data ustalenia nie jest terminem"
  else echo "── TEST ⊗ ZAWIÓDŁ: rc=$rc — USTALONE nadal czytane jako termin"; RC_ALL=1; fi

  printf 'tekst bez pola nosnika\n' > "$T/pr/a.md"
  out="$(sprawdz "$T/pr" 2026-08-13 2026-08-20)"; rc=$?
  if [ $rc -eq 0 ]; then echo "── TEST ∅ (brak pól nośnika):          rc=0 (oczekiwane 0)"; else echo "── TEST ∅ ZAWIÓDŁ: rc=$rc"; RC_ALL=1; fi

  echo
  if [ $RC_ALL -eq 0 ]; then
    echo "✓ STRAŻ ŻYWA: świeci po terminie, milczy przed nim, honoruje ZAMKNIĘTE:,"
    echo "  i nie gubi daty oddalonej od frazy (blizna 11.08)."
  else
    echo "✗ STRAŻ MARTWA — tor nie przechodzi."
  fi
  exit $RC_ALL
fi

echo "╔═══ STRAŻ PREREJESTRÓW ═══╗"
sprawdz
exit $?
