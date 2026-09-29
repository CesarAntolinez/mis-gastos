# Agent context — Mis Gastos

## Canonical project context

Before making product, domain, architecture, persistence, navigation, or UX decisions, read the relevant canonical documents:

- `docs/product/vision.md`
- `docs/product/domain-rules.md`
- `docs/product/roadmap.md`
- `docs/development/workflow.md`

Do not replace these sources with assumptions from the current implementation.

## Decision protocol

A decision is any choice that materially changes product behavior, domain semantics, architecture, data modeling, persistence, navigation, UX conventions, dependencies, security, compatibility, or development policy.

Before implementing such a choice:

1. Check whether the decision is already documented.
2. If documented, follow it unless the requested work explicitly changes it.
3. If not documented and the choice is reversible/local with no meaningful product or architectural consequence, choose the simplest consistent option and report it.
4. If not documented and the choice has meaningful consequences or credible alternatives, do **not** silently decide it. Surface the decision with context, alternatives, trade-offs, and a recommended option for owner approval.
5. After approval, persist the decision in the repository before or together with the implementation.

## Decision records

Store durable project decisions under:

`docs/architecture/decisions/`

Use one Markdown file per decision when the choice deserves an independent record. Use a short descriptive filename such as:

`docs/architecture/decisions/001-local-first-storage.md`

Each record should contain:

- **Status:** proposed, accepted, superseded, or rejected.
- **Context:** what forces the decision now.
- **Decision:** the approved choice.
- **Alternatives:** realistic options considered.
- **Consequences:** benefits, costs, constraints, migration or follow-up implications.
- **References:** related Issues, product rules, SDD artifacts, PRs, or evidence.

Do not create decision records for trivial implementation details.

## Product and financial rules

`docs/product/domain-rules.md` is authoritative for financial semantics. Never invent or silently alter classifications involving income, reimbursements, debts, available balance, savings, financial products, or period boundaries.

A change to a domain invariant requires an explicit product decision. Use SDD when the change benefits from formal proposal/spec/design/tasks/verify artifacts, according to `docs/development/workflow.md`.

## ODD, SDD and RDD boundary

Use the Gentle AI / Gentle Shell runtime contracts as the authority for ODD, SDD and RDD behavior. This file adds repository context only; it does not redefine those workflows.

- ODD / PI DEV is the normal implementation route for sufficiently understood work.
- SDD is explicitly selected when formal change artifacts are wanted.
- RDD is independent review/evidence and does not define product scope or delivery authority.

## UI and UX

For mobile interface or interaction work, load and follow:

`.agents/skills/mobile-design/SKILL.md`

Visual decisions must preserve domain meaning. A polished interface must never hide, merge, or relabel financially distinct concepts merely for visual simplicity.
