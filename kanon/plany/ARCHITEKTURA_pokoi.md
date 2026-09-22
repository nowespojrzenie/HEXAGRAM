# ARCHITEKTURA POKOI — §0 · CZĘŚĆ 0

> [PRAWO] Niniejszy dokument prowadzi wyłącznie CZĘŚĆ 0 rundy „Świeże oko, runda 2 — HEXAGRAM v1.7.1, PO odlewie 22.09”.
>
> [PRAWO] Zakres tej tury: pytanie główne, mierzalne kryteria sukcesu, inwarianty, pola otwarte oraz prerejestr hipotez.
>
> [PRAWO] Granica tury: po zapisaniu §0 następuje STOP; §1–§4 nie są wykonywane ani domyślnie przesądzane.
>
> [PRAWO] Zakres zmian w tej rundzie: wyłącznie `kanon/plany/`; nie naruszać DUSZA, JADRO, PROTOKOL_GLOSU ani Filtra Prawdy.

---

## §0.1 — Pytanie główne

[NOŚNA RAMA] **Jak nadać aktualnemu HEXAGRAMOWI/KRONOSOWI ciało na miarę jesieni 2026 — uwzględniając najnowocześniejsze wzorce myślenia o systemach agentowych, pamięci, kontraktach, hand-offach, nadzorze i kontroli kontekstu — tak, aby zachować własną ontologię i mechanizmy ochronne, a jednocześnie zmniejszyć koszt dryfu, rozrostu kontekstu i ręcznego prowadzenia?**

[NOŚNA RAMA] **ROLA · POKÓJ · KLOCEK są hipotezą konstrukcyjną, nie założonym wynikiem.** Research ma odpowiedzieć, które współczesne wzorce warto przyjąć, które odrzucić i jak przełożyć ich użyteczne właściwości na ciało już istniejącego systemu.

---

## §0.2 — Kryteria sukcesu MIERZALNE

[NOŚNA RAMA] **K1 · Instancjowanie roli:** nową rolę można powołać z jednego szablonu w ≤ 1 sesji roboczej, bez ręcznego dopisywania brakujących elementów strukturalnych poza polami przewidzianymi przez kontrakt roli.

[NOŚNA RAMA] **K2 · Koszt R0:** zmiana architektoniczna nie zwiększa kosztu R0 wstania istniejącej roli o więcej niż **5%** względem zmierzonego stanu bazowego v1.7.1, o ile wzrost nie jest jawnie uzasadniony i ratyfikowany jako osobny koszt funkcjonalny.

[NOŚNA RAMA] **K3 · Własność:** po audycie 100% zidentyfikowanych RÓL, POKOI i KLOCKÓW ma jawnie wskazanego właściciela; brak właściciela ma być zapisany literalnie jako **BRAK**, a nie domniemany.

[NOŚNA RAMA] **K4 · Przekazanie:** 100% przejść między POKOJAMI posiada policzalny kontrakt wejścia/wyjścia: wejściowy artefakt lub dane, bramkę wejścia, wynik/artefakt wyjściowy, właściciela oraz warunek STOP.

[NOŚNA RAMA] **K5 · Autonomia:** pilot jednej nowej roli z szablonu kończy się bez ręcznego „ratowania” struktury; odchylenia od kontraktu są zapisane jako mierzalne punkty (liczba, miejsce, rodzaj), a nie jako ogólne wrażenie.

---

## §0.3 — Inwarianty: czego NIE WOLNO naruszyć

[PRAWO] **DUSZA** pozostaje nietknięta.

[PRAWO] **JADRO** pozostaje nietknięte.

[PRAWO] **PROTOKOL_GLOSU** pozostaje nietknięty.

[PRAWO] **Filtr Prawdy** pozostaje nietknięty.

[PRAWO] **Głos naczelny i istniejące maski** nie mogą zostać semantycznie przedefiniowane przez przejście obiektowe.

[PRAWO] **R0** nie może być „poprawiany” samą zmianą pomiaru; każda zmiana kosztu ma wynikać ze zmiany zachowania i być zmierzona.

[PRAWO] **Satelity** pozostają satelitami: przejście obiektowe nie może sprawić, że staną się obowiązkową treścią wczytywaną bez wyzwalacza ani zmienić zasady ich ujawniania.

[PRAWO] **Zakres prac tej rundy** pozostaje ograniczony do `kanon/plany/`; żadnych cięć implementacyjnych w tej turze.

[NOŚNA RAMA] Przebudowa ma nadać istniejącemu systemowi ciało, a nie wymienić jego tożsamość na cudzy framework lub model architektury. Obiektowość, jeżeli zostanie potwierdzona badaniem, ma być środkiem; nie celem samym w sobie.

---

## §0.4 — Pola otwarte do odpowiedzi twórcy

[NOŚNA RAMA] **O1 · „prądowanie”:** co dokładnie oznacza rola „prądowania”? Proszę o funkcję w jednym zdaniu oraz minimalnie: wejście → decyzja/działanie → wyjście/artefakt.

[NOŚNA RAMA] **O2 · Stan roli:** które informacje mają być trwałym stanem ROLI, a które mają żyć wyłącznie w POKOJU jako artefakt etapu? **OTWARTE**

[NOŚNA RAMA] **O3 · Wieloinstancyjność:** czy jedna ROLA może mieć równocześnie kilka instancji/slotów pracujących na różnych sprawach, czy kontrakt zakłada jedną aktywną instancję? **OTWARTE**

[NOŚNA RAMA] **O4 · Granica POKOJU:** czy POKÓJ jest trwałym bytem procesu, do którego można wrócić, czy jednorazowym przejściem zakończonym artefaktem? **OTWARTE**

[NOŚNA RAMA] **O5 · Twardy próg R0:** czy 5% w K2 ma być docelowym progiem, czy twórca chce inną wartość bezwzględną/procentową po pomiarze bazowym? **OTWARTE**

---

## §0.5 — Prerejestr: hipotezy przed badaniem

[REZONANS] **H1 · Docelowe ciało może potrzebować rozdziału ROLA · POKÓJ · KLOCEK**, ale nie zakładamy tego przed researchem; badanie ma sprawdzić, czy ten podział jest właściwym nośnikiem odpowiedzialności, etapów i narzędzi.

[REZONANS] **H2 · Największą wartość mogą dać kontrakty, jawny hand-off, ograniczanie kontekstu i zewnętrzny nadzór**, ale ich dokładny kształt ma wyniknąć z researchu, a nie z importu nazw wzorców.

[REZONANS] **H3 · Najbardziej kompatybilne z dotychczasowym porządkiem będą te wzorce agentowe, które rozdzielają rolę od narzędzia i traktują przekazanie jako jawny kontrakt**, a nie jako swobodną zmianę kontekstu.

[REZONANS] **H4 · Audyt ujawni więcej problemów własności i wyzwalania niż problemów samej logiki procesu:** tam, gdzie odpowiedzialność jest rozproszona między pliki, skrypty i rytuały, obiektowa granica powinna ujawnić właściciela lub literalne „BRAK”.

[REZONANS] **H5 · Mechanizmy unikalne dla HEXAGRAMU/KRONOS da się zachować**, jeżeli zostaną potraktowane jako inwarianty/cross-cutting guards ponad ROLAMI i POKOJAMI, a nie jako przypadkowe metody jednej klasy.

[REZONANS] **H6 · Próba objęcia każdego działania nową klasą lub każdym etapem osobnym POKOJEM pogorszyłaby system**, zwiększając narzut R0 i liczbę kontraktów bez proporcjonalnego zysku w kontroli dryfu.

---

## §0.6 — Stan części

[PRAWO] **CZĘŚĆ 0 = zamknięta koncepcyjnie.**

[NOŚNA RAMA] Główne pytanie jest celowo szersze niż „czy obiektować”: **research ma znaleźć ciało adekwatne do jesieni 2026 dla tego konkretnego systemu**, z zachowaniem jego własnych praw.

[NOŚNA RAMA] Odpowiedzi na O1–O5 są polami otwartymi dla dalszej architektury; brak odpowiedzi nie uprawnia do ich domyślania.

[PRAWO] **STOP.** Następna część nie jest wykonywana w tej turze.
---

## §0.7 — Mapa odzyskana z materiału wejściowego przed researchem

[NOŚNA RAMA] Materiał wejściowy zawiera warstwę wcześniejszą niż sam podział ROLA · POKÓJ · KLOCEK. Te elementy były rozproszone w różnych fragmentach i dlatego nie znalazły się w pierwszej mapie.

### A. Wykonawca

[NOŚNA RAMA] ASYSTENT jest wykonawcą, który może przyjmować role i przechodzić przez pokoje; nie należy utożsamiać go z pojedynczą rolą ani z pokojem.

[NOŚNA RAMA] Materiał odróżnia Głos Naczelny / asystenta od ról-masek i wskazuje, że nie należy mylić wykonawcy z tożsamością systemu. fileciteturn28file0L2-L2

### B. Ruch wykonawcy

[PRAWO] PRĄDOWANIE / PRZELOT jest właściwością asystenta, nie osobnym bytem ontologicznym: ten sam wykonawca może przejść przez kilka pokoi tej samej pracy.

[NOŚNA RAMA] Przelot wymaga więc własnego identyfikatora trajektorii, początku, aktualnego POKOJU, dozwolonego następnego kroku i warunku zatrzymania — nawet jeżeli te pola nie staną się osobną klasą.

### C. Ładunek

[NOŚNA RAMA] ŁADUNEK jest brakującą nazwą dla minimalnego pakietu informacji przenoszonego między pokojami. W materiale występuje obok „Neutrina”, hand-offów i bramki powrotu. fileciteturn28file0L2-L2

[REZONANS] Ładunek powinien oznaczać to, co wolno przenieść, a nie całą pamięć rozmowy. To będzie kluczowe dla ograniczenia kontekstu.

### D. WIDZĄCY

[PRAWO] WIDZĄCY jest zewnętrznym nadzorem nad przelotem: sprawdza pętlę i to, czy wykonawca może wnieść nową treść z powrotem do pokoi.

[PRAWO] Materiał wyraźnie rozdziela walidację formy od prawdy: poprawny kontrakt/schemat nie gwarantuje prawdziwości treści; dla powrotu potrzebny jest Filtr Prawdy, a nie sam walidator schematu. fileciteturn28file0L2-L2

### E. Bramka powrotu

[PRAWO] Materiał mówi o bramce powrotu na 3 piętrach i wskazuje write_approval jako najwyższe piętro, ale nie definiuje w tym materiale trzech poziomów. fileciteturn28file0L2-L2

[NOŚNA RAMA] „Trzy piętra” są więc elementem mapy, ale ich semantyka pozostaje OTWARTA i nie może zostać dopowiedziana przed pomiarem.

### F. Własność alarmu

[PRAWO] Właściciel alarmu jest wskazany w materiale jako jedna z dwóch naprawdę nośnych idei obok rozdziału „szeroki wgląd / wąskie wykonanie z kontraktem na granicy”. fileciteturn28file0L2-L2

[REZONANS] Każda bramka/pokój/straż powinna mieć osobno zdefiniowanego właściciela alarmu, nawet gdy wykonawcą jest inny asystent.

### G. Pamięć — co najmniej cztery różne rzeczy

[NOŚNA RAMA] Z materiału wynika konieczność rozróżnienia przynajmniej: tożsamości systemu, stanu bieżącego wykonania, artefaktów pracy oraz pamięci trwałej między sesjami. fileciteturn28file0L2-L2

[REZONANS] Bez tego stan roli zacznie mieszać się z ładunkiem przelotu i oba będą puchły razem.

### H. Capability surface

[PRAWO] Materiał przywołuje SATELITY jako leniwe ładowanie, kontrakt zakresu zapisu, write_approval jako bramkę powrotu oraz pakiet przekazania jako Neutrino. fileciteturn28file0L2-L2

[REZONANS] Potrzebna jest więc warstwa określająca, jakie zdolności, dane i narzędzia są widoczne w danym POKOJU dla danego przelotu.

### I. Narzędzie / skill / blok

[PRAWO] Materiał wskazuje „klocki” jako zasoby, które można dołączać do wyspecjalizowanego wykonawcy, zamiast kodować całą wiedzę w jednym promptcie. fileciteturn28file0L2-L2

[REZONANS] KLOCEK powinien obejmować nie tylko skrypt/funkcję, ale potencjalnie skill / capability / resource, pod warunkiem zachowania zasady „bez własnego stanu”.

### J. Ślad wykonania

[NOŚNA RAMA] Materiał wspomina o pilocie, sesjach doświadczenia, audycie procesów i mierzeniu R0, ale mapa nie miała jeszcze jawnego obiektu ŚLADU: co się wydarzyło, czym dysponował wykonawca, jakie hand-offy wykonał, gdzie dostał blokadę i dlaczego powrót został przyjęty albo odrzucony. fileciteturn28file0L2-L2

[REZONANS] Bez śladu WIDZĄCY może wykryć pętlę głównie retrospektywnie; jawny ślad daje mu materiał do kontroli trajektorii.

### K. Harness / runtime

[NOŚNA RAMA] Materiał nie nazywa tej warstwy, ale aktualny research pokazuje, że jest ona potrzebna do opisania współczesnego ciała systemu: zarządzanie kontekstem, sesją, narzędziami, wznowieniem, uprawnieniami, środowiskiem i obserwowalnością.

[REZONANS] To może być warstwa nadrzędna nad ROLĄ, a nie kolejna maska.

---

## §1 — Research 1a · mapa współczesnych wzorców

### 1. Orkiestrator → wykonawcy

[PRAWO] Anthropic opisuje orchestrator-workers: centralny model dynamicznie rozbija zadanie, deleguje podzadania i scala wyniki; wzorzec jest użyteczny, gdy podzadań nie da się przewidzieć z góry. Źródło: Anthropic, „Building effective agents”, 19.12.2024. citeturn179040search0

[REZONANS] Dla HEXAGRAMU pasuje nie jako „szef agentów”, lecz jako mechanizm planowania przelotu i scalania wyników.

### 2. Graf stanów / durable execution

[PRAWO] LangGraph traktuje stan jako jawny element grafu wykonania, wspiera checkpointy, przerwania i wznowienie oraz zaleca przechowywanie surowego stanu i formatowanie promptu dopiero na żądanie. citeturn627185search1turn943168view3

[REZONANS] To jest mocny kandydat na mechanikę POKOJÓW, bo stan i przejścia stają się obserwowalne i odtwarzalne.

### 3. Blackboard / shared state

[PRAWO] Współczesne grafowe systemy utrzymują współdzielony stan, ale rozróżniają dane, które trzeba zachować, od tych, które można wyliczyć ponownie; LangGraph wprost zaleca, by nie przechowywać tego, co można odtworzyć. citeturn627185search1

[REZONANS] HEXAGRAM może mieć ograniczony blackboard, ale nie powinien zamieniać go w jeden wspólny brudnopis.

### 4. Role + skills / capabilities

[PRAWO] Anthropic rozwija Agent Skills jako pakiety instrukcji, skryptów i zasobów, które agent odkrywa i ładuje dynamicznie. citeturn119986search7

[REZONANS] To wzmacnia intuicję KLOCKA i SATELITY: zdolność powinna być dostępna na żądanie, a nie automatycznie obecna w każdym kontekście.

### 5. Handoff / agent-as-tool

[PRAWO] Aktualny OpenAI Agents SDK rozróżnia agent-as-tool, gdzie główny agent pozostaje właścicielem rozmowy, od handoffu, gdzie specjalista przejmuje aktywną rolę; historia przekazywana odbiorcy może być filtrowana. citeturn482559view3

[REZONANS] Przelot nie powinien automatycznie oznaczać przekazania całej historii ani oddania władzy nad całością.

### 6. Supervisor / guardrail

[PRAWO] OpenAI Agents SDK wspiera guardraile, które mogą blokować wykonanie oraz kontrolować wywołania narzędzi; handoff ma osobną ścieżkę kontroli, więc nie każda ochrona dziedziczy się automatycznie. citeturn865655search0turn865655search2

[REZONANS] To wspiera pomysł WIDZĄCEGO jako osobnej warstwy kontroli trajektorii, a nie kolejnej roli wykonawczej.

### 7. Agent-as-object / mały zestaw prymitywów

[PRAWO] Bieżący OpenAI Agents SDK definiuje agenta jako LLM wyposażony w instrukcje i narzędzia oraz opcjonalne handoffy, guardraile i structured output; runtime dostarcza także sesje, sandboxy i tracing. citeturn865655search3turn539341search0

[REZONANS] Współczesny agent jako obiekt jest bliższy konfigurowalnemu wykonawcy z kontraktem i runtime'em niż autonomicznej „osobie” zamkniętej w jednym promptcie.

### 8. Harness + środowisko wykonawcze

[PRAWO] OpenAI Agents API z 10.09.2026 rozdziela harness od środowiska: harness obsługuje kontekst, narzędzia, subagenty, kompresję kontekstu i równoległość, a sandbox daje pliki, kod i artefakty. citeturn482559view0

[PRAWO] Anthropic podkreśla, że założenia harnessu starzeją się wraz z poprawą modeli, dlatego stabilne interfejsy powinny przetrwać zmianę implementacji. citeturn482559view1

[REZONANS] To jest najważniejsza wskazówka dla „ciała”: stabilny kontrakt musi znajdować się ponad zmiennym modelem i zmiennym runtime'em.

### 9. Context engineering / just-in-time retrieval

[PRAWO] Anthropic zaleca najmniejszy zestaw wysokosygnałowych tokenów, just-in-time retrieval, compaction i structured memory; większe okno nie usuwa problemu zanieczyszczenia kontekstu. citeturn943168view0turn943168view1

[PRAWO] Aktualny OpenAI Agents API ma tool search do ładowania definicji narzędzi na żądanie oraz programmatic tool calling do przetwarzania wyników poza głównym kontekstem modelu. citeturn482559view0

[REZONANS] R0 powinien mierzyć nie tylko objętość startową, lecz także to, czy ciało umie nie ładować rzeczy, których aktualny pokój nie potrzebuje.

### 10. Stateless protocol layer

[PRAWO] MCP 2026-07-28 wprowadził stateless core, cacheowalne wyniki listowania, Tasks jako rozszerzenie i dalsze wzmocnienie autoryzacji. citeturn943168view4

[REZONANS] KLOCEK nie musi nosić sesji ani tożsamości; runtime może wystawiać capability przez stabilny protokół, a stan pozostaje w warstwie wykonania.

---

## §1.1 — Co z tego wynika dla mapy HEXAGRAMU

[REZONANS] Najpełniejsza hipoteza robocza mapy brzmi:

**SYSTEM → HARNESS/RUNTIME → ASYSTENT → ROLA → PRZELOT → POKÓJ → ŁADUNEK / ARTEFAKT → KLOCEK / CAPABILITY**,  
z **WIDZĄCYM** jako zewnętrzną warstwą kontroli trajektorii i **BRAMKĄ POWROTU** jako kontrolą wejścia z powrotem do ciała systemu.

[REZONANS] To nie jest jeszcze architektura docelowa. Jest to mapa robocza wynikająca z zestawienia brakujących pojęć z materiału wejściowego i współczesnych wzorców.

---

## §1.2 — Trzy wzorce do pogłębienia

[NOŚNA RAMA] **A · HARNESS + durable state / graph** — odpowiada na pytanie, jak dać asystentowi ciało, które przeżywa wieloetapową pracę, przerwanie i zmianę modelu bez utraty kontroli.

[NOŚNA RAMA] **B · CONTEXT ENGINEERING + JIT capabilities** — dotyka bezpośrednio R0, SATELITÓW, ŁADUNKU i problemu rozrostu kontekstu.

[NOŚNA RAMA] **C · HANDOFF + SUPERVISION / GUARDRAILS** — odpowiada na przelot asystenta i rolę WIDZĄCEGO, który kontroluje pętlę oraz powrót treści do systemu.

---

## §1.3 — Wstępne wskazówki architektoniczne

[PRAWO] Aktualne źródła nie pokazują, że większa liczba agentów sama w sobie jest celem; zamiast tego pokazują nacisk na prostotę, kontrolę kontekstu, jawne przejścia, runtime, sandbox, guardraile, tracing i ewaluację. citeturn179040search0turn765588search0turn482559view0

[REZONANS] **W1 — najpierw ciało, potem role:** nie mnożyć RÓL, dopóki nie ma jawnego runtime'u dla stanu, przelotu, uprawnień, śladu i powrotu.

[REZONANS] **W2 — POKÓJ powinien ograniczać widoczność, nie tylko opisywać etap:** powinien określać odczyty, capability, aktywny stan i dopuszczalny artefakt wyjściowy.

[REZONANS] **W3 — ŁADUNEK powinien być mniejszy niż historia:** hand-off powinien przenosić to, czego potrzebuje następny pokój, a nie automatycznie cały transcript.

[REZONANS] **W4 — WIDZĄCY patrzy na trajektorię, nie tylko na wynik:** interesują go pętle, wzrost ładunku, powroty do poprzednich pokoi, ponowne użycie tych samych capability i próby przekroczenia zakresu.

[REZONANS] **W5 — „wnieść z powrotem” jest osobnym typem operacji:** informacja odczytana ≠ artefakt zatwierdzony ≠ zmiana kanonu ≠ zmiana kodu.

[REZONANS] **W6 — model jest silnikiem wymiennym:** aktualne źródła wskazują projektowanie stabilnych interfejsów mimo zmian modeli i harnessu; dlatego nazwa modelu nie powinna być elementem tożsamości ROLI. citeturn482559view1turn671632search2turn671632search0

[PRAWO] **CZĘŚĆ 1a = wykonana.**

[PRAWO] **STOP przed §1b.**

