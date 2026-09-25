# 05 — Roadmap

## Principio

El roadmap se implementa como slices verticales cerrados. No avanzar al siguiente slice con funcionalidades requeridas del actual incompletas.

Cada slice debe terminar con código ejecutable, pruebas asociadas y UX funcional. Gentle-AI no debe generar estructuras anticipadas parcialmente conectadas para slices futuros.

## Slice 0 — Bootstrap técnico

Objetivo: app Android compilable con arquitectura mínima y sistema visual centralizado.

Entregables:

- Proyecto Android en `app/`.
- Kotlin + Compose + Material 3.
- Navigation Compose.
- Tema y tokens.
- Room configurado sin esquema funcional definitivo más allá de lo necesario.
- AppContainer.
- Tests configurados.

Definition of Done:

- Build debug exitoso.
- Tests ejecutables.
- Navegación base funcional.

## Slice 1 — Núcleo de dominio y persistencia

Objetivo: implementar modelos e invariantes ya cerrados antes de construir UI financiera.

Entregables:

- `Transaction`, dirección, naturaleza y estado.
- `Category` configurable.
- `FinancialProduct`.
- `Person`.
- `Receivable` y pagos.
- Persistencia Room.
- Repositories y validaciones.
- Anulación lógica.

Definition of Done:

- CRUD crítico probado.
- Dinero sólo en enteros COP.
- Cambio de categoría no modifica histórico.
- Dependencias inválidas son rechazadas.

## Slice 2 — Configuración inicial y categorías

Objetivo: poder iniciar la app sin reconstruir movimientos históricos anteriores.

Entregables:

- Saldo inicial disponible.
- Semilla de categorías iniciales.
- Crear/editar/activar/desactivar categorías.
- Bloque 50/30/20 por defecto por categoría.

Definition of Done:

- Saldo inicial no participa en ingreso base.
- Categoría desactivada no aparece en nuevos movimientos.
- Histórico conserva categoría y bucket originales.

## Slice 3 — Registro de ingresos y egresos normales

Objetivo: flujo principal completo de escritura.

Entregables:

- Registrar ingreso nuevo.
- Registrar egreso.
- Categoría propone bucket por defecto.
- Bucket puede sobrescribirse en la transacción.
- Concepto opcional.
- Fecha financiera.

Definition of Done:

- Ingreso nuevo afecta disponible e ingreso base.
- Egreso afecta disponible y bucket correcto.
- Sobrescribir bucket no cambia la categoría.

## Slice 4 — Productos financieros y ahorro

Objetivo: cerrar el flujo 20% sin ambigüedades contables.

Entregables:

- Crear/editar/desactivar producto financiero.
- Saldo inicial del producto.
- Aporte de ahorro.
- Retiro de ahorro.
- Rendimiento financiero explícito.

Definition of Done:

- Aporte cuenta como 20%.
- Retiro aumenta disponible pero no ingreso base.
- No se permite saldo negativo.
- Rendimiento sí aumenta ingreso base.

## Slice 5 — Cuentas por cobrar

Objetivo: gestionar préstamos simples y pagos parciales.

Entregables:

- Personas.
- Crear préstamo asociado a persona.
- Varios préstamos por persona.
- Registrar pagos parciales.
- Saldo pendiente.
- Estado pendiente/pagado.
- Dinero total por cobrar.

Definition of Done:

- Pagos acumulados no superan monto original.
- Pago del mismo mes se trata como reintegro.
- Pago de mes posterior se trata como ingreso del nuevo período.
- La relación con el préstamo original se conserva.

## Slice 6 — Historial, edición y anulación

Objetivo: cerrar trazabilidad antes de analítica.

Entregables:

- Historial mensual por defecto.
- Filtros definidos en requisitos.
- Edición segura.
- Anulación lógica.
- Restricciones por dependencias.

Definition of Done:

- Movimientos anulados no participan en cálculos normales.
- No se puede romper un préstamo o producto mediante edición/anulación inconsistente.
- Histórico mantiene relaciones.

## Slice 7 — Dashboard mensual e indicadores

Objetivo: implementar el valor analítico central después de cerrar las fórmulas del dashboard.

Entregables:

- Saldo disponible.
- Ingreso base.
- Egresos.
- Totales por 50/30/20.
- Saldo ahorrado.
- Dinero por cobrar.
- Comparación contra metas.
- Estados sin base de cálculo.

Definition of Done:

- Fórmulas cerradas en documentación antes de codificar.
- Cálculos cubiertos por tests.
- Entradas no computables no inflan ingreso base.

## Slice 8 — Semana y año

Objetivo: generalizar consulta temporal sin cambiar reglas contables mensuales.

Entregables:

- Selector Semana/Mes/Año.
- Navegación entre períodos.
- Historial e indicadores coherentes.

Definition of Done:

- Semana = lunes-domingo.
- Cruces de mes/año probados.
- Cambiar granularidad no reclasifica reintegros históricos.

## Slice 9 — Pulido UX/UI y release MVP

Objetivo: cerrar el producto sin añadir alcance funcional.

Entregables:

- Revisión del design system.
- Accesibilidad básica.
- Estados vacíos y errores finales.
- Revisión de textos.
- Tests de flujo crítico.
- README actualizado.

Definition of Done:

- Sin funcionalidad MVP incompleta.
- Sin TODOs funcionales requeridos.
- APK de prueba compila.

## Fuera del roadmap MVP

No introducir durante estos slices:

- autenticación;
- backend;
- sincronización;
- integración bancaria;
- moneda múltiple;
- tasas de cambio;
- intereses automáticos;
- agenda/sincronización de contactos;
- notificaciones;
- widgets;
- presupuestos distintos de 50/30/20;
- exportación/importación en la primera versión.

Cualquier propuesta de estos puntos debe registrarse como post-MVP.
