# Documentación — Mis Gastos

Esta carpeta es la fuente de verdad funcional y técnica del MVP.

## Orden de lectura

1. [`00-product-brief.md`](./00-product-brief.md) — problema, objetivo, alcance y reglas centrales.
2. [`01-requirements.md`](./01-requirements.md) — requisitos funcionales, no funcionales, validaciones y estados.
3. [`02-domain-and-data.md`](./02-domain-and-data.md) — dominio, invariantes y modelo lógico.
4. [`08-domain-scenarios.md`](./08-domain-scenarios.md) — escenarios concretos que deben convertirse en tests.
5. [`09-indicators-dashboard.md`](./09-indicators-dashboard.md) — contrato de fórmulas, saldos e indicadores 50/30/20.
6. [`10-navigation-and-flows.md`](./10-navigation-and-flows.md) — navegación y flujos funcionales de Dashboard/Registro y destinos relacionados.
7. [`11-history.md`](./11-history.md) — historial, filtros, detalle, edición, relaciones y anulación.
8. [`03-ux-ui.md`](./03-ux-ui.md) — principios visuales, componentes y sistema de diseño.
9. [`04-architecture.md`](./04-architecture.md) — stack y arquitectura objetivo.
10. [`05-roadmap.md`](./05-roadmap.md) — slices verticales y Definition of Done.
11. [`06-acceptance-criteria.md`](./06-acceptance-criteria.md) — comportamiento verificable del MVP.
12. [`07-gentle-ai-workflow.md`](./07-gentle-ai-workflow.md) — uso recomendado de Opencode/Gentle-AI con SDD, ODD y RDD.

## Regla de cambio

Cuando cambie el comportamiento esperado del producto, actualizar primero la especificación correspondiente y después el código.

No ampliar alcance desde una implementación sin reflejar el cambio en esta documentación.
