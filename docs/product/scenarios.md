# Escenarios de dominio

Este documento consolida los 23 escenarios conductuales canónicos de Mis Gastos. Cada escenario preserva su identificador numérico estable y se expresa en términos de producto: contexto inicial, acción y resultado esperado. Sirven como material de referencia para entender el comportamiento financiero esperado sin reproducir las reglas completas que viven en otras fuentes de verdad.

Los detalles de semántica de operaciones, fórmulas de presupuesto, configuración, historial, navegación, onboarding y criterios de aceptación se mantienen en las fuentes de verdad vinculadas. Las decisiones arquitectónicas que fundamentan la semántica contable aceptada para el producto están en ADR-009.

## Fuentes de verdad relacionadas

| Tema | Documento |
|------|-----------|
| Semántica de operaciones e invariantes financieras | [`domain-rules.md`](./domain-rules.md) |
| Fórmulas de ingreso base, gasto efectivo, metas y estados | [`budgeting.md`](./budgeting.md) |
| Configuración de categorías, productos financieros y personas | [`configuration.md`](./configuration.md) |
| Onboarding y finalización inicial | [`onboarding.md`](./onboarding.md) |
| Historial, detalle, edición, anulación y filtros | [`history.md`](./history.md) |
| Navegación principal, Dashboard y acción global `+ Registrar` | [`navigation.md`](./navigation.md) |
| Criterios de aceptación canónicos del MVP | [`acceptance.md`](./acceptance.md) |
| Fundamento arquitectónico de la semántica contable | [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md) |

## Escenario 1 — Ingreso nuevo

**Contexto inicial:** la persona no ha registrado ingresos en el período.

**Acción:** registra un ingreso nuevo de $5.000.000, por ejemplo una nómina.

**Resultado esperado:**

- El saldo disponible aumenta $5.000.000.
- El ingreso base del período aumenta $5.000.000.

_Ver [`domain-rules.md`](./domain-rules.md) §3 y §5, [`budgeting.md`](./budgeting.md) §3._

## Escenario 2 — Aporte a ahorro

**Contexto inicial:** el saldo disponible actual es $5.000.000.

**Acción:** la persona aporta $1.000.000 a un producto financiero, por ejemplo un fondo de emergencia.

**Resultado esperado:**

- El disponible queda en $4.000.000.
- El saldo del producto financiero aumenta $1.000.000.
- El ahorro del período aumenta $1.000.000 para el cumplimiento del 20%.
- El ingreso base no cambia.

_Ver [`domain-rules.md`](./domain-rules.md) §3, §5 y §7, [`budgeting.md`](./budgeting.md) §7._

## Escenario 3 — Retiro de ahorro en otro mes

**Contexto inicial:** en agosto la persona tenía un saldo acumulado de $1.300.000 en un producto financiero.

**Acción:** en septiembre retira $1.000.000 de ese producto.

**Resultado esperado en septiembre:**

- El disponible aumenta $1.000.000.
- El saldo del producto financiero disminuye $1.000.000.
- El ingreso base de septiembre aumenta $0.

El hecho de que el dinero se hubiera ahorrado en otro mes no transforma el retiro en ingreso nuevo.

_Ver [`domain-rules.md`](./domain-rules.md) §3 y §5, [`budgeting.md`](./budgeting.md) §3 y §7._

## Escenario 4 — Rendimiento financiero

**Contexto inicial:** el saldo de un producto financiero es $1.000.000.

**Acción:** la persona registra un rendimiento explícito de $100.000 generado dentro de ese producto.

**Resultado esperado:**

- El saldo del producto financiero aumenta a $1.100.000.
- El ingreso base del período aumenta $100.000.
- El saldo disponible no cambia directamente.

_Ver [`domain-rules.md`](./domain-rules.md) §3 y §5, [`budgeting.md`](./budgeting.md) §3._

## Escenario 5 — Préstamo y devolución en el mismo mes

**Contexto inicial:** la persona tiene disponible para prestar.

**Acción:**

- El 15 de septiembre presta $200.000 a Juan.
- El 22 de septiembre Juan devuelve $80.000.

**Resultado esperado:**

- El préstamo origina una cuenta por cobrar de $200.000.
- El pago reduce el saldo pendiente a $120.000.
- El pago aumenta el disponible en $80.000.
- El pago no aumenta el ingreso base de septiembre.
- El pago se trata como un reintegro dentro del mismo mes calendario.

_Ver [`domain-rules.md`](./domain-rules.md) §3, §5, §6 y §8, [`budgeting.md`](./budgeting.md) §3 y §4._

## Escenario 6 — Préstamo y devolución en otro mes

**Contexto inicial:** la persona tiene disponible para prestar.

**Acción:**

- El 20 de septiembre presta $200.000 a Ana.
- El 3 de octubre Ana devuelve $50.000.

**Resultado esperado en octubre:**

- El disponible aumenta $50.000.
- La cuenta por cobrar queda con un saldo pendiente de $150.000.
- El ingreso base de octubre aumenta $50.000.
- Se conserva la relación causal con el préstamo de septiembre.

_Ver [`domain-rules.md`](./domain-rules.md) §3, §5 y §8, [`budgeting.md`](./budgeting.md) §3._

## Escenario 7 — Pagos parciales cruzando meses

**Contexto inicial:** la persona tiene disponible para prestar.

**Acción:**

- El 20 de septiembre presta $200.000.
- El 28 de septiembre recibe un pago de $50.000.
- El 3 de octubre recibe un pago de $150.000.

**Resultado esperado:**

- El pago de septiembre se trata como reintegro del mismo mes calendario: no aumenta el ingreso base.
- El pago de octubre se reconoce como ingreso base de octubre.
- El saldo pendiente final es $0.
- La cuenta por cobrar queda en estado pagado.

_Ver [`domain-rules.md`](./domain-rules.md) §3, §5 y §8, [`budgeting.md`](./budgeting.md) §3 y §4._

## Escenario 8 — Categoría reclasificada por transacción

**Contexto inicial:** la categoría `Ropa` propone el bloque `Deseos` por defecto.

**Acción:** la persona registra una transacción de $250.000 en la categoría `Ropa`, pero elige el bloque `Necesidades` porque el concepto es zapatos obligatorios para el trabajo.

**Resultado esperado:**

- La transacción queda registrada en el bloque `Necesidades`.
- La categoría `Ropa` sigue proponiendo `Deseos` como bloque por defecto.
- Otras transacciones de `Ropa` no cambian.

_Ver [`configuration.md`](./configuration.md) §Categorías, [`domain-rules.md`](./domain-rules.md) §4._

## Escenario 9 — Cambio futuro de categoría

**Contexto inicial:**

- En enero la categoría `Ropa` propone `Deseos`.
- En enero la persona registra la transacción A en `Ropa`, que queda en `Deseos`.

**Acción:** en febrero cambia el bloque por defecto de `Ropa` a `Necesidades`.

**Resultado esperado:**

- La transacción A permanece en `Deseos`.
- Las nuevas transacciones de `Ropa` proponen `Necesidades`.

_Ver [`configuration.md`](./configuration.md) §Categorías, [`domain-rules.md`](./domain-rules.md) §4._

## Escenario 10 — Saldo inicial

**Contexto inicial:** la aplicación se acaba de instalar y no hay movimientos previos.

**Acción:** durante el onboarding la persona indica un saldo disponible inicial de $2.350.000 y un saldo inicial de $3.000.000 en un producto financiero.

**Resultado esperado:**

- El disponible inicial es $2.350.000.
- El ahorro inicial es $3.000.000.
- El ingreso base es $0.

_Ver [`onboarding.md`](./onboarding.md) §Pasos, [`domain-rules.md`](./domain-rules.md) §5 y §10._

## Escenario 11 — Retiro mayor que el aporte del mes

**Contexto inicial:**

- Saldo de ahorro previo: $3.000.000.
- Aporte del mes: $500.000.

**Acción:** la persona retira $2.000.000 del producto financiero en el mismo mes.

**Resultado esperado:**

- El retiro es válido porque existe saldo suficiente en el producto.
- El ahorro del período para el cumplimiento del 20% refleja el aporte de $500.000.
- El retiro no borra ni reduce retroactivamente el comportamiento de ahorro registrado para el período.
- El saldo financiero final es $1.500.000.

_Ver [`domain-rules.md`](./domain-rules.md) §7, §9 y §11, [`budgeting.md`](./budgeting.md) §7, [`configuration.md`](./configuration.md) §Productos financieros._

## Escenario 12 — Sobrepago rechazado

**Contexto inicial:**

- Préstamo original: $100.000.
- Pagos registrados: $80.000.

**Acción:** la persona intenta registrar un nuevo pago de $30.000.

**Resultado esperado:**

- La operación se rechaza.
- El saldo pendiente permanece en $20.000.
- No se crea un movimiento parcial de $30.000.

_Ver [`domain-rules.md`](./domain-rules.md) §8, [`history.md`](./history.md) §Detalle de movimiento._

## Escenario 13 — Anulación con dependencias

**Contexto inicial:**

- Préstamo original: $200.000.
- Pago activo relacionado: $50.000.

**Acción:** la persona intenta anular el préstamo.

**Resultado esperado:**

- La operación se bloquea mientras el pago relacionado siga activo o no exista un flujo explícito que resuelva todas las dependencias de forma consistente.

_Ver [`history.md`](./history.md) §Anulación con dependencias y [`domain-rules.md`](./domain-rules.md) §11 y §13._

## Escenario 14 — Consulta anual no reclasifica

**Contexto inicial:**

- Préstamo: septiembre.
- Pago relacionado: octubre.

**Acción:** la persona consulta el año completo en el Dashboard.

**Resultado esperado:**

- El pago conserva su naturaleza de pago de préstamo.
- Su tratamiento como ingreso sigue determinado por la relación entre los meses calendario de origen y de pago.
- No se convierte en reintegro sólo porque préstamo y pago aparecen dentro del mismo rango anual.

_Ver [`budgeting.md`](./budgeting.md) §2 y §3, [`domain-rules.md`](./domain-rules.md) §5._

## Escenario 15 — Dashboard mensual 50/30/20

**Contexto inicial:**

- Ingreso base del mes: $5.000.000.
- Necesidades efectivas: $2.200.000.
- Deseos efectivos: $1.600.000.
- Aportes a ahorro: $800.000.

**Acción:** la persona abre el Dashboard del mes.

**Resultado esperado en Necesidades:**

- Objetivo: $2.500.000.
- Participación sobre el ingreso: 44%.
- Uso del presupuesto: 88%.
- Restante: $300.000.
- Estado: cerca del límite.

**Resultado esperado en Deseos:**

- Objetivo: $1.500.000.
- Participación sobre el ingreso: 32%.
- Uso del presupuesto: 106,67%.
- Exceso: $100.000.
- Estado: excedido.

**Resultado esperado en Ahorro:**

- Objetivo: $1.000.000.
- Participación sobre el ingreso: 16%.
- Cumplimiento: 80%.
- Faltante: $200.000.
- Estado: cerca de la meta.

_Ver [`budgeting.md`](./budgeting.md) §5, §6 y §7._

## Escenario 16 — Retiro no reduce el cumplimiento de ahorro

**Contexto inicial:**

- Ingreso base del mes: $4.000.000.
- Aporte a ahorro: $1.000.000.
- Retiro de ahorro: $600.000.

**Acción:** la persona revisa el indicador de ahorro del período.

**Resultado esperado:**

- El objetivo del 20% es $800.000.
- El ahorro del período es $1.000.000.
- El cumplimiento es 125%.
- El cambio neto del producto por estas operaciones es +$400.000.
- El retiro no reduce el cumplimiento del período.

_Ver [`budgeting.md`](./budgeting.md) §7, [`domain-rules.md`](./domain-rules.md) §7 y §11._

## Escenario 17 — Reintegro en otra semana del mismo mes

**Contexto inicial:**

- El 2 de septiembre la persona registra un gasto de Salud en Necesidades por $200.000.

**Acción:** el 20 de septiembre registra un reintegro vinculado de $50.000.

**Resultado esperado en indicadores:**

- El costo efectivo del gasto original es $150.000.
- La semana del reintegro no muestra `-$50.000` como gasto del bloque.
- El reintegro no aumenta el ingreso base.

**Resultado esperado en historial:**

- El gasto aparece el 2 de septiembre.
- La entrada de reintegro aparece el 20 de septiembre.

_Ver [`budgeting.md`](./budgeting.md) §4 y §9.1, [`history.md`](./history.md) §Principios y §Detalle de movimiento._

## Escenario 18 — Disponible actual no cambia al navegar historial

**Contexto inicial:** el saldo disponible actual es $2.350.000.

**Acción:** la persona cambia el Dashboard de septiembre a agosto.

**Resultado esperado:**

- El indicador `Disponible actual` sigue mostrando $2.350.000.
- El ingreso base y los indicadores 50/30/20 cambian al rango de agosto.

_Ver [`navigation.md`](./navigation.md) §Dashboard / Resumen, [`domain-rules.md`](./domain-rules.md) §9._

## Escenario 19 — Flujo de caja no equivale a ingreso base

**Contexto inicial:** durante octubre la persona tiene:

- Una nómina registrada como ingreso nuevo: +$3.000.000.
- Un retiro de ahorro: +$500.000.

**Acción:** la persona revisa el resumen de entradas y salidas del período.

**Resultado esperado:**

- El flujo de caja de entradas del período es $3.500.000.
- El ingreso base del período es $3.000.000.

El retiro de ahorro aumenta el efectivo disponible, pero no la base del presupuesto 50/30/20.

_Ver [`budgeting.md`](./budgeting.md) §3, [`domain-rules.md`](./domain-rules.md) §3 y §5._

## Escenario 20 — Cálculo anual directo

**Contexto inicial:**

- Ingresos base: enero $1.000.000, febrero $3.000.000.
- Necesidades: enero $600.000, febrero $900.000.

**Acción:** la persona consulta la vista anual.

**Resultado esperado:**

- Ingreso base anual: $4.000.000.
- Objetivo anual de Necesidades: $2.000.000.
- Necesidades reales del año: $1.500.000.
- Uso del presupuesto anual: 75%.

No se usa el promedio simple de los porcentajes mensuales.

_Ver [`budgeting.md`](./budgeting.md) §8._

## Escenario 21 — Devolución tardía de gasto ordinario

**Contexto inicial:**

- El 20 de septiembre la persona registra un gasto de Ropa en Deseos por $200.000.

**Acción:** el 3 de octubre el comercio devuelve $50.000 asociados a ese gasto.

**Resultado esperado:**

- El disponible de octubre aumenta $50.000.
- El ingreso base de octubre aumenta $50.000.
- El gasto de septiembre no se reduce retroactivamente.
- Se conserva la relación causal con el gasto original.

_Ver [`domain-rules.md`](./domain-rules.md) §3, §5 y §6, [`budgeting.md`](./budgeting.md) §3 y §9.2, [`history.md`](./history.md) §Principios._

## Escenario 22 — Movimiento dependiente con fecha anterior rechazado

**Contexto inicial:** el 20 de septiembre la persona presta $100.000 a Juan.

**Acción:** intenta registrar un pago relacionado con fecha 15 de septiembre.

**Resultado esperado:**

- La operación se rechaza.
- No se crea un pago de préstamo.
- No se crea un movimiento de deuda con fecha anterior.
- El saldo pendiente permanece en $100.000.

La misma regla aplica a una devolución de gasto ordinario con fecha anterior al gasto origen.

_Ver [`domain-rules.md`](./domain-rules.md) §6 y §8, [`history.md`](./history.md) §Detalle de movimiento._

## Escenario 23 — Cuenta por cobrar deriva sus montos de transacciones

**Contexto inicial:** existe un préstamo activo de $200.000 y dos pagos activos vinculados: uno de $50.000 y otro de $30.000.

**Acción:** la persona consulta la cuenta por cobrar asociada al préstamo.

**Resultado esperado:**

- Monto original: $200.000.
- Monto pagado: $80.000.
- Monto pendiente: $120.000.
- Estado: pendiente.

La cuenta por cobrar no guarda una segunda copia del monto original ni del pendiente; estos valores se derivan de la operación de préstamo origen y de sus pagos vinculados.

_Ver [`domain-rules.md`](./domain-rules.md) §8, [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md) §Debt source-of-truth._
