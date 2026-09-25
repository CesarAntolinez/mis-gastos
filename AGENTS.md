# Instrucciones para agentes — Mis Gastos

## Objetivo del proyecto

Construir un MVP Android local-first para registrar y analizar finanzas personales en COP usando la metodología 50/30/20, con categorías configurables, ahorro en productos financieros simples y cuentas por cobrar.

## Fuente de verdad

Antes de implementar, leer en este orden:

1. `docs/00-product-brief.md`
2. `docs/01-requirements.md`
3. `docs/02-domain-and-data.md`
4. `docs/08-domain-scenarios.md`
5. `docs/09-indicators-dashboard.md`
6. `docs/10-navigation-and-flows.md`
7. `docs/11-history.md`
8. `docs/12-configuration.md`
9. `docs/13-onboarding.md`
10. `docs/14-room-sqlite-schema.md`
11. `docs/03-ux-ui.md`
12. `docs/04-architecture.md`
13. `docs/05-roadmap.md`
14. `docs/06-acceptance-criteria.md`
15. `docs/07-gentle-ai-workflow.md`

Si el código contradice la documentación aprobada, detener la implementación y reportar la contradicción. No ampliar alcance silenciosamente.

## Reglas de implementación

- Implementar únicamente el slice activo del roadmap.
- No dejar botones, pantallas, rutas, repositorios o casos de uso parcialmente conectados.
- Un slice sólo se considera terminado cuando cumple su Definition of Done y criterios de aceptación.
- No introducir backend, autenticación, sincronización en nube, exportación, notificaciones ni moneda múltiple en el MVP.
- Usar exclusivamente COP.
- No usar `Double`/`Float` para persistencia monetaria. Persistir montos como enteros en pesos.
- No asumir que toda entrada de dinero es ingreso base 50/30/20.
- `TransactionNature` determina el efecto financiero; `TransactionDirection` no basta para decidir qué saldo cambia.
- La UI nunca permite seleccionar `TransactionNature` directamente; la operación visible elegida determina la naturaleza.
- `SAVING_WITHDRAWAL`, `OPENING_BALANCE` y reintegros del mismo mes no aumentan ingreso base.
- `FINANCIAL_RETURN` aumenta el producto financiero y el ingreso base, pero no aumenta directamente el saldo disponible.
- Una devolución de préstamo recibida en un mes posterior sí aumenta el ingreso base de ese nuevo mes.
- Una devolución tardía de gasto ordinario se persiste como `NEW_INCOME` relacionada con el gasto origen.
- Un pago de préstamo siempre conserva `LOAN_REPAYMENT`; su participación en ingreso base se deriva por mes.
- No permitir que una devolución o pago relacionado tenga fecha anterior a su origen.
- `SAVING` implica bloque `SAVINGS/20%` y no requiere categoría ordinaria.
- Un préstamo a terceros sólo puede clasificarse en `NEEDS` o `WANTS`.
- El bloque 50/30/20 persistido en la transacción es la fuente de verdad histórica.
- Cambiar una categoría no debe reescribir transacciones existentes.
- No eliminar físicamente transacciones financieras: usar anulación lógica.
- No permitir saldo negativo en productos financieros.
- No permitir pagos acumulados de una cuenta por cobrar por encima del monto original.
- No permitir reintegros/devoluciones acumulados de un gasto por encima del monto original activo.
- Los retiros de ahorro no reducen el cumplimiento 20% ya registrado en el período.
- Semana = lunes a domingo. Mes y año son períodos calendario.
- Las reglas de reintegro se determinan por mes calendario aunque la UI esté mostrando semana o año.
- `Disponible actual`, `Saldo ahorrado actual` y `Por cobrar actual` son estado financiero actual; no deben reinterpretarse al navegar períodos históricos.
- Para Año se recalculan objetivos sobre los totales anuales; no se promedian porcentajes mensuales.
- Mantener diseño visual centralizado en tokens/tema.
- Mantener una sola fuente de verdad para cálculos de indicadores: `docs/09-indicators-dashboard.md`.
- Seguir los flujos visibles y navegación de `docs/10-navigation-and-flows.md`; no exponer operaciones incompletas.
- Seguir `docs/11-history.md`: Historial muestra movimientos reales, no netos; anulados están ocultos por defecto y no existe restauración en el MVP.
- Seguir `docs/12-configuration.md` para datos maestros y restricciones de activación/desactivación.
- Seguir `docs/13-onboarding.md` para inicialización; no inferir onboarding desde cantidad de transacciones.
- Seguir exactamente `docs/14-room-sqlite-schema.md` para entidades, foreign keys, índices, converters y operaciones atómicas. No inventar columnas/tablas paralelas sin actualizar primero la especificación.
- `transactions` es la fuente de verdad de monto, fecha y concepto de movimientos financieros.
- `receivables` no duplica `originalAmount`, fecha, concepto, pendiente ni estado persistido.
- `receivable_payments` no duplica monto ni fecha del pago.
- No persistir saldos de productos, saldos pendientes ni totales de Dashboard como columnas mutables.
- Enums Room se persisten como `TEXT` por nombre, nunca por ordinal.
- `LocalDate` se persiste como ISO `YYYY-MM-DD`; `Instant` como epoch milliseconds.
- Usar foreign keys restrictivas; no cascadas para borrar histórico financiero.
- No usar triggers de negocio en v1.
- `@Database(exportSchema = true)` y schemas exportados deben versionarse.
- No usar `fallbackToDestructiveMigration` como estrategia de producto.
- El onboarding debe poder completarse con todos los montos en cero.
- Si el saldo disponible inicial es mayor que cero, representarlo con `OPENING_BALANCE`; si es cero, no crear una transacción de monto cero.
- `FinancialProduct.openingBalance` representa ahorro previo y no cuenta como ingreso base ni como ahorro 20% del período.
- Las categorías seed deben crearse de forma idempotente.
- La confirmación final del onboarding debe ser atómica junto con `onboardingCompleted = true`.
- No persistir parcialmente productos/categorías/transacciones por navegar entre pasos del onboarding.
- No implementar `Reiniciar onboarding` en el MVP.
- Categorías ordinarias sólo pueden usar `NEEDS` o `WANTS` como `defaultBucket`.
- No crear categoría ordinaria para ahorro; `SAVING` representa el 20%.
- No permitir desactivar un producto financiero cuyo saldo derivado sea distinto de cero.
- Bloquear `openingBalance` de un producto una vez exista histórico financiero relacionado.
- No permitir desactivar una persona con saldo pendiente por cobrar.
- Validar unicidad de nombres activos por tipo usando `trim` + comparación case-insensitive, incluida reactivación.
- No depender sólo de índices SQL para reglas de unicidad condicionadas por `active`.
- Una transacción origen con dependencias activas no puede cambiar su fecha financiera.
- Un préstamo con pagos activos bloquea monto, fecha y persona.
- Un gasto con reintegros activos bloquea monto y fecha.
- No implementar anulación en cascada automática de relaciones financieras.
- El detalle de un movimiento debe consumir un efecto financiero calculado en dominio; la UI no interpreta manualmente la naturaleza.
- Operaciones compuestas deben usar transacciones Room atómicas.
- DAO puede optimizar filtros/agregaciones, pero no contener reglas financieras duplicadas.
- ViewModel y UI no deben recalcular fórmulas financieras.

## Stack objetivo

- Kotlin
- Jetpack Compose + Material 3
- Navigation Compose
- Room
- Coroutines + Flow
- ViewModel
- Inyección manual mediante `AppContainer`

## Calidad mínima

- Compilación limpia.
- Tests unitarios para reglas de ingreso base, reintegros, ahorro, productos financieros, cuentas por cobrar e indicadores 50/30/20.
- Tests de persistencia Room para converters, foreign keys, CRUD, filtros, agregaciones y operaciones atómicas críticas.
- Tests de invariantes antes de cerrar cada slice.
- Casos de `docs/08-domain-scenarios.md` relevantes al slice convertidos a tests.
- Tests del Historial deben cubrir filtros combinables, anulados, orden estable y preservación de relaciones.
- Tests de Configuración deben cubrir desactivación bloqueada, unicidad normalizada y preservación de histórico.
- Tests de Onboarding deben cubrir todo en cero, productos opcionales, seed idempotente, persistencia atómica y no duplicación tras reinicio.
- Tests Room deben cubrir exclusión de `VOIDED`, derivación de receivables y clasificación mismo/otro mes.
- Desde Database v2, toda migración debe tener test.
- Estados vacío, error y sin base de cálculo cubiertos en UI.
- Sin TODOs que representen funcionalidad requerida por el slice.

## Convenciones de trabajo

- Cambios pequeños y verticales.
- Preferir nombres de dominio en inglés en código y textos visibles en español.
- Un commit debe describir una unidad de trabajo verificable.
- No modificar artefactos de Gentle-AI generados automáticamente salvo que su documentación lo indique.
