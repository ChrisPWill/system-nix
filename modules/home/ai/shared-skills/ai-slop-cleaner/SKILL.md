---
name: ai-slop-cleaner
description: Clean AI-generated code slop with a regression-safe, deletion-first workflow and optional reviewer-only mode
---

# AI Slop Cleaner

Use this skill to clean AI-generated code slop without drifting scope or changing intended behavior. This is the bounded cleanup workflow for code that works but feels bloated, repetitive, weakly tested, or over-abstracted.

## When to Use

Use this skill when:
- the user explicitly says `deslop`, `anti-slop`, or `AI slop`
- the request is to clean up or refactor code that feels noisy, repetitive, or overly abstract
- follow-up implementation left duplicate logic, dead code, wrapper layers, boundary leaks, or weak regression coverage
- the user wants a reviewer-only anti-slop pass via `--review`
- the goal is simplification and cleanup, not new feature delivery

## When Not to Use

Do not use this skill when:
- the task is mainly a new feature build or product change
- the user wants a broad redesign instead of an incremental cleanup pass
- the request is a generic refactor with no simplification or anti-slop intent
- behavior is too unclear to protect with tests or a concrete verification plan

## Execution Posture

- Preserve behavior unless the user explicitly asks for behavior changes.
- Lock behavior with focused regression tests first whenever practical.
- Write a cleanup plan before editing code.
- Prefer deletion over addition.
- Reuse existing utilities and patterns before introducing new ones.
- Avoid new dependencies unless the user explicitly requests them.
- Keep diffs small, reversible, and smell-focused.
- Stay concise and evidence-dense: inspect, edit, verify, and report.
- Treat new user instructions as local scope updates without dropping earlier non-conflicting constraints.

## Scoped File-List Usage

This skill can be bounded to an explicit file list or changed-file scope when the caller already knows the safe cleanup surface.

- Good fit: `/ai-slop-cleaner src/auth/session.ts src/auth/tokens.ts`
- Good fit: a handoff of only the files changed in a prior implementation session
- Preserve the same regression-safe workflow even when the scope is a short file list
- Do not silently expand a changed-file scope into broader cleanup work unless the user explicitly asks for it

## Review Mode (`--review`)

`--review` is a reviewer-only pass after cleanup work is drafted. It exists to preserve explicit writer/reviewer separation for anti-slop work.

- **Writer pass**: make the cleanup changes with behavior locked by tests.
- **Reviewer pass**: inspect the cleanup plan, changed files, and verification evidence.
- The same pass must not both write and self-approve high-impact cleanup without a separate review step.

In review mode:
1. Do **not** start by editing files.
2. Review the cleanup plan, changed files, and regression coverage.
3. Check specifically for:
   - leftover dead code or unused exports
   - duplicate logic that should have been consolidated
   - needless wrappers or abstractions that still blur boundaries
   - missing tests or weak verification for preserved behavior
   - cleanup that appears to have changed behavior without intent
4. Produce a reviewer verdict with required follow-ups.
5. Hand needed changes back to a separate writer pass instead of fixing and approving in one step.

## Workflow

1. **Protect current behavior first**
   - Identify what must stay the same.
   - Add or run the narrowest regression tests needed before editing.
   - If tests cannot come first, record the verification plan explicitly before touching code.

2. **Write a cleanup plan before code**
   - Bound the pass to the requested files or feature area.
   - List the concrete smells to remove.
   - Order the work from safest deletion to riskier consolidation.

3. **Classify the slop before editing**
   - **Duplication** — repeated logic, copy-paste branches, redundant helpers
   - **Dead code** — unused code, unreachable branches, stale flags, debug leftovers
   - **Needless abstraction** — pass-through wrappers, speculative indirection, single-use helper layers
   - **Boundary violations** — hidden coupling, misplaced responsibilities, wrong-layer imports or side effects
   - **Missing tests** — behavior not locked, weak regression coverage, edge-case gaps
   - **UI/design defaults** — generic visual patterns that make an AI-built interface feel unreviewed

### Comment Hygiene

Treat comments as part of the cleanup surface. Review only comments introduced by the
current change; leave pre-existing comments alone unless the requested scope includes them.

- Keep comments that explain a non-obvious **why**: a constraint, tradeoff, workaround,
  race, invariant, compatibility issue, or external requirement.
- Delete comments that merely narrate the next line, restate an obvious declaration, record
  edit history, label a section, or form decorative banners. Treat filler such as “this
  function is responsible for”, “we need to”, and “note that” as a prompt to rewrite or delete.
- Prefer plain English and the fewest words that preserve the explanation. Keep doc comments
  concise; their summary is useful, but filler and implementation narration are not. As a
  review threshold, question non-doc comments longer than 15 words, doc comments over 60 words
  total (or 30 words before tags), three or more consecutive comment lines, and three or more
  comments that exceed 30% of added code lines.
- A concise “why” comment may legitimately resemble narration or restatement. Signals include
  an explanation of a constraint or consequence (for example, “because”, “otherwise”,
  “workaround”, “race”, “must”, “deprecated”, a spec/RFC, or an issue reference); inspect the
  surrounding code before removing it.
- Preserve directives, TODO/FIXME notes, URLs, license/copyright headers, and shebangs unless
  they are independently in scope for removal.
- When a comment is disputed but protects real context, retain it and make the reason explicit
  rather than deleting it to satisfy a mechanical rule.
- Avoid treating comment heuristics as infallible: verify the surrounding code and allow an
  explicit keep marker or documented exception when a terse comment is genuinely necessary.

4. **Run one smell-focused pass at a time**
   - **Pass 1: Dead code deletion**
   - **Pass 2: Duplicate removal**
   - **Pass 3: Naming and error-handling cleanup**
   - **Pass 4: Test reinforcement**
   - Re-run targeted verification after each pass.
   - Do not bundle unrelated refactors into the same edit set.

5. **Run the quality gates**
   - Keep regression tests green.
   - Run the relevant lint, typecheck, and unit/integration tests for the touched area.
   - Run existing static or security checks when available.
   - If a gate fails, fix the issue or back out the risky cleanup instead of forcing it through.

6. **Close with an evidence-dense report**
   Always report:
   - **Changed files**
   - **Simplifications**
   - **Behavior lock / verification run**
   - **Remaining risks**

## Usage

- `/ai-slop-cleaner <target>`
- `/ai-slop-cleaner <target> --review`
- `/ai-slop-cleaner <file-a> <file-b> <file-c>`

## Good Fits

**Good:** `deslop this module: too many wrappers, duplicate helpers, and dead code`

**Good:** `cleanup the AI slop in src/auth and tighten boundaries without changing behavior`

**Bad:** `refactor auth to support SSO`

**Bad:** `clean up formatting`
