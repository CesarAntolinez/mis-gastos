# 04 — Arquitectura

## Objetivo

Mantener un MVP Android pequeño, testeable y fácil de modificar mediante agentes, sin introducir capas o dependencias innecesarias.

El esquema físico Room/SQLite v1 está definido en [`14-room-sqlite-schema.md`](./14-room-sqlite-schema.md).

## Stack

- Kotlin
- Jetpack Compose
- Material 3
- Navigation Compose
- Room
- Coroutines
- Flow
- ViewModel

## Estructura sugerida

```text
app/
  src/main/java/.../
    data/
      local/
        entity/
        dao/
        converter/
        projection/
      repository/
    domain/
      model/
      repository/
      usecase/
      service/
    ui/
      navigation/
      screen/
        onboarding/
        dashboard/
        history/
        transaction/
        configuration/
        receivable/
      component/
      theme/
    di/
      AppContainer.kt
```

## Capas

### Data

Responsabilidades:

- Room entities.
- DAO.
- converters.
- proyecciones de consultas.
- implementación de repositorios.
- ejecución de operaciones atómicas Room.

No contiene lógica visual ni decisiones 50/30/20 duplicadas.

### Domain

Responsabilidades:

- modelos de negocio;
- reglas 50/30/20;
- clasificación de devoluciones por mes;
- cálculo de períodos;
- validaciones e invariantes;
- efecto financiero de cada movimiento;
- interfaces de repositorio.

Las reglas deben mantenerse independientes de Android cuando sea razonable.

### UI

Responsabilidades:

- Compose;
- estado de pantalla;
- interacción;
- formateo para presentación;
- navegación.

La UI no recalcula reglas financieras.

## Flujo de datos

```text
Room -> Repository/UseCase -> ViewModel -> UiState -> Compose
Compose event -> ViewModel -> UseCase/Repository -> Room
```

## Estado de pantalla

Cada pantalla expone `UiState` inmutable.

Ejemplo conceptual:

```text
DashboardUiState(
  period,
  currentState,
  baseIncome,
  needs,
  wants,
  savings,
  recentTransactions
)
```

## Repositorios

Interfaces de dominio recomendadas:

```text
TransactionRepository
CategoryRepository
FinancialProductRepository
PersonRepository
ReceivableRepository
SetupRepository
```

No crear un repositorio por tabla si no existe una responsabilidad de dominio clara.

Las operaciones que abarcan varias tablas deben exponerse como operaciones de dominio atómicas, por ejemplo:

```text
createLoan(...)
registerLoanRepayment(...)
registerExpenseRefund(...)
completeOnboarding(...)
withdrawSavings(...)
```

## Operaciones atómicas

Usar `RoomDatabase.withTransaction` para operaciones compuestas o de validación + escritura que deban observar un estado consistente.

Son obligatoriamente atómicas:

- onboarding final;
- préstamo + cuenta por cobrar;
- pago + asociación a cuenta por cobrar;
- reintegro/devolución relacionado;
- retiro de ahorro después de validar saldo;
- desactivación de producto/persona después de validar estado;
- creación/reactivación/renombrado cuando se valida unicidad activa.

## Inyección de dependencias

Usar `AppContainer` manual en el MVP.

Razón: el proyecto es pequeño y no necesita el coste conceptual de un framework DI. Si crece, revisar mediante ADR.

## Navegación

Destinos principales:

```text
onboarding (sólo mientras no esté completado)
dashboard
history
configuration
```

Rutas secundarias según necesidad:

```text
transaction/new/{operation}
transaction/{id}
categories
financial-products
financial-product/{id}
persons
receivables
receivable/{id}
```

No exponer rutas a funcionalidades incompletas.

## Manejo de fechas

- `Transaction.date` es `LocalDate` de negocio.
- Persistir en Room como ISO `YYYY-MM-DD`.
- `createdAt/updatedAt` son `Instant` técnicos persistidos como epoch milliseconds.
- Inyectar abstracción de reloj/fecha para `today` y timestamps cuando la lógica requiera tests deterministas.
- Un movimiento dependiente no puede tener fecha anterior al origen.

## Dinero

- Modelo monetario: `Long` en COP.
- UI formatea con locale `es-CO`.
- No usar `Float`/`Double` para montos.
- No persistir signos negativos; el efecto lo determina naturaleza/dirección.

## Room / SQLite

Database v1:

```text
app_setup
categories
financial_products
persons
transactions
receivables
receivable_payments
```

Reglas:

- `@Database(exportSchema = true)`;
- schemas exportados versionados en Git;
- foreign keys restrictivas;
- enums como `TEXT` por nombre;
- no triggers de negocio;
- no `fallbackToDestructiveMigration` en producto;
- balances e indicadores derivados, no persistidos.

Ver detalle completo en `14-room-sqlite-schema.md`.

## Fuente de verdad monetaria

`transactions` contiene monto, fecha y concepto de movimientos.

`receivables` y `receivable_payments` guardan relaciones, no copias de esos campos.

Esto evita estados divergentes entre un préstamo/pago y su cuenta por cobrar.

## Consultas y agregaciones

Room debe realizar filtros y agregaciones cuando esto evita cargar todo el histórico en memoria.

SQL puede producir datos crudos o proyecciones como:

```text
HistoryRowProjection
FinancialProductSummaryProjection
ReceivableSummaryProjection
DashboardRawTotalsProjection
```

La interpretación financiera final y estados de negocio pertenecen a dominio.

## Búsqueda de Historial

La búsqueda simple puede usar `LIKE` sobre concepto y joins con nombres de categoría/persona/producto.

No añadir FTS en v1 salvo evidencia de rendimiento que lo justifique.

## Anulación

Las transacciones financieras usan `status = VOIDED`.

No usar `DELETE` ni cascadas para representar anulación.

Consultas financieras normales excluyen `VOIDED`.

## Migraciones

- Database inicia en versión 1.
- Cada cambio futuro incrementa versión.
- Migraciones explícitas y testeadas.
- No migración destructiva en producción.
- Mantener schemas Room exportados en control de versiones.

## Testing

### Unit tests

Obligatorios para:

- validación por naturaleza;
- categoría/bucket;
- devoluciones mismo/otro mes;
- pago de préstamo mismo/otro mes;
- saldo disponible/producto;
- límites de reintegros y sobrepagos;
- períodos;
- indicadores 50/30/20;
- efecto financiero del detalle.

### Room tests

Obligatorios para:

- converters;
- foreign keys;
- CRUD crítico;
- filtros y orden de Historial;
- agregados;
- operaciones atómicas;
- seed idempotente;
- cuentas por cobrar derivadas;
- exclusión de `VOIDED`;
- tests de migración a partir de v2.

### UI tests

Mínimos por slice para flujos visibles terminados, sin intentar cubrir reglas financieras que corresponden a unit/Room tests.

## ADR

Usar `docs/adr/` sólo para decisiones técnicas con valor de revisión futura.

ADR iniciales recomendados:

- ADR-001: MVP local-only.
- ADR-002: dinero como `Long` COP.
- ADR-003: transacciones como fuente de verdad financiera.
- ADR-004: Room/SQLite y datos derivados no materializados.
- ADR-005: DI manual con `AppContainer`.

No crear ADR para decisiones triviales.

## Dependencias

Antes de añadir una dependencia:

1. explicar el problema concreto;
2. comprobar si plataforma/stdlib/Compose/Room lo resuelve razonablemente;
3. evitar librerías que dupliquen capacidades ya disponibles;
4. no introducir una dependencia sólo porque un agente la conoce mejor.
