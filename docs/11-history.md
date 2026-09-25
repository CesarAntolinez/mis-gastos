# 11 — Historial, detalle, edición y anulación

Este documento define el comportamiento funcional del Historial. El Historial muestra movimientos financieros reales y sus relaciones; no sustituye ni reinterpreta los agregados del Dashboard definidos en `09-indicators-dashboard.md`.

## 1. Principio de trazabilidad

El Historial muestra cada movimiento ocurrido en su fecha financiera real.

Ejemplo:

```text
2 septiembre
Mercado              -$200.000

20 septiembre
Reintegro mercado      +$50.000
```

El Historial no reemplaza estos dos movimientos por un único gasto de `$150.000`.

Regla:

```text
Historial = movimientos ocurridos
Dashboard = interpretación financiera y costo efectivo
```

Los indicadores pueden netear reintegros según el contrato de indicadores; el Historial conserva ambos eventos.

## 2. Estado inicial

Al abrir Historial desde la navegación principal:

```text
Granularidad: Mes
Período: mes actual
Orden: transactionDate DESC, createdAt DESC
Estado: ACTIVE
Filtros adicionales: ninguno
Búsqueda: vacía
```

`createdAt DESC` funciona como segundo criterio para mantener orden estable cuando varias transacciones comparten fecha financiera.

## 3. Estructura de pantalla

Orden recomendado:

1. título `Historial`;
2. selector `Semana | Mes | Año`;
3. navegación período anterior / siguiente;
4. campo de búsqueda;
5. botón `Filtros`;
6. chips de filtros activos;
7. lista agrupada por fecha;
8. estado vacío correspondiente;
9. acción global `+ Registrar`.

Ejemplo conceptual:

```text
Historial

[ Semana | Mes | Año ]
<  Septiembre 2026  >

[ Buscar movimientos... ]
[Filtros (2)]
[Necesidades ×] [Transporte público ×]

25 septiembre
────────────────────
Transporte público
Bus trabajo
− $12.000
50% Necesidades
```

## 4. Contenido de una fila

Una fila muestra como máximo:

- icono semántico;
- título principal;
- contexto/concepto secundario cuando exista;
- monto con signo visual;
- badge o etiqueta de clasificación/naturaleza relevante.

No saturar cada fila con todos los metadatos del movimiento; el detalle contiene la información completa.

### Ejemplos

Gasto:

```text
Transporte público
Bus trabajo
− $12.000
50% Necesidades
```

Ingreso:

```text
Nómina
Septiembre
+ $5.000.000
Ingreso
```

Aporte a ahorro:

```text
Fondo de emergencia
Aporte mensual
− $800.000
20% Ahorro
```

Retiro de ahorro:

```text
Fondo de emergencia
Retiro
+ $300.000
Retiro de ahorro
```

Préstamo:

```text
Juan
Préstamo
− $200.000
30% Deseos · Por cobrar
```

Pago recibido en mismo mes:

```text
Juan
Pago recibido
+ $80.000
Reintegro
```

Pago recibido en mes posterior:

```text
Juan
Pago recibido
+ $80.000
Ingreso computable
```

La etiqueta visible refleja el efecto contable real determinado por dominio, no el nombre técnico del enum ni únicamente el formulario de origen.

## 5. Agrupación por fecha

Agrupar visualmente por `transactionDate`.

Para fechas recientes pueden usarse etiquetas como `Hoy` y `Ayer` si la implementación mantiene claridad. En períodos históricos usar la fecha legible.

Ejemplo:

```text
Hoy
────────────────
...

Ayer
────────────────
...

23 septiembre
────────────────
...
```

## 6. Filtros del MVP

El botón `Filtros` abre un bottom sheet o superficie equivalente.

Filtros soportados:

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
- Reintegro/devolución.
- Rendimiento financiero.
- Saldo inicial cuando sea necesario para auditoría.

### Categoría

Debe permitir seleccionar categorías activas e históricas/inactivas que tengan movimientos dentro del universo consultable.

### Persona

Personas relacionadas con movimientos.

### Producto financiero

Productos relacionados con aportes, retiros o rendimientos.

### Estado

- Activos — default.
- Anulados.
- Todos.

## 7. Chips y limpieza de filtros

Cuando existen filtros activos:

```text
Filtros (2)
[Necesidades ×] [Transporte público ×]
```

Cada chip puede removerse individualmente.

Debe existir una acción `Limpiar filtros`.

Limpiar filtros no cambia el período seleccionado.

## 8. Búsqueda

El MVP incluye búsqueda textual simple.

Busca al menos por:

- concepto;
- nombre de categoría;
- nombre de persona;
- nombre de producto financiero.

No se requiere fuzzy search, ranking complejo ni full-text search especializado para el MVP.

Búsqueda y filtros pueden combinarse.

Ejemplo: buscar `Juan` con filtro `Entradas` devuelve pagos relacionados con Juan que cumplan el resto de criterios.

## 9. Entrada prefiltrada desde Dashboard

Al abrir Historial desde una tarjeta del Dashboard:

- conservar el `PeriodRange`/granularidad correspondiente;
- aplicar filtro explícito;
- mostrar el filtro como chip removible.

Mapeo mínimo:

- Necesidades 50% -> `NEEDS`;
- Deseos 30% -> `WANTS`;
- Ahorro 20% -> aportes `SAVING` del período;
- `Ver todos` de Últimos movimientos -> período del Dashboard sin filtro de bucket adicional.

Eliminar un filtro recibido desde Dashboard conserva el período.

## 10. Totales en Historial

El Historial no compite con el Dashboard como superficie analítica.

Puede mostrar de forma secundaria:

```text
12 movimientos
```

y opcionalmente, si no añade ruido:

```text
Entradas   $500.000
Salidas    $820.000
```

Estos totales son flujo de caja de los resultados visibles, no sustituyen ingreso base ni indicadores 50/30/20.

## 11. Detalle de movimiento

Tocar una fila abre Detalle.

Debe mostrar según aplique:

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

## 12. Efecto financiero explicado

El detalle incluye una sección `Efecto financiero` calculada por dominio.

Ejemplo gasto:

```text
Disponible
− $12.000

Necesidades
+ $12.000

Ingreso base
Sin cambio
```

Ejemplo retiro de ahorro:

```text
Disponible
+ $300.000

Fondo de emergencia
− $300.000

Ingreso base
Sin cambio

Ahorro 20% del período
Sin cambio
```

Ejemplo rendimiento:

```text
Disponible
Sin cambio

Producto financiero
+ $100.000

Ingreso base
+ $100.000
```

La UI no recalcula esta interpretación. Dominio entrega una representación como `TransactionEffect` o equivalente.

## 13. Tabla conceptual de efecto

| Naturaleza | Disponible | Ingreso base | Otro efecto |
| --- | ---: | ---: | --- |
| `NEW_INCOME` | + | + | — |
| `EXPENSE` | − | 0 | bucket 50/30 |
| `SAVING` | − | 0 | producto + / cumplimiento 20% + |
| `SAVING_WITHDRAWAL` | + | 0 | producto − |
| `FINANCIAL_RETURN` | 0 | + | producto + |
| `LOAN` | − | 0 | por cobrar + / bucket 50 o 30 |
| pago mismo mes | + | 0 | por cobrar − / gasto efectivo − |
| pago mes posterior | + | + | por cobrar − |
| `OPENING_BALANCE` | + | 0 | saldo inicial |

Esta tabla describe intención; las reglas completas siguen en `02-domain-and-data.md` y `09-indicators-dashboard.md`.

## 14. Relaciones entre movimientos

Las relaciones deben ser navegables desde Detalle.

### Préstamo

Ejemplo:

```text
Préstamo a Juan
Monto original   $200.000
Pagado            $80.000
Pendiente         $120.000

Movimientos relacionados
22 septiembre · Pago recibido · +$80.000
```

### Pago

Ejemplo:

```text
Relacionado con
Préstamo a Juan
15 septiembre
$200.000
```

Tocar una relación abre el detalle del movimiento relacionado sin perder la posibilidad de volver al detalle anterior.

## 15. Edición — movimientos independientes

Un movimiento sin dependencias activas puede editar los campos aplicables siempre que conserve invariantes.

Ejemplos de campos potencialmente editables según naturaleza:

- monto;
- fecha financiera;
- categoría;
- bucket permitido;
- concepto;
- persona;
- producto financiero.

La disponibilidad exacta depende de la naturaleza del movimiento.

## 16. Edición — movimientos con dependencias

Ser conservadores en el MVP.

### Préstamo con pagos activos

Una vez existe al menos un pago activo relacionado, bloquear:

- monto original;
- fecha financiera;
- persona.

Se pueden editar si no rompen otras reglas:

- concepto;
- categoría;
- bucket `NEEDS/WANTS`.

Mensaje sugerido:

```text
Este préstamo tiene pagos relacionados.
El monto, la fecha y la persona ya no pueden modificarse.
```

### Gasto con reintegros activos

Una vez existe un reintegro activo relacionado, bloquear:

- fecha financiera;
- monto original en el MVP.

Se pueden editar cuando sean compatibles:

- concepto;
- categoría;
- bucket.

Esta restricción evita tener que reclasificar retroactivamente reintegros o validar múltiples montos dependientes durante edición.

## 17. Regla estricta de fecha con dependencias

Una transacción origen con reintegros o pagos activos relacionados no puede cambiar su fecha financiera.

Razón:

```text
Préstamo septiembre + pago octubre = ingreso computable de octubre
```

Mover el préstamo a octubre cambiaría retroactivamente la naturaleza contable del pago. El MVP evita esta mutación bloqueando la fecha del origen una vez existen dependencias.

## 18. Anulación

La acción visible recomendada es `Anular movimiento`.

Confirmación:

```text
¿Anular este movimiento?

Dejará de participar en tus saldos e indicadores.
El registro permanecerá disponible para trazabilidad.

[Cancelar] [Anular]
```

No existe eliminación física de movimientos financieros.

## 19. Anulación con dependencias

No realizar anulaciones en cascada automáticas en el MVP.

Si la transacción tiene dependencias activas que quedarían inválidas, bloquear la operación.

Ejemplo:

```text
No puedes anular este préstamo porque tiene
2 pagos relacionados activos.

Resuelve primero los movimientos relacionados.
```

La UI debe explicar el bloqueo; no fallar silenciosamente.

## 20. Movimientos anulados

Por defecto están ocultos.

Se consultan mediante filtro Estado = `Anulados` o `Todos`.

Una fila anulada debe mostrar una etiqueta textual `Anulado`; no depender sólo de color/tachado.

Detalle de un movimiento `VOIDED`:

- sólo lectura;
- conserva relaciones y metadatos;
- no permite Editar;
- no permite Anular nuevamente.

No existe Restaurar en el MVP.

## 21. Estados vacíos

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

## 22. Preservación de estado de navegación

Durante la sesión:

- abrir Detalle y volver conserva período, búsqueda y filtros;
- abrir Registrar y volver conserva el destino de origen;
- un Historial abierto desde Dashboard conserva el filtro recibido hasta que la persona lo elimine o abandone razonablemente ese contexto;
- no es obligatorio persistir filtros entre cierres completos de la aplicación.

## 23. Rendimiento y consultas

El Historial no debe requerir cargar todas las transacciones en memoria para aplicar filtros básicos.

La capa de datos debe poder consultar por:

- rango de fecha;
- estado;
- dirección/efecto de caja cuando aplique;
- bucket;
- naturaleza;
- categoría;
- persona;
- producto financiero;
- búsqueda textual simple.

La estrategia concreta de paginación/limitación se decidirá al congelar Room. No introducir backend ni paginación de servidor.

## 24. Fuera del MVP

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

## 25. Decisiones congeladas para Historial

- El Historial muestra movimientos reales, no netos.
- El Dashboard puede netear reintegros según sus reglas; el Historial no los oculta.
- Los anulados se ocultan por defecto.
- No existe restauración en el MVP.
- Una transacción origen con dependencias activas no puede cambiar fecha.
- Un préstamo con pagos activos bloquea monto, fecha y persona.
- Un gasto con reintegros activos bloquea monto y fecha.
- Los filtros recibidos desde Dashboard son visibles y removibles.
- Detalle explica el efecto financiero usando lógica de dominio.
- No existen anulaciones en cascada automáticas.
