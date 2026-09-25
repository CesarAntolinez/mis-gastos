# 02 — Dominio y datos

## Principio

`Transaction` es la fuente de verdad de los movimientos financieros. Préstamos, pagos, ahorro, retiros y rendimientos deben estar respaldados por transacciones; las entidades auxiliares aportan contexto y estado de dominio.

Las fórmulas visibles del Dashboard se definen en [`09-indicators-dashboard.md`](./09-indicators-dashboard.md). Este documento define entidades e invariantes, pero no debe duplicar esas fórmulas.

## Transaction

Campos propuestos:

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

Naturalezas previstas hasta este punto:

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

- `NEW_INCOME`: aumenta disponible e ingreso base.
- `SAVING`: disminuye disponible y aumenta un producto financiero.
- `SAVING_WITHDRAWAL`: disminuye un producto y aumenta disponible; no aumenta ingreso base.
- `FINANCIAL_RETURN`: aumenta el producto financiero y el ingreso base, pero no el disponible directamente.
- `LOAN`: disminuye disponible y crea una cuenta por cobrar.
- `LOAN_REPAYMENT`: aumenta disponible y reduce la cuenta por cobrar; su efecto en ingreso base depende del mes original.

### TransactionStatus

- `ACTIVE`
- `VOIDED`

Una transacción anulada permanece persistida pero no participa en cálculos financieros normales.

## BudgetBucket

- `NEEDS` — meta 50%
- `WANTS` — meta 30%
- `SAVINGS` — meta 20%

El bloque persistido en la transacción es la fuente de verdad histórica.

## Category

Campos:

- `id: Long`
- `name: String`
- `defaultBucket: BudgetBucket`
- `active: Boolean`
- `createdAt: Instant`
- `updatedAt: Instant`

La categoría propone un bloque por defecto, pero la transacción puede sobrescribirlo.

Cambiar `defaultBucket` no modifica transacciones existentes.

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

Un retiro nunca puede producir saldo negativo.

## Person

Campos:

- `id: Long`
- `name: String`
- `active: Boolean`
- `createdAt: Instant`
- `updatedAt: Instant`

No es una agenda de contactos. Sólo identifica personas relacionadas con cuentas por cobrar.

## Receivable

Campos:

- `id: Long`
- `personId: Long`
- `originTransactionId: Long`
- `originalAmount: Long`
- `date: LocalDate`
- `concept: String?`
- `status: ReceivableStatus`
- `createdAt: Instant`
- `updatedAt: Instant`

### ReceivableStatus

- `PENDING`
- `PAID`

## ReceivablePayment

Campos:

- `id: Long`
- `receivableId: Long`
- `transactionId: Long`
- `amount: Long`
- `date: LocalDate`
- `createdAt: Instant`

Saldo pendiente:

```text
originalAmount - suma(pagos activos)
```

Los pagos parciales son válidos. La suma de pagos activos no puede superar `originalAmount`.

## Ingreso base 50/30/20

No toda entrada de dinero es ingreso computable.

Aumentan ingreso base:

- `NEW_INCOME`.
- `FINANCIAL_RETURN`.
- devolución de préstamo recibida en un mes posterior al préstamo original.

No aumentan ingreso base:

- `OPENING_BALANCE`.
- `SAVING_WITHDRAWAL`.
- `REIMBURSEMENT` del mismo mes.

La fórmula canónica se encuentra en `09-indicators-dashboard.md`.

## Regla de reintegro por mes contable

Para una devolución asociada a una salida anterior:

```text
si month(payment.date) == month(origin.date) y year coincide:
    naturaleza contable = REIMBURSEMENT
    ingreso base += 0
    gasto efectivo del origen se reduce
si el pago ocurre en un mes posterior:
    se considera ingreso del nuevo período
    ingreso base += amount
```

Esta regla no se aplica a retiros de productos financieros.

La visualización semanal o anual no reclasifica retrospectivamente estas relaciones.

## Saldos

### Saldo disponible

Representa el dinero utilizable actual fuera de productos financieros. Su contrato completo está en `09-indicators-dashboard.md`.

### Saldo ahorrado total

```text
suma de saldos derivados de productos financieros activos e inactivos
```

Desactivar un producto sólo evita nuevas operaciones; no elimina su saldo ni histórico.

### Dinero por cobrar

```text
suma de saldos pendientes de Receivable activos
```

## Invariantes centrales

1. `amount > 0`.
2. Los montos monetarios se persisten como enteros COP.
3. Nunca se persisten montos negativos para representar egresos.
4. `TransactionNature` determina el efecto contable; `TransactionDirection` no es suficiente por sí sola.
5. Una categoría modificada no altera el histórico.
6. El bloque almacenado en una transacción no cambia si cambia el default de la categoría.
7. Un retiro de ahorro nunca es ingreso base.
8. Un reintegro del mismo mes no es ingreso base.
9. Una devolución de préstamo en un mes posterior sí es ingreso base.
10. Un saldo inicial no es ingreso base.
11. Un producto financiero no puede quedar con saldo negativo.
12. Pagos acumulados de una cuenta por cobrar no superan su monto original.
13. Una transacción `VOIDED` no participa en saldos ni indicadores normales.
14. No se puede anular una transacción origen si existen dependencias activas que quedarían inválidas.
15. Un retiro de ahorro no reduce retroactivamente el indicador de aportes al 20% del período.
16. Un rendimiento financiero puede aumentar el ingreso base sin aumentar directamente el saldo disponible.

## Persistencia

Se mantiene Room/SQLite como objetivo. El esquema definitivo se cerrará cuando terminemos los flujos de pantallas, para evitar congelar prematuramente una estructura incompleta.

Índices esperables:

- fecha financiera de transacción;
- naturaleza + fecha;
- bloque + fecha;
- `relatedTransactionId` cuando aplique;
- `personId` cuando aplique;
- `financialProductId` cuando aplique.

No crear índices adicionales sin una consulta concreta que los justifique.

## Períodos

Crear un objeto de dominio `PeriodRange(start, endInclusive)` para filtros Semana/Mes/Año.

- Semana: lunes a domingo.
- Mes: mes calendario.
- Año: año calendario.

Los agregados del período se calculan directamente sobre su rango; no se promedian porcentajes mensuales para construir el año.
