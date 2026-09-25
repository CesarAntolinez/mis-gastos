# 10 — Navegación y flujos funcionales

Este documento define cómo se recorre el MVP y qué operación de dominio dispara cada flujo visible. Complementa `03-ux-ui.md`; no redefine las fórmulas de `09-indicators-dashboard.md`.

## 1. Navegación principal

La navegación inferior tiene tres destinos:

1. `Resumen`
2. `Historial`
3. `Configuración`

Existe una acción global prominente `+ Registrar` disponible desde Resumen e Historial.

No crear destinos principales adicionales para Ahorro o Por cobrar: se accede a ellos desde Resumen y Configuración para mantener una navegación pequeña.

Mapa conceptual:

```text
App
├── Onboarding
│   ├── Saldo disponible inicial
│   └── Productos financieros iniciales (opcional)
│
├── Resumen
│   ├── Indicadores 50/30/20
│   ├── Productos financieros
│   ├── Por cobrar
│   └── Últimos movimientos
│
├── Historial
│   ├── Filtros
│   └── Detalle / editar / anular
│
├── Registrar
│   ├── Ingreso
│   ├── Gasto
│   ├── Ahorro
│   ├── Retiro de ahorro
│   ├── Reintegro / devolución
│   ├── Préstamo
│   ├── Pago recibido
│   └── Rendimiento financiero
│
└── Configuración
    ├── Categorías
    ├── Productos financieros
    └── Personas
```

## 2. Resumen / Dashboard

### 2.1 Estructura

Orden recomendado:

1. Selector `Semana | Mes | Año`.
2. Navegación del período seleccionado.
3. Sección `Estado actual`:
   - Disponible actual.
   - Ahorrado actual.
   - Por cobrar actual.
4. `Ingreso base del período`.
5. Bloque Necesidades 50%.
6. Bloque Deseos 30%.
7. Bloque Ahorro 20%.
8. Opcional si cabe sin ruido: entradas y salidas de caja del período.
9. Últimos movimientos.
10. Acción global `+ Registrar`.

### 2.2 Estado actual frente a período

`Disponible`, `Ahorrado` y `Por cobrar` representan el estado actual a hoy y deben estar agrupados bajo una etiqueta explícita como `Estado actual`.

Cambiar el período histórico sólo modifica los indicadores de rendimiento y movimientos del período, no estas tres cifras actuales.

Ejemplo al consultar agosto:

```text
Agosto 2026

ESTADO ACTUAL · HOY
Disponible     $2.350.000
Ahorrado       $4.350.000
Por cobrar       $280.000

AGOSTO 2026
Ingreso base   ...
50 / 30 / 20   ...
```

La UI no debe inducir a interpretar los saldos actuales como saldos históricos de agosto.

### 2.3 Interacciones de tarjetas

- `Disponible actual`: informativa en el MVP; no navegar a un destino sin valor claro.
- `Ahorrado actual`: abre lista de Productos financieros.
- `Por cobrar actual`: abre lista de cuentas por cobrar pendientes.
- `Necesidades 50%`: abre Historial con período actual del Dashboard y filtro `NEEDS`.
- `Deseos 30%`: abre Historial con período actual y filtro `WANTS`.
- `Ahorro 20%`: abre Historial con período actual y naturaleza/aporte de ahorro prefiltrada.
- `Últimos movimientos`: tocar un movimiento abre su detalle; `Ver todos` abre Historial conservando el período cuando sea aplicable.

Un control visible no debe conducir a un placeholder.

### 2.4 Estado sin ingreso base

Se muestran montos absolutos disponibles, pero los porcentajes 50/30/20 se sustituyen por `—` y estado `Sin base de cálculo`.

Los saldos actuales continúan mostrándose normalmente.

## 3. Acción global `+ Registrar`

Al tocar `+ Registrar` se abre un bottom sheet o pantalla de selección breve con operaciones comprensibles para la persona, no nombres técnicos de `TransactionNature`.

Orden recomendado:

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

Si una opción no puede completarse por falta de configuración, no debe abrir un formulario roto. Debe conducir a la acción previa necesaria.

Ejemplos:

- `Ahorrar` sin productos financieros: mostrar explicación + `Crear producto`.
- `Pago recibido` sin cuentas pendientes: mostrar estado vacío + opción de volver, no formulario inválido.
- `Préstamo` sin personas: permitir crear persona dentro del flujo o mediante una acción clara antes de continuar.

## 4. Campos comunes de formularios

Salvo que el flujo indique otra cosa:

- Monto: obligatorio, entero COP mayor que cero.
- Fecha financiera: obligatoria, por defecto hoy.
- Concepto: opcional.
- Guardar: disponible sólo si el estado es válido o muestra validaciones inline al intentar guardar.

Después de guardar correctamente:

1. persistir operación completa de forma atómica;
2. volver al destino anterior;
3. refrescar datos mediante Flow, sin recarga manual;
4. mostrar confirmación breve no bloqueante.

No crear parcialmente una operación compuesta si una parte falla.

## 5. Flujo — Registrar ingreso

### Campos

```text
Monto
Fecha
Concepto opcional
```

Naturaleza generada:

```text
NEW_INCOME
```

Efecto:

- aumenta disponible;
- aumenta ingreso base del período correspondiente.

No solicitar categoría ni bloque 50/30/20.

## 6. Flujo — Registrar gasto

### Campos

```text
Monto
Categoría
Clasificación 50 / 30 / 20
Fecha
Concepto opcional
```

Comportamiento:

1. seleccionar categoría;
2. el formulario propone `defaultBucket`;
3. la persona puede cambiar el bucket para esa transacción;
4. guardar el bucket elegido como fuente histórica de verdad.

Naturaleza:

```text
EXPENSE
```

Efecto:

- disminuye disponible;
- participa en el bloque persistido.

No modificar `defaultBucket` de la categoría cuando se sobrescribe una transacción.

## 7. Flujo — Ahorrar

Representa mover dinero disponible hacia un producto financiero.

### Campos

```text
Monto
Producto financiero destino
Fecha
Concepto opcional
```

Naturaleza:

```text
SAVING
```

Bucket implícito:

```text
SAVINGS / 20%
```

No pedir categoría normal para este flujo. La naturaleza ya explica el movimiento y evita categorías artificiales redundantes.

Efecto:

- disminuye disponible;
- aumenta saldo del producto;
- suma al cumplimiento 20% del período.

Validación:

- el disponible resultante no se usa como restricción dura en el MVP salvo que se decida posteriormente impedir disponible negativo; no asumir esta regla sin especificación expresa.

## 8. Flujo — Retirar ahorro

### Campos

```text
Monto
Producto financiero origen
Fecha
Concepto opcional
```

Naturaleza:

```text
SAVING_WITHDRAWAL
```

Efecto:

- disminuye saldo del producto;
- aumenta disponible;
- no aumenta ingreso base;
- no reduce el ahorro realizado del período.

Validación obligatoria:

```text
monto <= saldo actual del producto
```

## 9. Flujo — Reintegro / devolución

Se usa cuando vuelve dinero correspondiente a un gasto previo, distinto del flujo específico de cuenta por cobrar.

### Paso 1

Seleccionar el gasto original entre movimientos elegibles.

### Paso 2

Registrar:

```text
Monto devuelto
Fecha
Concepto opcional
```

Validaciones:

- monto acumulado de devoluciones activas <= monto del gasto original;
- no permitir relacionar con una transacción anulada;
- guardar `relatedTransactionId`.

Regla contable:

- devolución en el mismo mes calendario del gasto original: `REIMBURSEMENT`, no aumenta ingreso base y reduce costo efectivo del gasto;
- devolución en un mes calendario posterior: se trata como entrada computable del nuevo mes según las reglas de dominio, conservando relación con el gasto original.

La UI puede seguir titulando el movimiento `Reintegro` aunque internamente su participación en ingreso base cambie por período contable.

## 10. Flujo — Prestar dinero

### Campos

```text
Persona
Monto
Categoría
Clasificación 50 / 30
Fecha
Concepto opcional
```

El préstamo es una salida del disponible y debe poder clasificarse según su motivo. No usar el bloque 20% para un préstamo a terceros; 20% queda reservado para aportes reales a productos financieros propios.

La categoría propone bucket y la persona puede sobrescribir entre `NEEDS` y `WANTS`.

Operación atómica:

1. crear transacción `LOAN`;
2. crear `Receivable` enlazada a esa transacción;
3. pendiente inicial = monto original.

Efecto:

- disminuye disponible;
- participa en 50 o 30 según clasificación elegida;
- aumenta dinero por cobrar.

## 11. Flujo — Registrar pago recibido

Puede iniciarse desde `+ Registrar` o desde el detalle de una cuenta por cobrar.

### Paso 1

Seleccionar cuenta por cobrar pendiente si no viene preseleccionada.

Mostrar:

```text
Persona
Concepto/préstamo
Monto original
Pagado
Pendiente
```

### Paso 2

Campos:

```text
Monto recibido
Fecha
Concepto opcional
```

Validación:

```text
monto <= saldo pendiente
```

Operación atómica:

1. crear transacción de pago;
2. crear `ReceivablePayment`;
3. recalcular pendiente/estado.

Regla contable:

- mismo mes calendario del préstamo: reintegro y reduce gasto efectivo del préstamo;
- mes posterior: aumenta ingreso base del nuevo mes;
- siempre aumenta disponible;
- siempre reduce dinero por cobrar.

Cuando el pendiente llega a cero, la cuenta pasa a `PAID`.

## 12. Flujo — Registrar rendimiento financiero

### Campos

```text
Producto financiero
Monto
Fecha
Concepto opcional
```

Naturaleza:

```text
FINANCIAL_RETURN
```

Efecto:

- aumenta saldo del producto financiero;
- aumenta ingreso base del período;
- no aumenta disponible.

No crear automáticamente un retiro.

## 13. Productos financieros

Acceso desde:

- `Ahorrado actual` en Dashboard;
- `Configuración > Productos financieros`.

Lista muestra como mínimo:

```text
Nombre
Saldo actual
Estado activo/inactivo
```

Detalle muestra:

- saldo inicial;
- saldo actual derivado;
- aportes/retiros/rendimientos recientes;
- acción `Ahorrar`;
- acción `Retirar`;
- edición del nombre/estado.

Desactivar no borra histórico ni saldo.

## 14. Por cobrar

Acceso desde `Por cobrar actual` en Dashboard.

Vista inicial prioriza pendientes.

Cada ítem:

```text
Persona
Concepto si existe
Monto pendiente
Monto original
```

Detalle:

```text
Persona
Fecha préstamo
Monto original
Pagado
Pendiente
Historial de pagos
Registrar pago
```

Puede existir una sección secundaria de cuentas pagadas, sin competir visualmente con pendientes.

## 15. Historial — comportamiento de destino prefiltrado

Cuando se abre desde una tarjeta del Dashboard debe recibir filtros explícitos y visibles.

Ejemplo:

```text
Septiembre 2026
Filtro: Necesidades 50%   [x]
```

La persona debe poder limpiar el filtro sin perder el período seleccionado.

## 16. Detalle, edición y anulación

El detalle de una transacción muestra:

- monto;
- naturaleza con etiqueta humana;
- fecha financiera;
- categoría/bucket cuando aplique;
- concepto;
- persona/producto cuando aplique;
- relaciones con otros movimientos.

### Edición

Movimiento independiente:
- editar campos permitidos normalmente.

Movimiento con dependencias:
- bloquear campos cuya modificación rompería invariantes;
- explicar el motivo en lenguaje claro.

Ejemplo: un préstamo con pagos no puede reducirse por debajo de lo ya pagado.

### Anulación

Usar término visible `Anular movimiento` para operaciones relacionadas y se puede usar `Eliminar` sólo si la UI explica que el registro se anula y no desaparece físicamente.

Si existen dependencias activas que quedarían inválidas, bloquear la anulación y mostrar cuáles deben resolverse primero.

## 17. Navegación hacia atrás y preservación de estado

- Volver desde un detalle conserva filtros/período del Historial.
- Volver de Registrar conserva el destino desde el que se abrió.
- Después de guardar, no crear una nueva instancia duplicada de Resumen/Historial en back stack.
- Cambiar entre tabs conserva razonablemente el período y filtros durante la sesión; no es necesario persistirlos entre cierres de app en el MVP.

## 18. Principios para implementación con agentes

- Cada opción del menú Registrar debe implementarse como slice completo antes de exponerse en UI productiva.
- No añadir una opción al selector si su formulario/persistencia/reglas todavía no están terminados.
- Los nombres visibles deben ser de usuario (`Ahorrar`, `Prestar dinero`), no enums (`SAVING`, `LOAN`).
- La selección de operación determina la naturaleza; la persona no elige `TransactionNature` manualmente.
- Formularios compuestos deben guardarse en una única transacción de base de datos cuando crean varias entidades relacionadas.
