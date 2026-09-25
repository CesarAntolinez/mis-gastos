# Instrucciones para agentes — Mis Gastos

## Objetivo del proyecto

Construir un MVP Android local-first para registrar y analizar finanzas personales en COP usando la metodología 50/30/20, con categorías configurables, ahorro en productos financieros simples y cuentas por cobrar.

## Fuente de verdad

Antes de implementar, leer en este orden:

1. `docs/00-product-brief.md`
2. `docs/01-requirements.md`
3. `docs/02-domain-and-data.md`
4. `docs/08-domain-scenarios.md`
5. `docs/03-ux-ui.md`
6. `docs/04-architecture.md`
7. `docs/05-roadmap.md`
8. `docs/06-acceptance-criteria.md`
9. `docs/07-gentle-ai-workflow.md`

Si el código contradice la documentación aprobada, detener la implementación y reportar la contradicción. No ampliar alcance silenciosamente.

## Reglas de implementación

- Implementar únicamente el slice activo del roadmap.
- No dejar botones, pantallas, rutas, repositorios o casos de uso parcialmente conectados.
- Un slice sólo se considera terminado cuando cumple su Definition of Done y criterios de aceptación.
- No introducir backend, autenticación, sincronización en nube, exportación, notificaciones ni moneda múltiple en el MVP.
- Usar exclusivamente COP.
- No usar `Double`/`Float` para persistencia monetaria. Persistir montos como enteros en pesos.
- No asumir que toda entrada de dinero es ingreso base 50/30/20.
- `SAVING_WITHDRAWAL`, `OPENING_BALANCE` y reintegros del mismo mes no aumentan ingreso base.
- Una devolución de préstamo recibida en un mes posterior sí aumenta el ingreso base de ese nuevo mes.
- El bloque 50/30/20 persistido en la transacción es la fuente de verdad histórica.
- Cambiar una categoría no debe reescribir transacciones existentes.
- No eliminar físicamente transacciones financieras: usar anulación lógica.
- No permitir saldo negativo en productos financieros.
- No permitir pagos acumulados de una cuenta por cobrar por encima del monto original.
- Semana = lunes a domingo. Mes y año son períodos calendario.
- Las reglas de reintegro se determinan por mes calendario aunque la UI esté mostrando semana o año.
- Mantener diseño visual centralizado en tokens/tema.
- Mantener una sola fuente de verdad para cálculos de indicadores.

## Stack objetivo

- Kotlin
- Jetpack Compose + Material 3
- Navigation Compose
- Room
- Coroutines + Flow
- ViewModel
- Inyección manual mediante `AppContainer` para evitar complejidad innecesaria

## Calidad mínima

- Compilación limpia.
- Tests unitarios para reglas de ingreso base, reintegros, ahorro, productos financieros y cuentas por cobrar.
- Tests de persistencia Room para CRUD crítico.
- Tests de invariantes antes de cerrar cada slice.
- Estados vacío, error y sin base de cálculo cubiertos en UI.
- Sin TODOs que representen funcionalidad requerida por el slice.

## Convenciones de trabajo

- Cambios pequeños y verticales.
- Preferir nombres de dominio en inglés en código y textos visibles en español.
- Un commit debe describir una unidad de trabajo verificable.
- No modificar artefactos de Gentle-AI generados automáticamente salvo que su documentación lo indique.
