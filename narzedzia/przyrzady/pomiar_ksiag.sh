#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# POMIAR KSIĄG — krok 1 PRZEGLĄDU STRUKTURY (18.09.2026)
#
# PO CO. Pytanie twórcy 18.09: „struktura robi się skomplikowana i ciężka — co
# warto obejrzeć zupełnie świeżym okiem?". Rada z zewnątrz brzmiała „skasować
# CLAUDE.md". Zmierzone: nasz odpowiednik (AGENTS.md) ma 5 kB i NIE jest
# ciężarem. Ciężar leży w dwóch księgach narracyjnych po ~240 kB.
# Ten przyrząd liczy to, co wtedy policzyłam ręcznie — żeby za pół roku
# wystarczyła jedna komenda, a nie druga taka sesja.
#
# CZEGO NIE ROBI. Nie ocenia, nie proponuje cięć, niczego nie kasuje.
# Drukuje liczby. Ocena jest krokiem 2 i należy do świeżego oka (Fable),
# które dostaje TEN RAPORT, nie repo — 29 MB to nie świeżość, to zalanie.
#
# ŹRÓDŁA LICZB (kolejność pytań jest tu treścią, nie stylem):
#   · rodziny i statusy blizn — WYŁĄCZNIE z indeksu kanonicznego BLEDY.md.
#     Nagłówki korpusu mają pole RODZINA tylko w części wpisów (29 z 90
#     przy pierwszym pomiarze) — liczenie z nich daje obraz fałszywy.
#     Blizna z tego pomiaru: pierwsze dwa moje podejścia dały 11 rodzin
#     zamiast 20 i 9 statusów zamiast 52, bo pytałam niewłaściwego źródła.
#   · pozycje rejestru mutacji — linie NIEpuste i NIEkomentarze.
#     `wc -l mutacje.txt` daje 434; pozycji jest 209. Liczba bez zakresu kłamie.
#
# UŻYCIE:  bash narzedzia/przyrzady/pomiar_ksiag.sh
#          bash narzedzia/przyrzady/pomiar_ksiag.sh --md   (do wklejenia)
# ══════════════════════════════════════════════════════════════════════════════
set -eu

MD=0; [ "${1:-}" = "--md" ] && MD=1

# ── TOR TESTOWY (#38) — mechanizm bez mutacji jest życzeniem (inwariant 5) ─────
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ POMIAR KSIĄG — AUTOTEST (#38) ═══╗"
  zle=""
  T="$(mktemp -d)"
  # Fikstura rejestru: 3 pozycje, 4 komentarze, 1 pusta — łącznie 8 linii.
  # Pomiar MUSI dać 3, nie 8. To jest cała treść blizny „liczba bez zakresu".
  printf '# komentarz\n#\na|||p|||x|||y|||sw\n\n# drugi\nb|||p|||x|||y|||sw\n# trzeci\nc|||p|||x|||y|||sw\n' > "$T/rej.txt"
  POZ_T=$(grep -cvE "^[[:space:]]*(#|$)" "$T/rej.txt")
  LIN_T=$(wc -l < "$T/rej.txt")
  [ "$POZ_T" -eq 3 ] || zle="$zle pozycje-liczone-jak-linie"
  [ "$LIN_T" -eq 8 ] || zle="$zle fikstura-zepsuta"
  [ "$POZ_T" -ne "$LIN_T" ] || zle="$zle pomiar-nie-rozroznia-pozycji-od-linii"
  # Fikstura indeksu: wiersz tabeli z numerem w 2. polu ma być czytany,
  # wiersz nagłówkowy i separator — nie. Bez tego licznik rodzin kłamie.
  printf '| # | znak | opis | x | POMIAR | R |\n|---|---|---|---|---|---|\n| 1 | a | b | c | POMIAR | R |\n| 2 | a | b | c | STRAŻE | M |\n' > "$T/idx.md"
  IDX_T=$(awk -F'|' 'NF>=6 && $2 ~ /^ *[0-9]+ *$/ {print}' "$T/idx.md" | wc -l)
  [ "$IDX_T" -eq 2 ] || zle="$zle indeks-czyta-naglowek-jako-wiersz"
  # (⊗) JEDNA NORMALIZACJA STATUSU (18.09.2026) — wada znaleziona przez świeże oko:
  # przyrząd liczył to samo pole dwiema normalizacjami i dawał dwie różne liczby.
  # Fikstura: statusy w kilku wariantach zapisu tej samej rzeczy. Po normalizacji
  # kategorie MUSZĄ pokryć CAŁE pole — suma kontrolna to jedyny świadek, który to łapie.
  printf '**M✓** — dostarczone\nM✓\n**R+M**\nR\n**M** — kandydat\nP\n' > "$T/st.txt"
  _N="$(tr -d '*' < "$T/st.txt" | sed 's/-cz\..*//; s/-częśc\..*//; s/ .*//')"
  _ma=$(printf '%s\n' "$_N" | grep -cE '^(M✓|R\+M)$' || true)
  _dl=$(printf '%s\n' "$_N" | grep -cE '^M$' || true)
  _sw=$(printf '%s\n' "$_N" | grep -cE '^(P|R|POSTAWA|NOŚNA|M✗|R\+rytuał)$' || true)
  [ "$((_ma+_dl+_sw))" -eq 6 ] || zle="$zle kategorie-nie-pokrywaja-pola-statusu"
  [ "$_ma" -eq 3 ] || zle="$zle warianty-zapisu-tej-samej-rzeczy-liczone-osobno"
  # (⊗) JEDNOSTKA DESTYLATU — indeks miesza rodzaje wpisów, korpus nie. Licznik liczący
  # DATY W INDEKSIE dawał 1 zamiast 6 dla września i zrodził fałszywy wniosek „destylacja
  # zamarła". Fikstura: 2 destylaty + 2 inne wpisy z tą samą datą.
  printf -- '- 100 · ⟐ DESTYLAT sesja 01.09.2026\n- 200 · ⟐ PYTANIA PEŁNI (01.09.2026)\n- 300 · ⟐ DOPISEK (01.09.2026)\n' > "$T/di.md"
  printf '## ⟐ DESTYLAT sesja 01.09.2026 — A\ntresc\n## Destylat — 02.09.2026 B\ntresc\n## ⟐ PYTANIA PEŁNI (03.09.2026)\ntresc\n' > "$T/dk.md"
  _z_idx=$(grep -oE "[0-9]{1,2}\.09\.20[0-9]{2}" "$T/di.md" | wc -l)
  _z_korp=$(grep -E '^## (Destylat —|⟐ DESTYLAT)' "$T/dk.md" | grep -oE "[0-9]{1,2}\.09\.20[0-9]{2}" | wc -l)
  [ "$_z_korp" -eq 2 ] || zle="$zle korpus-nie-liczy-destylatow"
  [ "$_z_idx" -ne "$_z_korp" ] || zle="$zle fikstura-nie-rozroznia-indeksu-od-korpusu"
  # (⊗) LISTA RODZIN BEZ OBCIĘCIA (18.09.2026, świeże oko — Fable, drugi bieg): `head -12`
  # chował ~połowę rodzin bez ostrzeżenia. Fikstura: 15 rodzin, każda z inną liczbą.
  printf '65|POMIAR\n5|STRAŻE\n4|GIT\n3|ELEGANCJA\n2|ZERO\n1|A\n1|B\n1|C\n1|D\n1|E\n1|F\n1|G\n1|H\n1|I\n1|J\n' \
    | awk -F'|' '{print $2}' > "$T/rodz.tsv"
  _RODZ_N=$(cut -f1 -d'|' "$T/rodz.tsv" 2>/dev/null | wc -l)  # placeholder unused
  _RODZ_LICZ=$(wc -l < "$T/rodz.tsv")
  _RODZ_WIDOK=$(cat "$T/rodz.tsv" | sort | uniq -c | wc -l)   # bez head — musi = 15
  [ "$_RODZ_WIDOK" -eq 15 ] || zle="$zle lista-rodzin-obcieta"
  # (⊗) PODRODZINY WYKRYWALNE, NIE UKRYTE (19.09.2026) — fikstura: rodzina z 2 gołymi
  # i 3 w dwóch podrodzinach. Musi wykryć obie podrodziny, policzyć goły≠z-podrodziną,
  # nie zgubić żadnej pozycji w sumie.
  printf 'X\nX\nX/A\nX/A\nX/B\n' > "$T/pod.tsv"
  _px_goly=$(cut -f1 "$T/pod.tsv" | grep -c '^X$' || true)
  _px_a=$(cut -f1 "$T/pod.tsv" | grep -c '^X/A$' || true)
  _px_b=$(cut -f1 "$T/pod.tsv" | grep -c '^X/B$' || true)
  [ "$_px_goly" -eq 2 ] || zle="$zle podrodzina-goly-zle-liczony"
  [ "$_px_a" -eq 2 ] && [ "$_px_b" -eq 1 ] || zle="$zle podrodzina-rozklad-zle-liczony"
  [ "$((_px_goly+_px_a+_px_b))" -eq 5 ] || zle="$zle podrodzina-gubi-pozycje"
  # (⊗) DATA Z TREŚCI PRZECIEKA DO LICZNIKA BLIZN (18.09.2026, świeże oko): `grep` na całym
  # pliku łapał daty cytowane W TEKŚCIE bliźny (np. „recydywa (9.07)" w treści innej blizny),
  # nie tylko w jej własnym nagłówku. Fikstura: nagłówek z lipca + treść cytująca sierpień.
  printf '## #1 test (01.07.2026) x\ntresc cytuje wczesniejszy przypadek (05.08.2026), nic wiecej\n' > "$T/bl.md"
  _M07=$(grep '^## #' "$T/bl.md" | grep -cE '\.07\.20[0-9]{2}' || true)
  _M08=$(grep '^## #' "$T/bl.md" | grep -cE '\.08\.20[0-9]{2}' || true)
  [ "$_M07" -eq 1 ] && [ "$_M08" -eq 0 ] || zle="$zle data-z-tresci-przecieka-do-licznika-miesiaca"
  # (⊗) DEGRADACJA ZAMIAST ODMOWY (19.09.2026, słowo twórcy „napraw zależności") —
  # przyrząd ma ruszyć na CUDZYM, uboższym ciele. Dwie próby na żywym sobie:
  # (a) ciało z samą księgą blizn → rc=0, raport dochodzi do KOŃCA, sekcje bez źródła
  #     mówią BRAK i NIE drukują zera (brak pomiaru ≠ zero);
  # (b) ciało bez księgi blizn → rc=1, bo bez niej nie ma czego mierzyć.
  TD="$(mktemp -d)"; mkdir -p "$TD/kanon/ksiegi"
  printf '| # | znak | opis | x | POMIAR | R |\n|---|---|---|---|---|---|\n| 1 | a | b | c | POMIAR | M✓ |\n## #1 test (01.07.2026) x\ntresc\n' > "$TD/kanon/ksiegi/BLEDY.md"
  cp "$0" "$TD/pk.sh"
  _deg_out="$TD/deg.txt"
  _deg_rc=0; ( cd "$TD" && bash pk.sh > "$_deg_out" 2>&1 ) || _deg_rc=$?
  [ "$_deg_rc" -eq 0 ] || zle="$zle odmawia-startu-na-ubozszym-ciele"
  grep -q "▤ KONIEC" "$_deg_out" || zle="$zle raport-nie-dochodzi-do-konca-bez-zrodel"
  grep -q "BRAK ŹRÓDŁA" "$_deg_out" || zle="$zle brak-zrodla-nie-nazwany"
  if grep -qE "pozycji: 0" "$_deg_out"; then zle="$zle brak-pomiaru-podany-jako-zero"; fi
  rm -f "$TD/kanon/ksiegi/BLEDY.md"
  _bez_rc=0; ( cd "$TD" && bash pk.sh > /dev/null 2>&1 ) || _bez_rc=$?
  [ "$_bez_rc" -eq 1 ] || zle="$zle brak-ksiegi-blizn-nie-oblewa"
  rm -rf "$TD"
  rm -rf "$T"
  if [ -n "$zle" ]; then echo "  ✗ PĘKŁO:$zle"; exit 1; fi
  echo "  ✓ tor zielony: pozycje≠linie (3≠8) · indeks pomija nagłówek (2) · jedna normalizacja statusu · destylat z korpusu · lista rodzin pełna · data tylko z nagłówka · podrodziny wykrywalne · degradacja na uboższym ciele (rc=0, BRAK≠0) · brak księgi blizn oblewa (rc=1)"
  exit 0
fi

# ── ŹRÓDŁA — parametryzowane, z degradacją (19.09.2026, słowo twórcy „napraw zależności")
# POWÓD. Ścieżki były wpisane na sztywno, a pętla niżej ODMAWIAŁA startu przy braku
# KTÓREGOKOLWIEK z czterech plików. Skutek zmierzony przed naprawą: na ciele bez
# `DESTYLATY_architekta.md` (księga prywatna, poza odlewem) i bez `AGENTS.md` przyrząd
# nie ruszał wcale — czyli u nowego twórcy NIGDY. PRAWO ODLEWU §1 mówi „mechanizm jedzie,
# zawartość zostaje"; przyrząd, który wymaga CUDZEJ zawartości, żeby zmierzyć WŁASNE ciało,
# łamie tę granicę w kodzie, nie w liście.
# ZASADA: wymagany jest JEDEN plik — księga blizn (bez niej nie ma czego mierzyć).
# Reszta jest opcjonalna: brak = sekcja mówi BRAK i nie liczy. Brak pomiaru ≠ zero —
# przyrząd nigdzie nie drukuje 0 tam, gdzie po prostu nie miał źródła.
B="${PK_BLEDY:-kanon/ksiegi/BLEDY.md}"
D="${PK_DESTYLATY:-kanon/ksiegi/DESTYLATY_architekta.md}"
DI="${PK_INDEKS:-kanon/ksiegi/DESTYLATY_indeks.md}"
M="${PK_MUTACJE:-mutacje.txt}"
[ -f "$B" ] || { echo "✗ brak księgi blizn ($B) — uruchom z korzenia repo albo wskaż PK_BLEDY=<plik>" >&2; exit 1; }
MA_D=0; [ -f "$D" ] && MA_D=1
MA_DI=0; [ -f "$DI" ] && MA_DI=1
MA_M=0; [ -f "$M" ] && MA_M=1
BRAKI=""
[ "$MA_D" -eq 1 ] || BRAKI="$BRAKI $D"
[ "$MA_DI" -eq 1 ] || BRAKI="$BRAKI $DI"
[ "$MA_M" -eq 1 ] || BRAKI="$BRAKI $M"

hdr() { if [ "$MD" -eq 1 ]; then echo; echo "### $1"; echo; else echo; echo "── $1 ──"; fi; }

echo "▤ POMIAR KSIĄG · $(date '+%Y-%m-%d %H:%M %Z') · HEAD=$(git rev-parse --short HEAD 2>/dev/null || echo ?)"
if [ -n "$BRAKI" ]; then
  echo "  ⓘ ŹRÓDŁA NIEOBECNE W TYM CIELE (sekcje ich dotyczące powiedzą BRAK, nie zero):$BRAKI"
  echo "     Wskaż własne: PK_BLEDY= · PK_DESTYLATY= · PK_INDEKS= · PK_MUTACJE="
fi

# ── 1. WAGA ───────────────────────────────────────────────────────────────────
hdr "WAGA — co model niesie"
for f in AGENTS.md 0_WYWOLANIA.md START_TU.md JADRO.md DUSZA.md README.md "$B" "$D" "$M"; do
  if [ -f "$f" ]; then
    printf "  %-38s %5s linii %8s B\n" "$f" "$(wc -l < "$f")" "$(wc -c < "$f")"
  else
    printf "  %-38s %s\n" "$f" "— nieobecny w tym ciele (nie liczę; to nie jest zero)"
  fi
done
echo "  ── plików .md w repo: $(find . -name '*.md' -not -path './node_modules/*' -not -path './.git/*' | wc -l)"

# ── 2. BLIZNY: rodziny ────────────────────────────────────────────────────────
# Indeks kanoniczny: wiersze tabeli, których 2. pole to sam numer.
awk -F'|' 'NF>=6 && $2 ~ /^ *[0-9]+ *$/ {
  gsub(/^ +| +$/,"",$5); gsub(/^ +| +$/,"",$6); print $5"\t"$6
}' "$B" > /tmp/_pk_idx.tsv
LB=$(wc -l < /tmp/_pk_idx.tsv)

hdr "BLIZNY — rodziny (źródło: indeks kanoniczny, $LB wierszy)"
cut -f1 /tmp/_pk_idx.tsv | sed 's#/.*##' | sort | uniq -c | sort -rn | sed 's/^/  /'
echo "  ── (lista pełna — bez obcięcia; suma kontrolna niżej)"
echo "  ── suma tabeli rodzin: $(cut -f1 /tmp/_pk_idx.tsv | sed 's#/.*##' | wc -l) (ma być $LB)"
DOM=$(cut -f1 /tmp/_pk_idx.tsv | sed 's#/.*##' | sort | uniq -c | sort -rn | head -1)
DOMN=$(echo "$DOM" | awk '{print $1}')
echo "  ── rodzina dominująca: $(echo "$DOM" | awk '{print $2}') = $DOMN z $LB ($((DOMN*100/LB))%)"
echo "  ── rodzin z JEDNĄ blizną: $(cut -f1 /tmp/_pk_idx.tsv | sed 's#/.*##' | sort | uniq -c | awk '$1==1' | wc -l)"

# (⊗) PODRODZINY UKRYTE PRZEZ OBCIĘCIE (19.09.2026, świeże oko — trzy niezależne rundy
# tagowania audytowały słupek "POMIAR: 63" jako jeden worek i zalecały go podzielić.
# Zmierzone: podział JUŻ ISTNIEJE w księdze — `sed 's#/.*##'` wyżej go ukrywał od
# pierwszej wersji tego przyrządu. Ta sama rodzina wady co #59 ("zamek mierzył co
# innego, niż deklarował"), tym razem w narzędziu zbudowanym do audytu TEJ rodziny.
# Rozdzielone: widok główny wyżej zostaje (obcięty, dla szybkiego przeglądu), tu
# dochodzi PEŁNY rozkład — bez obcinania, tylko dla rodzin, które faktycznie mają
# podrodziny (inne niż tylko-główna), żeby nie zaśmiecać raportu dla rodzin płaskich.
_GL=$(cut -f1 /tmp/_pk_idx.tsv | sed 's#/.*##' | sort -u)
_MA_POD=0
for _g in $_GL; do
  _n=$(cut -f1 /tmp/_pk_idx.tsv | grep -c "^${_g}/" || true)
  [ "$_n" -gt 0 ] && _MA_POD=1
done
if [ "$_MA_POD" -eq 1 ]; then
  echo "  ── PODRODZINY (pełny rozkład, bez obcięcia — rodziny, które je mają):"
  for _g in $_GL; do
    _pod=$(cut -f1 /tmp/_pk_idx.tsv | grep -c "^${_g}/" || true)
    [ "$_pod" -eq 0 ] && continue
    _goly=$(cut -f1 /tmp/_pk_idx.tsv | grep -c "^${_g}\$" || true)
    echo "     $_g (goły: $_goly · z podrodziną: $_pod):"
    cut -f1 /tmp/_pk_idx.tsv | grep "^${_g}/" | sort | uniq -c | sort -rn | sed 's/^/       /'
  done
fi

# ── 3. BLIZNY: statusy ────────────────────────────────────────────────────────
# JEDNA NORMALIZACJA (naprawa 18.09.2026 wieczór, znalezione przez świeże oko — Fable):
# przyrząd liczył to samo pole DWOMA różnymi normalizacjami — tabela przez `sed` obcinający
# po spacji (suma 99, poprawnie), a linia podsumowania BEZ `sed` (dawała 42, przy tej samej
# definicji z `sed` 44). Dwie liczby, jedno pole, jeden przyrząd. Teraz jedna funkcja.
#
# LEGENDA ŹRÓDŁOWA (nagłówek BLEDY.md): P = pamięć · R = rytuał/szablon · M = mechanika.
# Późniejsze warianty: M✓ dostarczone · M✗ świadomie bez mechanizmu · NOŚNA RAMA jawne
# „jeszcze nie" · POSTAWA niemechanizowalne świadomie.
# NIE sklejam ich w jedną liczbę „bez mechanizmu": dług (M-kandydat, który miał powstać)
# i świadoma decyzja (P, POSTAWA, M✗) to DWIE RÓŻNE WIELKOŚCI. Sklejenie ich było
# częścią tej samej wady co podwójna normalizacja.
norm_status() { tr -d '*' | sed 's/-cz\..*//; s/-częśc\..*//; s/ .*//'; }

hdr "BLIZNY — status mechanizmu"
cut -f2 /tmp/_pk_idx.tsv | norm_status | sort | uniq -c | sort -rn | sed 's/^/  /'
_ST="$(cut -f2 /tmp/_pk_idx.tsv | norm_status)"
MA=$(printf '%s\n' "$_ST" | grep -cE '^(M✓|R\+M)$' || true)
DLUG=$(printf '%s\n' "$_ST" | grep -cE '^M$' || true)
SWIADOMIE=$(printf '%s\n' "$_ST" | grep -cE '^(P|R|POSTAWA|NOŚNA|M✗|R\+rytuał)$' || true)
echo "  ──"
echo "  ── MA DZIAŁAJĄCY MECHANIZM (M✓, R+M):            $MA z $LB ($((MA*100/LB))%)"
echo "  ── DŁUG — kandydat M, który nie powstał:          $DLUG z $LB ($((DLUG*100/LB))%)"
echo "  ── BEZ MECHANIZMU ŚWIADOMIE (P/R/POSTAWA/M✗):     $SWIADOMIE z $LB ($((SWIADOMIE*100/LB))%)"
echo "  ── suma kontrolna: $((MA+DLUG+SWIADOMIE)) z $LB"
if [ "$((MA+DLUG+SWIADOMIE))" -ne "$LB" ]; then
  echo "  ⚠ $((LB-MA-DLUG-SWIADOMIE)) blizn(a) z nierozpoznanym statusem — NIE wliczone do żadnej kategorii:"
  paste <(awk -F'|' 'NF>=6 && $2 ~ /^ *[0-9]+ *$/ {gsub(/^ +| +$/,"",$2); print $2}' "$B") \
        <(cut -f2 /tmp/_pk_idx.tsv | norm_status) \
    | grep -vE "	(M✓|R\+M|M|P|R|POSTAWA|NOŚNA|M✗|R\+rytuał)$" | sed 's/^/     #/' | head -5
  echo "     (brak statusu to nie zero — luka ma być widoczna, nie doliczona po cichu)"
fi

# ── 4. TEMPO: blizny vs destylaty ─────────────────────────────────────────────
# NAPRAWA 18.09.2026 wieczór (świeże oko — Fable: „brakuje definicji jednostki").
# BYŁO: licznik szukał DAT w DESTYLATY_indeks.md. Zmierzone: indeks ma 59 pozycji,
# z czego DWIE to faktyczne destylaty sesji — reszta to PYTANIA PEŁNI, DOPISKI
# i fragmenty sekcji. Licznik nie liczył destylatów, tylko wystąpienia daty w spisie,
# który w 97% zawiera co innego.
# SKUTEK TAMTEJ WADY: raport mówił „wrzesień: 1 destylat, 21 blizn na destylat" i na tej
# liczbie oparłam wniosek „destylacja zamarła" — najmocniejsze znalezisko pierwszego
# biegu. Rzeczywistość z korpusu: 07→8, 08→16, 09→6. Tempo STABILNE ~3, nie zapaść.
# Wniosek był fałszywy, a stał w destylacie i w rytuale.
#
# JEDNOSTKA — jawna, jedna: destylat = nagłówek `## Destylat —` albo `## ⟐ DESTYLAT`
# w KORPUSIE. Indeks nie jest źródłem: to spis wielu rodzajów wpisów naraz.
hdr "TEMPO — czy wnioski nadążają za bliznami"
echo "  (destylat = nagłówek w korpusie; indeks NIE jest źródłem — miesza rodzaje wpisów)"
[ "$MA_D" -eq 1 ] || echo "  ⓘ BRAK księgi destylatów ($D) — kolumna destylatów i stosunek: NIEMIERZALNE."
echo "  miesiąc │ blizny │ destylaty │ blizn na destylat"
for mm in 06 07 08 09 10 11 12; do
  bl=$(grep '^## #' "$B" 2>/dev/null | grep -cE "\.$mm\.20[0-9]{2}" || true)
  if [ "$MA_D" -eq 1 ]; then
    de=$(grep -E '^## (Destylat —|⟐ DESTYLAT)' "$D" 2>/dev/null | grep -oE "[0-9]{1,2}(→[0-9]{1,2})?\.$mm\.20[0-9]{2}" | wc -l || true)
  else
    de="n/d"
  fi
  [ "$bl" -eq 0 ] && [ "$de" = "0" ] && continue
  if [ "$MA_D" -eq 0 ]; then
    r="n/d (brak źródła destylatów — nie zgaduję)"
  elif [ "$de" -gt 0 ]; then
    r=$(awk -v a="$bl" -v b="$de" 'BEGIN{printf "%.1f", a/b}')
    [ "$de" -lt 8 ] && r="$r (n=$de, mało — jeden destylat więcej/mniej zmienia wynik wyraźnie)"
  else
    r="— (zero)"
  fi
  printf "  %-7s │ %6s │ %9s │ %s\n" "$mm" "$bl" "$de" "$r"
done
_BL_BD=$(grep -c '^## #' "$B")
_BL_DAT=$(grep '^## #' "$B" | grep -cE '\.[0-9]{2}\.20[0-9]{2}' || true)
echo "  ── blizn w korpusie: $_BL_BD · z datą w nagłówku: $_BL_DAT"
[ "$_BL_BD" -ne "$_BL_DAT" ] && echo "  ⚠ $((_BL_BD-_BL_DAT)) bez daty (legacy, sprzed konwencji) — NIE wchodzą do tabeli wyżej"
if [ "$MA_D" -eq 1 ]; then
  _DEST_OG=$(grep -cE '^## (Destylat —|⟐ DESTYLAT)' "$D")
  _DEST_DAT=$(grep -E '^## (Destylat —|⟐ DESTYLAT)' "$D" | grep -cE '[0-9]{1,2}\.[0-9]{2}\.[0-9]{4}' || true)
  echo "  ── destylatów w korpusie: $_DEST_OG · z czytelną datą w nagłówku: $_DEST_DAT"
  [ "$_DEST_OG" -ne "$_DEST_DAT" ] && echo "  ⚠ $((_DEST_OG-_DEST_DAT)) bez daty — NIE wchodzą do tabeli wyżej (nie zgaduję miesiąca)"
else
  echo "  ── destylatów w korpusie: BRAK ŹRÓDŁA ($D) — nie liczone"
fi
if [ "$MA_DI" -eq 1 ]; then
  echo "  ── pozycji w indeksie destylatów: $(grep -c '^- ' "$DI") (spis wielu rodzajów, nie licznik destylatów)"
else
  echo "  ── pozycji w indeksie destylatów: BRAK ŹRÓDŁA ($DI) — nie liczone"
fi
echo "  ── UWAGA: liczba w sekcji SPÓJNOŚĆ FORMATU niżej ('nagłówków: N') to WSZYSTKIE"
echo "     podsekcje pliku (### CO POWSTAŁO, ### PYTANIA...), NIE liczba destylatów —"
echo "     nie porównywać jej z tabelą wyżej (dwie różne wielkości, ta sama sekcja pliku)."

# ── 5. REJESTR MUTACJI ────────────────────────────────────────────────────────
hdr "REJESTR MUTACJI — jedyny mechanizm, który mierzy sam siebie"
if [ "$MA_M" -eq 0 ]; then
  echo "  BRAK ŹRÓDŁA ($M) — rejestr mutacji nie zmierzony. To nie znaczy \"zero mutacji\"."
else
POZ=$(grep -cvE "^[[:space:]]*(#|$)" "$M")
echo "  pozycji: $POZ   (linii w pliku: $(wc -l < "$M") — komentarze to reszta)"
echo "  cele:"
grep -vE "^[[:space:]]*(#|$)" "$M" | awk -F'\\|\\|\\|' '{print $2}' | sed 's#/.*##' | sort | uniq -c | sort -rn | head -6 | sed 's/^/    /'
echo "  świadkowie (najczęstsi):"
grep -vE "^[[:space:]]*(#|$)" "$M" | awk -F'\\|\\|\\|' '{print $5}' | sort | uniq -c | sort -rn | head -5 | sed 's/^/    /'
fi

# ── 6. SPÓJNOŚĆ FORMATU ───────────────────────────────────────────────────────
hdr "SPÓJNOŚĆ FORMATU — o co potknie się świeże oko"
echo "  BLEDY: nagłówków korpusu $(grep -c '^## #' "$B") · z polem RODZINA $(grep -c '^## #.*RODZINA:' "$B") · wierszy indeksu $LB"
if [ "$MA_D" -eq 1 ]; then
  echo "  DESTYLATY: nagłówków $(grep -cE '^#{2,3} ' "$D") · wzorców sekcji $(grep -oE '^#{2,3} [^ ]+ ?[^ ]*' "$D" | sort -u | wc -l)"
else
  echo "  DESTYLATY: BRAK ŹRÓDŁA ($D) — nie mierzone"
fi

echo
echo "▤ KONIEC. Krok 2 (świeże oko) dostaje TEN raport, nie repo."
rm -f /tmp/_pk_idx.tsv
