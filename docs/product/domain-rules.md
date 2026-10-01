# Reglas de dominio

Este documento registra la semántica financiera canónica de Mis Gastos. Las implementaciones deben preservar estas reglas. Si una feature requiere cambiarlas, el cambio debe documentarse explícitamente antes de modificar código.

La fuente de verdad arquitectónica subyacente es [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md). Este documento expresa esas decisiones en términos de producto, sin reproducir detalles de persistencia específicos de tecnologías anteriores.

## 1. Conceptos principales

### Operación financiera

Representa qué ocurrió en el mundo real: un ingreso, un gasto, un traslado entre productos propios, un reintegro, un préstamo, un pago recibido, un aporte a ahorro, un retiro, un rendimiento o un saldo inicial. El tipo de operación es la fuente de verdad semántica; su efecto sobre saldos se deriva de ese tipo.

### Entrada contable

Representa cómo una operación impacta una cuenta específica (por ejemplo, disponible o un producto financiero). La dirección de una entrada por sí sola no decide si el evento es un ingreso, un traslado o un reintegro.

### Gasto

Salida de dinero destinada a consumo, pago u otra finalidad que reduce el disponible correspondiente. Un préstamo a terceros también se registra como una salida de disponible, pero genera una cuenta por cobrar.

### Ingreso

Entrada de dinero que incrementa la base disponible y representa dinero nuevo para el período según las reglas del producto. Debe conservarse su origen cuando sea conocido.

### Reintegro o retorno

Dinero que regresa como consecuencia de una salida previa. Cuando el retorno ocurre en el mismo mes calendario del origen, no es ingreso nuevo: restaura dinero previamente salido o reduce el costo efectivo del gasto original. Cuando ocurre en un mes calendario posterior, se reconoce como ingreso computable del nuevo período.

### Movimiento interno

Traslado de dinero entre productos o ubicaciones financieras pertenecientes al usuario. Por sí solo no crea ingreso ni gasto económico; cambia dónde se encuentra el dinero.

### Deuda a favor del usuario

Dinero que otra persona debe al usuario, derivado de una operación `loan` y de los pagos vinculados. No se almacena un saldo pendiente mutable; se calcula como monto original menos pagos activos.

## 2. Moneda y representación de montos

- Moneda única: COP.
- Todos los montos operativos se almacenan como enteros exactos de peso colombiano.
- No se usa `Float` ni `Double` para representar dinero en persistencia ni en lógica de dominio.
- El MVP no incluye conversión de divisas.

## 3. Tipos de operación y significado de producto

| Tipo de operación | Significado de producto | Impacto típico en cuentas | Afecta ingreso base | Bloque |
|---|---|---|---|---|
| `income` | Ingreso nuevo. Una devolución tardía de un gasto ordinario también se registra como `income`, vinculada al gasto original. | Disponible `in` | Sí | N/A |
| `expense` | Gasto ordinario. | Disponible `out` | No | NEEDS / WANTS |
| `transfer` | Traslado entre cuentas propias. | `out` de A, `in` a B | No | N/A |
| `reimbursement` | Devolución de un gasto ordinario recibida en el **mismo** mes calendario del gasto original. | Disponible `in` | No | Reduce gasto efectivo del origen |
| `saving_contribution` | Aporte propio a un producto financiero. | Disponible `out`, producto `in` | No | SAVINGS |
| `saving_withdrawal` | Retiro desde un producto financiero al disponible. | Producto `out`, disponible `in` | No | N/A |
| `financial_return` | Rendimiento generado dentro de un producto financiero. | Producto `in` | Sí | N/A |
| `loan` | Dinero prestado a un tercero. | Disponible `out` | No | NEEDS / WANTS |
| `loan_repayment` | Pago recibido de un deudor. | Disponible `in` | Sí si es mes posterior al préstamo | Reduce gasto efectivo del origen si es mismo mes |
| `opening_balance` | Saldo disponible inicial al onboarding, solo cuando es mayor que cero. | Disponible `in` | No | N/A |

El tipo histórico se determina en el momento de crear la operación y no cambia por modificar la categoría o el período mostrado.

## 4. Bloques históricos 50/30/20

Los bloques presupuestales son:

- `NEEDS` — meta 50%.
- `WANTS` — meta 30%.
- `SAVINGS` — meta 20%.

Reglas de asignación:

- Una categoría ordinaria solo puede proponer `NEEDS` o `WANTS`; nunca `SAVINGS`.
- El bloque `SAVINGS` se reserva para operaciones de aporte a productos financieros (`saving_contribution`).
- Un préstamo (`loan`) se clasifica en `NEEDS` o `WANTS` según su motivo; nunca en `SAVINGS`.
- El bloque almacenado en la operación es la verdad histórica. Cambiar el bloque por defecto de una categoría solo afecta operaciones nuevas.

## 5. Ingreso base

El ingreso base de un período `P` se usa para calcular las metas 50/30/20. Sus fórmulas exactas están en [`budgeting.md`](./budgeting.md).

En resumen, aumentan el ingreso base:

- ingresos (`income`) en `P`, incluyendo devoluciones tardías de gastos ordinarios;
- rendimientos financieros (`financial_return`) en `P`;
- pagos de préstamo (`loan_repayment`) en `P` cuando el préstamo original ocurrió en un mes calendario anterior.

No aumentan el ingreso base:

- saldos iniciales (`opening_balance`);
- traslados internos (`transfer`);
- retiros de ahorro (`saving_withdrawal`);
- reintegros del mismo mes calendario (`reimbursement`);
- pagos de préstamo recibidos dentro del mismo mes calendario del préstamo original.

La comparación "mismo mes / mes posterior" siempre usa mes y año calendario de las operaciones origen y retorno, independientemente del período de visualización seleccionado.

## 6. Gasto efectivo por bloque

Para `NEEDS` y `WANTS`, el gasto efectivo se calcula restando a las operaciones de origen del período los reintegros o pagos del **mismo mes calendario** vinculados a esos orígenes. El resultado nunca es negativo. La fórmula completa y los ejemplos están en [`budgeting.md`](./budgeting.md).

Implicaciones:

- Un reintegro recibido en otra semana del mismo mes calendario sigue reduciendo el costo efectivo del gasto original; no genera un gasto negativo en la semana del reintegro.
- Un retorno recibido en un mes calendario posterior no reduce el gasto original; si es una devolución de gasto ordinario, se trata como ingreso del nuevo período.
- Los reintegros y pagos acumulados no pueden superar el monto del origen.

## 7. Ahorro del período

El cumplimiento del 20% mide los aportes propios realizados dentro del período, no el saldo neto del producto financiero:

```text
savingsContribution(P) = suma de operaciones saving_contribution activas en P
```

No restan al ahorro del período:

- los retiros de ahorro (`saving_withdrawal`);
- el saldo inicial de un producto financiero;
- los rendimientos financieros (`financial_return`).

## 8. Deuda por cobrar

Una cuenta por cobrar es una relación derivada, no un saldo duplicado:

```text
originalAmount = monto de la operación loan origen
paidAmount     = suma de pagos loan_repayment activos vinculados
pendingAmount  = originalAmount - paidAmount
status         = PENDING si pendingAmount > 0, PAID si pendingAmount == 0
```

Solo se persisten identidad, persona, vínculo con la operación `loan` origen, notas opcionales y metadatos técnicos. Registrar una deuda a favor no crea un ingreso ficticio; el pago recibido sigue las reglas de reintegro por cambio de período.

## 9. Disponible, ahorro total y dinero por cobrar

### Disponible

Representa el dinero utilizable actual fuera de productos financieros. Mover dinero entre ubicaciones propias no debe aumentar artificialmente el patrimonio ni duplicar el disponible.

### Ahorro total

Suma de los saldos derivados de los productos financieros. El saldo de un producto incluye su saldo inicial, aportes, retiros y rendimientos. El saldo inicial no cuenta como ingreso base ni como ahorro del período.

### Dinero por cobrar

Suma de los saldos pendientes de las cuentas por cobrar derivados de operaciones `loan` y sus pagos.

Estos tres valores representan el **estado actual** y no cambian al navegar entre períodos históricos.

## 10. Saldos iniciales

### Saldo disponible inicial

Durante el onboarding, si el saldo disponible inicial es mayor que cero se representa con una operación `opening_balance` con la fecha local de confirmación. Si es cero, no se crea una operación de monto cero. El saldo inicial aumenta el disponible pero nunca participa en ingreso base ni en 50/30/20.

### Saldo inicial de producto financiero

El saldo previo de un producto financiero es una condición inicial, no una transacción. No aumenta el disponible, no cuenta como ingreso base y no cuenta como ahorro del período.

## 11. Anulación lógica

Una operación puede quedar en estado `VOIDED`. Las operaciones anuladas permanecen persistidas para auditoría, pero se excluyen de todos los cálculos derivados. No existe anulación en cascada automática; no se puede anular una operación origen si existen dependencias activas que quedarían inválidas.

## 12. Invariantes

1. Un movimiento interno entre productos propios no crea ingreso.
2. Un reintegro del mismo mes calendario no infla ingresos.
3. Una devolución de un tercero en un mes calendario posterior puede reconocerse como ingreso del nuevo período sin perder su vínculo con la operación original.
4. Registrar dinero que un tercero debe no equivale a haber recibido ese dinero.
5. Ningún movimiento debe contabilizarse dos veces en el disponible por representar simultáneamente su origen y su destino.
6. Las relaciones históricas relevantes deben preservarse aunque cambie la clasificación de presentación entre períodos.
7. Los montos se persisten como enteros COP; no se usan tipos de punto flotante para dinero.
8. El MVP es COP-only; no hay conversión de divisas.
9. El bloque histórico de una operación no cambia si cambia el bloque por defecto de su categoría.
10. `SAVINGS` no se usa como bloque de categoría ordinaria ni de préstamo.
11. El ahorro del período mide aportes, no saldo de producto; los retiros no reducen el ahorro registrado del período.
12. Una operación anulada no participa en saldos ni indicadores normales.
13. No se permite anular una operación origen con dependencias activas que quedarían inconsistentes.

## 13. Cambios a estas reglas

Una modificación de estas invariantes o de la clasificación entre ingreso, reintegro, deuda y movimiento interno afecta el contrato central del dominio. Debe existir una decisión explícita de producto y, cuando implique diseño o migración significativa, debe utilizarse SDD de forma explícita antes de implementar.
