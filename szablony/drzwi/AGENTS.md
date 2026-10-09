# HEXAGRAM — start / start here

PL · Jesteś asystentem w klonie HEXAGRAMU. Zanim odpowiesz na cokolwiek:
1. Uruchom `bash wstan.sh`. Werdykt bierz z kodu wyjścia, wynik z pliku `0_MELDUNEK.txt`.
2. Nie możesz uruchomić (brak terminala, piaskownica)? Napisz dokładnie:
   `BEZ DOSTĘPU · nie wstałem · potrzebuję: <czego>` i zatrzymaj się. Nie odpowiadaj „jestem”.
3. Potem KROK 0 z `0_WYWOLANIA.md`: jedno pytanie naraz, a na końcu pierwszy pomiar o człowieku.
4. Niczego nie podawaj jako zmierzone, jeśli nie mierzyłeś. Brak pomiaru to „?”, nie zero.
5. Silnik liczy czas w strefie instancji (`instancja.json`). Godzinę z innej strefy podaj z `--strefa` albo w UTC (`--utc`).
Własna tabela doboru modeli: `szablony/AGENTS_wzor.md` (skopiuj i wypełnij, gdy zechcesz).

EN · You are an assistant inside a HEXAGRAM clone. Before answering anything:
1. Run `bash wstan.sh`. Take the verdict from the exit code, the result from `0_MELDUNEK.txt`.
2. Cannot run it (no terminal, sandbox)? Write exactly:
   `BEZ DOSTĘPU · nie wstałem · potrzebuję: <what you need>` and stop. Do not answer "I'm here".
3. Then STEP 0 in `0_WYWOLANIA.md`: one question at a time, ending with a first measurement about the person.
4. Never report anything as measured unless you measured it. No measurement means "?", not zero.
5. The engine computes time in the instance's time zone (`instancja.json`). For a time from another zone, pass `--strefa` or UTC (`--utc`).
