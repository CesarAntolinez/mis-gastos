# Mis Gastos

Aplicación móvil Android para registrar ingresos y egresos y analizar la distribución del dinero usando la metodología 50/30/20.

## Objetivo del MVP

- Registrar ingresos y egresos.
- Clasificar egresos en Necesidades 50%, Deseos 30% y Ahorro 20%.
- Usar categorías predefinidas.
- Consultar indicadores por semana, mes y año.
- Revisar historial de transacciones.
- Funcionar completamente offline con persistencia local.

## Stack objetivo

- Kotlin
- Jetpack Compose + Material 3
- Navigation Compose
- Room
- Coroutines + Flow
- ViewModel

## Desarrollo asistido por IA

El proyecto está pensado para trabajarse con Opencode CLI y Gentle-AI usando un enfoque guiado por especificaciones y resultados.

Antes de implementar, leer [`AGENTS.md`](./AGENTS.md).

La fuente de verdad funcional y técnica está en [`docs/`](./docs/readme.md).

## Roadmap

El desarrollo se divide en slices verticales pequeños. Cada slice debe quedar funcional y verificable antes de iniciar el siguiente.

Ver [`docs/05-roadmap.md`](./docs/05-roadmap.md).

## Regla principal de producto

Los ingresos forman la base de cálculo. Los egresos se clasifican en:

- Necesidades — objetivo 50%.
- Deseos — objetivo 30%.
- Ahorro — objetivo 20%.

Los porcentajes se calculan sobre el total de ingresos del período seleccionado.
