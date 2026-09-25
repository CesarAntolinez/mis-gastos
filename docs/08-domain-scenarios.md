# 08 — Escenarios de dominio

Este documento fija ejemplos que deben poder convertirse en tests. Si una implementación produce un resultado distinto, debe revisarse contra estas reglas antes de modificar el comportamiento.

Las fórmulas canónicas de indicadores están en [`09-indicators-dashboard.md`](./09-indicators-dashboard.md).

## Escenario 1 — Ingreso nuevo

- Nómina: +$5.000.000.
- Naturaleza: `NEW_INCOME`.

Resultado:

- disponible +$5.000.000;
- ingreso base +$5.000.000.

## Escenario 2 — Aporte a ahorro

- Disponible actual: $5.000.000.
- Aporte a Fondo de emergencia: $1.000.000.

Resultado:

- disponible: $4.000.000;
- producto financiero: +$1.000.000;
- bloque 20%: +$1.000.000;
- ingreso base: sin cambio.

## Escenario 3 — Retiro de ahorro en otro mes

Agosto:
- saldo de ahorro acumulado: $1.300.000.

Septiembre:
- retiro: $1.000.000.

Resultado septiembre:

- disponible +$1.000.000;
- ahorro -$1.000.000;
- ingreso base +$0.

El hecho de que el dinero se hubiera ahorrado en otro mes no transforma el retiro en ingreso nuevo.

## Escenario 4 — Rendimiento financiero

- Saldo producto: $1.000.000.
- Rendimiento explícito: $100.000.

Resultado:

- `FINANCIAL_RETURN` aumenta el producto a $1.100.000;
- ingreso base +$100.000;
- saldo disponible no cambia directamente.

## Escenario 5 — Préstamo y devolución en el mismo mes

15 de septiembre:
- préstamo a Juan: $200.000.

22 de septiembre:
- Juan devuelve $80.000.

Resultado:

- el préstamo origina una cuenta por cobrar de $200.000;
- el pago reduce el pendiente a $120.000;
- el pago aumenta disponible $80.000;
- el pago no aumenta ingreso base;
- se trata como reintegro del mismo mes.

## Escenario 6 — Préstamo y devolución en otro mes

20 de septiembre:
- préstamo a Ana: $200.000.

3 de octubre:
- Ana devuelve $50.000.

Resultado octubre:

- disponible +$50.000;
- cuenta por cobrar pendiente: $150.000;
- ingreso base de octubre +$50.000;
- se conserva relación con el préstamo de septiembre.

## Escenario 7 — Pagos parciales cruzando meses

20 de septiembre:
- préstamo: $200.000.

28 de septiembre:
- pago: $50.000.

3 de octubre:
- pago: $150.000.

Resultado:

- pago de septiembre: reintegro, no ingreso base;
- pago de octubre: ingreso base de octubre;
- pendiente final: $0;
- estado derivado: `PAID`.

## Escenario 8 — Categoría reclasificada por transacción

Categoría `Ropa`:
- bloque por defecto: `WANTS`.

Transacción:
- monto: $250.000;
- categoría: Ropa;
- bloque elegido: `NEEDS`;
- concepto: zapatos obligatorios para el trabajo.

Resultado:

- la transacción queda en `NEEDS`;
- la categoría `Ropa` sigue teniendo `WANTS` como default;
- otras transacciones no cambian.

## Escenario 9 — Cambio futuro de categoría

Enero:
- `Ropa` default = `WANTS`;
- transacción A = `WANTS`.

Febrero:
- se cambia `Ropa` default = `NEEDS`.

Resultado:

- transacción A permanece `WANTS`;
- nuevas transacciones de Ropa proponen `NEEDS`.

## Escenario 10 — Saldo inicial

Al instalar:
- saldo disponible inicial: $2.350.000;
- saldo inicial Fondo de emergencia: $3.000.000.

Resultado:

- disponible inicial = $2.350.000;
- ahorro inicial = $3.000.000;
- ingreso base = $0.

## Escenario 11 — Retiro mayor que el aporte del mes

Saldo de ahorro previo: $3.000.000.
Aporte del mes: $500.000.
Retiro del mes: $2.000.000.

Resultado:

- retiro válido porque existe saldo suficiente;
- bloque 20% del mes refleja el aporte de $500.000;
- retiro no borra ni reduce retroactivamente el comportamiento de ahorro registrado para el 20%;
- saldo financiero final = $1.500.000.

## Escenario 12 — Sobrepago rechazado

Préstamo original: $100.000.
Pagos registrados: $80.000.
Nuevo pago solicitado: $30.000.

Resultado:

- operación rechazada;
- pendiente permanece $20.000;
- no se crea transacción parcial de $30.000.

## Escenario 13 — Anulación con dependencias

Préstamo original: $200.000.
Pago activo relacionado: $50.000.

Se intenta anular el préstamo.

Resultado:

- operación bloqueada mientras el pago relacionado siga activo o no exista un flujo explícito que resuelva todas las dependencias de forma consistente.

## Escenario 14 — Consulta anual no reclasifica

Préstamo: septiembre.
Pago: octubre.

Al consultar el año completo:

- el pago conserva `LOAN_REPAYMENT`;
- su tratamiento de ingreso sigue determinado por la relación entre los meses de origen y pago;
- no se convierte en reintegro sólo porque préstamo y pago aparecen dentro del mismo rango anual.

## Escenario 15 — Dashboard mensual 50/30/20

Datos:

- ingreso base: $5.000.000;
- Necesidades efectivas: $2.200.000;
- Deseos efectivos: $1.600.000;
- aportes a ahorro: $800.000.

Resultado Necesidades:

- objetivo: $2.500.000;
- 44% del ingreso;
- 88% del presupuesto;
- $300.000 restantes;
- estado `NEAR_LIMIT`.

Resultado Deseos:

- objetivo: $1.500.000;
- 32% del ingreso;
- 106,67% del presupuesto;
- $100.000 de exceso;
- estado `EXCEEDED`.

Resultado Ahorro:

- objetivo: $1.000.000;
- 16% del ingreso;
- 80% de cumplimiento;
- faltan $200.000;
- estado `NEAR_TARGET`.

## Escenario 16 — Retiro no reduce el cumplimiento de ahorro

Datos del mes:

- ingreso base: $4.000.000;
- aporte a ahorro: $1.000.000;
- retiro de ahorro: $600.000.

Resultado:

- objetivo 20%: $800.000;
- ahorro del período: $1.000.000;
- cumplimiento: 125%;
- cambio neto del producto por estas operaciones: +$400.000;
- el retiro no reduce el cumplimiento del período.

## Escenario 17 — Reintegro en otra semana del mismo mes

2 de septiembre:
- gasto Salud `NEEDS`: $200.000.

20 de septiembre:
- reintegro relacionado: $50.000.

Resultado de indicadores:

- costo efectivo del gasto original: $150.000;
- la semana de devolución no muestra `-$50.000` como gasto del bucket;
- el reintegro no aumenta ingreso base.

Resultado de historial:

- el gasto aparece el 2 de septiembre;
- la entrada de reintegro aparece el 20 de septiembre.

Persistencia del reintegro:

```text
nature = REIMBURSEMENT
relatedTransactionId = gasto del 2 de septiembre
```

## Escenario 18 — Disponible actual no cambia al navegar historial

Saldo disponible actual: $2.350.000.

La persona cambia Dashboard de septiembre a agosto.

Resultado:

- `Disponible actual` sigue mostrando $2.350.000;
- ingreso base y 50/30/20 cambian al rango de agosto.

## Escenario 19 — Flujo de caja no equivale a ingreso base

Durante octubre:

- nómina `NEW_INCOME`: +$3.000.000;
- retiro de ahorro: +$500.000.

Resultado:

- `periodCashIn = $3.500.000`;
- `baseIncome = $3.000.000`.

El retiro de ahorro aumenta efectivo disponible, pero no la base 50/30/20.

## Escenario 20 — Cálculo anual directo

Ingresos base:

- enero: $1.000.000;
- febrero: $3.000.000.

Necesidades:

- enero: $600.000;
- febrero: $900.000.

Resultado anual:

- ingreso base anual: $4.000.000;
- objetivo Necesidades anual: $2.000.000;
- Necesidades reales: $1.500.000;
- uso del presupuesto anual: 75%.

No se usa el promedio simple de los porcentajes mensuales.

## Escenario 21 — Devolución tardía de gasto ordinario

20 de septiembre:
- gasto Ropa `WANTS`: $200.000.

3 de octubre:
- comercio devuelve $50.000 asociados a ese gasto.

Resultado:

- disponible de octubre +$50.000;
- ingreso base de octubre +$50.000;
- el gasto de septiembre no se reduce retroactivamente;
- se conserva relación con el gasto original.

Persistencia de la devolución:

```text
nature = NEW_INCOME
relatedTransactionId = gasto del 20 de septiembre
```

No se persiste como `REIMBURSEMENT` porque ocurrió en un mes calendario posterior.

## Escenario 22 — Movimiento dependiente con fecha anterior rechazado

20 de septiembre:
- préstamo a Juan: $100.000.

Se intenta registrar un pago relacionado con fecha 15 de septiembre.

Resultado:

- operación rechazada;
- no se crea `LOAN_REPAYMENT`;
- no se crea `ReceivablePayment`;
- pendiente permanece $100.000.

La misma regla aplica a una devolución de gasto ordinario con fecha anterior al gasto origen.

## Escenario 23 — Cuenta por cobrar deriva sus montos de transacciones

Préstamo activo:

```text
LOAN = $200.000
```

Pagos activos:

```text
LOAN_REPAYMENT = $50.000
LOAN_REPAYMENT = $30.000
```

Resultado derivado:

```text
originalAmount = $200.000
paidAmount     = $80.000
pendingAmount  = $120.000
status         = PENDING
```

`Receivable` no almacena una segunda copia de `$200.000` ni del pendiente.
