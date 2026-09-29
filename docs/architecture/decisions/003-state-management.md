# ADR-003 — Estado y composición de dependencias: Riverpod

**Status:** accepted  
**Date:** 2026-09-25

## Context

Mis Gastos necesita coordinar estado de UI, streams provenientes de persistencia local, casos de uso y dependencias como repositories. Se busca evitar tanto estado global innecesario como múltiples mecanismos de dependency injection.

## Decision

Usar **Riverpod** como mecanismo principal para estado compartido, estado asíncrono y composición de dependencias en la aplicación Flutter.

Usar estado local de Flutter cuando el estado pertenezca exclusivamente a un widget o interacción breve. No convertir cada valor de UI en un provider.

Riverpod podrá exponer y componer repositories, casos de uso y servicios de aplicación, por lo que inicialmente **no se añadirá un contenedor DI separado** como GetIt/Injectable.

Las reglas financieras deben permanecer en dominio/casos de uso. Un provider puede orquestar una operación, pero no convertirse en la fuente canónica de reglas como clasificación de ingresos, reintegros o movimientos internos.

## Alternatives

### BLoC / Cubit

Ofrece flujo explícito y tooling maduro. No se selecciona porque para este proyecto introduce más ceremonia de eventos/estados que la necesaria para combinar persistencia reactiva, estado asíncrono y composición de dependencias.

### Provider

Es simple y conocido, pero Riverpod ofrece una composición y testabilidad más apropiadas para el crecimiento previsto sin depender del árbol de widgets.

### GetIt / Injectable como DI adicional

No se incorpora inicialmente porque Riverpod puede resolver la composición necesaria. Se reconsiderará solo si aparece una necesidad concreta que Riverpod no cubra adecuadamente.

## Consequences

### Positive

- Un mecanismo coherente para estado compartido y dependencias.
- Integración natural con streams/queries reactivas de Drift.
- Overrides útiles para testing.
- Menor necesidad de singletons o service locators globales.

### Costs

- El equipo/agentes deben conocer correctamente lifecycle, scopes y familias de providers.
- Un uso indiscriminado puede fragmentar la lógica entre demasiados providers.
- Requiere mantener una frontera clara entre orquestación y dominio.

## Guardrails

- Preferir estado local cuando no necesita compartirse o sobrevivir fuera del widget.
- Providers deben tener responsabilidades concretas y nombres orientados a intención.
- No ejecutar reglas financieras centrales directamente en providers si pertenecen al dominio.
- No acceder a Drift directamente desde widgets; pasar por los límites definidos para la feature.
- Evitar providers globales mutables que actúen como bolsas de estado.
- No agregar otro framework de estado/DI sin una decisión arquitectónica explícita.

## References

- `docs/architecture/decisions/001-mobile-framework.md`
- `docs/architecture/decisions/002-persistence.md`
- `docs/product/domain-rules.md`
