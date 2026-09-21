# 04 — Arquitectura

## Objetivo

Mantener un MVP pequeño, testeable y fácil de modificar mediante agentes sin introducir capas innecesarias.

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
      repository/
    domain/
      model/
      repository/
      usecase/
    ui/
      navigation/
      screen/
        dashboard/
        history/
        transaction/
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
- Implementación de repositorio.

No contiene lógica visual.

### Domain

Responsabilidades:

- Modelos de negocio.
- Reglas 50/30/20.
- Cálculo de períodos.
- Validaciones independientes de Android cuando sea posible.
- Interfaces de repositorio.

### UI

Responsabilidades:

- Compose.
- estado de pantalla.
- interacción.
- formateo para presentación.

La UI no debe recalcular reglas de negocio.

## Flujo de datos

```text
Room -> Repository -> ViewModel/UseCase -> UiState -> Compose
Compose event -> ViewModel -> Repository -> Room
```

## Estado

Cada pantalla debe exponer un `UiState` inmutable.

Ejemplo conceptual:

```text
DashboardUiState(
  period,
  periodRange,
  totals,
  buckets,
  isEmpty,
  hasIncome
)
```

## Repositorio

Una interfaz `TransactionRepository` debe cubrir el MVP:

- observeTransactions(range)
- observeSummary(range)
- getById(id)
- save(transaction)
- delete(transaction)

No crear múltiples repositorios para el mismo agregado si no existe una necesidad concreta.

## Inyección de dependencias

Usar `AppContainer` manual en el MVP.

Razón: el proyecto es pequeño y no necesita el coste conceptual de un framework DI. Si el proyecto crece, esta decisión puede revisarse mediante ADR.

## Navegación

Rutas mínimas:

```text
dashboard
history
transaction/new
transaction/{id}
```

## Manejo de fechas

- Persistir sólo la fecha de negocio de la transacción como `LocalDate`.
- Usar reloj/zona local sólo para validar día actual y timestamps técnicos.
- Inyectar abstracción de reloj en lógica que requiera `today` para hacer tests deterministas.

## Dinero

- Modelo: `Long` en COP.
- La capa de UI realiza formateo con locale `es-CO`.
- Evitar cálculos monetarios con punto flotante.

## Cálculo de resumen

Preferir que Room realice SUM filtrados por rango cuando esto simplifique rendimiento.

La conversión de totales a porcentajes y estados contra la meta pertenece a dominio.

## Testing

### Unit tests

Obligatorios para:

- validación de transacción.
- categoría vs bloque.
- cálculo de rango semanal/mensual/anual.
- porcentajes 50/30/20.
- comportamiento sin ingresos.

### Room tests

Obligatorios para:

- insert/read/update/delete.
- filtro por rango.
- agregados del dashboard.

### UI tests

Mínimos para el flujo crítico:

- abrir formulario.
- registrar ingreso.
- registrar egreso.
- visualizarlo en historial.

## ADR

Usar `docs/adr/` sólo para decisiones técnicas que puedan necesitar revisión futura.

ADR iniciales recomendados:

- ADR-001: local-only MVP.
- ADR-002: dinero como Long COP.
- ADR-003: catálogo de categorías en código.
- ADR-004: DI manual.

No crear ADR para decisiones triviales.

## Dependencias

Antes de añadir una dependencia:

1. explicar qué problema resuelve;
2. comprobar que plataforma/stdlib no lo resuelve razonablemente;
3. evitar librerías que dupliquen capacidades de Compose/Room para este MVP.
