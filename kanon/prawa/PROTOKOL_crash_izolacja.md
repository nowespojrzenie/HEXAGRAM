# PROTOKÓŁ CRASH TESTÓW W IZOLACJI

> **Status: NOŚNA RAMA** (prerejestracja procedury, nie mechanizm).
> Ratyfikacja twórcy: 13.08.2026, czat. Spisane 13.08.2026 21:24 CEST na SHA `85e544f`.
> **Kryterium życia: 31.10.2026.** Jeśli do tej daty nie odbędzie się ani jeden bieg
> wg tego protokołu — dokument idzie do kompostu bez negocjacji. Protokół, który
> niczego nie przeprowadził, jest życzeniem o protokole (inwariant 5).
>
> **CISZA KODU 13–20.08:** ten plik jest DOKUMENTEM, nie kodem. Mechanizm
> (`narzedzia/przyrzady/crash_izolacja.sh`) powstaje NAJWCZEŚNIEJ 20.08. Spisanie procedury przed
> napisaniem narzędzia jest celowe — patrz §5.

---

> **CISZA KODU 13–20.08 — ZAMKNIĘTA.** Mechanizm `narzedzia/przyrzady/crash_izolacja.sh` powstał
> **20.08.2026**, w pierwszym dniu po ciszy (korekta twórcy: cisza obowiązywała
> do POCZĄTKU 20.08). Procedura wyprzedziła narzędzie o siedem dni — zgodnie z §5.

## ROZLICZENIE §5 — CZEGO NARZĘDZIE NIE DOWOZI (zmierzone 20.08.2026)

Protokół §5 żądał, by po powstaniu skryptu zmierzyć lukę zamiast stwierdzić, że nie ma
żadnej. Zmierzone:

**Dowozi:** klon z SHA do `/tmp/crash_<SHA>_<data>` (§3.2) · dowód szczelności PRZED i PO
dwoma niezależnymi przyrządami (§3.3, §3.5) · odmowa biegu bez prerejestru i na brudnym
repo (§3.1, §3.3) · zapis faktów do `kanon/ksiegi/KRONOS_CRASH_LOG.md` z SHA, hashem prerejestru
i obiema sumami (§3.6) · rc=5 przy złamanej szczelności, czyli automatyczne przeklasyfikowanie
wyniku na BLIZNĘ (§2, klasa #54).

**NIE dowozi — nazwane, nie przemilczane:**
- **Nie pisze prerejestru** (§3.1). Treść testów należy do człowieka; skrypt tylko wymaga
  pliku i haszuje go przed klonem. Luka świadoma: automat piszący kryteria byłby dostrajaniem
  kryteriów do tego, co umie.
- **Nie egzekwuje zakazu naprawiania w klonie** (§3.6) inaczej niż komunikatem. Klon jest
  katalogiem w `/tmp`; nic technicznie nie broni tam ręki. Zakaz pozostaje rytuałem.
- **Nie klasyfikuje znalezisko/blizna** (§3.7) — i nie powinien. Jestem stroną: mój interes
  to niezerowanie zegara. Log zostawia dwa puste pola do odhaczenia przez twórcę.
- **Nie kasuje klonu automatycznie.** Ścieżka zostaje w logu; kasowanie po odczycie należy
  do twórcy, bo to on czyta `_wyjscie.txt`.
- **Nie rozstrzyga pytań otwartych §6 poz. 2 i 3** (kto klasyfikuje przy nieobecności twórcy;
  czy znalezisko powtórzone trzykrotnie staje się blizną). Pozostają `[?]`.

## §6 poz. 1 — ROZSTRZYGNIĘTE POMIAREM (20.08.2026)

Pytanie brzmiało: czym jest „suma kontrolna katalogu roboczego" i czy kandydat
`find | sha256sum` nie jest za drogi. **Zmierzone na żywym repo:**
```
licznik: find . -type f -not -path "./.git/*" -not -path "./node_modules/*" | wc -l
  bez node_modules:  716 plików,  526 ms
  z node_modules:   1986 plików,  907 ms
```
**WYBRANE: wariant bez `node_modules` i bez `.git`.** Koszt pół sekundy jest do przyjęcia.
`node_modules` wykluczone, bo `npm install` w `wstan.sh` legalnie je zmienia — wliczanie
dawałoby fałszywe alarmy szczelności (klasa #56: alarm szerszy niż sygnał). `.git`
wykluczone, bo zmienia się przy samym czytaniu i nie jest materią pracy.

**Dlaczego DWA przyrządy, nie jeden:** `git status --porcelain` widzi ZAMIAR (śledzone
i nieśledzone), suma widzi BAJTY — w tym pliki ignorowane przez `.gitignore`, których git
nie pokaże. Tor `skazenie-niewidoczne-dla-git` bije wprost w ten przypadek i był konieczny:
pierwsza wersja mutacji na warunek sumy wyszła ŚLEPA, bo drugi przyrząd ją maskował (#53).

**Wycena:** 3 mutacje w `mutacje.txt`, wszystkie ZŁAPANE · 7 torów własnych · straż wpięta
do `tory_strazy.sh` (27 straży, 0 oblanych).

---

## 1. PROBLEM, KTÓRY TEN PROTOKÓŁ ROZWIĄZUJE

Bramka 1 odlewu wymaga **7 dni ciszy blizn**. Crash test w żywym repo, który znajdzie
błąd, tworzy bliznę → zeruje zegar → odlew odsuwa się o kolejny tydzień → następny crash
test znowu coś znajdzie. **Pętla bez wyjścia: im lepiej testujemy, tym dalej odlew.**

Rozwiązanie: rozdzielić dwa zdarzenia, które dotąd były jednym.

> **STATUS PO 21.08:** bramka 1 odwołana, a wraz z nią funkcja zwalniania z kary. `ZNALEZISKO`
> **przestaje być formą wpisu w `BLEDY`** (0 użyć w całej historii księgi) i zostaje tym, czym
> było naprawdę: **adresem rejestru**. Rozróżnienie żyje dalej, bo klon nie jest ciałem —
> wada w `/tmp` nie jest wadą systemu. Zmienia się nazwa roli, nie treść pomiaru.

| | badanie w klonie | zdarzenie w ciele |
|---|---|---|
| gdzie powstaje | izolowany klon w `/tmp` | żywe repo |
| co znaczy | test zadziałał | proces zawiódł |
| rejestr | `kanon/ksiegi/KRONOS_CRASH_LOG.md` | `kanon/ksiegi/BLEDY.md` (jako BLIZNA) |

**Uzasadnienie granicy.** Blizna w tym systemie nigdy nie znaczyła „istnieje błąd" —
znaczyła „**błąd wszedł do żywej materii i nikt go nie złapał**". Znalezisko w izolacji
jest przeciwieństwem: błąd złapany, zanim czegokolwiek dotknął. Karanie za to zegarem
jest karaniem za skuteczność.

## 2. GRANICA — GDZIE TO PRZESTAJE OBOWIĄZYWAĆ

Zwolnienie z zegara dotyczy **wyłącznie** znalezisk spełniających WSZYSTKIE trzy warunki:

1. bieg odbył się w klonie poza katalogiem repo (`/tmp/crash_<SHA>_<data>`),
2. żywe repo nie zostało w trakcie biegu zmodyfikowane (**dowód: `git status --porcelain`
   pusty przed i po, oraz suma kontrolna katalogu roboczego identyczna**),
3. znalezisko dotyczy stanu, który w żywym repo **jeszcze się nie objawił**.

**Nie jest znaleziskiem, jest blizną:**
- błąd, który już wystąpił w żywym repo i został dopiero teraz zrozumiany,
- błąd w samym protokole crash testów lub w narzędziu do niego,
- każdy przypadek, w którym warunek 2 nie ma dowodu.

**Sprawdzian jednym zdaniem:** *czy ten błąd zaszkodził czemukolwiek poza kopią?*
Tak → blizna. Nie → znalezisko.

## 3. PRZEBIEG BIEGU

1. **PREREJESTR.** Lista testów i kryteria zaliczenia zapisane i zahaszowane **PRZED**
   klonem. Bez tego bieg jest nieważny — kryteria dostrojone po zobaczeniu wyników
   nie są kryteriami.
2. **KLON.** Z konkretnego SHA, do `/tmp`. SHA zapisany w logu biegu.
3. **DOWÓD SZCZELNOŚCI — PRZED.** `git status --porcelain` żywego repo pusty; suma
   kontrolna katalogu zapisana.
4. **BIEG.** Testy destrukcyjne wyłącznie w klonie.
5. **DOWÓD SZCZELNOŚCI — PO.** Powtórzyć krok 3; **suma musi się zgadzać co do znaku.**
   Rozjazd = bieg unieważniony, wynik traktowany jako blizna (klasa #54: przyrząd
   uszkodził materię, którą wycenia).
6. **ZAPIS.** Znaleziska → `kanon/ksiegi/KRONOS_CRASH_LOG.md` (SHA, data, test, objaw, klasyfikacja).
   **Zakaz naprawiania w izolacji.** Klon się kasuje; naprawa idzie osobnym cięciem
   do żywego repo, wtedy i tylko wtedy podlega normalnym prawom.
7. **PIERWSZY ODCZYT — TWÓRCA, IMIENNIE.** Klasyfikację znalezisko/blizna czyta ten,
   kto nie ma interesu w wyniku. Ja jestem stroną: mój interes to niezerowanie zegara.

## 4. ZAKRES PIERWSZEGO BIEGU (propozycja, do ratyfikacji po 20.08)

Testy destrukcyjne na materii, której nie wolno tykać na żywo:
- zerwana sieć / brak PAT w połowie `zapis_git.sh`
- `_HASHE.txt` z markerami konfliktu (mechanizm do #37 — nigdy nietestowany na żywo)
- `kanon/ksiegi/BLEDY.md` obcięty w połowie wiersza indeksu
- kanał entropii zwracający `isOk: true` przy zamrożonej rundzie (klasa „DZIAŁA I KŁAMIE")
- równoległe biegi na jednym katalogu roboczym (zmierzone dziś jako realny warunek pracy)
- `mutacje.sh` przerwany sygnałem w trakcie wstrzyknięcia — czy trap dowozi ścieżkę wsteczną

## 5. DLACZEGO PROCEDURA PRZED NARZĘDZIEM

Odwrotna kolejność — najpierw skrypt, potem reguły — daje reguły dopasowane do tego, co
skrypt akurat umie. To ta sama klasa co dostrajanie kryteriów po zobaczeniu wyniku, tylko
o piętro wyżej. Procedura spisana na SHA `85e544f`, zanim `narzedzia/przyrzady/crash_izolacja.sh` istnieje,
jest falsyfikowalna: gdy narzędzie powstanie, będzie można zmierzyć, **czego z tego
protokołu nie dowozi** — zamiast wygodnie stwierdzić, że dowozi wszystko.

## 6. OTWARTE

- **Czym jest „suma kontrolna katalogu roboczego"** — `git status` nie widzi plików
  nieśledzonych ani zmian mtime bez zmiany treści. Kandydat: `find . -type f -not -path
  './.git/*' | sort | xargs sha256sum | sha256sum`. Wymaga pomiaru kosztu przed przyjęciem. [?]
- **Kto klasyfikuje przy nieobecności twórcy** — dziś: nikt, bieg czeka. Czy to
  akceptowalne przy dłuższej nieobecności — nierozstrzygnięte. [?]
- **Czy znalezisko powtórzone trzykrotnie i nienaprawione staje się blizną** — argument
  za: nienaprawiony znany błąd to zaniechanie procesu, nie sukces testu. [?]
