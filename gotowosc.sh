#!/usr/bin/env bash
# ═══ gotowosc.sh — CZY WOLNO WYPUŚCIĆ ODLEW (wersja z package.json) ═══
#
# RODOWÓD (13.08.2026): plan bez przyrządu jest życzeniem — dokładnie tak, jak prawo
# bez mechanizmu (inwariant 5). `kanon/ksiegi/PLAN_ODLEWU_v1.5.md` deklaruje sześć bramek;
# ten plik je LICZY. Werdykt z kodu wyjścia, nigdy z samopoczucia.
#
# BRAMKA 1 JEST NADRZĘDNA: świeża blizna unieważnia pozostałe pięć, choćby świeciły
# zielono. Odlew ma być migawką STABILNOŚCI, nie migawką RUCHU.
#
# UŻYCIE:  bash gotowosc.sh          (pomiar; rc=0 tylko gdy WSZYSTKIE bramki zdane)
#          bash gotowosc.sh --test   (tor własny — musi umieć NIE przejść)
set -uo pipefail
cd "$(dirname "$0")"

# ── LOCALE DLA WZORCÓW Z POLSKĄ LITERĄ (03.09.2026, blizna #80) ──────────────
# Klasa `[...]` z literą spoza ASCII pod locale C rozpada się na BAJTY i cicho zmienia wynik.
# Ustalamy locale UTF-8 raz, do użycia PRZY KONKRETNYCH komendach (nie globalnie: `export LC_ALL`
# zmieniłby też porządek `sort`). Gdy w środowisku nie ma UTF-8 — zostaje C i wzorzec działa
# jak dotąd, nie gorzej; brak locale nie jest powodem do zatrzymania przyrządu.
UTF8="$(locale -a 2>/dev/null | grep -im1 -E '^(C\.utf-?8|en_US\.utf-?8)$' || echo C)"

PROG_CISZA=7          # dni bez nowej blizny
PROG_MUTACJI=25
PROG_DUPLIKATOW=2   # skorygowany 13.08: licznik dał 6 realnych, nie 14 surowych
PROG_R=0

# ── liczniki (każdy osobno, żeby dało się je zmutować pojedynczo) ──
dni_od_ostatniej_blizny() {
  # BLIZNA #60 (20.08.2026): ta funkcja brała `tail -1` z listy nagłówków, czyli
  # OSTATNI WPIS W PLIKU — a korpus kanon/ksiegi/BLEDY.md nie jest chronologiczny (nowe wpisy
  # bywają wstawiane przed starsze). Zmierzone: tail -1 dawał #54 (13.08), gdy
  # najświeższa blizna była #59 (20.08). Bramka NADRZĘDNA odlewu meldowała 6 dni
  # ciszy przy zerowej. Klasa #49: tor na alarm to nie tor na miarę — pięć torów
  # pilnowało PROGU, żaden nie pilnował, czy liczba mierzy właściwy obiekt.
  #
  # Poprawnie: przejrzeć WSZYSTKIE numery, dla każdego znaleźć commit wprowadzający,
  # wziąć NAJŚWIEŻSZĄ datę. Wzorzec z granicą (`## #N ` albo `## #N —`), bo `-S"## #5"`
  # łapie także `## #59` jako podciąg (zmierzone: dwa trafienia na jedną datę).
  #
  # ZNACZNIK ZASTANA (decyzja twórcy 20.08, PLAN_ODLEWU §KOREKTA OKNA CISZY):
  # blizna niosąca w korpusie linię `**ZEGAR:** ZASTANA` NIE zeruje zegara — to wada
  # odkryta, nie wprowadzona, z udokumentowaną datą powstania starszą niż okno bramki.
  # Wyjątek jest MECHANICZNY i widoczny w pliku; decyzja w czacie nie wystarcza,
  # bo skrypt jej nie przeczyta (#55: obietnica bez czytnika).
  # ISTOTNE (#50, złapane mutacją 20.08): funkcja przyjmuje PLIK i DOSTAWCĘ DATY,
  # żeby tor mógł uderzyć w to samo ciało, które liczy odlew — zamiast testować
  # własną kopię logiki obok. Domyślnie: żywy korpus i data z gita.
  local PLIK="${1:-kanon/ksiegi/BLEDY.md}" DOSTAWCA="${2:-data_blizny_git}"
  local najswiezsza="" n d
  for n in $(grep -oE '^## #[0-9]+' "$PLIK" 2>/dev/null | grep -oE '[0-9]+' | sort -nu); do
    zastana_blizna "$n" "$PLIK" && continue
    d=$("$DOSTAWCA" "$n")
    [ -n "$d" ] || continue
    [ -z "$najswiezsza" ] && najswiezsza="$d"
    [ "$d" \> "$najswiezsza" ] && najswiezsza="$d"
  done
  [ -n "$najswiezsza" ] || { echo -1; return; }
  echo $(( ( $(date +%s) - $(date -d "$najswiezsza" +%s) ) / 86400 ))
}

# Data commita wprowadzającego bliznę #N. -G z regexem i GRANICĄ, nie -S:
# `-S"## #5"` łapie `## #59` jako PODCIĄG (zmierzone: dwa trafienia na jedną datę),
# a `-S"## #58 "` NIE łapie nagłówka `## #58` bez sufiksu — obie odmiany `-S`
# fałszowały wynik, każda w przeciwną stronę.
data_blizny_git() { git log -1 --format=%cI -G"^## #${1}([ —]|\$)" -- kanon/ksiegi/BLEDY.md 2>/dev/null; }

# Czy blizna #N jest oznaczona jako ZASTANA (nie zeruje zegara)? rc=0 tak, rc=1 nie.
# Czyta korpus od nagłówka blizny do następnego nagłówka `## #`.
zastana_blizna() {
  awk -v n="$1" '
    $0 ~ "^## #" n "([ —]|$)" { w=1; next }
    w && /^## #/ { exit }
    w && /\*\*ZEGAR:\*\* ZASTANA/ { print "TAK"; exit }
  ' "${2:-kanon/ksiegi/BLEDY.md}" 2>/dev/null | grep -q TAK
}
# ── SANITIZER (#54, 13.08.2026) ──────────────────────────────────────────────
# WADA ZMIERZONA: `set -o pipefail` (l.13) + `|| echo FALLBACK` produkuje DWIE
# WARTOŚCI, gdy komenda zwraca rc≠0 MIMO poprawnego wyniku. Dwa przypadki realne:
#   · `bash mutacje.sh | grep -oP ...` — mutacje.sh kończy rc=1 przy ślepych punktach,
#     pipefail przenosi to na potok, `||` odpala fallback OBOK znalezionej wartości → "3\n99"
#   · `grep -c WZORZEC` przy ZERO trafień — wypisuje "0" i zwraca rc=1 → "0\n99" / "0\n0"
# Druga postać jest gorsza: licznik pada dokładnie w chwili, gdy bramka zostaje ZDANA
# (zero blizn R = sukces = wysyp `integer expression expected`). Bramka nie mierzyła nigdy.
# Dlatego rc licznika NIE jest werdyktem licznika — werdykt jest w treści wyjścia.
tylko_liczba() {   # $1 = surowe wyjście · $2 = wartość zastępcza
  local w; w=$(printf '%s\n' "$1" | grep -oE '^-?[0-9]+$' | head -1)
  [ -n "$w" ] && printf '%s\n' "$w" || printf '%s\n' "$2"
}
liczba_mutacji()  { tylko_liczba "$(grep -cE '^[a-z][^|]*\|\|\|' mutacje.txt 2>/dev/null)" 0; }
slepe_punkty()    {
  # 02.09.2026 — bramka czytała WYŁĄCZNIE „ŚLEPYCH", więc przechodziła przy zerze
  # zmierzonych tak samo jak przy komplecie złapanych (blizna #54 naprawiła rc→liczba,
  # ale liczbę wzięła jedną — tę, która przy ciszy też jest zerem). Teraz brak pomiaru
  # zwraca sentinel 99, ten sam, którym funkcja od początku sygnalizuje „nie wiem".
  # (03.09.2026) $1 = katalog atrapy, $2 = rejestr w nim — TYLKO dla toru; produkcja woła bez
  # argumentów i mierzy ŻYWY rejestr (bramka 3 pyta o STAN). Tor z pustymi argumentami
  # biegłby po żywym ciele — klasa #50 przez dwa piętra, zmierzona 03.09 (mutacje.sh ×3 w drzewie).
  local wy zl KOR; KOR="$(pwd)"
  # ── ODPORNOŚĆ NA ODZIEDZICZONE MUTACJE_W_BIEGU (13.09.2026, zmierzone) ─────────────
  # Gdy TA funkcja jest wołana jako ŚWIADEK z wnętrza `mutacje.sh` (świadek `bash gotowosc.sh
  # --test` przy dziewięciu pozycjach `gotowosc-*`), produkcyjna pętla mutatora ustawia
  # `MUTACJE_W_BIEGU=1` dla KAŻDEGO świadka (l. 388) — i ta zmienna DZIEDZICZY się w dół do
  # wywołań `mutacje.sh` TUTAJ. Zamek rekurencji w `mutacje.sh` odmawia startu (rc=4) na
  # WIDOK samej zmiennej, niezależnie od tego, czy zagnieżdżenie jest REALNE. Skutek zmierzony:
  # `MUTACJE_W_BIEGU=1 bash gotowosc.sh --test` → rc=1 NA ZDROWYM CIELE — więc produkcyjna
  # pętla melduje ZŁAPANĄ dla wszystkich dziewięciu pozycji `gotowosc-*` z POWODU wycieku,
  # nie z powodu wstrzykniętej mutacji. Pokrycie POZORNE, tej samej rodziny co #75/#50, tylko
  # nieodkryte dotąd, bo nikt nie sprawdzał tych świadków na zdrowym ciele POD tą zmienną.
  # Wywołania TUTAJ są własnym, samodzielnym pomiarem (atrapa w mktemp albo żywy rejestr
  # mierzony NA ŻĄDANIE bramki 3) — nie są zagnieżdżeniem cudzego biegu mutacyjnego, więc
  # zdejmujemy odziedziczoną zmienną PRZED wywołaniem, nie po (#50: czyść źródło, nie skutek).
  # ── `env -u` ZDJĘTE (18.09.2026, zmierzone). Diagnoza z 13.09 była trafna, miejsce naprawy
  # nie: zdjęcie flagi rozbrajało zamek także w gałęzi PRODUKCYJNEJ. Pod mutacją
  # `gotowosc-slepe-fikstura-ignorowana` świadek `bash gotowosc.sh --test` wchodził tu w pełny
  # bieg żywego rejestru z wnętrza biegu — bez dna; 18.09 `publikuj.sh` urósł do 3182 procesów
  # w 21 h i zostawił zmutowany `straz_hooka.sh`. Naprawa po stronie ZAMKA: flaga niesie
  # tożsamość ciała, `mutacje.sh` odmawia tylko w tym samym katalogu. Fikstura (`cd "$1"`,
  # inny katalog) rusza pod flagą; gałąź produkcyjna zagnieżdżona dostaje rc=4 → sentinel 99.
  if [ -n "${1:-}" ]; then wy=$(cd "$1" && REJESTR="${2:-rej.txt}" bash "$KOR/mutacje.sh" 2>/dev/null)
  else wy=$(bash mutacje.sh 2>/dev/null); fi
  zl=$(tylko_liczba "$(printf '%s\n' "$wy" | grep -oP 'złapanych \K[0-9]+' | tail -1)" 0)
  [ "$zl" -eq 0 ] && { printf '99\n'; return; }
  # ── DWA CZŁONY, JEDNA BRAMKA (13.09.2026) ──────────────────────────────────────────
  # Bramka 3 pyta „ile pozycji NIE MA realnego pokrycia". Od 13.09 `mutacje.sh` rozróżnia
  # dwa sposoby, na jakie pokrycia zabraknąć: ŚLEPA (straż nie złapała wstrzykniętej wady)
  # i ŚWIADEK MARTWY (nie dowiedzieliśmy się niczego, bo miernik oblewał już na zdrowym
  # ciele). Kategorie są OSOBNE w meldunku, bo znaczą co innego i naprawia się je inaczej —
  # ale dla BRAMKI obie znaczą to samo: pozycja nie jest dowodem. Czytanie samego członu
  # „ŚLEPYCH" zostawiłoby nowy mechanizm bez wpustu do bramki — czyli zamek, który mierzy
  # i melduje, ale niczego nie zatrzymuje (ta sama klasa, którą naprawialiśmy dziś ×3).
  # `grep -oP 'ŚLEPYCH \K'` NIE dopasuje „ŚWIADKÓW MARTWYCH", więc człony nie kolidują —
  # to był powód przemianowania kategorii z „ŚWIADKÓW ŚLEPYCH" tego samego dnia.
  local sl mart
  sl=$(tylko_liczba "$(printf '%s\n' "$wy" | grep -oP 'ŚLEPYCH \K[0-9]+' | tail -1)" 99)
  mart=$(tylko_liczba "$(printf '%s\n' "$wy" | grep -oP 'ŚWIADKÓW MARTWYCH \K[0-9]+' | tail -1)" 0)
  [ "$sl" -eq 99 ] && { printf '99\n'; return; }
  printf '%s\n' "$((sl + mart))"
}
liczba_duplikatow() {
  # ZLICZA CIAŁA, NIE NAZWY (naprawa 13.08, faza A). Pierwsza wersja liczyła same
  # nazwy i dała 6 — z czego `granice` i `scan` okazały się ZBIEŻNOŚCIĄ NAZW
  # (zupełnie różne funkcje), a `bisekcja` DWOMA RÓŻNYMI ALGORYTMAMI pod jedną nazwą
  # (bisekcja na zmianie znaku vs trójpodział na minimum |f|). Licznik nazw sterował
  # fazą A szumem: kazałby scalić rzeczy, które scalić NIE WOLNO.
  # Duplikat = ta sama nazwa ORAZ znormalizowane ciało podobne w ≥ 80%.
  tylko_liczba "$(node -e '
    const fs=require("fs");
    const CELOWE=new Set(["getC","analyze","moonDecl","raport","skan","sidLon"]);
    const pliki=fs.readdirSync(".").filter(f=>/\.js$/.test(f)&&!/^testy_|_tmp/.test(f));
    const m={};
    for(const f of pliki){
      const src=fs.readFileSync(f,"utf8"); let x;
      const re=/function\s+([A-Za-z_$][\w$]*)\s*\(/g;
      while((x=re.exec(src))){
        const cialo=src.slice(x.index, x.index+350).replace(/\s+/g,"");
        (m[x[1]] ||= []).push({f, cialo});
      }
    }
    const podobne=(a,b)=>{ const n=Math.min(a.length,b.length); let z=0;
      for(let i=0;i<n;i++) if(a[i]===b[i]) z++; else break;
      return z/Math.max(a.length,b.length); };
    let ile=0;
    for(const [n,v] of Object.entries(m)){
      if(CELOWE.has(n)) continue;
      const pl=[...new Set(v.map(x=>x.f))]; if(pl.length<2) continue;
      let dup=false;
      for(let i=0;i<v.length;i++) for(let j=i+1;j<v.length;j++)
        if(v[i].f!==v[j].f && podobne(v[i].cialo,v[j].cialo)>=0.8) dup=true;
      if(dup) ile++;
    }
    console.log(ile);
  ' 2>/dev/null)" 99
}
# BRAMKA 5 — PRZEPISANA 20.08.2026 (pytanie twórcy: „po co ten próg?").
# BYŁO: liczba wszystkich blizn R, próg ≤15. Próg nie miał rodowodu — plan uzasadniał,
# dlaczego 22 jest źle (45% księgi), nigdy dlaczego 15 jest dobrze (31%). Ta sama klasa,
# którą twórca zdjął z dat 13.08 („sztucznie zakładasz"); progi zostały niepoprawione.
# Gorzej: licznik proporcji zapraszał do zdejmowania statusu, żeby liczba spadła —
# czyli do zaspokajania wskaźnika przez zmianę etykiety (PRAWO: metryka nie jest zamówieniem).
#
# JEST: liczone WYŁĄCZNIE blizny R w klasach, które psują CUDZE repo. Rodowód progu:
# zero, bo odbiorca odlewu nie zna naszych reguł z pamięci — reguła bez mechanizmu
# działa u niego wyłącznie przypadkiem. Klasy spoza tej listy (POSTAWA, ELEGANCJA,
# RZEMIOSŁO, czysty POMIAR wewnętrzny) NIE blokują odlewu: są prawdziwe, ale ich
# złamanie kosztuje nas, nie jego. Mierzy je `narzedzia/przyrzady/pokrycie_m.js`, innym instrumentem.
KLASY_KRYTYCZNE='GIT|ŻYWE REPO|INTERPOLACJA'
blizny_bez_mechanizmu() {
  # KLASA ZOSTAJE, LOCALE USTALONE JAWNIE (03.09.2026, #80). Kuszące `[^|]*` ZMIERZONE I ODRZUCONE:
  # pochłania spację, więc wiersz „GITARA MUZYCZNA" wchodzi przez podciąg GIT — klasa BEZ SPACJI
  # jest tu granicą słowa i to jest jej istota, nie ozdoba. Naprawa zdejmuje zależność od locale,
  # nie rusza semantyki: pod C klasa rozpadała się na bajty (działała przypadkiem, bo bajty
  # polskich liter mieszczą się w zakresie — nowa rodzina z inną literą zmieniłaby wynik).
  tylko_liczba "$(grep -E '^\| [0-9]+ \|.*\| R \|$' kanon/ksiegi/BLEDY.md 2>/dev/null \
    | LC_ALL="$UTF8" grep -cE "\| ([A-ZŻŁĄĆĘŃÓŚŹ/]*($KLASY_KRYTYCZNE)[A-ZŻŁĄĆĘŃÓŚŹ/]*) \|")" 99
}
# ZAMEK #60
# BRAMKA 6 PRZEPISANA 20.08.2026 (rodowód, żeby nie było progu bez powodu — jak przy
# bramce 5). BYŁO: liczba plików straży różniących się między `prywatna` a `main`, próg 0.
# WADA KONSTRUKCYJNA, zmierzona: ta liczba nie może zejść do zera PRZED odlewem, bo
# zeruje ją dopiero force-push. Bramka gotowości mierzyła SKUTEK odlewu, nie gotowość
# do niego — więc albo blokowała wiecznie, albo wymuszała osobny transport przed
# wydaniem, czyli wystawienie światu wersji pośredniej, którą force-push i tak nadpisze.
#
# JEST: liczba straży rozjechanych z `main`, których odlew NIE ZABIERZE — bo nie ma ich
# na białej liście `publikuj.sh`. To jest prawdziwa gotowość: gdy wynosi zero, force-push
# zamyka rozjazd sam, w jednym ruchu. Gdy rośnie, znaczy że powstała straż, która nigdy
# nie dotrze do odbiorcy — i to jest realna wada odlewu, a nie stan przejściowy gałęzi.
# Iniekcja zależności ($1 = biała lista, $2 = zestaw plików) — po raz CZWARTY tej doby
# mutacja pokazała, że tor sprawdzający logikę OBOK funkcji jest ślepy (#50).
rozjazd_strazy() {
  local lista f n=0 pliki wyl
  lista="${1:-}"
  # 14.09.2026 (słowo twórcy „działaj z a"): bramka 6 czyta WYŁĄCZENIA Z POWODEM z tego
  # samego miejsca, w którym zapadają — `straz_odlewu.sh --wylaczenia`. Wcześniej dwa
  # przyrządy pytały o jedną granicę z dwiema listami prawdy: `straz_odlewu` znała decyzję
  # twórcy („ten wątek nie wchodzi do odlewu"), a ta bramka nie — i oblewała na tym, co
  # zostało świadomie rozstrzygnięte. Klasa MOSTY #29. Zamek NIE słabnie: pomijana jest
  # wyłącznie straż z ZAPISANYM POWODEM; straż zostawiona w domu MILCZĄCO nadal liczy się
  # do rozjazdu, bo PRAWO ODLEWU §5 mówi, że cisza nie jest decyzją.
  wyl="${3:-}"
  [ -n "$wyl" ] || wyl=$(sh narzedzia/straze/straz_odlewu.sh --wylaczenia 2>/dev/null | tr '\n' ' ')
  # C3 · tura 4 (02.09.2026): biała lista czytana JEDNYM ŹRÓDŁEM — `publikuj.sh --lista`.
  # Własny sed zdjęty. To NIE jest kosmetyka: wzorzec `/^  FORMA_X=/,/"$/p` PRZECIEKA na
  # definicji JEDNOLINIOWEJ (sed nie szuka wzorca końca na linii startowej) — dokładnie
  # klasa, którą 28.08 opisała `straz_aktora.sh` jako „KLASA UŚPIONA, ZGŁOSZONA" i wskazała
  # palcem to miejsce. Dziś nie przeciekał, bo obie definicje są wieloliniowe; przeciekłby
  # w dniu, w którym któraś zmieści się w jednej linii. Świadek równoważności ZOSTAJE:
  # tor `--lista` w `publikuj.sh --test` (dwustronny — zgodność z sedem + odmowa złej sekcji).
  [ -n "$lista" ] || lista=$( { sh publikuj.sh --lista JS; sh publikuj.sh --lista SH; } 2>/dev/null | tr '\n' ' ')
  pliki="${2:-}"
  [ -n "$pliki" ] || pliki=$(git diff --name-only origin/main HEAD -- 'straz_*.sh' 'narzedzia/straze/straz_*.sh' \
      'narzedzia/linty/lint_*.js' \
      'tory_strazy.sh' 'weryfikacja.js' 'mutacje.sh' 'testy_rdzen.js' 'narzedzia/przyrzady/crash_izolacja.sh' \
      'gotowosc.sh' 2>/dev/null)
  # dach narzedzia/ (29.08): porównanie po NAZWIE BAZOWEJ. Diff przenosin zwraca dwie
  # ścieżki dla jednego pliku (starą usuniętą i nową) — porównanie po ścieżce liczyło
  # każdą przeprowadzkę jako 20 straży „poza odlewem", choć żadna z odlewu nie wyszła.
  for f in $pliki; do
    _b="$(basename "$f")"; _jest=0
    for _l in $lista; do [ "$(basename "$_l")" = "$_b" ] && _jest=1 && break; done
    if [ "$_jest" = 0 ]; then
      for _w in $wyl; do [ "$(basename "$_w")" = "$_b" ] && _jest=1 && break; done
    fi
    [ "$_jest" = 1 ] || n=$((n+1))
  done
  tylko_liczba "$n" 99
}

# ── ŹRÓDŁO FUNKCJI dla toru na ścieżce zerowej (#53: zamek musi być osiągalny
# PRZEZ FASADĘ, nie tylko w kodzie). `source ./gotowosc.sh --zrodlo` definiuje
# liczniki i wraca, nie uruchamiając pomiaru.
[ "${1:-}" = "--zrodlo" ] && return 0 2>/dev/null

bramka() {  # nazwa · wartość · próg · kierunek(le|ge) · opis
  local naz="$1" war="$2" prg="$3" kier="$4" opis="$5" ok=0
  if [ "$kier" = "le" ]; then [ "$war" -le "$prg" ] && ok=1; else [ "$war" -ge "$prg" ] && ok=1; fi
  if [ "$ok" = 1 ]; then printf "  ✓ %-26s %6s  (próg %s%s)  %s\n" "$naz" "$war" "$([ "$kier" = le ] && echo '≤' || echo '≥')" "$prg" "$opis"
  else printf "  ✗ %-26s %6s  (próg %s%s)  %s\n" "$naz" "$war" "$([ "$kier" = le ] && echo '≤' || echo '≥')" "$prg" "$opis"; fi
  return $((1-ok))
}

# ── TOR WŁASNY (#38 + prawo 13.08: mechanizm bez mutacji = życzenie) ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ GOTOWOŚĆ — AUTOTEST (#38) ═══╗"
  zle=""
  bramka x 10 5 ge "" >/dev/null; [ $? -eq 0 ] || zle="$zle spelniona-bramka-oblewa"
  bramka x  2 5 ge "" >/dev/null; [ $? -ne 0 ] || zle="$zle niespelniona-bramka-przechodzi"
  bramka x  3 5 le "" >/dev/null; [ $? -eq 0 ] || zle="$zle le-spelniona-oblewa"
  bramka x  9 5 le "" >/dev/null; [ $? -ne 0 ] || zle="$zle le-niespelniona-przechodzi"
  bramka x  5 5 le "" >/dev/null; [ $? -eq 0 ] || zle="$zle rownosc-progu-oblewa"
  # (⊙) MIARA, nie tylko alarm (prawo #49): liczniki muszą zwracać LICZBY, nie puste.
  # KOMPLET 5/5 (#54): dawna pętla brała TRZY z pięciu i pomijała dokładnie ten licznik,
  # który był zepsuty — `slepe_punkty`. Tor pilnował podzbioru, o którym nie meldował.
  # ── (03.09.2026, słowo twórcy) KLASA #50 PRZEZ DWA PIĘTRA: do dziś ten tor wołał `slepe_punkty`
  # bez argumentów, czyli PEŁNY BIEG MUTACYJNY NA ŻYWYM REJESTRZE — tor woła ciało na żywym repo,
  # tylko dwa poziomy niżej, więc nikt tego nie widział. Cena zmierzona 03.09: bateria zabita
  # w środku (timeout 180 s mostu) zostawiła zmutowany `mutacje.sh` w drzewie TRZY razy tego dnia.
  # Tor mierzy MECHANIZM licznika (czy liczy ślepe, czy zwraca 99 przy ciszy) na atrapie w mktemp;
  # STAN żywego rejestru mierzy produkcja (bramka 3) i publikuj.sh — tam bieg jest pomiarem, nie fikstura.
  _ST0="$(git status --porcelain 2>/dev/null)"
  TF="$(mktemp -d)"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$TF/lapana.js"
  printf 'const y=1;\nprocess.exit(0);\n'          > "$TF/slepa.js"
  printf 'a|||lapana.js|||const x=1;|||const x=2;|||node lapana.js\nb|||slepa.js|||const y=1;|||const y=2;|||node slepa.js\n' > "$TF/rej_jedna_slepa.txt"
  printf 'w|||niema.js|||const q=1;|||const q=2;|||node niema.js\n' > "$TF/rej_cisza.txt"
  for f in liczba_mutacji liczba_duplikatow blizny_bez_mechanizmu rozjazd_strazy; do
    w=$($f); case "$w" in ''|*[!0-9]*) zle="$zle licznik-${f}-nie-jest-liczba($(printf '%s' "$w" | tr '\n' '~'))" ;; esac
  done
  # (+) rejestr z JEDNĄ ślepą → licznik zwraca 1 (liczy ślepe, nie złapane)
  w=$(slepe_punkty "$TF" rej_jedna_slepa.txt); [ "$w" = "1" ] || zle="$zle slepe-punkty-na-fiksturze($w!=1)"
  # (−) rejestr, w którym nic nie da się wstrzyknąć → sentinel 99, nigdy 0 (cisza ≠ czystość, #54/#39)
  w=$(slepe_punkty "$TF" rej_cisza.txt); [ "$w" = "99" ] || zle="$zle cisza-jako-czystosc($w!=99)"
  # (+) FIKSTURA POD FLAGĄ (18.09.2026) — cel naprawy z 13.09: świadek wołany z wnętrza biegu
  #     (flaga = tożsamość TEGO ciała, tak jak ustawia ją mutator) mierzy fiksturę w mktemp
  #     normalnie. Zamek po samej obecności flagi dałby tu 99 zamiast 1.
  TOZ_KOR="$(stat -c '%d:%i' .)"
  w=$(export MUTACJE_W_BIEGU="$TOZ_KOR"; slepe_punkty "$TF" rej_jedna_slepa.txt)
  [ "$w" = "1" ] || zle="$zle fikstura-pod-flaga-zablokowana($w!=1)"
  # (⊙) REKURENCJA REALNA POD MUTACJĄ `gotowosc-slepe-fikstura-ignorowana` (18.09.2026).
  #     Kopia TEGO pliku w atrapie z wstrzykniętym `if false` → `slepe_punkty` idzie w gałąź
  #     produkcyjną z wnętrza biegu. Na miejscu `mutacje.sh` pułapka: woła prawdziwy mutator
  #     i zapisuje jego rc. MUSI być 4 (odmowa w tym samym ciele). Przy `env -u` albo bez zamka
  #     prawdziwy bieg rusza (rc≠4) — 18.09 to było 3182 procesy. Rejestr atrapy ma jednego
  #     świadka, który nikogo nie woła, więc tor ma dno nawet wtedy, gdy zamek padnie.
  #     MUTATOR JEST KOPIĄ W ATRAPIE, NIGDY ŻYWYM PLIKIEM (18.09.2026, blizna własna tej łatki):
  #     `mutacje.sh:25` bez REJESTR robi `cd "$(dirname "$0")"`. Pierwsza wersja tego toru wołała
  #     `$KOR/mutacje.sh` — mutator przeszedł do ŻYWEGO repo, jego tożsamość ≠ flaga atrapy,
  #     zamek milczał i przez 4 min biegł pełny rejestr na żywym ciele. Kopia w $A → `cd` do $A.
  #     `timeout 120`: gdyby zamek padł, tor oblewa (rc=124), zamiast rosnąć.
  A="$(mktemp -d)"
  _src="$(cat gotowosc.sh)"; _wz='if [ -n "${1:-}" ]; then wy=$(cd "$1"'
  printf '%s\n' "${_src/"$_wz"/if false; then wy=\$(cd \"\$1\"}" > "$A/gotowosc.sh"
  cp mutacje.sh "$A/_mutator.sh"
  printf '#!/usr/bin/env bash\ntimeout 120 bash "$(dirname "$0")/_mutator.sh" "$@"; r=$?; printf "%%s" "$r" > rc_zagn.txt; exit $r\n' > "$A/mutacje.sh"
  printf 'const x=1;\nif(x!==1) process.exit(1);\n' > "$A/ofiara.js"
  printf '#!/usr/bin/env bash\nexit 1\n' > "$A/sonda.sh"
  printf 'sonda|||ofiara.js|||const x=1;|||const x=2;|||bash sonda.sh\n' > "$A/mutacje.txt"
  grep -q '^  if false; then wy=' "$A/gotowosc.sh" || zle="$zle atrapa-358-nie-wstrzyknieta"
  w=$(cd "$A" && export MUTACJE_W_BIEGU="$(stat -c '%d:%i' .)" && . ./gotowosc.sh --zrodlo >/dev/null 2>&1 && slepe_punkty "$TF" rej_jedna_slepa.txt)
  RC_ZAGN="$(cat "$A/rc_zagn.txt" 2>/dev/null || echo BRAK)"
  [ "$RC_ZAGN" = "4" ] || zle="$zle rekurencja-pod-358-wystartowala(rc=$RC_ZAGN)"
  [ "$w" = "99" ] || zle="$zle rekurencja-pod-358-zmierzyla-cos($w!=99)"
  rm -rf "$A"
  rm -rf "$TF"
  # (⊗) TOR NIE TYKA ŻYWEGO CIAŁA: drzewo po torze identyczne jak przed (to jest kontrola #50)
  [ "$(git status --porcelain 2>/dev/null)" = "$_ST0" ] || zle="$zle tor-brudzi-zywe-drzewo"
  # (⊙⊙⊙) BRAMKA 5 MUSI ODRÓŻNIAĆ KLASY (20.08.2026, przepisanie progu).
  # Licznik ma widzieć TYLKO blizny R w klasach psujących cudze repo. Regres do
  # „wszystkie R\" jest niewidoczny w liczbie zbiorczej — dlatego tor mierzy RÓŻNICĘ
  # na własnej fiksturze, a nie na żywym kanon/ksiegi/BLEDY.md (fikstura zasłaniająca błąd, #51).
  TB="$(mktemp -d)"; PWD_STARY="$PWD"
  {
    echo '| 10 | ❿ | regula git | GIT | R |'
    echo '| 12 | ⓬ | interpolacja | INTERPOLACJA | R |'
    echo '| 33 | — | postawa wewnetrzna | POMIAR | R |'
    echo '| 41 | — | inna wewnetrzna | ELEGANCJA | R |'
    echo '| 24 | — | juz zmechanizowana | GIT | M✓ |'
  } > "$TB/BLEDY.md"
  # produkcja czyta kanon/ksiegi/BLEDY.md (Ciecie 5) — fikstura odtwarza topologie (#64)
  mkdir -p "$TB/kanon/ksiegi" && mv "$TB/BLEDY.md" "$TB/kanon/ksiegi/BLEDY.md"
  cd "$TB"
  W5="$(blizny_bez_mechanizmu)"
  cd "$PWD_STARY"; rm -rf "$TB"
  # oczekiwane 2 (GIT + INTERPOLACJA). 4 = regres do wszystkich klas. 3 = M✓ policzone jako R.
  [ "$W5" = "2" ] || zle="$zle bramka5-nie-odroznia-klas(=$W5)"

  # klasa #54 (dwie wartości sklejone znakiem nowej linii, puste, nieliczbowe):
  # ── TORY NA MIARĘ BRAMKI 1 (#60, 20.08.2026) — nie na próg, na WIELKOŚĆ.
  # Pięć torów wyżej pilnuje, czy bramka umie oblać. Żaden nie pilnował, czy liczba
  # mierzy właściwy obiekt — i dlatego bramka NADRZĘDNA meldowała 6 dni przy zerowej.
  TB="$(mktemp -d)"; cp kanon/ksiegi/BLEDY.md "$TB/BLEDY.md.zapas"
  # (−) korpus NIECHRONOLOGICZNY: najwyższy numer stoi w środku pliku, nie na końcu.
  # Stara implementacja (`tail -1`) brała ostatni wpis W PLIKU — MUSI oblać.
  printf '## #91 — nowa\n\n## #90 — stara\n' > "$TB/prob.md"
  OSTATNI_W_PLIKU=$(grep -oE '^## #[0-9]+' "$TB/prob.md" | tail -1 | grep -oE '[0-9]+')
  NAJWYZSZY=$(grep -oE '^## #[0-9]+' "$TB/prob.md" | grep -oE '[0-9]+' | sort -n | tail -1)
  [ "$OSTATNI_W_PLIKU" != "$NAJWYZSZY" ] || zle="$zle fikstura-slaba-nie-odtwarza-rozjazdu"
  # (−) WZORZEC Z GRANICĄ: `#5` nie może łapać `#59`, a `#58` musi się znaleźć bez sufiksu
  # (03.09.2026, #80) em-dash WYJĘTY Z KLASY do alternatywy: `[ —]` pod locale C rozpada się
  # na bajty; `( |—|$)` jest niezależne od locale. Równoważność zmierzona przed zmianą.
  echo "## #58" | grep -qE '^## #58( |—|$)'  || zle="$zle wzorzec-gubi-naglowek-bez-sufiksu"
  echo "## #59" | grep -qE '^## #5( |—|$)'   && zle="$zle wzorzec-lapie-podciag(#5 w #59)"
  # (⊙) ZNACZNIK ZASTANA na atrapie — nie na żywym korpusie (#50: tor nie mierzy
  # własnej kopii, ale też nie może zależeć od treści, którą wycenia).
  printf '## #90 — stara\n\n## #91 — nowa\n**ZEGAR:** ZASTANA — atrapa\n\n## #92 — najnowsza\n' > "$TB/zn.md"
  zastana_blizna 91 "$TB/zn.md" || zle="$zle znacznik-zastana-nieczytany"
  zastana_blizna 90 "$TB/zn.md" && zle="$zle znacznik-zastana-lapie-nieoznaczona"

  # ── TORY NA MIARĘ BRAMKI 6 (przepisana 20.08) — czy odróżnia „rozjechana, ale
  # pojedzie w odlewie" od „rozjechana i NIE pojedzie". Ta druga to jedyna realna wada.
  # bije w SAMO CIAŁO rozjazd_strazy przez wstrzyknięte argumenty
  [ "$(rozjazd_strazy "alfa.sh beta.js" "alfa.sh beta.js")" = "0" ] \
    || zle="$zle bramka6-liczy-straz-objeta-odlewem"
  [ "$(rozjazd_strazy "alfa.sh" "alfa.sh gamma.sh delta.sh")" = "2" ] \
    || zle="$zle bramka6-nie-liczy-strazy-poza-odlewem(=$(rozjazd_strazy "alfa.sh" "alfa.sh gamma.sh delta.sh"))"
  # wyłuskiwanie białej listy z publikuj.sh musi dawać NIEPUSTY zbiór — inaczej bramka
  # zliczyłaby wszystko jako „poza odlewem" i blokowała bez powodu (klasa #52)
  L_ZYWA=$(sh publikuj.sh --lista SH 2>/dev/null | tr '\n' ' ')
  case " $L_ZYWA " in *" wstan.sh "*) ;; *) zle="$zle bramka6-nie-wyluskuje-bialej-listy" ;; esac

  # ── TORY NA FURTKĘ WYŁĄCZEŃ (14.09.2026) — furtka MUSI być wąska. Zamek, który
  # przepuszcza wszystko, o czym gdzieś napisano, jest gorszy od braku zamka.
  [ "$(rozjazd_strazy "alfa.sh" "alfa.sh gamma.sh" "gamma.sh")" = "0" ] \
    || zle="$zle bramka6-nie-honoruje-wylaczenia-z-powodem"
  # straż zostawiona MILCZĄCO (spoza listy wyłączeń) nadal liczy — PRAWO ODLEWU §5
  [ "$(rozjazd_strazy "alfa.sh" "alfa.sh gamma.sh delta.sh" "gamma.sh")" = "1" ] \
    || zle="$zle bramka6-furtka-przepuszcza-milczaca-straz"
  # pusty zbiór wyłączeń nie zmienia niczego (bramka sprzed 14.09 == bramka po)
  [ "$(rozjazd_strazy "alfa.sh" "alfa.sh gamma.sh delta.sh" " ")" = "2" ] \
    || zle="$zle bramka6-pusty-zbior-wylaczen-falszuje"
  # źródło prawdy ŻYWE: straz_odlewu --wylaczenia musi drukować nazwy, nie powody
  W_ZYWE=$(sh narzedzia/straze/straz_odlewu.sh --wylaczenia 2>/dev/null | tr '\n' ' ')
  case " $W_ZYWE " in *".sh "*|*".js "*|*".bat "*) ;; *) zle="$zle bramka6-zrodlo-wylaczen-nie-drukuje-nazw" ;; esac

  # (−−) TOR BIJĄCY W SAMO CIAŁO dni_od_ostatniej_blizny — przez wstrzykniętego
  # dostawcę daty. Bez tego mutacja pętli przechodziła: tory wyżej sprawdzały
  # logikę OBOK funkcji, nie funkcję (#50, trzeci raz tej doby).
  data_atrapa() {   # #90 najstarsza · #91 ZASTANA i najświeższa · #92 średnia
    case "$1" in
      90) echo "2026-01-01T00:00:00+00:00" ;;
      91) echo "2026-06-01T00:00:00+00:00" ;;
      92) echo "2026-03-01T00:00:00+00:00" ;;
    esac
  }
  D_ZN=$(dni_od_ostatniej_blizny "$TB/zn.md" data_atrapa)
  D_92=$(( ( $(date +%s) - $(date -d "2026-03-01T00:00:00+00:00" +%s) ) / 86400 ))
  # #91 jest ZASTANA i najświeższa → musi zostać pominięta, zegar liczy od #92
  [ "$D_ZN" = "$D_92" ] || zle="$zle cisza-nie-liczy-najswiezszej-nie-zastanej(=$D_ZN oczek=$D_92)"
  rm -rf "$TB"
  [ "$(tylko_liczba "$(printf '3\n99')" 7)" = "3" ]  || zle="$zle sanitizer-przepuszcza-sklejke"
  [ "$(tylko_liczba "$(printf '0\n99')" 7)" = "0" ]  || zle="$zle sanitizer-gubi-zero"
  [ "$(tylko_liczba "" 7)"                  = "7" ]  || zle="$zle sanitizer-nie-daje-zastepczej"
  [ "$(tylko_liczba "abc" 7)"               = "7" ]  || zle="$zle sanitizer-przepuszcza-tekst"
  # (⊙⊙⊙) TOR NA ŚCIEŻCE ZEROWEJ, PRZEZ FASADĘ (#53 + #51: fikstura nie może maskować).
  # Przy realnych danych grep ZAWSZE trafia, więc ścieżka zerowa jest niewidoczna —
  # a to na niej licznik pękał. Wymuszamy ją pustymi plikami w katalogu tymczasowym.
  tmp=$(mktemp -d)
  : > "$tmp/mutacje.txt"; : > "$tmp/BLEDY.md"; cp gotowosc.sh "$tmp/gotowosc.sh"
  for f in liczba_mutacji blizny_bez_mechanizmu; do
    w=$(cd "$tmp" && . ./gotowosc.sh --zrodlo >/dev/null 2>&1; $f)
    case "$w" in
      ''|*[!0-9]*) zle="$zle zerowa-sciezka-${f}($(printf '%s' "$w" | tr '\n' '~'))" ;;
      *) [ "$w" = "0" ] || zle="$zle zerowa-sciezka-${f}-nie-zero($w)" ;;
    esac
  done
  rm -rf "$tmp"
  if [ -z "$zle" ]; then
    echo "  ✓ GOTOWOŚĆ ŻYWA — 5 torów alarmu · 5 torów miary (komplet liczników)"
    echo "    · 4 tory sanitizera · 2 tory na ŚCIEŻCE ZEROWEJ przez fasadę."
    exit 0
  fi
  echo "  ✗ GOTOWOŚĆ MARTWA — oblane:$zle"; exit 1
fi

# ── POMIAR ──
# 19.09.2026: numer wydania czytany z JEDNEGO źródła (package.json), nie wpisany w tekst.
# Powód: etykieta stała na "v1.5.0", gdy repo było na 1.6.0 — nazwa obiecywała więcej niż
# pomiar (ta sama klasa co #34 DEKLAMATOR: liczba postawiona OBOK pomiaru, nie z niego).
WERSJA=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' package.json | head -1)
[ -n "$WERSJA" ] || WERSJA="? (package.json nieczytelny)"
echo "╔═══ GOTOWOŚĆ ODLEWU v$WERSJA — pięć bramek dowodu + jedna miara ═══╗"
echo "  zmierzone: $(TZ=Europe/Warsaw date '+%d.%m.%Y %H:%M %Z')"
echo
NIEZDANE=0
CISZA=$(dni_od_ostatniej_blizny)
# ── BRAMKA 1 ODWOŁANA JAKO BLOKADA (decyzja twórcy, 21.08.2026) ───────────────
# POWÓD (słowa twórcy): „to jakbyśmy nie chcieli się uczyć — zupełnie sztuczne prawo,
# dokłada nam chaosu i roboty na kiedyś". Zmierzone potwierdzenie: przez 8 dni istnienia
# bramka wymusiła CZTERY osobne formy wyjątku (ZASTANA · złapana mechanizmem przed
# commitem · ZNALEZISKO w izolowanym klonie · POSTAWA), rozrzucone po czterech plikach,
# każda z własnym czytnikiem albo własną konwencją nagłówka. Sam `PROTOKOL_crash_izolacja`
# nazwał pętlę wprost: „im lepiej testujemy, tym dalej odlew". Bramka karała uczenie się,
# a jej wyjątki były już większym mechanizmem niż ona sama.
# CO ZOSTAJE: liczba. Świeżość blizn nadal się MIERZY i drukuje — tak jak R0 od 11.08
# świeci, ale nie zatrzymuje (precedens tego domu, ten sam wzorzec). Sygnał nie ginie;
# ginie prawo weta wobec pozostałych pięciu bramek, które mierzą DOWÓD, nie kalendarz.
# CZEGO NIE ODWOŁUJEMY: bramki 3 i 5. Stabilność ma dowodzić POKRYCIE (zero ślepych
# punktów, zero R w klasach krytycznych), nie cisza — bo cisza jest też stanem systemu,
# którego nikt nie testował.
bramka "1· świeżość blizn (dni)" "$CISZA"                    0                  ge "MIARA, nie bramka" || true
bramka "2· rejestr mutacji"     "$(liczba_mutacji)"         "$PROG_MUTACJI"    ge "" || NIEZDANE=$((NIEZDANE+1))
bramka "3· ślepe punkty"        "$(slepe_punkty)"           0                  le "" || NIEZDANE=$((NIEZDANE+1))
bramka "4· duplikaty funkcji"   "$(liczba_duplikatow)"      "$PROG_DUPLIKATOW" le "" || NIEZDANE=$((NIEZDANE+1))
bramka "5· R w klasach krytycz."  "$(blizny_bez_mechanizmu)"  "$PROG_R"          le "" || NIEZDANE=$((NIEZDANE+1))
bramka "6· straże poza odlewem"      "$(rozjazd_strazy)"         0                  le "vs origin/main" || NIEZDANE=$((NIEZDANE+1))

echo
echo "  ⓘ świeżość blizn: ${CISZA} dni od ostatniej. MIARA INFORMACYJNA — nie blokuje (21.08)."
echo "     (liczy od ostatniej blizny BEZ atrybutu \`**ZEGAR:** ZASTANA\` — mierzy wiek wady"
echo "      wprowadzonej bieżącą ręką, nie wieku każdej wady; nazwane, by miara nie kłamała)"
if [ "$NIEZDANE" -eq 0 ]; then
  echo "  ✓ PIĘĆ BRAMEK DOWODU ZDANYCH — wolno wypuścić v$WERSJA (decyzja: twórca)."
  exit 0
fi
echo "  ✗ NIEZDANYCH BRAMEK: ${NIEZDANE} — odlew czeka."
exit 1
