# 12 — Configuración

Este documento define la gestión de datos maestros del MVP: categorías, productos financieros y personas. Configuración no es una superficie para mover dinero; los movimientos se registran mediante los flujos definidos en `10-navigation-and-flows.md`.

## 1. Pantalla principal

La navegación inferior `Configuración` contiene tres destinos:

```text
Categorías
Productos financieros
Personas
```

No incluir en el MVP preferencias de moneda, exportación, backup, sincronización, temas configurables, bancos ni ajustes financieros avanzados.

## 2. Principio de histórico

Categorías, productos financieros y personas pueden desactivarse, pero no deben eliminarse físicamente cuando tengan histórico asociado.

Desactivar una entidad:

- evita su selección en nuevas operaciones donde aplique;
- conserva relaciones históricas;
- conserva su disponibilidad en filtros históricos;
- no reescribe transacciones existentes.

## 3. Categorías

Una categoría tiene:

```text
id
name
defaultBucket
active
createdAt
updatedAt
```

`defaultBucket` sólo puede ser:

- `NEEDS` — 50%;
- `WANTS` — 30%.

No existen categorías ordinarias `SAVINGS` en el MVP. El 20% se registra mediante `SAVING` y un producto financiero.

### 3.1 Lista

Agrupar o identificar visualmente por bloque por defecto:

```text
NECESIDADES · 50%
Transporte público
Salud
...

DESEOS · 30%
Ropa
Salidas
...
```

Orden:

1. activas;
2. alfabético por nombre normalizado;
3. inactivas en sección/filtro secundario.

No existe orden manual ni drag & drop en el MVP.

### 3.2 Crear categoría

Campos:

```text
Nombre
Clasificación por defecto: 50% Necesidades | 30% Deseos
```

El nombre es obligatorio después de `trim`.

### 3.3 Editar categoría

Campos editables:

- nombre;
- `defaultBucket`;
- estado activo/inactivo.

Cambiar `defaultBucket` afecta sólo nuevas transacciones. El bucket persistido en transacciones anteriores permanece intacto.

### 3.4 Desactivar categoría

Se permite desactivar aunque exista histórico porque las transacciones conservan `categoryId` y bucket histórico.

Confirmación recomendada:

```text
¿Desactivar "Ropa"?

Ya no aparecerá al registrar nuevos movimientos.
Tu historial no se modificará.

[Cancelar] [Desactivar]
```

Una categoría inactiva:

- no aparece en selectores de nuevas operaciones;
- sigue siendo visible en movimientos existentes y filtros históricos;
- puede reactivarse.

## 4. Semilla inicial de categorías

La inicialización crea una sola vez las categorías base.

### NEEDS — 50%

- Transporte público
- Transporte privado
- Salud
- Alimentación hogar
- Arriendo
- Servicios
- Mantenimiento casa
- Mantenimiento bicicleta
- Mantenimiento computador
- Otros gastos únicos obligatorios

### WANTS — 30%

- Belleza
- Ropa
- Snacks
- Snacks trabajo
- Salidas
- Comidas por la calle

No crear categoría `Ahorro / inversión`; el ahorro se representa mediante productos financieros y `SAVING`.

## 5. Productos financieros

Un producto tiene:

```text
id
name
openingBalance
active
createdAt
updatedAt
```

`openingBalance` representa dinero existente antes de empezar a usar la app. No constituye ingreso base ni ahorro del período y no afecta el saldo disponible.

Saldo actual derivado:

```text
openingBalance + aportes + rendimientos - retiros
```

### 5.1 Lista

Cada elemento muestra como mínimo:

```text
Nombre
Saldo actual
Estado activo/inactivo
```

Orden:

1. activos;
2. alfabético;
3. inactivos en sección/filtro secundario.

### 5.2 Detalle

Mostrar:

- nombre;
- saldo inicial;
- saldo actual;
- total de aportes;
- total de retiros;
- total de rendimientos;
- estado;
- movimientos recientes relacionados.

Acciones cuando sean válidas:

- `Ahorrar`;
- `Retirar`;
- `Registrar rendimiento`;
- `Editar`.

Estas acciones reutilizan los flujos de `10-navigation-and-flows.md`.

### 5.3 Crear producto

Campos:

```text
Nombre
Saldo inicial COP
```

`openingBalance >= 0`.

Crear un producto con saldo inicial no crea ahorro del período ni ingreso base.

### 5.4 Editar producto

Siempre editables mientras la entidad esté activa o la operación sea válida:

- nombre.

`openingBalance` sólo puede modificarse mientras el producto no tenga transacciones financieras relacionadas activas o anuladas que formen parte de su histórico.

Una vez existe cualquier movimiento relacionado, `openingBalance` queda bloqueado en el MVP.

No corregir saldos posteriores manipulando silenciosamente el saldo inicial.

### 5.5 Desactivar producto

Regla del MVP:

```text
productBalance == 0 -> puede desactivarse
productBalance != 0 -> desactivación bloqueada
```

Esto evita dejar dinero atrapado en un producto que ya no puede seleccionarse para retiros.

Al intentar desactivar con saldo distinto de cero, explicar el saldo restante y pedir dejarlo en cero primero.

Un producto inactivo con histórico:

- no aparece para nuevos aportes, retiros o rendimientos;
- conserva movimientos e histórico;
- sigue disponible en filtros históricos;
- puede reactivarse.

## 6. Personas

`Person` identifica a alguien relacionado con cuentas por cobrar. No es una libreta de contactos.

Campos:

```text
id
name
active
createdAt
updatedAt
```

No incluir teléfono, email, dirección, foto, sincronización de contactos ni recordatorios en el MVP.

### 6.1 Lista

Cada elemento puede mostrar:

```text
Nombre
Total pendiente
Cantidad de préstamos
Estado
```

`Configuración > Personas` administra la entidad persona.

`Por cobrar` administra préstamos y pagos.

No mezclar ambos propósitos.

### 6.2 Crear persona

Campo:

```text
Nombre
```

Nombre obligatorio después de `trim`.

### 6.3 Editar persona

Editable:

- nombre;
- estado cuando cumpla las reglas de desactivación.

Cambiar el nombre no modifica relaciones históricas; las transacciones siguen enlazadas por id.

### 6.4 Desactivar persona

Regla:

```text
pendingReceivableTotal > 0 -> no puede desactivarse
pendingReceivableTotal == 0 -> puede desactivarse
```

Una persona inactiva:

- no aparece al crear nuevos préstamos;
- conserva préstamos y pagos históricos;
- sigue disponible en filtros históricos;
- puede reactivarse.

## 7. Normalización y duplicados

Para nombres de categorías, productos financieros y personas se usa una forma normalizada para validación:

```text
normalizedName = trim + comparación case-insensitive
```

El almacenamiento puede conservar la capitalización escrita por la persona; la comparación de duplicados usa la forma normalizada.

Regla MVP:

- no pueden existir dos categorías activas con el mismo nombre normalizado;
- no pueden existir dos productos activos con el mismo nombre normalizado;
- no pueden existir dos personas activas con el mismo nombre normalizado.

Una entidad inactiva con el mismo nombre no debe provocar silenciosamente ambigüedad al reactivarse: la reactivación debe validar nuevamente unicidad entre activas.

Estas reglas son de dominio/aplicación y no deben depender únicamente de un índice SQL sin considerar el estado `active`.

## 8. Información de uso

Para explicar restricciones, las listas/detalles pueden mostrar datos derivados:

Categoría:

```text
Ropa
30% Deseos
24 movimientos
```

Producto:

```text
Fondo de emergencia
$3.250.000
18 movimientos
```

Persona:

```text
Juan
$120.000 pendiente
2 préstamos
```

Estos conteos/saldos son derivados; no son nuevas fuentes de verdad persistidas salvo que el diseño físico futuro justifique cachearlos.

## 9. Confirmaciones

No requerir confirmación para cambios triviales de nombre.

Sí requerir confirmación para desactivar entidades.

La confirmación debe explicar el efecto funcional y que el histórico se conserva.

## 10. Estados vacíos

### Productos financieros

```text
Aún no tienes productos financieros.

Crea uno para empezar a registrar tus ahorros.

[Crear producto]
```

### Personas

```text
Aún no tienes personas registradas.

Puedes agregarlas cuando necesites prestar dinero.

[Agregar persona]
```

### Categorías sin activas

```text
No tienes categorías activas.

[Crear categoría]
[Ver inactivas]
```

## 11. Integridad y eliminación

No existe eliminación física desde UI para categorías, productos o personas con histórico.

Para entidades sin histórico, el MVP puede seguir usando desactivación en lugar de introducir un segundo comportamiento de borrado. Esto mantiene una regla uniforme y reduce complejidad.

## 12. Fuera del MVP

No incluir:

- iconos personalizados por categoría;
- colores personalizados por entidad;
- emojis configurables;
- orden manual;
- subcategorías;
- presupuestos distintos de 50/30/20;
- bancos o números de cuenta;
- tasas de interés configurables;
- teléfono/email de personas;
- sincronización con contactos;
- exportación o backup desde Configuración.

## 13. Decisiones congeladas

- Categorías ordinarias sólo usan `NEEDS` o `WANTS` como default.
- El 20% se representa con `SAVING`, no con una categoría ordinaria.
- Categorías, productos y personas se gestionan mediante activación/desactivación; no se borran físicamente desde UI.
- Un producto con saldo distinto de cero no puede desactivarse.
- `openingBalance` queda bloqueado después de existir histórico financiero del producto.
- Una persona con dinero pendiente no puede desactivarse.
- Nombres activos son únicos por tipo tras normalización `trim` + comparación case-insensitive.
- Reactivar también valida unicidad.
- Las listas usan orden alfabético y no tienen orden manual.
