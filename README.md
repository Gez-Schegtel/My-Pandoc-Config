# Pandoc config

Mi configuración de [pandoc](https://pandoc.org) para convertir apuntes en Markdown a PDF con un estilo propio y siempre el mismo. Se guarda y se usa en un solo lugar, así cada nota solo necesita su título, autor y fecha.

```bash
pandoc -d estilo nota.md -o nota.pdf
```

## Qué consigue

- **Una sola configuración para todas las notas.** Cada `.md` lleva únicamente su cabecera (`title`, `subtitle`, `author`, `date`). El aspecto vive acá.
- **Emojis a color** y símbolos (✅ ⚠️ α →), con la letra Latin Modern Roman o con la que pida cada nota.
- **Cuadros** celestes con barra azul para las citas (`>`): ideales para "Idea clave", "Ojo", "Para el examen".
- **Listas y tablas con más aire** que el pandoc por defecto.
- **Código que no se sale de la hoja:** las líneas largas se cortan y la continuación empieza con una flechita (↪).
- **URLs, hashes y rutas largas** en tablas o párrafos también se cortan en vez de salirse de la hoja.
- **Fórmulas largas que no se salen de la hoja:** las que no entran se parten solas en filas.
- **Una nota puede cambiar los valores del documento** (márgenes, letra, interlineado...) desde su propia cabecera, sin tocar la configuración.

## Contenido del repositorio

```
pandoc/                      (esta carpeta es ~/.local/share/pandoc)
├── defaults/
│   ├── estilo.yaml          opciones de pandoc; es el único que se nombra al compilar
│   ├── metadatos.yaml       valores por defecto que una nota puede cambiar: idioma, márgenes, letra...
│   └── estilo.tex           aspecto en LaTeX: fuentes, emojis, listas, tablas, cuadros, código
├── filters/
│   ├── preambulo.lua        filtro de pandoc: carga estilo.tex, respeta el header-includes y la letra de la nota
│   ├── cortar-formulas.lua  filtro de pandoc: parte en filas las fórmulas que no entran en la hoja
│   └── centrar-imagenes.lua filtro de pandoc: centra las imágenes sueltas (o las alinea a un costado)
├── examples/
│   ├── example_1.md / .pdf  ejemplo básico: todo lo que cubre el estilo
│   ├── example_2.md / .pdf  tablas y casos que pueden salirse de la hoja
│   └── example_3.md / .pdf  apunte real y largo (más de 90 páginas): índice, fórmulas, saltos de página
└── README.md
```

La carpeta `defaults/` tiene que llamarse así: es el nombre que pandoc busca. Los tres archivos de adentro tienen que estar juntos, porque `estilo.yaml` encuentra a los otros dos por su ubicación. `filters/` tiene que estar al lado de `defaults/`: `estilo.yaml` busca los filtros en `../filters/`, y `preambulo.lua` busca `estilo.tex` en `../defaults/`.

## Instalación

### 1. Instalar las dependencias (Debian/Ubuntu)

```bash
sudo apt install pandoc texlive-luatex texlive-latex-recommended \
     texlive-latex-extra texlive-fonts-recommended lmodern \
     fonts-noto-color-emoji
```

| Paquete | Para qué |
|:--|:--|
| `pandoc` | El conversor. |
| `texlive-luatex` | El motor `lualatex` que genera el PDF. Hace falta para los emojis y el corte de palabras largas. |
| `texlive-latex-recommended`, `texlive-fonts-recommended`, `lmodern` | Tablas, bloques de código y la letra base. Sin ellos pandoc no genera el PDF. |
| `texlive-latex-extra` | Trae `fvextra`, que corta las líneas largas de código. |
| `fonts-noto-color-emoji` | Los emojis a color. |

### 2. Poner el repositorio en la carpeta de datos de pandoc

Pandoc busca sus archivos de configuración en su "carpeta de datos". En Linux es `~/.local/share/pandoc` (sigue el estándar XDG, como muchos programas). No es una recomendación de pandoc sino el lugar donde busca por defecto: estando ahí, `-d estilo` alcanza, sin escribir la ruta. Si el repositorio estuviera en otro lado, habría que compilar con `pandoc -d /ruta/a/defaults/estilo.yaml ...`. Este repositorio **es** esa carpeta:

```bash
git clone https://github.com/Gez-Schegtel/My-Pandoc-Config.git ~/.local/share/pandoc
```

Para comprobar que pandoc usa esa carpeta:

```bash
pandoc --version | grep -i "user data"
```

Tiene que mostrar `/home/<usuario>/.local/share/pandoc`. Si muestra otra:

- `~/.pandoc` (la carpeta vieja): pandoc la usa solo cuando `~/.local/share/pandoc` no existe, así que el repositorio no quedó en su lugar.
- Otra ruta terminada en `/pandoc`: la variable `XDG_DATA_HOME` está definida y pandoc busca en `$XDG_DATA_HOME/pandoc`. Hay que poner el repositorio ahí o quitar esa variable.

### 3. Probar

```bash
cd ~/.local/share/pandoc/examples
pandoc -d estilo example_1.md -o /tmp/prueba.pdf
```

Si se genera el PDF, está todo bien.

## Uso

### Compilar una nota

```bash
pandoc -d estilo nota.md -o nota.pdf
```

`-d estilo` (la sigla es de *defaults*) le dice a pandoc que lea `~/.local/share/pandoc/defaults/estilo.yaml`. Se puede ejecutar desde cualquier carpeta.

Cada nota empieza con su cabecera:

```yaml
---
title: "Título de la nota"
subtitle: "Subtítulo opcional"
author: "Nombre"
date: "8 de octubre de 2026"
---
```

### Cambiar algo en una sola nota

Hay dos formas, y las dos ganan sobre los valores de `metadatos.yaml`:

```yaml
---
title: "Mi nota"
geometry: margin=4cm      # márgenes distintos solo para esta nota
fontsize: 12pt
toc: true                 # índice al principio
numbersections: true      # títulos numerados
mainfont: Libertinus Serif   # otra letra (los emojis se mantienen)
ancho-imagenes: 60%       # ninguna imagen más ancha que el 60 % del texto
header-includes: \usepackage{float}   # LaTeX extra para el preámbulo
---
```

O desde la terminal:

```bash
pandoc -d estilo -M date="$(date +%d/%m/%Y)" nota.md -o nota.pdf
```

Lo que la nota **no** puede cambiar desde su cabecera son las opciones de `estilo.yaml` (`pdf-engine`, `highlight-style`, `filters`): ver [Opciones y metadatos](#opciones-y-metadatos).

Sobre la letra: sin `mainfont` se usa Latin Modern Roman. El nombre tiene que ser exactamente el que muestra `fc-list | grep -i "nombre"`, y la letra tiene que estar instalada. Si la letra trae sus propios dibujos de algunos emojis o símbolos (DejaVu Sans, por ejemplo), usa esos, en blanco y negro; los que no tenga salen a color.

### Imágenes

Una imagen sola en su párrafo sale **centrada** (lo hace el filtro `centrar-imagenes.lua`). Si está dentro de una línea de texto, queda en su lugar dentro del texto.

Con texto entre los corchetes, la imagen pasa a ser una **figura con epígrafe** ("Figura 1: ..."):

```markdown
![](foto.png)                    centrada, sin epígrafe
![Esquema del sistema](foto.png) centrada, con "Figura 1: Esquema del sistema"
```

Para dejar una imagen a la izquierda o a la derecha, se le agrega la clase al lado (se puede combinar con el tamaño):

```markdown
![](foto.png){.izquierda}
![](foto.png){.derecha width=40%}
```

Eso vale para las imágenes sin epígrafe; las figuras con epígrafe siempre salen centradas.

Las figuras con epígrafe las ubica LaTeX: si no entran en lo que queda de la página, pueden pasar a la siguiente y el texto de abajo sube a ocupar el hueco. Las que no tienen epígrafe quedan siempre donde están en el Markdown.

**Tamaño.** Ninguna imagen pasa de `ancho-imagenes` (por defecto, el 80 % del ancho del texto, en `metadatos.yaml`). Las más anchas se achican; las más chicas quedan como están. Una nota puede poner su propio valor en la cabecera.

Para una imagen puntual, se le pone el tamaño al lado, y ese tamaño gana sobre el tope:

```markdown
![](foto.png){width=40%}        40 % del ancho del texto
![](foto.png){width=8cm}        también acepta cm, mm o in
```

### Escribir los cuadros

Todo bloque de cita de Markdown se dibuja como un cuadro celeste con barra azul:

```markdown
> **Idea clave.** Lo esencial del tema.

> **Ojo.** Una trampa o confusión frecuente.
```

Esto vale para **todas** las citas: no se puede tener a la vez una cita común y un cuadro.

### Salto de página y títulos al pie

Se puede escribir LaTeX suelto en el Markdown:

```markdown
\newpage          salta a la página siguiente

\needspace{5cm}   si quedan menos de 5 cm en la página, salta a la siguiente
# Título           (evita un título solo al final de la página)
```

## Cómo funciona

El PDF se genera en dos pasos:

```
nota.md  ──(pandoc)──►  nota.tex  ──(lualatex)──►  nota.pdf
```

Pandoc convierte el Markdown a LaTeX, y `lualatex` convierte ese LaTeX en PDF. Esta configuración se mete en el primero.

Para ver el LaTeX intermedio:

```bash
pandoc -d estilo nota.md -s -t latex -o nota.tex
```

### Por qué está dividida en varios archivos

| Archivo | Qué contiene | Por qué va aparte |
|:--|:--|:--|
| `estilo.yaml` | Opciones de pandoc: motor, estilo del código, `metadatos.yaml` y los filtros. | Es el que se nombra al compilar. |
| `metadatos.yaml` | Valores por defecto del documento: idioma, márgenes, letra, interlineado, enlaces, imágenes. | Una nota puede pisarlos desde su cabecera. Si estuvieran dentro de `estilo.yaml` (bajo `metadata:` o `variables:`), ganarían ellos y la nota no podría cambiarlos. |
| `estilo.tex` | Código LaTeX: fuentes, emojis, cuadros, listas, tablas, código, imágenes. | Es otro lenguaje; mezclarlo en un YAML lo haría ilegible. |
| `filters/*.lua` | Código Lua que pandoc ejecuta mientras convierte. | Pandoc solo los carga como archivos. |

Así se conectan al compilar:

```
pandoc -d estilo nota.md -o nota.pdf
        │
        └─ estilo.yaml ──┬─ metadatos.yaml        (valores de base; la nota puede pisarlos)
                         └─ filters/
                              ├─ preambulo.lua ──► estilo.tex + lo de la nota
                              ├─ cortar-formulas.lua
                              └─ centrar-imagenes.lua
```

`estilo.yaml` los conecta con `${.}`, que significa "la carpeta donde está este archivo". Por eso se puede mover la carpeta entera a cualquier lugar.

`estilo.tex` no lo carga `estilo.yaml` directamente (con `include-in-header`) sino el filtro `filters/preambulo.lua`. Con `include-in-header`, pandoc ignoraba sin avisar el `header-includes` de la cabecera de la nota. El filtro pone primero `estilo.tex` y después lo de la nota, así la nota puede cambiar algo del estilo. También es el que pasa el `mainfont` de la nota a `estilo.tex`, para que la letra nueva conserve los emojis.

### Opciones y metadatos

Pandoc maneja dos tipos de valores, y la diferencia importa para saber qué puede cambiar una nota:

| Tipo | Ejemplos | Dónde se cambian |
|:--|:--|:--|
| **Metadatos**: datos del documento que usa la plantilla | `title`, `geometry`, `fontsize`, `mainfont`, `linestretch`, `ancho-imagenes` | En `metadatos.yaml`, en la cabecera de la nota o con `-M` en el comando. |
| **Opciones**: cómo trabaja pandoc | `pdf-engine`, `highlight-style`, `filters`, `metadata-files` | En `estilo.yaml` o en el comando. **No desde la nota**: pandoc ignora, sin avisar, las opciones escritas en la cabecera de un `.md`. |

(`toc` funciona de las dos formas, por eso `toc: true` en la cabecera sí anda.)

Para cambiar una opción en una sola compilación, se escribe en el comando después de `-d estilo`, y gana:

```bash
pandoc -d estilo --highlight-style=zenburn nota.md -o nota.pdf
```

Con `--pdf-engine=xelatex` también compila, pero se pierden los emojis a color y el corte de palabras largas, que dependen de `lualatex`.

### Orden de prioridad de los metadatos

De menor a mayor:

```
metadatos.yaml  <  cabecera de la nota  <  opción -M del comando
```

### Qué hace cada sección de `estilo.tex`

| Sección | Qué hace |
|:--|:--|
| 0 | Letra principal (Latin Modern Roman, o la del `mainfont` de la nota) con respaldo: Noto Color Emoji (emojis) y DejaVu Sans (símbolos). |
| 1 | Más separación entre los ítems de las listas. |
| 2 | Más altura en las filas de las tablas. |
| 3 | Las citas pasan a ser cuadros celestes con barra azul. |
| 4 | Las líneas largas de código se cortan con una flechita (↪). |
| 5 | Las palabras de 20 caracteres o más sin espacios se cortan entre letras si no entran. |
| 6 | Define `\needspace`. |
| 7 | Ancho máximo de las imágenes (`ancho-imagenes`). |

Cada sección está explicada con más detalle en los comentarios del propio archivo.

### Fórmulas largas

Pandoc no corta una fórmula en bloque (`$$ ... $$`) que es más ancha que la hoja: se sale por la derecha. El filtro `filters/cortar-formulas.lua` lo resuelve solo, en todas las notas:

- Estima el ancho de cada fórmula en bloque. Si entra en la hoja, no la toca (ni las fórmulas en línea).
- Si no entra, la parte en filas cortando en los signos `+` y `-`: el numerador y el denominador de una fracción, o la derecha de la ecuación si no tiene fracción. Un numerador del tipo `\left(A\right) \left(B\right)` se corta dentro del último paréntesis.
- Si la misma fracción está escrita dos veces seguidas (`a = F = F`), deja una sola.
- Una parte que ya trae `\\` o `\begin` (cortada a mano) no se toca.
- Lee el tamaño de letra y los márgenes de la cabecera de la nota (`fontsize`, `geometry: margin=...`, `papersize`), así que se adapta si los cambiás.
- Si una fórmula sigue sin entrar (por ejemplo, un solo término larguísimo), avisa por pantalla.

Para ver qué fórmulas corta y con qué ancho: `CORTAR_FORMULAS_DEBUG=1 pandoc -d estilo nota.md -o nota.pdf`. Para apagarlo, comentar (con `#`) solo la línea de `cortar-formulas.lua` en el bloque `filters:` de `estilo.yaml`; la de `preambulo.lua` tiene que quedar, porque sin ella no se carga el estilo. Los umbrales están al principio del filtro.

Es una estimación (error de ±2 % en fórmulas anchas), y se calibró con fórmulas de funciones de transferencia: con símbolos poco comunes puede cortar de más o de menos.

## Modificar el estilo

| Quiero... | Dónde |
|:--|:--|
| Cambiar los márgenes, el tamaño de letra, el interlineado, el ancho de las imágenes o el idioma de todas las notas | `defaults/metadatos.yaml` |
| Cambiar los colores del código | `highlight-style` en `defaults/estilo.yaml` (`pandoc --list-highlight-styles` muestra las opciones). Para una sola compilación: `--highlight-style=...` en el comando |
| Cambiar los colores de los cuadros | los dos `\definecolor` de la sección 3 de `defaults/estilo.tex` |
| Más o menos aire en listas o tablas | secciones 1 y 2 de `defaults/estilo.tex` |
| Sacar algo del estilo | borrar o comentar su sección en `defaults/estilo.tex` |
| Que no se corten las fórmulas largas | comentar la línea de `cortar-formulas.lua` en `defaults/estilo.yaml` (no la de `preambulo.lua`) |
| Tener un segundo estilo (por ejemplo, uno compacto) | crear otro `.yaml` en `defaults/` y usarlo así: `pandoc -d estilo -d compacto nota.md -o nota.pdf` |

Después de cambiar el estilo, conviene volver a generar los PDF de los ejemplos:

```bash
cd ~/.local/share/pandoc/examples
for f in *.md; do pandoc -d estilo "$f" -o "${f%.md}.pdf"; done
```

## Ejemplos

En `examples/` hay tres notas con su PDF ya generado, para ver el resultado sin compilar.

| Ejemplo | Qué muestra |
|:--|:--|
| `example_1` | Lo básico: cabecera, texto, emojis, listas, cuadros, tablas y código. Sirve como plantilla para empezar. |
| `example_2` | Tablas con texto largo, muchas columnas, URLs y hashes sin espacios, y código en línea. Son los casos donde un PDF suele salirse de la hoja. |
| `example_3` | Un apunte real y largo (más de 90 páginas), con índice, fórmulas, saltos de página, y márgenes, interlineado y letra propios en la cabecera (`mainfont: Libertinus Serif`: para compilarlo hay que tener esa letra instalada). Tarda más en compilar (unos 15 segundos, contra 4 de los otros). |

## Problemas frecuentes

| Síntoma | Causa y solución |
|:--|:--|
| `estilo.yaml: ... does not exist` | Pandoc no encuentra el archivo. Revisá que los archivos estén en `~/.local/share/pandoc/defaults/` y que la carpeta de datos sea esa (`pandoc --version \| grep -i "user data"`). Si muestra otra, ver el paso 2 de la instalación. |
| `File 'fvextra.sty' not found` | Falta un paquete: `sudo apt install texlive-latex-extra`. |
| `lualatex not found. Please select a different --pdf-engine...` | Falta el motor: `sudo apt install texlive-luatex`. |
| Los emojis salen en blanco, en negro o no salen | Falta la fuente: `sudo apt install fonts-noto-color-emoji`. Si la nota tiene `mainfont`, puede ser que esa letra traiga sus propios emojis en blanco y negro. |
| `The font "X" cannot be found` | La letra del `mainfont` no está instalada o el nombre no coincide: comparalo con `fc-list \| grep -i "X"`. |
| `[preambulo] no encontré .../estilo.tex` | `defaults/` y `filters/` tienen que estar uno al lado del otro. |
| No se genera ningún PDF, error con `lmodern` | `sudo apt install lmodern texlive-fonts-recommended`. |
| Una fórmula se sale de la hoja | Mirá si el filtro avisó por pantalla. Si tiene un solo término larguísimo o no tiene `+` ni `-` con espacios alrededor, no hay dónde cortar: hay que partirla a mano con `\begin{aligned} ... \\ ... \end{aligned}`. |
| `Could not find filter` o error de un filtro | `filters/` tiene que estar al lado de `defaults/`. Si el error es de `cortar-formulas.lua`, se puede probar comentando su línea en `estilo.yaml`. `preambulo.lua` no se puede sacar: es el que carga el estilo. |
| Error de Lua o de `\directlua` | Mirá la sección 5 de `estilo.tex`. Si no lo necesitás, se puede borrar esa sección: el resto sigue funcionando. |
