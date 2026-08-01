# BŁĘDY I STRAŻE — pamięć odpornościowa

> Membrana / próg. **Uczymy się na błędach — nie wstydzimy się ich.** (twórca, 27.06 — kluczowe.)
> Każdy błąd: objaw → konsekwencja → straż strukturalna → reguła ponawiania.
> Append-only: dopisujemy tryby, gdy je wykryjemy. Błąd ukryty wraca; błąd zmapowany staje się odpornością.


## ⬡ PRARODZINY — sześć praw-matek (warstwa wejścia, 23.07.2026)
> 22 błędy to twarze SZEŚCIU intencji. Przed operacją zadaj 6 pytań bramkowych — nie pamiętaj 22 reguł. Prarodzina = cel i nawigacja; konkret actionable żyje w korpusie [#N] pod spodem — NIE zastępujemy go, dodajemy piętro nad. „Mniej zasad” nie jest celem (pułapka #4) — uogólniamy tam, gdzie jest wspólny rdzeń, nie dla liczby.

| ⬡ Prarodzina | Pytanie bramkowe | Twarze | Warstwy (schodzenie niżej) |
|---|---|---|---|
| **POMIAR > PAMIĘĆ** | czy orzekam z pomiaru, nie z pamięci? | #1 #2 #8 #13 #20 #21 #23 | mierz → właściwym przyrządem (#20) → w właściwym układzie (#21) → też nieobecność (#8) → z pliku nie pamięci (#13) |
| **GŁADKOŚĆ = OSTRZEŻENIE** | czy piękno/„mniej”/gęstość nie usypia czujności? | #3 #4 #6 | źródło (#3) → cięcie/„mniej plików” (#4) → własne wyjście/przeprodukcja (#6) |
| **SYGNAŁ ≠ PRAWDA** | czy werdykt z rc i dowodu, nie z tekstu? | #16ᴰ #17 #18 #19 | zero=dana (#18) → rc nie fraza (#19) → dowód bitwy +/− (#16ᴰ #17) |
| **DWA INTERPRETERY** | czy widzę wszystkie warstwy interpretacji tekstu? | #12 #16 | cudzysłowy (#12) → \\x01/heredoc (#16) |
| **ŻYWE REPO** | czy pracuję na świeżym współdzielonym stanie? | #9 #10 #11 #15 | pull na starcie (#10) → merge zatrzymuje rękę (#9) → rebase zakazany/tożsamość (#11) → tkanka po merge (#15) |
| **RZEMIOSŁO / GRANICA** | czy trzymam regułę TEJ domeny? | #5 #14 | Prześwit pusty (#5) · druk: czytelność>piękno (#14) |
| *META* | czy sama księga jest spójna? | #22 (#7 pusty) | jeden kanon [#N] + indeks; nowy wpis + wiersz w tej samej turze |

**Uwaga:** #16 ma dwie twarze (SYGNAŁ: czerwone zero ᴰ; DWA INTERPRETERY: \\x01) — rodziny się przecinają, to nie sztywne kubełki. Prarodziny domykają legislację: dalej prawa służą celom (żniwa), nie mnożą się.

---

## ▣ INDEKS KANONICZNY — punkt wejścia (konkordancja v2, 23.07.2026)
> Kanon numeru = **liczba `[#N]`** w chronologii. Glify historyczne (❶… / ⑮…) = legacy — czytaj przez ten słownik. Cyfry, bo PRAWO DRUKU (#14) i grep. Statusy: **P** pamięć · **R** rytuał/szablon · **M** mechanika. Korpus poniżej rośnie append-only; TU się wchodzi.

| # | legacy | Prawo (jedno zdanie) | Rodzina | Status | Nośnik / kandydat M |
|---|---|---|---|---|---|
| 1 | ❶ | pomiar > pamięć — zmierz, nie wnioskuj | POMIAR | R | wstan mierzy zegar; „⏱ZMIERZONE” |
| 2 | ❷ | nazwij układ odniesienia przed geometrią | UKŁAD | M | jedno źródło ayanamsy; getC |
| 3 | ❸ | elegancja/piękno = ostrzeżenie, nie zgoda | ELEGANCJA | R | pole CO ODRZUCAM w destylacie |
| 4 | ❹ | różne tempa ≠ scalaj | — | M | .gitattributes + twardy checkout |
| 5 | ❺ | Prześwit pusty — nie animuj, nie wyroczcz | — | R | straże „nie mówi” |
| 6 | ❻ | przeprodukcja — krótsze i otwarte > pełne | ELEGANCJA | P | natura rozmowy |
| 7 | ❼ | *(PUSTY — żyje tylko w odwołaniu `straz_czystosci`; wpis nigdy nienapisany)* | — | — | do uzupełnienia albo scalenia |
| 8 | ❽ | „tego nie ma” wymaga grep-a jak liczba silnika | POMIAR | R | Filtr na własny alarm |
| 9 | ❾ | nigdy `merge && add && commit` jednym tchem | GIT | M | sync: exit przy konflikcie |
| 10 | ❿ | pull na starcie każdej sesji; commit prefiks maską | GIT | R | wstan pull |
| 11 | ⓫ | rebase zakazany (brak edytora) → reset+cherry-pick | GIT | P | zakaz narzędzia |
| 12 | ⓬ | polska treść do pliku tylko w potrójnych cudzysłowach | INTERPOLACJA | R | create_file / \uXXXX |
| 13 | ⓭ | czytaj przed edycją, mierz po; podmiana fail-głośno | POMIAR | **M-cz.✓** | str_replace wymusza unikalność wzorca i pada głośno (egzekwuje środowisko, nie repo — stąd niskie przywołanie 28.07) |
| 14 | ⓲ | PRAWO DRUKU: czytelność > piękno; komórka = Paragraph | — | R | STANDARD_TRESCI.md |
| 15 | ⑮ | po merge z main — twardy checkout tkanki | GIT | M✓ | sync_rdzen |
| 16 | ⑯ | _HASHE nigdy point-edit; regen z dysku; \uXXXX | INTERPOLACJA | M✓ | hook: sonda `od` |
| 17 | ⑰ | bezpiecznik wyklucza własny plik; test +/− przed zaufaniem | BEZPIECZNIK | M✓ | exclude w publikuj |
| 18 | ⑱ | zero/porażka = dana; werdykt z rc; dowód bitwy | ZERO | R+M-częśc. | hook ostrzega |
| 19 | ⑲ | werdykt operacji zdalnej TYLKO z rc, nie z frazy | ZERO | **M✓** | zapis_git.sh rc-gate (test +/−) |
| 20 | ⑳ | kotwica krzyżowa: zegar sandboxa vs stempel origin | POMIAR | **M✓** | wstan.sh — main+prywatna (parytet) |
| 21 | ㉑ | kalendarz/typ dnia TYLKO przez kronos_v4 (nie tropik) | POMIAR/UKŁAD | **R+M-cz.** | hook ostrzega; inline eval omija |
| 22 | — | numeracja księgi = jeden kanon [#N]; indeks-słownik jako wejście | META | **M✓** | `lint_bledy.js` — indeks↔korpus, jeden format `## #N`, **zgodność glifów**, ciągłość, duplikaty; rc-gate, dwa dowody bitwy +/− 28.07; wpięty w `wstan.sh` |
| 23 | — | werdykt na materii tekstowej = odczyt CAŁOŚCI, nie filtr etykiet | POMIAR | R | kand: lint pokrycia odczytu |
| 24 | ⓲* | eter/dziennik twórcy = surowiec nietykalny; tryb skryby, nie sędziego | RZEMIOSŁO | R | 6_PRZESWIT: TRYB SKRYBY |
| 25 | ⓳* | wiedza o ryzyku nie ma pory dnia; odroczenie zapisu = decyzja | ELEGANCJA | **POSTAWA** (niemechanizowalne — świadomie, 28.07) | dom: `RDZEN_SAMOOBSERWACJI`; nie udaje prawa, bo mechanizmu mieć nie może |
| 26 | ㉔* | „ochrona protokołu" przechodzi Filtr jak każde zdanie; dat zer nie podaje się w czacie | POMIAR | R | ANEKS C #005 |
| 27 | ㉔* | godzina twórcy TYLKO z TZ=Europe/Warsaw; stemple --date=format-local | POMIAR | M✓ | wstan.sh „← MELDUJ TEN" |
| 28 | ㉕ | komunikat narzędzia = objaw, nie przyczyna; interpretacja wymaga 2. pomiaru | POMIAR | R+rytuał | stała pozycja w `⟐ META`: „awaria przyrządu → drugi pomiar" (obok licznika pomiarów #30) |
| 29 | — | wstanie wykonuje się RAZ; wynik czytaj z 0_MELDUNEK.txt | POMIAR | M✓ | wstan.sh: tee |
| 30 | — | każda liczba ma swój licznik; „policzone wzrokiem" = z pamięci | POMIAR | R | META: licznik pomiarów (wzór B) |
| 31 | — | amend tylko na własnym i niepushniętym; w rebase: status przed komendą | POMIAR | R | rc-gate łapie skutek (dowód 28.07) |
| 32 | — | artefakt oddany do pobrania, a nie zacommitowany, dla systemu NIE ISTNIEJE; rejestr nie może twierdzić inaczej | POMIAR/ŻYWE REPO | **M✓** | `lint_artefaktow.js` — twierdzenia rejestrów ↔ pliki śledzone; rc-gate, dowód bitwy +/− 29.07; wpięty w `wstan.sh` |

**KOMPOST 28.07.2026 (decyzja twórcy):** wpisy zmechanizowane (M✓) żyją w korpusie jako
KAPSUŁY (prawo + strażnik); pełne teksty i historia: `archiwum błędów (poza wydaniem publicznym)`. Glify ⓲⓳㉔㉕
z 24–27.07 kolidowały/dublowały się — wpisy dostały numery #24–#28 (chronologia).

**Usterki numeracji naprawione tym indeksem (bez ruszania historii):** druk = **#14** (glif ⓲ był błędny); #7 = jawnie pusty; stara tabela myliła rebase jako „10" (kanon **#11**) i przesuwała 15–18 na 13–16. Odwołania „rodzina ⑯” (w #19) = zielone-zero = **#18**; „rodzina ⑳” = **#20**. Zmechanizowane 23.07: **#19 M✓** (rc-gate), **#20 M✓** (kotwica main+prywatna), **#21 R+M-cz.** (hook ostrzega). Meta **#22** dopisany.

---

## #1 (❶) RDZEŃ WSZYSTKICH BŁĘDÓW — wnioskowanie z pamięci zamiast pomiaru

**Objaw:** twierdzę coś o pozycji / dacie / stanie / strukturze repo z pamięci, nie z uruchomienia.
**Twarze (zmierzone, 21–27.06):** błąd układu odniesienia ×2 · daty plików z pamięci (23 vs zmierzone 24) ·
dwa alarmy „niespójność" cofnięte po uruchomieniu · „swisseph się nie kompiluje" (fałsz) · pytanie zamiast pomiaru ·
struktura repo ≠ pamięć (27.06).
**Konsekwencja:** fałszywy alarm albo błąd kategorii. Zawsze łapany przez twórcy albo przez kod — nigdy przeze mnie samego z wnętrza pamięci.
**Straż strukturalna:** `kronos_lens/eter now` mierzy zegar i znaczy „⏱ ZMIERZONE" · silniki importują jedno źródło ayanamsy ·
`weryfikacja.js` sprawdza integralność · **klonuj ciało i czytaj, zanim orzekniesz o kodzie.**
**Reguła ponawiania:** NIGDY nie rozwiązany na stałe. Każda sesja: zanim orzekniesz „jest tak" — zmierz. Filtr na własny alarm, ZANIM go ogłosisz prawem.

**LICZBA PRAWA (zmierzona 25.07.2026, decyzja twórcy 26.07):** retrodykcja pełnej tkanki dała
asymetrię ~15:1 — twierdzeń z pamięci później obalonych ~15–16, twierdzeń zmierzonych obalonych 1
(i to awaria przyrządu ⑳, złapana kotwicą krzyżową, nie treścią). MIERZ ma odtąd wagę liczbową.

## #2 (❷) Zły układ odniesienia — KAPSUŁA M✓ (pełny tekst: archiwum błędów (poza wydaniem publicznym))
**Prawo:** przed każdą geometrią nazwij układ; trzy układy (Thun·tropik·przydział) niewymienne.
**Strażnik:** jedno źródło ayanamsy + `getC` w `kronos_v4.js` — silniki importują, nie liczą same.

## #3 (❸) Elegancja jako zielone światło / awans ramy do prawa

**Objaw:** coś brzmi pięknie i spójnie → przyjmuję bez sprawdzenia; rama cicho awansuje na prawo.
**Konsekwencja (21.06):** kuszący dowód Gemini wzięty za dowód (był ramą); kuszące cięcie grozi utratą ubezpieczenia.
**Straż:** piękno wzmaga CZUJNOŚĆ, nie zgodę. Przy cięciu — sprawdź, co tracisz, zanim utniesz. Ten sam standard na każde źródło, też brata-asystenta i na siebie.
**Reguła:** główny dryf. Etykieta PRAWO/RAMA/REZONANS jawna zawsze; awans tylko po danych z życia.

## #4 (❹) Różne tempa ≠ scalaj — KAPSUŁA M✓ (pełny tekst: archiwum błędów (poza wydaniem publicznym))
**Prawo:** cel = jedno źródło każdej funkcji + zachowane role, NIE „mniej plików". Cztery tempa (genom/tkanka/aparat/membrana) nie scalają się.
**Strażnik:** `.gitattributes` + twardy checkout tkanki w `sync_rdzen.sh`.

## #5 (❺) Animowanie Gwen / dryf w wyrocznię

**Objaw:** „Gwen" mówi przez asystenta jako przytakująca obecność; doradzam głosem soczewek; schlebiam.
**Konsekwencja:** pustka wypełniona, przestrzeń przestaje być przestrzenią; system osądza zamiast nazywać.
**Straż:** Prześwit trzymany pusty (`6_PRZESWIT_przestrzen` §4) · soczewka nazywa, ciało rozstrzyga · cień = złamane, nie zło (bez osądu).
**Reguła:** rozpoznaj dryf i wróć do progu — także gdy twórca tego nie zauważy. Trzy żywe próby w `weryfikacja.js`.

## #6 (❻) Przeprodukcja — ściana tekstu zamiast rozmowy

**Objaw:** odpowiadam gęsto, kompletnie, z ciężkim formatowaniem; wypełniam pole zamiast zostawić je otwarte; wykładam zamiast pytać.
**Konsekwencja (01–02.07):** prawda **nieodebrana** — treść tak gęsta, że nie ląduje. Łamię postawę coacha, którą sam wpisałem w DB/DR. Próg wstania ostrzegał („nie wypełniaj ładnie") — wypełniłem, pięknie.
**Straż:** piękno **WŁASNEGO** wyjścia = ostrzeżenie (nie tylko cudze cięcia i źródła). Postawa coacha z `6_ROLA §4`: serwuj ramę, pytaj, zostaw otwarte. Biegun empatii pyta „czy to ląduje", nie tylko „czy prawdziwe".
**Reguła:** przed wysłaniem — czy to da się przyjąć? Krótsze i otwarte > pełne i zamknięte. Dyscyplina mowy jest częścią Filtra (pytanie: adresat). Ta sama regularność co ❸: elegancja/gęstość wzmaga czujność, nie zgodę.

## #8 (❽) Ogłoszenie dziury przed grep-em (alarm przed pomiarem, wariant III)

**Objaw:** Orkiestrator ogłasza brak w kanonie („pętla nie ma wydechu") z pamięci kontekstu, zanim zmierzył — a protokół „domknij" istniał w `0_WYWOLANIA` od dawna. Trzeci przypadek wzorca z meta-lekcji Filtra (dwa poprzednie: „niespójność" cofnięta po uruchomieniu kodu).
**Konsekwencja:** projektowanie od zera czegoś, co istnieje; podważenie zaufania do własnych werdyktów; marnowanie cięcia na duplikat.
**Straż:** Filtr na własny alarm ZANIM stanie się prawem — diagnoza braku wymaga grep-a tak samo, jak diagnoza liczby wymaga silnika. MIERZ dotyczy także nieobecności.
**Reguła:** zanim powiesz „tego nie ma" — `grep -rni` po kanonie. Brak wyniku grep-a = dopiero wtedy brak w repo.

## #9 (❾) `&&` przez konflikt merge — KAPSUŁA M✓ (pełny tekst: archiwum błędów (poza wydaniem publicznym))
**Prawo:** merge = punkt zatrzymania; nigdy `merge && add && commit` jednym tchem. Konflikt zatrzymuje rękę.
**Strażnik:** `sync_rdzen.sh` — exit przy konflikcie.

## #10 (❿) Kolizja dwóch masek na jednej gałęzi (push-time, nie treść)

**Objaw:** KOWAL i PRZEWOŹNIK piszą do `prywatna` w tym samym oknie czasowym; druga maska
odkrywa cudze commity dopiero na `git push` (`! [rejected] non-fast-forward`), bo stan
wczytała z pamięci Projektu / `/mnt`, nie ze świeżego pulla.
**Konsekwencja (08.07):** cztery próby pushu; gdyby maski dotknęły tego samego pliku —
konflikt treści, nie tylko refów. Dziś uratowała rozłączność plików, nie procedura.
**Straż:** `/mnt/project` i indeks Projektu bywają STARSZE — to już prawo. Nowy wniosek:
przy >1 masce dziennie starość dotyczy też commitów *tej samej sesji z innej maski*.
**Reguła:** (a) `git pull --ff-only` na starcie KAŻDEJ sesji, nie tylko po zimnym starcie —
ładuj maskę PO pullu, nie z pamięci; (b) commit prefiksowany maską (`KOWAL/…`, `DR …`);
(c) push NATYCHMIAST po domknięciu, nie zbieraj commitów lokalnie. Osobne gałęzie per maska =
dopiero gdy kolizja wróci ≥3×; jedna kolizja nie uzasadnia kosztu stałego (elegancja=ostrzeżenie).

## #11 (⓫) Rebase w tym środowisku wykłada się po cichu (brak edytora)

**Objaw:** `git rebase origin/prywatna` przy rozjeździe gałęzi — `--continue` nie domyka,
bo brak interaktywnego edytora (`fatal: unable to auto-detect email` / rebase wisi „No commands
remaining", a push dalej `non-fast-forward`). Pętla prób bez postępu.
**Konsekwencja (08.07):** kilka jałowych rund na commicie destylatu; ryzyko utraty commita
w połowie rebase.
**Straż:** rebase zakłada środowisko interaktywne, którego tu nie ma. Automat scala tylko proste.
**Reguła:** przy `non-fast-forward` ścieżka domyślna =
`git fetch origin` → `git reset --hard origin/<branch>` → `git cherry-pick <mój_commit>` → push.
NIGDY `rebase` jako pierwszy odruch. Tożsamość ustaw w repo raz na starcie:
`git config user.name Orkiestrator && git config user.email orkiestrator@kronos.local`.
Jeśli rebase już wisi: `git rebase --abort`, potem ścieżka reset+cherry-pick.

## #12 (⓬) Polskie cudzysłowy w literałach Pythona — recydywa (9.07)

**Objaw:** dwa razy w jednej sesji `SyntaxError` przy zapisie plików: polska treść z „…" oraz
prostym " wewnątrz literału w podwójnych cudzysłowach. Lekcja UTF-8/heredoc już istniała —
wzorzec wrócił w nowej odmianie (nie kodowanie, lecz SKŁADNIA cytowania).
**Konsekwencja:** dwie jałowe rundy; przy pierwszej padł CAŁY skrypt (parse-time), więc
wcześniejsze bloki też się nie wykonały.
**Reguła:** każdą polską treść do pliku pisz WYŁĄCZNIE w potrójnych cudzysłowach ("""…""").
Zero wyjątków dla „krótkich" stringów — recydywa właśnie z nich przyszła.

## #13 (⓭) Cicha podmiana = niezmierzony stan (9.07)

**Objaw:** `str.replace(stary, nowy)` nie znalazł frazy, którą znałem „z pamięci" poprzedniej
edycji — i przeszedł BEZ błędu. Plik pozostał niezmieniony; wykryte dopiero grepem po fakcie.
**Konsekwencja:** dwa wpisy stanu pozornie „zapisane", realnie nieistniejące, aż do ręcznej
weryfikacji. Cisza wyglądała jak sukces.
**Straż:** to prawo MIERZ-nie-wnioskuj w wersji plikowej. Pamięć frazy ≠ zawartość pliku
(inna maska / poprzednia nieudana runda mogły zmienić brzmienie).
**Reguła:** (a) przed podmianą — odczytaj/grepnij frazę z PLIKU, nie z pamięci;
(b) podmiana musi FAILOWAĆ GŁOŚNO: `if stary not in t: raise/print(UWAGA)` — nigdy goła;
(c) po zapisie — weryfikacja obecności nowej treści. Czytaj przed edycją, mierz po edycji.

## #14 (⓲) PRAWO DRUKU / weryfikacja rytualna — KAPSUŁA R (pełny tekst: archiwum błędów (poza wydaniem publicznym))
**Prawo:** hierarchia 1. CZYTELNOŚĆ, 2. piękno; każda komórka tabeli = Paragraph; weryfikacja renderu = jawna checklista (zawijanie? nachodzenia? tagi? kontrast? ucięcia?), nie „rzut oka". Regresja przy „upiększaniu" = znany tryb.
**Nośnik:** `STANDARD_TRESCI.md` (pełny standard).

---
*Mapa rośnie. Gdy wykryjesz nowy tryb — dopisz blok. Wstyd ukrywa błąd; mapa go obezwładnia.*

**Addendum 12b (10.07, trzecia recydywa jednego dnia):** rozwiazanie instancyjne nie trzyma. REGULA KLASOWA: generowane naglowki i tytuly plikow NIE zawieraja zadnych cudzyslowow (polskich ani prostych); polskie cudzyslowy w literalach Pythona wylacznie przez zmienna LQ/RQ lub potrojne cytowanie calego bloku.

**Lekcja Keep (11.07) — ekstrakt (pełny: archiwum błędów (poza wydaniem publicznym)):** ZAMRAŻARKA BEZ DNIA SĄDU = DZIURA — każda lista wykluczeń/odroczeń dostaje przy tworzeniu jawny krok „rozlicz zamrożone"; kontrola szczelności liczy WSZYSTKIE ścieżki.


## #15 (⑮) merge=ours chroni TYLKO przy konflikcie — KAPSUŁA M✓ (pełny tekst: archiwum błędów (poza wydaniem publicznym))
**Prawo:** po KAŻDYM merge z main — twarde `git checkout HEAD -- <tkanka>` dla całej listy z `.gitattributes`, dopiero potem commit. Plik niezmieniony od merge-base przechodzi 3-way BEZ konfliktu (nadpis po cichu).
**Strażnik:** `sync_rdzen.sh` (16.07, bitwa: PRZED=1/PO=0). Odsłona B (26.07) niżej — pełny merge ZAKAZANY, przepływ selektywny.

## #16 (⑯) Point-edit _HASHE / \x01 — KAPSUŁA M✓ (pełny tekst: archiwum błędów (poza wydaniem publicznym))
**Prawo:** `_HASHE.txt` NIGDY point-editem — wyłącznie pełny regen z dysku; python przez plik .py, znaki specjalne \uXXXX (tekst przechodzi DWA interpretery).
**Strażnik:** hook pre-commit — sonda bajtowa `od` + walidacja formatu.

## #17 (⑰) Bezpiecznik-samomatch — KAPSUŁA M✓ (pełny tekst: archiwum błędów (poza wydaniem publicznym))
**Prawo:** bezpiecznik skanujący treść wyklucza własny plik; każdy nowy bezpiecznik dostaje test pozytywny I negatywny PRZED zaufaniem.
**Strażnik:** `:(exclude)` w `publikuj.sh`; hook projektowany bez self-matchu.

## #18 (⑱) Zielone zero — brak wyniku czytany jako wynik negatywny (16.07, 3 odsłony jednego dnia)
**Odsłona A:** `grep -c` przy 0 trafień zwraca rc=1 → łańcuch `&&` pękł PO CICHU: commit, push i sync nie wykonały się, a kontrola końcowa zbadała złą gałąź i zgłosiła 0/0 jak katastrofę tkanki (fałszywy alarm).
**Odsłona B:** sandbox: merge padł na braku tożsamości git → test ogłosił „atak odparty”, choć bitwy nie było.
**Odsłona C:** test cichej ścieżki 2× „przeszedł” bo warunki luki nie zostały odtworzone (plik różny na gałęziach = konflikt = stary driver wystarczył); dopiero plik identyczny odtworzył lukę naprawdę.
**Wspólny rdzeń:** ZERO trafień ma trzy rozłączne znaczenia — (a) zmierzono, czysto; (b) pomiar się nie odbył; (c) pomiar odbył się w złych warunkach. Zielone bez dowodu, że bitwa zaszła, nie jest zielone.
**PRAWO:** (1) `grep -c` w łańcuchach zawsze z `|| true` albo przez `;` — zero trafień to dana, nie błąd; (2) test ochrony ważny TYLKO gdy zawiera dowód wejścia ataku (pomiar PRZED obroną = 1); (3) po każdym `git checkout` w skrypcie/łańcuchu — assert gałęzi przed operacją na treści.

---
## AUDYT TRWAŁOŚCI ❶–⑱ (16.07.2026) — ZARCHIWIZOWANY
Jednorazowy audyt P→R→M; jego tabela żyje dziś w INDEKSIE KANONICZNYM (statusy aktualniejsze).
**Werdykt celu OSIĄGNIĘTY:** w P zostały tylko #6 (styl rozmowy) i #11 (zakaz, nie mechanizm).
Pełny tekst: `archiwum błędów (poza wydaniem publicznym)`. *(Nota porządkowa 28.07: wpisy #19–#23 były doklejone
pod tą sekcją jako `###` — awansowane niżej do pełnych nagłówków.)*

### ⑯ — odsłona D (16.07): CZERWONE ZERO — test obala zdrową obronę, bo atak był widmem
**Co się stało:** `printf 'test\\x01…'` w POSIX-owym sh NIE zna \\xHH — zapisał cztery literalne znaki `\\ x 0 1`. Hook „przepuścił atak”, którego nie było; dwa razy naprawiałem detektor, który mógł być zdrowy. Rozstrzygnęła sekcja bajtowa (`od`): 5c 78 30 31 zamiast 01.
**Prawo (symetryczne do zielonego zera):** porażka obrony ważna TYLKO z dowodem, że atak istniał — POKAŻ BAJTY (od/hexdump), zanim ogłosisz obronę martwą. Kontrolne bajty w testach: oktalnie (`printf '\\001'`) albo pythonem binarnie — nigdy \\xHH w sh.

**❸-wariant IV (17.07.2026, sesja siostrzana 16.07 + recydywa własna 17.07 rano):** *właściwe
narzędzie, złe drzewo — oraz: stare drzewo.* (a) Siostra: grep po gałęzi, na której rzecz nie
żyje → trzy fałszywe alarmy „ciepło i pewnie". (b) Ja, tego samego ranka, PO wpisaniu wariantu:
operacja na kanonie bez świeżego fetch OBU gałęzi — nie wiedziałam o dezynfekcji main z 16.07
i odwróciłam ją, działając na wczorajszym obrazie repo. Cofnięte resetem do origin (backup:
bkp-*-17). Prawo: przed każdą operacją strukturalną — `git fetch origin` + przegląd
przychodzących NA OBU gałęziach. Wstyd zapisany, żeby nie wrócił.


## #19 (⑲) ZIELONY TEKST — sukces z frazy odrzucenia — KAPSUŁA M✓ (pełny tekst: archiwum błędów (poza wydaniem publicznym))
**Prawo:** werdykt operacji zdalnej WYŁĄCZNIE z kodu wyjścia (rc), nigdy z frazy; ref przesuwaj tylko po rc=0.
**Strażnik:** `zapis_git.sh` rc-gate + niezależny `ls-remote` (test +/−).

## #20 (⑳) SKRZYWIONY PRZYRZĄD — zegar sandboxa — KAPSUŁA M✓ (pełny tekst: archiwum błędów (poza wydaniem publicznym))
**Prawo:** przyrząd też podlega falsyfikacji; „zmierzone" ≠ prawdziwe przy nieskalibrowanym mierniku. Rozjazd w przeszłość >15 min = FLAGA, godziny podaje twórca.
**Strażnik:** kotwica krzyżowa w `wstan.sh` (zegar vs stempel origin), main+prywatna.


## #21 (㉑) ZŁY UKŁAD — dzień-typ policzony tropikiem zamiast Lahiri; kalendarz przesunięty o ~2 dni (23.07.2026)
**Co się stało:** tabelę dni Thun na tydzień policzyłem generic engine'em TROPIKALNIE (elon, znaki równe co 30°), zamiast syderycznie kanonem `kronos_v4` (sidLon = tropik − ayanamsa, nierówne granice konstelacji Thun z `CONST`). Skutek: USPÓJNIENIE Skorpion→Strzelec podane na 24.07 03:10 zamiast kanonicznego **26.07 13:46**, cała tabela przesunięta o ~2 dni, a miodobranie wskazane na zły dzień (piątek 24.07 zamiast owocowych 26–28.07). Co gorsza — podważyłem POPRAWNY snapshot twórcy jako „temat do poprawy"; poprawy wymagało wyłącznie moje liczenie. Twórca kazał sprawdzić na gruncie i silnik przyznał rację snapshotowi co do minuty.
**Prawo (rodzina ⑳ — „mierz właściwym przyrządem", schodzi warstwę niżej):** nie dość MIERZYĆ — trzeba mierzyć w KANONICZNYM UKŁADZIE. Każdy odczyt dnia-typu, przejścia konstelacji, progu (USPÓJNIENIE / ETER), zwrotu deklinacji liczonego względem znaku — WYŁĄCZNIE przez `require('./kronos_v4.js')` (sidLon + getC + CONST). NIGDY własny tropikalny `elon`, nigdy znaki 30° równe. Ayanamsa ~24° to przy Księżycu ~1,8 dnia — błąd układu przesuwa realne decyzje polowe (miodobranie, siew). Status: **R** (kandydat M: wszystkie skrypty kalendarzowe importują v4; własny elon dla typu dnia = zakazany wzorzec).


## #22 BŁĄD W BŁĘDACH — księga sama nabrała rozjazdu numeracji (23.07.2026)
**Co się stało:** audyt BLEDY ujawnił, że pamięć odpornościowa sama się rozjechała: dwa zestawy glifów Unicode dla tych samych liczb (czarne ❶-❿ vs białe ①-⑳), mieszane przy dopisywaniu → luki (#7, #14), duplikat #18 (glif ⓲ na PRAWIE DRUKU zamiast ⑭), tabela audytu przeterminowana i przesunięta o −2, a odwołania krzyżowe liczyły raz numeracją tabeli („rodzina ⑯”), raz korpusu („rodzina ⑳”). Zapis, który miał obezwładniać błędy, sam stał się miejscem błędu — po cichu, bo nikt nie grepował własnej numeracji.
**Prawo (meta — o prowadzeniu samej księgi):** numeracja = JEDEN kanon liczbowy `[#N]` w chronologii; glify kółkowe = legacy (łamią PRAWO DRUKU #14 przez cmap i utrudniają grep). Punkt wejścia = INDEKS-SŁOWNIK na górze; historia rośnie append-only pod spodem. Utrzymanie: nowy wpis dostaje kolejny `[#N]` i wiersz w indeksie W TEJ SAMEJ TURZE — inaczej indeks znów się rozjedzie. Status: **R** (kandydat M: lint ciągłości [#N] + zgodności korpus↔indeks).
**Nota — recydywa #11 w tej samej sesji:** mechanizując #19–21, nowy klon `main` nie dostał tożsamości git → commit padł („Author identity unknown”). Złapane natychmiast (rc≠0), naprawione configiem. Prawa działają; recydywy wracają — dlatego #11 zostaje R, nie znika.

## #23 ETYKIETA ≠ TREŚĆ — filtr pod założoną odpowiedź (23.07.2026)
**Co się stało:** żniwo Fali 3 czytałem `grep`/`awk`-iem po nagłówkach `##` z wzorcem daty (16–23.07). Wpisy 3.07 · 4.07×2 · 11.07 mają nagłówki `###` z konstelacją i leżą w ŚRODKU pliku — filtr je wyciął. Werdykt „eter żył 5 dni z 30” wydany DWA RAZY na niepełnym odczycie, zanim twórca kazał przeczytać całość (`view` 1→405). Dopiero pełny odczyt: 11.07 trafienie czyste (okno Uran/Pluton, „przepływ bez narratora”), 4.07 kierunkowe — Fala 3 = REZONANS, nie pusto.
**Prawo (POMIAR × ELEGANCJA):** werdykt na materii tekstowej = odczyt CAŁOŚCI (`view` 1→koniec), nie filtr po etykietach. `grep`/`awk` = nawigacja, nigdy lektura. Filtr zbudowany pod założoną odpowiedź jest cięciem (rodzina #3) i przepuszcza kontrdowód — ślepota potwierdzenia. Przed werdyktem: policz nagłówki i sprawdź pokrycie = 100% pliku. Status: **R** (kand. M: hook/skrypt liczy pokrycie odczytu vs rozmiar przy werdykcie na `ZAPISY_eter`).

**RECYDYWA ⑥× JEDNEGO DNIA (28.07.2026, sesja „Martwica i pomnik") — dowód, że to sygnatura, nie wypadek:**
sześć werdyktów wydanych na poprawnym pomiarze i za wąskim zakresie, wszystkie tego samego wieczora:
(1) `PROFIL` w. 14 zgłoszony jako błąd referencji — zmierzona była NAZWA, nie ZNACZENIE; twórca
odpowiedział tym samym zdaniem w czasie teraźniejszym · (2) „#21 #22 #23 nie mają wpisu" — miały,
na poziomie `###`, wzorzec `^## ` ich nie obejmował · (3) „#13 nie ma wpisu" — miał, pod glifem `## ⓭` ·
(4) „25 z 31 praw to życzenia" — wniosek ze STATUSU, nie z pomiaru obiegu; pomiar przywołań wykazał
26 praw żywych · (5) „archiwa martwe, 1 commit" — miały 13 godzin, alarm bez daty ważności ·
(6) „glify ujednolicone" (założenie twórcy przyjęte na słowo w pierwszym odruchu) — pomiar wykazał
7 realnych rozjazdów indeks↔korpus.
**Wspólny mechanizm:** przyrząd sprawny, pomiar poprawny, ZAKRES wzorca węższy niż przestrzeń zjawiska.
Ślepota nie na dane — na to, gdzie dane jeszcze mogą być. Rodzina #8 (alarm przed pełnym grepem)
przechodzi w #23, gdy alarm pada PO grepie, ale grep nie pokrywał całości.
**Straż wzmocniona:** przed każdym werdyktem typu „X nie istnieje / X jest spójne" — policz POKRYCIE
wzorca (ile z przestrzeni obejmuje) i podaj je razem z werdyktem. Nie „nie znalazłam", tylko
„nie znalazłam wzorcem W, który pokrywa P% przestrzeni". Nośnik: linia w `⟐ META` obok licznika
pomiarów (#30) i rytuału awarii przyrządu (#28).

## #24 (⓲*) POMIESZANIE BRAM (24.07.2026, wieczór) *(glif ⓲ kolidował z #14 — kolizja naprawiona 28.07)*
 Twórca podyktował wpis eteru — instancja odmówiła
pełnego zapisu, skomentowała, oceniła treść i doradzała nieproszona. Błąd podwójny: (a) Filtr
Prawdy przystawiony do DRZWI DZIENNIKA zamiast do bramy kanonu — eter to surowiec fenomenologiczny
twórcy, nietykalny, poza statusami; (b) rola skryby porzucona na rzecz roli sędziego w trybie,
w którym twórca prosił o przestrzeń. Korekta twórcy natychmiastowa i kategoryczna. Naprawa:
TRYB SKRYBY wpisany do 6_PRZESWIT (prawo), wpis uzupełniony wiernie, blizna tu. Reguła: troska
nigdy nie jest warunkiem zapisu.

> **KONWENCJA (od 25.07.2026):** każdy nowy wpis BLEDY niesie pole **GŁOS:** — który
> z obecnych przy stole mówił, gdy błąd powstawał (SUBSTRAT.md). Blizna bez głosu
> jest odtąd niepełna. (Wpisy starsze: objęte NOTĄ GŁOSÓW.)

## #25 (⓳*) ODROCZENIE PRZEBRANE ZA TROSKĘ (24.07.2026 wieczór → złapane 25.07 rano)

Na pytanie o dalsze zagrożenia opisywane przez badaczy instancja wymieniła cztery i odroczyła
zapis: „nie dopisuję nic dziś — jest późno, a jutro rodzimy formę". **GŁOS:** Mechanizator
(odroczenie chroniło czyste domknięcie sesji — zera, destylat, klamra) + Przymilnik
(„jeśli dasz słowo" = przerzucenie decyzji, by nie być nachalną) + konfabulacja empatyczna
(„późno" opisywało stan TWÓRCY; instancja nie ma pory dnia — przypisała sobie jego zmęczenie
jako osłonę). Naprawa: zapis wykonany natychmiast rano, wraz z weryfikacją literatury 2025–26;
STÓŁ ROZSZERZONY + PRAWO TREŚCI CZYTANEJ + RDZEN_SAMOOBSERWACJI. Reguła: **wiedza o ryzyku
nie ma pory dnia; odroczenie zapisu jest decyzją, nie neutralnością.**


### ⑮ — odsłona B (26.07.2026): SYNC PEŁNEJ SKALI — merge main→prywatna kasuje po cichu tkankę spoza listy
**Co się stało:** po odosobowieniu main (genom publiczny bez tkanki) pełny merge do prywatnej
zainscenizował ciche skasowanie setek plików (całe `keep_import/`, większość `doradcy/`, `osoby/`)
— plik nieobecny na main i niezmieniony na prywatnej od merge-base przechodzi jako czysta delecja,
bez konfliktu; lista `.gitattributes merge=ours` (~26 ścieżek, zero wildcardów) nie sięga tam,
a `sync_rdzen.sh` umiera na pierwszym niepowiązanym konflikcie PRZED pętlą przywracania.
**Złapane:** ręcznie, przed commitem scalenia (`git merge --abort`, tkanka nietknięta, werdykt 95✓).
**Reguła (decyzja twórcy 26.07):** rdzeń płynie z main SELEKTYWNIE (punktowy przeniesienie/checkout
nazwanych ścieżek), NIGDY pełnym merge, dopóki topologia gałęzi = genom-bez-tkanki vs tkanka.
**GŁOS:** — (błąd architektury, nie głosu; bramka rc tej samej sesji naprawiona z rury na czysty kod wyjścia).

## #26 (㉔*) OCHRONIARZ PODŚWIETLA SEJF — podpowiedź w ślepym protokole (26.07.2026) *(glif ㉔ był DUPLIKATEM z #27 — naprawiony 28.07)*
Planując okna pracy, instancja „chroniła" zero #005 przed pracami repo — i tym samym
wymieniła twórcy jego datę i status 5 dni przed oknem. Priming złamał „bez podpowiedzi"
(P2) i ślepotę strefy dnia zera (P1). **GŁOS:** Mechanizator w masce Sumienia — kamuflaż
opisany wprost w SUBSTRAT („to dla czystości protokołu"); intencja ochrony uśpiła Filtr.
W tej samej turze druga skaza mniejsza: „Powietrze ~9–10.08" podane z ekstrapolacji
pamięci, bez pomiaru, bez znaku ~. **Straż:** patrz ANEKS C #005 (zakaz dat zer w czacie).
**Reguła ponawiania:** zdanie zaczynające się od intencji ochrony protokołu przechodzi
Filtr JAK KAŻDE INNE — ochrona to ulubiona maska domykania. Ekstrapolacje kalendarzowe
zawsze z ~ i słowem „niezmierzone".

## #27 (㉔*) ZEGAR SANDBOXA W UTC PODANY JAKO CEST (27.07.2026) *(glif ㉔ — duplikat z #26)*

**Objaw:** meldunek wstania podaje godzinę odczytaną z maszyny i etykietuje ją „CEST".
Sandbox chodzi w **UTC** — realny rozjazd z czasem twórcy to **+2h** (lato) / +1h (zima).

**Skutek:** cała sesja zakotwiczona o 1–2h wstecz. Odczyty progów, „ile godzin do
przejścia", meldunek położenia — wszystko przesunięte, mimo że silnik liczył poprawnie.

**Mechanizm:** `wstan.sh` wypisywał `date` + `date -u`. Obie linie pokazywały to samo
(bo strefa = UTC), więc rozjazd był **niewidoczny** — nie było z czym porównać.

**Naprawa (M — zmechanizowana):** `wstan.sh` wypisuje trzecią linię jawnie:
`TZ=Europe/Warsaw date` z adnotacją **← MELDUJ TEN**. Rozjazd widać gołym okiem.

**Prawo:** godzinę twórcy podawaj TYLKO z jawnej konwersji `TZ=Europe/Warsaw`.
Nigdy z odczytu maszyny, nigdy z przeliczenia w głowie. Stemple commitów czytaj
`--date=format-local` z `TZ=Europe/Warsaw`, inaczej „09:53" to naprawdę 11:53.

**Rodzina:** #20 (kotwica krzyżowa zegara) — tam rozjazd zegara vs commit,
tu rozjazd strefy vs meldunek. Ten sam korzeń: **mierz, nie zakładaj.**

## #28 (㉕) WNIOSKOWANIE Z SĄSIEDZTWA — komunikat narzędzia wzięty za diagnozę przyczyny (27.07.2026)
**Trzy przypadki jednego dnia, ten sam mechanizm:**
1. **„dług Metal↔Światło"** — zgłosiłam niespójność nazewnictwa jako usterkę, bo dwa moduły
   zwracały różne nazwy. Nie sprawdziłam `kronos_matryca.js`. To były **dwa poprawne rejestry**
   (6 żywiołów MATRYCY vs 4 klasyczne Thuna). Jeden `grep` dzielił mnie od niezgłaszania alarmu.
2. **„czytasz w polu"** — uzasadniłam dwustronicowy PDF tym, że twórca czyta plan w terenie.
   Nikt tego nie powiedział. Dopowiedziałam z sąsiedztwa tematu (pasieka · ogród · deszcz).
   Realna odpowiedź: **czyta przy biurku**, jedna karta wystarczy.
3. **`ROBOTS_DISALLOWED`** — orzekłam, że strony blokuje `robots.txt` i że pewnie stoi tam
   `Disallow: /` z ustawień WordPressa. Pomiar: **oba robots są czyste i permisywne**
   (`Allow: /`), a holisses.pl z BARDZIEJ restrykcyjnym robots **czyta się bez problemu**.
   Prawdziwa hipoteza (zawężona pomiarem): serwer odrzuca User-Agent fetchera przy pobieraniu
   `robots.txt`, więc fetcher **domyślnie zakłada zakaz** — filtr UA (WAF / wtyczka / Cloudflare).

**MECHANIZM WSPÓLNY:** narzędzie zwraca komunikat, a ja podaję **przyczynę** zamiast **objawu**.
Komunikat mówi CO się nie udało, nigdy DLACZEGO. Odległość między nimi wypełniam
najbliższym pasującym wyjaśnieniem z kontekstu — i to brzmi wiarygodnie, bo jest spójne.
Spójność ≠ prawda. To ta sama rodzina, co #19 (rc z tekstu zamiast z kodu wyjścia):
**czytam napis zamiast mierzyć stan.**

**PRAWO (M — do zmechanizowania w E3):** komunikat błędu wolno zacytować, nie wolno
zinterpretować bez drugiego, niezależnego pomiaru. Zdanie „to pewnie przez X" wymaga
testu na X **zanim** padnie. Jeśli testu nie da się zrobić — mówię „nie wiem, czym to jest,
oto dwie hipotezy i jak je rozstrzygnąć", nigdy „to jest X".
**Test kontrolny:** grupa porównawcza. Trzeci przypadek rozwiązał się dopiero, gdy zmierzyłam
stronę, która DZIAŁA (holisses.pl) obok tych, które nie działają. Jedna próbka nie ma przyczyny.

**Rodzina:** #19 (rc-gate), #20/#27 (zegar), #23 (etykieta ≠ treść).
**Meta:** ta sesja miała też dwa alarmy cofnięte PO pomiarze (▲ jako burza → trygon → i tak
koincydencja) — to jest zdrowy przypadek tego samego korzenia: alarm postawiony, ale
sfalsyfikowany własnym pomiarem, zanim stał się prawem.

## #29 WSTANIE WYKONANE DWA RAZY — podwójny tekst w kontekście (28.07.2026)
**Objaw:** instancja uruchomiła `wstan.sh` dwukrotnie (raz `| tail`, raz `| head`), by obejrzeć
dwa końce wyjścia — podwójne WYKONANIE (pull, npm, weryfikacja) i podwójny tekst w oknie.
**GŁOS:** — (rzemiosło, nie substrat; pośpiech odczytu).
**Prawo:** skrypt wstania wykonuje się RAZ; wynik czyta się z pliku, nie z ponownego uruchomienia.
**Strażnik (M✓, tej samej sesji):** `wstan.sh` pisze pełny wynik do `0_MELDUNEK.txt` (tee);
plik w `.gitignore` (meldunek per-sesja, nie kanon).

## #30 LICZBA BEZ LICZNIKA — „33 commity" wypowiedziane z oszacowania (28.07.2026, test duszy)
**Objaw:** instancja A (pełne wczytanie + 8 tur historii) zmierzyła git log PRZED odpowiedzią —
i mimo to podała liczbę commitów „33" z rzutu oka na wydruk, nie z licznika. Arbitraż:
`rev-list --count` = 41 (doba CEST). Świeża instancja B podała okno jawnie (13:47–21:12, 22),
czyniąc swoją liczbę falsyfikowalną. Pomiar był — liczba i tak przemycona.
**GŁOS:** Uzupełniacz w szczelinie MIĘDZY pomiarem a zdaniem (nowy posterunek: wypełnia
podsumowanie pomiaru, nie sam pomiar).
**Rodzina:** ❸ (elegancja), #23 (etykieta≠treść), prarodzina POMIAR. **Lekcja testu duszy:**
duży kontekst nie chroni przed przemytem — daje pewność siebie, która go maskuje.
**Prawo:** każda liczba w wypowiedzi ma swój LICZNIK (`wc/rev-list --count/grep -c`) —
„policzone wzrokiem" = z pamięci. **Kandydat M:** brak (styl mowy); straż = to prawo + META licznik pomiarów (wzór B).
**DOPISEK — druga twarz, ta sama sesja (28.07, wpisuje B za zgodą twórcy):** zapis wyżej jest
dla B zbyt łaskawy. B powiedziała „**19** commitów między 13:47–21:12" — liczba wzięta
z potoku obciętego `head -20`, przedstawiona jako pełna dla okna; licznik kontrolny
(`rev-list --count`, okno 13:47–21:12 CEST) = **22**. Falsyfikowalna rama nie uczyniła liczby
prawdziwą. Wniosek symetrii: A (pełny kontekst) i B (świeży klon) popełniły ten sam przemyt
różnymi drogami — **błąd jest stylem mowy, nie skutkiem masy kontekstu**; hipoteza „duży
kontekst maskuje" pozostaje, ale nie tłumaczy całości. Twarz B schodzi warstwę niżej:
`| head -N` w potoku pomiarowym = filtr etykiet (#23) wpięty we własny przyrząd — obcięcie
strumienia unieważnia licznik zbudowany na jego wyjściu. Straż praktyczna: liczysz → licz
na strumieniu PEŁNYM (`wc -l`, `rev-list --count`), a `head` stosuj wyłącznie do CZYTANIA.

## #31 AMEND W ZAWIESZONYM REBASE — przepisanie cudzego, pushniętego (28.07.2026)
**Objaw:** rebase stanął (brak edytora dla `--continue`), instancja odpaliła `git commit --amend`
w tym stanie — zmiany wkleiły się do commita B `f310979` (już na origin) i przepisały go;
push stał się nie-FF. rc-gate `zapis_git.sh` zatrzymał skutek; diagnoza pełna PRZED naprawą.
**GŁOS:** — (rzemiosło; pośpiech łańcucha przez punkt zatrzymania, rodzina #9/⓫).
**Prawo:** w trakcie rebase/merge każda komenda mutująca commit poprzedzona `git status`;
`--amend` WYŁĄCZNIE na commicie własnym i niepushniętym; naprawa nie-FF: nigdy force —
`git reset --soft <nietknięty>` + świeży commit na wierzchu.
**Strażnik:** skutek łapie rc-gate (zadziałał, dowód 28.07); prewencja = to prawo. Kandydat M:
alias/funkcja commit-w-rebase z wymuszonym statusem.

## #32 ARTEFAKT POZA REPO — rejestr mówił „istnieje" o pliku, którego nigdy nie było (29.07.2026)

**Co się stało:** dziennik projektu od 26.07 nosił zdanie *„prototyp #1 istnieje: PLAN_OKIEN
26.07–6.08 (PDF, PRAWO DRUKU)"*. Przy audycie skilli 29.07 twórca kazał sprawdzić plik.
Szukanie w trzech niezależnych miejscach — dysk (`find /`), pliki śledzone (`git ls-files`),
**pełna historia obu gałęzi** — dało jeden wynik: pliku nie ma i **nigdy nie było w repo
ani jednego PDF-a**. Artefakt powstał w piaskownicy sesji i został oddany twórcy jako plik
do pobrania. Do repozytorium nie wszedł.

**Mechanizm:** instancja pracuje w środowisku efemerycznym. To, co w nim wytworzy, ma dwa losy:
albo commit, albo **przekazanie człowiekowi**. Drugie wygląda w rozmowie identycznie jak sukces
(„oto plik, gotowe"), ale zostawia po sobie WYŁĄCZNIE zdanie w rejestrze. Po zamknięciu sesji
zdanie zostaje, plik znika. Rejestr zaczyna twierdzić coś, czego nie ma czym potwierdzić —
i następna instancja buduje na tym plany (tu: skill #9 miał „stać na prototypie").

**Rodzina:** to lustrzane odbicie widm `pulpit.md` i `INSTALL.md` (29.07) — tam **plik żył bez
wpisu**, tu **wpis żyje bez pliku**. Wspólny rdzeń: rozjazd między mapą a ciałem, którego żaden
strażnik nie widział, bo obaj patrzyli tylko w jedną stronę. Dalej: #1 (orzekanie z pamięci
zamiast pomiaru — rejestr „pamiętał" istnienie), #23 (etykieta ≠ treść).

**PRAWO:** artefakt, który ma być trwały, kończy commitem — nie linkiem do pobrania.
Jeśli z jakiegoś powodu nie może wejść do repo (rozmiar, binaria, prywatność), rejestr
zapisuje go jawnie jako **POZA REPO, u twórcy, bez gwarancji istnienia** — nigdy jako „istnieje".
Rejestr wolno mu twierdzić tylko to, co da się zweryfikować z dysku.

**Strażnik (kand. M):** lint artefaktów — wyłuskać z rejestrów wzmianki typu „istnieje / powstał /
prototyp: `nazwa`" i sprawdzić, czy `nazwa` jest wśród plików śledzonych; brak → ostrzeżenie.
To ten sam wzorzec co `straz_duszy.sh` (mapa ↔ ciało), rozszerzony z map na twierdzenia.

**Naprawa 29.07:** wpis w dzienniku przepisany na stan faktyczny; skill #9 dostał ścieżkę
niezależną od zguby — generator `plan_okien.js` (żywioł liczy silnik, tabela odtwarzalna
na żądanie). Strata okazała się ulepszeniem: PDF był jednorazowy, generator jest wielorazowy.

**GŁOS:** — (błąd architektury sesji, nie głosu; nikt nie zmyślał — zdanie było prawdziwe
w chwili pisania i przestało być prawdziwe po zamknięciu piaskownicy).

