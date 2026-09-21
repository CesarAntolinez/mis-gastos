# Instrucciones para agentes — Mis Gastos

## Objetivo del proyecto

Construir un MVP Android local-first para registrar ingresos y egresos y analizar el uso del ingreso mediante la regla 50/30/20.

## Fuente de verdad

Antes de implementar, leer en este orden:

1. `docs/00-product-brief.md`
2. `docs/01-requirements.md`
3. `docs/02-domain-and-data.md`
4. `docs/03-ux-ui.md`
5. `docs/04-architecture.md`
6. `docs/05-roadmap.md`
7. `docs/06-acceptance-criteria.md`
8. `docs/07-gentle-ai-workflow.md`

Si el código contradice la documentación aprobada, detener la implementación y reportar la contradicción. No ampliar alcance silenciosamente.

## Reglas de implementación

- Implementar únicamente el slice activo del roadmap.
- No dejar botones, pantallas, rutas, repositorios o casos de uso parcialmente conectados.
- Un slice sólo se considera terminado cuando cumple su Definition of Done y sus criterios de aceptación.
- No introducir backend, autenticación, sincronización en nube, exportación, notificaciones ni edición de categorías en el MVP.
- No usar `Double`/`Float` para dinero. Persistir montos como enteros en pesos.
- Los ingresos no pertenecen a un bloque 50/30/20. Los egresos sí.
- Si un período no tiene ingresos, no calcular porcentajes 50/30/20; mostrar estado sin base de cálculo.
- Semana = lunes a domingo; mes y año = períodos calendario según la zona horaria local del dispositivo.
- Mantener el diseño visual centralizado en tokens/tema. No codificar colores, radios, espaciados o tipografía de forma dispersa.
- Mantener una sola fuente de verdad para cálculos de indicadores; UI y tests deben consumir la misma lógica de dominio.

## Stack objetivo

- Kotlin
- Jetpack Compose + Material 3
- Navigation Compose
- Room
- Coroutines + Flow
- ViewModel
- Inyección manual mediante `AppContainer` para evitar complejidad innecesaria en el MVP

## Calidad mínima

- Compilación limpia.
- Tests unitarios para reglas 50/30/20 y agregaciones por período.
- Tests de persistencia Room para CRUD crítico.
- Estados vacío, error y sin ingresos cubiertos en UI.
- Sin TODOs que representen funcionalidad requerida por el slice.

## Convenciones de trabajo

- Cambios pequeños y verticales.
- Preferir nombres de dominio en inglés en código y textos visibles en español.
- Un commit debe describir una unidad de trabajo verificable.
- No modificar artefactos de Gentle-AI generados automáticamente salvo que su documentación lo indique.
