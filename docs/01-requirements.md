# 01 — Requisitos

## Requisitos funcionales

### RF-01 Registrar transacción

La persona puede crear una transacción indicando:

- Tipo: ingreso o egreso.
- Monto.
- Fecha.
- Concepto opcional.
- Si es egreso: bloque 50/30/20.
- Si es egreso: categoría predefinida.

### RF-02 Tipos 50/30/20 predefinidos

Los egresos deben clasificarse en una de estas opciones:

- Necesidades — 50%.
- Deseos — 30%.
- Ahorro — 20%.

### RF-03 Categorías predefinidas

Las categorías deben seleccionarse desde un catálogo local. Para el MVP:

Necesidades:
- Vivienda
- Alimentación básica
- Transporte
- Salud
- Servicios
- Educación
- Deudas esenciales
- Otros necesarios

Deseos:
- Restaurantes
- Entretenimiento
- Compras personales
- Suscripciones
- Viajes
- Hobbies
- Otros deseos

Ahorro:
- Fondo de emergencia
- Inversión
- Meta de ahorro
- Pago anticipado de deuda
- Otros ahorros

### RF-04 Dashboard

La pantalla principal muestra, para el período seleccionado:

- Total de ingresos.
- Total de egresos.
- Balance.
- Monto usado en Necesidades.
- Monto usado en Deseos.
- Monto usado en Ahorro.
- Porcentaje real de cada bloque respecto al ingreso.
- Diferencia frente a la meta 50/30/20.

### RF-05 Periodicidad

El dashboard debe poder consultarse por:

- Semana.
- Mes.
- Año.

Mes es la vista por defecto.

### RF-06 Navegación temporal

La persona puede moverse al período anterior o siguiente dentro de la granularidad seleccionada.

### RF-07 Historial

La persona puede ver las transacciones del período seleccionado ordenadas por fecha descendente.

Cada fila debe mostrar como mínimo:

- Tipo.
- Monto.
- Categoría cuando corresponda.
- Concepto si existe.
- Fecha.

### RF-08 Editar transacción

La persona puede modificar cualquier dato editable de una transacción existente.

### RF-09 Eliminar transacción

La persona puede eliminar una transacción con confirmación previa.

### RF-10 Persistencia

Las transacciones deben permanecer disponibles después de cerrar y volver a abrir la aplicación.

## Requisitos no funcionales

### RNF-01 Offline first

Todas las funciones del MVP deben funcionar sin conexión a internet.

### RNF-02 Rendimiento

Para una base local de hasta 10.000 transacciones, abrir dashboard e historial no debe depender de cargar todos los registros en memoria.

### RNF-03 Integridad monetaria

Los montos se almacenan como enteros en pesos. No se usa punto flotante para persistencia o cálculos monetarios.

### RNF-04 Accesibilidad básica

- Contraste suficiente.
- Áreas táctiles adecuadas.
- Soporte para tamaño de texto del sistema sin romper layouts principales.
- No depender únicamente del color para comunicar estado.

### RNF-05 Configuración visual centralizada

Colores, tipografía, radios, espaciados y elevación deben vivir en el sistema de diseño, no dispersos por pantallas.

## Reglas y validaciones

- Monto obligatorio y mayor que cero.
- Tipo obligatorio.
- Fecha obligatoria.
- Para ingreso, bloque 50/30/20 y categoría de egreso deben ser nulos.
- Para egreso, bloque y categoría son obligatorios.
- La categoría elegida debe pertenecer al bloque seleccionado.
- Concepto: opcional, máximo recomendado 120 caracteres.
- El MVP usa una sola moneda: COP.
- No se permiten fechas futuras para una transacción en el MVP.

## Estados del dashboard

### Sin transacciones

Mostrar un estado vacío con CTA para registrar la primera transacción.

### Con egresos pero sin ingresos

Mostrar montos absolutos, pero no porcentajes 50/30/20. Indicar que hace falta registrar ingresos para calcular la distribución.

### Con ingresos y sin egresos

Mostrar 0% usado en cada bloque y balance positivo.

## Definición de período

- Semana: lunes 00:00 a domingo 23:59:59 según hora local.
- Mes: primer al último día del mes calendario.
- Año: 1 de enero a 31 de diciembre.
