---
name: voice-profile-from-own-texts
description: Use when a person wants text written in their own voice and you would otherwise imitate it by feel. Turns "write like me" into a measurement - collect at least ten of the person's own texts, build a numeric style profile from them with one tool, write against the profile, then measure the draft before showing it. The profile belongs to the person; the method is shared.
license: CC-BY-NC-SA-4.0
version: 1.0.0
metadata:
  version: 1.0.0
  authors:
    - nowe spojrzenie (HEXAGRAM project)
  tags:
    - writing
    - style
    - measurement
    - voice
    - polish
  platforms:
    - claude-code
    - cursor
    - codex-cli
    - generic
  siblings:
    - ai-agent-verify-success-claims
    - ai-hallucination-truth-status
    - ai-self-audit-without-hedging
  udzial:
    tworca: "The method was separated from one author's own measured profile inside the HEXAGRAM project: the tool and this skill carry the method only. That author's texts and numbers are not part of this skill."
    forma: "instancja HEXAGRAM"
    cudze: []
---

# Voice Profile From Your Own Texts

**The problem this solves:** asked to write "in someone's style", a model writes from a general feeling of what that sounds like, then declares that it matched. Nobody checks, because there is nothing to check with.

This skill turns the declaration into a measurement, and keeps the person's profile in a file that belongs to them.

## Method and profile are two different things

- **Method** (shared): `narzedzia/przyrzady/profil_stylu.js` measures a corpus into a profile and compares a new text to a profile. It contains no number and no phrase of any particular author.
- **Profile** (personal): a JSON file produced from *the person's own texts*. It is theirs. Do not publish it, do not copy it into a shared repository, and do not use one person's profile to write for another.

## Procedure - four steps, none optional

### 1 · Collect

Ask for **at least ten of the person's own texts**, ideally several dozen, in one register (essays with essays, product descriptions with product descriptions). Fewer than ten gives a profile the tool itself marks as unreliable. Texts the person wrote - not texts they edited, and not texts a model wrote for them.

### 2 · Measure

```sh
node narzedzia/przyrzady/profil_stylu.js --zmierz tekst1.md tekst2.md ... > profil.json
```

The tool counts sentence length and its spread, the share of very short sentences, paragraph length, dash habits, bold, headings, book-style connectors, a recurring reflexive axis, hedging, and person (we / I / you). Show the person the numbers once, so they can say what looks wrong. Some of it will be wrong: the profile measures *form*, not what the person means.

### 3 · Write against the profile

Write the draft with the profile in front of you. Do not imitate the person's phrases; follow the measured shape. Where a rule would make the text worse for its purpose, say so and let the person decide.

### 4 · Measure before showing

```sh
node narzedzia/przyrzady/profil_stylu.js --lint profil.json draft.md
```

Take the verdict from the **exit code**, not from the report text, and not through a pipe (the exit code of a pipe is the last command's): `0` inside the profile, `1` deviations, `2` bad input (missing file, unreadable or incomplete profile).

Show the person the deviations *with* the text - "this many deviations, in these fields, by this much" - never "I matched your style". A deviation is not an error: a factual register (numbers, sources) legitimately departs from a personal one. The author decides.

## Known limits - read before relying on it

- **It measures form from outside.** It does not know what in a style is the person's voice and what is a habit they would like to drop. Only the person can separate those.
- **Old corpus, old voice.** A profile describes the texts it was built from. If the person's voice has moved since, the profile has not.
- **Thresholds are fractions of the profile**, set so the tool behaves continuously with the version it was extracted from. They are a setting of the method, not an independent calibration, and they have not been validated on other people's corpora.
- **Polish-specific lists.** The connector list, the first-person and second-person forms, the hedging phrases and the imperative detection are tuned for Polish. For another language the measurement of rhythm and typography carries over; the lexical rows do not.
- **Imperative detection is a list plus an ending heuristic, not morphology.** An imperative outside the list, away from the start of a sentence and without a matching ending will be missed.
- Below twenty sentences the rhythm measurement is unreliable; the tool says so.

## Verification

Checks you can run to see whether the method is being applied, not merely loaded:

1. **The tool can fail.** `node narzedzia/przyrzady/profil_stylu.js --test` uses a synthetic profile and a three-text fixture whose numbers were counted by hand. Break the tool on purpose (delete one measure from `--zmierz`); the test must go red. If it stays green, the test is decoration.
2. **The profile is built from the person's texts.** `jq .korpus profil.json` shows how many texts, characters and sentences it was measured on. Ten texts is the floor, not a target.
3. **The verdict came from the exit code.** The report you show quotes the deviation count from the run, and you can name the exit code you read it from. A sentence like "matches your style" with no run behind it fails this check.
4. **The person saw the numbers once.** Step 2 ends with the profile shown to its owner. A profile the owner never saw is a guess that has been given a file name.

## Sources & lineage

**Not ours:** no outside source is cited in this file.

**The author's words and scars:** The method was separated from one author's own measured profile inside the HEXAGRAM project (an older style linter with the profile hard-coded in it was replaced by a tool that reads the profile from a file). That author's texts and numbers are not part of this skill.

**Form:** this instance. The wording is by the project's AI instance.
