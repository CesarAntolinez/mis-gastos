# ADR-001 — MVP local-only y offline-first

- Estado: `Accepted`
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
