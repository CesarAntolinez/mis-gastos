# ADR-001 — Framework móvil: Flutter + Dart

**Status:** accepted  
**Date:** 2026-09-25

## Context

Mis Gastos es, en su alcance actual, un producto mobile-first orientado inicialmente a Android mediante APK/AAB, con posibilidad de soportar iOS posteriormente.

La aplicación requiere:

- experiencia móvil altamente cuidada;
- UI propia, fresca y juvenil conforme a `docs/design/design-system.md`;
- temas claro y oscuro;
- motion modernamente expresivo;
- funcionamiento local-first y offline;
- persistencia relacional local;
- reglas financieras aisladas de la presentación;
- pruebas sólidas de dominio e interfaz;
- una arquitectura comprensible para desarrollo asistido por agentes.

Se evaluaron Flutter + Dart y React Native + Expo + TypeScript como alternativas principales.

## Decision

Usar **Flutter + Dart** como framework y lenguaje principal de la aplicación móvil Mis Gastos.

La dirección arquitectónica asociada será:

- **Flutter** para presentación y runtime móvil;
- **Dart** para UI, dominio y acceso a datos de la aplicación;
- **SQLite** como base de persistencia local del MVP;
- enfoque **local-first**: las capacidades centrales deben funcionar sin conexión;
- organización **feature-first con capas ligeras**, manteniendo dominio, datos y presentación separados donde aporte claridad;
- reglas financieras fuera de widgets y pantallas;
- soporte de **Android** como objetivo inicial y diseño compatible con una futura salida en **iOS**.

La selección concreta de paquetes para SQLite, routing, state management, dependency injection, gráficos u otras capacidades queda fuera de este ADR. Cada dependencia relevante debe evaluarse cuando exista una necesidad concreta; no se adopta una librería por defecto únicamente por popularidad.

## Alternatives considered

### React Native + Expo + TypeScript

Alternativa válida y madura, con ventajas importantes:

- TypeScript y ecosistema React/JavaScript amplio;
- buena experiencia de desarrollo;
- Expo simplifica builds, distribución y acceso a capacidades nativas;
- `expo-sqlite` facilita persistencia local;
- mayor posibilidad de compartir lenguaje y paquetes si en el futuro aparecen frontend web o backend TypeScript.

No se selecciona para el alcance actual porque la prioridad inmediata es la experiencia móvil como producto principal, con alto control visual, motion, theming y una superficie de desarrollo cohesionada. Compartir TypeScript con sistemas futuros no es actualmente un requisito del producto.

### Android nativo con Kotlin + Jetpack Compose

Ofrece integración Android y UI nativa de alta calidad. No se selecciona porque aumentaría el costo de una futura expansión a iOS o requeriría introducir posteriormente una estrategia multiplataforma adicional.

### Kotlin Multiplatform

Permite compartir lógica manteniendo opciones de UI nativa. No se selecciona para el MVP por introducir complejidad adicional que no está justificada por el alcance actual.

## Consequences

### Positive

- Un solo stack principal para Android y un posible iOS futuro.
- Alto control sobre composición visual, theming, componentes y animaciones.
- Testing de unidades, widgets e integración dentro del ecosistema Flutter.
- El dominio financiero puede implementarse en Dart puro y mantenerse independiente de Flutter cuando sea conveniente.
- Menor presión para introducir servicios remotos: el MVP puede construirse completamente local-first.
- La dirección técnica encaja con el Design System aprobado.

### Costs and constraints

- El proyecto adopta Dart como lenguaje específico principal del cliente móvil.
- No existe reutilización directa de lógica TypeScript con un posible frontend/backend futuro.
- Dependencias Flutter/Dart deberán evaluarse por mantenimiento, compatibilidad y necesidad real.
- La consistencia multiplataforma no elimina la obligación de validar comportamiento, accesibilidad y convenciones en cada plataforma.
- Cambiar posteriormente a React Native, Kotlin nativo u otro framework sería una migración arquitectónica significativa.

## Architectural guardrails

La estructura inicial debe tender a:

```text
lib/
├── app/
│   ├── navigation/
│   ├── theme/
│   └── bootstrap/
├── core/
│   ├── database/
│   ├── money/
│   └── shared/
└── features/
    ├── transactions/
    ├── accounts/
    ├── debts/
    ├── history/
    ├── settings/
    └── onboarding/
```

Esta estructura es una dirección, no una obligación de crear carpetas vacías ni capas ceremoniales.

Dentro de una feature, separar `domain`, `data` y `presentation` cuando exista una responsabilidad real que separar. No crear abstracciones sin uso actual o próximo claramente identificado.

Los widgets pueden presentar y capturar estado de UI, pero no deben decidir invariantes financieras. Clasificaciones como ingreso, reintegro, movimiento interno o tratamiento de una devolución entre períodos pertenecen al dominio definido en `docs/product/domain-rules.md`.

SQLite será una implementación de persistencia detrás de límites que permitan evolucionar posteriormente hacia sincronización sin convertir una API remota en requisito para operar la aplicación.

## Follow-up decisions

Este ADR no decide todavía:

- paquete/capa SQLite;
- estrategia de migrations/schema;
- state management;
- routing/navigation package;
- dependency injection;
- librería de gráficos;
- estrategia futura de sync/cloud;
- observabilidad/analytics;
- pipeline de CI/CD y firma de APK/AAB.

Estas decisiones deben tomarse cuando su contexto sea suficientemente concreto, siguiendo `AGENT.md` y evitando incorporar infraestructura prematuramente.

## References

- `AGENT.md`
- `docs/product/vision.md`
- `docs/product/domain-rules.md`
- `docs/product/roadmap.md`
- `docs/development/workflow.md`
- `docs/design/design-system.md`
