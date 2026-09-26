# ADR-005 — Representación monetaria

**Status:** accepted  
**Date:** 2026-09-26

## Context

Mis Gastos realiza cálculos financieros y necesita evitar errores de precisión asociados a números binarios de punto flotante. También debe distinguir el valor monetario de la semántica del movimiento: un gasto no debe depender de que el monto se almacene negativo y un ingreso no debe depender de almacenarlo positivo.

Aunque COP es la moneda inicial esperada, el modelo no debe codificar una suposición irreversible de una única moneda.

## Decision

Representar dinero en el dominio mediante un value object conceptual `Money` compuesto por:

- `minorUnits`: entero con las unidades menores de la moneda;
- `currency`: código de moneda ISO 4217.

Ejemplos:

```text
COP 125.000  -> minorUnits = 125000, currency = COP
USD 12.50    -> minorUnits = 1250,   currency = USD
```

No usar `double`/floating point para almacenar o calcular montos financieros.

Los montos de movimientos serán magnitudes no negativas. La dirección y semántica del dinero se derivan del tipo/estructura del movimiento, no del signo del monto.

Ejemplos conceptuales:

```text
Expense(amount: COP 25.000)          -> salida
Income(amount: COP 800.000)          -> entrada
Transfer(amount: COP 100.000)        -> origen -> destino
```

El formateo de moneda pertenece a presentación y debe respetar locale y moneda.

## Alternatives

### `double`

No se selecciona debido a errores de representación y acumulación inherentes al punto flotante binario.

### Decimal arbitrario como representación persistente principal

Puede resolver precisión decimal, pero añade una dependencia y complejidad que no se justifican para el alcance actual cuando las unidades menores enteras representan correctamente las monedas soportadas.

### Montos con signo

No se selecciona como contrato principal porque mezcla magnitud con semántica. Un traslado, reintegro o ajuste no debe inferirse únicamente por `+` o `-`.

## Consequences

- SQLite puede persistir `minorUnits` como entero junto al código de moneda.
- Operaciones aritméticas deben validar compatibilidad de moneda.
- La UI es responsable de separadores, símbolo, posición del símbolo y decimales visibles.
- El dominio puede mantener operaciones exactas sin depender del locale.
- Si posteriormente se soportan monedas con características no cubiertas por ISO 4217/unidades menores estándar, deberá abrirse una nueva decisión.

## Guardrails

- Nunca convertir montos a `double` para cálculos de dominio.
- No asumir que todas las monedas tienen dos decimales.
- No asumir que el símbolo identifica inequívocamente la moneda.
- No mezclar dos monedas en una suma sin una regla explícita de conversión; conversión de divisas queda fuera del MVP.
- Validar overflow/rangos razonables en los límites donde corresponda.
- Persistencia y dominio deben conservar el código de moneda cuando el dato pueda requerirlo.

## References

- `docs/product/domain-rules.md`
- `docs/architecture/decisions/001-mobile-framework.md`
- `docs/architecture/decisions/002-persistence.md`
