# Criterios de aceptación del MVP

Este documento consolida los setenta criterios de aceptación heredados como requisitos de producto canónicos para el MVP de Mis Gastos. Cada criterio conserva su identificador estable y se expresa como un resultado observable y verificable desde la perspectiva de la persona usuaria, independiente de la plataforma de implementación.

Los detalles de fórmulas, semántica de operaciones, configuración, historial, navegación y onboarding se mantienen en las fuentes de verdad vinculadas; este documento no las reproduce.

## 1. Registro financiero

- **AC-01 Moneda**: Toda operación monetaria se expresa en COP y se almacena como valor entero exacto de peso colombiano. Ver [`vision.md`](./vision.md) y [`domain-rules.md`](./domain-rules.md).

- **AC-02 Saldo inicial**: Configurar un saldo disponible inicial aumenta el disponible, pero no el ingreso base ni los indicadores 50/30/20. Ver [`onboarding.md`](./onboarding.md).

- **AC-03 Categorías configurables**: La persona puede asignar a cada categoría un bloque por defecto permitido (`Necesidades` o `Deseos`). Ver [`configuration.md`](./configuration.md).

- **AC-04 Histórico de categoría**: Si cambia el bloque por defecto de una categoría, las operaciones anteriores conservan el bloque histórico original. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-05 Sobrescritura de bloque**: Al registrar un gasto o préstamo, la persona puede elegir el otro bloque permitido (`Necesidades`/`Deseos`) sin cambiar la configuración global de la categoría. Ver [`configuration.md`](./configuration.md).

- **AC-06 Ingreso nuevo**: Registrar un ingreso nuevo aumenta el saldo disponible y el ingreso base del período. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-15 Reintegro mismo mes**: Una devolución vinculada a una salida y recibida dentro del mismo mes calendario aumenta el disponible, no aumenta el ingreso base y reduce el gasto efectivo del origen. Ver [`budgeting.md`](./budgeting.md).

- **AC-16 Devolución en mes posterior**: Una devolución recibida en un mes calendario posterior al mes de la salida o préstamo original aumenta el disponible y se reconoce como ingreso computable del nuevo mes, conservando la relación con el movimiento original. Ver [`domain-rules.md`](./domain-rules.md) y [`budgeting.md`](./budgeting.md).

- **AC-17 Límite de reintegro**: La suma acumulada de reintegros vinculados a un gasto original no puede superar el monto original; el exceso se rechaza. Ver [`budgeting.md`](./budgeting.md).

- **AC-19 Anulación lógica**: Al anular una operación válida, su estado cambia a `Anulado`, permanece en persistencia para auditoría y deja de participar en cálculos financieros normales. Ver [`history.md`](./history.md).

- **AC-20 Dependencias activas**: Si una operación origen tiene movimientos dependientes activos y su edición o anulación dejaría inconsistencias, la operación se bloquea y la interfaz explica qué relación impide el cambio. Ver [`history.md`](./history.md).

- **AC-27 Detalle de movimiento**: El detalle de una operación activa muestra sus datos aplicables, relaciones y explica claramente cómo afecta el disponible y los indicadores financieros. Ver [`history.md`](./history.md).

- **AC-28 Relación navegable**: En el detalle de un préstamo con pagos o de un gasto con reintegros, las relaciones relevantes son visibles y permiten navegar al detalle del movimiento relacionado. Ver [`history.md`](./history.md).

- **AC-29 Préstamo con pagos bloquea edición estructural**: Una vez un préstamo tiene al menos un pago activo, no se pueden modificar monto, fecha financiera ni persona; los campos no estructurales solo pueden cambiar si conservan las invariantes del dominio. Ver [`history.md`](./history.md).

- **AC-30 Gasto con reintegros bloquea edición estructural**: Una vez un gasto tiene al menos un reintegro activo, no se pueden modificar monto ni fecha financiera; otros campos solo pueden cambiar si conservan las invariantes del dominio. Ver [`history.md`](./history.md).

- **AC-31 Fecha de origen con dependencias**: Una operación origen con dependencias activas no puede cambiar su fecha financiera, para evitar reclasificación contable retroactiva de pagos o reintegros. Ver [`history.md`](./history.md).

- **AC-32 Sin anulación en cascada**: No se anulan automáticamente los movimientos relacionados al anular el origen; si existen dependencias activas, la operación se bloquea y se explica qué debe resolverse primero. Ver [`history.md`](./history.md).

- **AC-33 Anulado sólo lectura**: El detalle de una operación `Anulado` se presenta solo lectura y no ofrece acciones de Editar, Restaurar ni Anular nuevamente. Ver [`history.md`](./history.md).

- **AC-52 Selector de operación**: Al tocar `+ Registrar`, se muestran operaciones con nombres comprensibles (`Ingreso`, `Gasto`, `Ahorrar`, etc.) y nunca se solicita elegir manualmente un tipo de operación técnico. Ver [`navigation.md`](./navigation.md).

- **AC-53 Operación no disponible**: Si una operación requiere una entidad previa inexistente, la interfaz ofrece una acción previa válida o un estado vacío explicativo, y no abre un formulario imposible de completar. Ver [`navigation.md`](./navigation.md).

- **AC-54 Guardado atómico**: En flujos que crean varias entidades relacionadas, si ocurre un error durante el guardado no queda una parte de la operación persistida sin su contraparte. Ver [`domain-rules.md`](./domain-rules.md).

## 2. Presupuesto 50/30/20

- **AC-37 Sin ingreso base**: En un período sin ingreso base, los indicadores 50/30/20 no presentan un `0%` engañoso y se indica explícitamente que no existe base de cálculo. Ver [`budgeting.md`](./budgeting.md).

- **AC-40 Ingreso base**: El ingreso base de un período solo incluye las naturalezas y relaciones autorizadas en [`budgeting.md`](./budgeting.md).

- **AC-41 Necesidades**: En un período con ingreso base, el objetivo de Necesidades es 50% del ingreso base; el monto usa el gasto efectivo neto de reintegros válidos del mismo mes; se muestran participación respecto al ingreso, uso respecto al objetivo, y restante o exceso. Ver [`budgeting.md`](./budgeting.md).

- **AC-42 Deseos**: En un período con ingreso base, el objetivo de Deseos es 30% del ingreso base; el monto usa el gasto efectivo neto de reintegros válidos del mismo mes; se muestran participación respecto al ingreso, uso respecto al objetivo, y restante o exceso. Ver [`budgeting.md`](./budgeting.md).

- **AC-46 Estados Necesidades/Deseos**: Con ingreso base, el estado es `Dentro del límite` si el uso es menor a 80%, `Cerca del límite` entre 80% y 100% inclusive, y `Excedido` si supera 100%. Sin ingreso base el estado es `Sin base`. Ver [`budgeting.md`](./budgeting.md).

- **AC-47 Estados Ahorro**: Con ingreso base, el estado es `En progreso` si el cumplimiento es menor a 80%, `Cerca de la meta` entre 80% inclusive y menos de 100%, y `Meta alcanzada` al alcanzar o superar 100%. Sin ingreso base el estado es `Sin base`. Ver [`budgeting.md`](./budgeting.md).

- **AC-48 Reintegro cruzando semanas**: Un reintegro recibido en otra semana del mismo mes calendario corrige el costo efectivo del gasto original y no genera un gasto negativo en la semana de la devolución. El Historial conserva ambas fechas reales. Ver [`budgeting.md`](./budgeting.md) y [`history.md`](./history.md).

- **AC-49 Cálculo anual**: En la vista anual, los objetivos 50/30/20 se derivan directamente del ingreso base anual y no del promedio de porcentajes mensuales. Ver [`budgeting.md`](./budgeting.md).

- **AC-50 Flujo de caja del período**: El resumen de entradas y salidas del período refleja los movimientos que cambian el disponible, sin confundirse con el ingreso base. Ver [`budgeting.md`](./budgeting.md).

## 3. Ahorro y deudas

- **AC-07 Aporte a ahorro**: Registrar un aporte desde disponible hacia un producto financiero disminuye el disponible, aumenta el saldo del producto y cuenta dentro del 20% del período, sin requerir categoría ordinaria. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-08 Retiro de ahorro**: Registrar un retiro válido desde un producto financiero aumenta el disponible, disminuye el saldo del producto y no aumenta el ingreso base. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-09 Saldo financiero no negativo**: No se permite retirar más del saldo actual de un producto financiero; la operación se rechaza y no se persiste parcialmente. Ver [`configuration.md`](./configuration.md).

- **AC-10 Rendimiento financiero**: Registrar un rendimiento explícito aumenta el saldo del producto financiero y el ingreso base del período, pero no aumenta directamente el disponible. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-11 Préstamo a una persona**: Crear un préstamo genera una operación de préstamo y una cuenta por cobrar asociada de forma atómica; el saldo pendiente inicia en el monto original. El préstamo solo se clasifica en `Necesidades` o `Deseos`. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-12 Pago parcial**: Registrar un pago menor al saldo pendiente disminuye el pendiente y la cuenta por cobrar permanece en estado `Pendiente`. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-13 Pago completo**: Cuando los pagos acumulados alcanzan el monto original del préstamo, el saldo pendiente es cero y el estado pasa a `Pagado`. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-14 Sobrepago**: Un pago que haría que los pagos acumulados superen el monto original del préstamo es rechazado. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-18 Retiro de ahorro en otro mes**: Retirar en un mes posterior un ahorro realizado en un mes anterior no se considera ingreso base y no reduce retroactivamente el aporte del 20% realizado en el período original. Ver [`budgeting.md`](./budgeting.md).

- **AC-43 Ahorro del período**: El indicador 20% solo suma aportes propios al cumplimiento del período; los retiros no restan ese cumplimiento. Ver [`budgeting.md`](./budgeting.md).

- **AC-44 Saldo total ahorrado**: El ahorro actual se calcula sumando saldos iniciales, aportes y rendimientos, y restando retiros, incluyendo productos inactivos que conserven saldo o histórico. Ver [`domain-rules.md`](./domain-rules.md).

- **AC-45 Dinero por cobrar**: El total por cobrar corresponde a la suma de montos originales de préstamos menos pagos activos recibidos. Ver [`domain-rules.md`](./domain-rules.md).

## 4. Dashboard e historial

- **AC-21 Historial mensual por defecto**: Al abrir Historial sin cambiar la granularidad, se muestra el mes actual, solo operaciones activas por defecto, ordenadas por fecha financiera descendente y, como segundo criterio, por fecha de creación descendente. Ver [`history.md`](./history.md).

- **AC-22 Historial muestra movimientos reales**: Un gasto y su reintegro relacionado aparecen por separado en sus fechas financieras reales, aunque el Dashboard use el costo efectivo neto. Ver [`history.md`](./history.md).

- **AC-23 Historial prefiltrado desde Dashboard**: Al tocar una tarjeta 50/30/20 del Dashboard y abrir Historial, se conserva el período seleccionado y se aplica un filtro explícito correspondiente que la persona puede eliminar sin perder el período. Ver [`history.md`](./history.md) y [`navigation.md`](./navigation.md).

- **AC-24 Filtros combinables**: Al aplicar búsqueda y uno o más filtros simultáneamente, solo aparecen operaciones que cumplen la combinación; cada filtro activo es visible y se puede remover individualmente. Ver [`history.md`](./history.md).

- **AC-25 Búsqueda de historial**: La búsqueda textual encuentra operaciones por concepto, categoría, persona o producto financiero, sin requerir búsqueda avanzada ni fuzzy. Ver [`history.md`](./history.md).

- **AC-26 Estado de movimientos anulados**: Por defecto, las operaciones `Anulado` no aparecen en Historial. Cuando se filtra por `Anulados` o `Todos`, se pueden consultar y muestran una etiqueta textual `Anulado`. Ver [`history.md`](./history.md).

- **AC-34 Estado vacío por período**: Si un período no tiene movimientos, Historial muestra un estado vacío con acción `+ Registrar`. Ver [`history.md`](./history.md).

- **AC-35 Estado vacío por filtros**: Si una búsqueda o filtros ocultan todos los movimientos de un período, la interfaz ofrece `Limpiar filtros` y no trata el caso como si no existieran movimientos. Ver [`history.md`](./history.md).

- **AC-36 Períodos de visualización**: Al elegir Semana, Mes o Año en el selector de período, se usan los rangos calendario definidos y no se reinterpretan las naturalezas históricas de las operaciones. Ver [`budgeting.md`](./budgeting.md).

- **AC-38 Saldo disponible actual**: El indicador `Disponible actual` del Dashboard representa el saldo global actual y no cambia únicamente por navegar a otro período histórico. Ver [`navigation.md`](./navigation.md).

- **AC-39 Estado actual diferenciado**: En un período histórico seleccionado, los indicadores `Disponible`, `Ahorrado` y `Por cobrar` se identifican visualmente como estado actual/hoy, no como cifras del período histórico. Ver [`navigation.md`](./navigation.md).

- **AC-55 Preservación de navegación**: Al abrir un detalle desde Historial y volver, se conservan el período, la búsqueda y los filtros activos durante la sesión. Después de guardar desde `+ Registrar`, la aplicación vuelve al destino de origen sin duplicar destinos principales en el historial de navegación. Ver [`navigation.md`](./navigation.md).

## 5. Configuración y onboarding

- **AC-51 Navegación principal**: Después del onboarding, la navegación principal contiene únicamente `Resumen`, `Historial` y `Configuración`, con la acción global `+ Registrar` disponible desde `Resumen` e `Historial`. Ver [`navigation.md`](./navigation.md).

- **AC-61 Onboarding con estado inicial cero**: En una instalación nueva, completar el onboarding con saldo disponible `$0` y sin productos financieros finaliza correctamente, marca el onboarding como completado y no crea una operación de monto cero. Ver [`onboarding.md`](./onboarding.md).

- **AC-62 Opening balance disponible**: Con un saldo disponible inicial mayor que cero, la confirmación del onboarding crea un evento de saldo inicial con la fecha local de confirmación, aumenta el disponible y no aumenta el ingreso base ni los indicadores 50/30/20. Ver [`onboarding.md`](./onboarding.md).

- **AC-63 Ahorro inicial de producto**: Un producto financiero creado durante el onboarding con saldo inicial mayor que cero aumenta el saldo del producto pero no modifica el disponible, el ingreso base ni el cumplimiento del 20% del período. Ver [`onboarding.md`](./onboarding.md).

- **AC-64 Productos opcionales**: En una instalación nueva, la persona puede decidir no agregar productos financieros durante el onboarding y continuar usando normalmente la aplicación. Ver [`onboarding.md`](./onboarding.md).

- **AC-65 Seed idempotente**: Si la inicialización de categorías se ejecuta más de una vez, no existen categorías base duplicadas. Ver [`configuration.md`](./configuration.md).

- **AC-66 Finalización atómica del onboarding**: Si falla cualquier escritura de categorías base, saldo inicial, productos iniciales o estado de finalización, el onboarding no queda marcado como completado y no queda una configuración parcial confirmada. Ver [`onboarding.md`](./onboarding.md).

- **AC-67 Estado explícito de onboarding**: Al volver a abrir la aplicación tras completar el onboarding con todos los montos en cero, se entra al flujo principal porque se consulta el estado de finalización explícito, no porque se infiera desde la existencia de transacciones. Ver [`onboarding.md`](./onboarding.md).

- **AC-68 Cierre antes de confirmar**: Si el onboarding no se ha confirmado y la aplicación se cierra, se puede reiniciar el onboarding sin que queden productos, categorías base o movimientos financieros parcialmente persistidos por navegar entre pasos. Ver [`onboarding.md`](./onboarding.md).

- **AC-69 Corrección de saldo inicial**: Con un saldo inicial y ningún movimiento financiero posterior, la persona puede corregir su monto y el disponible se recalcula sin convertir la corrección en ingreso base. Si ya existe un movimiento financiero posterior, la corrección se bloquea. Ver [`onboarding.md`](./onboarding.md).

- **AC-70 Onboarding fuera del back stack**: Tras confirmar el onboarding correctamente, navegar al Dashboard y pulsar Atrás no regresa al onboarding. Ver [`onboarding.md`](./onboarding.md).

## 6. Confiabilidad, navegación y accesibilidad

- **AC-56 Sin destinos muertos**: Todo control navegable visible en una funcionalidad terminada conduce a un flujo funcional o a un estado definido; nunca a un placeholder no documentado. Ver [`navigation.md`](./navigation.md).

- **AC-57 Persistencia offline**: Sin conexión a red, la persona puede registrar, consultar, editar o anular datos del MVP y todas las operaciones siguen funcionando localmente. Ver [`vision.md`](./vision.md).

- **AC-58 Tema centralizado**: En cualquier pantalla, los colores, tipografía, formas y espaciado principales provienen del sistema visual centralizado. Ver [`navigation.md`](./navigation.md) y [`docs/design/design-system.md`](../design/design-system.md).

- **AC-59 Coherencia de indicadores**: Los indicadores del Dashboard coinciden con las reglas y fórmulas financieras documentadas para el período seleccionado. Ver [`budgeting.md`](./budgeting.md).

- **AC-60 Calidad de slice**: Cada funcionalidad terminada no expone controles requeridos que conduzcan a flujos incompletos o placeholders. Ver [`navigation.md`](./navigation.md).

## Resumen por área

| Área de producto | Cantidad |
|---|---|
| Registro financiero | 21 |
| Presupuesto 50/30/20 | 9 |
| Ahorro y deudas | 12 |
| Dashboard e historial | 12 |
| Configuración y onboarding | 11 |
| Confiabilidad, navegación y accesibilidad | 5 |
| **Total** | **70** |

## Requiere decisión

Ningún criterio fue marcado como obsoleto o en conflicto con la arquitectura aceptada durante esta migración. Cada identificador se conserva exactamente una vez como etiqueta de su criterio.
