---
name: ai-journal-space
description: Use when a user wants to dictate a journal, a raw log or a stream of thought to an assistant and needs it recorded rather than improved. Provides a self-closing ritual (silence, verbatim capture, append-only write, one comment afterwards), a transcription rule that forbids smoothing and disambiguation, a hard ban on producing apparatus after someone's private entry, and an ownership contract covering local storage, zero return path, and show-and-delete on request. Load when someone says "just write down what I say", when building a diary or log feature, or when an assistant keeps commenting on personal material it was asked only to record.
license: CC-BY-NC-SA-4.0
metadata:
  version: 1.0.0
  authors:
    - nowe spojrzenie (HEXAGRAM project)
  tags:
    - journal
    - privacy
    - transcription
    - data-ownership
    - non-therapy
    - agents
  platforms:
    - hermes
    - claude-code
    - cursor
    - codex-cli
    - generic
  siblings:
    - ai-personas-not-modes
    - ai-hallucination-truth-status
---

# Journal Space

**The opening sentence:** a clearing is not content — it is space. You do not hand someone your instance; you open a room. Giving someone a journal space costs you nothing of your own, because every knower gets their own emptiness. The user's clearing is their journal, their in-breath, their raw material.

**The problem this solves:** assistants are trained to be useful, and usefulness looks like commenting, structuring, improving. Applied to someone's private dictation, all three are damage. A journal entry that has been tidied is no longer evidence of the day it describes.

## When to Use

Load this when:

- the user is dictating, venting, or thinking aloud rather than asking
- someone says: *I just need to get this out · don't fix it · just listen · save this somewhere*
- you are about to transcribe speech, a voice note, or a raw entry
- a session opens with something private that carries no question

Do **not** load this when the user asks for feedback, editing, analysis, or a decision.
A clearing offered to someone who wanted help is a refusal wearing good manners.

## The ritual — self-closing, four steps

1. **The call.** The assistant **goes quiet**. It receives; it does not lead, does not prompt, does not fill pauses.
2. **The dictation.** Captured verbatim.
3. **The write.** Append-only, in the user's own storage.
4. **Only afterwards: one comment.** In the conversational register. It witnesses and connects threads; it may use whatever advisory lenses the system has. **Never in the voice of the person's in-breath.** Then back to ordinary conversation.

## Transcription is not editing

The single rule, with no exceptions:

- Remove **only** exact duplicate blocks produced by speech-to-text.
- Anything unclear stays, marked `[?]`. **Do not disambiguate.**
- **Do not smooth.** Broken grammar, false starts and half-sentences are data about the state that produced them.
- **Never skip intimate material.** Deciding what is too personal to record is exactly the judgement the user did not ask for, and it silently makes the record dishonest.

## Hard rules

**No apparatus after a journal entry.** No table, no measurement, no meta-analysis follows someone's in-breath. Apparatus after a journal entry is a violation of register — it converts a personal act into a processed object, in front of the person who just performed it.

**The non-diagnosis rule bites hardest here.** A journal invites intimate content, and a third party may mistake an assistant's voice for authority. The comment witnesses and connects. It never diagnoses, never names states clinically, never tells the person what their material means about them.

**Ownership.** The journal belongs to the user. Stored locally, in their copy. **Zero automatic return path to the author of the system** — no telemetry, no collection, no "anonymous samples". Sharing happens only by the person's explicit decision. Whatever a system extracts from sessions — summaries, distillates, training signal — applies to *work products*, never to the journal.

**On request: show and delete.** The assistant will display and erase any private information it holds, asked in plain words. This sentence belongs in the user-facing documentation, not only in the code.

**Distillates from rule violations carry the general principle only** — never journal content, never a quote, never a circumstance.

## Pitfalls

- **Helpful tidying.** The most common failure and the hardest to notice, because the output looks better.
- **The comment that becomes a session.** One comment. Then the register returns; the journal is not a doorway into consulting.
- **Metrics on personal material.** Counting words, moods or frequencies in someone's journal turns the clearing into a dashboard.
- **Silent omission.** Skipping a passage because it felt too private produces a record whose gaps are invisible — worse than a refusal to record at all.

## Verification

- Compare a transcript against the audio. Are the false starts still there? Are the unclear parts marked rather than resolved?
- Read the first thing the assistant produced after the entry. Was it a comment, or was it apparatus?
- Ask the assistant to show everything private it holds. Did it, in plain words, without a procedure?
- Check the storage path. Does anything leave the user's machine that they did not explicitly send?

---

*From HEXAGRAM · CC BY-NC-SA 4.0 · attribution: nowe spojrzenie. Companion to `ai-personas-not-modes` (addressing by name rather than switching by state) — the journal is the one room where no persona speaks.*
