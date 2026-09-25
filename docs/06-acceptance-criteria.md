# 06 — Criterios de aceptación del MVP

## AC-01 Moneda

Dada cualquier operación monetaria,
cuando se registra o calcula,
entonces se expresa en COP y se persiste como entero en pesos.

## AC-02 Saldo inicial

Dado un saldo inicial disponible,
cuando se configura la aplicación,
entonces aumenta el disponible pero no el ingreso base 50/30/20.

## AC-03 Categorías configurables

Dada una categoría,
cuando se crea o edita,
entonces tiene un bloque por defecto permitido sin modificar código.

## AC-04 Histórico de categoría

Dada una transacción existente,
cuando posteriormente cambia el bloque por defecto de su categoría,
entonces la transacción conserva su bloque histórico original.

## AC-05 Sobrescritura de bloque

Dada una categoría con bloque por defecto,
cuando la persona registra un egreso y selecciona otro bloque permitido,
entonces la transacción usa el bloque elegido sin cambiar la categoría global.

## AC-06 Ingreso nuevo

Dado un ingreso con naturaleza `NEW_INCOME`,
cuando se guarda,
entonces aumenta el saldo disponible y el ingreso base del período.

## AC-07 Aporte a ahorro

Dado un producto financiero válido,
cuando se registra un aporte desde disponible,
entonces disminuye disponible, aumenta el producto y el movimiento cuenta dentro del 20% del período sin requerir una categoría ordinaria.

## AC-08 Retiro de ahorro

Dado un producto financiero con saldo,
cuando se registra un retiro válido,
entonces aumenta disponible, disminuye el producto y no aumenta el ingreso base.

## AC-09 Saldo financiero no negativo

Dado un producto financiero,
cuando se intenta retirar más que su saldo,
entonces la operación es rechazada y no se persiste parcialmente.

## AC-10 Rendimiento financiero

Dado un rendimiento registrado explícitamente,
cuando se guarda,
entonces aumenta el saldo del producto y el ingreso base, pero no aumenta directamente el saldo disponible.

## AC-11 Préstamo a una persona

Dada una persona registrada,
cuando se crea un préstamo,
entonces existe una transacción `LOAN` y una cuenta por cobrar asociada dentro de una única operación atómica, y el saldo pendiente inicia en el monto original.

El préstamo sólo puede clasificarse en `NEEDS` o `WANTS`.

## AC-12 Pago parcial

Dada una cuenta por cobrar pendiente,
cuando se registra un pago menor al saldo,
entonces disminuye el pendiente y la cuenta permanece en estado `PENDING`.

## AC-13 Pago completo

Dada una cuenta por cobrar,
cuando los pagos activos acumulados alcanzan el monto original,
entonces el pendiente es cero y el estado pasa a `PAID`.

## AC-14 Sobrepago

Dada una cuenta por cobrar,
cuando un pago haría que los pagos acumulados superen el monto original,
entonces la operación es rechazada.

## AC-15 Reintegro mismo mes

Dada una salida y una devolución relacionada dentro del mismo mes calendario,
cuando se registra la devolución,
entonces aumenta disponible, no aumenta ingreso base y reduce el gasto efectivo asociado al origen.

## AC-16 Devolución en mes posterior

Dada una salida o préstamo realizado en un mes anterior,
cuando se recibe su devolución en un mes posterior,
entonces aumenta disponible y se considera entrada computable del nuevo mes según las reglas de dominio, conservando la relación con el movimiento original.

## AC-17 Límite de reintegro

Dado un gasto original activo,
cuando la suma de reintegros activos intentaría superar su monto original,
entonces la operación se rechaza.

## AC-18 Retiro de ahorro en otro mes

Dado un ahorro realizado en cualquier mes anterior,
cuando se retira en un mes posterior,
entonces el retiro sigue sin considerarse ingreso base y no reduce retroactivamente el aporte 20% realizado en el período original.

## AC-19 Anulación lógica

Dada una transacción activa,
cuando se anula válidamente,
entonces cambia a estado `VOIDED`, permanece en persistencia y deja de participar en cálculos financieros normales.

## AC-20 Dependencias activas

Dada una transacción origen con movimientos dependientes activos,
cuando su edición o anulación dejaría inconsistencias,
entonces la operación se bloquea y la UI explica qué relación impide el cambio.

## AC-21 Historial mensual por defecto

Dado que se abre Historial,
cuando no se ha cambiado la granularidad,
entonces comienza en el mes actual, muestra sólo movimientos activos por defecto y ordena por fecha financiera descendente con `createdAt DESC` como segundo criterio.

## AC-22 Historial muestra movimientos reales

Dado un gasto y un reintegro relacionado,
cuando se consulta el Historial,
entonces ambos movimientos aparecen por separado en sus fechas financieras reales aunque el Dashboard utilice el costo efectivo neto.

## AC-23 Historial prefiltrado desde Dashboard

Dado que la persona toca una tarjeta 50/30/20 del Dashboard,
cuando se abre Historial,
entonces conserva el período seleccionado y muestra un filtro explícito correspondiente que puede eliminarse sin perder el período.

## AC-24 Filtros combinables

Dado un Historial con búsqueda y uno o más filtros,
cuando se aplican simultáneamente,
entonces sólo aparecen movimientos que cumplen la combinación y cada filtro activo es visible/removible.

## AC-25 Búsqueda de historial

Dado un texto de búsqueda,
cuando coincide con concepto, categoría, persona o producto financiero,
entonces el movimiento correspondiente puede encontrarse sin requerir búsqueda avanzada o fuzzy.

## AC-26 Estado de movimientos anulados

Dado un movimiento `VOIDED`,
cuando se abre Historial con estado por defecto,
entonces el movimiento no aparece.

Cuando se filtra por `Anulados` o `Todos`, entonces puede consultarse y muestra una etiqueta textual `Anulado`.

## AC-27 Detalle de movimiento

Dado un movimiento activo,
cuando se abre su detalle,
entonces se muestran sus datos aplicables, relaciones y un efecto financiero derivado por dominio, no recalculado manualmente por la UI.

## AC-28 Relación navegable

Dado un préstamo con pagos o un gasto con reintegros,
cuando se abre el detalle del origen o dependiente,
entonces las relaciones relevantes son visibles y permiten navegar entre movimientos relacionados.

## AC-29 Préstamo con pagos bloquea edición estructural

Dado un préstamo con al menos un pago activo,
cuando se intenta editar,
entonces monto, fecha financiera y persona no pueden modificarse; los campos no estructurales sólo pueden cambiar si conservan invariantes.

## AC-30 Gasto con reintegros bloquea edición estructural

Dado un gasto con al menos un reintegro activo,
cuando se intenta editar,
entonces monto y fecha financiera no pueden modificarse; otros campos sólo pueden cambiar si conservan invariantes.

## AC-31 Fecha de origen con dependencias

Dada una transacción origen con dependencias activas,
cuando la persona intenta cambiar la fecha financiera,
entonces la UI bloquea la operación para evitar reclasificación contable retroactiva de pagos/reintegros.

## AC-32 Sin anulación en cascada

Dada una transacción con dependencias activas,
cuando se intenta anular el origen,
entonces no se anulan automáticamente los movimientos relacionados; la operación se bloquea y se explica qué debe resolverse primero.

## AC-33 Anulado sólo lectura

Dado un movimiento anulado,
cuando se abre su detalle,
entonces se presenta sólo lectura y no existen acciones de Editar, Restaurar ni Anular nuevamente.

## AC-34 Estado vacío por período

Dado un período sin movimientos,
cuando se abre Historial,
entonces se muestra un estado vacío con acción `+ Registrar`.

## AC-35 Estado vacío por filtros

Dado un período con movimientos que quedan ocultos por búsqueda/filtros,
cuando no existen resultados visibles,
entonces la UI ofrece `Limpiar filtros` y no trata el caso como si nunca existieran movimientos.

## AC-36 Períodos de visualización

Dado el selector de período,
cuando se elige Semana, Mes o Año,
entonces se usan los rangos calendario definidos y no se reinterpretan las naturalezas históricas de las transacciones.

## AC-37 Sin ingreso base

Dado un período con egresos o entradas no computables pero sin ingreso base,
cuando se muestran indicadores 50/30/20,
entonces no se presenta un `0%` engañoso y se indica que no existe base de cálculo.

## AC-38 Saldo disponible actual

Dado cualquier período histórico seleccionado,
cuando se muestra el Dashboard,
entonces `Disponible actual` representa el saldo actual global y no cambia únicamente por navegar a otro período histórico.

## AC-39 Estado actual diferenciado

Dado un período histórico seleccionado,
cuando se muestran Disponible, Ahorrado y Por cobrar,
entonces la UI los identifica visualmente como estado actual/hoy y no como cifras pertenecientes al período histórico.

## AC-40 Ingreso base

Dado un período con múltiples clases de entrada,
cuando se calcula `baseIncome`,
entonces sólo participan las naturalezas y relaciones autorizadas por `09-indicators-dashboard.md`.

## AC-41 Necesidades

Dado un período con ingreso base,
cuando se calcula Necesidades,
entonces:

- el objetivo es 50% del ingreso base;
- el monto usa gasto efectivo neto de reintegros válidos del mismo mes;
- se muestra participación respecto al ingreso;
- se muestra uso respecto al objetivo;
- se muestra restante o exceso.

## AC-42 Deseos

Dado un período con ingreso base,
cuando se calcula Deseos,
entonces:

- el objetivo es 30% del ingreso base;
- el monto usa gasto efectivo neto de reintegros válidos del mismo mes;
- se muestra participación respecto al ingreso;
- se muestra uso respecto al objetivo;
- se muestra restante o exceso.

## AC-43 Ahorro del período

Dado un período con aportes y retiros de ahorro,
cuando se calcula el indicador 20%,
entonces sólo los aportes `SAVING` suman al cumplimiento del período y los retiros no restan ese cumplimiento.

## AC-44 Saldo total ahorrado

Dados uno o más productos financieros,
cuando se calcula el ahorro actual,
entonces se suman saldos iniciales, aportes y rendimientos, y se restan retiros, incluyendo productos inactivos que conservan saldo/histórico.

## AC-45 Dinero por cobrar

Dadas cuentas por cobrar con pagos parciales,
cuando se muestra el total por cobrar,
entonces corresponde a la suma de montos originales menos pagos activos.

## AC-46 Estados Necesidades/Deseos

Dado un objetivo válido,
cuando el uso del presupuesto es menor a 80%,
entonces el estado es `WITHIN`;
cuando está entre 80% y 100% inclusive,
entonces es `NEAR_LIMIT`;
cuando supera 100%,
entonces es `EXCEEDED`.

Sin ingreso base el estado es `NO_BASE`.

## AC-47 Estados Ahorro

Dado un objetivo de ahorro válido,
cuando el cumplimiento es menor a 80%,
entonces el estado es `IN_PROGRESS`;
cuando está entre 80% inclusive y menos de 100%,
entonces es `NEAR_TARGET`;
cuando alcanza o supera 100%,
entonces es `TARGET_MET`.

Sin ingreso base el estado es `NO_BASE`.

## AC-48 Reintegro cruzando semanas

Dado un gasto y su reintegro en semanas distintas pero dentro del mismo mes calendario,
cuando se consultan indicadores,
entonces el reintegro corrige el costo efectivo del gasto original y no genera una métrica de gasto negativo en la semana de devolución.

El historial conserva ambas fechas reales.

## AC-49 Cálculo anual

Dado un año seleccionado,
cuando se calculan 50/30/20,
entonces los objetivos se derivan directamente del ingreso base anual y no del promedio de porcentajes mensuales.

## AC-50 Flujo de caja del período

Dado un período,
cuando se muestra un resumen de entradas/salidas,
entonces `periodCashIn` y `periodCashOut` reflejan movimientos que cambian disponible, sin confundirse con `baseIncome`.

## AC-51 Navegación principal

Dada la aplicación después del onboarding,
cuando se muestra la navegación principal,
entonces existen únicamente los destinos `Resumen`, `Historial` y `Configuración`, con acción global `+ Registrar` desde Resumen e Historial.

## AC-52 Selector de operación

Dado que la persona toca `+ Registrar`,
cuando se muestran las operaciones disponibles,
entonces se usan nombres comprensibles (`Ingreso`, `Gasto`, `Ahorrar`, etc.) y nunca se solicita elegir manualmente un `TransactionNature`.

## AC-53 Operación no disponible

Dada una operación que requiere una entidad previa inexistente,
cuando la persona intenta iniciarla,
entonces la UI ofrece una acción previa válida o un estado vacío explicativo y no abre un formulario imposible de completar.

## AC-54 Guardado atómico

Dado un flujo que crea varias entidades relacionadas, como préstamo + cuenta por cobrar o pago + registro de pago,
cuando ocurre un error durante el guardado,
entonces no queda una parte de la operación persistida sin su contraparte.

## AC-55 Preservación de navegación

Dado un Historial con período, búsqueda o filtros activos,
cuando la persona abre un detalle y vuelve,
entonces conserva el estado razonable del Historial durante la sesión.

Después de guardar desde `+ Registrar`, la app vuelve al destino de origen sin duplicar destinos principales en el back stack.

## AC-56 Sin destinos muertos

Dado cualquier control navegable visible en una funcionalidad marcada como terminada,
cuando la persona lo toca,
entonces llega a un flujo funcional o a un estado definido, nunca a un placeholder no documentado.

## AC-57 Persistencia offline

Dado un dispositivo sin conexión,
cuando la persona registra, consulta, edita o anula datos del MVP,
entonces todas las operaciones siguen funcionando localmente.

## AC-58 Tema centralizado

Dada cualquier pantalla,
cuando se revisa su implementación,
entonces colores, tipografía, shapes y spacing principales provienen del sistema visual centralizado.

## AC-59 Fuente única de cálculos

Dado cualquier indicador del Dashboard,
cuando se revisa su implementación,
entonces las fórmulas se resuelven en una única capa de dominio conforme a `09-indicators-dashboard.md`; ViewModel y UI no duplican reglas de cálculo.

## AC-60 Calidad de slice

Dado un slice marcado como terminado,
cuando se ejecutan sus pruebas y se recorre el flujo,
entonces no existen controles requeridos que conduzcan a funcionalidades incompletas o placeholders.

## AC-61 Onboarding con estado inicial cero

Dada una instalación nueva,
cuando la persona completa onboarding con saldo disponible `$0` y sin productos financieros,
entonces el onboarding finaliza correctamente, `onboardingCompleted = true` y no se crea una transacción de monto cero.

## AC-62 Opening balance disponible

Dado un saldo disponible inicial mayor que cero,
cuando se confirma el onboarding,
entonces se crea una transacción `OPENING_BALANCE` con la fecha local de confirmación, aumenta el disponible y no aumenta ingreso base ni indicadores 50/30/20.

## AC-63 Ahorro inicial de producto

Dado un producto financiero creado durante onboarding con `openingBalance > 0`,
cuando se confirma,
entonces dicho saldo aumenta el producto pero no modifica disponible, ingreso base ni cumplimiento 20% del período.

## AC-64 Productos opcionales

Dada una instalación nueva,
cuando la persona decide no agregar productos financieros durante onboarding,
entonces puede continuar y usar normalmente la aplicación.

## AC-65 Seed idempotente

Dado que la inicialización de categorías se ejecuta más de una vez por reintento seguro,
cuando se completa,
entonces no existen categorías seed duplicadas.

## AC-66 Finalización atómica del onboarding

Dado un onboarding listo para confirmar,
cuando falla cualquier escritura de categorías seed, `OPENING_BALANCE`, productos iniciales o `AppSetup`,
entonces `onboardingCompleted` no queda marcado como `true` y no queda una configuración parcial confirmada.

## AC-67 Estado explícito de onboarding

Dado un usuario que completó onboarding con todos los montos en cero,
cuando vuelve a abrir la app,
entonces la aplicación entra al flujo principal porque consulta `AppSetup` o equivalente y no infiere el estado desde la existencia de transacciones.

## AC-68 Cierre antes de confirmar

Dado un onboarding no confirmado,
cuando la app se cierra y vuelve a abrir,
entonces puede reiniciar el onboarding sin haber creado productos, categorías seed o movimientos financieros parcialmente persistidos por navegar entre pasos.

## AC-69 Corrección de saldo inicial

Dado un `OPENING_BALANCE` inicial y ningún movimiento financiero posterior,
cuando se corrige su monto,
entonces el saldo disponible se recalcula sin convertir la corrección en ingreso base.

Dado que ya existe un movimiento financiero posterior,
cuando se intenta corregir el saldo inicial,
entonces la operación se bloquea.

## AC-70 Onboarding fuera del back stack

Dado que el onboarding se confirma correctamente,
cuando se navega al Dashboard y la persona pulsa Atrás,
entonces no regresa al onboarding.

## Criterio de salida

El MVP sólo se considera terminado cuando los criterios aplicables están satisfechos y todos los slices definidos en `05-roadmap.md` cumplen su Definition of Done.
