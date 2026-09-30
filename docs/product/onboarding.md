# Onboarding

El onboarding deja la aplicación lista para el primer uso sin obligar a reconstruir movimientos históricos. Solo se ejecuta una vez y se basa en dos preguntas: cuánto dinero disponible tiene la persona hoy y, opcionalmente, qué dinero ya tiene guardado en productos financieros propios.

## Camino feliz

1. Bienvenida con la regla 50/30/20.
2. Saldo disponible inicial, que puede ser `$0`.
3. Productos financieros existentes, opcionales y también con saldo `$0` permitido.
4. Resumen y confirmación final.
5. Dashboard; el onboarding desaparece del back stack.

## Objetivo

Responder únicamente:

```text
¿Cuánto dinero disponible tienes hoy?
¿Ya tienes dinero ahorrado en algún producto financiero?
```

No solicita ingreso mensual estimado, gastos históricos, préstamos anteriores, personas, metas de ahorro, login ni personalización avanzada.

## Reglas de entrada

- Si el onboarding aún no se ha completado, la aplicación inicia en el flujo de onboarding.
- El estado de finalización es explícito; no se infiere de la cantidad de transacciones, categorías o productos.
- Una persona puede completar onboarding legítimamente con todos los montos en `$0`.

## Pasos

### 1. Bienvenida

Contenido mínimo:

```text
Mis Gastos

Organiza tu dinero con la regla 50 / 30 / 20.

Necesidades · 50%
Deseos · 30%
Ahorro · 20%

Puedes comenzar con el dinero que tienes hoy,
sin registrar todos tus movimientos anteriores.

[Comenzar]
```

No usar carruseles largos ni tutoriales obligatorios en el MVP.

### 2. Saldo disponible inicial

Pregunta:

```text
¿Cuánto dinero tienes disponible actualmente?
```

Ayuda:

```text
Incluye el dinero que puedes usar para tus gastos actuales.
No incluyas dinero guardado en productos de ahorro;
podrás agregarlo en el siguiente paso.
```

Reglas:

| Aspecto | Regla |
| --- | --- |
| Moneda | COP, sin decimales. |
| Valor por defecto | `$0`. |
| Mínimo | `$0`; no se permiten valores negativos. |
| Continuar con `$0` | Permitido. |
| Fecha | Se toma automáticamente la fecha local de confirmación; la persona no la elige. |

Efecto:

- Si el monto es mayor que cero, se registra como un evento de saldo inicial que aumenta el disponible.
- Si el monto es `$0`, no se crea un evento de valor cero.
- En ambos casos el saldo inicial nunca cuenta como ingreso base ni participa en 50/30/20.

### 3. Productos financieros existentes

Este paso es opcional. La persona puede agregar uno o más productos financieros propios o continuar sin ninguno.

Campos por producto:

```text
Nombre
Saldo inicial COP
```

Reglas:

| Aspecto | Regla |
| --- | --- |
| Nombre | Obligatorio después de `trim`; se aplica la normalización y unicidad definidas en [`configuration.md`](./configuration.md). |
| Saldo inicial | Mayor o igual a `$0`; puede comenzar en `$0`. |
| Estado | Activo desde su creación. |

Efecto:

- El saldo inicial de un producto es una condición inicial, no un ingreso ni un aporte de ahorro del período.
- No aumenta el saldo disponible.
- No cuenta para el ingreso base.
- No cuenta para el cumplimiento del 20% de ahorro del período.

Ejemplo:

```text
Disponible inicial       $2.000.000
Fondo de emergencia      $3.000.000
```

Resultado:

```text
Disponible               $2.000.000
Ahorrado                 $3.000.000
Ingreso base             $0
Ahorro 20% período       $0
```

No debe interpretarse como `$5.000.000` disponibles menos un aporte de `$3.000.000`.

### 4. Resumen y confirmación

Antes de finalizar se muestra un resumen similar a:

```text
Todo listo

Disponible
$2.350.000

Ahorros
$4.200.000
  Fondo de emergencia   $3.000.000
  Cuenta ahorro         $1.200.000

Categorías
16 categorías iniciales

La regla 50/30/20 comenzará a calcularse
con los ingresos computables que registres.

[Comenzar a usar Mis Gastos]
```

Desde el resumen la persona puede volver atrás y corregir saldo o productos. La configuración definitiva se persiste únicamente al confirmar.

## Persistencia atómica

La confirmación final guarda todo como una única operación lógica:

1. Crear las categorías iniciales de forma idempotente.
2. Crear el evento de saldo inicial si el disponible inicial es mayor que cero.
3. Crear los productos financieros iniciales.
4. Marcar el onboarding como completado.

Si falla cualquier parte, no debe quedar una inicialización parcial marcada como completada. No deben existir categorías, productos ni movimientos parcialmente creados por navegar entre pasos.

## Abandono o interrupción

En el MVP no es obligatorio persistir el borrador de los pasos intermedios. Si la aplicación se cierra antes de confirmar:

- El onboarding vuelve a iniciarse al abrir la aplicación.
- No queda persistido un estado incompleto.
- No quedan productos, categorías seed ni movimientos financieros parciales.

## Finalización y back stack

Una vez completado:

- La aplicación navega al Dashboard.
- El onboarding se elimina del back stack principal; presionar Atrás no debe regresar al flujo inicial.
- El flujo de onboarding no se muestra de nuevo en inicios normales.
- No existe opción de reiniciar onboarding en el MVP.

## Correcciones después del onboarding

- El saldo disponible inicial solo puede corregirse mientras no exista ningún movimiento financiero posterior vinculado al uso normal de la aplicación.
- La corrección no transforma el saldo inicial en ingreso base.
- El `openingBalance` de un producto financiero solo puede corregirse mientras el producto no tenga histórico financiero relacionado.
- Si el onboarding se completó con `$0` y ya existen movimientos posteriores, no se permite crear retrospectivamente un saldo inicial desde Configuración como corrección silenciosa.

## Escenarios iniciales válidos

### Todo en cero

```text
Disponible       $0
Productos        ninguno
```

Resultado: onboarding completado, disponible `$0`, sin base de cálculo para 50/30/20.

### Solo ahorro existente

```text
Disponible              $0
Fondo de emergencia     $5.000.000
```

Resultado: disponible `$0`, ahorrado `$5.000.000`, ingreso base `$0`.

### Solo disponible

```text
Disponible              $2.000.000
Productos               ninguno
```

No es obligatorio crear un producto hasta que la persona quiera ahorrar.

## Fuera del alcance del onboarding MVP

No solicita ni configura:

- ingreso mensual estimado;
- salario;
- gastos históricos;
- préstamos históricos;
- personas;
- metas de ahorro;
- personalización de categorías;
- porcentajes distintos de 50/30/20;
- banco o cuenta bancaria;
- email o login;
- backup;
- notificaciones;
- preferencias visuales.

## Decisiones congeladas

- El onboarding se completa una sola vez.
- Puede completarse con todos los montos en `$0`.
- El saldo disponible inicial mayor que cero se representa como un evento de saldo inicial.
- Un saldo disponible inicial de `$0` no crea un evento de valor cero.
- El saldo inicial de un producto es una condición inicial, no un ingreso ni un aporte de ahorro del período.
- Los productos financieros son opcionales.
- Las categorías iniciales se crean automática e idempotentemente al confirmar.
- No se registran movimientos históricos durante el onboarding.
- La confirmación del onboarding es atómica.
- El estado de finalización es explícito; no se infiere de datos financieros.
- No es obligatorio persistir el borrador antes de confirmar.
- El saldo disponible inicial solo puede corregirse antes de existir movimientos financieros posteriores.
- No existe reinicio de onboarding en el MVP.

## Referencias

- [`vision.md`](./vision.md)
- [`domain-rules.md`](./domain-rules.md)
- [`budgeting.md`](./budgeting.md)
- [`configuration.md`](./configuration.md)
- [`roadmap.md`](./roadmap.md)
- [`docs/architecture/decisions/009-financial-accounting-semantics.md`](../architecture/decisions/009-financial-accounting-semantics.md)
