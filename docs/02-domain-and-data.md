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

Reglas de configuración:

- `name.trim()` no puede quedar vacío;
- no puede existir otra categoría activa con el mismo nombre normalizado;
- reactivar una categoría vuelve a validar unicidad;
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

Un retiro nunca puede producir saldo negativo.

Reglas de configuración:

- `openingBalance >= 0`;
- `openingBalance` no cuenta como ingreso base ni ahorro del período;
- `openingBalance` no afecta saldo disponible;
- `openingBalance` queda bloqueado después de existir cualquier movimiento financiero relacionado en el histórico;
- un producto sólo puede desactivarse si su saldo derivado actual es exactamente cero;
- un producto inactivo conserva histórico y puede reactivarse;
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

Reglas de configuración:

- `name.trim()` no puede quedar vacío;
- una persona sólo puede desactivarse cuando su saldo total pendiente por cobrar sea cero;
- desactivar conserva préstamos y pagos históricos;
- no puede existir otra persona activa con el mismo nombre normalizado;
- reactivar vuelve a validar unicidad.

## Normalización de nombres

Para validación de duplicados se usa una representación normalizada conceptual:

```text
normalizedName = trim + comparación case-insensitive
```

La capitalización original puede conservarse para presentación.

La unicidad condicionada por `active` es una regla de dominio/aplicación. El diseño Room puede apoyarla con índices cuando sea viable, pero no debe asumir que un índice SQL simple reemplaza todas las validaciones de crear/reactivar.

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

Un producto inactivo sólo puede existir con saldo actual cero bajo las reglas de Configuración del MVP, aunque su histórico siga participando en consultas pasadas.

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
7. `Category.defaultBucket` sólo puede ser `NEEDS` o `WANTS`.
8. Un retiro de ahorro nunca es ingreso base.
9. Un reintegro del mismo mes no es ingreso base.
10. Una devolución de préstamo en un mes posterior sí es ingreso base.
11. Un saldo inicial no es ingreso base.
12. Un producto financiero no puede quedar con saldo negativo.
13. Pagos acumulados de una cuenta por cobrar no superan su monto original.
14. Una transacción `VOIDED` no participa en saldos ni indicadores normales.
15. No se puede anular una transacción origen si existen dependencias activas que quedarían inválidas.
16. Un retiro de ahorro no reduce retroactivamente el indicador de aportes al 20% del período.
17. Un rendimiento financiero puede aumentar el ingreso base sin aumentar directamente el saldo disponible.
18. Un producto financiero con saldo actual distinto de cero no puede desactivarse.
19. `FinancialProduct.openingBalance` no puede cambiar después de existir histórico financiero relacionado.
20. Una persona con saldo pendiente por cobrar no puede desactivarse.
21. Categorías, productos y personas activos no pueden duplicar nombre normalizado dentro de su tipo.
22. Reactivar una entidad vuelve a validar las mismas invariantes que crearla activa.
23. Desactivar una entidad maestra nunca reescribe ni elimina histórico financiero.

## Persistencia

Se mantiene Room/SQLite como objetivo. El esquema definitivo se cerrará cuando terminemos los flujos de pantallas, para evitar congelar prematuramente una estructura incompleta.

Índices esperables:

- fecha financiera de transacción;
- naturaleza + fecha;
- bloque + fecha;
- `relatedTransactionId` cuando aplique;
- `personId` cuando aplique;
- `financialProductId` cuando aplique.

El diseño físico deberá considerar consultas para nombres normalizados/activos sin trasladar toda la lógica de negocio a restricciones SQL.

No crear índices adicionales sin una consulta concreta que los justifique.

## Períodos

Crear un objeto de dominio `PeriodRange(start, endInclusive)` para filtros Semana/Mes/Año.

- Semana: lunes a domingo.
- Mes: mes calendario.
- Año: año calendario.

Los agregados del período se calculan directamente sobre su rango; no se promedian porcentajes mensuales para construir el año.
