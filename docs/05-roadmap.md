# 05 — Roadmap

## Principio

El roadmap se implementa como slices verticales cerrados. No avanzar al siguiente slice con funcionalidades requeridas del actual incompletas.

Cada slice debe terminar con código ejecutable, pruebas asociadas y UX funcional. Gentle-AI no debe generar estructuras anticipadas parcialmente conectadas para slices futuros.

El esquema físico Room/SQLite v1 ya está congelado en `14-room-sqlite-schema.md`. Los slices deben implementarlo progresivamente sin inventar tablas o columnas paralelas.

## Slice 0 — Bootstrap técnico

Objetivo: app Android compilable con arquitectura mínima y sistema visual centralizado.

Entregables:

- Proyecto Android en `app/`.
- Kotlin + Compose + Material 3.
- Navigation Compose.
- Tema y tokens.
- Room configurado con `exportSchema = true` y estructura preparada para el schema v1.
- Coroutines + Flow.
- `AppContainer` manual.
- Abstracción de reloj/fecha para tests deterministas.
- Tests configurados.

Definition of Done:

- Build debug exitoso.
- Tests ejecutables.
- Navegación base funcional.
- Schema export de Room habilitado y versionable.
- No `fallbackToDestructiveMigration` como estrategia de producto.

## Slice 1 — Núcleo de dominio y persistencia

Objetivo: implementar modelos e invariantes centrales junto con el esquema Room v1 aprobado.

Entregables:

- `Transaction`, dirección, naturaleza y estado.
- `Category`.
- `FinancialProduct`.
- `Person`.
- `Receivable` y `ReceivablePayment` relacionales sin duplicar monto/fecha.
- `AppSetup`.
- Entities, converters y foreign keys según `14-room-sqlite-schema.md`.
- DAOs básicos y proyecciones críticas.
- Repositories e invariantes.
- Anulación lógica.

Definition of Done:

- CRUD crítico probado.
- Converters probados.
- Foreign keys restrictivas verificadas.
- Dinero sólo en enteros COP.
- Enums persistidos por nombre, no ordinal.
- `transactions` es fuente de verdad de montos/fechas de movimientos.
- Movimientos `VOIDED` quedan fuera de cálculos normales.
- Dependencias inválidas son rechazadas.

## Slice 2 — Onboarding y categorías

Objetivo: iniciar la app sin reconstruir movimientos históricos anteriores.

Entregables:

- Flujo de onboarding de `13-onboarding.md`.
- `AppSetup.onboardingCompleted`.
- Saldo inicial disponible mediante `OPENING_BALANCE` cuando sea > 0.
- Semilla idempotente de categorías.
- Productos financieros iniciales opcionales.
- Crear/editar/activar/desactivar categorías.
- Bloque `NEEDS/WANTS` por defecto por categoría.

Definition of Done:

- Onboarding puede finalizar con todo en cero.
- Confirmación final es atómica.
- Reiniciar app no duplica seed ni inicialización.
- Saldo inicial no participa en ingreso base.
- Opening balance de producto no cuenta como 20% del período.
- Categoría desactivada no aparece en nuevos movimientos.
- Histórico conserva bucket original.

## Slice 3 — Registro de ingresos y egresos normales

Objetivo: flujo principal completo de escritura.

Entregables:

- Registrar `NEW_INCOME`.
- Registrar `EXPENSE`.
- Categoría propone bucket.
- Bucket puede sobrescribirse en la transacción.
- Concepto opcional.
- Fecha financiera.
- Validaciones de naturaleza/campos.

Definition of Done:

- Ingreso nuevo afecta disponible e ingreso base.
- Egreso afecta disponible y bucket correcto.
- Sobrescribir bucket no cambia la categoría.
- No se permiten combinaciones de columnas inválidas por naturaleza.

## Slice 4 — Productos financieros y ahorro

Objetivo: cerrar el flujo 20% sin ambigüedades contables.

Entregables:

- Crear/editar/desactivar producto financiero.
- Saldo inicial del producto.
- `SAVING`.
- `SAVING_WITHDRAWAL`.
- `FINANCIAL_RETURN`.
- Consultas de saldo derivado.

Definition of Done:

- Aporte cuenta como 20%.
- Retiro aumenta disponible pero no ingreso base.
- Retiro no reduce cumplimiento 20% del período.
- No se permite saldo negativo.
- Producto con saldo distinto de cero no puede desactivarse.
- Rendimiento aumenta producto e ingreso base, no disponible.

## Slice 5 — Cuentas por cobrar

Objetivo: gestionar préstamos simples y pagos parciales usando transacciones como fuente de verdad.

Entregables:

- Personas.
- Crear préstamo asociado a persona.
- `Receivable` enlazado a `LOAN`.
- Varios préstamos por persona.
- Pagos parciales con `LOAN_REPAYMENT` + `ReceivablePayment`.
- Pendiente y estado derivados.
- Dinero total por cobrar.

Definition of Done:

- Crear préstamo es atómico.
- Registrar pago es atómico.
- Pagos acumulados no superan préstamo original.
- Pago no puede tener fecha anterior al préstamo.
- Pago del mismo mes no aumenta ingreso base.
- Pago de mes posterior sí aumenta ingreso base.
- `Receivable` no duplica monto, fecha, concepto, pendiente ni estado persistido.

## Slice 6 — Reintegros, Historial, edición y anulación

Objetivo: cerrar trazabilidad y devoluciones antes de analítica.

Entregables:

- Reintegro/devolución de gasto ordinario.
- `REIMBURSEMENT` mismo mes.
- devolución tardía como `NEW_INCOME` relacionada.
- Historial mensual por defecto.
- Búsqueda y filtros de `11-history.md`.
- Detalle con efecto financiero.
- Edición segura.
- Anulación lógica.
- Restricciones por dependencias.

Definition of Done:

- Reintegros acumulados no superan gasto origen.
- Devolución no puede tener fecha anterior al gasto.
- Historial muestra origen y devolución por separado.
- Movimientos anulados no participan en cálculos normales.
- No se puede romper una relación mediante edición/anulación inconsistente.
- Anulados se consultan sólo lectura y no se restauran.

## Slice 7 — Dashboard mensual e indicadores

Objetivo: implementar el valor analítico central usando el contrato ya cerrado.

Entregables:

- Saldo disponible actual.
- Ingreso base.
- Flujo de caja del período.
- Necesidades 50%.
- Deseos 30%.
- Ahorro 20%.
- Saldo ahorrado.
- Dinero por cobrar.
- Comparación contra metas y estados.
- Estado `NO_BASE`.

Definition of Done:

- Fórmulas implementadas según `09-indicators-dashboard.md`.
- Cálculos cubiertos por tests.
- Entradas no computables no inflan ingreso base.
- Anulados excluidos.
- ViewModel/UI no duplican fórmulas.

## Slice 8 — Semana y año

Objetivo: generalizar consulta temporal sin cambiar reglas contables mensuales.

Entregables:

- Selector Semana/Mes/Año.
- Navegación entre períodos.
- Historial e indicadores coherentes.

Definition of Done:

- Semana = lunes-domingo.
- Cruces de mes/año probados.
- Cambiar granularidad no reclasifica pagos/reintegros históricos.
- Año calcula objetivos desde totales anuales, no promedios mensuales.

## Slice 9 — Configuración completa

Objetivo: cerrar gestión de datos maestros sin ampliar alcance financiero.

Entregables:

- Categorías completas.
- Productos financieros completos.
- Personas completas.
- Reactivación con validación de unicidad.
- Estados vacíos y confirmaciones de `12-configuration.md`.

Definition of Done:

- Nombres activos normalizados son únicos por tipo.
- Producto con saldo no puede desactivarse.
- Persona con pendiente no puede desactivarse.
- `openingBalance` queda bloqueado después de existir histórico.
- Desactivar/reactivar nunca reescribe histórico.

## Slice 10 — Pulido UX/UI y release MVP

Objetivo: cerrar el producto sin añadir alcance funcional.

Entregables:

- revisión del design system;
- accesibilidad básica;
- estados vacíos y errores finales;
- revisión de textos;
- tests de flujo crítico;
- README actualizado;
- revisión final de schema exportado.

Definition of Done:

- Sin funcionalidad MVP incompleta.
- Sin TODOs funcionales requeridos.
- Sin rutas/controles a placeholders.
- APK de prueba compila.
- Tests aplicables pasan.

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
- exportación/importación;
- FTS/búsqueda avanzada sin evidencia de necesidad;
- triggers SQLite para lógica financiera;
- materialización de balances/indicadores sin ADR y evidencia de rendimiento.

Cualquier propuesta de estos puntos debe registrarse como post-MVP.
