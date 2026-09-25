# 07 — Flujo de trabajo con Gentle-AI / Opencode

## Objetivo

Usar agentes para implementar el proyecto sin permitir que el roadmap se convierta en una colección de funcionalidades parcialmente terminadas.

## Regla principal

Un agente trabaja sobre **un solo slice activo** de `docs/05-roadmap.md`.

No debe comenzar trabajo del slice siguiente aunque parezca conveniente.

La especificación auditada está marcada `READY FOR IMPLEMENTATION` en `15-spec-audit.md`. Esto no autoriza reinterpretar requisitos: cualquier cambio observable sigue siendo spec-first.

## Secuencia recomendada por slice

### 1. Read

El agente debe leer:

- `AGENTS.md`;
- Product brief;
- requisitos relacionados;
- dominio/datos relacionados;
- escenarios de dominio aplicables;
- flujos/UX relacionados;
- `14-room-sqlite-schema.md` cuando el slice toca persistencia;
- `04-architecture.md`;
- ADRs vigentes relevantes en `docs/adr/`;
- slice activo del roadmap;
- criterios de aceptación asociados.

No es necesario releer documentos irrelevantes al slice si `AGENTS.md` y la mini-spec identifican claramente el subconjunto aplicable, pero ninguna decisión puede contradecir la fuente de verdad.

### 2. Spec

Antes de escribir código, producir una mini-especificación de implementación del slice con:

- alcance;
- archivos/componentes esperados;
- invariantes afectadas;
- tablas/consultas afectadas cuando aplique;
- pruebas necesarias;
- criterios explícitos de no-alcance.

La mini-spec no puede añadir requisitos nuevos al producto ni cambiar el schema v1 por conveniencia.

### 3. Object / Design

Definir los objetos/componentes necesarios y sus responsabilidades antes de implementarlos.

Para lógica de dominio, priorizar contratos claros y objetos pequeños.

Para UI, definir estado, eventos y componentes antes de codificar la pantalla completa.

Para persistencia, distinguir claramente:

- Entity Room;
- Projection de consulta;
- modelo de dominio;
- UiState.

No reutilizar una misma clase para todo si eso mezcla responsabilidades.

### 4. Implement

Implementar verticalmente hasta que el flujo quede operativo de extremo a extremo para ese slice.

Evitar crear infraestructura para funcionalidades futuras.

No exponer rutas, botones o menús de slices aún no implementados.

### 5. Verify

Ejecutar según aplique:

- build;
- unit tests;
- Room tests;
- UI/instrumentation tests definidos por el slice;
- revisión manual de criterios de aceptación;
- verificación de schema exportado si cambió Room.

### 6. Review

Antes de marcar terminado, responder explícitamente:

- ¿Qué criterios de aceptación cubre?
- ¿Qué pruebas lo demuestran?
- ¿Quedó algún placeholder o TODO funcional?
- ¿Se agregó algo fuera del alcance?
- ¿El schema físico sigue `14-room-sqlite-schema.md`?
- ¿Se introdujo alguna decisión que requiera ADR?

Si alguna respuesta revela trabajo incompleto, el slice no está terminado.

## Uso práctico de SDD, ODD y RDD

Este proyecto se usa como laboratorio de aprendizaje. Se propone esta interpretación operativa:

### SDD — Spec-Driven Development

La documentación en `docs/` define el comportamiento antes de escribir código.

Regla: una funcionalidad no se implementa si no puede apuntar a un requisito, flujo o criterio de aceptación existente.

Un cambio funcional descubierto durante código vuelve primero a especificación.

### ODD — Object/Outcome-Driven Design

Antes de implementar, se explicitan los objetos del dominio/UI y el resultado observable que deben producir.

Ejemplos:

- Objeto: `PeriodRange`.
- Resultado: para septiembre de 2026 en MONTH produce `2026-09-01..2026-09-30`.

- Objeto: `ReceivableSummary`.
- Resultado: préstamo activo de $200.000 con pago activo de $80.000 produce pendiente $120.000 sin almacenar ese pendiente como fuente de verdad.

- Objeto: `TransactionEffect`.
- Resultado: `SAVING_WITHDRAWAL` aumenta disponible, reduce producto y no aumenta ingreso base.

Esto evita construir clases sin un comportamiento verificable.

### RDD — Requirement/Result-Driven Development

Cada slice parte de requisitos y termina con resultados verificables mediante aceptación/tests.

Regla:

```text
roadmap item -> requisitos -> implementación -> evidencia -> Done
```

No se acepta `implementado` como evidencia por sí sola.

## Plantilla de prompt para Opencode

```text
Implementa únicamente el Slice N de docs/05-roadmap.md.

Lee primero AGENTS.md y los documentos aplicables que éste referencia.
Respeta docs/14-room-sqlite-schema.md y los ADR vigentes cuando correspondan.
No avances al siguiente slice.
No agregues funcionalidades post-MVP.

Antes de modificar código:
1. resume el alcance;
2. identifica los criterios de aceptación aplicables;
3. enumera invariantes y tablas afectadas;
4. enumera los tests que vas a crear/actualizar.

Después implementa el slice verticalmente.

Al finalizar:
- ejecuta build y tests;
- informa criterios satisfechos;
- informa cualquier desviación;
- confirma que no añadiste placeholders funcionales;
- no marques Done si queda funcionalidad requerida incompleta.
```

## Roadmap seguro para agentes

Evitar tareas como:

- `Crear dashboard` cuando todavía no existe persistencia fiable.
- `Crear toda la UI` antes de validar flujos verticales.
- `Preparar arquitectura para sync futuro`.
- `Añadir pantallas placeholder para después`.
- `Guardar saldo actual para simplificar consultas` cuando la spec lo define como derivado.

Preferir tareas como:

- `Registrar ingreso end-to-end`.
- `Registrar egreso con clasificación end-to-end`.
- `Crear préstamo + Receivable de forma atómica`.
- `Mostrar historial mensual usando datos reales`.

## Registro de desviaciones

Si durante implementación aparece una contradicción o requisito funcional faltante:

1. no improvisar comportamiento;
2. documentar la pregunta/decisión;
3. actualizar primero la especificación si se decide cambiar el producto;
4. crear/actualizar ADR si cambia una decisión técnica estable;
5. después modificar código.

Una decisión puramente interna que respeta contratos existentes no requiere detener el slice ni crear documentación innecesaria.

## Definition of Ready de un slice

Un slice está listo para ser tomado por un agente cuando:

- tiene objetivo;
- tiene entregables;
- tiene Definition of Done;
- los requisitos involucrados están definidos;
- los estados UX relevantes están definidos;
- las invariantes de datos están definidas;
- el schema requerido está definido cuando toca persistencia;
- no existe una contradicción conocida pendiente que bloquee el slice.

## Definition of Done global

`Done` significa comportamiento funcional y verificable, no sólo archivos creados o código que compila.
