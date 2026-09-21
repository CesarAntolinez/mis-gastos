# 05 — Roadmap

## Principio

El roadmap está diseñado como slices verticales cerrados. No avanzar al siguiente slice con funcionalidades requeridas del actual incompletas.

Cada slice debe terminar con código ejecutable, pruebas correspondientes y UX funcional.

## Slice 0 — Bootstrap técnico

Objetivo: tener una app Android que compile y una base arquitectónica mínima.

Entregables:

- Proyecto Android en `app/`.
- Kotlin + Compose + Material 3.
- Navigation Compose configurado.
- Tema centralizado con tokens base.
- Estructura de paquetes definida en arquitectura.
- `AppContainer` inicial.
- Pantalla placeholder de Resumen y de Historial navegables.
- Tests configurados.

Definition of Done:

- Build debug exitoso.
- Tests ejecutables.
- Navegación entre Resumen e Historial funcional.
- Ningún botón principal conduce a un dead-end no documentado.

## Slice 1 — Dominio y persistencia de transacciones

Objetivo: poder persistir correctamente el agregado Transaction sin UI final.

Entregables:

- Modelos de dominio.
- Catálogo estático de categorías.
- Validaciones.
- Room entity, DAO, database y converters.
- Repository.
- CRUD cubierto por tests.
- Queries por rango.

Definition of Done:

- CRUD probado.
- Invariantes de ingreso/egreso probadas.
- Categoría incompatible con bucket es rechazada.
- Dinero no usa Float/Double.

## Slice 2 — Registrar ingreso

Objetivo: primer flujo completo de escritura desde UI hasta DB.

Entregables:

- Formulario de transacción.
- Modo Ingreso funcional.
- Monto, fecha y concepto.
- Validación inline.
- Guardar y volver a pantalla anterior.
- El ingreso persiste al reiniciar app.

Definition of Done:

- Se puede crear un ingreso válido.
- No se muestran bloque/categoría en modo ingreso.
- Error de monto/fecha se muestra en el formulario.
- UI test del flujo principal.

## Slice 3 — Registrar egreso 50/30/20

Objetivo: completar la captura de transacciones.

Entregables:

- Modo Egreso.
- Selector de bloque Necesidades/Deseos/Ahorro.
- Categorías filtradas por bloque.
- Limpieza de categoría al cambiar a bloque incompatible.
- Guardado de egreso.

Definition of Done:

- Los tres bloques pueden registrarse.
- Sólo aparecen categorías válidas para el bloque.
- Cambio Egreso -> Ingreso limpia datos exclusivos de egreso.
- UI test del flujo principal.

## Slice 4 — Historial mensual

Objetivo: consultar lo registrado con mes como período por defecto.

Entregables:

- Lista de transacciones.
- Mes actual por defecto.
- Navegación mes anterior/siguiente.
- Orden descendente por fecha.
- Estado vacío.
- Formato COP.

Definition of Done:

- Sólo aparecen transacciones del mes seleccionado.
- Ingreso/egreso se distinguen sin depender sólo de color.
- Estado vacío conduce a registrar transacción.

## Slice 5 — Edición y eliminación

Objetivo: cerrar CRUD visible antes de construir analítica.

Entregables:

- Abrir transacción desde historial.
- Formulario precargado.
- Actualizar.
- Confirmar y eliminar.

Definition of Done:

- Edición conserva invariantes.
- Eliminación requiere confirmación.
- Lista se actualiza automáticamente tras cambios.
- Tests de update/delete.

## Slice 6 — Dashboard mensual 50/30/20

Objetivo: entregar el valor central del producto para el período mensual.

Entregables:

- Total ingresos.
- Total egresos.
- Balance.
- Totales Necesidades/Deseos/Ahorro.
- Porcentajes sobre ingreso.
- Meta y delta de cada bloque.
- Estado sin ingresos.
- Estado sin transacciones.

Definition of Done:

- Cálculos cubiertos por unit tests.
- Agregados Room cubiertos por tests.
- Cambiar datos refresca dashboard sin recarga manual.
- No aparece `0%` engañoso cuando el ingreso es cero.

## Slice 7 — Semana y año

Objetivo: generalizar períodos sólo después de validar la experiencia mensual.

Entregables:

- Selector Semana/Mes/Año.
- Navegación anterior/siguiente para cada granularidad.
- Resumen e historial usan el mismo período seleccionado dentro de su flujo de estado definido.
- Rango semanal lunes-domingo.

Definition of Done:

- Tests de límites de semana, mes y año.
- Cambiar granularidad produce datos correctos.
- Cruces de año/mes funcionan.

## Slice 8 — Pulido UX/UI y release MVP

Objetivo: cerrar producto sin añadir alcance funcional.

Entregables:

- Revisión de componentes y tokens.
- Contraste y accesibilidad básica.
- Estados vacíos finales.
- Iconografía consistente.
- Revisión de textos.
- Pruebas del flujo crítico completo.
- README de ejecución y arquitectura actualizado.

Definition of Done:

- No hay colores/tamaños arbitrarios relevantes fuera del sistema visual.
- No hay TODOs de alcance MVP.
- Todos los criterios de aceptación están satisfechos.
- APK debug/release de prueba compila según configuración del proyecto.

## Fuera del roadmap MVP

No introducir durante estos slices:

- autenticación;
- backend;
- sync;
- categorías editables;
- presupuestos configurables distintos de 50/30/20;
- cuentas bancarias;
- exportación;
- notificaciones;
- widgets;
- moneda múltiple.

Cualquier propuesta de estos puntos debe registrarse como `post-MVP`, no implementarse dentro de un slice actual.
