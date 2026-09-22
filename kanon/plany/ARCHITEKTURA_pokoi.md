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
