# Visión del producto

## Propósito

Mis Gastos es una aplicación móvil de finanzas personales orientada a registrar y comprender el dinero disponible, sus movimientos y su origen sin confundir movimientos internos con ingresos reales.

El producto debe permitir que una persona responda con claridad preguntas como:

- ¿Cuánto dinero tengo realmente disponible?
- ¿De dónde vino ese dinero?
- ¿En qué lo gasté?
- ¿Qué parte corresponde a ahorro u otros productos financieros?
- ¿Qué dinero salió temporalmente y luego regresó?
- ¿Quién me debe dinero y qué impacto tiene eso sobre mis finanzas?

## Principios de producto

1. **El significado financiero precede a la interfaz.** Cada movimiento debe tener una semántica definida antes de decidir cómo mostrarlo.
2. **No inflar ingresos.** Transferencias internas, devoluciones y reintegros no deben convertirse automáticamente en ingresos nuevos.
3. **Trazabilidad.** Cuando sea relevante, un movimiento debe poder relacionarse con el movimiento o evento que lo originó.
4. **Saldo comprensible.** El usuario debe poder entender por qué su disponible cambió.
5. **Registro simple, modelo riguroso.** La experiencia de captura debe ser rápida aunque internamente se conserven las relaciones necesarias.
6. **Evolución controlada.** Las reglas financieras centrales se documentan antes de modificarse.

## Modelo contable del MVP

El MVP se construye sobre un contrato financiero canónico que complementa los principios de producto:

- **COP única.** Moneda única peso colombiano (COP). Todos los montos se almacenan como enteros exactos de COP; no se usa punto flotante para dinero ni conversión de divisas en el MVP.
- **Evento antes que dirección.** La semántica de una operación —ingreso, gasto, traslado, reintegro, préstamo, pago, aporte a ahorro, retiro, rendimiento, saldo inicial— se interpreta a partir del tipo de operación y sus vínculos causales, no solo por la dirección contable de una entrada.
- **50/30/20 fijo.** Necesidades 50%, Deseos 30%, Ahorro 20% son porcentajes fijos e inmutables en el MVP; no son configurables por el usuario.
- **Períodos calendario.** La regla "mismo mes / mes posterior" entre un origen y su retorno compara siempre mes y año calendario, independientemente de que el dashboard muestre semana, mes o año.
- **Estados independientes.** El saldo disponible actual, el ahorro total y el dinero por cobrar son estados derivados hasta hoy; no cambian al navegar a un período histórico.

Las fórmulas completas de ingreso base, gasto efectivo por bloque, ahorro del período y estados se definen en [`budgeting.md`](./budgeting.md). La semántica de cada tipo de operación se detalla en [`domain-rules.md`](./domain-rules.md).

## Alcance del MVP

El MVP contempla como capacidades principales:

- registro de gastos;
- registro de ingresos con origen identificable;
- manejo de reintegros y retornos de dinero sin mezclarlos indiscriminadamente con ingresos;
- manejo de dinero movido hacia y desde ahorro u otros productos financieros;
- seguimiento básico de personas que deben dinero al usuario;
- detalle e historial de movimientos;
- configuración de la aplicación;
- onboarding inicial.

## Fuera de alcance inicial

Salvo que una decisión posterior lo incorpore explícitamente, el MVP no pretende ser un sistema de contabilidad formal, banca en línea, conciliación bancaria automática, plataforma de crédito ni sistema multiusuario.

## Fuentes de verdad

- `docs/product/vision.md`: propósito, límites y modelo contable del producto.
- `docs/product/domain-rules.md`: semántica financiera e invariantes del dominio.
- `docs/product/budgeting.md`: fórmulas de presupuesto 50/30/20, períodos y estados.
- `docs/product/configuration.md`: reglas de categorías, productos financieros, personas y semilla inicial.
- `docs/product/onboarding.md`: contrato de configuración inicial y finalización única.
- `docs/product/roadmap.md`: capacidades y orden de evolución.
- `docs/development/workflow.md`: cómo una decisión de producto llega a implementación.
- `docs/architecture/decisions/009-financial-accounting-semantics.md`: decisiones de arquitectura que fundamentan la semántica contable.

Los Issues representan trabajo operativo. SDD, cuando se selecciona explícitamente, formaliza un cambio; no reemplaza estas fuentes de verdad de producto.
