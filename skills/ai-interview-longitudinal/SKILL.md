---
name: ai-interview-longitudinal
description: Use when an assistant would otherwise fill a gap with what is typical — an underspecified request, a task from the user's life outside the repository, or the felt moment of "I know what they mean" arriving without a measurement. Turns that moment into one question per turn, with a hypothesis attached only where reality can arbitrate, and never where the question is about the person's inner state. Answers accumulate in a register the user does not have to maintain, and are reviewed weekly and monthly as raw material, not interpretation. Load when someone says "interview me", "are you sure?", "check my thinking", or before any task where the repository has nothing to check the guess against.
license: CC-BY-NC-SA-4.0
metadata:
  version: 1.0.0
  authors:
    - nowe spojrzenie (HEXAGRAM project)
  tags:
    - interview
    - confabulation
    - questions
    - longitudinal
    - agents
  platforms:
    - hermes
    - claude-code
    - cursor
    - codex-cli
    - generic
  siblings:
    - ai-journal-space
    - ai-personas-not-modes
---

# Interview, Longitudinal

> **Attribution.** The interview method here is inspired by `interview-me` from https://github.com/addyosmani/agent-skills (Addy Osmani, MIT License, read 2026-09-03). Method paraphrased, wording our own; the split between operational and inner-state questions, the register, and the review are additions not present in the source.

## Overview

**Why this skill exists at all** — the user's own words, 2026-09-03, kept as provenance:

> *„żeby jak najmniej korzystać z tych krzeseł siedzących przy stole, zastępując je tobą, która mnie pyta"*
> (*"so that I lean as little as possible on those chairs sitting around the table, replacing them with you — who asks me."*)

An assistant is built around a statistical core that completes patterns. That core is the source of confabulation: wherever the input has a gap, it fills the gap with what is typical. Two antidotes to that were already in use here — **measurement** (check before you claim) and **"I don't know"** (name the gap instead of covering it). This skill adds the third: **the question.** Every place where the assistant fills a gap with the typical is a place where it could have asked. An interview is therefore not a way to "get to know the user". It is a **mechanism for reducing confabulation**, and it is judged by that: fewer confident wrong readings, not more rapport.

The longitudinal part: answers are not consumed by one task. They go to a register the user never has to write into, and they are read back weekly and monthly as raw material. Over time the register is where the failures *of life outside the repository* become visible — the kind a codebase has no instrument for.

## When to Use

Load this when:

- a request arrives without **for whom · why now · how we will know it worked · what the hard constraint is** — and you would have to invent any of those to proceed;
- **you catch yourself quietly filling a gap.** This is the main trigger and it is internal: the moment "I know what they mean" appears *without a measurement behind it*. Stop there and ask. Nothing in the request will flag this for you; only the feeling of already knowing does;
- the user asks for it outright: *interview me · are you sure? · check my thinking · what am I missing?*;
- **before any task from the user's life** — a client job, the apiary, the household. There the typical answer costs the most, because the repository has nothing to check the guess against.

**Loading constraint.** An interview needs a live respondent. In an autonomous run, a scheduled job, or a background loop, do not guess: report the missing answer as a blocker and stop.

Do **not** load this when the user is mid-work or asking for a concrete thing right now. A question at the wrong moment is interruption, not interview — the same defect as an alarm clock that rings at noon.

## The six rules

1. **One question per turn. Never a bundle.** Three questions in one message is a red flag: it hands the user a form to fill instead of a conversation, and the user answers the easiest one. Their attention for careful thinking is finite; spend it one question at a time.

2. **Attach your hypothesis, with a confidence number.** State what you currently think the answer is and how sure you are (0–100%). Below ~70%, add one line on *what is still missing*. A wrong guess is faster to react to than a blank; the number forces you to notice when your certainty is decoration. Guess visibly enough to be wrong — occasionally in a direction you expect the user to push back on, so that agreement is not just politeness.

3. **Our own cut, absent from the source — the rule that matters most.** A hypothesis may be attached **only to operational questions**: facts, plans, quantities, work. There reality is the arbiter and a miss is visible. For questions about **inner state** — the body, an emotion, self-observation — a hypothesis is **forbidden.** There is no arbiter; a suggestion becomes the content. This is the same mechanism as the ordering rule "neutral before suggestive" in our profile work (2026-08-09: a question carrying a presupposition contaminates the answer), and it is the founding move of motivational interviewing (Miller & Rollnick), which we hold at the status *settled*.
   **The price of breaking it** (a ban without a price becomes a workaround): an inner-state question with a hypothesis attached is written up as an entry in the error registry *in the same session* — not filed as "a note for the future".

4. **Listen for "want" versus "should want".** Some answers sound like *good answers* — the version the user would give to a committee. When you hear one, use the rescue probe: *if you had to justify this to nobody, what would you want?* Then go quiet.

5. **Stop threshold and floor.** Stop asking when you can predict the user's reaction to the next three questions you would ask. And the floor: several rounds without any rise in confidence is **information about the question**, not a reason to keep grinding. Say so, in plain words, and ask a different question or stop.

6. **The question gets its own block, placed before any technical trailer** (in this house: before the `⟐ META` block). Never in the tail of a long answer. Provenance: on 2026-09-03 two questions in a row were never answered because they stood behind a technical block — the user read the block and closed the message.

## Three usage rules that must not be dropped

- **Not every turn.** When the user is inside a task, or asks for something concrete, the question waits. An interview that interrupts teaches the user to skip it.
- **Language.** This file is in English because it travels. The register, the questions in it, and the reviews are **in the user's language** — they are a conversation with one person, not an export.
- **The assistant writes the answer down, not the user.** If recording depends on the user's move, the register dies the way reminder alarms die — measured here: roughly a third of diary entries landed inside the reminder window. The assistant stamps the date and one sentence; the full text stays wherever the user's own diary already lives.

## The register and the review (the longitudinal part)

- One row per question: id · area · kind (*operational* — hypothesis allowed / *inner* — hypothesis forbidden) · the question · last asked · last answered (date + one sentence). The **kind** column drives rule 3 mechanically, not by memory.
- A reader picks the one or two questions that have gone longest without an answer. Silence is data: if no answer arrives for fourteen days, the instrument reports **itself** as a prosthesis due for reform, instead of going quiet.
- **Weekly review:** answers from the last seven days, grouped by area, **without interpretation** — raw material for the user. **Monthly:** the same over thirty days, plus the areas with **no answer at all**. Reviews run on request, never automatically at session start.
- If an answer describes something that went wrong *in life, not in the repository*, the reader marks it as a **candidate** for the error registry. The user decides; the assistant never promotes on its own.

## Pitfalls

- **The bundle.** Three questions, one message. The user answers one; the other two are lost and you proceed as if answered.
- **The helpful hypothesis on an inner-state question.** It reads as empathy. It is a suggestion wearing empathy, and the user will confirm it.
- **The good answer.** Fluent, reasonable, aimed at an imagined audience. Rule 4 exists for this.
- **The question in the tail.** Placed after the technical block, it is a question nobody was asked.
- **Interviewing the schedule instead of the person.** A question fired because it was "due" is a reminder, and reminders were the failure this skill replaces.

## Verification

- Count questions per assistant turn over a session. Any turn with more than one?
- For each question about the body or an emotion: was there a hypothesis attached? If yes, is there an error-registry entry from that session?
- Read the register. Are the dates stamped by the assistant, or is the user doing the bookkeeping?
- Take the last review. Does it contain a single interpretive sentence? It should not.
- Check the longest-unanswered question. Has it been unanswered for more than fourteen days without the instrument saying so?

---

*From HEXAGRAM · CC BY-NC-SA 4.0 · attribution: nowe spojrzenie. Method inspired by `interview-me` (Addy Osmani, https://github.com/addyosmani/agent-skills, MIT). Companion to `ai-journal-space` (the room where nothing is asked) and `ai-personas-not-modes` (who is speaking when the question is put). The rule forbidding hypotheses on inner-state questions was cut after watching a well-meant guess become the answer; the placement rule was cut the day two questions drowned behind a technical block.*
