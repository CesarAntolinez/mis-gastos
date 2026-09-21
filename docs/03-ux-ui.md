# 03 — UX / UI

## Principios

- Rápido: registrar una transacción debe requerir pocos pasos.
- Legible: priorizar montos, período e indicador 50/30/20.
- Amable: visual pastel y moderno, sin apariencia infantil.
- Consistente: todos los valores visuales deben venir del tema/tokens.
- Explicable: un indicador nunca debe depender sólo del color.

## Navegación MVP

Navegación inferior con dos destinos:

1. `Resumen`
2. `Historial`

Acción principal flotante `+` para registrar transacción.

Editar una transacción se abre desde el historial.

## Pantalla Resumen

Orden recomendado:

1. Encabezado con nombre de app.
2. Selector de granularidad: Semana / Mes / Año.
3. Navegación de período: anterior, etiqueta del período, siguiente.
4. Tarjeta de balance:
   - Ingresos
   - Egresos
   - Balance
5. Sección `Tu regla 50/30/20` con tres tarjetas o barras:
   - Necesidades — objetivo 50%
   - Deseos — objetivo 30%
   - Ahorro — objetivo 20%
6. Cada indicador muestra:
   - monto actual
   - porcentaje real cuando exista ingreso
   - meta
   - diferencia frente a meta
   - texto de estado
7. CTA para agregar transacción.

No usar un único gráfico circular como única representación porque dificulta comparar contra objetivos independientes.

## Pantalla Historial

- Comparte selector de granularidad y navegación temporal del resumen.
- Lista agrupable por fecha si esto no añade complejidad excesiva.
- Transacciones ordenadas de más reciente a más antigua.
- Ingreso y egreso deben distinguirse por icono/signo y no sólo por color.
- Tocar una fila abre edición.
- Eliminar requiere confirmación.

## Formulario de transacción

### Flujo

1. Selector segmentado `Ingreso / Egreso`.
2. Campo de monto prominente.
3. Fecha.
4. Si `Egreso`:
   - selector 50/30/20
   - selector de categoría filtrado por bloque
5. Concepto opcional.
6. Botón Guardar.

Al cambiar de `Egreso` a `Ingreso`, limpiar bloque y categoría del estado del formulario.

Al cambiar el bloque de un egreso, si la categoría actual no pertenece al nuevo bloque, limpiarla.

## Estados

### Vacío global

Ilustración/icono simple, texto corto y botón `Registrar primera transacción`.

### Sin ingresos en período

Mostrar los montos de egreso pero sustituir porcentajes por `—` y explicar: `Registra un ingreso en este período para comparar con la regla 50/30/20.`

### Error de validación

Mostrar mensaje junto al campo correspondiente. Evitar diálogos para errores normales de formulario.

## Sistema visual

Crear una capa de tokens, por ejemplo:

```text
AppColors
AppTypography
AppSpacing
AppShapes
AppElevation
```

Las pantallas no deben introducir colores hexadecimales, tamaños o radios arbitrarios.

### Paleta inicial sugerida

La implementación exacta puede ajustarse por contraste, pero mantener semántica centralizada:

- Primary: lavanda/púrpura suave.
- Needs: coral pastel.
- Wants: amarillo/durazno pastel.
- Savings: verde/menta pastel.
- Income: verde semántico accesible.
- Expense: rojo/coral semántico accesible.
- Background: neutro cálido muy claro.
- Surface: blanco o variante tonal clara.

Los colores de 50/30/20 deben obtenerse del tema por nombres semánticos, no por código hardcoded en componentes.

## Componentes reutilizables mínimos

- `PeriodSelector`
- `PeriodNavigator`
- `MoneyText`
- `SummaryCard`
- `BudgetBucketCard`
- `TransactionListItem`
- `EmptyState`
- `AppTopBar`

## Formato

- Moneda: COP, formato local es-CO.
- Concepto ausente: no mostrar placeholder ruidoso en listas.
- Montos: ingreso con `+`, egreso con `−` cuando se muestren en historial.

## Accesibilidad

- Content descriptions en iconos accionables.
- Área táctil mínima acorde con Material.
- Indicadores incluyen texto como `por encima`, `por debajo` o `en meta` además del color.
- Revisar contraste final de la paleta pastel en modo claro.

## Tema futuro

El MVP puede tener sólo un tema visual, pero debe estar construido de modo que una futura actualización pueda modificar paleta, tipografía, shapes y spacing desde archivos centrales sin recorrer cada pantalla.
