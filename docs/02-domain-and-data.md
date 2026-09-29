# 02 — Dominio y datos

## Principio

`Transaction` es la fuente de verdad de los movimientos financieros. Préstamos, pagos, ahorro, retiros, devoluciones y rendimientos deben estar respaldados por transacciones; las entidades auxiliares aportan contexto y relaciones, pero no duplican los datos monetarios del movimiento.

Las fórmulas visibles del Dashboard se definen en [`09-indicators-dashboard.md`](./09-indicators-dashboard.md). El diseño físico de persistencia está congelado en [`14-room-sqlite-schema.md`](./14-room-sqlite-schema.md).

## Transaction

Campos de dominio:

- `id: Long`
- `date: LocalDate`
- `direction: TransactionDirection`
- `nature: TransactionNature`
- `amount: Long`
- `categoryId: Long?`
- `bucket: BudgetBucket?`
- `concept: String?`
- `relatedTransactionId: Long?`
- `personId: Long?`
- `financialProductId: Long?`
- `status: TransactionStatus`
- `createdAt: Instant`
- `updatedAt: Instant`

### TransactionDirection

- `INCOME`
- `EXPENSE`

La dirección describe el signo del movimiento desde la perspectiva funcional del usuario, pero **no basta para decidir qué saldo cambia**.

### TransactionNature

- `NEW_INCOME`
- `EXPENSE`
- `SAVING`
- `SAVING_WITHDRAWAL`
- `REIMBURSEMENT`
- `OPENING_BALANCE`
- `FINANCIAL_RETURN`
- `LOAN`
- `LOAN_REPAYMENT`

La naturaleza determina cómo participa el movimiento en saldo disponible, productos financieros, ingreso base, ahorro y cuentas por cobrar.

Ejemplos:

- `NEW_INCOME`: aumenta disponible e ingreso base. Puede ser ingreso ordinario o una devolución tardía relacionada con un gasto anterior.
- `SAVING`: disminuye disponible y aumenta un producto financiero.
- `SAVING_WITHDRAWAL`: disminuye un producto y aumenta disponible; no aumenta ingreso base.
- `FINANCIAL_RETURN`: aumenta el producto financiero y el ingreso base, pero no el disponible directamente.
- `LOAN`: disminuye disponible y crea una cuenta por cobrar.
- `LOAN_REPAYMENT`: aumenta disponible y reduce la cuenta por cobrar; su efecto en ingreso base depende del mes del préstamo original.
- `REIMBURSEMENT`: devolución asociada a un gasto ordinario dentro del mismo mes calendario; aumenta disponible, no ingreso base y reduce el gasto efectivo del origen.

### TransactionStatus

- `ACTIVE`
- `VOIDED`

Una transacción anulada permanece persistida pero no participa en cálculos financieros normales.

## BudgetBucket

- `NEEDS` — meta 50%
- `WANTS` — meta 30%
- `SAVINGS` — meta 20%

El bloque persistido en la transacción es la fuente de verdad histórica.

`Category.defaultBucket` sólo puede usar `NEEDS` o `WANTS` en el MVP. `SAVINGS` se usa en transacciones de naturaleza `SAVING`, no como categoría ordinaria.

## Category

Campos:

- `id: Long`
- `name: String`
- `defaultBucket: BudgetBucket`
- `active: Boolean`
- `createdAt: Instant`
- `updatedAt: Instant`

La categoría propone un bloque por defecto, pero la transacción puede sobrescribirlo dentro de los valores permitidos.

Cambiar `defaultBucket` no modifica transacciones existentes.

Reglas:

- `name.trim()` no puede quedar vacío;
- no puede existir otra categoría activa con el mismo nombre normalizado;
- reactivar vuelve a validar unicidad;
- desactivar no elimina histórico ni relaciones.

## FinancialProduct

Representa un contenedor financiero local simple, no una integración bancaria.

Campos:

- `id: Long`
- `name: String`
- `openingBalance: Long`
- `active: Boolean`
- `createdAt: Instant`
- `updatedAt: Instant`

Saldo derivado:

```text
openingBalance + aportes + rendimientos - retiros
```

Reglas:

- `openingBalance >= 0`;
- no cuenta como ingreso base ni ahorro del período;
- no afecta saldo disponible;
- queda bloqueado después de existir histórico financiero relacionado;
- el saldo derivado nunca puede ser negativo;
- sólo puede desactivarse con saldo derivado exactamente cero;
- no puede existir otro producto activo con el mismo nombre normalizado;
- reactivar vuelve a validar unicidad.

## Person

Campos:

- `id: Long`
- `name: String`
- `active: Boolean`
- `createdAt: Instant`
- `updatedAt: Instant`

No es una agenda de contactos. Sólo identifica personas relacionadas con cuentas por cobrar.

Reglas:

- `name.trim()` no puede quedar vacío;
- sólo puede desactivarse cuando su saldo total pendiente por cobrar sea cero;
- desactivar conserva préstamos y pagos históricos;
- no puede existir otra persona activa con el mismo nombre normalizado;
- reactivar vuelve a validar unicidad.

## Normalización de nombres

Conceptualmente:

```text
normalizedName = trim + comparación case-insensitive
```

La capitalización original se conserva para presentación. El diseño físico persiste `normalized_name` para consultas/validaciones eficientes.

## Receivable

`Receivable` representa la relación de cuenta por cobrar generada por una transacción `LOAN`. No duplica monto, fecha ni concepto del préstamo.

Campos persistentes mínimos:

- `id: Long`
- `personId: Long`
- `originTransactionId: Long`
- `createdAt: Instant`
- `updatedAt: Instant`

Datos derivados desde la transacción origen y sus pagos:

```text
originalAmount = originTransaction.amount
date           = originTransaction.date
concept        = originTransaction.concept
paidAmount     = suma de pagos con transacción ACTIVE
pendingAmount  = originalAmount - paidAmount
status         = pendingAmount == 0 ? PAID : PENDING
```

`ReceivableStatus` puede existir como valor derivado de dominio/UI:

- `PENDING`
- `PAID`

No es necesario persistirlo en v1.

## ReceivablePayment

Representa la asociación entre una cuenta por cobrar y la transacción `LOAN_REPAYMENT` que registra un pago.

Campos persistentes mínimos:

- `id: Long`
- `receivableId: Long`
- `transactionId: Long`
- `createdAt: Instant`

Monto y fecha se derivan desde la transacción asociada. No se duplican.

Los pagos parciales son válidos. La suma de pagos activos no puede superar el monto de la transacción `LOAN` origen.

## AppSetup

Estado explícito de inicialización:

```text
onboardingCompleted: Boolean
```

No se infiere a partir de transacciones, categorías o productos. Su representación física se define en `14-room-sqlite-schema.md`.

## Ingreso base 50/30/20

Aumentan ingreso base:

- `NEW_INCOME`;
- `FINANCIAL_RETURN`;
- `LOAN_REPAYMENT` recibido en un mes calendario posterior al préstamo original.

No aumentan ingreso base:

- `OPENING_BALANCE`;
- `SAVING_WITHDRAWAL`;
- `REIMBURSEMENT` del mismo mes;
- `LOAN_REPAYMENT` del mismo mes del préstamo.

Una devolución de gasto ordinario recibida en un mes posterior se persiste como `NEW_INCOME` con `relatedTransactionId` apuntando al gasto origen.

La fórmula canónica está en `09-indicators-dashboard.md`.

## Saldo disponible inicial

Durante onboarding:

```text
openingAvailableBalance > 0
→ crear Transaction(OPENING_BALANCE)

openingAvailableBalance == 0
→ no crear transacción de monto cero
```

`OPENING_BALANCE` usa la fecha local de confirmación, aumenta disponible y no participa en ingreso base ni 50/30/20.

Puede corregirse mientras no exista ningún otro movimiento financiero posterior. Después queda bloqueado.

## Regla de devolución por mes contable

### Gasto ordinario

```text
mismo mes de origin.date:
    nature = REIMBURSEMENT
    ingreso base += 0
    gasto efectivo del origen se reduce

mes posterior:
    nature = NEW_INCOME
    relatedTransactionId = origen
    ingreso base += amount
```

### Préstamo

```text
nature = LOAN_REPAYMENT siempre

mismo mes de origin.date:
    ingreso base += 0
    gasto efectivo del préstamo se reduce

mes posterior:
    ingreso base += amount
```

La naturaleza de `LOAN_REPAYMENT` no cambia porque sigue siendo un pago de la misma cuenta por cobrar; su tratamiento se deriva por relación de fechas.

La visualización semanal o anual no reclasifica retrospectivamente estas relaciones.

## Orden temporal de dependencias

Para devoluciones y pagos relacionados:

```text
dependent.date >= origin.date
```

No se permite registrar una devolución o pago con fecha financiera anterior a su origen.

## Saldos

### Saldo disponible

Representa dinero utilizable actual fuera de productos financieros. Contrato completo en `09-indicators-dashboard.md`.

### Saldo ahorrado total

```text
suma de saldos derivados de productos financieros
```

Bajo las reglas del MVP un producto sólo puede desactivarse con saldo actual cero, aunque conserve histórico.

### Dinero por cobrar

```text
suma de pendingAmount derivados de Receivable
```

## Invariantes centrales

1. `amount > 0`.
2. Los montos monetarios se persisten como enteros COP.
3. Nunca se persisten montos negativos para representar egresos.
4. `TransactionNature` determina el efecto contable; `TransactionDirection` no es suficiente por sí sola.
5. Una categoría modificada no altera el histórico.
6. El bloque almacenado en una transacción no cambia si cambia el default de la categoría.
7. `Category.defaultBucket` sólo puede ser `NEEDS` o `WANTS`.
8. Un retiro de ahorro nunca es ingreso base.
9. Un reintegro del mismo mes no es ingreso base.
10. Una devolución de gasto ordinario de mes posterior es `NEW_INCOME` relacionado.
11. Un pago de préstamo de mes posterior sí es ingreso base, pero conserva `LOAN_REPAYMENT`.
12. Un saldo inicial no es ingreso base.
13. Un producto financiero no puede quedar con saldo negativo.
14. Pagos activos acumulados no superan el préstamo original.
15. Reintegros/devoluciones activos acumulados no superan el gasto original.
16. Una transacción `VOIDED` no participa en saldos ni indicadores normales.
17. No se puede anular una transacción origen si existen dependencias activas que quedarían inválidas.
18. Un retiro de ahorro no reduce retroactivamente el indicador 20% del período.
19. Un rendimiento financiero puede aumentar ingreso base sin aumentar directamente disponible.
20. Un producto con saldo distinto de cero no puede desactivarse.
21. `FinancialProduct.openingBalance` no puede cambiar después de existir histórico financiero relacionado.
22. Una persona con saldo pendiente no puede desactivarse.
23. Categorías, productos y personas activos no duplican nombre normalizado dentro de su tipo.
24. Reactivar vuelve a validar las mismas invariantes que crear activo.
25. Desactivar una entidad maestra nunca reescribe ni elimina histórico.
26. `Receivable` y `ReceivablePayment` no duplican monto/fecha de sus transacciones fuente.
27. Un movimiento dependiente no puede tener fecha anterior a su origen.
28. El onboarding puede completarse con estado financiero inicial completamente en cero.
29. No se persiste `OPENING_BALANCE` con monto cero.
30. Las categorías seed se inicializan idempotentemente.
31. `onboardingCompleted` es explícito y la finalización del onboarding es atómica.

## Persistencia

Room/SQLite es la persistencia objetivo. El esquema físico v1, foreign keys, índices, converters, operaciones atómicas y consultas críticas están definidos en `14-room-sqlite-schema.md`.

No crear tablas/materializaciones adicionales para saldos o Dashboard sin una necesidad medida y una decisión documentada.

## Períodos

Objeto de dominio:

```text
PeriodRange(start, endInclusive)
```

- Semana: lunes a domingo.
- Mes: mes calendario.
- Año: año calendario.

Los agregados se calculan directamente sobre el rango; el año no promedia porcentajes mensuales.
