# ADR-002 — Persistencia local: SQLite + Drift

**Status:** accepted  
**Date:** 2026-09-25

## Context

Mis Gastos es local-first y debe funcionar sin conexión. El dominio requiere persistir movimientos, productos financieros, personas, deudas, reintegros y relaciones entre operaciones. También necesitará consultas agregadas e históricas sin perder integridad relacional.

SQLite ya fue establecido como dirección de persistencia en ADR-001. Falta decidir la capa de acceso desde Dart.

## Decision

Usar **SQLite** como motor local y **Drift** como capa tipada de acceso a datos.

Drift pertenece a la capa `data`; sus tablas, companions y modelos generados no son el modelo de dominio y no deben filtrarse innecesariamente hacia `domain` o `presentation`.

Los repositories serán el límite entre persistencia y dominio cuando exista una responsabilidad real que separar.

Las migraciones de schema deben ser explícitas, versionadas y probadas cuando el esquema empiece a evolucionar.

## Alternatives

### sqflite / SQL directo

Mantiene una superficie muy cercana a SQLite y ofrece máximo control. No se selecciona como opción principal porque el proyecto se beneficiará de consultas tipadas, streams reactivos, generación de código y una estructura consistente para schemas y migrations.

### Almacenamiento key-value/documental

Puede ser apropiado para preferencias simples, pero no como persistencia financiera principal debido a las relaciones, integridad y consultas que requiere el dominio.

## Consequences

### Positive

- SQLite continúa siendo la fuente persistente local.
- Queries y schemas tipados en Dart.
- Buen encaje con datos reactivos consumidos desde Riverpod.
- Relaciones y consultas agregadas pueden expresarse sin abandonar SQL.
- Facilita evolución controlada del schema.

### Costs

- Introduce generación de código y tooling de Drift.
- Requiere disciplina para no convertir filas de base de datos en entidades de dominio por comodidad.
- Cambios de schema requerirán estrategia de migración y pruebas.

## Guardrails

- No almacenar montos financieros como `double` sin una decisión explícita sobre representación monetaria.
- Preservar relaciones necesarias para trazabilidad entre movimientos.
- Aplicar constraints e índices cuando protejan invariantes o consultas reales.
- No crear tablas anticipando features no aprobadas.
- Las reglas de clasificación financiera pertenecen al dominio, no a triggers SQL ni a widgets.

## References

- `docs/architecture/decisions/001-mobile-framework.md`
- `docs/product/domain-rules.md`
- `docs/development/workflow.md`
