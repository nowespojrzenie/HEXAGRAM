#!/usr/bin/env sh
# ═══ STRAŻ ODLEWU (30.08.2026) — mechanizm PRAWA ODLEWU (_GRANICA) ═══════════════════
#
# PRAWO §5: CISZA NIE JEST DECYZJĄ. Każdy dojrzały przyrząd (ma tor `--test`) musi stać
# na jednej z dwóch list: białej (`FORMA_*` w publikuj.sh) albo tutaj — w liście wyłączeń
# Z POWODEM. Brak na obu = alarm.
#
# SKĄD: 30.08 zmierzono, że siedem dojrzałych przyrządów nie jedzie w odlewie — i że nikt
# tego nie wybrał. Biała lista rosła przyrostowo, więc „nie wchodzi" znaczyło „nikt nie
# zapytał". Ta straż zamienia milczenie w pytanie, które ktoś musi rozstrzygnąć.
#
# DLACZEGO POWÓD JEST OBOWIĄZKOWY: lista wyłączeń, na której wolno napisać samą nazwę,
# nic nie kosztuje — po miesiącu ma trzydzieści pozycji i znowu jest osadem (#56/#74).
# Powód nie musi być mądry; musi ISTNIEĆ i być czytelny dla następnego.
#
# ZĘBY: rc=1. To bramka, nie miara — w przeciwieństwie do `straz_powtorzen` tutaj DA SIĘ
# kodem wymusić właściwe zachowanie (wpis na listę), więc twarda odmowa jest uczciwa.
set -eu
cd "$(dirname "$0")/../.."

PUBLIKUJ="${ODL_PUBLIKUJ:-publikuj.sh}"
TRYB="${1:-}"

# ── LISTA WYŁĄCZEŃ: nazwa|powód. Powód pusty = wpis nieważny (patrz wyżej). ────────────
WYLACZENIA="${ODL_WYLACZENIA:-}"
[ -n "$WYLACZENIA" ] || WYLACZENIA='kpull.bat|środowisko twórcy (Windows), nie genom — PRAWO ODLEWU §4
kpush.bat|środowisko twórcy (Windows), nie genom — PRAWO ODLEWU §4
plan_a4.py|narzędzie projektowe Kowala, nie repo — PRAWO ODLEWU §4
_rozdziel_okna.js|jednorazowe, wykonane raz i martwe z chwilą wykonania (kanon/archiwum)
_zdejmij_hub.js|jednorazowe, wykonane raz i martwe z chwilą wykonania (kanon/archiwum)
narodziny.sh|rytuał onboardingu TEGO repo; nowy twórca ma własny START_TU
destyluj_ksiege.js|destyluje księgi PRZY publikacji — działa na tym ciele, nie na przyszłym
markery_z_ciala.sh|czyta TKANKĘ (PROFIL, 7_NATAL), której odlew nie niesie, i sam niesie 4 trafienia wzorca PII (zmierzone 05.09) — odbiorca ma szablony/markery_osobowe_wzor.md
spis_projektow.js|klasyfikator zaszyty pod projekty TEGO twórcy (nazwy marek w regexach) — zamek wycieku złapał go 30.08 przy pierwszej próbie wypuszczenia; wejdzie po sparametryzowaniu listy projektów'

# C3 · tura 4 (02.09.2026): biała lista czytana JEDNYM ŹRÓDŁEM — `publikuj.sh --lista`.
# Ta straż była najbardziej narażona ze wszystkich czytelników: jej wzorzec sed nie miał
# nawet kotwicy `^  `, więc łapał KAŻDE wystąpienie `FORMA_JS=` w pliku — także w blokach
# `--test` samego `publikuj.sh`. Odczyt idzie teraz przez jedno źródło, które o własnych
# fiksturach nie wie nic. `$PUBLIKUJ` zmienia znaczenie z PLIKU DO SPARSOWANIA na
# SKRYPT DO ZAPYTANIA — fikstura toru niżej jest przepisana pod to (atrapa odpowiada
# na `--lista`, zamiast udawać składnię, której nikt już nie parsuje).
nazwy_bialej_listy() {
  { sh "$PUBLIKUJ" --lista JS; sh "$PUBLIKUJ" --lista SH; sh "$PUBLIKUJ" --lista INNE; } 2>/dev/null \
    | grep -E '\.(js|sh|bat|py)$' | while read -r _s; do basename "$_s"; done | sort -u
}

powod_wylaczenia() {   # $1 = nazwa bazowa; echo powód (pusty = brak wpisu). ZAWSZE rc 0:
  # pod `set -e` funkcja kończąca się nieudanym `[ ]` ubijała cały skrypt w ciszy —
  # przebieg żywy nie wypisywał NICZEGO i wyglądał jak przejście (zmierzone przy budowie).
  printf '%s\n' "$WYLACZENIA" | while IFS='|' read -r _n _p; do
    [ "$_n" = "$1" ] && { printf '%s' "$_p"; break; }
    true
  done
  return 0
}

if [ "$TRYB" = "--test" ]; then
  z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (było $2, miało $3)"; o=$((o+1)); fi; }
  T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
  mkdir -p "$T/narzedzia/przyrzady"
  # FIKSTURA PO MIGRACJI (C3 tura 4): atrapa nie udaje SKŁADNI publikuj.sh, tylko jego
  # ODPOWIEDZI. Parser przestał być tu mierzony — mierzy go tor równoważności `--lista`
  # w `publikuj.sh --test`; tutaj mierzy się WERDYKT straży nad podaną listą.
  printf '#!/bin/sh\ncase "$2" in JS) echo narzedzia/przyrzady/jest.js ;; esac\n' > "$T/pub.sh"
  # dojrzały = ma tor; niedojrzały = nie ma
  printf '#!/bin/sh\nif [ "$1" = "--test" ]; then exit 0; fi\n' > "$T/narzedzia/przyrzady/jest.js"
  printf '#!/bin/sh\nif [ "$1" = "--test" ]; then exit 0; fi\n' > "$T/narzedzia/przyrzady/brak.js"
  printf '#!/bin/sh\nif [ "$1" = "--test" ]; then exit 0; fi\n' > "$T/narzedzia/przyrzady/wylaczony.js"
  printf '#!/bin/sh\necho bez toru\n'                            > "$T/narzedzia/przyrzady/niedojrzaly.js"

  # FIKSTURA ODTWARZA TOPOLOGIĘ PRODUKCJI (klasa #70, złapane przy budowie): straż robi
  # `cd dirname/../..`, więc uruchomiona ze ŚCIEŻKI ŻYWEGO REPO mierzyłaby żywe repo, nie
  # atrapę — tor meldował wtedy „nie przeszedł" o cudzym ciele. Kopia musi leżeć w atrapie
  # dwa poziomy pod jej korzeniem, dokładnie jak w produkcji.
  mkdir -p "$T/narzedzia/straze"
  cp "$(cd "$(dirname "$0")" && pwd)/$(basename "$0")" "$T/narzedzia/straze/straz.sh"
  ( cd "$T" && git init -q . && git add -A && git -c user.email=z@z.z -c user.name=Z commit -qm x ) >/dev/null 2>&1
  bieg_w() { ( cd "$T" && ODL_PUBLIKUJ=pub.sh ODL_WYLACZENIA="$1" sh narzedzia/straze/straz.sh >/dev/null 2>&1 && echo 0 || echo 1 ); }
  # (−) dojrzały przyrząd spoza obu list MUSI oblać — to cała racja bytu tej straży
  # SAMA KOPIA STRAŻY jest dojrzała, więc w każdej fiksturze musi mieć własne rozstrzygnięcie —
  # inaczej łapie siebie i wszystkie trzy przypadki oblewają z tego samego, cudzego powodu (#53).
  SAMA='straz.sh|kopia straży w atrapie toru'
  spr "dojrzaly SPOZA obu list OBLEWA" "$(bieg_w "$SAMA
wylaczony.js|powod jest")" "1"
  # (+) ten sam przyrząd z powodem PRZECHODZI
  spr "dojrzaly z POWODEM przechodzi" "$(bieg_w "$SAMA
brak.js|powod jest
wylaczony.js|powod jest")" "0"
  # (−) wyłączenie BEZ POWODU nie liczy się — inaczej lista nic nie kosztuje
  spr "wylaczenie BEZ POWODU oblewa" "$(bieg_w "$SAMA
brak.js|
wylaczony.js|powod jest")" "1"
  echo "╔═══ STRAŻ ODLEWU — AUTOTEST ═══╗"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ STRAŻ ŻYWA: milczenie o dojrzałym przyrządzie jest alarmem, a wyłączenie kosztuje powód."
  exit 0
fi

BIALA="$(nazwy_bialej_listy)"
braki=""; wylaczonych=0; jedzie=0; niedojrzalych=0
for f in $(git ls-files '*.js' '*.sh' '*.bat' '*.py' 2>/dev/null \
           | grep -vE '^(node_modules|ephe|projekty|keep_import)/'); do
  [ -f "$f" ] || continue
  b="$(basename "$f")"
  # DOJRZAŁY = ma tor. Bez toru nie pytamy — to pytanie do straży dojrzałości, nie do tej.
  grep -qE '\-\-test' "$f" 2>/dev/null || { niedojrzalych=$((niedojrzalych+1)); continue; }
  if printf '%s\n' "$BIALA" | grep -qx "$b"; then jedzie=$((jedzie+1)); continue; fi
  _p="$(powod_wylaczenia "$b" || true)"
  if [ -n "$_p" ]; then wylaczonych=$((wylaczonych+1)); continue; fi
  braki="$braki $f"
done

echo "▤ STRAŻ ODLEWU — czy o każdym dojrzałym przyrządzie ktoś rozstrzygnął:"
echo "   zmierzone: w odlewie $jedzie · wyłączonych z powodem $wylaczonych · bez toru $niedojrzalych (nie moje pytanie)"
if [ -n "$braki" ]; then
  echo "   ✗ DOJRZAŁY PRZYRZĄD, O KTÓRYM NIKT NIE ROZSTRZYGNĄŁ:"
  for f in $braki; do echo "      $f"; done
  echo "   PRAWO ODLEWU §5: cisza nie jest decyzją. Dopisz do FORMA_* albo do WYŁĄCZEŃ z powodem."
  exit 1
fi
echo "   ✓ KAŻDY DOJRZAŁY PRZYRZĄD MA ROZSTRZYGNIĘCIE — żaden nie został poza odlewem milczeniem."
