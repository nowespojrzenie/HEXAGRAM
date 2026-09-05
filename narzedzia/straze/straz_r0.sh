#!/usr/bin/env bash
# STRAŻ R0 (11.08.2026) — mechanizm dla progu, który przez ≥13 dni był echem.
# RODOWÓD: linia „próg alarmu R0: 35000" w wstan.sh była drukowana obok liczby,
# której NIC nie porównywało — zgłoszone NIEZALEŻNIE przez oba ciała w ROZMOWIE #2
# (odlew v1.1: przekroczenie 1,7× · żywa: 3,2×). Piąty inwariant: prawo bez
# mechanizmu = życzenie. Ten plik jest mechanizmem.
#
# DECYZJA TWÓRCY (11.08, w czacie): bramka MIĘKKA — „niech świeci i nie zatrzymuje,
# komunikuj". rc=0 zawsze w trybie pomiaru; przekroczenie daje WYRAŹNY komunikat ⚠
# z krotnością i wskazaniem wydechu DUSZY. Podniesienie do bramki twardej = osobna
# decyzja twórcy, nie drift tego pliku.
#
# UŻYCIE:  bash straz_r0.sh          (pomiar + komunikat; rc=0 zawsze)
#          bash straz_r0.sh --test   (tor +/− — straż musi umieć NIE przejść)
set -u
cd "$(dirname "$0")/../.."

PROG=36000
# RODOWÓD PROGU (26.08.2026) — pierwszy, jaki ta liczba w ogóle ma.
# 35 000 stało tu od 11.08 BEZ rodowodu pomiarowego (grep: żyło jako `PROG=` i napis
# w wstan.sh, nigdzie indziej). 26.08 zmierzony szereg czasowy sierpnia jedną, dzisiejszą
# formułą na 13 stanach historycznych: R0 waha się 34 571 – 54 422, jądro 24–39 KB
# i WRACA (oddycha, nie rośnie), prarodziny 9,7–12,1 KB (podłoga, nie problem).
# 35 000 przecinało rozkład w połowie naturalnego wahania — świeciło i gasło bez związku
# z tym, czy coś przybyło. Decyzja twórcy: 36 000 („ciut więcej").
# ZAPAS ZMIERZONY W CHWILI DECYZJI: 326 B nad stanem 35 674 — czyli JEDEN AKAPIT.
# To jest nazwane, nie przemilczane: przy tym progu alarm zapali się szybko i ma
# znaczyć „dopisano akapit do jądra", nie „przekroczono bezpieczeństwo".

# WYCINEK kanon/ksiegi/BLEDY.md liczony do R0 — kotwica zamykająca po WZORCU `^## #N`,
# nie po TYTULE. Blizna #49: nagłówek `## ❶ RDZEŃ` przestał istnieć, gdy prawo #22
# ujednoliciło korpus, awk nie ma jak zgłosić braku kotwicy i po cichu połykał
# 99% księgi. Wzorca `^## #[0-9]+` pilnuje lint_bledy.js — kotwica jest teraz
# zależnością mierzoną, nie napisem.
# ── SATELITY (22.08.2026, decyzja twórcy: „postaw znacznik") ────────────────
# Blok `<!-- ⟠ SATELITA ... -->` … `<!-- ⟠ /SATELITA -->` NIE liczy się do R0, bo instancja
# GO NIE CZYTA przy wstaniu — sięga po niego dopiero, gdy padnie wyzwalacz opisany
# w wierszu-spuście, który zostaje w jądrze. WARUNEK, bez którego to jest przesuwanie
# kreski, a nie wydech: w jądrze MUSI stać spust mówiący, że treść istnieje i gdzie leży.
# Znacznik bez spustu = treść, o której instancja nie wie, czyli cicha strata (#56 odwrotnie).
# KOTWICE NA POCZĄTKU LINII — ta straż ma już DWIE blizny od kotwic (#49 i 21.08:
# raz martwa kotwica zamykająca, raz otwierająca trafiająca w cytat). Trzeciej nie będzie.
# JEDNA definicja filtra — czyta stdin. Pierwsza wersja miała dwie kopie tego awk
# (tu i w wycinku BLEDY) i MUTACJE TO ZŁAPAŁY, odmawiając wstrzyknięcia: „wzorzec nie
# występuje dokładnie raz". Dokładnie blizna #49 tej samej straży, o jeden dzień później.
filtr_satelitow() {
  awk '/^<!-- ⟠ SATELITA/{s=1; next} /^<!-- ⟠ \/SATELITA/{s=0; next} !s'
}
bez_satelitow() { filtr_satelitow < "$1" 2>/dev/null | wc -c; }

# ── DRUGA LICZBA (26.08.2026, decyzja twórcy: „zmiana tego, co świeci") ──
# ODWROTNOŚĆ filtra: liczy WYŁĄCZNIE treść wyniesioną do bloków ⟠ SATELITA.
# PO CO: R0 spada dwiema drogami, które z jednej liczby wyglądają IDENTYCZNIE —
#   (a) WYDECH: treść skompostowana, przestaje istnieć          → CAŁOŚĆ maleje
#   (b) PRZENOSINY: treść przesunięta za znacznik, dalej jest    → CAŁOŚĆ stoi
# Jedną liczbę da się zoptymalizować przenosinami (ten sam kształt, co pułapka
# mianownika ratyfikowana 22.08). Dwie nie. Dlatego straż melduje odtąd:
#   R0 (do przeczytania TERAZ) · SATELITY (odłożone, sięgane wg potrzeby) · CAŁOŚĆ.
# CAŁOŚĆ jest niewrażliwa na przesuwanie znacznika — porusza ją wyłącznie
# napisanie albo skompostowanie treści.
# JEDNO ŹRÓDŁO awk-a (blizna #49 tej samej straży): filtr i jego odwrotność
# czytają stdin i stoją tu raz.
tylko_satelity() {
  awk '/^<!-- ⟠ SATELITA/{s=1; next} /^<!-- ⟠ \/SATELITA/{s=0; next} s'
}
sam_satelita() { tylko_satelity < "$1" 2>/dev/null | wc -c; }

zmierz_satelity() {
  local t=0 f
  for f in DUSZA.md 0_SNAPSHOT_watek.md 0_WYWOLANIA.md; do
    [ -e "$f" ] && t=$((t + $(sam_satelita "$f")))
  done
  echo "$t"
}

wycinek_bledy() {
  # KOTWICA OTWIERAJĄCA ZAKOTWICZONA NA POCZĄTKU LINII (21.08.2026) — druga awaria tej
  # samej straży, tym razem od drugiej strony. Wzorzec bez `^` trafiał TAKŻE w CYTAT
  # `## ⬡ PRARODZINY` stojący w środku zdania w korpusie — w opisie blizny o... martwej
  # kotwicy ZAMYKAJĄCEJ tej samej straży. Flaga włączała się ponownie i awk doliczał do R0
  # cały blok korpusu od tamtego zdania. Zmierzone: wycinek 147 linii zamiast 96.
  # TEKST OPISUJĄCY WADĘ BYŁ NOŚNIKIEM TEJ SAMEJ WADY — #50 na poziomie treści, rodzina #12
  # (materia w grawisach czytana jak kod). Naprawa jednoznakowa, granica sprawdzalna:
  # nagłówek zaczyna linię, cytat nigdy.
  awk '/^## ⬡ PRARODZINY/{f=1} /^## #[0-9]+/{f=0} f' "${1:-kanon/ksiegi/BLEDY.md}" 2>/dev/null \
    | filtr_satelitow | wc -c
}

zmierz_r0() {
  # JEDYNA definicja R0 w repo. `wstan.sh` NIE liczy jej drugi raz — woła `--liczba`.
  # Blizna #49, druga warstwa: komentarz deklarował jedność, a w ciele stały dwie kopie
  # z tą samą martwą kotwicą (#38 — reguła istniejąca wyłącznie w dokumentacji).
  local t=0 f
  for f in DUSZA.md 0_SNAPSHOT_watek.md 0_WYWOLANIA.md; do
    [ -e "$f" ] && t=$((t + $(bez_satelitow "$f")))
  done
  echo $((t + $(wycinek_bledy kanon/ksiegi/BLEDY.md)))
}

komunikat() {
  local r0="$1" prog="$2" sat="${3:-}"
  if [ -n "$sat" ]; then
    echo "   ⓘ R0 = ${r0} · SATELITY = ${sat} · CAŁOŚĆ = $((r0 + sat)) B"
    echo "     (CAŁOŚĆ nie drga przy przesuwaniu znacznika ⟠ SATELITA — porusza ją tylko"
    echo "      napisanie albo skompostowanie treści. Spadek R0 przy stałej CAŁOŚCI = przenosiny, nie wydech.)"
  fi
  if [ "$r0" -gt "$prog" ]; then
    local kroc=$((r0 * 10 / prog))
    echo "   ⚠ R0 = ${r0} > próg ${prog} (${kroc%?},${kroc: -1}×) — PRAWO ŚWIECI, NIE ZATRZYMUJE (decyzja twórcy 11.08)."
    echo "   ⚠ Wydech DUSZY czeka w kolejce: destylat gęstnieje szybciej, niż jest kompostowany."
    return 1   # sygnał dla toru; tryb pomiaru i tak zwraca 0 (miękka)
  fi
  echo "   ✓ R0 = ${r0} ≤ próg ${prog} — budżet wdechu trzyma."
  return 0
}

# ── TRYB LICZBOWY: jedyne wyjście dla wstan.sh (koniec duplikatu formuły) ──
if [ "${1:-}" = "--liczba" ]; then zmierz_r0; exit 0; fi

# ── TOR TESTOWY (#38) — bez niego ta straż byłaby tą samą chorobą, którą leczy ──
if [ "${1:-}" = "--test" ]; then
  echo "╔═══ STRAŻ R0 — AUTOTEST (#38) ═══╗"
  zle=""
  # (+) przekroczenie MUSI dać komunikat ⚠ (sygnał wewn. 1)
  komunikat 113354 35000 >/dev/null; [ $? -eq 1 ] || zle="$zle przekroczenie-nie-świeci"
  # (−) stan pod progiem MUSI przejść cicho-zielono (sygnał 0)
  komunikat 20000 35000 >/dev/null;  [ $? -eq 0 ] || zle="$zle zdrowy-alarmuje"
  # (=) równość progu NIE alarmuje (próg to sufit, nie ściana przed sufitem)
  komunikat 35000 35000 >/dev/null;  [ $? -eq 0 ] || zle="$zle równość-alarmuje"
  # (⊙) pomiar realny na tym repo zwraca liczbę > 0 (formuła żyje, nie pusta)
  R=$(zmierz_r0); [ "$R" -gt 0 ] || zle="$zle pomiar-pusty"
  # (⊘) MIĘKKOŚĆ: tryb pomiaru MUSI zwrócić rc=0 nawet przy przekroczeniu —
  #     twardnienie tej straży bez decyzji twórcy ma tu OBLAĆ.
  ( exec >/dev/null; bash "$0" ); [ $? -eq 0 ] || zle="$zle bramka-stwardniała-sama"
  # ── TORY NA MIARĘ (#49) — pięć powyższych testowało wyłącznie ALARM.
  #    Straż mierząca źle i dzwoniąca bezbłędnie daje PEWNOŚĆ OPARTĄ NA FAŁSZYWEJ
  #    WIELKOŚCI — gorzej niż cisza. Prawo #49: tor na alarm to nie tor na miarę.
  TR="$(mktemp -d)"
  printf '## ⬡ PRARODZINY\nAAAA\n## ▣ INDEKS\nBBBB\n## #1 (❶) RDZEN\n' > "$TR/BLEDY.md"
  # T-CYTAT (21.08): kotwica otwierająca musi ignorować CYTAT wzorca w środku zdania.
  # Fikstura ODRÓŻNIALNA (#64): ta sama treść raz jako NAGŁÓWEK (liczona), raz jako cytat
  # w korpusie (pomijana) — bez drugiego przebiegu „nie dolicza" byłoby nieodróżnialne
  # od „nie liczy w ogóle". Rodowód: wzorzec bez `^` trafiał w opis blizny o martwej
  # kotwicy tej samej straży i doliczał korpus — tekst o wadzie niósł tę samą wadę.
  printf 'X%.0s' $(seq 1 9000) >> "$TR/BLEDY.md"     # korpus, którego NIE wolno liczyć
  # (①) wycinek nie połyka korpusu
  W1="$(wycinek_bledy "$TR/BLEDY.md")"
  [ "$W1" -lt 200 ] || zle="$zle wycinek-połyka-korpus($W1)"
  # (②) przemianowanie TYTUŁU nie rusza pomiaru — kotwica po wzorcu, nie po napisie
  sed -i 's/## #1 (❶) RDZEN/## #1 (❶) ZUPELNIE INNY TYTUL/' "$TR/BLEDY.md"
  W2="$(wycinek_bledy "$TR/BLEDY.md")"
  [ "$W2" -eq "$W1" ] || zle="$zle kotwica-zależna-od-tytułu($W1→$W2)"
  # (②b) CYTAT wzorca w korpusie NIE MOŻE włączać flagi (21.08). Fikstura odróżnialna:
  #      ta sama treść raz jako nagłówek (liczona), raz w środku zdania (pomijana).
  printf 'tekst o bledzie: kotwica `## ⬡ PRARODZINY` byla zla\n' >> "$TR/BLEDY.md"
  printf 'Y%%.0s' $(seq 1 5000) >> "$TR/BLEDY.md"
  W3="$(wycinek_bledy "$TR/BLEDY.md")"
  [ "$W3" -eq "$W2" ] || zle="$zle cytat-wzorca-wlacza-flage($W2→$W3)"
  # (③) na ŻYWEJ księdze wycinek musi być mniejszy niż pół pliku
  CALY=$(wc -c < kanon/ksiegi/BLEDY.md); ZYWY=$(wycinek_bledy kanon/ksiegi/BLEDY.md)
  [ "$ZYWY" -lt $((CALY / 2)) ] || zle="$zle żywy-wycinek-to-cały-plik($ZYWY/$CALY)"
  # (④) SATELITY (22.08) — fikstura ODRÓŻNIALNA (#64): TA SAMA treść raz poza blokiem
  #     (liczona), raz w bloku (pomijana). Bez drugiego przebiegu „nie doliczył" byłoby
  #     nieodróżnialne od „nie liczy w ogóle". Kotwice na początku linii — ta straż ma
  #     już dwie blizny kotwicowe, a znacznik bywa CYTOWANY w tekście o znacznikach.
  printf 'jadro\n' > "$TR/S.md"; printf 'Z%.0s' $(seq 1 3000) >> "$TR/S.md"; printf '\n' >> "$TR/S.md"
  S1="$(bez_satelitow "$TR/S.md")"
  [ "$S1" -gt 3000 ] || zle="$zle satelita-gubi-jądro($S1)"
  printf '<!-- ⟠ SATELITA t → spust -->\n' >> "$TR/S.md"
  printf 'Q%.0s' $(seq 1 5000) >> "$TR/S.md"; printf '\n<!-- ⟠ /SATELITA -->\n' >> "$TR/S.md"
  S2="$(bez_satelitow "$TR/S.md")"
  [ "$S2" -lt $((S1 + 200)) ] || zle="$zle satelita-nie-pomijany($S1→$S2)"
  # (④b) blok NIEDOMKNIĘTY nie może zjeść reszty pliku po cichu — po otwarciu bez
  #     zamknięcia wszystko dalej znika z pomiaru, czyli R0 spada BEZ wydechu.
  printf 'ogon-ktory-musi-byc-liczony\n' >> "$TR/S.md"
  S3="$(bez_satelitow "$TR/S.md")"
  [ "$S3" -gt "$S2" ] || zle="$zle blok-domkniety-nie-wpuszcza-ogona"
  # (④c) CYTAT znacznika w środku zdania NIE MOŻE włączyć pomijania (22.08). Ten plik
  #     OPISUJE znaczniki, więc wzorzec stoi w nim także jako tekst — bez `^` straż
  #     zaczęłaby połykać resztę pliku od pierwszej wzmianki. Trzecia odsłona tej samej
  #     blizny kotwicowej; MUTACJA `r0-satelita-kotwica-bez-poczatku-linii` była ŚLEPA,
  #     dopóki tego przebiegu nie było.
  printf 'zdanie o tym ze <!-- ⟠ SATELITA --> to znacznik\n' > "$TR/C.md"
  printf 'W%.0s' $(seq 1 4000) >> "$TR/C.md"; printf '\n' >> "$TR/C.md"
  C1="$(bez_satelitow "$TR/C.md")"
  [ "$C1" -gt 4000 ] || zle="$zle cytat-znacznika-wlacza-pomijanie($C1)"
  rm -rf "$TR"
  # ── TORY NA DRUGĄ LICZBĘ (26.08) — miara, nie alarm (prawo #49 na nowej wielkości) ──
  TS="$(mktemp -d)"
  printf 'AAAA\n<!-- ⟠ SATELITA x -->\nBBBBBBBB\n<!-- ⟠ /SATELITA -->\nCC\n' > "$TS/po.md"
  # (⊙) filtr i jego ODWROTNOŚĆ dzielą materię bez gubienia i bez podwajania — liczone WPROST
  _j="$(bez_satelitow "$TS/po.md")"; _s="$(sam_satelita "$TS/po.md")"
  [ "$_j" -eq 8 ] || zle="$zle jadro-liczy-zle($_j)"      # "AAAA\n"+"CC\n"
  [ "$_s" -eq 9 ] || zle="$zle satelita-liczy-zle($_s)"   # "BBBBBBBB\n"
  # (−) CAŁY POWÓD ISTNIENIA DRUGIEJ LICZBY: przenosiny obniżają R0, a CAŁOŚCI nie ruszają.
  printf 'AAAA\nBBBBBBBB\nCC\n' > "$TS/przed.md"
  _jp="$(bez_satelitow "$TS/przed.md")"
  [ $((_jp + $(sam_satelita "$TS/przed.md"))) -eq $((_j + _s)) ] || zle="$zle przenosiny-zmieniaja-calosc"
  [ "$_jp" -gt "$_j" ] || zle="$zle przenosiny-nie-obnizaja-R0"
  # (⊘) satelita bez zamknięcia nie może połknąć reszty pliku (ta straż ma DWIE blizny od kotwic)
  printf 'AAAA\n<!-- ⟠ SATELITA x -->\nBB\n' > "$TS/otwarty.md"
  [ "$(sam_satelita "$TS/otwarty.md")" -eq 3 ] || zle="$zle satelita-bez-zamkniecia-polyka"
  rm -rf "$TS"
  if [ -z "$zle" ]; then
    echo "  ✓ STRAŻ ŻYWA — 12 torów: świeci na przekroczeniu, milczy pod progiem,"
    echo "    równość przepuszcza, formuła mierzy, miękkość zaryglowana torem,"
    echo "    MIARA nie połyka korpusu, nie zależy od tytułu i nie jest całym plikiem (#49),"
    echo "    a DRUGA LICZBA łapie przenosiny: R0 spada, CAŁOŚĆ stoi (26.08)."
    exit 0
  fi
  echo "  ✗ STRAŻ MARTWA — oblane:$zle"
  exit 1
fi

# ── TRYB POMIARU (wołany z wstan.sh) ──
komunikat "$(zmierz_r0)" "$PROG" "$(zmierz_satelity)" || true
exit 0
