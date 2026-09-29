# 00 — Product Brief

## Problema

Registrar gastos manualmente suele terminar en una lista de movimientos sin contexto. Mis Gastos busca convertir ingresos, egresos, ahorro y dinero por cobrar en una lectura simple del comportamiento financiero personal usando la metodología 50/30/20.

## Objetivo del MVP

Permitir registrar movimientos financieros en COP, clasificar egresos entre Necesidades 50%, Deseos 30% y Ahorro 20%, gestionar categorías configurables, registrar productos financieros simples y cuentas por cobrar, y consultar indicadores por semana, mes o año.

## Usuario objetivo

Persona que desea controlar sus finanzas personales de forma local, rápida y sin crear una cuenta.

## Principios del producto

- Offline first.
- Una sola moneda: COP.
- El historial financiero es trazable: movimientos anulados no se borran físicamente.
- Las reglas contables del MVP son explícitas y testeables.
- Las categorías son configurables sin modificar código.
- La clasificación 50/30/20 de una transacción es la fuente de verdad histórica.
- El diseño visual usa un sistema de tokens centralizado para permitir cambios globales futuros.

## Alcance MVP

Incluye:

- Android.
- Persistencia local.
- Registro de ingresos y egresos.
- Clasificación 50/30/20.
- Categorías configurables con bloque por defecto.
- Sobrescritura del bloque 50/30/20 por transacción.
- Concepto opcional.
- Fecha financiera editable.
- Saldo inicial disponible.
- Productos financieros simples con saldo inicial.
- Aportes y retiros de ahorro.
- Rendimientos financieros registrados explícitamente.
- Personas relacionadas con dinero por cobrar.
- Préstamos y pagos parciales.
- Reintegros y devoluciones con reglas por período contable.
- Dashboard e historial.
- Consulta por semana, mes y año.

No incluye:

- Login o multiusuario.
- Backend o sincronización.
- Integración bancaria.
- Tasas de cambio o monedas múltiples.
- Intereses automáticos.
- Modelado de bancos, números de cuenta o productos de inversión complejos.
- Sincronización con contactos.
- Recordatorios y notificaciones.
- Exportación/importación en la primera versión del MVP.
- Presupuestos distintos de 50/30/20.

## Regla de negocio central

La metodología 50/30/20 usa una base de ingreso computable, no toda entrada de dinero.

- Necesidades objetivo: 50% del ingreso base.
- Deseos objetivo: 30% del ingreso base.
- Ahorro objetivo: 20% del ingreso base.

Aumentar el saldo disponible no implica necesariamente aumentar el ingreso base. Por ejemplo, un retiro de ahorro aumenta disponible pero no constituye ingreso nuevo.

## Período contable

El mes calendario determina ciertas reglas de dominio, especialmente reintegros y devoluciones de préstamos.

Una devolución recibida dentro del mismo mes de la salida original se trata como reintegro. Si se recibe en un mes posterior, se trata como ingreso del nuevo período, salvo retiros de ahorro, que nunca constituyen ingreso nuevo.

## Métrica principal de éxito

Una persona puede abrir la app, registrar un movimiento y entender en menos de un minuto cómo cambia su saldo disponible y su distribución 50/30/20.