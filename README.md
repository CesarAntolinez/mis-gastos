# Mis Gastos

Aplicación móvil Android local-first para registrar y analizar finanzas personales en COP usando la metodología 50/30/20.

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

Las fórmulas canónicas están en [`docs/09-indicators-dashboard.md`](./docs/09-indicators-dashboard.md).

## Persistencia

`transactions` es la fuente de verdad de los movimientos financieros.

Room/SQLite v1 está definido en [`docs/14-room-sqlite-schema.md`](./docs/14-room-sqlite-schema.md).

Principios:

- montos en `Long` / SQLite `INTEGER` en pesos COP;
- sin `Float`/`Double` monetario;
- saldos e indicadores derivados;
- transacciones anuladas permanecen persistidas como `VOIDED`;
- sin backend, login o sincronización en el MVP.

## Stack objetivo

- Kotlin
- Jetpack Compose + Material 3
- Navigation Compose
- Room
- Coroutines + Flow
- ViewModel
- DI manual mediante `AppContainer`

## Desarrollo asistido por IA

El proyecto está pensado para trabajarse con Opencode CLI y Gentle-AI mediante SDD, ODD y RDD.

Antes de implementar, leer [`AGENTS.md`](./AGENTS.md).

La fuente de verdad funcional y técnica está en [`docs/`](./docs/readme.md).

Las decisiones técnicas estables están registradas en [`docs/adr/`](./docs/adr/README.md).

## Roadmap

El desarrollo se divide en slices verticales pequeños. Cada slice debe quedar funcional, probado y verificable antes de iniciar el siguiente.

Ver [`docs/05-roadmap.md`](./docs/05-roadmap.md).

## Estado de especificación

La especificación funcional, UX, persistencia y arquitectura del MVP está cerrada para iniciar implementación. Si durante desarrollo aparece una contradicción o comportamiento no definido, se actualiza primero la documentación antes de modificar el producto silenciosamente.
