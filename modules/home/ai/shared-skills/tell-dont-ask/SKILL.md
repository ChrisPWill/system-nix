---
name: tell-dont-ask
description: Keep each business rule in one place, on the object whose data it reads, and delete the copies. Use when writing, fixing or changing a business rule (a condition that decides something about a domain object from its fields), when reviewing a diff for rule drift, when a test asserts several fields of one object, or when asked to apply "tell, don't ask".
argument-hint: "[rule to change | 'review' | path or PR]"
---

# Tell, don't ask

Sequence's agreed engineering standard (Notion: "Tell, don't ask", Proposals and
decisions, stage Agreed). It applies to every module, in new code and old, and a
departure from it is a blocking review comment.

**Asking** is code outside an object reading that object's fields to make a decision
the object could have made. **Telling** is calling a method on the object that makes
the decision from its own data. When the rule is asked in several places, the copies
drift: one gets a fix and the others don't, and customers see contradictory behaviour.

Real cost from our codebase:

- "Should we chase this invoice for money?" has seven copies across `invoices` and
  `orchestra`. One skips a total `== 0`, one refuses anything not `> 0`, and
  `Invoice.asSent` rounds to the currency first. An invoice totalling 0.0032 was sent
  as unpaid and chased, though it showed as 0.00 everywhere. The rounding fix reached
  one copy.
- "Is this quote expired?" was written out five times before `Quote.isExpired(today)`
  existed. Adding the method switched two callers; three copies are still there.
- "Must the customer keep a primary billing contact?" is enforced four different ways
  by four validators on a raw list, because nothing represents a customer's contacts.

Creating the method is half the work. Deleting the copies is the other half, and it is
the half that gets forgotten.

## The default failure to avoid

Asked to fix a bug, a model fixes it in the code in front of it, and when the rule
already exists elsewhere it writes another copy. Don't. Before touching a rule, find
every copy of it.

## When changing or adding a rule

1. **State the question the rule answers** in business words, e.g. "is this invoice
   still owed money?". This becomes the method name.
2. **Search every module for existing copies** before changing anything. Search for the
   field names the rule reads (e.g. `paymentStatus`, `grossTotal`, `expiresAt`),
   the enum values it compares against, and the object's existing methods. Include
   other services that see the object through a shared model (e.g. orchestra reads
   invoices via `invoices-protos`), validators, API mappers, controllers, event
   handlers, SQL, and tests.
3. **List every copy** to the user as a table: location, how it differs (thresholds,
   rounding, which statuses it allows or excludes, null handling). Differences between
   copies are often live bugs; call them out and ask which behaviour is correct rather
   than picking one silently.
4. **Put the rule where it belongs:**
   - Reads one object's data → a method on that object, named the way the business
     would say it (`isAwaitingPayment()`, `isExpired(today)`, `isZeroAmount()`). Keep
     the fields it reads private where the language and codebase allow.
   - Must hold across a group of objects → the aggregate root, and every change to the
     group goes through it (e.g. `CustomerContacts.add/change/archive`, each checking
     the billing-primary rule in one private method).
   - Needs several objects → a policy (e.g. `AutoIssueEligibility.evaluate(...)`) that
     owns the order of checks and the outcome, and asks each object its own question
     instead of reading its fields. Prefer exhaustive outcomes that fail closed over an
     `else` that fails open.
   - If the method already exists, call it.
5. **Switch every copy to the method and delete the copies in the same change.** That
   includes a wrapper like `QuoteAggregate` that holds the object and re-implements its
   rule. Tests that re-assert the rule's fields should call the method instead; the
   rule's own tests sit next to the method.
6. **Keep caller-specific logic in the caller.** Only the "what is true about this
   object" part moves. "When to send the reminder" stays in the reminder job;
   "is the customer still owed money" moves to the invoice.

## What is not a copy

- Reading fields to display, map into an API response, or export. (Mapping
  `isExpired = quote.isExpired(today)` is fine; mapping
  `isExpired = status !in ... && expiresAt...` is a copy.)
- A database query filtering by status to keep the result set small, as long as the
  domain method still makes the decision.

## Reviewing for drift

When asked to review, or before finishing your own change, look for:

- **Conditions built from another object's getters**, e.g.
  `invoice.paymentStatus != PAID` in a job, or
  `schedule.endDate != null && schedule.endDate.isBefore(date)` in a use case. Ask
  which object owns the rule, then search for the same field names to find the other
  copies.
- **Comments that explain what a condition means.** The comment is usually the name of
  the missing method ("Check the schedule is still alive at the effective date").
- **Comments that point at other code**, such as "mirrors the workflow's
  `validForDunning` rule". That's an admission of two copies; compare them.
- **Tests asserting several fields of one object** to check an outcome. The test is
  another copy of the rule and will keep passing on the old rule after it changes.
- **Fixes to a rule that touch fewer places than the rule exists in.** Check that a PR
  fixing a rule fixed every copy, and that the copies it touched now agree.

Report each finding with the question the rule answers, every location found, how the
copies differ, and the object (or aggregate or policy) the rule should live on.

## Output

When changing a rule, before editing: the question, the table of copies with their
differences, and the proposed home. Ask about any behavioural differences between
copies. Then make the change, and finish by confirming that a fresh search for the
rule's field combinations finds only the method and its tests.
