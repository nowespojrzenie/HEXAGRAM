#!/usr/bin/env bash
# ═══ STRAŻ FEROMONÓW v2 (21.08.2026 · v2 03.10.2026 — „KARTKA = PLIK SESJI, TABLICA = WIDOK") ═══
#
# PRAWO TROPU wymaga kompletu pól; ten trop je ma (KIERUNEK_ORGANIZM §IV):
#   WYZWALACZ: więcej niż jedna ręka na gałęzi w tym samym oknie czasu
#   ZASÓB:     praca nie-zdublowana (godziny instancji, spójność gałęzi)
#   METRYKA:   kolizje wymagające ręcznego scalenia / miesiąc
#
# CO ZMIENIA v2 (kanon/plany/linienie/TABLICA_kartki.md, słowo twórcy 03.10 18:16/19:28):
# do 03.10 tablicą był JEDEN plik (KTO_CO_BIERZE.md), do którego pisało każde okno — i to przez edycję
# w środku (`--oddaje`, `--przejmuje`). Zmierzone: 34 commity dziś, STATUS wpisu #127 M zjedzony przez
# unię linii (c2cad24) 17 min po jej wdrożeniu. Przyczyna to kształt nośnika, nie dyscyplina rąk.
# Teraz: każda sesja pisze WYŁĄCZNIE do własnej kartki kanon/ksiegi/kartki/<SESJA>.md; nikt nie dotyka
# cudzego pliku, więc dwa okna nie mają o co się zderzyć. TABLICA = widok składany przy czytaniu
# (`--tablica`, `--inne`), niecommitowany. Przejęcie nie edytuje cudzej kartki: wpis `Z:` we własnej
# kartce przesłania cudzy temat (widok liczy to przy czytaniu).
# PRZEJŚCIE (do 10.10.2026): archiwum KTO_CO_BIERZE.md jest nadal CZYTANE — okno ze starym skryptem,
# które powiesi tam wpis, nie zniknie z widoku (ⓘ „stare okno").
#
# CZEGO TA STRAŻ NIE UDAJE: nie zapobiega kolizji tematów. Dwie instancje nie mają wspólnego zegara
# ani wspólnej pamięci. Ona ją WIDZI — i to jest cała różnica wobec 21.08, gdy trzecia kolizja doby
# została wykryta przypadkiem przez `git status`, a nie przez żaden przyrząd. v2 usuwa natomiast
# kolizję PLIKÓW: to jedyna, którą dało się usunąć z konstrukcji.
#
# TRZY RZECZY MIERZONE, KAŻDA OSOBNO:
#   (1) DWA OTWARTE ŚLADY RÓŻNYCH SESJI — rc=1. Sedno przyrządu.
#   (2) MARTWY FEROMON — ślad otwarty dłużej niż PROG_H godzin. Ostrzega, nie blokuje —
#       długa sesja jest legalna, a straż, która krzyczy nad legalnym stanem, uczy nie patrzeć (#56).
#   (3) HEAD PRZESUNIĘTY od chwili wzięcia — ⓘ, nigdy alarm (#49: tor na ALARM to nie tor na MIARĘ).
#
# ZERO ZNACZĄCE (lekcja INSUM): brak śladów = jedna ręka albo cisza = stan ZDROWY, rc=0.
# Brak KATALOGU kartek to też zero (git nie trzyma pustych katalogów; kartka oddana znika).
# Brak jawnie wskazanego REJESTR (plik wejściowy toru) oblewa — #39: cisza byłaby fałszem.
#
# UŻYCIE:  bash straz_feromonow.sh                          (żywy przebieg po lokalnych kartkach; rc=1 przy kolizji)
#          bash straz_feromonow.sh --biore "ROLA" "co" [--sesja ID] [--przejmuje SESJA ["temat"]] [--mimo]
#          bash straz_feromonow.sh --oddaje "ROLA" ["początek tematu"|--wszystkie]
#          bash straz_feromonow.sh --postep "tekst" ["początek tematu"]   (prawo 6a, 07.10: postęp do WŁASNEJ kartki, wątek składa właściciel przy --oddaje)
#          bash straz_feromonow.sh --inne                    (wstanie: kto jeszcze trzyma temat; rc=0)
#          bash straz_feromonow.sh --tablica                 (cała tablica: origin + własna kartka; rc=0)
#          bash straz_feromonow.sh --test                    (tor +/− — straż musi umieć NIE przejść)
# ZMIENNE: KARTKI (katalog kartek) · LEGACY (archiwum) · REJESTR (jawny plik WEJŚCIOWY: tryb pojedynczego
#          pliku dla toru i awaryjnie; ustawiony = czytamy/piszemy ten plik zamiast katalogu kartek)
set -u
_STREFA_ST="$(node "$(dirname "$0")/../silniki/tz_pl.js" --strefa 2>/dev/null || echo Europe/Warsaw)"   # strefa instancji (tz_pl.js: KRONOS_TZ > instancja.json > package.json); stemple czasu
cd "$(dirname "$0")/../.."

KARTKI="${KARTKI:-kanon/ksiegi/kartki}"
LEGACY="${LEGACY:-kanon/ksiegi/KTO_CO_BIERZE.md}"
REJESTR="${REJESTR:-}"
PROG_H="${PROG_H:-4}"          # po ilu godzinach otwarty ślad OSTRZEGAMY, że sesja mogła umrzeć (NIE warunek odmowy — 03.10)

teraz_iso() { TZ="$_STREFA_ST" date '+%Y-%m-%dT%H:%M:%S%z'; }
epoch_z()   { date -d "$1" +%s 2>/dev/null || echo 0; }

# ═══ SESJA JAKO WSKAŹNIK (03.10.2026, słowo twórcy 13:09 i 13:19) ═══
# „To nie czas, a sesja powinna być indykatorem. Czas w drugiej kolejności. To zmusi do domykania
#  sesji i/lub przenoszenia tematów z jednej do drugiej."
# Karteczka ma TRZY pola o różnej funkcji: SESJA (kto — klucz kolizji) · RĘKA (w jakiej roli — opis)
# · BIORĘ (jaki temat). Wiek jest tylko dopiskiem. Wpisy sprzed 03.10 nie mają SESJA — kluczem jest
# wtedy rola (zgodność wsteczna, wszystkie ODDANE).
# Desygnat sesji = ID z adresu sesji (stopka commita `Claude-Session: …/session_<ID>`, LOG_SESJI),
# 8 znaków; w chmurze z CLAUDE_CODE_REMOTE_SESSION_ID (prefiks cse_/session_ zdejmowany).
# NIE CLAUDE_CODE_SESSION_ID (inny numer tej samej sesji, nieobecny w repo) i NIE żeton wstania.
MIMO=0; WSZ=0; SESJA_ARG=""; MASZ_ARG=""; PRZEJ=""; PRZEJ_TEMAT=""
opcje() { while [ $# -gt 0 ]; do case "$1" in
  --mimo) MIMO=1;; --sesja) SESJA_ARG="${2:-}"; shift;; --maszyna) MASZ_ARG="${2:-}"; shift;; --wszystkie) WSZ=1;; --przejmuje) PRZEJ="${2:-}"; shift; case "${2:-}" in ""|--*) ;; *) PRZEJ_TEMAT="$2"; shift;; esac;;
  esac; shift; done; }
sesja_id() { local v="${SESJA_ARG:-${CLAUDE_CODE_REMOTE_SESSION_ID:-}}"; v="${v#cse_}"; v="${v#session_}"; printf '%s' "${v:0:8}"; }
maszyna_id() { if [ -n "$MASZ_ARG" ]; then printf '%s' "$MASZ_ARG"; elif [ -n "${CLAUDE_CODE_REMOTE_SESSION_ID:-}" ]; then printf 'chmura'; else hostname -s 2>/dev/null || echo '?'; fi; }

# stdin: sklejone wpisy → TSV: klucz  sesja  reka  maszyna  od  co   (tylko OTWARTE i NIEPRZEJĘTE).
# PRZEJĘTY = istnieje wpis innej sesji z `Z:` równym sesji wpisu, nie wcześniejszy od niego i — gdy ma `Z-TEMAT:` —
# o temacie zaczynającym się od tego prefiksu. Status wpisu przejmującego nie ma znaczenia: przejęcie się wydarzyło.
# Wpis bez linii STATUS nie jest otwarty (nie zgadujemy). Klucz = sesja albo rola:REKA (wpisy sprzed 03.10).
otwarte_tsv() { awk '
  function flush() {
    if (w) { i++; Aco[i]=co; Ases[i]=ses; Areka[i]=reka; Amasz[i]=masz; Aod[i]=od; Az[i]=z; Azt[i]=zt; Ast[i]=st }
    w=0 }
  /^\*\*BIORĘ:\*\*/ { flush(); w=1; co=substr($0, index($0,":**")+4); ses=""; reka=""; masz=""; od=""; z=""; zt=""; st=""; next }
  /^\*\*RĘKA:\*\*/    { reka=substr($0, index($0,":**")+4) }
  /^\*\*SESJA:\*\*/   { ses=substr($0, index($0,":**")+4) }
  /^\*\*MASZYNA:\*\*/ { masz=substr($0, index($0,":**")+4) }
  /^\*\*OD:\*\*/      { od=substr($0, index($0,":**")+4) }
  /^\*\*Z:\*\*/       { z=substr($0, index($0,":**")+4) }
  /^\*\*Z-TEMAT:\*\*/ { zt=substr($0, index($0,":**")+4) }
  /^\*\*STATUS:\*\*/  { st=substr($0, index($0,":**")+4) }
  END { flush()
    for (a=1; a<=i; a++) {
      if (Ast[a] !~ /^OTWARTE( · .*)?$/) continue
      prz=0
      if (Ases[a] != "") for (b=1; b<=i; b++)
        if (Az[b]==Ases[a] && Ases[b]!=Ases[a] && Aod[b]>=Aod[a] && (Azt[b]=="" || index(Aco[a], Azt[b])==1)) { prz=1; break }
      if (prz) continue
      k = (Ases[a] != "" ? Ases[a] : "rola:" Areka[a])
      print k "\037" Ases[a] "\037" Areka[a] "\037" Amasz[a] "\037" Aod[a] "\037" Aco[a] } }'; }
# stdin TSV (klucz sesja rola maszyna od co) → lista pogrupowana po SESJI: karteczka jest TEMATEM, sesja tylko jego właścicielem
lista_grup() { local kp="" TAB; TAB="$(printf '\037')"; sort -t"$TAB" -k1,1 | while IFS="$TAB" read -r k s r m od co; do
  [ "$k" = "$kp" ] || { echo "   ▸ sesja ${s:-$k} · $r · ${m:-?}${SESJA_MOJA:+$([ "${s:-$k}" = "$SESJA_MOJA" ] && echo ' ← ta sesja')}"; kp="$k"; }
  echo "       • $co — otwarta $(wiek_txt "$od")"; done; }
wiek_txt() { local w=$(( ($(date +%s) - $(epoch_z "$1")) / 3600 )); if [ "$w" -ge 48 ]; then echo "$((w/24)) dni"; else echo "${w} h"; fi; }
fetch_origin() { local br; br="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"; git fetch -q origin "$br" 2>/dev/null; }

# WIDOKI. Tryb REJESTR (jawny plik) czyta/pisze ten jeden plik; domyślnie katalog kartek.
plik_sesji() { if [ -n "$REJESTR" ]; then printf '%s' "$REJESTR"; else printf '%s/%s.md' "$KARTKI" "$1"; fi; }
lokalny_widok() {   # wszystkie kartki z dysku (albo jeden plik REJESTR)
  if [ -n "$REJESTR" ]; then cat "$REJESTR" 2>/dev/null; return; fi
  local f; for f in "$KARTKI"/*.md; do [ -f "$f" ] && { cat "$f"; echo; }; done; }
zdalny_widok() {    # po fetch: kartki z FETCH_HEAD (bez pliku sesji $1) + archiwum; własną kartkę czytamy z dysku
  local f
  git ls-tree -r --name-only FETCH_HEAD -- "$KARTKI" 2>/dev/null | grep '\.md$' | while IFS= read -r f; do
    [ -n "${1:-}" ] && [ "$(basename "$f" .md)" = "$1" ] && continue
    git show "FETCH_HEAD:$f" 2>/dev/null; echo
  done
  git show "FETCH_HEAD:$LEGACY" 2>/dev/null; echo; }
legacy_otwarte() { git show "FETCH_HEAD:$LEGACY" 2>/dev/null | otwarte_tsv | grep -c . || true; }

# ── ZOSTAW ŚLAD ───────────────────────────────────────────────────────────────
if [ "${1:-}" = "--biore" ]; then
  REKA="${2:-}"; CO="${3:-}"; shift 3 2>/dev/null || true; opcje "$@"
  [ -n "$REKA" ] && [ -n "$CO" ] || {
    echo "✗ FEROMON BEZ NADAWCY albo bez treści."
    echo "  → bash straz_feromonow.sh --biore \"ROLA\" \"co biorę\" [--sesja ID] [--maszyna M] [--przejmuje SESJA [\"temat\"]] [--mimo]"; exit 1; }
  SES="$(sesja_id)"
  [ -n "$SES" ] || { echo "✗ BRAK SESJI: karteczka bez sesji nie wskazuje właściciela (zmienna CLAUDE_CODE_REMOTE_SESSION_ID pusta)."
    echo "  → podaj ID z adresu sesji: --sesja 01PRZYKLAD"; exit 1; }
  case "$SES" in *[!A-Za-z0-9_-]*) echo "✗ SESJA „$SES” ma znaki spoza [A-Za-z0-9_-] — nazwa kartki to nazwa pliku."; exit 1;; esac
  TF="$(plik_sesji "$SES")"
  if [ -n "$REJESTR" ] && [ ! -f "$REJESTR" ]; then echo "✗ brak rejestru $REJESTR"; exit 1; fi
  OBCE=""; WIDOK_ZRODLA=""
  if [ -n "$REJESTR" ]; then
    WIDOK_ZRODLA="$(lokalny_widok | otwarte_tsv)"   # tryb jawnego pliku: źródłem jest ten plik, nie origin
    OBCE="$(printf '%s\n' "$WIDOK_ZRODLA" | awk -F'\037' -v ja="$SES" -v p="$PRZEJ" -v pt="$PRZEJ_TEMAT" 'NF && $1!=ja && !($2==p && p!="" && (pt=="" || index($6,pt)==1))')"
  elif fetch_origin; then
    WIDOK_ZRODLA="$(zdalny_widok | otwarte_tsv)"
    OBCE="$(printf '%s\n' "$WIDOK_ZRODLA" | awk -F'\037' -v ja="$SES" -v p="$PRZEJ" -v pt="$PRZEJ_TEMAT" 'NF && $1!=ja && !($2==p && p!="" && (pt=="" || index($6,pt)==1))')"
    git merge-base --is-ancestor FETCH_HEAD HEAD 2>/dev/null || echo "ⓘ origin ma nowsze commity niż HEAD — git pull --ff-only, zanim zaczniesz."
  else
    echo "ⓘ nie widzę origin (fetch nie przeszedł) — karteczka będzie tylko lokalna, drugie okno jej NIE zobaczy."
    WIDOK_ZRODLA="$(lokalny_widok | otwarte_tsv)"
  fi
  if [ -n "$PRZEJ" ]; then
    ILE_Z="$(printf '%s\n' "$WIDOK_ZRODLA" | awk -F'\037' -v s="$PRZEJ" -v pt="$PRZEJ_TEMAT" 'NF && $2==s && (pt=="" || index($6,pt)==1)' | grep -c . || true)"
    if [ "${ILE_Z:-0}" -eq 0 ]; then
      echo "✗ NIE MA CZEGO PRZEJĄĆ: sesja $PRZEJ nie ma otwartej karteczki${PRZEJ_TEMAT:+ o temacie na „$PRZEJ_TEMAT”} (git pull --ff-only? albo już oddana / już przejęta)."; exit 1; fi
  fi
  if [ -n "$OBCE" ] && [ "$MIMO" != "1" ]; then
    echo "✗ DRUGA SESJA JUŻ TO MA — na origin wisi cudza karteczka (wiek tylko dopisek, nie warunek):"
    printf '%s\n' "$OBCE" | lista_grup
    echo "  → przenieś temat jawnie: --przejmuje <SESJA> [\"początek tematu\"] (jej kartka zostaje nietknięta; widok pokaże PRZEJĘTE)"
    echo "  → albo pracuj OBOK nad innym tematem: --mimo (cudzy temat zostaje zapisany jako MIMO — to miara, nie zakaz)"
    exit 2
  fi
  T="$(teraz_iso)"; H="$(git rev-parse --short HEAD 2>/dev/null || echo '?')"
  [ -z "$REJESTR" ] && mkdir -p "$KARTKI"
  {
    [ -s "$TF" ] && printf '\n'
    printf '**BIORĘ:** %s\n' "$CO"
    printf '**RĘKA:** %s\n' "$REKA"
    printf '**SESJA:** %s\n' "$SES"
    printf '**MASZYNA:** %s\n' "$(maszyna_id)"
    printf '**OD:** %s\n' "$T"
    printf '**HEAD:** %s\n' "$H"
    if [ -n "$PRZEJ" ]; then printf '**Z:** %s\n' "$PRZEJ"; [ -n "$PRZEJ_TEMAT" ] && printf '**Z-TEMAT:** %s\n' "$PRZEJ_TEMAT"; fi
    if [ -n "$OBCE" ]; then printf '%s\n' "$OBCE" | while IFS="$(printf '\037')" read -r k s r m od co; do [ -n "$k" ] && printf '**MIMO:** %s — %s\n' "${s:-$k}" "$co"; done; fi
    printf '**STATUS:** OTWARTE · %s\n' "$SES"
  } >> "$TF"
  echo "▤ ślad zostawiony: [$REKA · $SES · $(maszyna_id)] $CO (HEAD $H)"
  [ -n "$PRZEJ" ] && echo "   przejęcie od sesji $PRZEJ zapisane w TWOJEJ kartce; kartka $PRZEJ zostaje nietknięta (jej właściciel zobaczy PRZEJĘTE w widoku)."
  echo "   drugie okno zobaczy ją DOPIERO po pushu: git add -A $TF && git commit -m \"karteczka\" && bash zapis_git.sh"
  exit 0
fi

# ── POSTĘP DO KARTKI (prawo 6a, 07.10.2026 — słowo twórcy 15:10 „1.ok”) ─────────────────────────────────
# W trakcie pracy sesja NIE dopisuje do linii wątku w WATKI_OTWARTE.md (jedna linia przepisywana w całości = konflikt dwóch okien).
# Postęp idzie TU: linia `**POSTĘP:** <czas ISO> · <tekst>` wstawiana w otwartym bloku własnej kartki bezpośrednio przed jego
# linią STATUS. Kilka otwartych bloków własnej sesji → temat wskazujesz początkiem (jak w --oddaje); bez tematu = odmowa rc=2.
# Brak otwartej kartki albo pusty tekst = rc=1 (pusty powód to tor oblany). --oddaje drukuje zebrane linie pod „DO WĄTKU”.
if [ "${1:-}" = "--postep" ]; then
  shift; TEKST=""; TEMAT=""
  case "${1-}" in --*) ;; *) TEKST="${1-}"; shift 2>/dev/null || true;; esac
  case "${1-}" in ""|--*) ;; *) TEMAT="$1"; shift;; esac
  opcje "$@"
  TEKST="$(printf '%s' "$TEKST" | tr '\n\r' '  ')"
  if [ -z "$(printf '%s' "$TEKST" | tr -d '[:space:]')" ]; then echo "✗ pusty tekst postępu: --postep \"tekst\" [\"początek tematu\"]"; exit 1; fi
  SES="$(sesja_id)"; T="$(teraz_iso)"; TF="$(plik_sesji "${SES:-?}")"
  if [ ! -f "$TF" ]; then echo "✗ brak kartki sesji ${SES:-?} (${TF}) — najpierw --biore \"ROLA\" \"co biorę\"."; exit 1; fi
  WLASNE="$(otwarte_tsv < "$TF" | awk -F'\037' -v ja="$SES" '$2!="" && $2==ja')"
  if [ -z "$WLASNE" ]; then echo "✗ sesja ${SES:-?} nie ma otwartej kartki — najpierw --biore \"ROLA\" \"co biorę\"."; exit 1; fi
  if [ -n "$TEMAT" ]; then DOBOR="$(printf '%s\n' "$WLASNE" | awk -F'\037' -v t="$TEMAT" 'index($6,t)==1')"; else DOBOR="$WLASNE"; fi
  ILE="$(printf '%s' "$DOBOR" | grep -c . || true)"
  if [ "$ILE" -eq 0 ]; then echo "✗ NIE MA otwartej karteczki własnej sesji o temacie na „$TEMAT”. Własne otwarte:"; printf '%s\n' "$WLASNE" | lista_grup; exit 1; fi
  if [ "$ILE" -gt 1 ]; then echo "✗ NIEJEDNOZNACZNE: $ILE otwartych karteczek własnej sesji. Wskaż temat: --postep \"tekst\" \"początek tematu\":"; printf '%s\n' "$DOBOR" | lista_grup; exit 2; fi
  CO_JEDNO="$(printf '%s\n' "$DOBOR" | cut -d"$(printf '\037')" -f6)"
  LIN="**POSTĘP:** $T · $TEKST" awk -v ses_ja="$SES" -v ct="$CO_JEDNO" '
    /^\*\*BIORĘ:\*\*/ { ses=""; co=substr($0, index($0,":**")+4) }
    /^\*\*SESJA:\*\*/ { ses=substr($0, index($0,":**")+4) }
    /^\*\*STATUS:\*\* OTWARTE( · .*)?$/ && ses!="" && ses==ses_ja && co==ct && !zrobione { print ENVIRON["LIN"]; zrobione=1 }
    { print }
  ' "$TF" > "$TF.tmp" && mv "$TF.tmp" "$TF"
  echo "▤ postęp zapisany w kartce [${SES:-?}] — $CO_JEDNO ($T)"
  exit 0
fi

# ── ODDAJ ŚLAD ────────────────────────────────────────────────────────────────
# KARTECZKA JEST TEMATEM (03.10, słowo twórcy 13:42: „karteczka powinna być zdjęta i tematyczna a nie sesyjna"):
# skończony temat zdejmujemy OD RAZU, w trakcie sesji; niedokończony zostaje otwarty (to ślad przeniesienia).
#   --oddaje ROLA "początek tematu"   zdejmuje JEDNĄ karteczkę własnej sesji (0 lub >1 trafień = odmowa z listą)
#   --oddaje ROLA                     zdejmuje jedyną własną; gdy jest ich więcej — odmowa z listą
#   --oddaje ROLA --wszystkie         wszystkie własne (domknięcie hurtem)
# v2: edytuje WYŁĄCZNIE własną kartkę. v2b (04.10, #129): plik NIE znika — kartka oddana w całości zostaje ze STATUS
# ODDANE (kasowanie zatrzymywało bramkę 15B u drugiej ręki; sprzątanie = osobny krok na słowo twórcy). Kartka z `Z:`
# zostaje tak czy tak: jej usunięcie przywróciłoby do widoku temat, który przejęła (wskrzeszenie). Zdejmowane są też
# stare wpisy BEZ SESJA tej roli (tryb pliku).
if [ "${1:-}" = "--oddaje" ]; then
  REKA="${2:-}"; shift 2 2>/dev/null || true
  TEMAT=""; case "${1:-}" in ""|--*) ;; *) TEMAT="$1"; shift;; esac
  opcje "$@"
  [ -n "$REKA" ] || { echo "✗ podaj ROLĘ: --oddaje \"ROLA\" [\"początek tematu\"|--wszystkie] [--sesja ID]"; exit 1; }
  SES="$(sesja_id)"; T="$(teraz_iso)"; TF="$(plik_sesji "${SES:-?}")"
  # PRZEJŚCIE (do 10.10): sesja, której temat wisi jeszcze w archiwum (powieszony starym skryptem), zdejmuje go stamtąd
  # — jedyna dozwolona edycja archiwum, i to własnego wpisu; bez tego taki temat wisiałby na tablicy bez końca.
  if [ ! -f "$TF" ] && [ -z "$REJESTR" ] && [ -f "$LEGACY" ] && otwarte_tsv < "$LEGACY" | awk -F'\037' -v ja="$SES" 'NF && $2!="" && $2==ja {f=1} END{exit !f}'; then
    echo "ⓘ brak kartki sesji ${SES:-?} — zdejmuję własny wpis z archiwum $LEGACY (przejście do 10.10)."; TF="$LEGACY"
  fi
  if [ ! -f "$TF" ]; then
    if [ -n "$REJESTR" ]; then echo "✗ brak rejestru $REJESTR"; exit 1; fi
    echo "▤ nic do oddania — sesja ${SES:-?} nie ma kartki (${TF})."; exit 0
  fi
  WLASNE="$(otwarte_tsv < "$TF" | awk -F'\037' -v ja="$SES" -v r="$REKA" '($2!="" && $2==ja) || ($2=="" && $3==r)')"
  CO_JEDNO=""
  if [ "$WSZ" != "1" ]; then
    if [ -n "$TEMAT" ]; then DOBOR="$(printf '%s\n' "$WLASNE" | awk -F'\037' -v t="$TEMAT" 'index($6,t)==1')"; else DOBOR="$WLASNE"; fi
    ILE="$(printf '%s' "$DOBOR" | grep -c . || true)"
    if [ "$ILE" -eq 0 ]; then
      if [ -n "$TEMAT" ]; then echo "✗ NIE MA karteczki własnej sesji o temacie na „$TEMAT”. Własne otwarte:"; printf '%s\n' "$WLASNE" | lista_grup; exit 1; fi
      echo "▤ nic do oddania — sesja ${SES:-?} nie ma otwartej karteczki."; exit 0
    fi
    if [ "$ILE" -gt 1 ]; then
      echo "✗ NIEJEDNOZNACZNE: $ILE karteczek własnej sesji${TEMAT:+ pasuje do „$TEMAT”}. Zdejmij JEDNĄ: --oddaje \"$REKA\" \"początek tematu\" (albo --wszystkie):"
      printf '%s\n' "$DOBOR" | lista_grup; exit 2
    fi
    CO_JEDNO="$(printf '%s\n' "$DOBOR" | cut -d"$(printf '\037')" -f6)"
  fi
  # 6a (07.10): zbierz linie POSTĘP oddawanych bloków PRZED zmianą STATUS (ten sam warunek co niżej) — tylko druk, wątku nie zmienia.
  DO_WATKU="$(awk -v reka="$REKA" -v ses_ja="$SES" -v wsz="$WSZ" -v ct="$CO_JEDNO" '
    /^\*\*BIORĘ:\*\*/ { rok=0; ses=""; buf=""; co=substr($0, index($0,":**")+4) }
    /^\*\*RĘKA:\*\*/  { rok = ($0 == "**RĘKA:** " reka) }
    /^\*\*SESJA:\*\*/ { ses=substr($0, index($0,":**")+4) }
    /^\*\*POSTĘP:\*\*/ { buf = buf "   " $0 "\n" }
    /^\*\*STATUS:\*\* OTWARTE( · .*)?$/ && ((ses!="" && ses==ses_ja) || (ses=="" && rok)) && (wsz==1 || ct==co) { if (buf != "") { print "   ⟦" co "⟧"; printf "%s", buf } }
  ' "$TF")"
  awk -v reka="$REKA" -v ses_ja="$SES" -v t="$T" -v wsz="$WSZ" -v ct="$CO_JEDNO" '
    /^\*\*BIORĘ:\*\*/ { rok=0; ses=""; co=substr($0, index($0,":**")+4) }
    /^\*\*RĘKA:\*\*/  { rok = ($0 == "**RĘKA:** " reka) }
    /^\*\*SESJA:\*\*/ { ses=substr($0, index($0,":**")+4) }
    /^\*\*STATUS:\*\* OTWARTE( · .*)?$/ && ((ses!="" && ses==ses_ja) || (ses=="" && rok)) && (wsz==1 || co==ct) { print "**STATUS:** ODDANE " t; n++; next }
    { print }
  ' "$TF" > "$TF.tmp" && mv "$TF.tmp" "$TF"
  USUNIETA=""
  # 2b (04.10, BLEDY #129, słowo twórcy „Działaj"): oddana kartka ZOSTAJE jako ślad (STATUS ODDANE). Skasowanie pliku
  # przez jedną rękę zatrzymuje bramkę 15B u każdej drugiej ręki (rc=3), a 15B ma zostać bezwarunkowe. DORAŹNE: katalog
  # rośnie o plik na sesję; sprzątanie to osobny, jawny krok na słowo twórcy — nie ten przyrząd.
  if [ -z "$REJESTR" ] && [ "$TF" != "$LEGACY" ] && ! grep -q '^\*\*STATUS:\*\* OTWARTE' "$TF" && ! grep -q '^\*\*Z:\*\*' "$TF"; then USUNIETA=" — kartka oddana w całości, plik ZOSTAJE jako ślad (BLEDY #129)"; fi
  echo "▤ zdjęte [$REKA · ${SES:-bez sesji}]${CO_JEDNO:+ — $CO_JEDNO}${WSZ:+$([ "$WSZ" = 1 ] && echo ' — wszystkie własne')} ($T)$USUNIETA"
  if [ -n "$DO_WATKU" ]; then echo "▤ DO WĄTKU (jeden commit, ręką właściciela):"; printf '%s\n' "$DO_WATKU"; fi
  exit 0
fi

# ── POKAŻ INNE SESJE (wstanie: pokazuje, nie wiesza — temat przy wstaniu nieznany) ───────────
if [ "${1:-}" = "--inne" ]; then
  shift; opcje "$@"; SES="$(sesja_id)"
  if ! fetch_origin; then echo "   ⓘ nie widzę origin — karteczek innych sesji nie sprawdzono."; exit 0; fi
  INNE="$(zdalny_widok | otwarte_tsv | awk -F'\037' -v ja="$SES" 'NF && $1!=ja')"
  LEG="$(legacy_otwarte)"
  [ "${LEG:-0}" -eq 0 ] || echo "   ⓘ stare okno: archiwum $LEGACY ma $LEG otwartych wpisów (ktoś wiesza ze starym skryptem — widać je niżej)."
  if [ -z "$INNE" ]; then echo "   ✓ żadna INNA sesja nie ma otwartej karteczki na origin."; exit 0; fi
  echo "   ⓘ INNE SESJE trzymają tematy (karteczka = temat; nie bierz zajętego bez --przejmuje albo --mimo):"
  printf '%s\n' "$INNE" | lista_grup
  exit 0
fi

# ── TABLICA: cały widok (origin + własna kartka z dysku); niecommitowany ─────────────────────
if [ "${1:-}" = "--tablica" ]; then
  shift; opcje "$@"; SES="$(sesja_id)"; SESJA_MOJA="$SES"
  if fetch_origin; then
    WID="$( { zdalny_widok "$SES"; [ -n "$SES" ] && [ -f "$(plik_sesji "$SES")" ] && cat "$(plik_sesji "$SES")"; } | otwarte_tsv)"
    ZRODLO="origin + własna kartka"
    LEG="$(legacy_otwarte)"; [ "${LEG:-0}" -eq 0 ] || echo "   ⓘ stare okno: archiwum $LEGACY ma $LEG otwartych wpisów."
  else
    echo "   ⓘ nie widzę origin — tablica z lokalnych kartek (może być nieświeża)."
    WID="$(lokalny_widok | otwarte_tsv)"; ZRODLO="tylko lokalnie"
  fi
  echo "▤ TABLICA ($ZRODLO) — widok składany z kartek, nie plik; temat zajęty → --przejmuje albo --mimo:"
  if [ -z "$WID" ]; then echo "   ✓ nikt nie trzyma żadnego tematu."; exit 0; fi
  printf '%s\n' "$WID" | lista_grup
  exit 0
fi

# ── TOR WŁASNY (#38 · #47) ────────────────────────────────────────────────────
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ FEROMONÓW v2 — AUTOTEST (#38) ═══╗"
  T="$(mktemp -d)"; z=0; o=0
  spr() { if [ "$2" = "$3" ]; then echo "  ✓ $1"; z=$((z+1)); else echo "  ✗ $1 (rc=$2, oczekiwano $3)"; o=$((o+1)); fi; }
  # FIKSTURA ODTWARZA TOPOLOGIĘ PRODUKCJI (29.08, dach narzedzia/straze/): straż robi
  # `cd dirname/../..`, więc kopia MUSI leżeć dwa poziomy pod korzeniem atrapy — kopia
  # w korzeniu wyprowadzała `cd` POZA atrapę, na żywe repo (#66 ods. 8 / #70).
  mkdir -p "$T/narzedzia/straze"
  cp "$0" "$T/narzedzia/straze/straz.sh"
  run() { ( cd "$T" && REJESTR="$1" PROG_H="${2:-4}" bash narzedzia/straze/straz.sh >/dev/null 2>&1; echo $? ); }
  ISO_TERAZ="$(TZ="$_STREFA_ST" date '+%Y-%m-%dT%H:%M:%S%z')"

  # ── A. TRYB PLIKU (REJESTR=plik) — pierwotne przypadki z v1, bez zmiany sensu ──
  : > "$T/pusty.md"
  spr "ZERO ZNACZACE: brak sladow przechodzi" "$(run pusty.md)" "0"

  printf '**BIORĘ:** x\n**RĘKA:** A\n**OD:** %s\n**HEAD:** abc\n**STATUS:** OTWARTE\n' "$ISO_TERAZ" > "$T/jeden.md"
  spr "JEDEN otwarty slad przechodzi (jedna reka to nie kolizja)" "$(run jeden.md)" "0"

  cp "$T/jeden.md" "$T/dwa.md"
  printf '\n**BIORĘ:** y\n**RĘKA:** B\n**OD:** %s\n**HEAD:** abc\n**STATUS:** OTWARTE\n' "$ISO_TERAZ" >> "$T/dwa.md"
  spr "DWIE rozne rece otwarte OBLEWA (sedno przyrzadu)" "$(run dwa.md)" "1"

  # ta sama ręka dwa razy to nie kolizja — inaczej straż karałaby własną wielozadaniowość
  cp "$T/jeden.md" "$T/dwa_te_same.md"
  printf '\n**BIORĘ:** y\n**RĘKA:** A\n**OD:** %s\n**HEAD:** abc\n**STATUS:** OTWARTE\n' "$ISO_TERAZ" >> "$T/dwa_te_same.md"
  spr "TA SAMA reka dwa razy NIE jest kolizja" "$(run dwa_te_same.md)" "0"

  # oddany ślad znika z pola widzenia — inaczej rejestr append-only zatruwałby się historią
  sed 's/^\*\*STATUS:\*\* OTWARTE$/**STATUS:** ODDANE 2026-01-01T00:00:00+0100/' "$T/dwa.md" > "$T/oddane.md"
  spr "ODDANE slady nie licza sie do kolizji" "$(run oddane.md)" "0"

  # PROZA bez znacznika NIE jest wpisem (#56: znacznik, nie heurystyka)
  printf 'Reka A bierze dzis straz lintow, a reka B bierze feromony.\n' > "$T/proza.md"
  spr "PROZA bez znacznika nie jest wpisem" "$(run proza.md)" "0"

  # martwy feromon: OSTRZEGA, nie blokuje — długa sesja jest legalna
  printf '**BIORĘ:** x\n**RĘKA:** A\n**OD:** 2020-01-01T00:00:00+0100\n**HEAD:** abc\n**STATUS:** OTWARTE\n' > "$T/stary.md"
  spr "MARTWY feromon ostrzega, nie blokuje (#56)" "$(run stary.md)" "0"

  # brak jawnie wskazanego rejestru: cisza byłaby fałszem (#39) — straż nie zmierzyła, więc się nie zieleni
  spr "BRAK rejestru (jawnego) oblewa, nie milczy (#39)" "$(run nie_ma.md)" "1"

  # wpisy sprzed 03.10 (bez SESJA) nadal się parsują: dwie różne role = kolizja
  printf '**BIORĘ:** x\n**RĘKA:** A\n**OD:** %s\n**HEAD:** abc\n**STATUS:** OTWARTE\n\n**BIORĘ:** y\n**RĘKA:** B\n**OD:** %s\n**HEAD:** abc\n**STATUS:** OTWARTE\n' "$ISO_TERAZ" "$ISO_TERAZ" > "$T/stare.md"
  spr "stare wpisy bez SESJA: parsowane (dwie role = kolizja)" "$(run stare.md)" "1"

  # wpis BEZ linii STATUS nie jest otwarty (nie zgadujemy) — tak wygląda ogon sklejony przez unię linii (#127)
  printf '**BIORĘ:** x\n**RĘKA:** A\n**SESJA:** SESXXXXX\n**OD:** %s\n\n**BIORĘ:** y\n**RĘKA:** B\n**SESJA:** SESYYYYY\n**OD:** %s\n**STATUS:** OTWARTE · SESYYYYY\n' "$ISO_TERAZ" "$ISO_TERAZ" > "$T/bezstatusu.md"
  spr "wpis BEZ STATUS nie liczy się jako otwarty (jedna sesja → rc=0)" "$(run bezstatusu.md)" "0"

  # ── B. KARTKI W KATALOGU (v2): dwa klony jednego bare repo ──
  # Zmienna środowiska sesji jest czyszczona: tor ma być niezależny od tego, w jakiej sesji biegnie.
  G="$T/git"; mkdir -p "$G"
  ( cd "$G" && git init -q --bare o.git && git clone -q o.git a 2>/dev/null && git clone -q o.git b 2>/dev/null ) >/dev/null 2>&1
  mkdir -p "$G/a/narzedzia/straze" "$G/a/kanon/ksiegi"; cp "$0" "$G/a/narzedzia/straze/straz.sh"
  gx() { ( cd "$G/$1" && git -c user.email=t@t -c user.name=t "${@:2}" ); }
  sz() { ( cd "$G/$1" && env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh "${@:2}" >/dev/null 2>&1 ); echo $?; }
  szo() { ( cd "$G/$1" && env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh "${@:2}" 2>&1 ); }
  KA="kanon/ksiegi/kartki"
  # A wiesza pod rolą „Budowniczy" (sesja SESAAAA) i pcha
  spr "A wiesza karteczkę (sesja SESAAAA, rola Budowniczy)" "$(sz a --biore Budowniczy "temat X" --sesja SESAAAA)" 0
  [ -f "$G/a/$KA/SESAAAA.md" ] && spr "kartka = własny plik sesji ($KA/SESAAAA.md)" 0 0 || spr "kartka = własny plik sesji ($KA/SESAAAA.md)" 1 0
  gx a add -A >/dev/null 2>&1; gx a commit -qm k >/dev/null 2>&1; gx a push -q origin HEAD:master >/dev/null 2>&1 || gx a push -q origin HEAD:main >/dev/null 2>&1
  BR="$(cd "$G/a" && git rev-parse --abbrev-ref HEAD)"
  ( cd "$G/b" && git fetch -q origin >/dev/null 2>&1; git checkout -q -B "$BR" "origin/$BR" >/dev/null 2>&1 )
  mkdir -p "$G/b/narzedzia/straze"; cp "$0" "$G/b/narzedzia/straze/straz.sh"
  # TA SAMA ROLA × DWIE SESJE = kolizja (dziura sprzed 03.10: obie nazywały się „Budowniczy")
  spr "TA SAMA rola × INNA sesja na origin = ODMOWA rc=2" "$(sz b --biore Budowniczy "temat Y" --sesja SESBBBBB)" 2
  spr "brak SESJI = odmowa rc=1 (feromon bez nadawcy)" "$(sz b --biore Budowniczy "temat Y")" 1
  spr "SESJA ze znakami spoza [A-Za-z0-9_-] = odmowa rc=1 (nazwa pliku)" "$(sz b --biore Budowniczy "temat Y" --sesja '../x')" 1
  spr "--mimo wiesza obok jawnie (rc=0)" "$(sz b --biore Budowniczy "temat Y" --sesja SESBBBBB --mimo)" 0
  grep -q '^\*\*MIMO:\*\* SESAAAA — temat X' "$G/b/$KA/SESBBBBB.md" && spr "--mimo zapisuje MIMO: cudzy temat (miara M3)" 0 0 || spr "--mimo zapisuje MIMO: cudzy temat (miara M3)" 1 0
  # CUDZA KARTKA NIETKNIĘTA: B nie dotyka pliku A (sedno v2)
  SHA_A_PRZED="$(cd "$G/b" && sha256sum < "$KA/SESAAAA.md")"
  # TA SAMA SESJA × DWIE ROLE = brak kolizji (rola zmienia się w trakcie sesji)
  spr "TA SAMA sesja, INNA rola = brak odmowy (rc=0)" "$(sz a --biore Orkiestrator "temat Z" --sesja SESAAAA)" 0
  # KARTECZKA STARA 10 DNI nadal blokuje — czas nie jest wskaźnikiem
  sed -i "s/^\*\*OD:\*\* .*/**OD:** 2020-01-01T00:00:00+0100/" "$G/a/$KA/SESAAAA.md"
  gx a add -A >/dev/null 2>&1; gx a commit -qm stara >/dev/null 2>&1; gx a push -q origin HEAD:"$BR" >/dev/null 2>&1
  spr "karteczka sprzed lat NIE zwalnia: nadal rc=2 (wskaźnik to sesja, nie czas)" "$(sz b --biore Budowniczy "temat W" --sesja SESBBBBB)" 2
  # PRZEJĘCIE: stara sesja → nowa; cudza kartka NIETKNIĘTA, wpis Z: we własnej, widok pokazuje PRZEJĘTE
  ( cd "$G/b" && git pull -q --ff-only origin "$BR" >/dev/null 2>&1 )
  SHA_A_PRZED="$(cd "$G/b" && sha256sum < "$KA/SESAAAA.md")"
  spr "--przejmuje SESAAAA otwiera nowy wpis (rc=0)" "$(sz b --biore Budowniczy "temat X (przeniesiony)" --sesja SESBBBBB --przejmuje SESAAAA)" 0
  SHA_A_PO="$(cd "$G/b" && sha256sum < "$KA/SESAAAA.md")"
  [ "$SHA_A_PRZED" = "$SHA_A_PO" ] && spr "przejęcie NIE zmienia cudzej kartki (sha przed = po)" 0 0 || spr "przejęcie NIE zmienia cudzej kartki (sha przed = po)" 1 0
  grep -q '^\*\*Z:\*\* SESAAAA' "$G/b/$KA/SESBBBBB.md" && spr "nowy wpis niesie Z: w WŁASNEJ kartce" 0 0 || spr "nowy wpis niesie Z: w WŁASNEJ kartce" 1 0
  grep -q "^\*\*STATUS:\*\* OTWARTE · SESBBBBB\$" "$G/b/$KA/SESBBBBB.md" && spr "nowy wpis: STATUS unikalny per wpis (OTWARTE · SESJA, #127)" 0 0 || spr "nowy wpis: STATUS unikalny per wpis (OTWARTE · SESJA, #127)" 1 0
  ( cd "$G/b" && git add -A && git -c user.email=t@t -c user.name=t commit -qm przej && git push -q origin HEAD:"$BR" ) >/dev/null 2>&1
  WID="$(szo a --tablica --sesja SESCCCCC)"
  printf '%s' "$WID" | grep -q 'temat X (przeniesiony)' && ! printf '%s' "$WID" | grep -qE '• temat X —|• temat Z —' && spr "widok: temat przejęty znika u starej sesji, jest u nowej" 0 0 || spr "widok: temat przejęty znika u starej sesji, jest u nowej" 1 0
  spr "--przejmuje sesji bez karteczki = rc=1 (nie ma czego przejąć)" "$(sz b --biore Budowniczy "t" --sesja SESBBBBB --przejmuje SESNIEMA)" 1
  # --oddaje zamyka wpisy własnej sesji
  # KARTECZKA = TEMAT (03.10 13:42): sesja ma dwie karteczki → zdejmuje się JEDNĄ, drugą zostawia
  spr "--oddaje bez tematu przy DWÓCH własnych = odmowa rc=2" "$(sz b --oddaje Budowniczy --sesja SESBBBBB)" 2
  spr "--oddaje niejednoznaczny początek („temat”) = odmowa rc=2" "$(sz b --oddaje Budowniczy "temat" --sesja SESBBBBB)" 2
  spr "--oddaje nieistniejący temat = rc=1" "$(sz b --oddaje Budowniczy "nie ma takiego" --sesja SESBBBBB)" 1
  spr "--oddaje „temat Y” zdejmuje JEDNĄ (rc=0)" "$(sz b --oddaje Budowniczy "temat Y" --sesja SESBBBBB)" 0
  NOTW="$(grep -c '^\*\*STATUS:\*\* OTWARTE' "$G/b/$KA/SESBBBBB.md" || true)"; [ "$NOTW" = "1" ] && spr "druga karteczka tej sesji ZOSTAJE otwarta" 0 0 || spr "druga karteczka tej sesji ZOSTAJE otwarta" 1 0
  spr "--oddaje bez tematu przy JEDNEJ własnej = zdejmuje (rc=0)" "$(sz b --oddaje Budowniczy --sesja SESBBBBB)" 0
  ! grep -q '^\*\*STATUS:\*\* OTWARTE' "$G/b/$KA/SESBBBBB.md" && spr "po zdjęciu obu brak OTWARTYCH w pliku" 0 0 || spr "po zdjęciu obu brak OTWARTYCH w pliku" 1 0
  # WSKRZESZENIE: kartka z Z: zostaje po oddaniu (inaczej temat przejęty wróciłby do widoku starej sesji)
  [ -f "$G/b/$KA/SESBBBBB.md" ] && spr "kartka z Z: ZOSTAJE po oddaniu (anty-wskrzeszenie)" 0 0 || spr "kartka z Z: ZOSTAJE po oddaniu (anty-wskrzeszenie)" 1 0
  ( cd "$G/b" && git add -A && git -c user.email=t@t -c user.name=t commit -qm oddane && git push -q origin HEAD:"$BR" ) >/dev/null 2>&1
  WID2="$(szo a --tablica --sesja SESCCCCC)"
  printf '%s' "$WID2" | grep -qE 'temat X|temat Z' && spr "po oddaniu przez nową sesję temat NIE wraca do widoku starej" 1 0 || spr "po oddaniu przez nową sesję temat NIE wraca do widoku starej" 0 0
  # --wszystkie: hurtem; kartka bez Z: ZOSTAJE ze STATUS ODDANE (2b, #129 — plik nie znika)
  spr "dwa wpisy + --wszystkie (rc=0)" "$( ( cd "$G/b" && env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh --biore Rola "t1" --sesja SESDDDDD >/dev/null 2>&1; env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh --biore Rola "t2" --sesja SESDDDDD --mimo >/dev/null 2>&1; env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh --oddaje Rola --wszystkie --sesja SESDDDDD >/dev/null 2>&1; echo $? ) )" 0
  [ -f "$G/b/$KA/SESDDDDD.md" ] && grep -q '^\*\*STATUS:\*\* ODDANE' "$G/b/$KA/SESDDDDD.md" && ! grep -q '^\*\*STATUS:\*\* OTWARTE' "$G/b/$KA/SESDDDDD.md" && spr "kartka bez otwartych i bez Z: ZOSTAJE ze STATUS ODDANE (2b, #129: 15B bezwarunkowe)" 0 0 || spr "kartka bez otwartych i bez Z: ZOSTAJE ze STATUS ODDANE (2b, #129: 15B bezwarunkowe)" 1 0
  # DWIE SESJE BIORĄ NARAZ (zanim którakolwiek zobaczy drugą) → merge bez konfliktu, BEZ atrybutów i unii
  ( cd "$G" && git clone -q o.git c 2>/dev/null && git clone -q o.git d 2>/dev/null )
  for k in c d; do ( cd "$G/$k" && git fetch -q origin && git checkout -q -B "$BR" "origin/$BR" ) >/dev/null 2>&1; mkdir -p "$G/$k/narzedzia/straze"; cp "$0" "$G/$k/narzedzia/straze/straz.sh"; done
  sz c --biore Rola "naraz C" --sesja SESCCCCC >/dev/null; sz d --biore Rola "naraz D" --sesja SESDDDDD --mimo >/dev/null
  ( cd "$G/c" && git add -A && git -c user.email=t@t -c user.name=t commit -qm cc && git push -q origin HEAD:"$BR" ) >/dev/null 2>&1
  ( cd "$G/d" && git add -A && git -c user.email=t@t -c user.name=t commit -qm dd && git fetch -q origin "$BR" ) >/dev/null 2>&1
  ( cd "$G/d" && git merge-tree --write-tree HEAD FETCH_HEAD >/dev/null 2>&1 ); spr "dwie sesje wieszają NARAZ → merge-tree rc=0 (bez atrybutów, bez unii)" $? 0
  # WIDOK: własna niewypchnięta kartka + cudze z origin; archiwum czytane
  WID3="$(cd "$G/d" && git merge -q --no-edit FETCH_HEAD >/dev/null 2>&1; env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh --tablica --sesja SESDDDDD 2>&1)"
  printf '%s' "$WID3" | grep -q 'naraz C' && printf '%s' "$WID3" | grep -q 'naraz D' && spr "--tablica pokazuje cudzą (origin) i własną kartkę" 0 0 || spr "--tablica pokazuje cudzą (origin) i własną kartkę" 1 0
  # STARE OKNO: wpis powieszony w archiwum (stary skrypt) jest WIDOCZNY i blokuje --biore
  printf '\n**BIORĘ:** stare okno temat\n**RĘKA:** Staruch\n**SESJA:** SESOLDWIN\n**OD:** %s\n**HEAD:** h\n**STATUS:** OTWARTE · SESOLDWIN\n' "$ISO_TERAZ" > "$G/c/kanon/ksiegi/KTO_CO_BIERZE.md"
  ( cd "$G/c" && git add -A && git -c user.email=t@t -c user.name=t commit -qm stare && git push -q origin HEAD:"$BR" ) >/dev/null 2>&1
  szo a --inne --sesja SESAAAA | grep -q 'stare okno temat' && spr "--inne widzi wpis powieszony w archiwum (stare okno)" 0 0 || spr "--inne widzi wpis powieszony w archiwum (stare okno)" 1 0
  szo a --inne --sesja SESAAAA | grep -q 'ⓘ stare okno' && spr "--inne nazywa stare okno wprost (ⓘ)" 0 0 || spr "--inne nazywa stare okno wprost (ⓘ)" 1 0
  spr "wpis ze starego okna BLOKUJE --biore (rc=2)" "$(sz b --biore Rola "inny" --sesja SESBBBBB)" 2
  # PRZEJĘCIE JEDNEGO TEMATU zostawia pozostałe u starej sesji (tryb pliku; OD realne, bo przesłanianie liczy czas)
  printf '\n**BIORĘ:** alfa pierwsza\n**RĘKA:** R\n**SESJA:** SESOLDDD\n**OD:** 2020-01-01T00:00:00+0100\n**HEAD:** h\n**STATUS:** OTWARTE\n\n**BIORĘ:** beta druga\n**RĘKA:** R\n**SESJA:** SESOLDDD\n**OD:** 2020-01-01T00:00:00+0100\n**HEAD:** h\n**STATUS:** OTWARTE\n' > "$G/b/p.md"
  ( cd "$G/b" && git fetch -q origin >/dev/null 2>&1; REJESTR=p.md env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh --biore R "alfa dalej" --sesja SESNEWWW --przejmuje SESOLDDD "alfa" --mimo >/dev/null 2>&1 ); spr "--przejmuje z tematem (rc=0)" $? 0
  POZ="$( cd "$G/b" && REJESTR=p.md bash narzedzia/straze/straz.sh 2>&1 )"
  printf '%s' "$POZ" | grep -q 'beta druga' && printf '%s' "$POZ" | grep -q 'alfa dalej' && ! printf '%s' "$POZ" | grep -q 'alfa pierwsza' && spr "przejęty JEDEN temat, drugi zostaje u starej sesji" 0 0 || spr "przejęty JEDEN temat, drugi zostaje u starej sesji" 1 0
  # R3 (05.10.2026, seria R): temat, którego stara sesja NIE trzyma, nie jest do przejęcia — rc=1, plik bez zmian (mutacja `feromon-przejmuje-liczy-kazdy-temat` była ślepa)
  ( cd "$G/b" && REJESTR=p.md env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh --biore R "gamma nowa" --sesja SESNEWW2 --przejmuje SESOLDDD "gamma" --mimo >/dev/null 2>&1 ); spr "--przejmuje z tematem, którego sesja nie trzyma = rc=1" $? 1
  # PRZEJŚCIE: --oddaje zdejmuje własny wpis z archiwum, gdy sesja nie ma kartki (stary skrypt powiesił temat tam)
  printf '\n**BIORĘ:** wisi w archiwum\n**RĘKA:** Staruch\n**SESJA:** SESARCH1\n**OD:** %s\n**HEAD:** h\n**STATUS:** OTWARTE\n' "$ISO_TERAZ" >> "$G/b/kanon/ksiegi/KTO_CO_BIERZE.md"
  spr "--oddaje bez kartki zdejmuje własny wpis z ARCHIWUM (przejście)" "$(sz b --oddaje Staruch --sesja SESARCH1)" 0
  grep -q '^\*\*STATUS:\*\* ODDANE' "$G/b/kanon/ksiegi/KTO_CO_BIERZE.md" && spr "wpis w archiwum ma STATUS ODDANE po zdjęciu" 0 0 || spr "wpis w archiwum ma STATUS ODDANE po zdjęciu" 1 0
  # BRAK ORIGIN = ⓘ, nie odmowa
  ( cd "$G/b" && git remote remove origin )
  spr "BRAK origin = ⓘ, nie odmowa (rc=0)" "$(sz b --biore Budowniczy "offline" --sesja SESBBBBB)" 0
  # --inne: wstanie pokazuje, nie wiesza, rc=0
  spr "--inne (wstanie) tylko pokazuje, rc=0" "$(sz a --inne --sesja SESAAAA)" 0
  spr "--tablica tylko pokazuje, rc=0" "$(sz a --tablica --sesja SESAAAA)" 0
  # ZERO ZNACZĄCE w trybie katalogu: brak katalogu kartek = stan zdrowy, nie błąd
  mkdir -p "$T/pusty_kat/narzedzia/straze" && cp "$0" "$T/pusty_kat/narzedzia/straze/straz.sh"
  ( cd "$T/pusty_kat" && bash narzedzia/straze/straz.sh >/dev/null 2>&1 ); spr "BRAK katalogu kartek = zero znaczące (rc=0), nie błąd" $? 0

  # ── C. POSTĘP DO KARTKI (prawo 6a, 07.10): biore → 2× postep → inne → oddaje (druk) ──
  PP="$T/postep"; mkdir -p "$PP"
  ( cd "$PP" && git init -q --bare o.git && git clone -q o.git c ) >/dev/null 2>&1
  mkdir -p "$PP/c/narzedzia/straze" "$PP/c/kanon/ksiegi"; cp "$0" "$PP/c/narzedzia/straze/straz.sh"
  pk() { ( cd "$PP/c" && env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh "$@" >/dev/null 2>&1 ); echo $?; }
  pko() { ( cd "$PP/c" && env -u CLAUDE_CODE_REMOTE_SESSION_ID bash narzedzia/straze/straz.sh "$@" 2>&1 ); }
  spr "postęp BEZ kartki = rc=1 (najpierw --biore)" "$(pk --postep "krok 0" --sesja SESPPPPP)" 1
  pko --postep "krok 0" --sesja SESPPPPP | grep -q 'najpierw --biore' && spr "postęp bez kartki mówi „najpierw --biore”" 0 0 || spr "postęp bez kartki mówi „najpierw --biore”" 1 0
  spr "biore pod postęp (rc=0)" "$(pk --biore Wykonawca "temat postepu" --sesja SESPPPPP)" 0
  spr "postęp z PUSTYM tekstem = rc=1" "$(pk --postep "   " --sesja SESPPPPP)" 1
  spr "postęp 1 (rc=0)" "$(pk --postep "krok pierwszy" --sesja SESPPPPP)" 0
  spr "postęp 2 (rc=0)" "$(pk --postep "krok drugi \\ z ukośnikiem" --sesja SESPPPPP)" 0
  KP="$PP/c/$KA/SESPPPPP.md"
  L1="$(grep -n 'krok pierwszy' "$KP" | cut -d: -f1)"; L2="$(grep -n 'krok drugi' "$KP" | cut -d: -f1)"; LS="$(grep -n '^\*\*STATUS:\*\*' "$KP" | head -1 | cut -d: -f1)"
  [ -n "$L1" ] && [ -n "$L2" ] && [ "$L1" -lt "$L2" ] && [ "$L2" -lt "$LS" ] && spr "linie POSTĘP stoją w kolejności, PRZED linią STATUS" 0 0 || spr "linie POSTĘP stoją w kolejności, PRZED linią STATUS" 1 0
  grep -q 'krok drugi \\ z ukośnikiem' "$KP" && spr "ukośnik w tekście postępu zachowany (ENVIRON, nie -v)" 0 0 || spr "ukośnik w tekście postępu zachowany (ENVIRON, nie -v)" 1 0
  # czytniki kartek nie potykają się o nową linię: widok tematów bez zmian
  NT="$(pko --tablica --sesja SESPPPPP | grep -c 'temat postepu' || true)"
  [ "$NT" = "1" ] && spr "--tablica widzi temat dokładnie raz (POSTĘP nie psuje czytnika)" 0 0 || spr "--tablica widzi temat dokładnie raz (POSTĘP nie psuje czytnika)" 1 0
  spr "--inne z drugiej sesji: rc=0" "$(pk --inne --sesja SESQQQQQ)" 0
  # dwa otwarte tematy: bez wskazania = odmowa, ze wskazaniem = zapis
  spr "drugi temat własnej sesji (rc=0)" "$(pk --biore Wykonawca "drugi temat" --sesja SESPPPPP)" 0
  spr "postęp przy DWÓCH otwartych bez tematu = rc=2" "$(pk --postep "x" --sesja SESPPPPP)" 2
  spr "postęp z tematem wybiera jedną (rc=0)" "$(pk --postep "w drugim" "drugi temat" --sesja SESPPPPP)" 0
  spr "oddaje drugi temat (rc=0)" "$(pk --oddaje Wykonawca "drugi temat" --sesja SESPPPPP)" 0
  OUT="$(pko --oddaje Wykonawca --sesja SESPPPPP)"
  printf '%s\n' "$OUT" | grep -q 'DO WĄTKU' && spr "oddaje drukuje nagłówek DO WĄTKU" 0 0 || spr "oddaje drukuje nagłówek DO WĄTKU" 1 0
  A1="$(printf '%s\n' "$OUT" | grep -n 'krok pierwszy' | cut -d: -f1)"; A2="$(printf '%s\n' "$OUT" | grep -n 'krok drugi' | cut -d: -f1)"
  [ -n "$A1" ] && [ -n "$A2" ] && [ "$A1" -lt "$A2" ] && spr "oddaje drukuje OBIE linie postępu w kolejności" 0 0 || spr "oddaje drukuje OBIE linie postępu w kolejności" 1 0
  printf '%s\n' "$OUT" | grep -q 'w drugim' && spr "oddaje NIE drukuje postępu cudzego (drugiego, oddanego wcześniej) tematu" 1 0 || spr "oddaje NIE drukuje postępu cudzego (drugiego, oddanego wcześniej) tematu" 0 0
  spr "postęp po oddaniu wszystkiego = rc=1" "$(pk --postep "za późno" --sesja SESPPPPP)" 1

  rm -rf "$T"
  echo "  zmierzone: zdanych $z · oblanych $o"
  [ "$o" -eq 0 ] || { echo "  ✗ TOR OBLANY"; exit 1; }
  echo "  ✓ STRAŻ UMIE NIE PRZEJŚĆ — reguła nie obowiązuje wyłącznie w dokumentacji."
  exit 0
fi

# ── PRZEBIEG ŻYWY ─────────────────────────────────────────────────────────────
echo "▤ STRAŻ FEROMONÓW v2 (trop bio #2) — kto co bierze TERAZ (wskaźnik: SESJA, wiek tylko dopisek):"

if [ -n "$REJESTR" ] && [ ! -f "$REJESTR" ]; then
  echo "   ✗ brak rejestru $REJESTR — straż NIE ZMIERZYŁA, więc się nie zieleni (#39)."
  exit 1
fi

OTWARTE="$(lokalny_widok | otwarte_tsv)"

if [ -z "$OTWARTE" ]; then
  echo "   ✓ żadnego otwartego śladu — jedna sesja albo cisza. Stan zdrowy (zero znaczące)."
  exit 0
fi

KLUCZE="$(printf '%s\n' "$OTWARTE" | cut -d"$(printf '\037')" -f1 | sort -u)"
ILE="$(printf '%s\n' "$KLUCZE" | grep -c .)"

printf '%s\n' "$OTWARTE" | while IFS="$(printf '\037')" read -r k s r m od co; do
  w=$(( ($(date +%s) - $(epoch_z "$od")) / 3600 ))
  echo "   • [$r · ${s:-$k} · ${m:-?}] $co — otwarte $(wiek_txt "$od")"
  [ "$w" -lt "$PROG_H" ] || echo "     ⓘ ślad starszy niż ${PROG_H}h — sesja mogła umrzeć; przejąć: --biore … --przejmuje ${s:-?} (wiek NIE odblokowuje)."
done

if [ "$ILE" -gt 1 ]; then
  echo "   ✗ KOLIZJA: $ILE różne sesje mają otwarte karteczki jednocześnie."
  echo "     Uzgodnij zakres, ZANIM zbudujesz — albo przenieś temat jawnie (--przejmuje)."
  exit 1
fi

echo "   ✓ jedna sesja w polu — brak kolizji."
exit 0
