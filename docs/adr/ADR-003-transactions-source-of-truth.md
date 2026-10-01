# ADR-003 — Transacciones como fuente de verdad financiera

> **Histórico / legacy.** Este ADR pertenece a la era Kotlin/Room del proyecto y **ya no es autoridad de implementación activa**. El principio "transacciones como fuente de verdad financiera" evolucionó al modelo `Financial Operation + Transaction Entry` de [`docs/architecture/decisions/007-financial-data-model.md`](../architecture/decisions/007-financial-data-model.md) (guía estructural, superseded para semántica contable) y [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md) (semántica contable vigente). El modelo plano `Transaction` de este ADR está obsoleto para la implementación actual.

- Estado: `Accepted` (en su momento, era Kotlin/Room)
- Fecha: 2026-09-25

## Contexto

El MVP maneja ingresos, gastos, ahorro, retiros, préstamos, pagos, reintegros y rendimientos. Varias de estas operaciones tienen entidades auxiliares para contexto, como cuentas por cobrar, personas o productos financieros.

Duplicar monto, fecha o concepto del mismo movimiento en varias tablas introduciría riesgo de divergencia.

## Decisión

`transactions` es la fuente de verdad de los movimientos financieros.

- Monto, fecha financiera, concepto, naturaleza, bucket y relaciones viven en la transacción cuando aplican.
- `receivables` representa la relación de una cuenta por cobrar, no una segunda copia del préstamo.
- `receivable_payments` relaciona la cuenta por cobrar con la transacción de pago; no duplica monto ni fecha.
- Saldos y pendientes se derivan de transacciones activas.
- Una transacción anulada permanece persistida con `status = VOIDED`.

## Consecuencias

### Positivas

- Evita estados inconsistentes entre tablas.
- Mejora trazabilidad.
- Reduce reglas de sincronización interna entre entidades.
- Permite recalcular saldos e indicadores desde hechos financieros explícitos.

### Costes

- Algunas consultas requieren joins y agregaciones.
- La capa de dominio debe validar coherencia de relaciones antes de persistir.

## Revisión futura

Si el volumen de datos justificara materializar proyecciones o saldos, deberá hacerse como caché derivada con ADR propio, nunca reemplazando a `transactions` como fuente primaria.
