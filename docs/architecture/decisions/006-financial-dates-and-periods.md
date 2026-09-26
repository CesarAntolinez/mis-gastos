# ADR-006 — Fechas financieras y períodos

**Status:** accepted  
**Date:** 2026-09-26

## Context

Las reglas de Mis Gastos dependen del período financiero en el que ocurre un movimiento. En particular, una devolución puede tratarse como reintegro dentro del mismo período y como ingreso del período receptor cuando cruza a un período posterior, conservando su relación causal.

La fecha de registro técnico no necesariamente coincide con la fecha en que ocurrió financieramente el movimiento. También deben evitarse errores causados por UTC, zona horaria y límites de mes.

## Decision

### Período del MVP

Usar **mes calendario** como período financiero: desde el día 1 hasta el último día del mismo mes.

Períodos personalizados (por ejemplo, del 15 al 14) quedan fuera del MVP.

### Fecha efectiva

Cada movimiento financiero debe tener una fecha efectiva (`effectiveDate`/equivalente) que represente cuándo ocurrió para efectos financieros.

El período financiero se deriva de esa fecha efectiva en la zona horaria aplicable, no de `createdAt`.

Ejemplo:

```text
Préstamo: 31 enero
  devolución 31 enero -> mismo período -> reintegro
  devolución 1 febrero -> período posterior -> ingreso de febrero
```

En ambos casos se conserva la relación con la operación original.

### Timestamps técnicos

Timestamps de auditoría técnica como `createdAt` y `updatedAt` representan instantes y deben normalizarse/persistirse en UTC.

No utilizar `createdAt` como sustituto de la fecha financiera efectiva.

### Zona horaria

Las operaciones que conviertan instantes a fecha local o determinen límites temporales deben utilizar una zona horaria explícita proveniente de la configuración/contexto de la aplicación.

El MVP puede inicializarla desde el dispositivo, pero el dominio no debe depender implícitamente de la zona horaria de la máquina durante cálculos reproducibles.

### Período derivado

No almacenar nombres como `"septiembre"` ni otra representación textual duplicada como fuente de verdad del período de cada movimiento. Año/mes y etiquetas de presentación deben derivarse de la fecha efectiva cuando sea posible.

## Alternatives

### Usar `createdAt` para determinar el mes

No se selecciona porque registrar posteriormente una transacción cambiaría incorrectamente el período financiero al que pertenece.

### Guardar únicamente UTC para toda semántica financiera

UTC es adecuado para instantes técnicos, pero un límite mensual financiero corresponde a una fecha civil en una zona horaria. Un instante UTC por sí solo puede caer en un día/mes diferente al mostrado al usuario.

### Períodos configurables desde el MVP

No se selecciona porque añade complejidad a reportes, reintegros y clasificación sin un requisito actual que la justifique.

## Consequences

- El schema deberá distinguir fecha efectiva de timestamps técnicos.
- Consultas mensuales deben usar límites derivados de fecha efectiva y zona horaria aplicable.
- Las pruebas deben cubrir fin/inicio de mes y cambios de período.
- Cambiar la fecha efectiva de un movimiento puede modificar reportes o clasificación derivada y debe tratarse conscientemente en UX/dominio.
- La relación causal entre movimientos no se pierde al cruzar un límite mensual.

## Guardrails

- No usar `DateTime.now()` disperso en reglas de dominio; inyectar/proporcionar el tiempo actual cuando una regla dependa de él.
- No mezclar timestamps UTC de auditoría con fechas civiles sin conversión explícita.
- Probar límites como último/primer día del mes.
- Considerar años bisiestos y meses de distinta duración mediante APIs de fecha, no constantes manuales.
- No introducir períodos fiscales/personalizados sin una nueva decisión de producto.
- No reclasificar o romper relaciones históricas únicamente por presentación mensual.

## References

- `docs/product/domain-rules.md`
- `docs/architecture/decisions/002-persistence.md`
- `docs/architecture/decisions/005-money-representation.md`
