# 02 — Dominio y datos

## Modelo de dominio

### Transaction

Representa un movimiento financiero.

Campos:

- `id: Long`
- `type: TransactionType`
- `amount: Long`
- `date: LocalDate`
- `concept: String?`
- `bucket: BudgetBucket?`
- `category: ExpenseCategory?`
- `createdAt: Instant`
- `updatedAt: Instant`

### TransactionType

- `INCOME`
- `EXPENSE`

### BudgetBucket

- `NEEDS` — meta 50%
- `WANTS` — meta 30%
- `SAVINGS` — meta 20%

### ExpenseCategory

Cada categoría tiene un `BudgetBucket` asociado y no puede usarse fuera de ese bloque.

No se persiste una tabla de categorías en el MVP. El catálogo vive en código como dominio estático, porque no existe CRUD de categorías.

## Invariantes

1. `amount > 0`.
2. Una transacción `INCOME` tiene `bucket == null` y `category == null`.
3. Una transacción `EXPENSE` tiene `bucket != null` y `category != null`.
4. En un egreso, `category.bucket == bucket`.
5. `concept`, si existe, debe almacenarse sin espacios extremos y no debe quedar como cadena vacía.
6. La fecha no puede ser posterior al día local actual.

## Modelo Room

### Tabla `transactions`

```text
id              INTEGER PRIMARY KEY AUTOINCREMENT
transactionType TEXT NOT NULL
amount          INTEGER NOT NULL
transactionDate TEXT NOT NULL
concept         TEXT NULL
budgetBucket    TEXT NULL
category        TEXT NULL
createdAt       INTEGER NOT NULL
updatedAt       INTEGER NOT NULL
```

### Decisiones

- `amount`: entero en COP.
- `transactionDate`: fecha ISO-8601 `YYYY-MM-DD` mediante converter.
- `createdAt` / `updatedAt`: epoch milliseconds.
- enums persistidos como identificadores estables de texto.
- No guardar porcentajes ni agregados calculados; se derivan de transacciones.

## Índices

Crear índice por `transactionDate`, porque dashboard e historial filtran por rango temporal.

Opcional si las consultas lo justifican durante implementación:

- `(transactionType, transactionDate)`
- `(budgetBucket, transactionDate)`

No añadir índices por anticipación si los tests/consultas no los requieren.

## Consultas mínimas DAO

- Insertar transacción.
- Actualizar transacción.
- Eliminar transacción.
- Obtener transacción por id.
- Observar transacciones entre dos fechas, ordenadas descendente.
- Observar totales del período sin cargar todas las filas cuando sea razonable.

## Agregados del dashboard

Para un período `P`:

```text
income = suma(amount donde type = INCOME)
expenses = suma(amount donde type = EXPENSE)
balance = income - expenses
needs = suma(amount donde type = EXPENSE y bucket = NEEDS)
wants = suma(amount donde type = EXPENSE y bucket = WANTS)
savings = suma(amount donde type = EXPENSE y bucket = SAVINGS)
```

Si `income > 0`:

```text
needsPercent = needs / income * 100
wantsPercent = wants / income * 100
savingsPercent = savings / income * 100
```

La lógica de porcentaje debe usar una representación decimal segura para cálculo/formato; nunca persistir dinero en `Double`.

### Diferencia frente a objetivo

```text
needsDelta = needsPercent - 50
wantsDelta = wantsPercent - 30
savingsDelta = savingsPercent - 20
```

Interpretación visual:

- Necesidades/Deseos: sobrepasar la meta es señal de atención.
- Ahorro: quedar por debajo de la meta es señal de atención.

No convertir esta interpretación en consejos financieros personalizados en el MVP.

## Rango temporal

Crear un value object o función de dominio `PeriodRange(start: LocalDate, endInclusive: LocalDate)`.

Granularidades:

- `WEEK`
- `MONTH`
- `YEAR`

El cálculo del rango no pertenece a la UI.

## Semillas

No insertar transacciones demo en builds normales.

Para previews/tests pueden existir fixtures separados que nunca se escriban automáticamente en la DB real.

## Migraciones

Versión inicial de Room: `1`.

Desde el inicio:

- No usar destructive migration en producción.
- Toda futura modificación de esquema debe añadir migración explícita y test de migración.
