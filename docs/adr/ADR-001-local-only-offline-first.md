# ADR-001 — MVP local-only y offline-first

> **Histórico / legacy.** Este ADR pertenece a la era Kotlin/Room del proyecto y **ya no es autoridad de implementación activa**. La regla de producto "MVP local-only y offline-first" sigue vigente en [`docs/product/vision.md`](../product/vision.md) (sección *Operación local y offline-first*) y en [`docs/architecture/decisions/001-mobile-framework.md`](../architecture/decisions/001-mobile-framework.md) (enfoque local-first). El mecanismo Room y las referencias a Kotlin están obsoletos para la implementación actual.

- Estado: `Accepted` (en su momento, era Kotlin/Room)
- Fecha: 2026-09-25

## Contexto

El MVP busca registrar y analizar finanzas personales sin cuenta, backend ni sincronización. El alcance funcional aprobado no requiere colaboración, múltiples dispositivos ni datos remotos.

## Decisión

La primera versión será completamente local y offline-first.

- Persistencia en Room/SQLite dentro del dispositivo.
- Todas las operaciones funcionales del MVP deben funcionar sin conexión.
- No se implementan login, backend, sincronización, resolución de conflictos ni cuentas remotas.
- La arquitectura no debe introducir abstracciones de red especulativas para un sync futuro.

## Consecuencias

### Positivas

- Menor complejidad operativa y de seguridad.
- Desarrollo y testing más simples.
- Tiempos de respuesta locales.
- Menor superficie de fallos para el MVP.

### Costes

- Los datos permanecen en un único dispositivo.
- No existe recuperación en nube ni sincronización entre dispositivos.
- Backup/exportación quedan fuera de esta versión.

## Revisión futura

Si se aprueba sincronización o multi-dispositivo, crear un nuevo ADR antes de introducir identidad remota, backend o estrategia de conflictos.
