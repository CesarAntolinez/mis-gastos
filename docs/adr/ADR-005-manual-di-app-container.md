# ADR-005 — Inyección manual con AppContainer

> **Histórico / legacy — superseded.** Este ADR pertenece a la era Kotlin/Room del proyecto y **ya no es autoridad de implementación activa**. La inyección manual con `AppContainer` fue reemplazada por [`docs/architecture/decisions/003-state-management.md`](../architecture/decisions/003-state-management.md) (Riverpod como mecanismo de estado y composición de dependencias). `AppContainer`, Kotlin, Jetpack Compose y la arquitectura manual descrita aquí están obsoletas para la implementación actual.

- Estado: `Accepted` (en su momento, era Kotlin/Room)
- Fecha: 2026-09-25

## Contexto

El MVP tiene un número pequeño de repositorios, DAOs, servicios de dominio y ViewModels. Introducir un framework de DI agregaría configuración y abstracciones sin una necesidad demostrada.

## Decisión

Usar composición manual de dependencias mediante `AppContainer`.

- `AppContainer` construye Database, DAOs, repositorios y servicios compartidos.
- ViewModels reciben dependencias explícitas mediante factories o mecanismos simples compatibles con Compose.
- No introducir Hilt/Koin/Dagger en el MVP.
- Las interfaces de dominio no dependen de `AppContainer`.

## Consecuencias

### Positivas

- Menor complejidad conceptual y de build.
- Dependencias explícitas y fáciles de seguir para agentes.
- Testing sencillo mediante sustitución manual de implementaciones.

### Costes

- Más wiring explícito.
- Si crece sustancialmente el grafo de dependencias, el contenedor manual puede volverse repetitivo.

## Revisión futura

Si el proyecto crece hasta hacer costosa la composición manual, evaluar un framework DI mediante un ADR que compare complejidad real, testing y mantenimiento.
