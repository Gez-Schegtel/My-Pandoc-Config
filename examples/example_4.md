---
title: "Prueba completa del estilo"
subtitle: "Recorrido por estilo.yaml, metadatos.yaml, estilo.tex (0 a 9) y los tres filtros"
author: "Juani"
date: "Noviembre de 2026"
toc: true
toc-depth: 3
numbersections: true
ancho-imagenes: 60%
header-includes: \newcommand{\marcaPrueba}{\textbf{[header-includes de la nota activo]}}
---

# Qué prueba este documento

Este ejemplo ejercita todas las piezas de la configuración en un solo archivo. Se compila así:

```bash
pandoc -d estilo example_4.md -o example_4.pdf
```

- **Filtro `preambulo.lua`:** junta `estilo.tex` con el `header-includes` de esta nota sin que se pisen $\rightarrow$ \marcaPrueba.
- **Opción `markdown+hard_line_breaks` (`estilo.yaml`):**
  Esta línea termina con un solo Enter (sin línea en blanco abajo)
  y esta otra sale en el renglón de abajo en vez de pegarse a la anterior.

# Sección 0: Fuentes, emojis, símbolos y respaldo en código

En el texto normal (Latin Modern Roman por defecto):

- **Emojis a color (`Noto Color Emoji`):** ✅ listo, ⚠️ atención, 📌 nota, 📄 archivo, 📘 libro, 🚀 rápido.
- **Símbolos y letras griegas (`DejaVu Sans`):** ✓ tilde, → derecha, ← izquierda, ↔ ambos lados, ↕ vertical, α β γ δ, ≠ ≤ ≥.
- **Código en línea con símbolos y emojis:** árbol `├──`, flecha técnica `↕` (en blanco y negro, no emoji) y botón `[📄 PDF]`.

En un bloque de código (`Latin Modern Mono` con respaldo `monoletras`: primero `DejaVu Sans Mono` para los trazos de árboles y flechas con ancho fijo, y segundo `Noto Color Emoji` para los emojis puros):

```text
pandoc/
├── defaults/
│   ├── estilo.yaml      ──► opciones de pandoc   ✓
│   ├── metadatos.yaml   ↕   valores de base      ✓
│   └── estilo.tex       ──► aspecto en LaTeX     📘
└── filters/
    ├── preambulo.lua
    ├── cortar-formulas.lua
    └── centrar-imagenes.lua                      ✅
```

# Sección 1 y `metadatos.yaml`: Listas y títulos de nivel 4 y 5

Lista con viñetas apretada (con `0.55em` de aire entre ítems gracias a `\tightlist`):

- Primer ítem de la lista.
- Segundo ítem con dos niveles:
  - Subítem A.
  - Subítem B.
- Tercer ítem.

#### Título de nivel 4 (`####`)

Con `block-headings: true` en `metadatos.yaml`, este párrafo sale debajo del título de nivel 4 (y no pegado en la misma línea).

##### Título de nivel 5 (`#####`)

Lo mismo ocurre con los títulos de nivel 5.

# Sección 2 y 5: Tablas con más aire y corte de palabras largas

Las filas tienen más altura (`\arraystretch = 1.5`), y las palabras de 20 caracteres o más sin espacios se cortan solas para no salirse de la hoja:

| Caso | Ejemplo dentro de una tabla |
|:--|:--|
| Enlace con color (`NavyBlue`) | [Sitio de Pandoc](https://pandoc.org) |
| URL larga sin espacios | https://www.ejemplo.com/ruta/extremadamente/larga/sin/espacios/para/probar/el/corte/automatico/de/lualatex/index.html |
| Hash SHA-256 continuo | e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855e3b0c44298fc1c149afbf4c8996fb924 |

También en un párrafo común: la ruta `/usr/local/share/carpeta_con_un_nombre_larguisimo_sin_espacios_intermedios/configuracion/archivo_de_prueba.tex` se corta antes de salirse del margen derecho.

# Sección 3: Cuadros para las citas (`>`)

> **💡 Idea clave:** todo bloque que empieza con `>` se dibuja como un cuadro celeste con barra azul a la izquierda.
>
> También puede tener más de un párrafo o incluir `código en línea` y fórmulas como $E = m \cdot c^2$.

> **⚠️ Ojo:** el alto de la barra azul se ajusta solo a la altura total del cuadro.

# Sección 4: Bloques de código con líneas largas (`fvextra`)

Bloque sin lenguaje (`verbatim`):

```
Esta es una línea de texto plano sin lenguaje que es mucho más ancha que la hoja para comprobar que fvextra la corta sola y agrega la flechita de continuación en el renglón siguiente.
```

Bloque con resaltado de sintaxis (`python`) y un texto largo sin espacios adentro (`breaknonspaceingroup`):

```python
def comprobar_corte():
    token = " cadena_muy_larga_con_colores_de_sintaxis_que_tambien_se_corta_aunque_no_tenga_espacios_9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
    return f"Resultado: {token}"
```

# Sección 6: `\needspace`

\needspace{4cm}

Si quedaran menos de 4 cm libres al pie de la página, `\needspace{4cm}` salta a la siguiente antes de empezar este bloque.

# Secciones 7, 8 y 9 + `centrar-imagenes.lua`: Imágenes y figuras

1. **Imagen suelta sin epígrafe** (`![](./logo_utn.png){width=18%}`): el filtro `centrar-imagenes.lua` la centra automáticamente.

![](./logo_utn.png){width=18%}

2. **Imagen alineada a la izquierda** (`{.izquierda width=15%}`):

![](./logo_utn.png){.izquierda width=15%}

3. **Imagen alineada a la derecha** (`{.derecha width=15%}`):

![](./logo_utn.png){.derecha width=15%}

4. **Figura con epígrafe** (`![Texto](./logo_utn.png){width=18%}`): queda fija donde está en el Markdown (`floatplacement{figure}{H}`, sección 8) y el epígrafe sale limpio, sin el prefijo `"Figura 1:"` (sección 9).

![Epígrafe de prueba: figura fija en su lugar y sin "Figura 1:" adelante.](./logo_utn.png){width=18%}

# Filtro `cortar-formulas.lua`: Fórmulas en bloque

1. **Fórmula corta (entra en la hoja, no se toca):**

$$
G(s) = \frac{K}{\tau s + 1}
$$

2. **Fracción ancha (el filtro parte numerador y denominador en filas):**

$$
T(s) = \frac{b_0 s^7 + b_1 s^6 + b_2 s^5 + b_3 s^4 + b_4 s^3 + b_5 s^2 + b_6 s + b_7 + K_p (s^4 + 3 s^3 + 5 s^2 + 7 s + 9)}{a_0 s^8 + a_1 s^7 + a_2 s^6 + a_3 s^5 + a_4 s^4 + a_5 s^3 + a_6 s^2 + a_7 s + a_8 + K_d (s^5 + 2 s^4 + 4 s^3 + 6 s^2 + 8 s + 10)}
$$

3. **Ecuación larga sin fracción (se corta a la derecha del signo `=`):**

$$
\Delta C_{total} = C_{prevencion} + C_{evaluacion} + C_{fallas\_internas} + C_{fallas\_externas} + C_{reproceso} + C_{garantia} + C_{soporte\_correctivo} + C_{penalidades}
$$

4. **Fracción repetida (`a = F = F`, el filtro deja una sola):**

$$
R(s) = \frac{s^6 + 2 s^5 + 3 s^4 + 4 s^3 + 5 s^2 + 6 s + 7}{s^7 + 8 s^6 + 9 s^5 + 10 s^4 + 11 s^3 + 12 s^2 + 13 s + 14} = \frac{s^6 + 2 s^5 + 3 s^4 + 4 s^3 + 5 s^2 + 6 s + 7}{s^7 + 8 s^6 + 9 s^5 + 10 s^4 + 11 s^3 + 12 s^2 + 13 s + 14}
$$
