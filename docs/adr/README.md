# Architecture Decision Records — Mis Gastos

> **Índice histórico / legacy.** Los ADRs enumerados en esta carpeta (`ADR-001` a `ADR-005`) corresponden a la era Kotlin/Room del proyecto y **ya no son autoridad de implementación activa**.
>
> **Autoridad actual técnica:** `docs/architecture/decisions/` (Flutter + Dart, SQLite + Drift, Riverpod, semántica contable).
> **Autoridad actual de producto:** `docs/product/vision.md`, `docs/product/domain-rules.md` y `docs/product/budgeting.md`.
>
> Cada ADR histórico conserva su texto original e incluye una nota en su encabezado que indica qué reglas de producto o decisiones de arquitectura lo reemplazan.

## Estados (usados en los registros históricos)

- `Accepted` en este índice histórico significa "aceptado en su momento" para la era Kotlin/Room, no para la implementación actual.
- Las decisiones vigentes se encuentran en `docs/architecture/decisions/`.

## ADRs históricos

1. [`ADR-001-local-only-offline-first.md`](./ADR-001-local-only-offline-first.md) — MVP local-only y offline-first (era Kotlin/Room).
2. [`ADR-002-money-long-cop.md`](./ADR-002-money-long-cop.md) — dinero como enteros COP (era Kotlin/Room).
3. [`ADR-003-transactions-source-of-truth.md`](./ADR-003-transactions-source-of-truth.md) — transacciones como fuente de verdad financiera (era Kotlin/Room).
4. [`ADR-004-room-derived-state.md`](./ADR-004-room-derived-state.md) — Room/SQLite y estado financiero derivado (era Kotlin/Room).
5. [`ADR-005-manual-di-app-container.md`](./ADR-005-manual-di-app-container.md) — inyección manual con `AppContainer` (era Kotlin/Room).
