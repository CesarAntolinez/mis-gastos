# 03 — UX / UI

## Principios

- Rápido: registrar una operación debe requerir pocos pasos.
- Legible: priorizar montos, período e indicador 50/30/20.
- Amable: visual pastel y moderno, sin apariencia infantil.
- Consistente: todos los valores visuales deben venir del tema/tokens.
- Explicable: un indicador nunca debe depender sólo del color.

Las fórmulas del Dashboard no se definen aquí. La fuente de verdad es [`09-indicators-dashboard.md`](./09-indicators-dashboard.md).

Los flujos y navegación funcionales están definidos en [`10-navigation-and-flows.md`](./10-navigation-and-flows.md), [`11-history.md`](./11-history.md), [`12-configuration.md`](./12-configuration.md) y [`13-onboarding.md`](./13-onboarding.md).

## Navegación MVP

Navegación inferior con tres destinos:

1. `Resumen`
2. `Historial`
3. `Configuración`

Acción global prominente `+ Registrar` disponible desde Resumen e Historial.

Onboarding aparece únicamente mientras `onboardingCompleted == false` y no forma parte de la navegación inferior.

Editar una transacción se abre desde Historial/Detalle cuando sus invariantes lo permiten.

## Pantalla Resumen

Orden recomendado:

1. Encabezado y período seleccionado.
2. Selector `Semana / Mes / Año`.
3. Navegación temporal anterior / siguiente.
4. Sección `Estado actual`:
   - Disponible actual.
   - Ahorrado actual.
   - Por cobrar actual.
5. `Ingreso base del período`.
6. Sección 50/30/20:
   - Necesidades — 50%.
   - Deseos — 30%.
   - Ahorro — 20%.
7. Últimos movimientos.
8. CTA principal para registrar movimiento.

### Estado actual

`Disponible actual`, `Ahorrado actual` y `Por cobrar actual` representan hoy. Navegar entre períodos históricos no cambia estos valores.

La UI debe separarlos visualmente de los indicadores del período para evitar interpretaciones erróneas.

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

## Interacciones del Dashboard

- `Disponible actual`: informativo en el MVP.
- `Ahorrado actual`: abre Productos financieros.
- `Por cobrar actual`: abre cuentas por cobrar pendientes.
- `Necesidades`: abre Historial prefiltrado por `NEEDS`.
- `Deseos`: abre Historial prefiltrado por `WANTS`.
- `Ahorro`: abre Historial prefiltrado por aportes `SAVING`.
- Último movimiento: abre Detalle.
- `Ver todos`: abre Historial conservando período cuando aplique.

No crear controles navegables que terminen en placeholders.

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

Seguir `11-history.md`.

Resumen visual:

- selector de granularidad y navegación temporal;
- búsqueda simple;
- filtros visibles/removibles;
- lista agrupada por fecha;
- transacciones ordenadas por `transactionDate DESC`, `createdAt DESC`;
- entradas/salidas distinguidas por signo/icono y no sólo color;
- origen y reintegro aparecen como movimientos separados;
- anulados ocultos por defecto;
- tocar una fila abre Detalle.

## Registro de operaciones

La persona no elige un enum técnico de naturaleza.

Al tocar `+ Registrar`, elige una operación humana definida en `10-navigation-and-flows.md`:

- Ingreso.
- Gasto.
- Ahorrar.
- Retirar ahorro.
- Reintegro / devolución.
- Prestar dinero.
- Registrar pago recibido.
- Registrar rendimiento financiero.

Cada flujo usa únicamente los campos relevantes.

### Ingreso normal

- monto;
- fecha financiera;
- concepto opcional.

### Gasto normal

- monto;
- categoría;
- bloque `NEEDS/WANTS` sugerido por categoría y sobrescribible;
- fecha financiera;
- concepto opcional.

### Operaciones especializadas

Ahorro, retiro, préstamo, pago, reintegro y rendimiento usan formularios específicos para evitar campos irrelevantes.

## Configuración

La pantalla principal contiene:

- Categorías.
- Productos financieros.
- Personas.

Seguir `12-configuration.md` para estados, restricciones y confirmaciones.

No mezclar en el MVP preferencias de moneda, backend, backup o personalización visual avanzada.

## Onboarding

Seguir `13-onboarding.md`.

Debe ser corto:

1. bienvenida;
2. saldo disponible inicial;
3. productos financieros existentes opcionales;
4. resumen;
5. confirmar y entrar al Dashboard.

Usa el mismo Design System del producto.

## Estados generales

### Vacío global

Ilustración/icono simple, texto corto y CTA contextual.

### Sin ingreso base en período

Mostrar montos absolutos, pero sustituir porcentajes/objetivos dependientes del ingreso por `—` o estado equivalente. Explicar que no existe ingreso base computable para ese período.

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
- `CurrentFinancialStateCard` o componentes equivalentes pequeños
- `BudgetBucketCard`
- `SavingsGoalCard`
- `TransactionListItem`
- `FilterChip`
- `EmptyState`
- `AppTopBar`

No crear componentes genéricos prematuramente si sólo tienen un uso.

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
- Soportar razonablemente tamaño de texto del sistema.

## Tema futuro

El MVP puede tener un único tema visual, construido de forma que una futura actualización modifique paleta, tipografía, shapes y spacing desde archivos centrales.
