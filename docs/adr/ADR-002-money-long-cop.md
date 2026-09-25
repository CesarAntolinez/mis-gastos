# ADR-002 — Dinero como enteros COP

- Estado: `Accepted`
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
