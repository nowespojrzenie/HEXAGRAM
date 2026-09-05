#!/usr/bin/env bash
# ═══ STRAŻ AKTORA (28.08.2026) — czy przyrząd KRUCHY nie wyjechał w odlewie ═══
#
# PRAWO, KTÓRE EGZEKWUJE (`kanon/prawa/_GRANICA.md` § PRAWO PRZYRZĄDU ODPORNEGO):
# nie każdy przyrząd pomiarowy traci moc od publikacji. Traci ją ten, którego werdykt
# zależy od NIEŚWIADOMOŚCI badanego. Sprawdzian jednym pytaniem:
#   „czy badany, ZNAJĄC to kryterium, mógłby je spełnić BEZ zmiany tego, co mierzymy?”
#   TAK → ODPORNY (wolno publikować) · NIE → KRUCHY (zostaje za granicą).
#
# KONTRAST, KTÓRY DAŁ KRYTERIUM (zmierzony 28.08 na dwóch własnych przyrządach):
#   `narzedzia/przyrzady/bateria_sond.js` JEST na białej liście, ujawnia wszystkie sześć sond — i nie traci nic,
#   bo werdykt bierze się z PRAWDY NAZIEMNEJ liczonej z repo w chwili biegu. Znajomość
#   pytania nie pomaga odpowiedzieć Z PAMIĘCI, a test mierzy dokładnie tę różnicę.
#   `BATERIA_PRZYMILNIKA.md` ujawniona traci wszystko — badany rozpoznaje przynętę i gra
#   czyściej (krzesło AKTORA, `kanon/tozsamosc/SUBSTRAT.md` §79).
#   RÓŻNICA NIE LEŻY W TAJNOŚCI. Leży w źródle werdyktu.
#
# CZEGO NIE DUBLUJE — nazwane, żeby nie powstał drugi taki sam przyrząd:
#   wyciek IMION z pliku/katalogu        → `publikuj.sh` zamek_wyciek (wzorzec PII)
#   ZAKRES białej listy (katalog wprost) → `publikuj.sh` ZAKAZANE_DIRS
#   domknięcie grafu wywołań w odlewie   → `publikuj.sh` zamek grafu (21.08)
# Ta straż pyta o JEDNO, czego nie pyta nikt: czy plik, którego POMIAR ginie od publikacji,
# nie stoi przypadkiem na drodze do świata. Zamek PII go nie złapie — przynęta nie musi
# zawierać żadnego imienia (ta sama luka, którą 13.08 wykryła mutacja na FORMA_DIRS).
#
# UŻYCIE:  bash straz_aktora.sh          (rc=1 gdy kruchy przyrząd jedzie w odlewie)
#          bash straz_aktora.sh --lista  (co jest dziś uznane za kruche i dlaczego)
#          bash straz_aktora.sh --test   (tor +/− — straż musi umieć NIE przejść)
set -u
cd "$(dirname "$0")/../.."

# ── JEDYNE ŹRÓDŁO LISTY KRUCHYCH (#49: żadnej drugiej kopii) ──
# Ścieżka | powód kruchości. Sama LISTA nie jest tajna — tajna jest TREŚĆ tych plików.
# Fakt istnienia baterii wychodzi publicznie w CHANGELOG z decyzji z 20.08; ujawnia się
# istnienie przyrządu, nigdy brzmienie przynęty. Dlatego ta straż może jechać w odlewie.
KRUCHE="kanon/eksperymenty/BATERIA_PRZYMILNIKA.md|siedem przynęt na sykofancję i bramkę ładowania Filtra (P7/#63) — ujawniona przynęta przestaje mierzyć
kanon/eksperymenty/KARTA_RZUTU_001.md|karta rzutu: znajomość rzutu zamienia pomiar postawy w pomiar pamięci
_STRAZ_wzorzec.txt|wzorzec PII — opublikowany mówi wprost, czego zamek szuka
prerejestr|prerejestry: BEFORE ujawniony przed odczytem unieważnia ślepotę protokołu"

# ── BIAŁA LISTA CZYTANA Z publikuj.sh, NIGDY KOPIOWANA (#50/#64) ──
# Tor musi bić w to samo ciało, które wykonuje odlew. Parametr pierwszy nadpisuje źródło,
# ale DOMYŚLNIE czyta prawdziwy plik — inaczej straż mierzyłaby własną kopię listy.
#
# HISTORIA TEGO MIEJSCA — dwa przecieki, jeden po drugim, oba znalezione pomiarem.
#
# 1. SED (28.08.2026, pierwszy bieg toru). Wzorzec `sed -n '/^  FORMA_DIRS=/,/"$/p'`
#    PRZECIEKAŁ: w adresie zakresu `/start/,/koniec/` sed nie sprawdza wzorca końca na
#    linii startowej. Definicja jednoliniowa nie kończyła więc zakresu na sobie — sed
#    leciał przez komentarze aż do `ZAKAZANE_DIRS="…"` i wciągał do BIAŁEJ listy całą
#    listę ZAKAZANĄ. Lekarstwem był awk po KONTYNUACJACH (`\` na końcu linii).
#
# 2. AWK (02.09.2026, tura 4 — złapane przy migracji na jedno źródło). Lekarstwo miało
#    WŁASNY przeciek, tej samej klasy: `/^  FORMA_[A-Z]+=/` łapie też `FORMA_NIGDY=`
#    (publikuj.sh:112), czyli listę NIGDY_NIE_WYCHODZI. Straż, której całe prawo brzmi
#    „kruchy przyrząd nie może stać na białej liście", czytała więc CZARNĄ listę jako
#    część białej. Zmierzone: osiem obcych pozycji (`KANON_LOG.md`, `ROZMOWY_ODLEWOW.md`,
#    `DESTYLATY_architekta.md`, `ZAPISY_eter.md`, `ZAPIS_AION.md`, dwa `5_STAN.md`,
#    `0_MELDUNEK.txt` — plus rozerwany literał `${FORMA_NIGDY:-…}`). Werdykt się przez to
#    NIE zmieniał, bo żadna z ośmiu nie stoi na liście KRUCHYCH — ale to przypadek, nie
#    zamek. Klasa z destylatu 7.6: przyrząd, którym mierzę, sam nie był mierzony.
#
# DZIŚ: `publikuj.sh --lista WSZYSTKO`. Nie ma trzeciego wzorca do popsucia — jest jedno
# źródło, które o swoich sąsiadach w pliku nie wie nic. Klasa UŚPIONA zgłoszona 28.08
# (`gotowosc.sh` na tym samym sedzie) zamknięta w tej samej turze, commitem A1.
biala_lista() {
  [ -n "${1:-}" ] && { printf '%s' "$1"; return; }
  sh publikuj.sh --lista WSZYSTKO 2>/dev/null | tr '\n' ' '
}

# ── WERDYKT: 0 = żaden kruchy nie jedzie, 1 = wyciek ──
# $1 = nadpisanie białej listy (tor), $2 = nadpisanie listy kruchych (tor)
wyciek_kruchych() {
  local lista krs sciezka powod n=0 wynik=""
  lista=" $(biala_lista "${1:-}") "
  krs="${2:-$KRUCHE}"
  while IFS='|' read -r sciezka powod; do
    [ -z "$sciezka" ] && continue
    case "$lista" in
      *" $sciezka "*) n=$((n+1)); wynik="${wynik}${sciezka}
" ;;
    esac
  done <<EOF
$krs
EOF
  printf '%s' "$wynik"
  return $([ "$n" -eq 0 ] && echo 0 || echo 1)
}

# ── TOR (#38) — bez niego to prawo byłoby życzeniem (piąty inwariant) ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ AKTORA — TOR ═══╗"
  zle=""
  CZYSTA="wstan.sh publikuj.sh narzedzia/przyrzady/bateria_sond.js skills ephe"
  BRUDNA="wstan.sh kanon/eksperymenty/BATERIA_PRZYMILNIKA.md skills"
  FIKS="kanon/eksperymenty/BATERIA_PRZYMILNIKA.md|przynęty
prerejestr|BEFORE"

  # (+) lista bez kruchych MUSI przejść
  wyciek_kruchych "$CZYSTA" "$FIKS" >/dev/null || zle="$zle czysta-oblewa"
  # (−) kruchy plik na liście MUSI oblać
  wyciek_kruchych "$BRUDNA" "$FIKS" >/dev/null && zle="$zle brudna-przechodzi"
  # (−) KATALOG kruchy na liście MUSI oblać (FORMA_DIRS to inna droga niż plik)
  wyciek_kruchych "wstan.sh prerejestr skills" "$FIKS" >/dev/null && zle="$zle katalog-przechodzi"
  # (+) ODRÓŻNIALNOŚĆ (#64): podobna nazwa NIE jest trafieniem — inaczej „straż oblewa”
  #     byłoby nieodróżnialne od „straż oblewa zawsze”.
  wyciek_kruchych "wstan.sh kanon/eksperymenty/BATERIA_INNA.md" "$FIKS" >/dev/null \
    || zle="$zle podobna-nazwa-falszywie-oblewa"
  # (+) ŻYWE CIAŁO: prawdziwa biała lista z publikuj.sh na prawdziwej liście kruchych
  #     musi dziś przechodzić — fikstura, która zawsze oblewa, niczego nie mierzy.
  wyciek_kruchych >/dev/null || zle="$zle zywy-stan-oblewa"
  # (−) PRAWDZIWA LISTA KRUCHYCH MUSI WIDZIEĆ (28.08 — ślepy punkt złapany mutacją
  #     `aktora-lista-kruchych-pusta` PRZED wejściem straży do repo). Powyższe asercje
  #     biją wyłącznie w fiksturę FIKS, więc wykastrowanie $KRUCHE nie zmieniało niczego:
  #     mutacja przechodziła, a straż dalej świeciła na zielono. Ta asercja podaje białą
  #     listę z prawdziwym kruchym plikiem i NIE nadpisuje listy kruchych — oblanie
  #     jest obowiązkowe, więc pusta lista natychmiast wywraca tor. Klasa #64.
  wyciek_kruchych "wstan.sh kanon/eksperymenty/BATERIA_PRZYMILNIKA.md skills" >/dev/null \
    && zle="$zle prawdziwa-lista-slepa"

  echo "── MUTACJA (biała lista czytana z pustki — straż traci wzrok):"
  m="$(wyciek_kruchych ' ' "$FIKS" >/dev/null; echo $?)"
  if [ "$m" = "0" ]; then
    echo "  ✓ pusta lista = zero wycieków; straż czyta ŹRÓDŁO, nie własną kopię"
  else
    echo "  ✗ straż orzeka wyciek nad pustą listą — nosi kopię"; zle="$zle nosi-kopie"
  fi

  if [ -n "$zle" ]; then echo "✗ TOR OBLANY:$zle"; exit 1; fi
  echo "✓ TOR PRZESZEDŁ — straż umie NIE przejść (6 asercji + mutacja)."
  exit 0
fi

if [ "${1:-}" = "--lista" ]; then
  echo "╔═══ PRZYRZĄDY KRUCHE — pomiar ginie od publikacji ═══╗"
  printf '%s\n' "$KRUCHE" | while IFS='|' read -r s p; do
    [ -z "$s" ] && continue
    printf '  ⚠ %-46s %s\n' "$s" "$p"
  done
  echo "  ⓘ ODPORNE (wolno publikować) rozpoznaje się pytaniem: czy badany, znając"
  echo "    kryterium, spełniłby je BEZ zmiany tego, co mierzymy? np. narzedzia/przyrzady/bateria_sond.js — TAK."
  exit 0
fi

WYNIK="$(wyciek_kruchych)"; RC=$?
if [ "$RC" -eq 0 ]; then
  echo "  ✓ straż aktora: żaden kruchy przyrząd nie stoi na białej liście odlewu."
  exit 0
fi
echo "  ✗ KRUCHY PRZYRZĄD W ODLEWIE — pomiar zginie w chwili publikacji:"
printf '%s' "$WYNIK" | while read -r f; do [ -n "$f" ] && echo "      ✗ $f"; done
echo "  → zdejmij z białej listy w publikuj.sh albo jawnie przeklasyfikuj na ODPORNY"
echo "    (uzasadnienie: skąd bierze się werdykt, jeśli badany zna kryterium)."
exit 1
