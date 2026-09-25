# 14 — Esquema físico Room / SQLite

Este documento congela el diseño físico inicial de persistencia del MVP. Complementa `02-domain-and-data.md`: el dominio define significado e invariantes; este documento define cómo se representan en Room/SQLite.

## 1. Principios

1. `transactions` es la fuente de verdad de los movimientos financieros.
2. No duplicar monto/fecha/concepto financiero en tablas auxiliares si ya existen en una transacción.
3. Los saldos e indicadores son derivados; no se persisten como columnas mutables.
4. Dinero se persiste como `INTEGER` de 64 bits (`Long`) en pesos COP.
5. `LocalDate` se persiste como texto ISO `YYYY-MM-DD`.
6. `Instant` se persiste como epoch milliseconds `INTEGER`.
7. Enums se persisten por nombre estable `TEXT`, nunca por ordinal.
8. No usar `fallbackToDestructiveMigration`.
9. `@Database(exportSchema = true)` y los schemas exportados se versionan en Git.
10. Foreign keys activas y borrado físico restringido para preservar trazabilidad.

## 2. Database v1

Entidades físicas:

```text
app_setup
categories
financial_products
persons
transactions
receivables
receivable_payments
```

No crear tablas separadas para Dashboard, balances, presupuestos o histórico neteado.

## 3. `app_setup`

Propósito: estado explícito de inicialización/onboarding.

```text
app_setup
- id: INTEGER PRIMARY KEY
- onboarding_completed: INTEGER NOT NULL
- created_at_epoch_ms: INTEGER NOT NULL
- updated_at_epoch_ms: INTEGER NOT NULL
```

Convención MVP:

```text
id = 1
```

Puede no existir fila antes de completar onboarding; ausencia equivale a `onboardingCompleted = false`.

La fila se inserta/actualiza dentro de la misma transacción Room que confirma onboarding.

No usar cantidad de transacciones/categorías para inferir este estado.

## 4. `categories`

```text
categories
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- name: TEXT NOT NULL
- normalized_name: TEXT NOT NULL
- default_bucket: TEXT NOT NULL
- active: INTEGER NOT NULL
- created_at_epoch_ms: INTEGER NOT NULL
- updated_at_epoch_ms: INTEGER NOT NULL
```

Valores físicos permitidos por dominio para `default_bucket`:

```text
NEEDS
WANTS
```

`SAVINGS` no es válido como default de categoría ordinaria.

Índice:

```text
INDEX idx_categories_normalized_active
ON categories(normalized_name, active)
```

La unicidad entre nombres activos se valida dentro de una operación transaccional de dominio/repositorio. No depender únicamente de un índice SQL porque la regla está condicionada por `active` y debe producir errores de dominio comprensibles.

## 5. `financial_products`

```text
financial_products
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- name: TEXT NOT NULL
- normalized_name: TEXT NOT NULL
- opening_balance: INTEGER NOT NULL
- active: INTEGER NOT NULL
- created_at_epoch_ms: INTEGER NOT NULL
- updated_at_epoch_ms: INTEGER NOT NULL
```

`opening_balance >= 0` se valida antes de persistir.

Índice:

```text
INDEX idx_financial_products_normalized_active
ON financial_products(normalized_name, active)
```

No persistir `current_balance`. Se calcula:

```text
opening_balance
+ SAVING activos
+ FINANCIAL_RETURN activos
- SAVING_WITHDRAWAL activos
```

## 6. `persons`

```text
persons
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- name: TEXT NOT NULL
- normalized_name: TEXT NOT NULL
- active: INTEGER NOT NULL
- created_at_epoch_ms: INTEGER NOT NULL
- updated_at_epoch_ms: INTEGER NOT NULL
```

Índice:

```text
INDEX idx_persons_normalized_active
ON persons(normalized_name, active)
```

No persistir monto pendiente ni cantidad de préstamos; son valores derivados.

## 7. `transactions`

```text
transactions
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- transaction_date: TEXT NOT NULL
- direction: TEXT NOT NULL
- nature: TEXT NOT NULL
- amount: INTEGER NOT NULL
- category_id: INTEGER NULL
- bucket: TEXT NULL
- concept: TEXT NULL
- related_transaction_id: INTEGER NULL
- person_id: INTEGER NULL
- financial_product_id: INTEGER NULL
- status: TEXT NOT NULL
- created_at_epoch_ms: INTEGER NOT NULL
- updated_at_epoch_ms: INTEGER NOT NULL
```

### Foreign keys

```text
category_id -> categories.id              ON DELETE RESTRICT
related_transaction_id -> transactions.id ON DELETE RESTRICT
person_id -> persons.id                    ON DELETE RESTRICT
financial_product_id -> financial_products.id ON DELETE RESTRICT
```

No usar `CASCADE` para movimientos financieros.

### Enums físicos

`direction`:

```text
INCOME
EXPENSE
```

`nature`:

```text
NEW_INCOME
EXPENSE
SAVING
SAVING_WITHDRAWAL
REIMBURSEMENT
OPENING_BALANCE
FINANCIAL_RETURN
LOAN
LOAN_REPAYMENT
```

`bucket`:

```text
NEEDS
WANTS
SAVINGS
NULL
```

`status`:

```text
ACTIVE
VOIDED
```

### Índices

```text
INDEX idx_transactions_date_status
ON transactions(transaction_date, status)

INDEX idx_transactions_nature_date_status
ON transactions(nature, transaction_date, status)

INDEX idx_transactions_direction_date_status
ON transactions(direction, transaction_date, status)

INDEX idx_transactions_bucket_date_status
ON transactions(bucket, transaction_date, status)

INDEX idx_transactions_category
ON transactions(category_id)

INDEX idx_transactions_person
ON transactions(person_id)

INDEX idx_transactions_financial_product
ON transactions(financial_product_id)

INDEX idx_transactions_related
ON transactions(related_transaction_id)
```

No indexar `concept` para búsqueda `%texto%`; un índice B-tree normal no mejora ese patrón.

## 8. Contrato de columnas por naturaleza

Las restricciones cruzadas se validan en dominio/repositorio antes de escribir. Room/SQLite protege referencias; la capa de dominio protege semántica.

| Nature | Direction | Category | Bucket | Person | Product | Related transaction |
| --- | --- | --- | --- | --- | --- | --- |
| `OPENING_BALANCE` | `INCOME` | NULL | NULL | NULL | NULL | NULL |
| `NEW_INCOME` normal | `INCOME` | NULL | NULL | NULL | NULL | NULL |
| `NEW_INCOME` devolución tardía de gasto | `INCOME` | NULL | NULL | NULL | NULL | EXPENSE origen |
| `EXPENSE` | `EXPENSE` | required | `NEEDS/WANTS` | NULL | NULL | NULL |
| `SAVING` | `EXPENSE` | NULL | `SAVINGS` | NULL | required | NULL |
| `SAVING_WITHDRAWAL` | `INCOME` | NULL | NULL | NULL | required | NULL |
| `FINANCIAL_RETURN` | `INCOME` | NULL | NULL | NULL | required | NULL |
| `LOAN` | `EXPENSE` | required | `NEEDS/WANTS` | required | NULL | NULL |
| `LOAN_REPAYMENT` | `INCOME` | NULL | NULL | required | NULL | LOAN origen |
| `REIMBURSEMENT` | `INCOME` | NULL | NULL | NULL | NULL | EXPENSE origen |

### Regla para devoluciones de gastos ordinarios

Al registrar desde el flujo visible `Reintegro / devolución`:

```text
mismo mes calendario que el gasto origen
→ nature = REIMBURSEMENT

mes calendario posterior
→ nature = NEW_INCOME
→ related_transaction_id conserva vínculo con el gasto origen
```

La UI puede seguir presentando ambos como una devolución relacionada; la naturaleza física expresa su tratamiento contable.

### Regla para pagos de préstamos

Un pago de préstamo siempre persiste:

```text
nature = LOAN_REPAYMENT
related_transaction_id = transacción LOAN origen
```

Su tratamiento se deriva:

```text
mismo mes calendario -> reintegro / no base income
mes posterior         -> ingreso base del nuevo período
```

No cambiar `nature` para representar esta diferencia porque el movimiento sigue siendo un pago de la misma cuenta por cobrar.

## 9. Orden temporal de movimientos relacionados

Para `REIMBURSEMENT`, devolución tardía de gasto y `LOAN_REPAYMENT`:

```text
dependent.transaction_date >= origin.transaction_date
```

No se permite registrar una devolución/pago con fecha financiera anterior a su movimiento origen.

Esto se valida en dominio y evita relaciones temporalmente imposibles.

## 10. `receivables`

La tabla representa la relación de cuenta por cobrar, no duplica los datos financieros del préstamo.

```text
receivables
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- person_id: INTEGER NOT NULL
- origin_transaction_id: INTEGER NOT NULL
- created_at_epoch_ms: INTEGER NOT NULL
- updated_at_epoch_ms: INTEGER NOT NULL
```

Foreign keys:

```text
person_id -> persons.id                    ON DELETE RESTRICT
origin_transaction_id -> transactions.id   ON DELETE RESTRICT
```

Índices:

```text
UNIQUE INDEX idx_receivables_origin_unique
ON receivables(origin_transaction_id)

INDEX idx_receivables_person
ON receivables(person_id)
```

La transacción origen debe ser `LOAN` y debe referenciar la misma `person_id`. Se valida al crear el agregado.

### Datos derivados

No persistir de nuevo:

```text
originalAmount
date
concept
status
pendingAmount
paidAmount
```

Se derivan:

```text
originalAmount = originTransaction.amount
date           = originTransaction.transactionDate
concept        = originTransaction.concept
paidAmount     = SUM(paymentTransaction.amount WHERE paymentTransaction.status = ACTIVE)
pendingAmount  = originalAmount - paidAmount
status         = pendingAmount == 0 ? PAID : PENDING
```

Esto elimina el riesgo de que un préstamo diga `$200.000` en `transactions` y `$180.000` en `receivables`.

## 11. `receivable_payments`

Tabla de asociación entre una cuenta por cobrar y la transacción que representa el pago.

```text
receivable_payments
- id: INTEGER PRIMARY KEY AUTOINCREMENT
- receivable_id: INTEGER NOT NULL
- transaction_id: INTEGER NOT NULL
- created_at_epoch_ms: INTEGER NOT NULL
```

Foreign keys:

```text
receivable_id -> receivables.id       ON DELETE RESTRICT
transaction_id -> transactions.id      ON DELETE RESTRICT
```

Índices:

```text
INDEX idx_receivable_payments_receivable
ON receivable_payments(receivable_id)

UNIQUE INDEX idx_receivable_payments_transaction_unique
ON receivable_payments(transaction_id)
```

No persistir nuevamente `amount` ni `date`.

Se derivan desde `transactions`.

La transacción enlazada debe:

- tener `nature = LOAN_REPAYMENT`;
- apuntar mediante `related_transaction_id` al `LOAN` origen del `receivable`;
- usar la misma persona;
- cumplir fecha >= fecha del origen.

## 12. Anulación y tablas auxiliares

Anular una transacción cambia únicamente:

```text
transactions.status = VOIDED
transactions.updated_at_epoch_ms = now
```

No borrar físicamente filas de `receivables` o `receivable_payments` para esconder movimientos.

Las consultas derivadas sólo suman transacciones `ACTIVE`.

Una transacción origen no puede anularse mientras existan dependencias activas que quedarían inválidas, conforme a `11-history.md`.

## 13. Converters Room

### `LocalDate`

Persistencia:

```text
LocalDate <-> ISO-8601 String YYYY-MM-DD
```

Razones:

- mantiene orden cronológico lexicográfico;
- simplifica consultas por rango;
- permite comparar mes con `substr(date, 1, 7)` cuando sea necesario;
- evita timezone en una fecha de negocio que no tiene hora.

### `Instant`

```text
Instant <-> Long epochMilliseconds
```

### Enums

```text
Enum.name <-> TEXT
```

Nunca persistir ordinales (`0`, `1`, `2`) porque reordenar el enum corrompería significado histórico.

## 14. `normalized_name`

Se calcula en Kotlin antes de persistir:

```text
trim()
lowercase(Locale.ROOT)
```

La columna se persiste para búsquedas/validaciones eficientes.

No modificar automáticamente el `name` visible más allá de las validaciones aprobadas.

## 15. Operaciones atómicas obligatorias

Usar `RoomDatabase.withTransaction` o equivalente.

### Completar onboarding

Dentro de una sola transacción:

1. validar que onboarding no esté completado;
2. insertar seed faltante de categorías de forma idempotente;
3. insertar `OPENING_BALANCE` si monto > 0;
4. insertar productos iniciales;
5. insertar/actualizar `app_setup(id=1, onboarding_completed=true)`.

### Crear préstamo

1. validar persona/categoría/bucket;
2. insertar transacción `LOAN`;
3. insertar `receivable` enlazado al id de la transacción.

### Registrar pago de préstamo

1. cargar `receivable` + origen;
2. calcular pagos activos;
3. validar `amount <= pending`;
4. validar fecha;
5. insertar `LOAN_REPAYMENT`;
6. insertar `receivable_payment`.

### Registrar reintegro de gasto

1. cargar gasto origen;
2. sumar devoluciones activas relacionadas;
3. validar límite y fecha;
4. decidir `REIMBURSEMENT` vs `NEW_INCOME` por mes;
5. insertar transacción relacionada.

### Retirar ahorro

1. calcular saldo actual del producto dentro de la operación;
2. validar monto <= saldo;
3. insertar `SAVING_WITHDRAWAL`.

### Desactivar producto

1. calcular saldo actual;
2. exigir saldo == 0;
3. actualizar `active`.

### Desactivar persona

1. calcular total pendiente activo;
2. exigir pendiente == 0;
3. actualizar `active`.

### Crear/reactivar/renombrar entidad maestra

1. calcular `normalized_name`;
2. verificar duplicado activo dentro del tipo;
3. persistir cambio.

## 16. Consultas críticas

El diseño debe soportar sin cargar todo el historial en memoria:

### Historial

- rango de fechas;
- estado;
- dirección;
- bucket;
- naturaleza;
- categoría;
- persona;
- producto;
- búsqueda simple por concepto/nombres relacionados;
- orden `transaction_date DESC, created_at_epoch_ms DESC`.

### Saldo disponible actual

Agregar sólo transacciones `ACTIVE` con `transaction_date <= today` y mapear efecto según `nature`.

`FINANCIAL_RETURN` no afecta disponible.

### Saldo de producto

```text
opening_balance
+ SUM(SAVING ACTIVE)
+ SUM(FINANCIAL_RETURN ACTIVE)
- SUM(SAVING_WITHDRAWAL ACTIVE)
```

filtrado por `financial_product_id`.

### Cuenta por cobrar

Join:

```text
receivables
-> origin transaction
-> receivable_payments
-> payment transactions
```

Sumar sólo pagos cuyas transacciones estén `ACTIVE`.

### Ingreso base por período

La consulta/agregación debe incluir:

- `NEW_INCOME` activo dentro del rango;
- `FINANCIAL_RETURN` activo dentro del rango;
- `LOAN_REPAYMENT` activo dentro del rango sólo si `substr(payment.date,1,7) > substr(origin.date,1,7)`.

La devolución tardía de un gasto ordinario ya está persistida como `NEW_INCOME`, por lo que entra naturalmente sin duplicar regla.

### Gasto efectivo

Para `NEEDS/WANTS`, relacionar gasto origen con devoluciones `REIMBURSEMENT` activas del mismo mes según `09-indicators-dashboard.md`.

## 17. Proyecciones, no entidades duplicadas

Crear DTO/proyecciones de consulta cuando sean útiles, por ejemplo:

```text
HistoryRowProjection
FinancialProductSummaryProjection
ReceivableSummaryProjection
DashboardRawTotalsProjection
```

No convertir esas proyecciones en tablas persistidas salvo ADR futura con evidencia de necesidad.

`ReceivableStatus`, `paidAmount` y `pendingAmount` pueden existir en modelos de dominio/UI aunque sean derivados en persistencia.

## 18. Repositories / DAOs

DAOs físicos recomendados:

```text
TransactionDao
CategoryDao
FinancialProductDao
PersonDao
ReceivableDao
AppSetupDao
```

`ReceivableDao` puede incluir operaciones/proyecciones de `receivable_payments` para evitar un DAO público innecesario.

Repositorios de dominio recomendados:

```text
TransactionRepository
CategoryRepository
FinancialProductRepository
PersonRepository
ReceivableRepository
SetupRepository
```

Las operaciones multi-DAO y reglas de negocio pertenecen a repositorio/use case con `withTransaction`; no esconder reglas 50/30/20 dentro de SQL difícil de auditar.

## 19. SQLite foreign keys y borrado

Room habilita foreign keys para entidades declaradas.

Política MVP:

```text
ON DELETE RESTRICT / NO ACTION
```

No usar borrado en cascada para datos financieros o maestros con histórico.

La UI usa `active` o `status = VOIDED`, no `DELETE`, para el ciclo de vida normal.

## 20. Migraciones

Versión inicial:

```text
Database version = 1
exportSchema = true
```

Reglas futuras:

- cada cambio de esquema incrementa versión;
- escribir migración explícita;
- añadir test de migración;
- no usar migración destructiva en builds de producción;
- los JSON exportados por Room se versionan en Git.

Durante desarrollo temprano puede limpiarse manualmente una instalación local de prueba si todavía no existe data real, pero esto no debe convertirse en estrategia de migración del producto.

## 21. Validación vs constraints SQL

SQLite protege:

- primary keys;
- foreign keys;
- índices únicos estructurales como una transacción de pago usada una sola vez;
- tipos/NULL según schema.

Dominio/repositorio protege:

- `amount > 0`;
- combinaciones válidas naturaleza/campos;
- bucket permitido;
- saldo de producto no negativo;
- sobrepago;
- límite de reintegros;
- fecha dependiente >= origen;
- restricciones de edición/anulación;
- unicidad de nombres activos;
- desactivación de personas/productos;
- clasificación mensual de devoluciones.

No intentar convertir toda la lógica del dominio en triggers SQLite.

## 22. No usar triggers en v1

No crear triggers para:

- actualizar saldos;
- cambiar estados de receivables;
- recalcular Dashboard;
- propagar anulaciones.

La trazabilidad es más clara si esos valores son derivados y las reglas viven en código de dominio testeable.

## 23. Tests Room obligatorios

Como mínimo:

- converters `LocalDate`/`Instant`/enums;
- foreign keys y restricciones de referencias;
- seed idempotente;
- onboarding atómico;
- histórico de categoría después de cambiar default;
- saldo de producto con opening/aporte/retiro/rendimiento/anulado;
- retiro inválido no deja escritura parcial;
- préstamo crea `LOAN + receivable` atómicamente;
- pagos parciales y sobrepago;
- pago del mismo mes vs mes posterior;
- gasto + reintegro mismo mes;
- devolución tardía de gasto como `NEW_INCOME` relacionado;
- movimientos anulados excluidos de agregados;
- historial con filtros combinados y orden estable;
- nombres activos normalizados y reactivación;
- persona/producto no pueden desactivarse cuando incumplen invariantes;
- migraciones cuando exista versión > 1.

## 24. Decisiones congeladas

- `transactions` es la única fuente de verdad de montos/fechas de movimientos.
- `receivables` no duplica monto, fecha, concepto, pendiente ni estado financiero.
- `receivable_payments` no duplica monto/fecha del pago.
- `LocalDate` se persiste en ISO `YYYY-MM-DD`.
- `Instant` se persiste en epoch milliseconds.
- Enums se persisten como `TEXT` por nombre, nunca ordinal.
- No se persisten balances/indicadores calculados.
- `AppSetup` vive en Room para permitir onboarding atómico.
- Devolución tardía de gasto ordinario usa `NEW_INCOME` + `related_transaction_id`.
- Pago de préstamo siempre usa `LOAN_REPAYMENT`; su tratamiento de ingreso se deriva por mes.
- Una devolución/pago relacionado nunca puede tener fecha anterior a su origen.
- Foreign keys usan borrado restrictivo.
- No hay triggers de negocio en v1.
- Database v1 exporta schema y no usa migración destructiva.
