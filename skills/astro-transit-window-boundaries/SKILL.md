---
name: astro-transit-window-boundaries
description: Use when computing or reporting astrological transit windows — when a configuration begins, peaks and ends. Enforces both edges rather than one, marks a search-horizon boundary instead of inventing a date, refuses to let the edge of a search range pass as a peak, and requires that difficult aspects be reported alongside favourable ones. Load before telling anyone when their window opens or closes.
license: CC-BY-NC-SA-4.0
version: 1.0.0
metadata:
  version: 1.0.0
  former-name: kronos-czyta-niebo
  authors:
    - nowe spojrzenie (HEXAGRAM project)
  tags:
    - astrology
    - astronomy
    - ephemeris
    - transits
    - measurement
    - reporting
  platforms:
    - hermes
    - claude-code
    - cursor
    - codex-cli
    - generic
  siblings:
    - ai-hallucination-truth-status
    - astro-six-element-lens
---

# Transit Window Boundaries

**What this is.** A discipline for reporting *when* — when a transit begins, when it is exact, when it ends. It is arithmetic on ephemeris positions, and it can be got wrong in ways that are invisible to the person receiving the answer.

**What this is not.** It says nothing about what a transit *means*. Meaning is not computed here and this skill will not supply it. Load `astro-six-element-lens` if you want an interpretive layer that declares itself as one.

The separation is the point: **the arithmetic can be right or wrong, and that is checkable. The meaning cannot be checked the same way.** Collapsing them is how a defensible calculation becomes an indefensible claim.

## When to Use

- someone asks when a window opens, closes, or peaks
- you are about to say *this period is favourable for X* — the timing half of that sentence belongs here
- you are writing a script that scans transits and reports boundaries
- a previous answer gave one edge of a window and you are about to give the other

Do **not** load this when the question is what a period *means* rather than when it begins.
Meaning belongs to `astro-six-element-lens`, and that skill carries RESONANCE — this one
is arithmetic and is checkable.

## The five failures

### 1. Reporting one edge

A window has two. If you scan forward from *now*, you get the exit and nothing else — and the entry gets supplied by symmetry, by intuition, or by silence.

**Scan backwards as well.** If the entry was not scanned, do not state it. "Roughly mid-July, by symmetry" is an inference; label it as one, or go and measure it. The correction costs one loop; an inference presented as a date is uncorrectable once the person has planned around it.

### 2. Letting the search edge pass as a peak

If you search for the exact moment within ±30 days and the aspect is still tightening at day 30, the minimum you find sits *on the boundary of your search*. Reporting it as the peak is a fabricated precision — the number is real, the label is false.

**Detect it:** if the minimum falls at the edge of the range, say so — *"still tightening beyond the search horizon"* — and either widen the range or report no peak. Never both narrow the search and announce a maximum.

### 3. Inventing a boundary you did not reach

Slow bodies produce windows longer than any convenient scan. When the edge is outside the horizon, mark it — `> 14 months` — rather than reporting the horizon date as the boundary.

### 4. Reporting only the favourable

If three configurations are in orb and one is a trine, reporting the trine is **confabulation by omission**. Nothing false is said; the picture is false.

Report everything in orb, and count the hard aspects separately so the shape of the period is visible at a glance. Someone told only about the fortunate half will act on a half-picture and will not know that they did.

### 5. Leaving the frame unstated

An orb of 3° and an orb of 8° describe different windows around the same event. Sidereal and tropical give different signs for the same longitude. Ayanamsa choice moves everything by degrees.

**State the frame with every result:** zodiac, ayanamsa if sidereal, orb, scan step, body set. A window without its frame is not reproducible, and a result nobody can reproduce is a claim rather than a measurement.

## Procedure

1. **Measure the clock.** Not the assumed date — the system clock, read in the same step that writes the result. Cross-check against an external anchor when the environment's clock is not trusted.
2. **Compute natal positions once**, from birth data, in a stated frame.
3. **For each transiting body × natal point × aspect angle**, compute the deviation from exact.
4. **Anything within orb → scan both directions** until it exceeds orb. Beyond the horizon → mark it.
5. **Search for the exact moment** at a finer step, and **flag boundary minima**.
6. **Report everything found**, sorted by tightness, with hard aspects counted.
7. **Stop.** Do not attach meaning in the same output. A file that computes should not also interpret; mixing them means neither can be checked.

## Verification

1. Was the clock measured this run, or assumed?
2. For every boundary reported: was it *reached by a scan*, or inferred? Are inferences labelled?
3. Does any reported peak sit at the edge of the search range?
4. How many configurations are in orb, and how many did you report? If those numbers differ, why?
5. Is the frame stated — zodiac, ayanamsa, orb, step?
6. Could someone reproduce your window from your output alone? If not, it is not yet a measurement.

## Pitfalls

- **Symmetry as evidence.** Windows are not symmetric around the peak; retrograde motion breaks it entirely.
- **Ignoring retrograde returns.** A slow body may re-enter orb months later. A "closes on X" that does not check for a return is incomplete.
- **Orb inflation after the fact.** Choosing the orb that includes the aspect you wanted is the astrological form of p-hacking.
- **Precision beyond the source.** Reporting a peak to the minute when the scan step was twelve hours.
- **Blending timing and meaning.** The most common way a checkable statement becomes an unfalsifiable one.

---

*From HEXAGRAM · CC BY-NC-SA 4.0 · attribution: nowe spojrzenie. Every failure listed above was made by this project before it was written down: a window whose entry was inferred "by symmetry" and only measured a day later; five aspects whose reported peak turned out to be exactly the edge of the search range; a first report that mentioned the favourable transit and omitted the hard one in the same period. The engine that produced them is in the repository — the discipline is what travels.*
