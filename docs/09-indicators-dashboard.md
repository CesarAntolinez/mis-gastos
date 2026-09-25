# 09 — Indicadores y Dashboard

Este documento es la fuente de verdad para las fórmulas financieras visibles en Resumen. Si una consulta Room, caso de uso, ViewModel o componente UI produce un valor diferente, debe revisarse contra este contrato.

## 1. Separación conceptual

Los indicadores se dividen en dos grupos.

### Estado financiero actual

No cambia al navegar entre Semana/Mes/Año históricos:

- saldo disponible;
- saldo total ahorrado;
- dinero por cobrar.

Estos valores representan el estado actual derivado de todos los movimientos activos hasta hoy.

### Rendimiento del período

Sí depende del `PeriodRange` seleccionado:

- ingreso base 50/30/20;
- entradas y salidas del período;
- Necesidades 50%;
- Deseos 30%;
- Ahorro 20%;
- objetivos, uso/cumplimiento y diferencias.

Cambiar de septiembre a agosto no debe hacer parecer que el saldo disponible actual cambió.

## 2. Regla de efecto por naturaleza

`TransactionDirection` no determina por sí sola qué saldo cambia. `TransactionNature` determina el efecto contable.

Ejemplos:

- `NEW_INCOME`: aumenta disponible y puede aumentar ingreso base.
- `EXPENSE`: disminuye disponible.
- `SAVING`: disminuye disponible y aumenta un producto financiero.
- `SAVING_WITHDRAWAL`: disminuye un producto financiero y aumenta disponible.
- `FINANCIAL_RETURN`: aumenta el producto financiero y el ingreso base; no aumenta disponible hasta que exista un retiro.
- `LOAN`: disminuye disponible y crea/aumenta una cuenta por cobrar.
- `LOAN_REPAYMENT`: aumenta disponible y reduce una cuenta por cobrar; su participación en ingreso base depende del mes del préstamo original.
- `OPENING_BALANCE`: establece una base de saldo sin constituir ingreso base.

La lógica de efecto debe estar centralizada en dominio; no duplicarla en UI o DAO.

## 3. Saldo disponible actual

Representa dinero utilizable fuera de productos financieros.

Conceptualmente:

```text
availableBalance =
    openingAvailableBalance
    + NEW_INCOME que afecta disponible
    + SAVING_WITHDRAWAL
    + REIMBURSEMENT
    + LOAN_REPAYMENT
    - EXPENSE
    - LOAN
    - SAVING
```

Sólo participan transacciones `ACTIVE` con fecha financiera hasta hoy.

`FINANCIAL_RETURN` no aumenta disponible directamente.

## 4. Saldo total ahorrado

Para cada producto financiero:

```text
productBalance =
    openingBalance
    + SAVING aportado al producto
    + FINANCIAL_RETURN del producto
    - SAVING_WITHDRAWAL del producto
```

Luego:

```text
totalSavedBalance = sum(productBalance)
```

Un producto inactivo conserva saldo e histórico. No puede quedar con saldo negativo.

## 5. Dinero por cobrar

Para cada cuenta por cobrar:

```text
pendingReceivable = originalAmount - sum(activePayments)
```

Total:

```text
totalReceivable = sum(pendingReceivable donde pendingReceivable > 0)
```

Los movimientos anulados no participan.

## 6. Ingreso base 50/30/20

Para un período `P`:

```text
baseIncome(P) =
    NEW_INCOME dentro de P
    + FINANCIAL_RETURN dentro de P
    + LOAN_REPAYMENT dentro de P cuyo préstamo original ocurrió en un mes calendario anterior
```

No participan:

- `OPENING_BALANCE`;
- `SAVING_WITHDRAWAL`;
- reintegros del mismo mes;
- devolución de préstamo recibida dentro del mismo mes calendario del préstamo original.

La naturaleza histórica de una devolución se determina comparando el mes/año de origen y pago. Cambiar la visualización a Semana o Año no reclasifica el movimiento.

## 7. Gasto efectivo por bloque

Para `NEEDS` y `WANTS`, el gasto efectivo debe reflejar reintegros válidos del mismo mes asociados al egreso original.

```text
effectiveBucketExpense(P, bucket) =
    sum(active expense origins del bucket relevantes para P)
    - sum(active same-month reimbursements relacionados con esos orígenes)
```

Un reintegro corrige el costo efectivo del gasto original para indicadores. En historial conserva su fecha real como entrada de dinero.

### Regla semanal importante

Si un gasto ocurre el 2 de septiembre y su reintegro el 20 de septiembre, ambos del mismo mes, el indicador del gasto original refleja su costo neto aunque el reintegro haya ocurrido en otra semana. El historial sí muestra ambos movimientos en sus fechas reales.

Esto evita semanas con gastos negativos artificiales.

## 8. Necesidades — 50%

```text
needsAmount(P) = effectiveBucketExpense(P, NEEDS)
needsTarget(P) = baseIncome(P) * 0.50
needsIncomeShare = needsAmount / baseIncome * 100
needsBudgetUse = needsAmount / needsTarget * 100
needsRemaining = needsTarget - needsAmount
```

Si `baseIncome == 0`, los porcentajes son `NO_BASE` y no deben mostrarse como `0%`.

Estados según `needsBudgetUse`:

- `< 80%`: `WITHIN`;
- `>= 80% y <= 100%`: `NEAR_LIMIT`;
- `> 100%`: `EXCEEDED`;
- sin base: `NO_BASE`.

## 9. Deseos — 30%

```text
wantsAmount(P) = effectiveBucketExpense(P, WANTS)
wantsTarget(P) = baseIncome(P) * 0.30
wantsIncomeShare = wantsAmount / baseIncome * 100
wantsBudgetUse = wantsAmount / wantsTarget * 100
wantsRemaining = wantsTarget - wantsAmount
```

Estados:

- `< 80%`: `WITHIN`;
- `>= 80% y <= 100%`: `NEAR_LIMIT`;
- `> 100%`: `EXCEEDED`;
- sin base: `NO_BASE`.

## 10. Ahorro — 20%

El comportamiento de ahorro del período mide aportes realizados, no el saldo neto del producto.

```text
savingsContribution(P) = sum(active SAVING dentro de P)
savingsTarget(P) = baseIncome(P) * 0.20
savingsIncomeShare = savingsContribution / baseIncome * 100
savingsTargetCompletion = savingsContribution / savingsTarget * 100
savingsMissing = savingsTarget - savingsContribution
```

Los `SAVING_WITHDRAWAL` no restan `savingsContribution`.

Estados según `savingsTargetCompletion`:

- `< 80%`: `IN_PROGRESS`;
- `>= 80% y < 100%`: `NEAR_TARGET`;
- `>= 100%`: `TARGET_MET`;
- sin base: `NO_BASE`.

`Ahorro del período` y `Saldo total ahorrado` son métricas distintas.

## 11. Entradas, salidas y balance de flujo del período

Para transparencia del historial puede mostrarse un resumen de flujo:

```text
periodCashIn = sum(movimientos activos dentro de P que aumentan disponible)
periodCashOut = sum(movimientos activos dentro de P que disminuyen disponible)
periodCashFlow = periodCashIn - periodCashOut
```

Estas métricas no sustituyen `baseIncome`.

Ejemplo: un retiro de ahorro aumenta `periodCashIn`, pero no `baseIncome`.

## 12. Cálculo por Semana, Mes y Año

Los objetivos siempre se calculan sobre el período seleccionado:

```text
needsTarget = baseIncome(P) * 50%
wantsTarget = baseIncome(P) * 30%
savingsTarget = baseIncome(P) * 20%
```

Para Año se usan directamente los totales del año. No se promedian porcentajes mensuales.

Para Semana se usan directamente los totales de la semana, respetando que la clasificación reintegro/ingreso ya fue determinada por la relación mensual de origen y pago.

## 13. Escenario de referencia — dashboard mensual

Período:

```text
Ingreso base              $5.000.000
Necesidades efectivas     $2.200.000
Deseos efectivos          $1.600.000
Aportes a ahorro            $800.000
```

Resultado Necesidades:

```text
Objetivo                  $2.500.000
Participación ingreso            44%
Uso presupuesto                  88%
Restante                    $300.000
Estado                    NEAR_LIMIT
```

Resultado Deseos:

```text
Objetivo                  $1.500.000
Participación ingreso            32%
Uso presupuesto              106,67%
Exceso                       $100.000
Estado                     EXCEEDED
```

Resultado Ahorro:

```text
Objetivo                  $1.000.000
Participación ingreso            16%
Cumplimiento meta                80%
Faltante                     $200.000
Estado                   NEAR_TARGET
```

## 14. Escenario — retiro no destruye ahorro del período

```text
Ingreso nuevo              $4.000.000
Aporte a ahorro            $1.000.000
Retiro de ahorro             $600.000
```

Resultado:

```text
baseIncome                 $4.000.000
savingsTarget                $800.000
savingsContribution        $1.000.000
savingsTargetCompletion          125%
impacto neto producto        +$400.000
```

El retiro aumenta disponible pero no reduce el cumplimiento 20% del período.

## 15. Escenario — pago parcial de préstamo cruzando meses

Septiembre:

```text
Préstamo                     $500.000
Pago recibido mismo mes      $200.000
```

Resultado septiembre:

```text
pendiente                    $300.000
pago de $200.000 = reintegro
baseIncome adicional                $0
```

Octubre:

```text
Pago restante                $300.000
```

Resultado octubre:

```text
pendiente                          $0
baseIncome adicional          $300.000
```

## 16. Escenario — rendimiento financiero

```text
Saldo producto inicial       $2.000.000
Rendimiento                    $100.000
```

Resultado:

```text
saldo producto               $2.100.000
baseIncome                   +$100.000
saldo disponible              sin cambio
```

## 17. Presentación recomendada del Dashboard

Orden conceptual:

```text
[Período]               [Semana | Mes | Año]

Disponible actual
$X

Ingreso base del período
$Y

Necesidades · 50%
actual / objetivo
uso del presupuesto
participación del ingreso
restante o exceso
estado textual

Deseos · 30%
...

Ahorro · 20%
aportado / objetivo
cumplimiento
participación del ingreso
faltante o superación
estado textual

Patrimonio relacionado
- Ahorrado actual
- Por cobrar actual

Últimos movimientos
```

Los estados nunca deben comunicarse sólo mediante color.

## 18. Redondeo y formato

- Dinero persistido en enteros COP.
- Objetivos monetarios deben resolverse sin `Float`/`Double` monetario.
- Los porcentajes pueden representarse con precisión decimal de dominio y formatearse para UI.
- La UI puede mostrar porcentajes enteros cuando sea suficiente y hasta dos decimales cuando el valor aporte claridad.
- El cálculo interno no debe depender del texto formateado.

## 19. Reglas de implementación

- Una sola capa de dominio produce estos agregados.
- DAO puede optimizar sumas, pero no reinterpretar reglas de negocio.
- ViewModel no replica fórmulas.
- UI sólo presenta valores y estados calculados.
- Cada fórmula y caso límite debe tener test unitario.
- Consultas Room críticas deben tener tests de integración con conjuntos de datos que incluyan movimientos anulados y relaciones entre meses.
