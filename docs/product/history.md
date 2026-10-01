# Historial de movimientos

El Historial es la superficie de trazabilidad financiera del MVP. Muestra cada operación real en su fecha financiera, preserva las relaciones entre movimientos y permite consultar, filtrar, buscar, editar y anular operaciones conforme a las reglas del dominio.

La semántica de cada tipo de operación se define en [`domain-rules.md`](./domain-rules.md). Las fórmulas de ingreso base, gasto efectivo y ahorro del período están en [`budgeting.md`](./budgeting.md). Las decisiones arquitectónicas que fundamentan este modelo están en [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md).

## Principios

- **El Historial muestra movimientos reales, no neteados.** Si un gasto y su reintegro ocurrieron en fechas distintas, ambos aparecen por separado en sus fechas financieras reales, aunque el Dashboard use el costo efectivo neto.
- **Trazabilidad antes que resumen.** El Historial no reinterpreta los agregados del Dashboard; conserva cada evento para auditoría.
- **Significado financiero explícito.** Cada fila y cada detalle derivan su etiqueta y efecto del tipo de operación y sus vínculos causales, no solo de la dirección contable.

## Estado inicial

Al abrir Historial desde la navegación principal:

| Aspecto | Valor por defecto |
|---|---|
| Granularidad | Mes |
| Período | Mes actual |
| Orden | `transactionDate DESC`, luego `createdAt DESC` |
| Estado | Activos (`ACTIVE`) |
| Filtros adicionales | Ninguno |
| Búsqueda | Vacía |

El criterio `createdAt DESC` estabiliza el orden cuando varias operaciones comparten la misma fecha financiera.

## Estructura de pantalla

Orden recomendado de los elementos:

1. Título `Historial`.
2. Selector de granularidad `Semana | Mes | Año`.
3. Navegación período anterior / siguiente.
4. Campo de búsqueda textual.
5. Botón `Filtros`.
6. Chips de filtros activos.
7. Lista agrupada por fecha financiera.
8. Estado vacío correspondiente.
9. Acción global `+ Registrar`.

## Contenido de una fila

Cada fila muestra como máximo:

- icono semántico;
- título principal;
- contexto o concepto secundario cuando exista;
- monto con signo visual;
- etiqueta de clasificación o naturaleza relevante.

No se saturan las filas con todos los metadatos; el detalle contiene la información completa.

### Etiquetas visibles

La etiqueta refleja el efecto contable real determinado por dominio. Ejemplos:

| Operación | Etiqueta visible |
|---|---|
| Gasto ordinario | `Necesidades` / `Deseos` según bucket histórico |
| Ingreso nuevo | `Ingreso` |
| Aporte a ahorro | `Ahorro` |
| Retiro de ahorro | `Retiro de ahorro` |
| Préstamo | `Préstamo` + `Por cobrar` |
| Pago recibido mismo mes | `Reintegro` |
| Pago recibido mes posterior | `Ingreso computable` |
| Rendimiento financiero | `Rendimiento financiero` |

## Agrupación por fecha

Las operaciones se agrupan visualmente por `transactionDate`. Para fechas recientes pueden usarse etiquetas como `Hoy` y `Ayer` si se mantiene la claridad; en períodos históricos se usa la fecha legible.

## Filtros

El botón `Filtros` abre una superficie (bottom sheet o equivalente) con los siguientes filtros soportados:

### Dirección / efecto de caja

- Todas.
- Entradas.
- Salidas.

### Bloque 50/30/20

- Necesidades.
- Deseos.
- Ahorro.

### Naturaleza visible

- Ingreso.
- Gasto.
- Ahorro.
- Retiro de ahorro.
- Préstamo.
- Pago recibido.
- Reintegro / devolución.
- Rendimiento financiero.
- Saldo inicial cuando sea necesario para auditoría.

### Categoría

Permite seleccionar categorías activas e históricas/inactivas que tengan movimientos dentro del universo consultable.

### Persona

Personas relacionadas con movimientos (por ejemplo, deudores de préstamos).

### Producto financiero

Productos relacionados con aportes, retiros o rendimientos.

### Estado

- Activos — default.
- Anulados.
- Todos.

## Chips y limpieza de filtros

Cuando existen filtros activos se muestran como chips removibles individualmente. Debe existir una acción `Limpiar filtros`. Limpiar filtros no cambia el período seleccionado.

## Búsqueda

El MVP incluye búsqueda textual simple que busca al menos por:

- concepto;
- nombre de categoría;
- nombre de persona;
- nombre de producto financiero.

No se requiere fuzzy search, ranking complejo ni full-text search especializado para el MVP. La búsqueda y los filtros pueden combinarse.

## Entrada prefiltrada desde Dashboard

Al abrir Historial desde una tarjeta del Dashboard:

- conservar el `PeriodRange`/granularidad correspondiente;
- aplicar el filtro explícito como chip removible;
- no perder el período al eliminar el filtro recibido.

Mapeo mínimo:

| Tarjeta Dashboard | Filtro aplicado |
|---|---|
| Necesidades 50% | `NEEDS` |
| Deseos 30% | `WANTS` |
| Ahorro 20% | aportes `SAVING` del período |
| Ver todos de Últimos movimientos | período del Dashboard sin filtro de bucket adicional |

## Totales en Historial

El Historial no compite con el Dashboard como superficie analítica. Puede mostrar de forma secundaria:

- cantidad de movimientos visibles;
- opcionalmente, flujo de caja de los resultados visibles (`Entradas` / `Salidas`).

Estos totales son flujo de caja de los resultados visibles, no sustituyen ingreso base ni indicadores 50/30/20.

## Detalle de movimiento

Tocar una fila abre el Detalle. Debe mostrar según aplique:

- monto;
- etiqueta humana de naturaleza/operación;
- fecha financiera;
- concepto;
- categoría;
- bucket histórico;
- persona;
- producto financiero;
- estado;
- movimientos relacionados;
- efecto financiero explicado;
- acciones Editar / Anular cuando correspondan.

### Efecto financiero explicado

El detalle incluye una sección `Efecto financiero` calculada por la capa de dominio, no recalculada manualmente por la UI. El dominio entrega una representación estructurada (por ejemplo, `TransactionEffect` o equivalente) que indica el impacto en disponible, ingreso base, producto financiero, cuenta por cobrar y bloque presupuestal.

Ejemplo de gasto ordinario:

```text
Disponible        − $12.000
Necesidades       + $12.000
Ingreso base      Sin cambio
```

Ejemplo de retiro de ahorro:

```text
Disponible        + $300.000
Fondo de emergencia − $300.000
Ingreso base      Sin cambio
Ahorro 20% del período Sin cambio
```

Ejemplo de rendimiento financiero:

```text
Disponible        Sin cambio
Producto financiero + $100.000
Ingreso base      + $100.000
```

La tabla conceptual completa de efectos se deriva de [`domain-rules.md`](./domain-rules.md) §3 y [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md).

## Relaciones entre movimientos

Las relaciones deben ser navegables desde el Detalle.

### Préstamo

```text
Préstamo a Juan
Monto original   $200.000
Pagado            $80.000
Pendiente         $120.000

Movimientos relacionados
22 septiembre · Pago recibido · +$80.000
```

### Pago o reintegro

```text
Relacionado con
Préstamo a Juan
15 septiembre
$200.000
```

Tocar una relación abre el detalle del movimiento relacionado sin perder la posibilidad de volver al detalle anterior.

## Edición

### Movimientos independientes

Un movimiento sin dependencias activas puede editar los campos aplicables siempre que conserve las invariantes del dominio. Campos potencialmente editables según naturaleza:

- monto;
- fecha financiera;
- categoría;
- bucket permitido;
- concepto;
- persona;
- producto financiero.

### Préstamo con pagos activos

Una vez existe al menos un pago activo relacionado, bloquear:

- monto original;
- fecha financiera;
- persona.

Se pueden editar si no rompen otras reglas:

- concepto;
- categoría;
- bucket `NEEDS`/`WANTS`.

Mensaje sugerido:

```text
Este préstamo tiene pagos relacionados.
El monto, la fecha y la persona ya no pueden modificarse.
```

### Gasto con reintegros activos

Una vez existe un reintegro activo relacionado, bloquear:

- fecha financiera;
- monto original.

Se pueden editar cuando sean compatibles:

- concepto;
- categoría;
- bucket.

### Regla estricta de fecha con dependencias

Una transacción origen con reintegros o pagos activos relacionados no puede cambiar su fecha financiera. La razón: mover el origen a otro mes calendario cambiaría la clasificación contable del dependiente (por ejemplo, un préstamo de septiembre con pago de octubre pasaría a ser ingreso computable de octubre).

## Anulación

La acción visible recomendada es `Anular movimiento`. No existe eliminación física de movimientos financieros.

Confirmación sugerida:

```text
¿Anular este movimiento?

Dejará de participar en tus saldos e indicadores.
El registro permanecerá disponible para trazabilidad.

[Cancelar] [Anular]
```

### Anulación con dependencias

No se realizan anulaciones en cascada automáticas en el MVP. Si la transacción tiene dependencias activas que quedarían inválidas, la operación se bloquea y la UI explica qué relación impide el cambio.

Ejemplo:

```text
No puedes anular este préstamo porque tiene
2 pagos relacionados activos.

Resuelve primero los movimientos relacionados.
```

### Movimientos anulados

Por defecto están ocultos. Se consultan mediante filtro Estado = `Anulados` o `Todos`. Una fila anulada debe mostrar una etiqueta textual `Anulado`; no depender sólo de color o tachado.

El detalle de un movimiento `VOIDED`:

- es sólo lectura;
- conserva relaciones y metadatos;
- no permite Editar;
- no permite Anular nuevamente;
- no permite Restaurar.

No existe Restaurar en el MVP.

## Estados vacíos

### Período sin movimientos

```text
No hay movimientos en septiembre.

Registra tu primer movimiento para comenzar a construir tu historial.

[+ Registrar]
```

### Filtros/búsqueda sin resultados

```text
No encontramos movimientos con estos filtros.

[Limpiar filtros]
```

No usar el CTA `Registrar` como solución principal cuando el problema es un filtro que oculta resultados.

## Preservación de estado de navegación

Durante la sesión:

- abrir Detalle y volver conserva período, búsqueda y filtros;
- abrir Registrar y volver conserva el destino de origen;
- un Historial abierto desde Dashboard conserva el filtro recibido hasta que la persona lo elimine o abandone razonablemente ese contexto;
- no es obligatorio persistir filtros entre cierres completos de la aplicación.

## Consulta y rendimiento

El Historial no debe requerir cargar todas las transacciones en memoria para aplicar filtros básicos. La capa de datos debe poder consultar por:

- rango de fecha;
- estado;
- dirección/efecto de caja cuando aplique;
- bucket;
- naturaleza;
- categoría;
- persona;
- producto financiero;
- búsqueda textual simple.

## Fuera del MVP

No incluir:

- exportación PDF/Excel;
- selección múltiple;
- anulación masiva;
- restauración de anulados;
- fotos/adjuntos de recibos;
- etiquetas personalizadas;
- filtros guardados;
- búsqueda fuzzy avanzada;
- sincronización.

## Decisiones congeladas para Historial

- El Historial muestra movimientos reales, no netos.
- El Dashboard puede netear reintegros según sus reglas; el Historial no los oculta.
- Los anulados se ocultan por defecto.
- No existe restauración en el MVP.
- Una transacción origen con dependencias activas no puede cambiar fecha.
- Un préstamo con pagos activos bloquea monto, fecha y persona.
- Un gasto con reintegros activos bloquea monto y fecha.
- Los filtros recibidos desde Dashboard son visibles y removibles.
- El detalle explica el efecto financiero usando lógica de dominio.
- No existen anulaciones en cascada automáticas.
