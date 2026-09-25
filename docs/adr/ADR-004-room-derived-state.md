# ADR-004 — Room/SQLite y estado financiero derivado

- Estado: `Accepted`
- Fecha: 2026-09-25

## Contexto

El MVP requiere persistencia local fiable, relaciones, filtros, agregaciones y transacciones atómicas. Los saldos e indicadores pueden calcularse desde movimientos financieros y no necesitan columnas mutables duplicadas.

## Decisión

Usar Room sobre SQLite como persistencia local y derivar estado financiero desde datos fuente.

- `@Database(exportSchema = true)`.
- Schemas Room versionados en Git.
- Foreign keys restrictivas.
- Enums persistidos como `TEXT` por nombre, no ordinal.
- `LocalDate` como `YYYY-MM-DD`.
- `Instant` como epoch milliseconds.
- No persistir balances, pendientes o indicadores como fuente de verdad mutable.
- DAO puede hacer SUM, JOIN y filtros; las reglas financieras finales pertenecen a dominio.
- Operaciones compuestas usan transacciones Room atómicas.
- No usar `fallbackToDestructiveMigration` como estrategia del producto.
- No usar triggers SQLite para lógica financiera del MVP.

## Consecuencias

### Positivas

- Persistencia tipada y testeable.
- Migraciones explícitas.
- Consultas locales eficientes sin duplicar reglas de negocio.
- Estado financiero reconstruible desde datos fuente.

### Costes

- Algunas consultas requieren agregaciones y joins.
- Deben existir tests de Room para converters, foreign keys, agregados y atomicidad.

## Revisión futura

Si métricas de rendimiento reales justifican materialización, introducirla como optimización derivada mediante un ADR nuevo y tests que demuestren equivalencia con la fuente de verdad.
