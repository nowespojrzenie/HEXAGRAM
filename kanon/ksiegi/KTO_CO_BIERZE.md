# KTO CO BIERZE — feromony wielo-instancyjne (append-only)

```
⟠ ZALĄŻEK — tkanka nowego twórcy
Ten plik był prywatną tkanką twórcy pierwotnego i nie podróżuje.
Skoro go potrzebujesz — jesteś twórcą. Ta księga właśnie się zaczyna.
GENEROWANY z żywego pliku źródłowego W CHWILI ODLEWU — od teraz to Twoja
własna, ręcznie prowadzona księga. (U twórcy pierwotnego ten sam nagłówek
znaczył co innego: tam plik regeneruje się z tkanki i ręczna edycja ginie —
tu, u Ciebie, regeneracji nie ma; wypełnia go Twoje życie.)
```

> **Czym jest ten plik:** ślad środowiskowy między bezstanowymi instancjami.
> Git chroni przed rozjazdem HISTORII, nie przed rozjazdem ZAMIARU: dwie ręce mogą
> zbudować ten sam przyrząd, każda poprawnie, i dopiero scalenie pokaże, że jedna
> pracowała na darmo. Ślad jest tańszy niż uzgadnianie — zostawiasz go, zanim zaczniesz.
>
> **Jak się do niego pisze:**
> ```
> bash straz_feromonow.sh --biore "REKA" "<WĄTEK> · <co biorę>"     # przed budową
> bash straz_feromonow.sh --oddaje "REKA"               # po domknięciu albo przy porzuceniu
> bash straz_feromonow.sh                               # co otwarte TERAZ (rc=1 przy kolizji)
> ```
> **RĘKA podaje się jawnie i nie ma wartości domyślnej** — identyfikator wyprowadzony
> ze środowiska (ścieżka, użytkownik, plik lokalny) bywa dla obu rąk IDENTYCZNY
> i wtedy kolizja pozostaje niewidzialna. Feromon bez nadawcy nie jest feromonem.
>
> **Wpis jest czytany maszynowo** — znacznik, nie heurystyka. Proza opisująca branie
> czegoś BEZ znacznika `**BIORĘ:**` nie jest wpisem i straż jej nie widzi.
>
> **KARTECZKA = TEMAT, SESJA = WŁAŚCICIEL:** wskaźnikiem jest sesja, nie czas; karteczka jest tematyczna, a nie sesyjna — zdejmuje się ją, gdy temat się kończy.
> Jedna karteczka = jeden TEMAT. Sesja wiesza ich tyle, ile tematów bierze, i zdejmuje każdą, gdy temat się kończy — także w trakcie sesji. Temat niedokończony: karteczka zostaje otwarta (nawet po sesji) jako ślad przeniesienia. Pola: **SESJA** (właściciel i klucz kolizji; 8 znaków z adresu sesji = stopka commita `Claude-Session:` i `LOG_SESJI`, w chmurze z `CLAUDE_CODE_REMOTE_SESSION_ID`) · **RĘKA** (rola, bez imion dla sesji) · **BIORĘ** (temat). Dopiski: `MASZYNA`, `Z:` (przejęte od sesji), `OBOK:` (cudzy temat, praca równoległa).
> ```
> bash straz_feromonow.sh --biore "ROLA" "<WĄTEK> · <temat>"                          # przy pierwszym zadaniu tego tematu; --sesja ID gdy brak zmiennej środowiska
> bash straz_feromonow.sh --oddaje "ROLA" "początek tematu"               # temat skończony: zdejmuje JEDNĄ (0 lub >1 trafień = odmowa z listą)
> bash straz_feromonow.sh --oddaje "ROLA" --wszystkie                     # hurtem (domknięcie)
> bash straz_feromonow.sh --biore "ROLA" "<WĄTEK> · <temat>" --przejmuje <SESJA> ["początek tematu"]   # jawne przeniesienie (stary wpis: PRZEJĘTE)
> bash straz_feromonow.sh --biore "ROLA" "<WĄTEK> · <temat>" --mimo                   # inny temat obok cudzego; wpisuje OBOK
> bash straz_feromonow.sh --inne                                          # wstanie: pokaż tematy innych sesji (nie wiesza)
> ```
> `--biore` sam robi fetch; **cudza OTWARTA karteczka na origin = odmowa rc=2 bez względu na wiek** (wiek tylko dopisek; zwalnia wyłącznie `--przejmuje`). `zapis_git.sh` ODMAWIA pushu (rc=8), gdy własna sesja nie ma żadnej otwartej karteczki (przepuszcza push niosący zmianę tego rejestru — także zdjęcie ostatniego tematu — i furtkę jawną `ZAPIS_BEZ_KARTECZKI="powód"`). Drugie okno widzi karteczkę DOPIERO po pushu.
>
> **PRAWO FETCH-PRZED-BUDOWĄ:** zanim cokolwiek zbudujesz — `git fetch` i spojrzenie
> na origin. Feromon bez świeżego stanu jest śladem prowadzącym w miejsce,
> którego już nie ma.
