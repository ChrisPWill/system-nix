---
name: go-deeper
description: Rewrite a prompt or task so it asks for the deeper version a top professional would do, not a bigger one — naming the expert's extra step, the raw material they'd start from, their methods and tools, and an outside judge of correctness. Use when asked to "go deeper", deepen a prompt, ask "what would an expert do here", or when a task feels like it's being done at the level of digested summaries.
argument-hint: "[prompt text | 'this task']"
---

# Go deeper

Most prompts ask for work one layer above where the real answer lives: a summary of a
ticket instead of the logs, a formatted table instead of a model, "check it works"
instead of a test someone else wrote. This skill moves the request down that layer.

It comes from Felix Rieseberg's prompt in "How to be more ambitious: A tutorial for
humans with models":

> I want a deeper version of this task, not a bigger one. Before rewriting it: (1) say
> what a top professional in this field would do here that I'm not asking for; (2) name
> the rawest material they would start from instead of what has already been digested
> for me; (3) name the specific methods and tools they would use; (4) say what, other
> than you or me, would show the result is right. Then rewrite my prompt to ask for
> exactly that.

The output is the analysis and the rewritten prompt, in chat. Don't start the deeper
work until the user approves the rewrite.

## Input

- **A prompt** passed as the argument: deepen that.
- **No argument, or "this task"**: deepen the task currently in progress in the
  conversation, stated as the prompt the user effectively gave.

If neither exists, ask for the prompt rather than inventing one.

## Ground it first

The four answers are only useful if they name things that exist. Before answering,
spend a few minutes finding out what is actually reachable:

- In a repository: the code paths involved, tests, fixtures, git or jj history, schema
  and migrations, ADRs and docs.
- Through connected tools: databases, logs, traces, tickets, meeting transcripts. Check
  the tool is connected; a configured-but-failed server is not available right now.
- Otherwise: the primary sources for the field (specifications, standards, original
  datasets, statutes), not articles about them.

Don't claim a source, table, tool or test exists without having seen it. If an expert
would want something you can't reach, say so and name who or what could provide it.

## Answer the four questions

Start by naming the field in one line ("a billing systems engineer", "an SRE doing an
incident review", "a statistician"). Every answer below depends on that choice, and
naming it lets the user correct it before anything else.

Then, briefly and concretely:

1. **What a top professional would do that isn't being asked for.** Depth only: the
   step they wouldn't skip, the question they'd ask first, the assumption they'd test.
   Not extra features, extra deliverables or adjacent scope.
2. **The rawest material.** What they'd start from instead of what has been digested:
   rows in the database rather than a dashboard, the diff rather than the PR
   description, request logs rather than the incident summary, the contract rather
   than the account manager's notes. Name the actual table, file, log query or document
   where you found one.
3. **Methods and tools.** Named and specific: `EXPLAIN ANALYZE`, a cohort query, a
   property-based test, `git bisect`, a reconciliation against the ledger, a
   difference-in-differences comparison. "Analyse carefully" is not a method.
4. **The outside judge.** Something other than the model or the user that would show
   the result is right: a test that fails before and passes after, totals that match
   an issued invoice, a prediction checked on data not used to build it, a type
   checker, a domain expert's sign-off. Prefer judges the model can run itself, since
   they give feedback during the work rather than after it. Never "review it again".

## Rewrite the prompt

Write the prompt the user should have sent, asking for exactly what the four answers
describe. It should:

- name the raw sources to start from, by location
- name the methods to use
- state the outside judge as the definition of done
- keep the user's original goal and constraints

Then check it against "deeper, not bigger". Compare the rewrite to the original: if it
now asks for more outputs, more systems or more features, cut back to the original
scope. The rewrite may be longer because it is more specific; it must not be broader.

## Output

In this order, as short sections:

1. **Field** — one line.
2. **The four answers** — a short paragraph or a few bullets each.
3. **Rewritten prompt** — in a quoted block, ready to copy.
4. **Gaps** — sources or judges an expert would want that aren't reachable here, and
   who could provide them. Omit if there are none.

End by offering to run the rewritten prompt. Only start once the user says yes; they
may want to edit it first.
