# Configuración

Este documento describe la gestión de datos maestros del MVP: categorías, productos financieros y personas. La sección `Configuración` no es una superficie para mover dinero; los movimientos se registran a través de los flujos de operaciones definidos en [`domain-rules.md`](./domain-rules.md).

## Alcance de Configuración

La navegación inferior `Configuración` contiene tres destinos:

- Categorías.
- Productos financieros.
- Personas.

Fuera del MVP: preferencias de moneda, exportación, backup, sincronización, temas configurables, bancos, números de cuenta y ajustes financieros avanzados.

## Principio de histórico

Categorías, productos financieros y personas pueden desactivarse, pero no deben eliminarse físicamente cuando tengan histórico asociado.

Desactivar una entidad:

- evita su selección en nuevas operaciones donde aplique;
- conserva relaciones históricas;
- conserva su disponibilidad en filtros históricos;
- no reescribe transacciones existentes.

## Categorías

Una categoría propone un bloque por defecto para gastos ordinarios y préstamos. En el MVP una categoría ordinaria solo puede proponer `NEEDS` o `WANTS`; nunca `SAVINGS`.

Atributos mínimos:

```text
id
name
defaultBucket  // NEEDS o WANTS
active
createdAt
updatedAt
```

### Lista de categorías

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
3. inactivas en sección o filtro secundario.

No existe orden manual ni arrastre de elementos en el MVP.

### Crear categoría

Campos:

```text
Nombre
Clasificación por defecto: 50% Necesidades | 30% Deseos
```

El nombre es obligatorio después de `trim`.

### Editar categoría

Campos editables:

- nombre;
- `defaultBucket`;
- estado activo/inactivo.

Cambiar `defaultBucket` afecta solo nuevas operaciones. El bloque registrado en operaciones anteriores permanece intacto.

### Desactivar categoría

Se permite desactivar aunque exista histórico, porque las operaciones conservan su vínculo con la categoría y su bloque histórico.

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

## Semilla inicial de categorías

La inicialización crea una sola vez las categorías base de forma idempotente. Reintentar la inicialización no duplica las categorías existentes.

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

No se crea una categoría ordinaria de ahorro; el ahorro se representa mediante operaciones `saving_contribution` y productos financieros.

## Productos financieros

Un producto financiero representa un contenedor local simple, no una integración bancaria.

Atributos mínimos:

```text
id
name
openingBalance  // saldo previo a usar la app
active
createdAt
updatedAt
```

`openingBalance` representa dinero existente antes de empezar a usar la aplicación. No constituye ingreso base ni ahorro del período y no afecta el saldo disponible.

Saldo actual derivado:

```text
openingBalance + aportes + rendimientos - retiros
```

Los rendimientos son movimientos explícitos ingresados por el usuario; la aplicación no los calcula ni los registra automáticamente.

### Lista de productos

Cada elemento muestra como mínimo:

```text
Nombre
Saldo actual
Estado activo/inactivo
```

Orden:

1. activos;
2. alfabético;
3. inactivos en sección o filtro secundario.

### Detalle de producto

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

- Ahorrar.
- Retirar.
- Registrar rendimiento.
- Editar.

Estas acciones reutilizan los flujos de operaciones definidos en [`domain-rules.md`](./domain-rules.md).

### Crear producto

Campos:

```text
Nombre
Saldo inicial COP
```

`openingBalance >= 0`.

Crear un producto con saldo inicial no crea ahorro del período ni ingreso base.

### Editar producto

Siempre editables mientras la entidad esté activa o la operación sea válida:

- nombre.

`openingBalance` solo puede modificarse mientras el producto no tenga transacciones financieras relacionadas activas o anuladas que formen parte de su histórico. Una vez existe cualquier movimiento relacionado, `openingBalance` queda bloqueado en el MVP.

No corregir saldos posteriores manipulando silenciosamente el saldo inicial.

### Desactivar producto

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

## Personas

`Person` identifica a alguien relacionado con cuentas por cobrar. No es una libreta de contactos.

Atributos mínimos:

```text
id
name
active
createdAt
updatedAt
```

No incluir teléfono, email, dirección, foto, sincronización de contactos ni recordatorios en el MVP.

### Lista de personas

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

### Crear persona

Campo:

```text
Nombre
```

Nombre obligatorio después de `trim`.

### Editar persona

Editables:

- nombre;
- estado cuando cumpla las reglas de desactivación.

Cambiar el nombre no modifica relaciones históricas; las operaciones siguen enlazadas por id.

### Desactivar persona

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

## Normalización y duplicados

Para nombres de categorías, productos financieros y personas se usa una forma normalizada para validación:

```text
normalizedName = trim + comparación case-insensitive
```

La capitalización original se conserva para presentación; la comparación de duplicados usa la forma normalizada.

Reglas del MVP:

- no pueden existir dos categorías activas con el mismo nombre normalizado;
- no pueden existir dos productos activos con el mismo nombre normalizado;
- no pueden existir dos personas activas con el mismo nombre normalizado.

Una entidad inactiva con el mismo nombre no debe provocar silenciosamente ambigüedad al reactivarse: la reactivación debe validar nuevamente unicidad entre activas.

Estas reglas son de dominio/aplicación y no deben depender únicamente de un índice de base de datos sin considerar el estado `active`.

## Información de uso

Para explicar restricciones, las listas y detalles pueden mostrar datos derivados:

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

Estos conteos y saldos son derivados; no son nuevas fuentes de verdad persistidas salvo que el diseño físico futuro justifique cachearlos.

## Confirmaciones

No requerir confirmación para cambios triviales de nombre.

Sí requerir confirmación para desactivar entidades.

La confirmación debe explicar el efecto funcional y que el histórico se conserva.

## Estados vacíos

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

## Integridad y eliminación

No existe eliminación física desde la interfaz para categorías, productos o personas con histórico.

Para entidades sin histórico, el MVP puede seguir usando desactivación en lugar de introducir un segundo comportamiento de borrado. Esto mantiene una regla uniforme y reduce complejidad.

## Fuera del MVP

No incluir en Configuración:

- iconos personalizados por categoría;
- colores personalizados por entidad;
- emojis configurables;
- orden manual de listas;
- subcategorías;
- presupuestos distintos de 50/30/20;
- bancos o números de cuenta;
- tasas de interés configurables;
- teléfono o email de personas;
- sincronización con contactos;
- exportación o backup desde Configuración.

## Decisiones congeladas

- Las categorías ordinarias solo usan `NEEDS` o `WANTS` como bloque por defecto.
- El 20% se representa con operaciones de aporte a ahorro, no con una categoría ordinaria.
- Categorías, productos y personas se gestionan mediante activación/desactivación; no se borran físicamente desde la interfaz.
- Un producto con saldo derivado distinto de cero no puede desactivarse.
- El `openingBalance` de un producto queda bloqueado después de existir histórico financiero relacionado.
- Una persona con dinero pendiente por cobrar no puede desactivarse.
- Los nombres activos son únicos por tipo tras normalización `trim` + comparación case-insensitive.
- Reactivar una entidad también valida unicidad de nombres activos.
- Las listas usan orden alfabético y no tienen orden manual.
