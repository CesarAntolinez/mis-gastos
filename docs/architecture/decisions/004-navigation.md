# ADR-004 — Navegación: go_router

**Status:** accepted  
**Date:** 2026-09-25

## Context

Mis Gastos tendrá múltiples áreas y flujos móviles: onboarding, inicio, historial, detalle de movimientos, registro de gastos/ingresos, personas/deudas y configuración. La navegación debe ser explícita, testeable y capaz de evolucionar hacia deep links sin diseñar infraestructura específica antes de necesitarla.

## Decision

Usar **go_router** como solución principal de navegación para Flutter.

Las rutas deben definirse de forma central y con nombres/paths estables cuando tengan identidad propia. Los detalles internos de navegación de una feature pueden encapsularse cuando el crecimiento lo justifique.

La navegación no debe transportar objetos de persistencia como contrato principal entre pantallas. Preferir identificadores o parámetros pequeños y resolver los datos mediante la capa correspondiente.

La estructura conceptual inicial incluye:

```text
/
├── onboarding
├── home
├── history
│   └── transaction/:id
├── debts
│   └── person/:id
├── settings
└── transaction
    ├── expense/new
    └── income/new
```

Esta lista expresa intención y puede evolucionar con el producto; no obliga a crear rutas sin una feature implementada.

## Alternatives

### Navigator API sin router adicional

Es suficiente para aplicaciones pequeñas y flujos simples. No se selecciona como estrategia principal porque el producto ya prevé varias áreas, rutas con identidad y posible soporte futuro de deep links.

### AutoRoute u otros routers con generación

Son opciones válidas, pero añadirían otra capa de generación/configuración sin una ventaja necesaria para el alcance actual.

## Consequences

### Positive

- Mapa de navegación declarativo y legible.
- Rutas con identidad clara para testing y deep linking futuro.
- Buen encaje con Flutter y Riverpod sin acoplar navegación al estado financiero.
- Facilita shells/navegación persistente si la app lo requiere posteriormente.

### Costs

- Requiere mantener redirects y guards con cuidado para evitar loops o lógica oculta.
- La navegación declarativa puede introducir complejidad si se modelan prematuramente rutas que aún no existen.

## Guardrails

- No usar navegación para decidir reglas de dominio.
- Mantener guards limitados a concerns de navegación/acceso, como onboarding completado; no convertirlos en casos de uso financieros.
- Preferir IDs sobre objetos completos en parámetros de ruta.
- No crear deep links públicos hasta definir explícitamente su contrato.
- Mantener transiciones coherentes con `docs/design/design-system.md` y respetar reduced motion.
- No añadir un segundo router sin una decisión explícita.

## References

- `docs/architecture/decisions/001-mobile-framework.md`
- `docs/architecture/decisions/003-state-management.md`
- `docs/design/design-system.md`
- `docs/product/roadmap.md`
