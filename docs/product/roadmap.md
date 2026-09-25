# Roadmap de producto

Este roadmap describe capacidades y dependencias del producto. No es un backlog técnico ni una lista de tareas SDD. Los Issues de GitHub representan el trabajo operativo y deben enlazar la evidencia o documentación que justifica cada cambio.

El orden puede evolucionar cuando aparezca nueva evidencia, pero las dependencias del dominio deben respetarse.

## Estado 0 — Fundamentos del producto

Objetivo: establecer una fuente de verdad antes de acelerar implementación.

- [x] Definir visión y alcance inicial.
- [x] Documentar reglas centrales del dominio financiero.
- [x] Definir separación entre roadmap, Issues, ODD, SDD y RDD.
- [ ] Consolidar decisiones previas adicionales que todavía existan solo fuera del repositorio.
- [ ] Mantener Issues aprobados como backlog operativo.

## Etapa 1 — Modelo financiero base

Objetivo: poder representar correctamente el dinero antes de optimizar la experiencia visual.

Capacidades:

- gastos;
- ingresos y origen del ingreso;
- disponible;
- productos financieros propios;
- movimientos internos;
- reintegros;
- clasificación dependiente del período cuando corresponda;
- trazabilidad entre movimientos relacionados.

Criterio de salida: los casos principales definidos en `domain-rules.md` pueden representarse sin duplicar dinero ni inflar ingresos.

## Etapa 2 — Registro y operación diaria

Objetivo: permitir que el usuario mantenga sus finanzas al día con baja fricción.

Capacidades:

- creación de gastos;
- creación de ingresos;
- movimientos hacia y desde ahorro/productos financieros;
- registro de reintegros;
- validaciones y estados necesarios para evitar registros ambiguos.

Criterio de salida: los movimientos cotidianos pueden registrarse con una semántica consistente y producir un disponible explicable.

## Etapa 3 — Historial y detalle

Objetivo: hacer auditable y comprensible lo registrado.

Capacidades:

- listado/historial de movimientos;
- detalle de un movimiento;
- clasificación visible del movimiento;
- origen del dinero cuando corresponda;
- relación con movimientos previos;
- filtros básicos que resulten necesarios para navegar el historial.

Criterio de salida: el usuario puede explicar por qué cambió su disponible consultando el historial.

## Etapa 4 — Personas y dinero por cobrar

Objetivo: representar dinero entregado a terceros y su recuperación sin contaminar ingresos.

Capacidades:

- alta/identificación de personas;
- registro de dinero pendiente por cobrar;
- saldo pendiente por persona;
- devoluciones parciales o totales;
- relación con el movimiento original;
- aplicación de la regla de cambio de período.

Criterio de salida: una deuda y su devolución pueden seguirse de extremo a extremo manteniendo trazabilidad y clasificación correcta.

## Etapa 5 — Configuración

Objetivo: concentrar preferencias y parámetros que deban ser controlados por el usuario sin alterar silenciosamente las reglas del dominio.

El alcance concreto se implementará mediante Issues aprobados. Las preferencias no deben redefinir invariantes financieras salvo que exista una decisión de producto explícita.

## Etapa 6 — Onboarding

Objetivo: explicar los conceptos mínimos necesarios y dejar la aplicación preparada para el primer uso.

El onboarding debe enseñar el modelo real del producto y no introducir conceptos que contradigan `domain-rules.md`.

## Después del MVP

Las siguientes áreas requieren evaluación separada antes de incorporarse:

- automatización o importación de movimientos;
- conciliación con fuentes externas;
- analítica avanzada;
- presupuestos y metas;
- sincronización/múltiples dispositivos;
- capacidades multiusuario;
- integraciones financieras externas.

No se consideran comprometidas por aparecer en esta sección.

## Relación con el desarrollo

1. El roadmap define la capacidad deseada.
2. La documentación de producto define sus reglas.
3. Un Issue aprobado representa una unidad operativa de cambio.
4. ODD/PI DEV es la ruta normal para trabajo suficientemente entendido.
5. SDD se selecciona explícitamente cuando se necesitan proposal/spec/design/tasks/verify como artefactos formales.
6. RDD revisa evidencia de un candidato de forma independiente de la ruta de implementación.
7. La política normal del repositorio controla commit, push, PR y merge.
