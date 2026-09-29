# Reglas de dominio

Este documento registra la semántica financiera canónica de Mis Gastos. Las implementaciones deben preservar estas reglas. Si una feature requiere cambiarlas, el cambio debe documentarse explícitamente antes de modificar código.

## 1. Conceptos principales

### Gasto

Salida de dinero destinada a consumo, pago u otra finalidad que reduce el disponible correspondiente.

### Ingreso

Entrada de dinero que incrementa la base disponible y representa dinero nuevo para el período según las reglas del producto. Debe conservarse su origen cuando sea conocido.

### Reintegro o retorno

Dinero que regresa al usuario como consecuencia de una salida previa. Mientras corresponda al mismo período contable del producto, no debe tratarse como ingreso nuevo: restaura dinero previamente disponible.

### Movimiento interno

Traslado de dinero entre productos o ubicaciones financieras pertenecientes al usuario. Por sí solo no crea ingreso ni gasto económico; cambia dónde se encuentra el dinero.

### Deuda a favor del usuario

Dinero que otra persona debe al usuario. Debe poder asociarse a una persona y mantenerse distinguible de un ingreso hasta que corresponda reconocer su devolución según las reglas aplicables.

## 2. Disponible

El disponible representa el dinero que el usuario puede considerar utilizable según los productos y estados registrados.

Mover dinero entre ubicaciones propias no debe aumentar artificialmente el patrimonio ni duplicar el disponible.

Cuando dinero previamente enviado a ahorro u otro producto financiero vuelve a la base disponible, el movimiento debe conservar su naturaleza de traslado interno y no convertirse automáticamente en ingreso.

## 3. Ingresos y origen

Todo ingreso debe poder distinguirse de un reintegro o movimiento interno.

Cuando se conozca el origen del ingreso, debe conservarse para que el usuario pueda entender de dónde proviene su base disponible.

Ejemplos de origen pueden incluir salario, venta, pago por trabajo u otra fuente definida posteriormente.

## 4. Reintegros y cambio de período

Si el usuario entrega o presta dinero y este regresa dentro del mismo mes/período relevante, el retorno se considera reintegro o reingreso del dinero previamente salido y no un ingreso nuevo.

Ejemplo: el usuario presta $2.000 y recibe esos mismos $2.000 la semana siguiente dentro del mismo mes. La devolución restaura el disponible; no constituye un ingreso nuevo.

Si la devolución ocurre en un mes/período posterior, para la lectura financiera de ese nuevo período se reconoce como ingreso, conservando cuando sea posible la referencia a la salida o deuda original. Esta regla permite que el período receptor explique correctamente de dónde provino el dinero sin perder trazabilidad histórica.

La implementación no debe borrar la relación causal solo porque cambie la clasificación utilizada para el nuevo período.

## 5. Ahorro y productos financieros

Enviar dinero desde la base disponible hacia ahorro u otro producto financiero propio es un movimiento interno, no un gasto económico.

Retirar posteriormente parte o todo ese dinero hacia la base disponible es igualmente un movimiento interno, no un ingreso nuevo por el simple hecho de regresar al disponible.

Esta regla es distinta de la devolución de dinero por parte de un tercero: los movimientos entre productos propios conservan siempre su naturaleza interna.

## 6. Personas que deben dinero

El producto puede mantener un registro de personas que deben dinero al usuario.

Como mínimo, el modelo debe poder representar:

- la persona;
- el monto pendiente;
- el origen o motivo cuando corresponda;
- la fecha del evento;
- devoluciones parciales o totales cuando se implementen;
- la relación entre la devolución y la deuda original.

Registrar una deuda a favor no debe crear un ingreso ficticio. El tratamiento de la devolución debe seguir la regla de reintegros y cambio de período.

## 7. Historial y trazabilidad

El historial debe permitir comprender qué ocurrió, cuándo ocurrió, qué monto estuvo involucrado y qué efecto tuvo sobre el disponible.

Cuando un movimiento derive de otro —por ejemplo, devolución de un préstamo o retorno desde un producto financiero— la relación debe conservarse aunque la interfaz la presente de forma simplificada.

## 8. Invariantes

1. Un movimiento interno entre productos propios no crea ingreso.
2. Un reintegro del mismo período no infla ingresos.
3. Una devolución de un tercero en un período posterior puede reconocerse como ingreso del nuevo período sin perder su vínculo con la operación original.
4. Registrar dinero que un tercero debe no equivale a haber recibido ese dinero.
5. Ningún movimiento debe contabilizarse dos veces en el disponible por representar simultáneamente su origen y su destino.
6. Las relaciones históricas relevantes deben preservarse aunque cambie la clasificación de presentación entre períodos.

## 9. Cambios a estas reglas

Una modificación de estas invariantes o de la clasificación entre ingreso, reintegro, deuda y movimiento interno afecta el contrato central del dominio. Debe existir una decisión explícita de producto y, cuando implique diseño o migración significativa, debe utilizarse SDD de forma explícita antes de implementar.
