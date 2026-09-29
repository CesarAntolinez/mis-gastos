# ADR-009 — Financial accounting semantics for Operations + Entries

**Status:** proposed
**Date:** 2026-09-29

> **Owner acceptance is required before this ADR can supersede or amend ADR-007.**
> This document records the approved *drafting direction* for review; it is not an accepted architecture decision.

## Decision in one sentence

Retain the **Financial Operation + Transaction Entry** model from ADR-007 and enrich it with explicit operation/event semantics so that the product rules for 50/30/20, debt derivation, opening balances, voiding, and COP-only MVP can be derived from a single source of truth per financial event.

## Problem

ADR-007 separated the *financial event* (`Financial Operation`) from the *account impact* (`Transaction Entry`), but it left the mapping between operation kinds and product-level concepts under-specified:

- What distinguishes an internal transfer from income?
- How does a reimbursement reduce the effective expense of a historical bucket without rewriting history?
- How is savings contribution counted for the 20% target without treating the savings account balance as the source of truth?
- How is a debt's remaining principal derived instead of duplicated?
- How is an opening balance traceable without inflating base income?
- What does voiding mean, and what must *not* cascade?

The legacy specification (`docs/02-domain-and-data.md`, `docs/09-indicators-dashboard.md`) contains detailed rules compatible with these questions, but they were written against a flatter `Transaction` model. This ADR proposes the reconciliation layer: a small, explicit event semantics vocabulary on top of Operations + Entries.

## Proposed decision

1. **Keep the Operations + Entries split.** `Financial Operation` represents what happened; `Transaction Entry` represents how it affected an `Account`.
2. **Separate operation *kind* from entry *direction*.** The kind answers the product question ("is this income, an expense, a transfer, a reimbursement?"); the direction answers the accounting question ("did this account go in or out?").
3. **Derive product-level concepts from operation kind + linked operations.** Do not persist mutable duplicate fields such as `remainingAmount` on debts, `isIncome` flags, or bucket overrides that change after the fact.
4. **Store the historical bucket on the operation/entry.** A category may *propose* a default bucket, but the bucket recorded at creation time is the historical truth and does not change when the category changes.
5. **Count savings contribution by operation semantics.** The 20% target is satisfied by operations whose kind is a savings contribution, not by inspecting account type or balance.
6. **Treat opening balance as a traceable event that is not income.** It establishes available cash but never participates in 50/30/20 base income. A zero opening balance produces no zero-value operation; a savings product's prior balance is a starting condition, not income or a 20% contribution.
7. **Use logical voiding.** A voided operation remains persisted but is excluded from derived calculations. Voiding is blocked when active dependent operations would be left invalid; there is no cascade delete.
8. **Keep ADR-005's `Money` value object multi-currency-capable, but the MVP remains COP-only.** Currency conversion is out of MVP scope.

## Conceptual operation/event semantics

The following table maps operation *kinds* to product meaning and typical account impact. Exact naming and enum values are intentionally left as a follow-up product decision; the semantics are the stable part of this proposal.

| Operation kind | Event semantics | Typical entries | Affects base income? | Bucket relevance |
|---|---|---|---|---|
| `income` | New money becomes available. A refund of an earlier ordinary expense received in a *later* calendar month is recorded as `income` linked to that expense. | Cash/bank `in` | Yes | N/A |
| `expense` | Consumption or payment. | Cash/bank `out` | No | NEEDS / WANTS |
| `transfer` | Move money between own accounts. | `out` from A, `in` to B | No | N/A |
| `reimbursement` | Return of a prior expense received in the *same* calendar month as the origin expense. | Cash/bank `in` | No | Reduces effective expense of the origin bucket (same calendar month only) |
| `saving_contribution` | Move money into a savings product. | Cash/bank `out`, savings `in` | No | SAVINGS |
| `saving_withdrawal` | Move money out of a savings product. | Savings `out`, cash/bank `in` | No | N/A |
| `financial_return` | Yield generated inside a savings product. | Savings `in` | Yes | N/A |
| `loan` | Money lent to a third party. | Cash/bank `out` | No | NEEDS / WANTS (bucketed like an expense at creation) |
| `loan_repayment` | Money returned by a debtor. | Cash/bank `in` | Same calendar month as loan: No. Later calendar month: Yes. | Reduces effective expense of the origin loan bucket when in the same calendar month |
| `opening_balance` | Initial available cash at onboarding, only when the amount is greater than zero. | Cash/bank `in` | No | N/A |

Key implications:

- `Transaction Entry.direction` alone does not decide whether the event is income, a transfer, or a reimbursement. The operation kind decides; the entry only records the account impact.
- A late refund of an ordinary expense is **not** a `reimbursement` kind. It is an `income` operation that carries a causal link to the original expense and contributes to the receiving month's base income.

## Bucket and base-income derivation at product-rule level

Base income for a period `P` is derived from operation kinds and linked causality, not from entry direction:

| Included in base income | Excluded from base income |
|---|---|
| `income` in `P` (including late-expense refunds recorded as `income`) | `opening_balance` |
| `financial_return` in `P` | `transfer` |
| `loan_repayment` in `P` when the original `loan` was in an earlier calendar month | `saving_withdrawal` |
|  | `reimbursement` received in the same calendar month as the original expense |
|  | `loan_repayment` received in the same calendar month as the original loan |

The same-vs-later calendar-month classification is based on the origin and refund/repayment calendar months (year + month), independent of whether the dashboard is showing a week, month, or year. Changing the dashboard period never reclassifies the operation.

Effective bucket expense for NEEDS/WANTS is derived as:

```text
sameCalendarMonth(d1, d2) = (year(d1) == year(d2) AND month(d1) == month(d2))

bucketOrigins(P, bucket) =
    active expense operations of bucket with date in P
  + active loan operations of bucket with date in P

linkedSameMonthRefunds(origin) =
    active operations r where
      r.kind in {reimbursement, loan_repayment}
      AND r causally links to origin
      AND r.date >= origin.date
      AND sameCalendarMonth(r.date, origin.date)

gross(P, bucket) = sum(bucketOrigins(P, bucket).amount)

refundTotal(P, bucket) =
    sum over origin in bucketOrigins(P, bucket) of
      min(sum(linkedSameMonthRefunds(origin).amount), origin.amount)

effectiveBucketExpense(P, bucket) = max(gross(P, bucket) - refundTotal(P, bucket), 0)
```

Rules encoded by this formula:

- Only refunds/repayments that are causally linked to an origin operation that is itself included in the selected period and bucket can reduce the bucket expense.
- A refund/repayment in a later week of the same calendar month still reduces the origin's effective cost; it does **not** create a negative expense in the refund week.
- Refunds/repayments are capped at their origin amount, and the resulting effective bucket expense is clamped at zero.
- A refund/repayment received in a later calendar month is excluded here; if it is a late-expense refund it was already recorded as `income` and contributes to base income instead.

`loan` operations are bucketed at creation (NEEDS or WANTS), and a same-calendar-month `loan_repayment` reduces the effective bucket expense of that loan rather than increasing base income. `loan_repayment` in a later calendar month still contributes to base income, as shown above.

Savings contribution for the 20% target is:

```text
savingsContribution(P) = sum(active saving_contribution operations in P)
```

Retirement of savings does **not** reduce the savings contribution of the period; it only affects account balances. These formulas mirror the intent of `docs/09-indicators-dashboard.md` §6–10.

## Debt source-of-truth

A debt ("cuenta por cobrar") is a relationship entity, not an account balance. Persist only identity, person reference, link to the originating `loan` operation, optional notes, and technical metadata (timestamps). Derive all financial values from the linked operations:

| What persists | What is derived |
|---|---|
| Debt identity | `originalAmount` from the originating `loan` operation |
| Person reference | `date` from the originating `loan` operation |
| Link to originating `loan` operation | `paidAmount` from linked `loan_repayment` operations |
| Optional note / concept | `remainingAmount = originalAmount - paidAmount` |
| Timestamps / technical metadata | `status` = `PENDING` while `remainingAmount > 0`, `PAID` when `remainingAmount == 0` |

Repayments are independent `loan_repayment` operations linked to the original `loan` operation (or to a `Debt` entity) via an **Operation Link** with relation `repaysDebt`. This preserves the rule from `docs/product/domain-rules.md` §6 and `docs/02-domain-and-data.md`: registering money owed is not the same as receiving it, and the debt state must not duplicate the operation amount.

The derived vocabulary is intentionally limited to `PENDING` and `PAID`. Do **not** introduce new product statuses such as `PARTIALLY_PAID` or `CANCELLED`. Cancellation or voiding consequences remain an open product decision. The only safe bound is to tie cancellation to logical voiding of the originating `loan` operation or of an erroneous repayment, with no cascade delete or automatic mutation of linked operations; the exact UX and business rules are left for the first vertical slice.

## Opening-balance and void behavior

- **Available cash opening balance:** If the onboarding opening amount is greater than zero, represent it as an `opening_balance` operation with a single entry increasing the default cash/bank account. If the amount is zero, do **not** create a zero-value operation. The operation is traceable in history when it exists, but it never contributes to base income or 50/30/20. Correction is allowed only while no related financial history exists; once history exists the opening balance is locked.
- **Savings product opening balance:** A savings product's `initialBalanceMinor`/`openingBalance` is a starting condition, not a transaction. It does not count as base income and does not count as savings contribution for the 20% target.
- **Voiding:** An operation can be marked `VOIDED`. Voided operations and their entries are excluded from all derived calculations. Voiding is blocked if active dependent operations (reimbursements, repayments, linked returns) would become causally invalid; there is **no cascade delete** or automatic voiding of dependents. This matches `docs/11-history.md` §§18–20 and `docs/02-domain-and-data.md` invariant 16.

## Consequences

### Positive

- A single operation kind + links is the source of truth for product interpretation; no `isIncome`/`isTransfer` flags or mutable derived amounts.
- Transfer between own accounts cannot be mistaken for income.
- Reimbursements and repayments preserve causal links while allowing period-dependent presentation.
- Savings contribution and savings account balance remain distinct concepts.
- Voiding preserves audit history; no destructive cascade is needed.
- `Money` with currency code keeps the door open for future multi-currency support without adding MVP scope.

### Costs and risks

- Queries for history and dashboard require joins across operations, entries, links, debts, and persons.
- The exact operation-kind vocabulary must be finalized before schema freeze.
- UI labels (e.g., "Reintegro" vs. "Ingreso computable") must be derived from kind + link + period, not from a single stored field.
- Team discipline is required: do not add a new operation kind that mixes event semantics with account impact.

## Alternatives considered

| Alternative | Why not selected |
|---|---|
| Return to a flat `Transaction` table with nature + direction enums | Reintroduces the event/impact mix that ADR-007 rejected and makes transfers and linked operations harder to keep consistent. |
| Persist `remainingAmount` on `Debt` and update it on every repayment | Creates a second source of truth and risks drift between the persisted value and the sum of linked operations. |
| Cascade delete voided operations and their dependents | Breaks traceability and contradicts the history/audit requirements in `docs/11-history.md`. |
| Treat savings account balance as the 20% savings metric | Would make withdrawals reduce past period performance retroactively; rejected per `docs/09-indicators-dashboard.md` §10 and §14. |
| Add formal double-entry accounting | Exceeds MVP scope and introduces concepts (debits/credits, chart of accounts) that the product does not need, per ADR-007. |

## Questions and implementation dependencies

The following items are intentionally left open for the first vertical slice or owner decision; this ADR only fixes the semantics direction:

1. Exact enum names and cardinality for operation kinds (e.g., does `financial_return` need a separate kind, or can it be a subtype of `income`?).
2. Whether the historical bucket is stored on the operation, on the primary entry, or both.
3. Whether a `Debt` entity is created at the domain layer or represented purely by operation links in the MVP schema.
4. UX behavior when voiding is blocked by active dependents: error, warning, or guided correction?
5. Index and query design for effective-date ranges, links, and void filtering (follow ADR-007 Drift implications).
6. Conversion rules for `Money` across accounts remain undefined; MVP is strictly COP.

## References

- `AGENT.md`
- `docs/product/domain-rules.md`
- `docs/product/roadmap.md`
- `docs/02-domain-and-data.md`
- `docs/09-indicators-dashboard.md`
- `docs/11-history.md`
- `docs/13-onboarding.md`
- `docs/architecture/decisions/005-money-representation.md`
- `docs/architecture/decisions/006-financial-dates-and-periods.md`
- `docs/architecture/decisions/007-financial-data-model.md`
