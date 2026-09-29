# 01 — Requisitos

## Requisitos funcionales

### RF-01 Registrar transacción

La persona puede iniciar operaciones desde una acción global `+ Registrar` sin elegir enums técnicos. La operación elegida determina la naturaleza del movimiento.

Operaciones visibles del MVP:

- Ingreso.
- Gasto.
- Ahorrar.
- Retirar ahorro.
- Reintegro / devolución.
- Prestar dinero.
- Registrar pago recibido.
- Registrar rendimiento financiero.

Campos comunes cuando aplican:

- Monto en COP.
- Fecha financiera.
- Concepto opcional.
- Categoría.
- Bloque 50/30/20.
- Persona relacionada.
- Producto financiero.
- Transacción relacionada.

### RF-02 Bloques 50/30/20

Los egresos clasificables usan:

- Necesidades — 50%.
- Deseos — 30%.
- Ahorro — 20%.

Los porcentajes 50/30/20 no son configurables en el MVP.

El bloque 20% está reservado para aportes propios a productos financieros mediante el flujo `Ahorrar`. Un préstamo a terceros sólo puede clasificarse en 50% o 30% según su motivo.

### RF-03 Categorías configurables

Las categorías se persisten localmente y pueden:

- crearse;
- editarse;
- activarse;
- desactivarse.

Cada categoría tiene un bloque por defecto `NEEDS` o `WANTS` para gastos ordinarios y préstamos. Una transacción puede sobrescribir ese bloque permitido sin modificar la categoría ni otras transacciones.

Cambiar el bloque por defecto de una categoría sólo afecta nuevas transacciones.

Categorías iniciales sugeridas:

Necesidades 50%:
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

Deseos 30%:
- Belleza
- Ropa
- Snacks
- Snacks trabajo
- Salidas
- Comidas por la calle

No se requiere una categoría artificial de ahorro: `SAVING` implica el bloque 20% y se relaciona con un producto financiero.

### RF-04 Saldo inicial

En el onboarding la persona puede indicar un saldo disponible inicial mayor o igual a cero.

- Si el monto es mayor que cero, se representa con una transacción `OPENING_BALANCE` fechada automáticamente el día local en que se confirma el onboarding.
- Si el monto es cero, no se crea una transacción de monto cero.
- El saldo inicial aumenta el disponible pero nunca cuenta como ingreso base 50/30/20.
- Sólo puede corregirse antes de existir movimientos financieros posteriores de uso normal.

### RF-05 Productos financieros

La persona puede crear múltiples productos financieros simples con:

- nombre;
- saldo inicial;
- estado activo/inactivo.

Un aporte desde disponible hacia un producto financiero:

- disminuye disponible;
- aumenta el saldo del producto;
- cuenta en el bloque 20% del período;
- no requiere categoría ordinaria.

Un retiro desde un producto hacia disponible:

- aumenta disponible;
- disminuye el saldo del producto;
- no aumenta el ingreso base;
- no reduce el cumplimiento de ahorro ya realizado del período.

No puede retirarse un monto superior al saldo disponible del producto.

`FinancialProduct.openingBalance` representa ahorro previo a la app y no aumenta disponible, ingreso base ni ahorro 20% del período.

### RF-06 Rendimientos financieros

Los rendimientos se registran explícitamente. No se calculan automáticamente.

Un rendimiento:

- aumenta el saldo del producto financiero;
- aumenta el ingreso base del período;
- no aumenta el saldo disponible hasta que exista un retiro.

### RF-07 Personas y cuentas por cobrar

La persona puede crear, editar y desactivar personas relacionadas con dinero por cobrar.

Un préstamo puede asociarse a una persona y admite pagos parciales.

La app muestra:

- monto original;
- monto pagado;
- saldo pendiente;
- estado pendiente/pagado.

Una persona puede tener varios préstamos independientes.

Crear un préstamo debe ser una operación atómica que genere la transacción `LOAN` y su `Receivable` asociada.

### RF-08 Reintegros y devoluciones

Cuando una entrada de dinero está relacionada con una salida anterior:

- si ocurre en el mismo mes calendario de la salida original, se trata como reintegro y no aumenta el ingreso base;
- si ocurre en un mes posterior, se trata como entrada computable del nuevo período y sí aumenta el ingreso base.

Debe conservarse la relación con la transacción original.

Esta regla no aplica a retiros de ahorro, que nunca se consideran ingreso nuevo.

Para reintegros de gastos ordinarios, el monto acumulado devuelto no puede superar el monto original activo.

### RF-09 Dashboard

La pantalla principal muestra según `09-indicators-dashboard.md`:

Estado actual:
- saldo disponible;
- saldo total ahorrado;
- dinero por cobrar.

Período seleccionado:
- ingreso base;
- Necesidades 50%;
- Deseos 30%;
- Ahorro 20%;
- objetivos, uso/cumplimiento y diferencias;
- últimos movimientos.

Los saldos del estado actual representan hoy y no cambian al navegar a un período histórico.

Interacciones mínimas:

- Ahorrado actual abre Productos financieros.
- Por cobrar actual abre cuentas por cobrar pendientes.
- Una tarjeta 50/30/20 abre Historial prefiltrado.
- Disponible actual es informativo en el MVP.

### RF-10 Periodicidad

Los indicadores pueden consultarse por:

- Semana.
- Mes.
- Año.

Mes es la vista por defecto.

El mes calendario sigue siendo la unidad contable usada por las reglas de reintegro aunque la visualización sea semanal o anual.

### RF-11 Historial

El Historial sigue el contrato de `11-history.md` y muestra movimientos reales, no resultados neteados.

Debe:

- iniciar en el mes actual;
- ordenar por `transactionDate DESC` y luego `createdAt DESC`;
- agrupar por fecha financiera;
- ocultar movimientos anulados por defecto;
- permitir búsqueda textual simple;
- permitir filtros por período, dirección/entrada-salida, bloque 50/30/20, categoría, naturaleza, persona, producto financiero y estado;
- combinar búsqueda y filtros;
- conservar período y filtros razonablemente durante la sesión al entrar y salir de Detalle.

Cuando Historial se abre desde Dashboard con un filtro, dicho filtro debe ser visible y removible sin perder el período seleccionado.

El Historial conserva por separado gasto y reintegro aunque el Dashboard utilice el gasto efectivo neto.

### RF-12 Detalle, edición y anulación

El detalle de un movimiento muestra sus datos, relaciones y un `Efecto financiero` calculado por dominio.

Una transacción puede editarse siempre que el resultado conserve las invariantes del dominio.

Reglas conservadoras del MVP:

- una transacción origen con dependencias activas no puede cambiar fecha financiera;
- un préstamo con pagos activos bloquea monto, fecha y persona;
- un gasto con reintegros activos bloquea monto y fecha;
- categoría, bucket y concepto sólo pueden editarse cuando la naturaleza y relaciones lo permitan sin romper invariantes.

La acción visible debe ser `Anular movimiento`. Internamente se usa anulación lógica.

Una transacción anulada:

- permanece persistida;
- deja de participar en saldos e indicadores;
- está oculta por defecto en Historial;
- puede consultarse mediante filtro;
- abre detalle sólo lectura.

No existe restauración ni anulación en cascada automática en el MVP.

No se puede anular una transacción origen si existen dependencias activas que dejarían el dominio inconsistente.

### RF-13 Navegación principal

La navegación inferior del MVP contiene:

- Resumen.
- Historial.
- Configuración.

La acción global `+ Registrar` está disponible desde Resumen e Historial.

No deben exponerse opciones de registro cuya persistencia, validaciones y flujo completo aún no estén implementados.

### RF-14 Onboarding y configuración inicial

El onboarding sigue `13-onboarding.md` y se completa una sola vez antes del uso normal.

Permite configurar:

- saldo disponible inicial, incluyendo `$0`;
- cero o más productos financieros iniciales y sus saldos.

Las categorías iniciales se crean automáticamente de forma idempotente al confirmar.

La confirmación final debe ser atómica: categorías seed, `OPENING_BALANCE` cuando corresponda, productos iniciales y `onboardingCompleted = true` se guardan como una única operación lógica.

Debe existir un estado explícito `AppSetup` o equivalente con `onboardingCompleted`; no se infiere desde cantidad de transacciones u otras entidades.

Si la app se cierra antes de confirmar, el MVP puede descartar el borrador y volver a iniciar onboarding. No debe haber persistencia parcial por navegar entre pasos.

No existe `Reiniciar onboarding` en el MVP.

### RF-15 Persistencia

Todos los datos del MVP deben persistir localmente después de cerrar la aplicación.

Las operaciones que crean varias entidades relacionadas deben persistirse de forma atómica.

## Requisitos no funcionales

### RNF-01 Offline first

Todas las funciones del MVP funcionan sin conexión a internet.

### RNF-02 Integridad monetaria

- Moneda única: COP.
- Montos almacenados como enteros en pesos.
- No usar `Float` ni `Double` para persistencia monetaria.
- Todo monto de transacción es mayor que cero; la naturaleza/dirección define su efecto.
- Saldos iniciales configurables pueden ser cero, pero no negativos.

### RNF-03 Rendimiento

Las consultas de dashboard e historial deben filtrar y agregar desde persistencia sin requerir cargar todas las transacciones en memoria.

Los filtros básicos de Historial no deben implementarse cargando todos los movimientos para filtrarlos posteriormente en UI.

### RNF-04 Accesibilidad básica

- Contraste suficiente.
- Áreas táctiles adecuadas.
- Soporte razonable para tamaño de texto del sistema.
- No depender únicamente del color para comunicar estados.

### RNF-05 Configuración visual centralizada

Colores, tipografía, radios, espaciados y elevación viven en el sistema de diseño centralizado.

## Reglas y validaciones

- `amount > 0` para transacciones persistidas.
- Fecha financiera obligatoria.
- `createdAt` y `updatedAt` no sustituyen la fecha financiera.
- Una categoría desactivada no aparece para nuevas transacciones, pero conserva su histórico.
- Modificar una categoría no modifica transacciones históricas.
- Un retiro de ahorro nunca aumenta el ingreso base.
- Un saldo inicial nunca aumenta el ingreso base.
- `FinancialProduct.openingBalance` nunca cuenta como ahorro del período.
- Los pagos acumulados de un préstamo no pueden superar el monto original pendiente.
- Los reintegros acumulados de un gasto no pueden superar el monto original activo.
- El saldo de un producto financiero no puede quedar negativo.
- Una transacción anulada no participa en cálculos.
- La UI no permite seleccionar `TransactionNature` directamente.
- Los anulados no pueden editarse ni restaurarse en el MVP.
- No crear transacción `OPENING_BALANCE` con monto cero.
- Las categorías seed no pueden duplicarse por reintentos de inicialización.

## Definición de período de visualización

- Semana: lunes a domingo según hora local.
- Mes: mes calendario.
- Año: 1 de enero a 31 de diciembre.
