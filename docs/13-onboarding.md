# 13 — Onboarding

Este documento define la configuración inicial del MVP. El onboarding permite establecer un estado financiero inicial correcto sin obligar a reconstruir movimientos históricos anteriores.

## 1. Objetivo

El onboarding debe responder únicamente:

```text
¿Cuánto dinero disponible tienes hoy?
¿Ya tienes dinero ahorrado en algún producto financiero?
```

No solicita salario estimado, gastos históricos, préstamos históricos, personas, metas, login ni personalización avanzada.

## 2. Flujo

```text
Bienvenida
   ↓
Saldo disponible inicial
   ↓
Productos financieros existentes · opcional
   ↓
Resumen de configuración
   ↓
Comenzar
   ↓
Dashboard
```

Las categorías seed se crean automáticamente al confirmar el onboarding.

## 3. Bienvenida

Contenido breve:

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

## 4. Saldo disponible inicial

Pregunta:

```text
¿Cuánto dinero tienes disponible actualmente?
```

Explicación:

```text
Incluye el dinero que puedes usar para tus gastos actuales.
No incluyas dinero guardado en productos de ahorro;
podrás agregarlo en el siguiente paso.
```

Campo:

```text
Saldo disponible
$ __________ COP
```

Reglas:

- valor por defecto: `$0`;
- `openingAvailableBalance >= 0`;
- se puede continuar con `$0`;
- no se permiten valores negativos;
- la fecha financiera se establece automáticamente con la fecha local en que se confirma el onboarding;
- la persona no selecciona manualmente la fecha del saldo inicial.

## 5. Representación del saldo disponible inicial

Si el monto es mayor que cero, al confirmar se crea una transacción:

```text
nature = OPENING_BALANCE
amount = openingAvailableBalance
date = fecha local de finalización del onboarding
status = ACTIVE
```

Efectos:

```text
Disponible       + openingAvailableBalance
Ingreso base     + 0
50/30/20         sin efecto
```

Si el saldo inicial es `$0`, no es necesario crear una transacción de monto cero, porque `Transaction.amount > 0`. El estado inicial cero queda representado por ausencia de `OPENING_BALANCE` y `onboardingCompleted = true`.

## 6. Productos financieros existentes

El paso es opcional.

Opciones:

```text
[Agregar producto financiero]
[Ahora no]
```

Cada producto inicial solicita:

```text
Nombre
Saldo inicial COP
```

Puede agregarse más de uno antes de confirmar.

Reglas:

- nombre obligatorio;
- aplicar normalización/unicidad definida en `12-configuration.md`;
- `openingBalance >= 0`;
- un producto puede comenzar en `$0`;
- los productos creados durante onboarding comienzan activos.

## 7. Significado del saldo inicial de producto

El valor se persiste como:

```text
FinancialProduct.openingBalance
```

No se crea una transacción `SAVING` para representar ese dinero.

Efectos:

```text
Saldo producto       + openingBalance
Disponible           sin cambio
Ingreso base         sin cambio
Ahorro 20% período   sin cambio
```

Esta asimetría es intencional:

- disponible inicial -> `OPENING_BALANCE` para trazabilidad del saldo utilizable;
- ahorro previo -> `FinancialProduct.openingBalance` para evitar fingir un aporte de ahorro en el período actual.

## 8. Independencia entre disponible y ahorro inicial

Ejemplo:

```text
Disponible inicial       $2.000.000
Fondo de emergencia      $3.000.000
```

Resultado:

```text
Disponible               $2.000.000
Ahorrado                  $3.000.000
Ingreso base                     $0
Ahorro 20% período               $0
```

No debe interpretarse como `$5.000.000` disponibles menos un aporte de `$3.000.000`.

## 9. Resumen previo a confirmar

Antes de finalizar mostrar:

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

Desde este paso se puede volver y corregir saldo/productos antes de confirmar.

## 10. Persistencia atómica

Los pasos intermedios mantienen un borrador en estado de UI. La configuración definitiva se persiste únicamente al pulsar `Comenzar a usar Mis Gastos`.

La operación final debe ser atómica:

1. crear categorías seed si todavía no existen;
2. crear `OPENING_BALANCE` si el saldo disponible inicial es mayor que cero;
3. crear productos financieros iniciales;
4. marcar `onboardingCompleted = true`.

Si falla cualquier parte, no debe quedar una inicialización parcial marcada como completada.

## 11. AppSetup

Debe existir una fuente explícita para saber si el onboarding terminó.

Modelo conceptual:

```text
AppSetup
- onboardingCompleted: Boolean
```

No inferir onboarding a partir de cantidad de transacciones, categorías o productos.

Incorrecto:

```text
transactions.count == 0 -> onboarding pendiente
```

Un usuario puede completar onboarding legítimamente con todos los valores en cero.

El diseño físico definitivo de `AppSetup` se decide en la especificación Room/SQLite.

## 12. Cierre de app durante onboarding

En el MVP no es obligatorio persistir el borrador de los pasos intermedios.

Si la app se cierra antes de confirmar:

```text
onboardingCompleted = false
```

Al volver a abrir, se inicia nuevamente el onboarding.

No deben existir categorías/productos/transacciones parcialmente creados por navegar entre pasos.

## 13. Semilla de categorías

La creación de categorías seed debe ser idempotente.

Conceptualmente:

```text
seedCategoriesIfNeeded()
```

Ejecutar la inicialización más de una vez nunca puede duplicar categorías.

Las categorías exactas y sus defaults están definidas en `12-configuration.md`.

## 14. Onboarding de una sola ejecución

Una vez:

```text
onboardingCompleted = true
```

el flujo no vuelve a mostrarse en el inicio normal de la aplicación.

Cambios posteriores se realizan desde `Configuración` o los flujos normales de registro.

No existe `Reiniciar onboarding` en el MVP.

## 15. Escenarios iniciales válidos

### Todo en cero

```text
Disponible       $0
Productos        ninguno
```

Resultado:

```text
Disponible       $0
Ingreso base     sin base de cálculo
50 / 30 / 20     —
```

La persona puede comenzar a usar `+ Registrar` normalmente.

### Sólo ahorro existente

```text
Disponible              $0
Fondo de emergencia     $5.000.000
```

Resultado:

```text
Disponible              $0
Ahorrado                 $5.000.000
Ingreso base             $0
```

Posteriormente puede retirar mediante el flujo normal.

### Sólo disponible

```text
Disponible              $2.000.000
Productos               ninguno
```

No es obligatorio crear un producto hasta que quiera ahorrar.

## 16. Corrección del saldo disponible inicial

El `OPENING_BALANCE` inicial sólo puede corregirse mientras no exista ninguna otra transacción financiera posterior vinculada al uso normal de la app.

Regla conservadora del MVP:

```text
sólo OPENING_BALANCE activo / sin movimientos posteriores
→ monto inicial editable

existe cualquier otro movimiento financiero posterior
→ monto inicial bloqueado
```

La corrección no transforma el saldo inicial en ingreso base.

Si el onboarding se completó con `$0` y ya existen movimientos posteriores, no se permite crear retrospectivamente un `OPENING_BALANCE` desde Configuración como corrección silenciosa.

## 17. Corrección de openingBalance de productos

Sigue `12-configuration.md`:

- puede editarse mientras el producto no tenga histórico financiero relacionado;
- queda bloqueado después del primer movimiento relacionado.

## 18. Navegación y back stack

Mientras `onboardingCompleted == false`, la aplicación inicia en Onboarding.

Al confirmar exitosamente:

- navegar al Dashboard;
- remover Onboarding del back stack principal;
- Atrás no debe regresar al flujo inicial.

## 19. UX y accesibilidad

- usar el mismo Design System global de la app;
- campo monetario prominente y teclado adecuado;
- progreso discreto entre pasos;
- botón Atrás en pasos intermedios;
- mensajes cortos y explícitos;
- no depender únicamente del color;
- no crear un tema visual exclusivo para onboarding.

## 20. Fuera del onboarding MVP

No solicitar:

- ingreso mensual estimado;
- salario;
- gastos históricos;
- préstamos históricos;
- personas;
- metas de ahorro;
- personalización de categorías;
- porcentajes distintos de 50/30/20;
- banco/cuenta bancaria;
- email/login;
- backup;
- notificaciones;
- preferencias visuales.

## 21. Decisiones congeladas

- Onboarding se completa una sola vez.
- Puede completarse con todos los montos en `$0`.
- Saldo disponible inicial mayor que cero se representa con `OPENING_BALANCE`.
- Un saldo disponible inicial de cero no crea una transacción de monto cero.
- Saldo inicial de un producto se representa con `FinancialProduct.openingBalance`.
- Ninguno de los saldos iniciales aumenta ingreso base.
- `FinancialProduct.openingBalance` tampoco cuenta como ahorro 20% del período.
- Los productos financieros son opcionales.
- Las categorías seed se crean automática e idempotentemente al confirmar.
- No se registran movimientos históricos durante onboarding.
- La confirmación del onboarding es atómica.
- El estado de finalización es explícito mediante `AppSetup` o equivalente; no se infiere de datos financieros.
- No es obligatorio persistir el borrador antes de confirmar.
- El saldo disponible inicial sólo puede corregirse antes de existir movimientos financieros posteriores.
- No existe reinicio de onboarding en el MVP.
