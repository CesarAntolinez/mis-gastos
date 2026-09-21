# 06 — Criterios de aceptación del MVP

## AC-01 Crear ingreso

Dado que la persona abre el formulario,
cuando selecciona Ingreso, registra un monto válido, una fecha no futura y opcionalmente un concepto,
entonces la transacción se guarda sin bloque 50/30/20 ni categoría y aparece en el historial del período correspondiente.

## AC-02 Crear egreso

Dado que la persona selecciona Egreso,
cuando informa monto, fecha, bloque y una categoría válida para ese bloque,
entonces el egreso se guarda y aparece en historial y agregados del período.

## AC-03 Categorías coherentes

Dado un egreso clasificado en un bloque,
cuando se abre el selector de categoría,
entonces sólo se muestran categorías pertenecientes a ese bloque.

## AC-04 Cambio de bloque

Dado un egreso con categoría seleccionada,
cuando la persona cambia a otro bloque donde la categoría no es válida,
entonces la categoría se limpia y debe elegirse una nueva antes de guardar.

## AC-05 Persistencia

Dada una transacción guardada,
cuando se cierra y vuelve a abrir la app,
entonces la transacción sigue disponible.

## AC-06 Historial mensual por defecto

Dado que se abre Historial,
cuando no se ha cambiado la granularidad,
entonces se muestran únicamente las transacciones del mes seleccionado, comenzando por el mes actual.

## AC-07 Orden del historial

Dadas múltiples transacciones en el período,
cuando se muestra el historial,
entonces aparecen ordenadas por fecha descendente.

## AC-08 Editar

Dada una transacción existente,
cuando la persona cambia datos válidos y guarda,
entonces el registro existente se actualiza sin crear un duplicado.

## AC-09 Eliminar

Dada una transacción existente,
cuando la persona solicita eliminarla,
entonces se requiere confirmación y, tras confirmar, deja de participar en historial e indicadores.

## AC-10 Dashboard con ingresos

Dado un período con ingresos y egresos,
cuando se abre Resumen,
entonces se muestran ingresos, egresos, balance, montos por bloque y porcentaje de cada bloque respecto al ingreso total.

## AC-11 Metas 50/30/20

Dado un período con ingresos,
cuando se muestran los indicadores,
entonces Necesidades se compara con 50%, Deseos con 30% y Ahorro con 20%, incluyendo la diferencia en puntos porcentuales.

## AC-12 Sin ingresos

Dado un período con egresos pero sin ingresos,
cuando se abre Resumen,
entonces los montos absolutos se muestran, los porcentajes aparecen como no disponibles y la UI explica que hace falta registrar ingreso para calcular la distribución.

## AC-13 Sin transacciones

Dado un período sin transacciones,
cuando se abre Resumen o Historial,
entonces existe un estado vacío claro y una acción para registrar una transacción.

## AC-14 Semana

Dado que se selecciona Semana,
cuando se navega entre períodos,
entonces cada período comprende lunes a domingo y sólo participan las transacciones de ese rango.

## AC-15 Año

Dado que se selecciona Año,
cuando se consulta un año,
entonces sólo participan las transacciones entre 1 de enero y 31 de diciembre de ese año.

## AC-16 Dinero

Dado cualquier transacción o agregado,
cuando se persiste o calcula dinero,
entonces los valores monetarios base no dependen de `Float` ni `Double`.

## AC-17 Tema centralizado

Dada cualquier pantalla del MVP,
cuando se revisa su implementación visual,
entonces colores semánticos, tipografía, shapes y spacing principales provienen del sistema de diseño centralizado.

## AC-18 Offline

Dado un dispositivo sin conexión,
cuando la persona registra, consulta, edita o elimina transacciones,
entonces todas las funciones del MVP continúan operativas.

## AC-19 Calidad de slice

Dado un slice marcado como terminado,
cuando se ejecuta la suite asociada y se recorre su flujo,
entonces no existen controles visibles requeridos por ese slice que conduzcan a funcionalidades incompletas o placeholders.

## Criterio de salida del MVP

El MVP está terminado sólo cuando AC-01 a AC-19 están satisfechos y los slices 0 a 8 cumplen su Definition of Done.
