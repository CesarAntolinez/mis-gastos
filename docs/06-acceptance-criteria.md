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
entonces tiene un bloque 50/30/20 por defecto configurable sin modificar código.

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

Dado un producto financiero con saldo suficiente para aceptar aportes,
cuando se registra un aporte desde disponible,
entonces disminuye disponible, aumenta el producto y el movimiento cuenta dentro del 20%.

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
entonces aumenta el saldo correspondiente y se considera ingreso nuevo según el flujo definido.

## AC-11 Préstamo a una persona

Dada una persona registrada,
cuando se crea un préstamo,
entonces existe una cuenta por cobrar asociada y el saldo pendiente inicia en el monto original.

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
entonces aumenta disponible, no aumenta ingreso base y reduce el gasto efectivo del mes según las fórmulas que se cierren para indicadores.

## AC-16 Devolución en mes posterior

Dado un préstamo realizado en un mes anterior,
cuando se recibe su devolución en un mes posterior,
entonces aumenta disponible y el pago se considera ingreso base del nuevo mes, conservando la relación con el préstamo original.

## AC-17 Retiro de ahorro en otro mes

Dado un ahorro realizado en cualquier mes anterior,
cuando se retira en un mes posterior,
entonces el retiro sigue sin considerarse ingreso base.

## AC-18 Anulación lógica

Dada una transacción activa,
cuando se anula válidamente,
entonces cambia a estado `VOIDED`, permanece en persistencia y deja de participar en cálculos financieros normales.

## AC-19 Dependencias activas

Dada una transacción origen con movimientos dependientes activos,
cuando su edición o anulación dejaría inconsistencias,
entonces la operación se bloquea o se exige resolver primero las dependencias.

## AC-20 Historial mensual por defecto

Dado que se abre Historial,
cuando no se ha cambiado la granularidad,
entonces comienza en el mes actual y ordena movimientos por fecha financiera descendente.

## AC-21 Períodos de visualización

Dado el selector de período,
cuando se elige Semana, Mes o Año,
entonces se usan los rangos calendario definidos y no se reinterpretan las naturalezas históricas de las transacciones.

## AC-22 Sin ingreso base

Dado un período con egresos o entradas no computables pero sin ingreso base,
cuando se muestran indicadores 50/30/20,
entonces no se presenta un 0% engañoso y se indica que no existe base de cálculo.

## AC-23 Persistencia offline

Dado un dispositivo sin conexión,
cuando la persona registra, consulta, edita o anula datos del MVP,
entonces todas las operaciones siguen funcionando localmente.

## AC-24 Tema centralizado

Dada cualquier pantalla,
cuando se revisa su implementación,
entonces colores, tipografía, shapes y spacing principales provienen del sistema visual centralizado.

## AC-25 Calidad de slice

Dado un slice marcado como terminado,
cuando se ejecutan sus pruebas y se recorre el flujo,
entonces no existen controles requeridos que conduzcan a funcionalidades incompletas o placeholders.

## Criterio de salida

El MVP sólo se considera terminado cuando los criterios aplicables están satisfechos y todos los slices definidos en `05-roadmap.md` cumplen su Definition of Done.
