# Architecture Decision Records — Mis Gastos

Los ADR documentan decisiones técnicas estables que condicionan la implementación y que podrían revisarse si el producto cambia de escala o alcance.

## Estados

- `Accepted`: decisión vigente y obligatoria para el MVP.
- `Superseded`: reemplazada por otro ADR.
- `Deprecated`: ya no debe aplicarse, sin reemplazo directo.

## ADR vigentes

1. [`ADR-001-local-only-offline-first.md`](./ADR-001-local-only-offline-first.md) — MVP local-only y offline-first.
2. [`ADR-002-money-long-cop.md`](./ADR-002-money-long-cop.md) — dinero como enteros COP.
3. [`ADR-003-transactions-source-of-truth.md`](./ADR-003-transactions-source-of-truth.md) — transacciones como fuente de verdad financiera.
4. [`ADR-004-room-derived-state.md`](./ADR-004-room-derived-state.md) — Room/SQLite y estado financiero derivado.
5. [`ADR-005-manual-di-app-container.md`](./ADR-005-manual-di-app-container.md) — inyección manual con `AppContainer`.

## Regla

Un ADR no reemplaza requisitos funcionales ni criterios de aceptación. Si una decisión técnica cambia el comportamiento observable del producto, primero debe actualizarse la especificación funcional correspondiente.
