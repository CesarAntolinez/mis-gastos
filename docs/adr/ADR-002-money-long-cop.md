# ADR-002 — Dinero como enteros COP

> **Histórico / legacy.** Este ADR pertenece a la era Kotlin/Room del proyecto y **ya no es autoridad de implementación activa**. La regla "dinero como enteros COP" y el alcance COP-only del MVP siguen vigentes en [`docs/product/domain-rules.md`](../product/domain-rules.md), [`docs/product/budgeting.md`](../product/budgeting.md) y [`docs/architecture/decisions/005-money-representation.md`](../architecture/decisions/005-money-representation.md). El tipo Kotlin `Long`, la convención Room/SQLite `INTEGER` y la suposición irreversible de COP de este ADR están obsoletos para la implementación actual.

- Estado: `Accepted` (en su momento, era Kotlin/Room)
- Fecha: 2026-09-25

## Contexto

El MVP usa una sola moneda: pesos colombianos. Los cálculos financieros no requieren centavos ni conversión de divisas.

## Decisión

Todos los montos monetarios se representan como enteros de 64 bits en pesos COP.

- Kotlin: `Long`.
- SQLite/Room: `INTEGER`.
- Los montos persistidos son no negativos; naturaleza/dirección determinan el efecto.
- No usar `Float` ni `Double` para montos monetarios.
- El formateo `es-CO` pertenece a UI.

## Consecuencias

### Positivas

- Evita errores binarios de punto flotante.
- Simplifica sumas, comparaciones e invariantes.
- Encaja con COP sin centavos en el alcance del MVP.

### Costes

- Si una versión futura soporta monedas fraccionarias deberá revisar representación y escala.
- Porcentajes/ratios pueden usar tipos decimales para cálculo, pero nunca sustituyen el `Long` monetario persistido.

## Revisión futura

Una futura moneda múltiple o valores con subunidades requiere un nuevo ADR y migración explícita.
