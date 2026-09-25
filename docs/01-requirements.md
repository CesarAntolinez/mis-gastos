# 01 — Requisitos

## Requisitos funcionales

### RF-01 Registrar transacción

La persona puede crear una transacción indicando:

- Dirección: ingreso o egreso.
- Naturaleza del movimiento.
- Monto en COP.
- Fecha financiera.
- Concepto opcional.
- Categoría cuando aplique.
- Bloque 50/30/20 cuando aplique.
- Persona relacionada cuando aplique.
- Producto financiero cuando aplique.
- Transacción relacionada cuando aplique.

### RF-02 Bloques 50/30/20

Los egresos clasificables usan:

- Necesidades — 50%.
- Deseos — 30%.
- Ahorro — 20%.

Los porcentajes 50/30/20 no son configurables en el MVP.

### RF-03 Categorías configurables

Las categorías se persisten localmente y pueden:

- crearse;
- editarse;
- activarse;
- desactivarse.

Cada categoría tiene un bloque 50/30/20 por defecto. Una transacción puede sobrescribir ese bloque sin modificar la categoría ni otras transacciones.

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

Ahorro 20%:
- Ahorro / inversión

### RF-04 Saldo inicial

En la primera configuración la persona puede indicar un saldo inicial disponible. Este saldo aumenta el disponible pero no cuenta como ingreso base 50/30/20.

### RF-05 Productos financieros

La persona puede crear múltiples productos financieros simples con:

- nombre;
- saldo inicial;
- estado activo/inactivo.

Un aporte desde disponible hacia un producto financiero:

- disminuye disponible;
- aumenta el saldo del producto;
- cuenta como egreso del bloque 20%.

Un retiro desde un producto hacia disponible:

- aumenta disponible;
- disminuye el saldo del producto;
- no aumenta el ingreso base.

No puede retirarse un monto superior al saldo disponible del producto.

### RF-06 Rendimientos financieros

Los rendimientos se registran explícitamente como ingreso nuevo. No se calculan automáticamente.

### RF-07 Personas y cuentas por cobrar

La persona puede crear, editar y desactivar personas relacionadas con dinero por cobrar.

Un préstamo puede asociarse a una persona y admite pagos parciales.

La app muestra:

- monto original;
- monto pagado;
- saldo pendiente;
- estado pendiente/pagado.

Una persona puede tener varios préstamos independientes.

### RF-08 Reintegros y devoluciones

Cuando una entrada de dinero está relacionada con una salida anterior:

- si ocurre en el mismo mes calendario de la salida original, se trata como reintegro y no aumenta el ingreso base;
- si ocurre en un mes posterior, se trata como ingreso del nuevo período y sí aumenta el ingreso base.

Esta regla no aplica a retiros de ahorro, que nunca se consideran ingreso nuevo.

### RF-09 Dashboard

La pantalla principal debe poder mostrar, según la especificación de indicadores que se cerrará posteriormente:

- saldo disponible;
- ingreso base del período;
- egresos del período;
- montos 50/30/20;
- saldo total ahorrado;
- dinero por cobrar;
- comparación contra metas 50/30/20.

### RF-10 Periodicidad

Los indicadores pueden consultarse por:

- Semana.
- Mes.
- Año.

Mes es la vista por defecto.

El mes calendario sigue siendo la unidad contable usada por las reglas de reintegro aunque la visualización sea semanal o anual.

### RF-11 Historial

La persona puede consultar movimientos ordenados por fecha descendente y filtrar al menos por:

- período;
- ingreso/egreso;
- bloque 50/30/20;
- categoría;
- persona relacionada.

### RF-12 Editar y anular

Una transacción puede editarse siempre que el resultado conserve las invariantes del dominio.

La acción de eliminación visible debe implementarse internamente como anulación lógica. Una transacción anulada no participa en saldos, indicadores ni listados normales, pero permanece para trazabilidad.

No se puede anular una transacción origen si existen dependencias activas que dejarían el dominio inconsistente.

### RF-13 Persistencia

Todos los datos del MVP deben persistir localmente después de cerrar la aplicación.

## Requisitos no funcionales

### RNF-01 Offline first

Todas las funciones del MVP funcionan sin conexión a internet.

### RNF-02 Integridad monetaria

- Moneda única: COP.
- Montos almacenados como enteros en pesos.
- No usar `Float` ni `Double` para persistencia monetaria.
- Todo monto de transacción es mayor que cero; la dirección determina el signo lógico.

### RNF-03 Rendimiento

Las consultas de dashboard e historial deben filtrar y agregar desde persistencia sin requerir cargar todas las transacciones en memoria.

### RNF-04 Accesibilidad básica

- Contraste suficiente.
- Áreas táctiles adecuadas.
- Soporte razonable para tamaño de texto del sistema.
- No depender únicamente del color para comunicar estados.

### RNF-05 Configuración visual centralizada

Colores, tipografía, radios, espaciados y elevación viven en el sistema de diseño centralizado.

## Reglas y validaciones

- `amount > 0`.
- Fecha financiera obligatoria.
- `createdAt` y `updatedAt` no sustituyen la fecha financiera.
- Una categoría desactivada no aparece para nuevas transacciones, pero conserva su histórico.
- Modificar una categoría no modifica transacciones históricas.
- Un retiro de ahorro nunca aumenta el ingreso base.
- Un saldo inicial nunca aumenta el ingreso base.
- Los pagos acumulados de un préstamo no pueden superar el monto original pendiente.
- El saldo de un producto financiero no puede quedar negativo.
- Una transacción anulada no participa en cálculos.

## Definición de período de visualización

- Semana: lunes a domingo según hora local.
- Mes: mes calendario.
- Año: 1 de enero a 31 de diciembre.
