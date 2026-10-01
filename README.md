# Mis Gastos

Aplicación móvil local-first para registrar y analizar finanzas personales en COP usando la metodología 50/30/20.

## Objetivo del MVP

- Registrar ingresos y egresos.
- Clasificar gastos ordinarios entre Necesidades 50% y Deseos 30%.
- Registrar ahorro 20% mediante productos financieros propios.
- Usar categorías configurables con bucket por defecto `NEEDS/WANTS`.
- Permitir sobrescribir el bucket por transacción sin alterar histórico.
- Registrar saldo disponible inicial y saldos iniciales de productos financieros.
- Registrar aportes, retiros y rendimientos financieros.
- Gestionar personas, préstamos, pagos parciales y dinero por cobrar.
- Registrar reintegros/devoluciones relacionados.
- Consultar Dashboard e Historial por semana, mes y año.
- Funcionar completamente offline con persistencia local.

## Regla financiera central

La regla 50/30/20 usa **ingreso base computable**, no toda entrada de dinero.

Objetivos:

- Necesidades — 50% del ingreso base.
- Deseos — 30% del ingreso base.
- Ahorro — 20% del ingreso base.

Ejemplos de entradas que no aumentan ingreso base:

- saldo inicial;
- retiro de ahorro;
- reintegro recibido en el mismo mes de la salida original.

Una devolución de préstamo recibida en un mes posterior sí aumenta el ingreso base del nuevo período. Los retiros de ahorro nunca se convierten en ingreso nuevo.

> Fórmulas e invariantes históricas: [`docs/09-indicators-dashboard.md`](./docs/09-indicators-dashboard.md).
>
> La consolidación canónica de reglas financieras está en curso en [`docs/product/domain-rules.md`](./docs/product/domain-rules.md).

## Stack objetivo

- **Flutter + Dart** para UI, dominio y runtime móvil.
- **Drift** sobre SQLite para persistencia local tipada.
- **Riverpod** para estado compartido y composición de dependencias.

Ver decisiones técnicas aceptadas en [`docs/architecture/decisions/`](./docs/architecture/decisions/).

## Persistencia

- Motor local: SQLite.
- Capa de acceso: Drift.
- Montos financieros: enteros en pesos COP (ver [ADR-005](docs/architecture/decisions/005-money-representation.md)).
- Transacciones anuladas permanecen persistidas (`VOIDED`).
- Sin backend, login o sincronización en el MVP.

Detalles en [ADR-002](docs/architecture/decisions/002-persistence.md) y en el schema/entidades que se definan en el slice activo.

## Desarrollo asistido por IA

El proyecto se trabaja con Opencode CLI y Gentle-AI mediante ODD, SDD y RDD.

Antes de implementar, leer [`AGENT.md`](./AGENT.md).

Fuentes de verdad:

- Producto: [`docs/product/`](./docs/product/)
- Decisiones técnicas: [`docs/architecture/decisions/`](./docs/architecture/decisions/)
- Flujo de trabajo: [`docs/development/workflow.md`](./docs/development/workflow.md)

## Roadmap

El desarrollo se divide en slices verticales pequeños. Cada slice debe quedar funcional, probado y verificable antes de iniciar el siguiente.

Ver [`docs/product/roadmap.md`](./docs/product/roadmap.md).

## Estado de especificación

La dirección funcional y técnica del MVP está cerrada para iniciar implementación. Si aparece una contradicción o comportamiento no definido, se actualiza primero la documentación antes de modificar el producto silenciosamente.

## Referencia histórica

La especificación original Kotlin/Room (`docs/00-product-brief.md` a `docs/15-spec-audit.md`) y los ADR legacy (`docs/adr/README.md`) se conservan como contexto histórico; no son autoridad de implementación actual.
