# Design System — Mis Gastos

**Status:** accepted  
**Version:** 1.0  
**Direction:** Finanzas sin rigidez

Este documento define la identidad visual y de interacción de Mis Gastos. Complementa `.agents/skills/mobile-design/SKILL.md`: la skill establece cómo diseñar buenas experiencias móviles; este documento establece cómo debe sentirse y verse específicamente Mis Gastos.

## 1. Personalidad

Mis Gastos debe sentirse:

- **fresca y juvenil**, sin resultar infantil;
- **cercana**, evitando la frialdad típica de interfaces bancarias;
- **clara y confiable**, especialmente al mostrar dinero;
- **modernamente expresiva**, con movimiento y color intencionales;
- **ligera**, sin sacrificar información financiera importante.

La idea rectora es **“finanzas sin rigidez”**: administrar dinero debe sentirse comprensible y cotidiano, no como operar un sistema contable.

## 2. Principios visuales

### Claridad primero

El dato financiero principal debe dominar la jerarquía. Una pantalla no debe convertir métricas secundarias en competidores del saldo, monto o acción principal.

### Vida con intención

Color, formas y movimiento pueden aportar personalidad, pero deben responder al significado o a una acción del usuario. Evitar decoración arbitraria.

### Profundidad progresiva

Mostrar primero lo necesario para decidir o actuar. Los detalles, relaciones y explicaciones deben aparecer al profundizar en la interfaz.

### Semántica antes que estética

Ingreso, gasto, reintegro, deuda y movimiento interno son conceptos distintos. Nunca fusionarlos o renombrarlos únicamente para simplificar visualmente una pantalla.

### Familiar, no genérica

Usar patrones móviles reconocibles, pero evitar que la app parezca un dashboard SaaS reducido a un teléfono o una plantilla bancaria genérica.

## 3. Color

### Identidad

El color de marca parte de un azul pastel entre sky blue y periwinkle.

Tokens iniciales:

| Token | Claro | Oscuro | Uso |
| --- | --- | --- | --- |
| `brand.primary` | `#82B6FF` | `#91BEFF` | acciones, selección, identidad |
| `brand.strong` | `#356FC4` | `#75A9F5` | contraste, énfasis, estados activos |
| `brand.soft` | `#E8F2FF` | `#172B47` | fondos destacados, chips, superficies suaves |
| `background` | `#F7F9FC` | `#0E1420` | fondo principal |
| `surface` | `#FFFFFF` | `#171F2D` | tarjetas y superficies |
| `surface.subtle` | `#EFF3F8` | `#202A3A` | agrupación secundaria |
| `text.primary` | `#172033` | `#F4F7FC` | texto principal |
| `text.secondary` | `#667085` | `#AAB5C5` | texto secundario |
| `border` | `#E3E8F0` | `#2B3648` | divisores y bordes discretos |

Estos valores son la base del sistema y pueden ajustarse durante implementación por contraste o comportamiento real en dispositivo, manteniendo la dirección aprobada.

### Color semántico

No usar `brand.primary` para representar significado financiero.

Definir familias diferenciadas para:

- ingreso/positivo;
- gasto/salida;
- ahorro;
- deuda/por cobrar;
- advertencia;
- error;
- información.

El color nunca será el único indicador. Combinarlo con texto, signo, icono, posición o etiqueta.

Rojo y verde deben reservarse para significado, no para decoración general.

## 4. Tema claro y oscuro

Ambos temas son parte del sistema desde el inicio.

### Claro

Usar un fondo casi blanco ligeramente frío, superficies claras y azul pastel como acento. Evitar grandes áreas de azul saturado que hagan pesada la interfaz.

### Oscuro

No usar negro absoluto como fondo principal. Construir profundidad con azul-negro y grises fríos. Las superficies deben distinguirse por luminancia y bordes sutiles, no por sombras intensas.

No crear dark mode mediante inversión automática. Cada token semántico debe tener una variante apropiada.

## 5. Tipografía

Usar una sans-serif contemporánea, altamente legible y compatible con las plataformas objetivo. Priorizar tipografía nativa o una familia de bajo costo de carga antes que una fuente decorativa.

La escala inicial debe distinguir:

- **display financiero:** saldo o monto protagonista;
- **title:** títulos de pantalla y secciones importantes;
- **body:** contenido principal;
- **label:** acciones, filtros y controles;
- **caption:** metadatos y contexto secundario.

Los números financieros deben usar cifras claramente distinguibles y, cuando la tecnología lo permita, cifras tabulares en listas o columnas donde la alineación ayude a comparar.

No reducir excesivamente montos largos para obligarlos a caber. Adaptar layout antes que sacrificar legibilidad.

## 6. Espaciado y layout

Usar una escala basada en múltiplos de 4 con ritmo principal de 8.

Escala recomendada: `4, 8, 12, 16, 24, 32, 40, 48`.

Reglas:

- `16` como padding móvil común;
- `24–32` para separar bloques conceptuales;
- espacio generoso alrededor del dato financiero protagonista;
- evitar cuadrículas densas con demasiadas tarjetas pequeñas;
- respetar safe areas y barras del sistema;
- diseñar para pantallas pequeñas antes de aprovechar tamaños grandes.

## 7. Forma y superficies

La geometría debe sentirse suave y contemporánea.

Radios iniciales:

- controles pequeños: `10–12`;
- inputs y botones: `14–16`;
- tarjetas: `18–24`;
- superficies expresivas/hero: hasta `28` cuando la composición lo justifique.

No redondear absolutamente todo. La jerarquía debe provenir también de espacio, tipografía y agrupación.

Preferir bordes sutiles y contraste entre superficies. Usar sombras con moderación y principalmente cuando comuniquen elevación real.

## 8. Iconografía

Usar una sola familia de iconos coherente, moderna y de trazos limpios.

- mantener pesos ópticos consistentes;
- acompañar iconos ambiguos con texto;
- usar iconos de categoría para acelerar reconocimiento;
- no utilizar emoji como iconografía principal del producto;
- permitir ilustración ligera o formas abstractas en onboarding y empty states.

## 9. Componentes base

El sistema debe evolucionar hacia componentes reutilizables, no pantallas construidas con estilos aislados.

Priorizar:

- buttons: primary, secondary, ghost y destructive;
- amount/money display;
- transaction row;
- financial summary card;
- category indicator;
- chips y filtros;
- text field y amount input;
- bottom sheet;
- confirmation surface;
- empty/error/loading states;
- bottom navigation;
- charts y leyendas cuando aporten una decisión real.

Los componentes deben compartir tokens de spacing, radius, color y typography.

## 10. Home y densidad

La Home seguirá una jerarquía progresiva aproximada:

1. contexto/saludo discreto;
2. disponible como dato protagonista;
3. acciones frecuentes;
4. resumen del período;
5. visualización útil del mes;
6. movimientos recientes;
7. navegación principal.

Evitar presentar toda la contabilidad en Home. El usuario debe poder profundizar hacia historial y detalle.

## 11. Visualización financiera

- Formatear moneda de forma consistente con locale.
- Distinguir entradas y salidas mediante signo y lenguaje, además del color.
- No usar gráficos si una cifra o comparación textual comunica mejor la información.
- Evitar gráficos decorativos sin escala, contexto o significado.
- Mantener consistencia entre el color/indicador de una categoría en gráficos, historial y detalle.
- Un movimiento interno debe verse distinto de un ingreso incluso cuando ambos aumenten el disponible de una ubicación.

## 12. Motion

La personalidad es **modernamente expresiva**.

Usar motion para:

- confirmar acciones;
- conectar origen y destino durante navegación;
- actualizar saldos y montos de forma comprensible;
- introducir contenido o gráficos progresivamente;
- comunicar éxito, cambio de estado o finalización.

Ejemplos apropiados incluyen interpolación breve de un saldo después de registrar un movimiento, transición de una deuda a pagada o expansión de una transacción hacia su detalle.

Evitar animación continua, rebotes excesivos y movimiento puramente ornamental en pantallas de alta frecuencia.

Como punto de partida, mantener microinteracciones aproximadamente entre `150–300 ms` y transiciones de navegación alrededor de `250–400 ms`, ajustando según plataforma y contexto.

Respetar siempre la preferencia del sistema de reducción de movimiento.

## 13. Feedback y estados

Toda operación relevante debe comunicar su estado.

Diseñar explícitamente:

- loading;
- empty;
- error;
- success;
- disabled;
- offline cuando aplique;
- datos parciales cuando aplique.

Los empty states son una oportunidad para usar más personalidad mediante copy cercano, ilustración ligera o formas abstractas, siempre acompañados por una acción clara cuando exista un siguiente paso.

## 14. Interacción móvil

- Mantener objetivos táctiles cómodos, idealmente alrededor de `44–48` puntos/píxeles lógicos como mínimo según plataforma.
- Colocar acciones frecuentes importantes dentro de zonas alcanzables con el pulgar cuando sea posible.
- No esconder acciones esenciales únicamente en gestos.
- Considerar teclado, foco, scroll y retorno al contexto anterior.
- Usar bottom sheets para decisiones breves/contextuales; usar pantallas completas cuando el flujo necesite espacio, revisión o múltiples pasos.
- Proteger al usuario frente a acciones destructivas o difíciles de revertir.

## 15. Accesibilidad

La apariencia juvenil no reduce los requisitos de accesibilidad.

- Mantener contraste suficiente para texto y controles.
- No depender únicamente del color.
- Soportar escalado de texto sin romper jerarquía o navegación.
- Proporcionar labels accesibles a iconos y controles.
- Respetar reduced motion.
- Evitar textos secundarios excesivamente tenues, especialmente en dark mode.
- Verificar estados de foco cuando la plataforma los utilice.

## 16. Copy de interfaz

Usar lenguaje cercano, directo y breve.

Preferir:

- “Agregar gasto” sobre terminología contable innecesaria;
- “Te deben” cuando el contexto permita una expresión humana clara;
- explicaciones cortas cuando una clasificación financiera pueda sorprender al usuario.

No sacrificar precisión financiera por sonar casual.

## 17. Anti-patrones

Evitar:

- estética de dashboard web comprimido;
- exceso de tarjetas dentro de tarjetas;
- gradientes en cada superficie;
- glassmorphism que reduzca legibilidad;
- sombras profundas como recurso decorativo;
- azul para absolutamente todos los estados;
- interfaces monocromáticas que oculten categorías importantes;
- animaciones en cada interacción;
- navegación basada únicamente en iconos ambiguos;
- gráficos decorativos;
- modificar la semántica financiera para hacer una pantalla más simple.

## 18. Evolución del sistema

Este documento define una base, no una biblioteca cerrada.

Cuando aparezca una necesidad visual nueva:

1. comprobar si puede resolverse con un patrón existente;
2. evitar crear variantes locales sin razón;
3. si introduce un patrón reutilizable, incorporarlo al sistema;
4. si modifica una decisión relevante de identidad o UX, documentar la decisión conforme a `AGENT.md`;
5. validar siempre contra `docs/product/domain-rules.md`.

Las implementaciones pueden refinar valores concretos de tokens cuando exista evidencia de accesibilidad, plataforma o dispositivo, pero no deben cambiar silenciosamente la dirección visual aprobada.
