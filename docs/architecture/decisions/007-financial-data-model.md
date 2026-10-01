# ADR-007 — Modelo de datos financiero: Operations + Entries

**Status:** superseded
**Date:** 2026-09-28

> **Superseded por ADR-009.** `docs/architecture/decisions/009-financial-accounting-semantics.md` reemplaza este ADR para la semántica contable del producto. ADR-007 sigue describiendo el modelo estructural subyacente de Operations + Entries allí donde sea consistente con ADR-009.

## Context

Mis Gastos necesita representar gastos, ingresos, movimientos entre cuentas propias, reintegros, dinero prestado a terceros, devoluciones parciales o totales y relaciones históricas entre movimientos.

Un modelo plano de una fila por transacción tiende a mezclar dos conceptos diferentes:

1. qué evento financiero ocurrió;
2. cómo ese evento afectó una o más ubicaciones de dinero.

También puede forzar campos derivados como `isIncome`, `isTransfer` o balances persistidos que terminan creando múltiples fuentes de verdad.

El modelo debe respetar las reglas de `docs/product/domain-rules.md`, la representación monetaria de ADR-005 y los períodos financieros de ADR-006 sin convertirse en un sistema completo de contabilidad de partida doble.

## Decision

Adoptar un modelo basado en **Financial Operation + Transaction Entries**.

- **Financial Operation** representa el evento económico/lógico que ocurrió.
- **Transaction Entry** representa el efecto de esa operación sobre una cuenta/producto financiero.
- Las relaciones causales entre operaciones se representan explícitamente mediante **Operation Links**.
- Personas y deudas se modelan como entidades relacionadas, sin convertir una deuda pendiente en dinero recibido.

El modelo es similar a un ledger por su trazabilidad, pero **no implementará contabilidad formal de partida doble** en el MVP.

## Conceptual model

```text
┌──────────┐
│ Account  │
└────┬─────┘
     │
┌────▼────────────────┐
│ Transaction Entry   │
└────┬────────────────┘
     │
┌────▼────────────────┐
│ Financial Operation │──── Category
└────┬────────────────┘
     │
     ├──────── Operation Link ──── Financial Operation
     │
     └──────── Debt ────────────── Person
```

## Core entities

### Accounts

Representan dónde está el dinero del usuario.

Campos conceptuales iniciales:

```text
id
name
type
currency
initialBalanceMinor
isArchived
createdAt
updatedAt
```

Tipos iniciales previstos:

```text
cash
bank
savings
other
```

`Savings` es un tipo de cuenta/producto financiero, no una categoría de gasto.

Mover dinero entre dos cuentas propias no crea ingreso ni gasto económico.

### Financial Operations

Representan qué ocurrió.

Campos conceptuales iniciales:

```text
id
kind
effectiveDate
categoryId?
personId?
note?
createdAt
updatedAt
```

Kinds iniciales previstos:

```text
expense
income
transfer
reimbursement
```

La lista puede evolucionar cuando el dominio lo requiera. No añadir flags redundantes para representar simultáneamente varias interpretaciones derivables.

### Transaction Entries

Representan cómo una operación afecta una cuenta.

Campos conceptuales iniciales:

```text
id
operationId
accountId
direction
amountMinor
currency
createdAt
```

`direction` expresa el efecto sobre esa cuenta:

```text
in
out
```

El monto continúa siendo una magnitud no negativa conforme a ADR-005.

Ejemplos:

#### Gasto

```text
Operation: expense
  Entry:
    account = Cuenta bancaria
    direction = out
    amount = COP 25.000
```

#### Ingreso

```text
Operation: income
  Entry:
    account = Cuenta bancaria
    direction = in
    amount = COP 800.000
```

#### Transferencia entre cuentas propias

```text
Operation: transfer
  Entry 1:
    account = Cuenta bancaria
    direction = out
    amount = COP 100.000

  Entry 2:
    account = Ahorros
    direction = in
    amount = COP 100.000
```

La transferencia es una sola operación lógica con dos efectos relacionados, no dos transacciones independientes.

## Categories

Campos conceptuales iniciales:

```text
id
name
icon
kind
isSystem
isArchived
createdAt
updatedAt
```

`kind` permite inicialmente categorías de:

```text
expense
income
```

Las transferencias internas no deben categorizarse como gastos únicamente para reutilizar categorías existentes.

El producto puede incluir categorías iniciales del sistema y permitir su evolución posteriormente conforme al roadmap.

## People

Una persona representa un tercero relevante para relaciones financieras dentro de Mis Gastos.

Campos conceptuales iniciales:

```text
id
name
note?
isArchived
createdAt
updatedAt
```

El MVP no requiere acceso a los contactos del dispositivo. Integrar contactos requeriría una decisión posterior debido a permisos, privacidad y UX.

## Debts

Una deuda representa dinero que un tercero debe al usuario.

Campos conceptuales iniciales:

```text
id
personId
originalOperationId
amountMinor
currency
effectiveDate
status
note?
createdAt
updatedAt
```

Estados iniciales:

```text
open
partiallyPaid
paid
cancelled
```

No persistir `remainingAmount` como segunda fuente de verdad mientras pueda derivarse de:

```text
original amount - repayments = remaining amount
```

Las devoluciones parciales o totales deben relacionarse con la deuda/operación original.

## Operation Links

Representan relaciones causales entre operaciones.

Campos conceptuales iniciales:

```text
id
sourceOperationId
targetOperationId
relation
createdAt
```

Relaciones iniciales previstas:

```text
reimburses
repaysDebt
```

Ejemplo:

```text
Operación original
      │
      │ repaysDebt
      ▼
Operación de devolución
```

La relación debe conservarse aunque la clasificación de presentación de la devolución cambie por período.

## Persisted facts vs derived values

### Persistir

- operaciones y su tipo factual;
- entries y su dirección por cuenta;
- montos exactos y moneda;
- fecha efectiva;
- timestamps técnicos;
- cuentas;
- categorías;
- personas;
- deudas y estado cuando represente workflow real;
- relaciones entre operaciones.

### Derivar cuando sea posible

- saldo actual de una cuenta;
- disponible total;
- remaining amount de una deuda;
- totales mensuales;
- gastos/ingresos agregados por categoría;
- pertenencia a período cuando pueda derivarse de fecha efectiva y zona horaria;
- clasificación de presentación dependiente de la relación y período cuando aplique.

No persistir caches/aggregates como fuente de verdad hasta que exista evidencia de rendimiento que lo justifique.

## Invariants

1. Todo entry pertenece a exactamente una operación y una cuenta.
2. `amountMinor` es no negativo.
3. Un entry debe usar una moneda compatible con la cuenta, salvo que exista posteriormente un modelo explícito de conversión de divisas.
4. Una transferencia interna ordinaria debe representar salida y entrada relacionadas dentro de una sola operación.
5. Una transferencia interna no crea ingreso ni gasto económico.
6. Una deuda pendiente no incrementa el dinero disponible.
7. Las devoluciones deben preservar su relación causal con la operación/deuda original cuando exista.
8. No duplicar valores derivados como fuentes independientes de verdad sin una decisión explícita.
9. Las reglas financieras pertenecen al dominio; el schema protege integridad estructural pero no reemplaza `domain-rules.md`.

## Not double-entry accounting

El patrón Operations + Entries no implica adoptar contabilidad formal de partida doble.

El MVP no introduce:

- chart of accounts contable;
- débitos/créditos contables formales;
- activo/pasivo/patrimonio;
- journal contable general;
- balance general;
- cierre contable.

Estas capacidades no deben aparecer accidentalmente por intentar generalizar el modelo.

## Drift / SQLite implications

La implementación concreta deberá:

- usar foreign keys donde protejan relaciones reales;
- definir índices basados en consultas reales, especialmente por `effectiveDate`, `operationId`, `accountId`, `personId` y relaciones cuando corresponda;
- mantener migraciones versionadas;
- mapear filas Drift hacia modelos de dominio en los límites adecuados;
- evitar exponer companions/data classes generados directamente a widgets;
- probar constraints y migraciones cuando el schema evolucione.

Los nombres exactos de tablas/columnas pueden ajustarse durante implementación si conservan este contrato conceptual.

## Alternatives considered

### Una tabla plana `transactions`

Es más simple inicialmente, pero dificulta representar transferencias como una sola operación, favorece flags redundantes y mezcla evento financiero con impacto por cuenta.

### Dos transacciones independientes para cada transferencia

No se selecciona porque permite que los dos lados se desincronicen y pierde identidad de operación.

### Contabilidad completa de partida doble

Aporta rigor contable pero excede el alcance de una aplicación personal de gastos y añadiría conceptos que el usuario/producto no necesita actualmente.

## Consequences

### Positive

- Transferencias y operaciones relacionadas conservan identidad y trazabilidad.
- El saldo puede derivarse de entries sin tratar movimientos internos como ingresos.
- El modelo admite reintegros y devoluciones sin perder el origen.
- Reduce campos booleanos redundantes y estados contradictorios.
- Proporciona una base consistente para historial y agregados mensuales.

### Costs

- Es más estructurado que una tabla plana.
- Consultas de historial requerirán joins entre operations, entries y entidades relacionadas.
- Repositories/mappers deberán presentar modelos convenientes para la UI sin filtrar complejidad innecesaria.

## Follow-up

Con este ADR aceptado, el schema físico inicial puede definirse durante el bootstrap/primera vertical slice. No es necesario congelar ahora todos los nombres de columnas o índices.

La primera implementación debe validar el modelo con un flujo vertical real antes de ampliar todas las features.

## References

- `AGENT.md`
- `docs/product/domain-rules.md`
- `docs/product/roadmap.md`
- `docs/architecture/decisions/002-persistence.md`
- `docs/architecture/decisions/005-money-representation.md`
- `docs/architecture/decisions/006-financial-dates-and-periods.md`
