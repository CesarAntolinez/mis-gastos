# 03 — UX / UI

## Principios

- Rápido: registrar una transacción debe requerir pocos pasos.
- Legible: priorizar montos, período e indicador 50/30/20.
- Amable: visual pastel y moderno, sin apariencia infantil.
- Consistente: todos los valores visuales deben venir del tema/tokens.
- Explicable: un indicador nunca debe depender sólo del color.

Las fórmulas del Dashboard no se definen aquí. La fuente de verdad es [`09-indicators-dashboard.md`](./09-indicators-dashboard.md).

## Navegación MVP

Navegación inferior con dos destinos:

1. `Resumen`
2. `Historial`

Acción principal flotante `+` para registrar transacción.

Editar una transacción se abre desde el historial.

## Pantalla Resumen

Orden recomendado:

1. Encabezado y período seleccionado.
2. Selector `Semana / Mes / Año`.
3. Navegación temporal anterior / siguiente.
4. Tarjeta principal `Disponible actual`.
5. `Ingreso base del período`.
6. Sección 50/30/20:
   - Necesidades — 50%.
   - Deseos — 30%.
   - Ahorro — 20%.
7. Patrimonio relacionado:
   - saldo total ahorrado actual;
   - dinero por cobrar actual.
8. Últimos movimientos.
9. CTA principal para registrar movimiento.

### Disponible actual

Debe dejar claro que es un valor actual y no histórico. Navegar entre períodos no cambia esta tarjeta.

### Tarjetas Necesidades y Deseos

Mostrar:

- monto efectivo;
- objetivo monetario;
- participación respecto al ingreso base;
- uso del presupuesto;
- restante o exceso;
- estado textual (`Dentro del presupuesto`, `Cerca del límite`, `Excedido`, `Sin base de cálculo`).

### Tarjeta Ahorro

Mostrar:

- aportado en el período;
- objetivo monetario;
- participación respecto al ingreso base;
- cumplimiento de meta;
- faltante o superación;
- estado textual (`En progreso`, `Cerca de la meta`, `Meta alcanzada`, `Sin base de cálculo`).

No describir un retiro de ahorro como pérdida del cumplimiento del 20% del período.

## Estados visuales

Los estados son semánticos y deben llegar calculados desde dominio.

Necesidades/Deseos:

- `WITHIN`
- `NEAR_LIMIT`
- `EXCEEDED`
- `NO_BASE`

Ahorro:

- `IN_PROGRESS`
- `NEAR_TARGET`
- `TARGET_MET`
- `NO_BASE`

La UI decide iconografía, textos y colores a partir del estado; no recalcula umbrales.

## Pantalla Historial

- Comparte selector de granularidad y navegación temporal del resumen.
- Lista agrupable por fecha si no añade complejidad excesiva.
- Transacciones ordenadas de más reciente a más antigua.
- Entrada/salida se distinguen por icono/signo y no sólo por color.
- Un reintegro conserva la fecha real en que entró el dinero aunque corrija indicadores del gasto original.
- Tocar una fila abre detalle/edición cuando la operación es editable.
- Anular requiere confirmación.

## Formulario de transacción

El formulario final dependerá de la naturaleza seleccionada. Para ingresos/egresos normales:

1. Tipo/naturaleza de operación.
2. Campo de monto prominente.
3. Fecha financiera.
4. Para egreso normal:
   - categoría;
   - bloque sugerido por la categoría;
   - posibilidad de sobrescribir 50/30/20.
5. Concepto opcional.
6. Botón Guardar.

Los flujos de ahorro, retiro, préstamo y pago pueden usar formularios especializados para evitar presentar campos irrelevantes.

## Estados generales

### Vacío global

Ilustración/icono simple, texto corto y botón `Registrar primera transacción`.

### Sin ingreso base en período

Mostrar montos absolutos, pero sustituir porcentajes y objetivos dependientes del ingreso por `—` o estado equivalente. Explicar que no existe ingreso base computable para ese período.

### Error de validación

Mostrar mensaje junto al campo correspondiente. Evitar diálogos para errores normales de formulario.

## Sistema visual

Crear una capa de tokens:

```text
AppColors
AppTypography
AppSpacing
AppShapes
AppElevation
```

Las pantallas no deben introducir colores hexadecimales, tamaños o radios arbitrarios.

### Paleta inicial sugerida

La implementación exacta puede ajustarse por contraste, manteniendo semántica centralizada:

- Primary: lavanda/púrpura suave.
- Needs: coral pastel.
- Wants: amarillo/durazno pastel.
- Savings: verde/menta pastel.
- Income: verde semántico accesible.
- Expense: rojo/coral semántico accesible.
- Background: neutro cálido muy claro.
- Surface: blanco o variante tonal clara.

Los colores de 50/30/20 se obtienen del tema por nombres semánticos.

## Componentes reutilizables mínimos

- `PeriodSelector`
- `PeriodNavigator`
- `MoneyText`
- `AvailableBalanceCard`
- `BudgetBucketCard`
- `SavingsGoalCard`
- `TransactionListItem`
- `EmptyState`
- `AppTopBar`

## Formato

- Moneda: COP, formato local `es-CO`.
- Concepto ausente: no mostrar placeholder ruidoso en listas.
- Montos del historial: signo `+` o `−` cuando corresponda al efecto en disponible.
- Los porcentajes pueden mostrarse enteros o con hasta dos decimales cuando mejore comprensión.

## Accesibilidad

- Content descriptions en iconos accionables.
- Área táctil mínima acorde con Material.
- Indicadores incluyen texto como `Cerca del límite`, `Excedido` o `Meta alcanzada`, además del color.
- Revisar contraste final de la paleta pastel en modo claro.

## Tema futuro

El MVP puede tener un único tema visual, construido de forma que una futura actualización modifique paleta, tipografía, shapes y spacing desde archivos centrales.
