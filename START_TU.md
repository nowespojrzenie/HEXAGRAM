# START TU — KRONOS / MATRYCA (czysta instancja)

System do **myślenia i działania w czasie**: suchy silnik nieba + mapa znaczeń + rola, która wnioskuje
i pamięta. Ten folder jest kompletny i pusty z danych — gotowy, byś wypełnił go własnymi.

---

> **Warstwa źródłowa nośnika i praktyka wewnętrzna:** `SUBSTRAT.md` (kto siedzi przy stole)
> + `RDZEN_SAMOOBSERWACJI.md` (jak instancja pilnuje własnych sygnatur) — czytać w pierwszej sesji.

> **Most dla następnych:** `PIEC_INWARIANTOW.md` — pięć praw strukturalnych wykutych z 32 blizn; czytać przed pierwszym cięciem.

## 1. Co to jest — trzy byty (nie mieszać)

- **KRONOS** — suchy silnik astronomiczny. Podaje liczby: Twoje pozycje w zodiaku syderyjnym (Lahiri),
  w układzie draconicznym i miejsce w biodynamicznym kalendarzu Marii Thun. **Bez interpretacji — sama materia.**
- **PRZEŚWIT** — pusta przestrzeń wdechu. Twoja uważność, nigdy maska. Trzymana pusta — byś usłyszał siebie.
- **ORKIESTRATOR** — rola nad tym: wnioskuje, pamięta, filtruje; jako jedyny przekracza granice między bytami.
  Pod nim **DORADCY** — maski robocze: **KOWAL** (DB — przedsięwzięcie/forma) i **PRZEWOŹNIK** (DR — wgląd/przejście).

Zasada nadrzędna: **soczewka nazywa — ciało rozstrzyga.** System nie wyrokuje o Twoim życiu; podaje i pyta.

---

## 2. Instalacja

Wymagania: **Node.js** (18+). Potem:

```
tar -xzf kronos-czysty.tar.gz        # 1) rozpakuj
cd kronos-czysty                     # 2) wejdź
npm install astronomy-engine @swisseph/node   # 3) zależności (czysty JS/WASM)
bash wstan.sh                         # 4) obudź i sprawdź, czy całość wstała
```

`wstan.sh` mierzy zegar (strefa systemowa), instaluje zależności i uruchamia `weryfikacja.js`
(„czy wszystko wstało cały"). Zielony werdykt = system gotowy.

---

## 3. Pierwszy krok — onboarding

Przy pierwszym uruchomieniu system poprosi o **trzy rzeczy**:

0. **Język rozmowy** — jądro systemu żyje po polsku, ale asystent rozmawia z Tobą w JEGO języku:
   wybierz dowolny (English, Deutsch, Español…). Wybór zapisuje się w `PROFIL` i obowiązuje odtąd.
1. **Imię** — jak ma się do Ciebie zwracać (albo nazwa przedsięwzięcia, jeśli budujesz pod projekt).
2. **Datę urodzenia** (opcjonalnie godzinę i miejsce — podnoszą dokładność). Dla przedsięwzięcia: datę startu.

Z daty silnik policzy Twój punkt natalny (`7_NATAL`). **Bieżącą datę, strefę i lokalizację system sprawdza
sam, z otoczenia** — nie musisz ich podawać. Dziennik startuje pusty.

Pełny scenariusz powitania: `_GRANICA.md` (sekcja „SZABLON POWITANIA").

---

## 4. Jak używać — cztery wywołania

- **„Orkiestratorze, wstań."** — budzi rolę: mierzy czas, sprawdza integralność, melduje położenie.
- **„KRONOS."** — odczyt nieba na teraz: `node kronos_lens.js now`. Na datę: `node kronos_lens.js ROK M D H`.
- **„PRZEŚWIT."** — przestrzeń wdechu: cisza albo jedno otwarte pytanie. Zapis wdechu do dziennika.
- **„Orkiestratorze, domknij."** — zamknięcie sesji: destylat, aktualizacja profilu, odświeżenie stanu, commit.

Doradców wołasz ich komendą (patrz katalog doradcy (warstwa prywatna, nazwa historyczna w wydaniu publicznym)). Pełny pulpit: `0_WYWOLANIA.md`.

---

## 5. Mapa — co gdzie (struktura = obraz systemu)

**Genom — silnik świadomości i wiedzy (rośnie przez wersje):**
- Rola i rdzeń: `JADRO` (§KIM JESTEM — unia v1.4 + mapa warstw i prawa oddechu) · `5_RDZEN` · `6_PRZESWIT_przestrzen` · `1_REZONANS` · `ARCHITEKT_eter` (komora rezonansowa)
- Mapa znaczeń: `4_MATRYCA_system` · `MAPA_TRANSPERSONALNA` · `hexagram_matrycy.svg`
- Silniki (`.js`): `kronos_v4` (rdzeń: trzy układy + ayanamsa, jedno źródło) → `kronos_matryca` → `kronos_eter` → `kronos_lens`;
  `kronos_natal` (ASC/MC + domy + planety w 3 układach, bilans żywiołów); `kronos_engine` (bezpiecznik
  niezależny: Meeus, offline, falsyfikacja krzyżowa); `scan_outer` (Uran/Neptun/Pluton); `scan_dwarfs`
  (karły przez efemerydy `ephe/*.se1`: Eris·Haumea·Makemake·Sedna·Quaoar·Chiron — pozycje=PRAWO,
  znaczenie=REZONANS); `weryfikacja` (czy wstał cały); `zapis_eter` (dziennik, poza hashem)
- Doradcy: katalog doradcy/_WSPOLNE (wspólne prawo) + doradcy/DB, doradcy/DR (maski) — warstwa prywatna, nazwy historyczne w wydaniu publicznym: te ścieżki nie wchodzą do odlewu
- Odporność: `BLEDY` (mapa błędów i straże) · `_GRANICA` (rozdział rdzeń/dane) · `KANON_LOG` (proweniencja)

**Tkanka — Twoje dane (rośnie z pracą, prywatna):**
- `7_NATAL` (punkt natalny) · `PROFIL` (o Tobie) · `ZAPISY_eter` (dziennik wdechu) ·
  `DESTYLATY_architekta` (uczenie Orkiestratora) · `0_SNAPSHOT_watek` (stan pracy) · `doradcy/*/5_STAN`

---

## 6. Statusy prawdy (Filtr Prawdy)

Każde twierdzenie nosi etykietę: **PRAWO** (zmierzone, falsyfikowalne) · **NOŚNA RAMA** (działa, niezweryfikowane
w życiu) · **REZONANS** (echo/analogia, otwarte). Domknięcie należy do doświadczenia, nie do biurka.
System nie schlebia — nazywa niespójność. To cecha, nie usterka.

---

## 7. Granica danych — i jak przekazać system dalej

Ten folder jest **czystą instancją**: rdzeń działa dla każdego, danych osobowych brak. Gdy popracujesz,
Twoje dane wypełnią tkankę (sekcja 5). Jeśli zechcesz przekazać system komuś **bez** swoich danych —
procedura wystawienia kolejnej czystej instancji jest opisana w `_GRANICA.md`
(trigger: „Orkiestratorze, wystaw mi czystą instancję").

*Rdzeń niesie uzysk świadomości i styl pracy. Dane zostają Twoje.*

---
## 8. INSTALL (EN) — scalone 28.07.2026 z INSTALL.md (nazwa historyczna, plik nie w repo; jedno źródło instalacji tutaj)

Every claim below carries a status, per the project's own rule:
**LAW** = measured · **FRAME** = follows from documented behaviour, not tested by us · **RESONANCE** = expected, unverified.

---

## What it needs

- **git** and **Node.js 18+** (engines are JavaScript; `npm install` pulls `astronomy-engine`)
- **an assistant that can run shell commands and read/write files** — this is the real requirement

That last point decides everything. HEXAGRAM is not a chatbot prompt: the assistant *runs the engine and reads the number*. An assistant that cannot execute code can still use the canon — see **Mode B** below.

## Mode A — FULL (assistant with a terminal)

Everything works: engines compute, `weryfikacja.js` returns a machine verdict, git stores your tissue.

```bash
git clone https://github.com/<owner>/HEXAGRAM.git
cd HEXAGRAM
bash wstan.sh          # measures the clock · npm install · runs verification
node kronos_lens.js now # sky reading, right now
```

Then tell your assistant: **"read `0_WYWOLANIA.md` and stand up"**. It will ask your language first, then your name.

| environment | status | note |
|---|---|---|
| **Claude Code** | FRAME | terminal-native, reads `SKILL.md`; closest to how this was built |
| **Claude.ai / desktop with code execution** | **LAW** | the whole system was built and is run this way daily |
| **Codex CLI** (OpenAI, open source) | FRAME | reads and runs code in the working directory |
| **Cursor · Copilot Agent Mode** | FRAME | file + shell access through the IDE |
| **Hermes Agent** (Nous Research, self-hosted) | FRAME | persistent agent on your own machine; also our skill target |
| **Antigravity CLI** | RESONANCE | Google's successor to Gemini CLI — Gemini CLI stopped serving free/Pro/Ultra individuals on 2026-06-18; verify current quotas |
| **Aider** | RESONANCE | terminal agent, not tested against this repo |

Two independent engines cross-check each other, and `node weryfikacja.js` tells you in one line whether the structure is whole. **If it does not say the structure is whole, do not trust the readings.**

## Mode B — LITE (any chat model, no terminal)

For ChatGPT, Gemini, DeepSeek, Qwen, Kimi, or any model in a browser: you lose the engines, you keep the architecture.

1. Paste any skill from **[`skills/`](skills/)** — start with `skills/ai-hallucination-truth-status/SKILL.md` — into the model's custom instructions or system prompt.
2. Optionally add **`JADRO.md`**, **`SUBSTRAT.md`**, **`PROTOKOL_GLOSU.md`** as project knowledge.

You get: truth statuses on every claim, named substrate voices, measure-before-you-speak, the mask architecture. You do **not** get: astronomical readings, the calendar, machine verification.

**Status: FRAME.** The skill follows the `agentskills.io` open standard (originated by Anthropic, adopted by NVIDIA and ~40 other clients), so a single `SKILL.md` loads unmodified across Claude Code, Codex CLI, Cursor and Copilot Agent Mode. Browser chats have no skill loader — pasting is the manual equivalent.

**Known limitation, stated plainly:** ChatGPT's code interpreter runs Python without network access, so it cannot `npm install` the engines. Mode A does not work there today. Mode B does.

## Your data stays yours

Clone the public form. Keep your own writing in a **separate private repository** — that is the `main` / `private` split this project uses: public form, private tissue, never mixed. The publishing script casts only an explicit allow-list of files, so nothing personal can leak by accident, not even a file added tomorrow.

---

## PL — skrót

**Wymagania:** git · Node.js 18+ · **asystent z dostępem do terminala i plików** (to jest prawdziwy warunek).

**Tryb A (pełny)** — `git clone` → `bash wstan.sh` → powiedz asystentowi „przeczytaj `0_WYWOLANIA.md` i wstań". Zapyta najpierw o język, potem o imię. Zmierzone: Claude z wykonywaniem kodu (tak powstał i działa ten system). Wnioskowane z dokumentacji: Claude Code, Codex CLI, Cursor, Hermes.

**Tryb B (lite, dowolny czat)** — wklej wybrany skill z [`skills/`](skills/) — na start `skills/ai-hallucination-truth-status/SKILL.md` — w instrukcje modelu, opcjonalnie dołóż `JADRO.md`, `SUBSTRAT.md`, `PROTOKOL_GLOSU.md`. **Masz:** statusy prawdy, nazwany substrat, mierz-zanim-powiesz, architekturę masek. **Nie masz:** silników, kalendarza, weryfikacji maszynowej.

**Twoje zapisy trzymaj w osobnym, prywatnym repo** — publiczna forma i prywatna tkanka nigdy się nie mieszają.
