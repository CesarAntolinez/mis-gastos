# Presupuesto 50/30/20

Este documento define las fórmulas canónicas del presupuesto 50/30/20 de Mis Gastos. Cualquier implementación que muestre ingreso base, metas, uso de bloques o estados debe producir los mismos valores que se derivan de estas reglas.

La semántica de cada operación se describe en [`domain-rules.md`](./domain-rules.md); las decisiones arquitectónicas que las fundamentan están en [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md).

## 1. Períodos de visualización

Los indicadores de presupuesto pueden consultarse por:

- **Semana:** lunes a domingo, hora local.
- **Mes:** mes calendario.
- **Año:** 1 de enero a 31 de diciembre.

El mes calendario sigue siendo la unidad contable para clasificar retornos, aunque la visualización sea semanal o anual.

## 2. Regla de clasificación por mes calendario

La comparación entre una operación origen y su retorno usa exclusivamente mes y año calendario:

```text
mismoMesCalendario(d1, d2) =
    año(d1) == año(d2) AND mes(d1) == mes(d2)
```

Cambiar el período de visualización no reclasifica la operación. Por ejemplo, un préstamo de septiembre con un pago de octubre sigue siendo "mes posterior" aunque el dashboard muestre el año completo.

## 3. Ingreso base

Para un período `P`:

```text
baseIncome(P) =
    income dentro de P
  + financial_return dentro de P
  + loan_repayment dentro de P donde
      mismoMesCalendario(loan.date, repayment.date) == false
```

No participan:

- `opening_balance`;
- `transfer`;
- `saving_withdrawal`;
- `reimbursement` del mismo mes calendario del gasto original;
- `loan_repayment` dentro del mismo mes calendario del préstamo original.

Una devolución tardía de un gasto ordinario se registra como `income` vinculada al gasto original, y por tanto sí aumenta el ingreso base del mes en que se recibe.

Si `baseIncome(P) == 0`, los porcentajes del período se marcan como `NO_BASE` y no se muestran como `0%`.

## 4. Gasto efectivo por bloque

### 4.1 Orígenes de un bloque

Los orígenes de `NEEDS` y `WANTS` dentro de un período `P` son:

```text
bucketOrigins(P, bucket) =
    expense activas del bucket en P
  + loan activas del bucket en P
```

### 4.2 Reintegros del mismo mes calendario

Para cada origen, se consideran los retornos vinculados que ocurran en el mismo mes calendario del origen:

```text
linkedSameMonthRefunds(origin) =
    operaciones r activas donde
      r.kind IN {reimbursement, loan_repayment}
      AND r vinculada causalmente con origin
      AND r.date >= origin.date
      AND mismoMesCalendario(r.date, origin.date)
```

### 4.3 Gasto efectivo

```text
gross(P, bucket) = suma(bucketOrigins(P, bucket).monto)

refundTotal(P, bucket) =
    suma sobre origin en bucketOrigins(P, bucket) de
      min(
        suma(linkedSameMonthRefunds(origin).monto),
        origin.monto
      )

effectiveBucketExpense(P, bucket) = max(
  gross(P, bucket) - refundTotal(P, bucket),
  0
)
```

Implicaciones:

- El reintegro reduce el costo efectivo del gasto original, no genera un gasto negativo en la semana del reintegro.
- Los reintegros acumulados no superan el monto del origen.
- Un retorno de mes posterior no resta al gasto original; si es una devolución de gasto ordinario, se contabiliza como ingreso del nuevo período.

## 5. Necesidades — 50%

```text
needsAmount(P)       = effectiveBucketExpense(P, NEEDS)
needsTarget(P)       = baseIncome(P) * 50 / 100
needsIncomeShare     = (baseIncome(P) == 0) ? NO_BASE : needsAmount(P) / baseIncome(P) * 100
needsBudgetUse       = (baseIncome(P) == 0) ? NO_BASE : needsAmount(P) / needsTarget(P) * 100
needsRemaining(P)    = needsTarget(P) - needsAmount(P)
```

Estados según `needsBudgetUse`:

| Condición | Estado |
|---|---|
| `baseIncome(P) == 0` | `NO_BASE` |
| `< 80%` | `WITHIN` |
| `>= 80% y <= 100%` | `NEAR_LIMIT` |
| `> 100%` | `EXCEEDED` |

## 6. Deseos — 30%

```text
wantsAmount(P)       = effectiveBucketExpense(P, WANTS)
wantsTarget(P)       = baseIncome(P) * 30 / 100
wantsIncomeShare     = (baseIncome(P) == 0) ? NO_BASE : wantsAmount(P) / baseIncome(P) * 100
wantsBudgetUse       = (baseIncome(P) == 0) ? NO_BASE : wantsAmount(P) / wantsTarget(P) * 100
wantsRemaining(P)    = wantsTarget(P) - wantsAmount(P)
```

Estados según `wantsBudgetUse`:

| Condición | Estado |
|---|---|
| `baseIncome(P) == 0` | `NO_BASE` |
| `< 80%` | `WITHIN` |
| `>= 80% y <= 100%` | `NEAR_LIMIT` |
| `> 100%` | `EXCEEDED` |

## 7. Ahorro — 20%

El ahorro del período mide aportes propios realizados en ese período, no el saldo neto del producto:

```text
savingsContribution(P)  = suma(saving_contribution activas en P)
savingsTarget(P)        = baseIncome(P) * 20 / 100
savingsIncomeShare      = (baseIncome(P) == 0) ? NO_BASE : savingsContribution(P) / baseIncome(P) * 100
savingsTargetCompletion = (baseIncome(P) == 0) ? NO_BASE : savingsContribution(P) / savingsTarget(P) * 100
savingsMissing(P)       = savingsTarget(P) - savingsContribution(P)
```

Estados según `savingsTargetCompletion`:

| Condición | Estado |
|---|---|
| `baseIncome(P) == 0` | `NO_BASE` |
| `< 80%` | `IN_PROGRESS` |
| `>= 80% y < 100%` | `NEAR_TARGET` |
| `>= 100%` | `TARGET_MET` |

## 8. Agregados anuales

Para la vista anual los valores se calculan sobre los totales del año completo. No se promedian porcentajes mensuales.

```text
baseIncome(Año)       = suma de baseIncome de cada mes del año
needsAmount(Año)      = suma de needsAmount de cada mes del año
needsTarget(Año)      = baseIncome(Año) * 50 / 100
savingsContribution(Año) = suma de savingsContribution de cada mes del año
```

## 9. Ejemplos de referencia

### 9.1 Reintegro en otra semana del mismo mes

- 2 de septiembre: gasto Salud `NEEDS` $200.000.
- 20 de septiembre: reintegro vinculado $50.000.

Resultado:

- `needsAmount(septiembre) = $150.000`;
- la semana del 20 de septiembre no muestra `-$50.000` como gasto del bucket;
- el reintegro no aumenta ingreso base.

### 9.2 Devolución tardía de gasto ordinario

- 20 de septiembre: gasto Ropa `WANTS` $200.000.
- 3 de octubre: devolución vinculada $50.000.

Resultado:

- el gasto de septiembre no se reduce retroactivamente;
- octubre recibe `income` de $50.000, vinculado al gasto original;
- `baseIncome(octubre)` aumenta $50.000.

### 9.3 Préstamo con pago cruzando meses

- 20 de septiembre: préstamo `LOAN` $200.000 clasificado `WANTS`.
- 28 de septiembre: pago $50.000.
- 3 de octubre: pago $150.000.

Resultado:

- septiembre: pago de $50.000 es reintegro del mismo mes; `wantsAmount(septiembre) = $150.000`; ingreso base adicional $0.
- octubre: pago de $150.000 aumenta `baseIncome(octubre)` en $150.000; `wantsAmount(octubre)` no se reduce.

### 9.4 Retiro de ahorro no destruye el cumplimiento

- ingreso base del mes: $4.000.000;
- aporte a ahorro: $1.000.000;
- retiro de ahorro: $600.000.

Resultado:

- `savingsTarget = $800.000`;
- `savingsContribution = $1.000.000`;
- `savingsTargetCompletion = 125%`;
- el retiro aumenta disponible pero no reduce el ahorro registrado del período.

### 9.5 Dashboard mensual de referencia

Datos:

- ingreso base: $5.000.000;
- necesidades efectivas: $2.200.000;
- deseos efectivos: $1.600.000;
- aportes a ahorro: $800.000.

Necesidades:

- objetivo: $2.500.000;
- participación del ingreso: 44%;
- uso del presupuesto: 88%;
- restante: $300.000;
- estado: `NEAR_LIMIT`.

Deseos:

- objetivo: $1.500.000;
- participación del ingreso: 32%;
- uso del presupuesto: 106,67%;
- exceso: $100.000;
- estado: `EXCEEDED`.

Ahorro:

- objetivo: $1.000.000;
- participación del ingreso: 16%;
- cumplimiento: 80%;
- faltante: $200.000;
- estado: `NEAR_TARGET`.
