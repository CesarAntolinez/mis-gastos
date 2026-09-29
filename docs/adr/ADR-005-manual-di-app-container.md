# ADR-005 — Inyección manual con AppContainer

- Estado: `Accepted`
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
