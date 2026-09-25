# 08 — Escenarios de dominio

Este documento fija ejemplos que deben poder convertirse en tests. Si una implementación produce un resultado distinto, debe revisarse contra estas reglas antes de modificar el comportamiento.

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

- Capital registrado: $1.000.000.
- Rendimiento explícito: $100.000.

Resultado:

- el rendimiento se registra como `FINANCIAL_RETURN`;
- aumenta el valor financiero correspondiente;
- aumenta el ingreso base en $100.000.

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
- estado: `PAID`.

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

- el pago conserva la naturaleza determinada por su relación mensual original;
- no se convierte en reintegro sólo porque préstamo y pago aparecen dentro del mismo rango anual.
