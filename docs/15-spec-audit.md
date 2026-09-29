# 15 — Auditoría final de especificación MVP

Fecha de revisión: 2026-09-25

## Objetivo

Verificar que alcance, dominio, UX, persistencia, arquitectura, roadmap y reglas para agentes describan el mismo MVP antes de iniciar implementación.

## Documentos revisados

- `00-product-brief.md`
- `01-requirements.md`
- `02-domain-and-data.md`
- `03-ux-ui.md`
- `04-architecture.md`
- `05-roadmap.md`
- `06-acceptance-criteria.md`
- `07-gentle-ai-workflow.md`
- `08-domain-scenarios.md`
- `09-indicators-dashboard.md`
- `10-navigation-and-flows.md`
- `11-history.md`
- `12-configuration.md`
- `13-onboarding.md`
- `14-room-sqlite-schema.md`
- `AGENTS.md`
- `README.md`
- ADRs vigentes en `docs/adr/`

## Contradicciones encontradas y corregidas

### UX — navegación principal

`03-ux-ui.md` todavía indicaba dos destinos inferiores (`Resumen`, `Historial`).

Corrección:

```text
Resumen | Historial | Configuración
```

con `+ Registrar` desde Resumen e Historial, conforme a los flujos aprobados.

### README — categorías e ingreso base

El README todavía describía categorías como predefinidas y afirmaba que los porcentajes se calculaban sobre todo ingreso del período.

Corrección:

- categorías configurables `NEEDS/WANTS`;
- ahorro 20% mediante `SAVING` y productos financieros;
- cálculo sobre `baseIncome`, no toda entrada de dinero.

### Modelo lógico de cuentas por cobrar

Durante el cierre del esquema físico, el modelo lógico anterior duplicaba monto/fecha/concepto en `Receivable` y monto/fecha en `ReceivablePayment`.

Corrección:

- `transactions` conserva la fuente de verdad;
- las tablas auxiliares sólo conservan relaciones;
- pendiente, pagado y estado se derivan.

### Arquitectura — catálogo de categorías

Una versión anterior de arquitectura proponía un ADR para catálogo de categorías en código.

Corrección:

- categorías son datos configurables persistidos;
- ADR vigente se enfoca en transacciones como fuente de verdad.

## Contratos considerados cerrados

### Alcance

- Android local-only/offline-first.
- COP único.
- Sin login/backend/sync/exportación en MVP.
- Regla fija 50/30/20.

### Dominio

- `TransactionNature` determina efecto financiero.
- `transactions` es fuente de verdad de movimientos.
- bucket persistido en transacción conserva histórico.
- reintegros/pagos dependen del mes calendario del origen.
- ahorro propio y cuentas por cobrar tienen relaciones explícitas.

### Indicadores

- Dashboard conforme a `09-indicators-dashboard.md`.
- disponible/ahorrado/por cobrar actuales no se reinterpretan al navegar períodos históricos.
- 20% mide aportes brutos del período; retiros no reducen cumplimiento.

### UX

- navegación principal de tres destinos.
- operaciones visibles específicas; no selector de enums técnicos.
- Historial muestra movimientos reales y Detalle explica efecto financiero.
- Configuración administra categorías, productos y personas.
- Onboarding corto y de una sola ejecución.

### Persistencia

- schema Room/SQLite v1 de `14-room-sqlite-schema.md`.
- dinero `Long`/`INTEGER`.
- enums como `TEXT`.
- `LocalDate` ISO.
- `Instant` epoch millis.
- foreign keys restrictivas.
- sin triggers de negocio.
- sin balances/indicadores materializados como fuente de verdad.
- operaciones compuestas atómicas.

### Arquitectura

- Kotlin + Compose + Material 3.
- Room + Coroutines + Flow.
- ViewModel.
- DI manual con `AppContainer`.
- reglas financieras en dominio, no UI.

## Decisiones deliberadamente fuera del MVP

No se consideran huecos de especificación:

- múltiples monedas;
- porcentajes 50/30/20 configurables;
- login;
- backend/sincronización;
- integración bancaria;
- intereses automáticos;
- exportación/importación;
- notificaciones;
- widgets;
- contactos del sistema;
- adjuntos de recibos;
- restaurar transacciones anuladas;
- FTS/búsqueda avanzada;
- materialización de balances;
- framework DI.

## Riesgos que deben vigilarse durante implementación

1. No duplicar fórmulas del Dashboard en DAO/ViewModel/UI.
2. No interpretar `direction` como sustituto de `nature`.
3. No permitir writes parciales en operaciones compuestas.
4. No introducir cascadas destructivas en Room.
5. No crear funcionalidades de slices futuros como placeholders navegables.
6. No modificar el schema v1 por conveniencia sin actualizar primero especificación/ADR cuando corresponda.
7. Mantener tests de escenarios de dominio como evidencia del comportamiento aprobado.

## Resultado

**Estado: READY FOR IMPLEMENTATION**

No quedan contradicciones conocidas que bloqueen Slice 0.

Si durante implementación aparece una contradicción material o una regla funcional no cubierta:

1. detener esa decisión concreta;
2. documentar el caso;
3. actualizar primero la especificación apropiada;
4. después continuar código.

No usar esta regla para ampliar alcance innecesariamente ni para bloquear decisiones puramente de implementación que no cambian comportamiento observable.
