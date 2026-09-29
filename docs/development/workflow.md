# Flujo de desarrollo

Este documento define cómo se transforma una necesidad de Mis Gastos en una implementación sin superponer las responsabilidades de producto, ODD, SDD y RDD.

## Principio rector

El repositorio debe tener una sola fuente de verdad para cada tipo de decisión:

| Capa | Fuente principal | Responsabilidad |
| --- | --- | --- |
| Producto | `docs/product/` | Qué debe hacer el producto y cuáles son sus reglas |
| Trabajo operativo | GitHub Issues | Qué cambio concreto está listo o pendiente |
| Ejecución | ODD / PI DEV | Investigar, implementar y verificar trabajo suficientemente entendido |
| Especificación formal | SDD | Formalizar cambios cuando se requieren proposal/spec/design/tasks/verify |
| Revisión | RDD | Obtener evidencia/revisión del candidato |
| Entrega | Git/GitHub y política del repositorio | Commit, push, PR y merge |

Ninguna capa debe duplicar o asumir silenciosamente la autoridad de otra.

## Flujo canónico

```text
Necesidad o idea
      |
      v
¿Producto/regla suficientemente definido?
   | No                    | Sí
   v                       v
Actualizar docs/product   Crear/actualizar Issue
   |                       |
   +-----------+-----------+
               v
         Issue aprobado
               |
               v
¿Se requieren artefactos formales SDD?
       | No              | Sí
       v                 v
   ODD / PI DEV          SDD explícito
       |                 |
       |              SDD Apply
       +--------+--------+
                v
          Implementación
                |
                v
      Pruebas/verificación aplicable
                |
                v
       RDD según review mode
                |
                v
       Política Git/GitHub
                |
                v
              Merge
```

## ODD y PI DEV

ODD es la ruta normal de trabajo. PI DEV debe poder:

- leer las fuentes de verdad del repositorio;
- investigar el código cuando sea necesario;
- delegar trabajo según las reglas del runtime;
- implementar cambios ya suficientemente definidos;
- ejecutar las comprobaciones funcionales aplicables;
- reportar incertidumbre cuando una decisión afecte alcance, seguridad, efectos externos o reglas de producto.

El tamaño o la dificultad de una tarea no convierten por sí solos el trabajo en SDD.

PI DEV no debe inventar nuevas reglas financieras para completar una implementación. Si falta una decisión de producto, el trabajo vuelve a `docs/product/` o al Issue correspondiente.

## Cuándo usar SDD

SDD es opcional y debe seleccionarse explícitamente cuando sus artefactos formales aportan valor.

Indicadores apropiados para proponer SDD en este repositorio incluyen:

- modificación de invariantes de `docs/product/domain-rules.md`;
- cambios importantes en el modelo de persistencia que requieran migración o compatibilidad;
- contratos nuevos entre módulos o subsistemas;
- decisiones arquitectónicas con alternativas relevantes que deban quedar registradas;
- cambios cuyo comportamiento necesite una especificación formal antes de implementar.

No se debe activar SDD automáticamente por:

- número de archivos;
- incertidumbre que pueda resolverse con investigación acotada;
- complejidad de implementación;
- riesgo por sí solo;
- uso de delegación.

Cuando SDD esté activo para un cambio, sus artefactos describen ese cambio. No reemplazan la visión, las reglas de dominio ni el roadmap del producto.

## RDD

RDD es una capa de revisión basada en evidencia y es independiente de si la implementación utilizó ODD o SDD.

RDD no decide:

- qué feature construir;
- las reglas del producto;
- si debe utilizarse SDD;
- si se autoriza un commit, push, PR, release o merge.

El review mode efectivo del ecosistema Gentle AI controla cuándo se ejecuta esta revisión. Automatizaciones o instrucciones locales del repositorio no deben habilitar o deshabilitar silenciosamente esa preferencia del usuario.

## Issues

Los Issues son el backlog operativo vivo.

Una feature request debe incluir, como mínimo, el problema, resultado propuesto, evidencia, alternativas y fuera de alcance conforme al template del repositorio.

Un Issue puede referenciar:

- reglas existentes en `docs/product/`;
- una decisión arquitectónica;
- artefactos SDD cuando existan;
- evidencia de ejecución o defectos.

No es necesario copiar specs completas dentro del Issue si existe una fuente canónica versionada.

## Roadmap

`docs/product/roadmap.md` describe capacidades y dependencias de producto, no cada tarea técnica.

El roadmap no debe duplicar manualmente todos los Issues ni prometer fechas de entrega sin una decisión explícita. GitHub Issues representa el estado operativo actual.

## Archivos de agente

`AGENT.md`, `.agents/` y configuraciones específicas del runtime deben contener únicamente contexto específico del repositorio cuando sea necesario: comandos, stack, convenciones, rutas canónicas y restricciones locales.

No deben copiar ni redefinir los contratos generales de ODD, SDD o RDD que pertenecen a Gentle AI/Gentle Shell. Tampoco deben mantener una segunda copia del roadmap o de las reglas financieras.

Cuando se necesite contexto para el agente, se debe referenciar la fuente canónica del repositorio.

## Orden de autoridad para decisiones del proyecto

Ante información contradictoria dentro del repositorio:

1. una decisión de producto explícita y vigente;
2. `docs/product/domain-rules.md` para semántica financiera;
3. artefactos SDD vigentes para el cambio concreto, cuando SDD haya sido seleccionado;
4. el Issue aprobado y su alcance;
5. implementación existente y pruebas como evidencia del comportamiento actual, no necesariamente del comportamiento deseado.

Una contradicción relevante debe resolverse antes de introducir comportamiento nuevo.

## Criterio de listo para implementar

Un cambio está listo cuando:

- el problema está identificado;
- el resultado esperado es comprensible;
- las reglas de producto afectadas están definidas;
- el alcance y los no-objetivos son suficientes para evitar decisiones implícitas importantes;
- cualquier SDD requerido fue seleccionado explícitamente y tiene los artefactos necesarios para la etapa de implementación.

A partir de ese punto PI DEV puede ejecutar el trabajo mediante la ruta correspondiente.
