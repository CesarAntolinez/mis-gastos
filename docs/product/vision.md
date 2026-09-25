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

- `docs/product/vision.md`: propósito y límites del producto.
- `docs/product/domain-rules.md`: semántica financiera e invariantes del dominio.
- `docs/product/roadmap.md`: capacidades y orden de evolución.
- `docs/development/workflow.md`: cómo una decisión de producto llega a implementación.

Los Issues representan trabajo operativo. SDD, cuando se selecciona explícitamente, formaliza un cambio; no reemplaza estas fuentes de verdad de producto.
