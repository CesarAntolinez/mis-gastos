# 07 — Flujo de trabajo con Gentle-AI / Opencode

## Objetivo

Usar agentes para implementar el proyecto sin permitir que el roadmap se convierta en una colección de funcionalidades parcialmente terminadas.

## Regla principal

Un agente trabaja sobre **un solo slice activo** de `docs/05-roadmap.md`.

No debe comenzar trabajo del slice siguiente aunque parezca conveniente.

## Secuencia recomendada por slice

### 1. Read

El agente debe leer:

- `AGENTS.md`
- Product brief
- Requisitos relacionados
- Dominio/datos relacionados
- UX/UI relacionada
- Arquitectura
- Slice activo
- Criterios de aceptación asociados

### 2. Spec

Antes de escribir código, producir una mini-especificación de implementación del slice con:

- alcance;
- archivos/componentes esperados;
- invariantes afectadas;
- pruebas necesarias;
- criterios explícitos de no-alcance.

La mini-spec no puede añadir requisitos nuevos al producto.

### 3. Object / Design

Definir los objetos/componentes necesarios y sus responsabilidades antes de implementarlos.

Para lógica de dominio, priorizar contratos claros y objetos pequeños.

Para UI, definir estado, eventos y componentes antes de codificar la pantalla completa.

### 4. Implement

Implementar verticalmente hasta que el flujo quede operativo de extremo a extremo para ese slice.

Evitar crear infraestructura para funcionalidades futuras.

### 5. Verify

Ejecutar:

- build;
- unit tests;
- Room tests cuando aplique;
- UI/instrumentation tests definidos por el slice;
- revisión manual de criterios de aceptación.

### 6. Review

Antes de marcar terminado, responder explícitamente:

- ¿Qué criterios de aceptación cubre?
- ¿Qué pruebas lo demuestran?
- ¿Quedó algún placeholder o TODO funcional?
- ¿Se agregó algo fuera del alcance?
- ¿Se introdujo alguna decisión que requiera ADR?

Si alguna respuesta revela trabajo incompleto, el slice no está terminado.

## Uso práctico de SDD, ODD y RDD

Este proyecto se usa como laboratorio de aprendizaje. Se propone esta interpretación operativa:

### SDD — Spec-Driven Development

La documentación en `docs/` define el comportamiento antes de escribir código.

Regla: una funcionalidad no se implementa si no puede apuntar a un requisito o criterio de aceptación existente.

### ODD — Object/Outcome-Driven Design

Antes de implementar, se explicitan los objetos del dominio/UI y el resultado observable que deben producir.

Ejemplo:

- Objeto: `PeriodRange`.
- Resultado: para septiembre de 2026 en MONTH produce 2026-09-01..2026-09-30.

- Objeto: `BudgetDistribution`.
- Resultado: con ingreso 1.000.000 y Needs 550.000 produce 55% y delta +5 pp.

Esto evita construir clases sin un comportamiento verificable.

### RDD — Requirement/Result-Driven Development

Cada slice parte de requisitos y termina con resultados verificables mediante aceptación/tests.

Regla: `roadmap item -> requisitos -> implementación -> evidencia -> Done`.

No se acepta `implementado` como evidencia por sí sola.

## Plantilla de prompt para Opencode

```text
Implementa únicamente el Slice N de docs/05-roadmap.md.

Lee primero AGENTS.md y los documentos enlazados.
No avances al siguiente slice.
No agregues funcionalidades post-MVP.

Antes de modificar código:
1. resume el alcance;
2. identifica los criterios de aceptación aplicables;
3. enumera los tests que vas a crear/actualizar.

Después implementa el slice verticalmente.

Al finalizar:
- ejecuta build y tests;
- informa criterios satisfechos;
- informa cualquier desviación;
- no marques Done si queda funcionalidad requerida incompleta.
```

## Roadmap seguro para agentes

Evitar tareas como:

- `Crear dashboard` cuando todavía no existe persistencia fiable.
- `Crear toda la UI` antes de validar flujos verticales.
- `Preparar arquitectura para sync futuro`.
- `Añadir pantallas placeholder para después`.

Preferir tareas como:

- `Registrar ingreso end-to-end`.
- `Registrar egreso con clasificación end-to-end`.
- `Mostrar historial mensual usando datos reales`.

## Registro de desviaciones

Si durante implementación aparece una contradicción o requisito faltante:

1. no improvisar comportamiento;
2. documentar la pregunta/decisión;
3. actualizar primero la especificación si se decide cambiar el producto;
4. después modificar código.

## Definition of Ready de un slice

Un slice está listo para ser tomado por un agente cuando:

- tiene objetivo;
- tiene entregables;
- tiene Definition of Done;
- los requisitos involucrados están definidos;
- los estados UX relevantes están definidos;
- las invariantes de datos están definidas.

## Definition of Done global

`Done` significa comportamiento funcional y verificable, no sólo archivos creados o código que compila.
