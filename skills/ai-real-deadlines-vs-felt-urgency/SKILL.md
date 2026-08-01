---
name: ai-real-deadlines-vs-felt-urgency
description: Use when deciding what to do next under time pressure — especially pressure nobody imposed. Separates windows that genuinely close (a cost that rises with delay) from urgency that is merely felt, measures how wide each window actually is before planning inside it, and refuses to manufacture deadlines where none exist. Load when someone says "we should do this today", when a plan is being sequenced, or when a task feels urgent and you cannot name what closes.
license: CC-BY-NC-SA-4.0
metadata:
  version: 1.0.0
  former-name: orkiestrator-czasu
  authors:
    - nowe spojrzenie (HEXAGRAM project)
  tags:
    - planning
    - prioritization
    - decision-making
    - time-management
    - agents
    - productivity
  platforms:
    - hermes
    - claude-code
    - cursor
    - codex-cli
    - generic
  siblings:
    - ai-hallucination-truth-status
    - ai-preregistration-confirmation-bias
---

# Real Deadlines vs Felt Urgency

**The problem this solves:** almost everything feels urgent, almost nothing is, and the few things that genuinely have a closing window rarely feel like anything at all. Plans then get built around the loud items and the quiet closing one is missed — usually noticed weeks later, when the cheap version of it is no longer available.

An assistant makes this worse by default. Asked *what should we do first*, it produces a confident ordering, and confident ordering reads as analysis. The ordering is usually driven by whatever was mentioned most recently and most emphatically.

## When to Use

- a plan is being sequenced and something is "the priority"
- someone says *we should do this today* — and the reason is not yet stated
- a task feels urgent and you cannot name what closes if it slips
- you are about to work late, cut scope, or skip verification to "make it"
- an agent is about to recommend an order of work

## The single question

For every item:

> **What becomes more expensive, or impossible, if this slips — and by how much?**

Three honest answers:

- **a rising cost** — name it and name the rate. *Renaming is free now and costs the accumulated history later.* That is a real window.
- **a hard boundary** — an external date somebody else set. Real, and the rarest.
- **nothing** — it will cost exactly the same next week.

**The third answer is the most common and the hardest to say.** Say it anyway. An item with no closing window is not thereby unimportant; it is simply not urgent, and conflating those two is what produces plans that are busy and wrong.

## Windows of different orders

The most expensive planning error in practice is not misjudging a window — it is **mistaking two windows of different orders for one.**

A window measured in hours and a window measured in weeks are not comparable, and the short one is almost always the louder. When both are in view, state each with its own duration, explicitly, side by side. Otherwise the hourly one silently sets the pace for the weekly one, and work gets rushed against a clock that governs something else entirely.

Practical form: **before planning, write down each relevant window as a pair — what closes, and how wide.** Ranges that differ by an order of magnitude belong in separate lines, never in one sentence.

## Measure the window before planning inside it

Width is checkable far more often than people assume — a config change is free until adoption, a migration cost rises with data volume, a submission form has no clock at all. **A width nobody measured tends to be assumed narrow**, because assumed-narrow feels responsible and assumed-wide feels lazy.

Then:

- **Do not narrow a window to create motivation.** Manufactured urgency buys speed by spending judgement, and it trains everyone to distrust future urgency, including the real kind.
- **Do not report a boundary you did not check.** *"We should do this today"* without a named cost is a mood.
- **When the window is wide, say so plainly.** *There is no rush here* is real information and usually a relief. Withholding it to keep momentum is a small dishonesty with a long tail.

## Plan with margin, not to capacity

A plan filled to the edge has no room for the thing that always happens. Margin is not slack — it is the part of the plan that absorbs discovery.

Two rules that survive contact:

- **One irreversible move per sitting.** Renames, deletions, publications, force pushes: one, then verify, then stop. Two irreversible moves in one pass means the second one was not really decided.
- **Do not start something whose failure mode is "half-done" at the end of a block.** Half-migrated, half-renamed, half-published are all worse than not-started, and end-of-block is exactly when that gets attempted.

## Death criteria for plans

Every planned item gets a **date and a condition under which it is dropped rather than deferred**.

Without it, items do not die — they become quiet residents of the list, cited occasionally, never done, quietly shaping priorities by their presence. A list of those is worse than no list, because it looks like a plan.

Drop them **in batches**. Individually, each one argues its case; together, the pattern is visible.

## Verification

1. For each item on your list: what closes, and how fast? Any item you cannot answer for is not urgent.
2. Are there two windows of different orders in play? Are they written separately with their widths?
3. Did you measure any width this session, or are they all assumed?
4. Is there manufactured urgency in your plan — pressure that exists to create motion rather than because something closes?
5. How many irreversible moves does this block contain?
6. Does every item have a date and a drop condition? When did you last drop anything?

## Pitfalls

- **Loudest as most urgent.** Recency and emphasis are not closing costs.
- **Assumed-narrow.** An unmeasured window defaults to feeling tight; it is more often wide.
- **Urgency as motivation.** Effective once, corrosive after, and it devalues genuine urgency.
- **The quiet closing window.** Free-until-adopted, cheap-until-migrated, reversible-until-published. These never announce themselves and are the ones actually worth tracking.
- **Deferral instead of death.** An item moved forward three times has already been decided against; the list is just refusing to say so.
- **Confusing quality windows with deadlines.** *This is a good time for X* is not *X must happen by Y*. The first informs sequencing; the second constrains it. Treating the first as the second is how a good period becomes a bad rush.

---

*From HEXAGRAM · CC BY-NC-SA 4.0 · attribution: nowe spojrzenie. The distinctions here were paid for. A renaming that was free at zero adoption and would have cost accumulated history a month later was nearly deferred as "not urgent"; a submission that felt like the day's most pressing task turned out to have no clock on it whatsoever; and a window of roughly thirty-six hours and one of roughly two weeks were, for a full day, treated as the same window — with the short one setting the pace.*
