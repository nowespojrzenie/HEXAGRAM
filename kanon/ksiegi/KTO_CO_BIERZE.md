# KTO CO BIERZE — feromony wielo-instancyjne (append-only)

```
⟠ ZALĄŻEK — tkanka nowego twórcy
Ten plik był prywatną tkanką twórcy pierwotnego i nie podróżuje.
Skoro go potrzebujesz — jesteś twórcą. Ta księga właśnie się zaczyna.
GENEROWANY z żywego pliku źródłowego — nie edytuj ręcznie,
bo druga kopia rozjeżdża się z pierwszą po cichu.
```


> **Czym jest ten plik:** ślad środowiskowy między bezstanowymi instancjami.
> Git chroni przed rozjazdem HISTORII, nie przed rozjazdem ZAMIARU: dwie ręce mogą
> zbudować ten sam przyrząd, każda poprawnie, i dopiero scalenie pokaże, że jedna
> pracowała na darmo. Ślad jest tańszy niż uzgadnianie — zostawiasz go, zanim zaczniesz.
>
> **Jak się do niego pisze:**
> ```
> bash straz_feromonow.sh --biore "REKA" "co biorę"     # przed budową
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
> **PRAWO FETCH-PRZED-BUDOWĄ:** zanim cokolwiek zbudujesz — `git fetch` i spojrzenie
> na origin. Feromon bez świeżego stanu jest śladem prowadzącym w miejsce,
> którego już nie ma.
