# Navegación y flujos de producto

Este documento define la estructura de navegación del MVP, el comportamiento de la acción global `+ Registrar`, las interacciones del Dashboard y las reglas de preservación de estado y retroceso. No reproduce las fórmulas contables ni la semántica de cada operación: esas reglas están en [`budgeting.md`](./budgeting.md), [`domain-rules.md`](./domain-rules.md), [`history.md`](./history.md), [`configuration.md`](./configuration.md), [`onboarding.md`](./onboarding.md) y en [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md).

## Resumen

- La navegación principal tiene tres pestañas: `Resumen`, `Historial` y `Configuración`.
- Una acción global `+ Registrar` está disponible desde `Resumen` e `Historial`.
- El Dashboard separa el **estado actual a hoy** del **rendimiento del período seleccionado**.
- Tocar una tarjeta del Dashboard abre el detalle o historial correspondiente, conservando el período seleccionado y llevando filtros removibles.
- Después del onboarding, la aplicación entra al flujo principal y el onboarding desaparece del historial de navegación.
- La navegación hacia atrás conserva el contexto razonable durante la sesión, sin duplicar destinos principales.
- Toda la interfaz respeta accesibilidad básica y se basa en el sistema visual centralizado.

## Navegación principal

Las tres pestañas inferiores del MVP son:

1. `Resumen` — Dashboard con estado actual, indicadores del período y movimientos recientes.
2. `Historial` — Listado trazable de operaciones con búsqueda y filtros.
3. `Configuración` — Gestión de categorías, productos financieros y personas.

No se agregan destinos principales adicionales para Ahorro o Por cobrar: se alcanzan desde `Resumen` y `Configuración` para mantener la navegación pequeña.

## Dashboard / Resumen

### Separación entre estado actual y período

El Dashboard muestra dos grupos bien diferenciados:

- **Estado actual · hoy**: `Disponible actual`, `Ahorrado actual` y `Por cobrar actual`. Estas cifras representan el estado global derivado de todos los movimientos activos hasta hoy y **no cambian** al navegar a un período histórico.
- **Rendimiento del período seleccionado**: ingreso base, bloques `Necesidades 50%`, `Deseos 30%`, `Ahorro 20%`, últimos movimientos y, opcionalmente, un resumen de entradas y salidas de caja del período.

La UI no debe inducir a interpretar los saldos actuales como cifras históricas del período consultado.

### Interacciones de tarjetas

- `Disponible actual`: informativa en el MVP; no abre un destino a menos que tenga un valor claro.
- `Ahorrado actual`: abre la lista de **Productos financieros**.
- `Por cobrar actual`: abre la lista de **cuentas por cobrar pendientes**.
- `Necesidades 50%`: abre `Historial` con el período actual del Dashboard y un filtro removible de `Necesidades`.
- `Deseos 30%`: abre `Historial` con el período actual del Dashboard y un filtro removible de `Deseos`.
- `Ahorro 20%`: abre `Historial` con el período actual del Dashboard y un filtro removible sobre operaciones de ahorro.
- Últimos movimientos: tocar un movimiento abre su detalle; `Ver todos` abre `Historial` conservando el período cuando aplique.

Los filtros recibidos desde el Dashboard deben ser visibles y removibles sin perder el período seleccionado.

### Sin controles muertos

Ningún control navegable visible debe conducir a un placeholder o a una funcionalidad cuya persistencia, validaciones y flujo completo no estén implementados.

## Acción global `+ Registrar`

La acción `+ Registrar` abre un selector breve con operaciones escritas en lenguaje humano. Nunca se le pide a la persona elegir un enum técnico como `TransactionNature`.

Orden y agrupación recomendados:

```text
Movimiento diario
- Ingreso
- Gasto

Mover / recuperar dinero
- Ahorrar
- Retirar ahorro
- Reintegro / devolución

Dinero prestado
- Prestar dinero
- Registrar pago recibido

Producto financiero
- Registrar rendimiento
```

### Operaciones que dependen de configuración previa

Si una operación no puede completarse por falta de una entidad previa, no se abre un formulario roto. La UI debe:

- explicar brevemente qué falta;
- ofrecer una acción previa válida, como `Crear producto` o `Crear persona`;
- o mostrar un estado vacío explicativo con opción de volver.

Ejemplos:

- `Ahorrar` sin productos financieros: explicación + `Crear producto`.
- `Registrar pago recibido` sin cuentas pendientes: estado vacío + opción de volver.
- `Prestar dinero` sin personas: permitir crear la persona dentro del flujo o mediante una acción clara antes de continuar.

### No exponer flujos incompletos

No se añade una opción al selector `+ Registrar` mientras su formulario, persistencia, validaciones y reglas de dominio no estén terminados. Cada opción del selector representa un slice completo.

## Comportamiento después del onboarding

Cuando el onboarding se completa de forma atómica:

1. Se guardan categorías seed, saldo inicial, productos iniciales y el estado de finalización como una operación lógica única.
2. La aplicación muestra el flujo principal con las pestañas `Resumen`, `Historial` y `Configuración`.
3. El onboarding se elimina del historial de navegación: pulsar atrás desde `Resumen` no regresa al onboarding.

Si el onboarding no se ha completado, la aplicación inicia en el flujo de onboarding. Ver [`onboarding.md`](./onboarding.md).

## Navegación hacia atrás y preservación de estado

- Volver desde el **detalle** de un movimiento conserva el período, la búsqueda y los filtros activos del `Historial` durante la sesión.
- Volver desde `+ Registrar` sin guardar regresa al destino desde el que se abrió.
- Después de **guardar correctamente**, la aplicación vuelve al destino de origen y refresca los datos sin crear una nueva instancia duplicada de `Resumen` o `Historial` en el historial de navegación.
- Cambiar entre pestañas conserva razonablemente el período y los filtros durante la sesión. No es necesario persistirlos entre cierres de la aplicación en el MVP.

## Accesibilidad y sistema visual

La navegación debe ser usable para todas las personas que cumplan con los requisitos básicos del dispositivo:

- contraste suficiente para texto, iconos y controles;
- áreas táctiles mínimas cómodas, idealmente alrededor de `44–48` puntos/píxeles lógicos según plataforma;
- soporte razonable para el tamaño de texto del sistema, sin romper jerarquía ni navegación;
- labels accesibles para iconos y controles;
- respeto a la preferencia del sistema de reducción de movimiento;
- el color nunca es el único indicador de estado: se combina con texto, signo, icono, posición o etiqueta.

Los colores, tipografía, formas, espaciado y componentes principales provienen del sistema visual centralizado definido en [`docs/design/design-system.md`](../design/design-system.md).

## Relación con otras fuentes de verdad

| Tema | Documento |
|------|-----------|
| Semántica de operaciones e invariantes financieras | [`domain-rules.md`](./domain-rules.md) |
| Fórmulas de ingreso base, gasto efectivo, metas y estados | [`budgeting.md`](./budgeting.md) |
| Historial, detalle, edición, anulación y filtros | [`history.md`](./history.md) |
| Categorías, productos financieros y personas | [`configuration.md`](./configuration.md) |
| Onboarding y finalización inicial | [`onboarding.md`](./onboarding.md) |
| Sistema visual y accesibilidad | [`docs/design/design-system.md`](../design/design-system.md) |
| Fundamento arquitectónico de la semántica contable | [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md) |

## Checklist de revisión

- [ ] Las tres pestañas inferiores son `Resumen`, `Historial` y `Configuración`.
- [ ] `+ Registrar` está disponible desde `Resumen` e `Historial` y usa nombres comprensibles.
- [ ] El Dashboard separa visualmente el estado actual a hoy del rendimiento del período seleccionado.
- [ ] Al cambiar de período histórico, `Disponible`, `Ahorrado` y `Por cobrar` no cambian.
- [ ] Tocar una tarjeta del Dashboard abre el detalle o historial correspondiente conservando el período y llevando filtros removibles.
- [ ] No hay controles navegables que abran placeholders ni flujos sin persistencia completa.
- [ ] Después del onboarding, la app entra al flujo principal y el onboarding sale del historial de navegación.
- [ ] La navegación hacia atrás conserva el contexto razonable y no duplica destinos principales.
- [ ] Se cumplen criterios básicos de accesibilidad y se usa el sistema visual centralizado.
