# ADR-008 — Entorno de desarrollo reproducible con Docker

**Status:** accepted  
**Date:** 2026-09-28

## Context

Mis Gastos será desarrollado con Flutter/Dart, pero no todos los colaboradores o agentes dispondrán inicialmente de un entorno Flutter/Android configurado en el host. PI DEV necesita poder ejecutar de forma determinista las comprobaciones y builds principales del proyecto.

El desarrollo interactivo móvil, especialmente hot reload, emuladores y dispositivos físicos, tiene requisitos de USB/ADB, virtualización y gráficos que pueden hacer innecesariamente complejo un entorno completamente encapsulado.

## Decision

Mantener un **entorno Docker reproducible como contrato de tooling del repositorio**, especialmente para PI DEV y futuras automatizaciones.

El contenedor deberá proporcionar, con versiones fijadas o controladas por el repositorio:

- Flutter SDK / Dart;
- JDK requerido por el toolchain Android;
- Android SDK command-line/build tools necesarios para compilar;
- dependencias de sistema necesarias para Flutter Android;
- acceso a los comandos estándar del proyecto.

El workflow Docker deberá soportar como mínimo:

```text
flutter pub get
format/check
flutter analyze
flutter test
Drift/build_runner generation
Android APK build
```

La implementación puede usar `Dockerfile`, `compose.yaml`, scripts o wrappers pequeños para mantener los comandos estables y comprensibles.

## Host boundary

Docker es obligatorio como entorno reproducible soportado para checks, generación y build, pero **no es obligatorio ejecutar la aplicación interactiva dentro de Docker**.

El host puede instalar Flutter y Android SDK/ADB para:

- `flutter run`;
- hot reload/hot restart;
- debugging interactivo;
- emulador Android;
- dispositivo Android físico.

Android Studio no es requisito arquitectónico del repositorio. Puede utilizarse como IDE/emulator manager si el desarrollador lo desea.

## Android emulator

Ejecutar un emulador Android dentro del contenedor queda fuera del entorno estándar.

No diseñar el workflow principal alrededor de nested virtualization, forwarding gráfico o USB passthrough complejo.

Un APK debe poder construirse sin emulador.

## PI DEV contract

PI DEV debe preferir los comandos documentados del repositorio en lugar de asumir instalaciones globales del host.

Antes de considerar terminada una implementación que afecte código Flutter, ejecutar los checks aplicables mediante el entorno reproducible cuando esté disponible.

Como mínimo para cambios normales de aplicación:

```text
format/check
flutter analyze
flutter test
```

Cuando el cambio afecte generación Drift u otro código generado, ejecutar también la generación/verificación correspondiente.

Cuando el Issue/criterio de aceptación requiera un artefacto Android, validar el build APK/AAB correspondiente.

## Versioning

La versión de Flutter utilizada por el proyecto debe quedar fijada o identificada de forma inequívoca en el repositorio/imagen de desarrollo. No depender implícitamente de `latest` para builds reproducibles.

Android SDK/JDK relevantes deben mantenerse compatibles con esa versión de Flutter.

Las actualizaciones significativas del toolchain deben hacerse deliberadamente, ejecutar la suite aplicable y documentarse cuando introduzcan consecuencias arquitectónicas o de compatibilidad.

## Alternatives considered

### Tooling únicamente instalado en el host

Es la experiencia interactiva más directa, pero deja a agentes/CI y nuevos colaboradores sujetos a configuración específica de cada máquina.

### Todo dentro de Docker, incluido emulador

Aumenta aislamiento pero añade complejidad de virtualización, gráficos, ADB y dispositivos que no aporta valor proporcional al flujo normal.

### IDE/dev environment específico obligatorio

No se selecciona. El contrato debe ser CLI/repository-driven para que pueda ser usado por humanos, PI DEV y automatización.

## Consequences

### Positive

- PI DEV dispone de un entorno reproducible.
- Menor divergencia de versiones entre colaboradores y automatizaciones.
- Analyze, tests, codegen y builds Android pueden ejecutarse sin preparar manualmente todo el host.
- El desarrollador conserva una experiencia local rápida para UI/hot reload cuando instale Flutter/ADB en el host.

### Costs

- La imagen Docker incluirá un toolchain Android relativamente pesado.
- Habrá que mantener versiones de Flutter/JDK/Android SDK compatibles.
- El primer build puede requerir descargas y espacio significativo.
- Algunas pruebas que dependan de dispositivo/emulador seguirán requiriendo un entorno host/device separado.

## Guardrails

- No usar tags `latest` como única definición de toolchain reproducible.
- No introducir secretos, keystores de producción o credenciales en la imagen.
- Mantener caches como optimización, no como requisito para builds correctos.
- Los comandos Docker deben funcionar desde un checkout limpio con las instrucciones documentadas.
- No exigir emulador para `flutter analyze`, unit/widget tests o build APK.
- No introducir Android Studio como dependencia obligatoria de PI DEV.

## Initial implementation

La primera implementación de este ADR forma parte del Issue #1, `Bootstrap Flutter and first expense vertical slice`.

Ese Issue debe crear el entorno real y demostrar que el contrato funciona ejecutando analyze/tests/code generation y produciendo un APK Android.

## References

- `AGENT.md`
- `docs/development/workflow.md`
- `docs/architecture/decisions/001-mobile-framework.md`
- `docs/architecture/decisions/002-persistence.md`
- GitHub Issue #1
