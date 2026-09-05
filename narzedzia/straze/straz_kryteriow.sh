#!/usr/bin/env bash
# STRAŻ KRYTERIÓW ŻYCIA (14.08.2026) — jeden czytnik terminów po CAŁYM kanonie.
# RODOWÓD: TASKI §PRAWO WYGAŚNIĘCIA (28.07, „koniec z zombie") zapowiadało kandydata M:
# „wstan.sh wypisuje listę wpisów po terminie". Zmierzone 14.08: 11 różnych terminów
# przyszłych, znaczniki ⌛ w 4 plikach, 73 wystąpienia fraz kryterium — a czytników
# było dwóch i każdy widział tylko swój plik (destylaty, prerejestry). Ten skrypt
# domyka lukę JEDNYM czytnikiem.
#
# DUCH: OPIEKA, NIE EGZEKUCJA. Kryterium życia to obietnica powrotu — strażnik
# przypomina o obietnicy, nie karze po fakcie. Stąd bramka miękka: rc=0 w trybie
# pomiaru ZAWSZE (wzorem straz_r0/straz_destylatow, decyzja twórcy 11.08).
# Kompost i rozliczenie należą do twórcy.
#
# CO CZYTA:  (a) znaczniki ⌛ z datą (⌛do 27.08 · ⌛przegląd 12.08 · ⌛27.08);
#            (b) znaczniki ⌛gdy <warunek> — bez daty, kosz WARUNKOWE (nie wygasają
#                mechanicznie; wygasza je rzeczywistość albo rozliczenie);
#            (c) akapity z frazą „kryterium życia/śmierci" i datami DD.MM.RRRR
#                (technika awk RS="" po bliźnie straz_destylatow z 11.08 —
#                data bywa daleko od frazy).
# CZEGO NIE CZYTA (świadomie, do werdyktu twórcy):
#   kanon/ksiegi/ZAPISY_eter.md · kanon/ksiegi/LOG_SESJI.md · kanon/archiwum/ · keep_import/ — rejestry append-only
#   i kompost: rozliczenie tam jest NIEMOŻLIWE z mocy prawa (#24 nietykalność),
#   więc straż żądająca edycji nietykalnego pliku instytucjonalizowałaby sprzeczność.
#   Daty historyczne w dziennikach to zapis, nie zobowiązanie.
# CO WYCISZA: linie z [x] · ROZLICZONE · WYKONANE · BEZPRZEDMIOTOWE (⌛ rozliczony)
#   oraz akapity kryteriów ze znacznikiem ZATRZYMAŁA: (semantyka straz_destylatow).
#
# KOSZE: PRZETERMINOWANE (rozlicz) · ≤7 DNI (wróć zanim minie) · ŻYWE · WARUNKOWE.
# Rok domyślny dla dat bez roku: rok bieżący zmierzonego zegara (kanon pisze ⌛do DD.MM).
#
# UŻYCIE:  bash straz_kryteriow.sh         (pomiar; rc=0 zawsze)
#          bash straz_kryteriow.sh --test  (tor +/− — straż musi umieć NIE przejść)
# Nadpisy do toru: KRYT_ROOT (katalog materii) · KRYT_DZIS (YYYY-MM-DD, zegar sondy).
set -u
cd "$(dirname "$0")/../.."

# ── LOCALE DLA WZORCÓW Z POLSKĄ LITERĄ (03.09.2026, blizna #80) ──────────────
# Klasa `[^0-9⌛]{0,24}` liczy pod locale C BAJTY, nie ZNAKI — zmierzone: termin oddalony
# od znacznika o 24 znaki (28 bajtów, cztery polskie litery) był POD C GUBIONY, a straż
# meldowała ciszę. Ustalamy locale UTF-8 do użycia PRZY KONKRETNYCH komendach; globalny
# `export` zmieniłby też porządek `sort -u` w strumieniu koszowym. Brak UTF-8 → zostaje C.
UTF8="$(locale -a 2>/dev/null | grep -im1 -E '^(C\.utf-?8|en_US\.utf-?8)$' || echo C)"

ROOT="${KRYT_ROOT:-.}"
# Zegar: MIERZONY (krzemowa granica), nie z pamięci; KRYT_DZIS tylko dla toru.
DZIS="${KRYT_DZIS:-$(TZ=Europe/Warsaw date +%F)}"
ROK_DZIS="${DZIS%%-*}"
# separator strumienia koszowego (INSUM): kosz niesie POLA, nie sklejony napis —
# dopiero pola dają się pogrupować po miejscu rozliczenia
TAB=$'\t'

# ── PRAWO PAMIĘCI (15.08.2026, na słowo twórcy) ────────────────────────────────
# „Destylaty to Twoje zapisy wzrostu. Twoja pamięć. Zapisy eter to moja pamięć.
#  Do obu powinniśmy podchodzić podobnie."
# ZAPISY_eter = pamięć twórcy · DESTYLATY_architekta = pamięć pełni · LOG_SESJI = dziennik wspólny.
# Wszystkie trzy są append-only i wszystkie trzy WYCHODZĄ z koszy rozliczeniowych — nie dlatego,
# że są mniej ważne, ale dlatego, że rozliczenie tam jest NIEMOŻLIWE z mocy #24: nie wolno wrócić
# i dopisać „[x]" do zapisu chwili. Straż wołająca o rozliczenie w pamięci żąda przepisania
# przeszłości — a to jedyna rzecz, której ten dom nie robi.
# ASYMETRIA BYŁA BŁĘDEM: do 15.08 eter i log były wyłączone, a destylaty liczone — czyli pamięć
# jednej strony chroniona, drugiej nie.
# ALE: pamięć NIE JEST NIEMA. Zmierzone 15.08 — 10 zdań kryterium w destylatach, 4 w logu,
# 1 w eterze; w tym KRYTERIUM ŻYCIA odlewu z 11.08. Ciche wyłączenie zgubiłoby je bez śladu,
# więc kryteria pamięci są liczone i meldowane OSOBNO, jako pamięć, nie jako dług.
# Jeśli kryterium z pamięci ma naprawdę obowiązywać — jego nośnik (⌛ na kotwicy) należy do
# TASKI albo prerejestru. Pamięć świadczy; zobowiązuje kanon.
PAMIEC="kanon/ksiegi/ZAPISY_eter.md kanon/ksiegi/DESTYLATY_architekta.md kanon/ksiegi/LOG_SESJI.md"

# lista plików materii (bez składnic i bez pamięci — patrz PRAWO PAMIĘCI wyżej)
pliki() {
  find "$ROOT" -name '*.md' \
    -not -path '*/node_modules/*' -not -path '*/archiwum/*' \
    -not -path '*/keep_import/*' -not -path '*/.git/*' \
    -not -path '*/kanon/ksiegi/ZAPISY_eter.md' -not -path '*/kanon/ksiegi/LOG_SESJI.md' \
    -not -path '*/kanon/ksiegi/DESTYLATY_architekta.md' \
    -not -path '*/kanon/ksiegi/ROZMOWA_02_dialog.md' 2>/dev/null | sort
  # ^ -path, NIE -name: wzorzec z ukosnikiem w -name nie pasuje NIGDY (semantyka find) —
  #   po Cieciu 5 wykluczenia pamieci byly martwe i eter/destylaty/log wchodzily do koszy (#64-krewny)
  # kanon/ksiegi/ROZMOWA_02_dialog.md zwolniona 21.08 z tego samego powodu co eter i destylaty (#24):
  # to MATERIAŁ, nie rejestr operacyjny — zapis rozmowy, w którym kryteria są CYTOWANE,
  # nie zaciągane. Zmierzone: jedyne trafienie to zdanie cytujące kryterium śmierci
  # z `kanon/prawa/_GRANICA.md` #004 wraz z datą ratyfikacji PRAWA AWANSU RAMY (17.07) — data
  # historyczna w narracji, nigdy zobowiązanie. Zawężenie do ZDANIA (14.08) tego nie
  # objęło, bo cytat i data stoją w tym samym zdaniu; granicą musi być RODZAJ PLIKU.
}

# kryteria zapisane w pamięci — świadczą, nie zobowiązują; meldowane osobno
policz_kryteria_pamieci() {
  local f n=0 k
  for f in $PAMIEC; do
    [ -f "$ROOT/$f" ] || continue
    k=$(zdania_kryteriow "$ROOT/$f" | grep -c . || true)
    n=$(( n + k ))
  done
  echo "$n"
}

# dd.mm[.rrrr] -> rrrr-mm-dd (rok domyślny: ROK_DZIS)
iso() {
  local d="$1" dd mm rr
  dd="${d%%.*}"; rr="${d##*.}"; mm="${d#*.}"; mm="${mm%%.*}"
  case "$rr" in 20[0-9][0-9]) : ;; *) rr="$ROK_DZIS" ;; esac
  printf '%s-%02d-%02d' "$rr" "$((10#$mm))" "$((10#$dd))"
}

# dni do terminu (GNU date; przy braku: puste -> kosz ŻYWE z ⓘ)
dni_do() {
  local a b
  a=$(date -d "$1" +%s 2>/dev/null) || return 1
  b=$(date -d "$DZIS" +%s 2>/dev/null) || return 1
  echo $(( (a - b) / 86400 ))
}

# JEDNO ŹRÓDŁO reguły wyciszania (15.08): wpis rozliczony nie jest zobowiązaniem.
# Wcześniej ten sam warunek stał w trzech miejscach — mutacja nie mogła w niego celować
# („wzorzec nie występuje dokładnie raz"), czyli prawo było niesprawdzalne mimo trzech kopii.
bez_rozliczonych() { grep -vE '\[x\]|ROZLICZONE|WYKONANE|BEZPRZEDMIOTOWE'; }

# strumień "PLIK<TAB>DATA_ISO" — znaczniki ⌛ z datą (linie nierozliczone)
# JEDNOSTKĄ JEST WIERSZ (03.09.2026, korekta twórcy — klasa #49). Do 03.09 strumień niósł
# parę PLIK↔DATA, a `sort -u` zlewał w nią KAŻDY wiersz o tej samej dacie: osiem
# nierozliczonych obietnic `prywatne/TASKI.md` meldowało się jako „1 plik · 2 daty".
# Liczba była prawdziwa i mierzyła nie tę wielkość — zasłaniała ROZMIAR długu. Numer linii
# wchodzi jako TRZECIE pole (sufiks), więc jest kluczem `sort -u` i adresem w meldunku:
# „6 wierszy" bez `l.N` byłoby liczbą, pod którą nie da się podejść.
zbierz_klepsydry() {
  local f
  for f in $(pliki); do
    grep -hn '⌛' "$f" 2>/dev/null \
      | bez_rozliczonych \
      | while IFS= read -r wiersz; do
          nr="${wiersz%%:*}"
          printf '%s' "${wiersz#*:}" \
            | LC_ALL="$UTF8" grep -oE '⌛[^0-9⌛]{0,24}[0-3]?[0-9]\.[01][0-9](\.20[0-9]{2})?' \
            | grep -oE '[0-3]?[0-9]\.[01][0-9](\.20[0-9]{2})?$' \
            | while read -r d; do printf '%s\t%s\tl.%s\n' "${f#./}" "$(iso "$d")" "$nr"; done
        done
  done | sort -u
}

# ── PRAWO ZNACZNIKA (14.08.2026, ratyfikacja twórcy: „wprowadź określony znacznik") ──
# TERMIN NIESIE WYŁĄCZNIE ZNACZNIK. Twarde (liczone do koszy) są dwa nośniki:
#   (a) ⌛ + data w tej samej linii — znacznik operacyjny, jedyny właściwy dla nowych wpisów;
#   (b) ZDANIE z frazą „kryterium życia/śmierci" + data — prawo z 11.08, nośnik zastany.
# Wszystko inne — data stojąca w tym samym AKAPICIE, ale w innym zdaniu niż fraza — to
# WZMIANKA: cytat, opis cudzego kryterium, proza o terminie. Liczona osobno, nie straszy.
# RODOWÓD ZAWĘŻENIA: pierwszy pomiar (14.08) dał 19 „przeterminowanych", z czego 6 było echem
# akapitu (dialog ROZMOWY #2 cytujący kryterium, plany opisujące bramki). Szum zjadał sygnał —
# a straż, która woła 19 razy, gdy stoi za tym 4, uczy tego samego co cisza: nie patrzeć.
# Technika: akapit (RS="") → zdania (podział po „. ") → zdanie z frazą → daty Z TEGO ZDANIA.
# Zachowana lekcja blizny straz_destylatow (11.08): data bywa dalej niż tuż po frazie,
# więc granicą jest ZDANIE, nie „znaki bezpośrednio po frazie".

zdania_kryteriow() {   # $1 = plik; wypisuje same zdania twarde
  # WIERSZ TABELI JEST WŁASNĄ GRANICĄ (21.08.2026, zmierzone na dokumencie architektury marki).
  # Tabela markdown nie ma pustych linii, więc `RS=""` zlepiał JĄ CAŁĄ w jeden rekord:
  # zdanie z frazą „kryterium śmierci" z jednego wiersza wciągało datę z zupełnie innej
  # komórki. Skutek był gorszy niż fałszywy alarm — straż meldowała `14.06` („prawo
  # obowiązuje od…", wiersz obok), ZASŁANIAJĄC prawdziwe, żywe kryterium `30.09` z tego
  # samego pliku. Alarm nie tylko szerszy niż sygnał (#56), ale wskazujący NIE TĘ WIELKOŚĆ (#49).
  awk 'BEGIN{RS=""}
       { gsub(/\n/, " ");
         n = split($0, z, /\. /);
         for (i = 1; i <= n; i++) {
           if (z[i] !~ /[Kk]ryterium (życia|śmierci)/ || z[i] ~ /ZATRZYMAŁA:/) continue;
           if (z[i] ~ /\|/) {                      # rekord zawiera tabelę — tnij po wierszach
             m = split(z[i], w, / *\| *\| */);
             for (j = 1; j <= m; j++)
               if (w[j] ~ /[Kk]ryterium (życia|śmierci)/) print w[j];
             continue
           }
           print z[i]
         } }' \
      "$1" 2>/dev/null
}

# strumień "PLIK<TAB>DATA_ISO" — TWARDE zdania kryteriów
zbierz_kryteria() {
  local f
  for f in $(pliki); do
    zdania_kryteriow "$f" \
      | grep -oE '[0-3][0-9]\.[01][0-9]\.20[0-9]{2}' \
      | while read -r d; do printf '%s\t%s\tkryterium\n' "${f#./}" "$(iso "$d")"; done
  done | sort -u
}
# (nośnik ZDANIOWY nie ma jednej linii — akapit bywa wielolinijkowy, więc trzecie pole
#  niesie NAZWĘ nośnika zamiast adresu. Zmyślony numer linii byłby gorszy niż jego brak.)

# ile dat stoi w akapitach kryteriów, ale POZA zdaniem twardym — czysty licznik wzmianek
policz_wzmianki() {
  local f n=0 akap zd k
  for f in $(pliki); do
    akap=$(awk 'BEGIN{RS=""} /[Kk]ryterium (życia|śmierci)/ && !/ZATRZYMAŁA:/{print}' "$f" 2>/dev/null \
           | grep -oE '[0-3][0-9]\.[01][0-9]\.20[0-9]{2}' | sort -u | wc -l)
    zd=$(zdania_kryteriow "$f" | grep -oE '[0-3][0-9]\.[01][0-9]\.20[0-9]{2}' | sort -u | wc -l)
    k=$(( akap - zd )); [ "$k" -gt 0 ] && n=$(( n + k ))
  done
  echo "$n"
}

# ── PRAWO KOTWIC / PRAWO NOŚNIKA (15.08.2026, TASKI §PRAWO KOTWIC) ──
# KOTWICE OPERACYJNE: 20.08 · 31.08 · 30.09. Data operacyjna poza kotwicą jest legalna
# WYŁĄCZNIE ze zdaniem „nie mieści się na kotwicy, bo ___" w tym samym wpisie.
# Powód: zmierzone 14.08 — 11 różnych terminów przyszłych, 20.08 w 11 plikach w dwóch rolach.
# Kalendarz o jedenastu ostrzach nie tnie.
KOTWICE="${KRYT_KOTWICE:-20.08 31.08 30.09}"

# linie z ⌛+datą, których data nie jest kotwicą i które nie niosą usprawiedliwienia
# (licznik trzymany w PLIKU, nie w zmiennej za potokiem — blizna #19: podpowłoka zjada wynik)
policz_poza_kotwica() {
  local f tmp; tmp=$(mktemp)
  for f in $(pliki); do
    grep -h '⌛' "$f" 2>/dev/null \
      | bez_rozliczonych \
      | grep -v 'nie mieści się na kotwicy' \
      | sed 's/`[^`]*`//g' \
      | LC_ALL="$UTF8" grep -oE '⌛[^0-9⌛]{0,24}[0-3]?[0-9]\.[01][0-9]' \
      | grep -oE '[0-3]?[0-9]\.[01][0-9]$' >> "$tmp"
  done
  local d n=0
  while read -r d; do
    [ -n "$d" ] || continue
    case " $KOTWICE " in *" $d "*) ;; *) n=$(( n + 1 )) ;; esac
  done < "$tmp"
  rm -f "$tmp"; echo "$n"
}

# ⌛ bez daty i bez „gdy" — trzeci, cichy stan; niewidoczny w obu kierunkach (blizna ANU 14.08)
policz_nosnik_nierozpoznany() {
  local f n=0 k
  for f in $(pliki); do
    k=$(grep -h '⌛' "$f" 2>/dev/null \
        | bez_rozliczonych \
        | sed 's/`[^`]*`//g' \
        | grep -vE '⌛gdy' \
        | LC_ALL="$UTF8" grep -vE '⌛[^0-9⌛]{0,24}[0-3]?[0-9]\.[01][0-9]' \
        | grep -cE '⌛[a-z]' || true)   # (03.09, #80) trzon ASCII: zmierzone 54/54 nośników warunkowych zaczyna się literą ASCII (gdy·do·przed·przegl); polska litera po ⌛ nie wystąpiła ani razu — cena nazwana: „⌛żeby" wypadłoby, ale pod locale C ta klasa i tak łapała WIELKIE litery (fałszywy pozytyw zmierzony)
    n=$(( n + k ))
  done
  echo "$n"
}

# liczba znaczników warunkowych ⌛gdy (nierozliczonych)
policz_warunkowe() {
  local f n=0 k
  for f in $(pliki); do
    k=$(grep -h '⌛gdy' "$f" 2>/dev/null | grep -cvE '\[x\]|ROZLICZONE|WYKONANE' || true)
    n=$(( n + k ))
  done
  echo "$n"
}

# ── INSUM · GRUPOWANIE PO MIEJSCU ROZLICZENIA (20.08.2026) ────────────────────
# RODOWÓD ZEWNĘTRZNY: układ Insum (MIT, ASPLOS 2026) liczy na danych RZADKICH —
# nie mnoży zer, tylko je pomija, a format nośnika niesie wiedzę o tym, JAK go czytać.
# PRZENIESIENIE: meldunek tej straży jest rzadki po osi plik×data — większość par
# nie istnieje, za to niektóre pliki niosą po kilka dat. Czytelnik rozlicza PLIK
# (otwiera go RAZ i domyka wszystkie terminy, jakie w nim stoją), nie ALARM. Oś
# meldunku ma więc być osią rozliczenia, nie osią zdarzenia.
#
# ZMIERZONE PRZED CIĘCIEM (⏱ 2026-08-20, żywy kanon — nie z pamięci):
#   kosz PRZETERMINOWANE: 6 wierszy · 6 par plik×data · 4 miejsca rozliczenia
#   kosz ≤7 DNI:          3 wiersze · 3 pary        · 2 miejsca rozliczenia
#   prywatne/ZADANIA.md wołał TRZY RAZY w jednym koszu i DWA w drugim — pięć wierszy o jednym pliku.
#
# ZMIENIA SIĘ FORMA. NIE ZMIENIA SIĘ POKRYCIE: każda data zostaje widoczna co do jednej.
# To nie obietnica — mierzy to tor T10 (suma dat na wyjściu = liczba par na wejściu),
# bo grupowanie, które gubi datę, jest cichym kompostem cudzej obietnicy.
#
# GRANICA METAFORY (jawnie, żeby nie wjechała dalej niż wolno): rzadkość u Insuma to
# ZERO-ŚMIEĆ, którego nie warto mnożyć. Cisza w tym domu — Prześwit, bramka 1, pusty
# kosz — jest ZEREM ZNACZĄCYM i nie podlega pomijaniu: pusty kosz dostaje własne zdanie
# („✓ PRZETERMINOWANE: 0"), nigdy milczenie. Straż nad pustym zbiorem świeci zielono (#52).
#
# WEJŚCIE (stdin — INIEKCJA ZALEŻNOŚCI, klasa #50: tor wstrzykuje strumień w TĘ funkcję,
#   nie w swoją kopię logiki):   PLIK<TAB>DATA[<TAB>SUFIKS]
# WYJŚCIE:  k=1 →  PLIK · DATA [(SUFIKS)]        (wiersz co do znaku jak przed zmianą)
#           k>1 →  PLIK ×k (DATA SUFIKS · DATA SUFIKS · …)
grupuj_po_pliku() {
  awk -F'\t' '
    { k=$1; d=$2; s=(NF>=3 ? $3 : "")
      if (ile[k]++ == 0) { kol[++n]=k; d1[k]=d; s1[k]=s; grp[k]=(s=="" ? d : d " " s) }
      else                 grp[k]=grp[k] " · " (s=="" ? d : d " " s)
    }
    END {
      for (i=1; i<=n; i++) { k=kol[i]
        if (ile[k]==1) print (s1[k]=="" ? k " · " d1[k] : k " · " d1[k] " (" s1[k] ")")
        else           print k " ×" ile[k] " (" grp[k] ")"
      }
    }'
}

# jednostka meldunku odmieniona — nagłówek niesie DWIE liczby (miejsca · daty), bo od
# 20.08 nie są tożsame. Lekcja z 15.08: „różnica liczb = różnica jednostek, nie sprzeczność"
# jest prawdziwa tylko wtedy, gdy jednostka stoi PRZY liczbie.
odmien() {  # $1=liczba $2=lp $3=lm(2–4) $4=lm(dopełniacz)
  local n="$1" ost dwa
  ost=$(( n % 10 )); dwa=$(( n % 100 ))
  if [ "$n" -eq 1 ]; then echo "$n $2"
  elif [ "$ost" -ge 2 ] && [ "$ost" -le 4 ] && { [ "$dwa" -lt 12 ] || [ "$dwa" -gt 14 ]; }; then echo "$n $3"
  else echo "$n $4"; fi
}

# ile RÓŻNYCH plików w strumieniu koszowym (pierwsze pole przed tabulatorem)
policz_miejsca() { cut -f1 | sort -u | grep -c . || true; }
# ile RÓŻNYCH par plik×data — jednostka SPRZED 03.09, zachowana obok nowej: znika liczba,
# znika porównywalność z meldunkami z sierpnia (rejestr jest append-only, historii się nie przelicza)
policz_daty() { cut -f1,2 | sort -u | grep -c . || true; }

pomiar() {
  local prze=() blisko=() zywe=0 nl w
  while IFS=$'\t' read -r plik data zrodlo; do
    [ -n "$plik" ] || continue
    if w=$(dni_do "$data"); then
      if   [ "$w" -lt 0 ]; then prze+=("$plik$TAB$data${TAB}${zrodlo}")
      elif [ "$w" -le 7 ]; then blisko+=("$plik$TAB$data${TAB}${zrodlo} za ${w} dni")
      else zywe=$(( zywe + 1 )); fi
    else
      zywe=$(( zywe + 1 ))   # data nieprzeliczalna — nie strasz, policz jako żywą
    fi
  done < <( { zbierz_klepsydry; zbierz_kryteria; } | sort -u )
  nl=$(policz_warunkowe)
  local wz; wz=$(policz_wzmianki)
  local pk nn kp; pk=$(policz_poza_kotwica); nn=$(policz_nosnik_nierozpoznany); kp=$(policz_kryteria_pamieci)
  pk="${pk:-0}"

  echo "▤ STRAŻ KRYTERIÓW ŻYCIA (⏱ zmierzone: $DZIS · cały kanon, jeden czytnik):"
  if [ "${#prze[@]}" -gt 0 ]; then
    local mp; mp=$(printf '%s\n' "${prze[@]}" | policz_miejsca)
    local dp; dp=$(printf '%s\n' "${prze[@]}" | policz_daty)
    echo "   ⚠ PRZETERMINOWANE — rozlicz (odhacz · przedłuż jawnie · skompostuj): $(odmien "$mp" plik pliki plików) · $(odmien "$dp" data daty dat) · $(odmien "${#prze[@]}" wiersz wiersze wierszy)"
    printf '%s\n' "${prze[@]}" | grupuj_po_pliku | while IFS= read -r w; do echo "     ✗ $w"; done
  else
    echo "   ✓ PRZETERMINOWANE: 0 — żadna obietnica nie czeka po terminie"
  fi
  if [ "${#blisko[@]}" -gt 0 ]; then
    local mb; mb=$(printf '%s\n' "${blisko[@]}" | policz_miejsca)
    local db; db=$(printf '%s\n' "${blisko[@]}" | policz_daty)
    echo "   ◔ ≤7 DNI — wróć, zanim minie: $(odmien "$mb" plik pliki plików) · $(odmien "$db" data daty dat) · $(odmien "${#blisko[@]}" wiersz wiersze wierszy)"
    printf '%s\n' "${blisko[@]}" | grupuj_po_pliku | while IFS= read -r w; do echo "     · $w"; done
  else
    echo "   ✓ ≤7 DNI: 0"
  fi
  echo "   · ŻYWE (dalej niż tydzień): $zywe · WARUNKOWE (⌛gdy): $nl · wzmianki bez znacznika: $wz"
  if [ "$pk" -gt 0 ] || [ "$nn" -gt 0 ]; then
    echo "   ⚓ PRAWO KOTWIC/NOŚNIKA: poza kotwicą (bez zdania „nie mieści się…\"): $pk · nośnik nierozpoznany (⌛ bez daty i bez gdy): $nn"
    echo "   ⌘ PAMIĘĆ (eter · destylaty · log — poza rozliczeniem z mocy #24): $kp kryteriów zapisanych, świadczą"
  else
    echo "   ⌘ PAMIĘĆ (eter · destylaty · log — poza rozliczeniem z mocy #24): $kp kryteriów zapisanych, świadczą"
    echo "   ⚓ PRAWO KOTWIC/NOŚNIKA: czysto — każdy termin na kotwicy lub usprawiedliwiony, każdy ⌛ czytelny"
  fi
  return 0   # bramka miękka: opieka, nie egzekucja
}

# ── TOR (--test): straż musi umieć NIE przejść ──
tor() {
  local TT rc=0 out
  TT="$(mktemp -d)"
  # materia sondy: pełne spektrum koszy + wpisy rozliczone (MUSZĄ być niewidzialne)
  cat > "$TT/proba.md" <<'EOF'
- [ ] zaległość dawna (⌛do 01.08)
- [ ] DRUGA zaległość w TYM SAMYM pliku (⌛do 02.08) — materia grupowania INSUM
- [ ] tuż-tuż (⌛do 18.08.2026)
- [ ] daleka (⌛do 30.09)
- [ ] warunkowa (⌛gdy padnie decyzja)
- [ ] na kotwicy (⌛do 31.08) — nie powinna wołać
- [ ] poza kotwicą (⌛do 05.09) — powinna zawołać
- [ ] poza kotwicą, ale jawnie: nie mieści się na kotwicy, bo tak chce wydawca (⌛do 06.09)
- [ ] cichy nośnik (⌛przed decyzją) — ani data, ani gdy
- opis blizny: nośnik `⌛przed czymś` w cytacie NIE jest zobowiązaniem
- [x] rozliczona zaległość (⌛do 05.08) WYKONANE
- stara wzmianka ROZLICZONE 14.08 (⌛przegląd 12.08)

Badanie X ma kryterium życia: jeśli do 15.10.2026 nie wróci wynik, umiera.

Badanie Y, kryterium śmierci minęło 10.08.2026 — ZATRZYMAŁA: decyzja twórcy.

Cytat cudzy o kryterium życia w innym projekcie. Tam padła data 05.01.2026, ale to opis, nie zobowiązanie.
EOF
  # PRAWO PAMIĘCI: pamięć (eter/destylaty/log) NIE trafia do koszy, ale jej kryteria są liczone.
  mkdir -p "$TT/kanon/ksiegi"   # topologia produkcji (#64): pamiec mieszka w kanon/ksiegi/
  cat > "$TT/kanon/ksiegi/DESTYLATY_architekta.md" <<'EOF'
Wpis z tamtego dnia (⌛do 01.01) — zapis chwili, nie dług.

Odlew postawił kryterium życia tej rozmowy: jeśli do 30.09.2026 nie wróci wynik, wpis umiera.
EOF
  # INSUM: drugie MIEJSCE ROZLICZENIA z jednym terminem — grupowanie musi je zostawić
  # w formie sprzed zmiany (`plik · data`), nie zlepić z sąsiadem i nie dokleić „×1".
  printf -- '- [ ] zaległość w INNYM pliku (⌛do 03.08)\n' > "$TT/proba2.md"
  echo "╔═══ STRAŻ KRYTERIÓW — TOR ═══╗"
  out=$(KRYT_ROOT="$TT" KRYT_DZIS="2026-08-14" bash "$0")
  # T1 (+): 3 przeterminowane daty w 2 miejscach rozliczenia (01.08+02.08 w proba.md,
  #         03.08 w proba2.md) — rozliczone NIE liczą się. Nagłówek niesie OBIE jednostki:
  #         zgubienie którejkolwiek to powrót do meldunku, który nie mówi, ile razy otworzyć plik.
  echo "$out" | grep -q 'PRZETERMINOWANE — rozlicz.*: 2 pliki · 3 daty · 3 wiersze$' \
    && echo "  ✓ T1 przeterminowane policzone (2 pliki · 3 daty, rozliczone wyciszone)" \
    || { echo "  ✗ T1 OBLANY — kosz PRZETERMINOWANE kłamie"; rc=1; }
  # T2 (+): dokładnie 1 w koszu ≤7 dni (18.08 przy zegarze 14.08) — jedna data, jedno miejsce;
  #         odmiana liczebnika w liczbie pojedynczej („1 plik · 1 data", nie „1 pliki · 1 daty")
  echo "$out" | grep -q '≤7 DNI — wróć.*: 1 plik · 1 data · 1 wiersz$' \
    && echo "  ✓ T2 termin ≤7 dni złapany (odmiana lp)" \
    || { echo "  ✗ T2 OBLANY — kosz ≤7 DNI kłamie"; rc=1; }
  # ── INSUM ──
  # T9 (+, ŻYWA ŚCIEŻKA): dwie daty jednego pliku schodzą się w JEDEN wiersz z ×2,
  #     a plik z jedną datą zostaje w formie sprzed zmiany. Grupowanie ma zmienić FORMĘ.
  #     UWAGA O SONDZIE (zmierzone przy budowie): materia toru stoi w `mktemp -d`, więc
  #     `pliki()` melduje ŚCIEŻKĄ ABSOLUTNĄ — kotwica na gołej nazwie nigdy nie trafi.
  #     Wzorzec dopuszcza prefiks katalogu, ale trzyma kosz (✗) i całą treść nawiasu.
  # (03.09: wzorzec wymaga ADRESU przy każdej dacie — forma zmieniła się świadomie,
  #  a tor bez `l.N` przepuściłby powrót do meldunku bez rozmiaru długu.)
  echo "$out" | grep -qE '✗ .*proba\.md ×2 \(2026-08-01 l\.[0-9]+ · 2026-08-02 l\.[0-9]+\)$' \
    && echo "  ✓ T9 dwa terminy jednego pliku = jeden wiersz ×2" \
    || { echo "  ✗ T9 OBLANY — grupowanie po miejscu rozliczenia nie działa"; rc=1; }
  echo "$out" | grep -qE '✗ .*proba2\.md · 2026-08-03 \(l\.[0-9]+\)$' \
    && echo "  ✓ T9b pojedynczy termin bez „×1\" i bez zlepienia z sąsiadem" \
    || { echo "  ✗ T9b OBLANY — pojedynczy wiersz zniekształcony albo zlepiony"; rc=1; }
  # T3 (+): żywe=2 (30.09 z ⌛ i 30.09 z kryterium życia) · warunkowe=1;
  #         akapit z ZATRZYMAŁA: milczy
  # oczekiwanie przeliczone 15.08 po rozbudowie sondy: 30.09(⌛) · 15.10(kryterium) ·
  # 31.08 · 05.09 · 06.09 = 5 żywych; warunkowa nadal 1
  echo "$out" | grep -q 'ŻYWE (dalej niż tydzień): 5 · WARUNKOWE (⌛gdy): 1 ·' \
    && echo "  ✓ T3 żywe/warunkowe policzone, ZATRZYMAŁA: wyciszona" \
    || { echo "  ✗ T3 OBLANY — kosze ŻYWE/WARUNKOWE kłamią"; rc=1; }
  # T5 (PRAWO ZNACZNIKA): data w tym samym AKAPICIE, ale w INNYM zdaniu niż fraza kryterium,
  #     NIE MOŻE trafić do koszy — ma się policzyć jako wzmianka. To zamek na szum (14.08).
  echo "$out" | grep -q 'wzmianki bez znacznika: 1$' \
    && echo "  ✓ T5 echo akapitu policzone jako wzmianka, nie jako termin" \
    || { echo "  ✗ T5 OBLANY — echo akapitu przecieka do koszy"; rc=1; }
  # T6 (PRAWO KOTWIC): woła tylko data poza kotwicą BEZ usprawiedliwienia — 05.09.
  #     Cichy 15.10 z ⌛? nie ma; 01.08/18.08/30.09 poza kotwicami → liczone też.
  echo "$out" | grep -qE 'poza kotwicą[^:]*: [1-9]' \
    && echo "  ✓ T6 data poza kotwicą woła" \
    || { echo "  ✗ T6 OBLANY — prawo kotwic nie egzekwuje"; rc=1; }
  # T7 (PRAWO NOŚNIKA): ⌛ bez daty i bez gdy = 1 (cichy nośnik), cytat w backtickach milczy
  echo "$out" | grep -q 'nośnik nierozpoznany (⌛ bez daty i bez gdy): 1' \
    && echo "  ✓ T7 cichy nośnik złapany, cytat wyciszony" \
    || { echo "  ✗ T7 OBLANY — cichy stan przecieka albo cytat straszy"; rc=1; }
  # T8 (PRAWO PAMIĘCI, +/−): pamięć nie zwiększa koszy (T1 nadal 1), ale jej kryterium JEST liczone
  echo "$out" | grep -q 'PAMIĘĆ.*: 1 kryteriów zapisanych' \
    && echo "  ✓ T8 pamięć świadczy (1 kryterium), nie zobowiązuje" \
    || { echo "  ✗ T8 OBLANY — pamięć albo niema, albo wciągnięta do długu"; rc=1; }
  # T10 (INWARIANT POKRYCIA — rdzeń INSUM). Tor NIE odtwarza logiki grupowania: wstrzykuje
  #     strumień w `grupuj_po_pliku`, czyli w TO SAMO ciało, którego używa `pomiar` (iniekcja
  #     zależności, klasa #50 — pięć razy złapana 20.08: tor mierzący własną kopię mierzy
  #     inny obiekt). Prawo: grupowanie wolno zmienić FORMĘ, nigdy POKRYCIE. Dowód, nie obietnica:
  #     ile dat weszło, tyle musi wyjść — inaczej straż cicho kompostuje cudzą obietnicę.
  local wej wyj
  wej=$(printf 'a.md\t2026-01-01\na.md\t2026-01-02\na.md\t2026-01-03\nb.md\t2026-02-01\nc.md\t2026-03-01\nc.md\t2026-03-02\n')
  wyj=$(printf '%s\n' "$wej" | grupuj_po_pliku)
  local n_wej n_wyj n_wierszy
  n_wej=$(printf '%s\n' "$wej" | grep -c .)
  n_wyj=$(printf '%s\n' "$wyj" | grep -oE '20[0-9]{2}-[01][0-9]-[0-3][0-9]' | grep -c .)
  n_wierszy=$(printf '%s\n' "$wyj" | grep -c .)
  # zamek na #52: pomiar nad pustym zbiorem świeciłby zielono — zbiór MUSI być niepusty
  [ "$n_wej" -eq 6 ] \
    || { echo "  ✗ T10 OBLANY — sonda pusta lub okrojona (wejście=$n_wej, oczekiwane 6): pomiar nie mierzy"; rc=1; }
  [ "$n_wyj" -eq "$n_wej" ] \
    && echo "  ✓ T10 POKRYCIE CAŁE — $n_wej dat weszło, $n_wyj wyszło (wierszy: $n_wierszy)" \
    || { echo "  ✗ T10 OBLANY — grupowanie ZGUBIŁO daty ($n_wej → $n_wyj)"; rc=1; }
  [ "$n_wierszy" -eq 3 ] \
    && echo "  ✓ T10b forma zwinięta do 3 miejsc rozliczenia (z 6 alarmów)" \
    || { echo "  ✗ T10b OBLANY — grupowanie nie zwija (wierszy=$n_wierszy, oczekiwane 3)"; rc=1; }
  # T11 (+, iniekcja): sufiks „za N dni" przeżywa grupowanie PRZY KAŻDEJ dacie z osobna —
  #     w grupie bez nawiasu (nawias trzyma całą grupę), przy pojedynczej dacie z nawiasem.
  wyj=$(printf 'a.md\t2026-08-22\tza 2 dni\na.md\t2026-08-27\tza 7 dni\nb.md\t2026-08-20\tza 0 dni\n' | grupuj_po_pliku)
  printf '%s\n' "$wyj" | grep -q 'a.md ×2 (2026-08-22 za 2 dni · 2026-08-27 za 7 dni)$' \
    && printf '%s\n' "$wyj" | grep -q 'b.md · 2026-08-20 (za 0 dni)$' \
    && echo "  ✓ T11 sufiks przeżywa grupowanie przy każdej dacie" \
    || { echo "  ✗ T11 OBLANY — sufiks zgubiony albo zniekształcony przez grupowanie"; rc=1; }
  # ── T14 (−, 03.09.2026, korekta twórcy): JEDNOSTKĄ JEST WIERSZ, NIE UNIKALNA DATA ──
  # Rodowód: meldunek „1 plik · 2 daty" na żywym kanonie, a za nim OSIEM nierozliczonych
  # wierszy `prywatne/TASKI.md` (l.165, 276, 278, 353, 613, 686, 720, 724) z dwiema datami.
  # `sort -u` na parze PLIK↔DATA zlewał osiem obietnic w dwie. To nie jest „cytat vs
  # zobowiązanie" (klasa #60, rola daty) — to KLASA #49: straż wskazuje NIE TĘ WIELKOŚĆ
  # i zasłania ROZMIAR długu. Kolejność cięć: najpierw jednostka, potem rola daty —
  # odwrotnie byłoby cięciem w ślepego (kto nie widzi rozmiaru, nie wie, co przycina).
  TT="$(mktemp -d)"
  { for i in 1 2 3 4 5; do printf -- '- [ ] obietnica %s (⌛do 31.08)\n' "$i"; done
    printf -- '- [ ] szósta obietnica (⌛do 01.09)\n'; } > "$TT/wiele.md"
  out=$(KRYT_ROOT="$TT" KRYT_DZIS="2026-09-03" bash "$0")
  echo "$out" | grep -q 'PRZETERMINOWANE — rozlicz.*: 1 plik · 2 daty · 6 wierszy$' \
    && echo "  ✓ T14 jednostka: 1 plik · 2 daty · 6 wierszy (rozmiar długu widoczny)" \
    || { echo "  ✗ T14 OBLANY — meldunek: $(echo "$out" | grep -o 'PRZETERMINOWANE — rozlicz.*')"; rc=1; }
  # T14b: numer linii stoi PRZY dacie — bez niego „6 wierszy" jest liczbą bez adresu
  echo "$out" | grep -qE 'wiele\.md ×6 \(.*l\.1 .*l\.6\)' \
    && echo "  ✓ T14b każdy wiersz ma adres (l.N)" \
    || { echo "  ✗ T14b OBLANY — numery linii nie doszły do meldunku"; rc=1; }
  rm -rf "$TT"; TT="$(mktemp -d)"

  # T4 (−): materia bez terminów NIE świeci przeterminowaniem
  printf '# pusto\nbez dat.\n' > "$TT/pusta.md"; rm -f "$TT/proba.md" "$TT/proba2.md"
  out=$(KRYT_ROOT="$TT" KRYT_DZIS="2026-08-14" bash "$0")
  echo "$out" | grep -q 'PRZETERMINOWANE: 0' \
    && echo "  ✓ T4 cisza na czystej materii" \
    || { echo "  ✗ T4 OBLANY — straż straszy bez powodu"; rc=1; }
  rm -rf "$TT"

  # T12 (−, TABELA): wiersz tabeli jest własną granicą. Fikstura odróżnialna (#64):
  # data przeterminowana stoi w INNEJ komórce niż fraza „kryterium śmierci", a prawdziwe
  # kryterium jest PRZYSZŁE. Złamana wersja zlepi tabelę i zamelduje przeterminowanie,
  # zasłaniając żywy termin — zdrowa milczy. Bez tego przypadku naprawa byłaby życzeniem.
  TT="$(mktemp -d)"
  printf '# tabela\n\n| # | co | uwaga |\n|---|---|---|\n| 1 | prawo obowiazuje od 14.06.2026 | tlo |\n| 2 | pozycja z kryterium śmierci 30.09 | zywe |\n' > "$TT/tab.md"
  out=$(KRYT_ROOT="$TT" KRYT_DZIS="2026-08-21" bash "$0")
  echo "$out" | grep -q 'PRZETERMINOWANE: 0' \
    && echo "  ✓ T12 wiersz tabeli jest granicą — data z sąsiedniej komórki nie zaciąga alarmu" \
    || { echo "  ✗ T12 OBLANY — tabela zlepiona, alarm z cudzej komórki (#56/#49)"; rc=1; }
  rm -rf "$TT"

  # T13 (−, MATERIAŁ): plik-materiał nie zaciąga długu, ale TA SAMA TREŚĆ w pliku
  # operacyjnym musi alarmować. Dwa przebiegi, jedna treść, dwa przeciwne werdykty —
  # różnica wyłącznie w NAZWIE pliku (#64: fikstura odróżnialna od swojego przeciwieństwa).
  # Bez drugiego przebiegu „zwolnione" byłoby nieodróżnialne od „straż w ogóle nie widzi".
  TT="$(mktemp -d)"
  TRESC='Kontekst rozmowy: kryterium śmierci 17.07.2026 zostało wtedy zacytowane.'
  mkdir -p "$TT/kanon/ksiegi"   # zwolnienie dziala po -path, wiec material musi lezec w domu (#64)
  printf '%s\n' "$TRESC" > "$TT/kanon/ksiegi/ROZMOWA_02_dialog.md"
  out=$(KRYT_ROOT="$TT" KRYT_DZIS="2026-08-21" bash "$0")
  echo "$out" | grep -q 'PRZETERMINOWANE: 0' \
    && echo "  ✓ T13 materiał rozmowy nie zaciąga długu (cytat ≠ zobowiązanie)" \
    || { echo "  ✗ T13 OBLANY — materiał wciągnięty w rozliczenie"; rc=1; }
  rm -f "$TT/kanon/ksiegi/ROZMOWA_02_dialog.md"
  printf '%s\n' "$TRESC" > "$TT/REJESTR_operacyjny.md"
  out=$(KRYT_ROOT="$TT" KRYT_DZIS="2026-08-21" bash "$0")
  echo "$out" | grep -q 'PRZETERMINOWANE: 0' \
    && { echo "  ✗ T13b OBLANY — ta sama treść w pliku operacyjnym też milczy: zwolnienie zbyt szerokie"; rc=1; } \
    || echo "  ✓ T13b ta sama treść w pliku operacyjnym ALARMUJE (zwolnienie wąskie)"
  rm -rf "$TT"

  [ $rc -eq 0 ] && echo "  TOR PRZESZEDŁ" || echo "  TOR OBLANY"
  return $rc
}

case "${1:-}" in
  --test) tor ;;
  *)      pomiar ;;
esac
