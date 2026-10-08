# Pandoc config

Mi configuración de [pandoc](https://pandoc.org) para convertir apuntes en Markdown a PDF con un estilo propio y siempre el mismo. Se guarda y se usa en un solo lugar, así cada nota solo necesita su título, autor y fecha.

```bash
pandoc -d estilo nota.md -o nota.pdf
```

## Qué consigue

- **Una sola configuración para todas las notas.** Cada `.md` lleva únicamente su cabecera (`title`, `subtitle`, `author`, `date`). El aspecto vive acá.
- **Emojis a color** y símbolos (✅ ⚠️ α →) con la letra Latin Modern Roman.
- **Cuadros** celestes con barra azul para las citas (`>`): ideales para "Idea clave", "Ojo", "Para el examen".
- **Listas y tablas con más aire** que el pandoc por defecto.
- **Código que no se sale de la hoja:** las líneas largas se cortan y la continuación empieza con una flechita (↪).
- **URLs, hashes y rutas largas** en tablas o párrafos también se cortan en vez de salirse de la hoja.
- **Una nota puede cambiar cualquier valor** (márgenes, tamaño de letra...) desde su propia cabecera, sin tocar la configuración.

## Contenido del repositorio

```
pandoc/                      (esta carpeta es ~/.local/share/pandoc)
├── defaults/
│   ├── estilo.yaml          opciones de pandoc; es el único que se nombra al compilar
│   ├── metadatos.yaml       valores por defecto: idioma, márgenes, tamaño de letra
│   └── estilo.tex           aspecto en LaTeX: fuentes, emojis, listas, tablas, cuadros, código
├── examples/
│   ├── example_1.md / .pdf  ejemplo básico: todo lo que cubre el estilo
│   ├── example_2.md / .pdf  tablas y casos que pueden salirse de la hoja
│   └── example_3.md / .pdf  apunte real y largo (85 páginas): índice, fórmulas, saltos de página
└── README.md
```

La carpeta `defaults/` tiene que llamarse así: es el nombre que pandoc busca. Los tres archivos de adentro tienen que estar juntos, porque `estilo.yaml` encuentra a los otros dos por su ubicación.

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

Pandoc busca sus archivos de configuración en su "carpeta de datos". En Linux es `~/.local/share/pandoc`. Este repositorio **es** esa carpeta:

```bash
git clone https://github.com/Gez-Schegtel/My-Pandoc-Config.git ~/.local/share/pandoc
```

Para comprobar que pandoc usa esa carpeta:

```bash
pandoc --version | grep -i "user data"
```

Tiene que mostrar `/home/<usuario>/.local/share/pandoc`. Si existe una carpeta `~/.pandoc`, pandoc usa esa en su lugar: hay que borrarla o renombrarla.

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
---
```

O desde la terminal:

```bash
pandoc -d estilo -M date="$(date +%d/%m/%Y)" nota.md -o nota.pdf
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

### Por qué son tres archivos

| Archivo | Qué contiene | Por qué va aparte |
|:--|:--|:--|
| `estilo.yaml` | Opciones de pandoc: motor, estilo del código, y qué otros dos archivos cargar. | Es el que se nombra al compilar. |
| `metadatos.yaml` | Valores por defecto: idioma, márgenes, tamaño de letra, enlaces. | Una nota puede pisarlos desde su cabecera. Si estuvieran en `estilo.yaml`, ganarían ellos y la nota no podría cambiarlos. |
| `estilo.tex` | Código LaTeX: fuentes, emojis, cuadros, listas, tablas, código. | Es otro lenguaje; mezclarlo en un YAML lo haría ilegible. |

`estilo.yaml` los conecta con `${.}`, que significa "la carpeta donde está este archivo". Por eso se pueden mover los tres juntos a cualquier lugar.

### Orden de prioridad de los valores

De menor a mayor:

```
metadatos.yaml  <  cabecera de la nota  <  opción -M del comando
```

### Qué hace cada sección de `estilo.tex`

| Sección | Qué hace |
|:--|:--|
| 0 | Letra Latin Modern Roman con respaldo: Noto Color Emoji (emojis) y DejaVu Sans (símbolos). |
| 1 | Más separación entre los ítems de las listas. |
| 2 | Más altura en las filas de las tablas. |
| 3 | Las citas pasan a ser cuadros celestes con barra azul. |
| 4 | Las líneas largas de código se cortan con una flechita (↪). |
| 5 | Las palabras de 20 caracteres o más sin espacios se cortan entre letras si no entran. |
| 6 | Define `\needspace`. |

Cada sección está explicada con más detalle en los comentarios del propio archivo.

## Modificar el estilo

| Quiero... | Dónde |
|:--|:--|
| Cambiar los márgenes, la letra o el idioma de todas las notas | `defaults/metadatos.yaml` |
| Cambiar los colores del código | `highlight-style` en `defaults/estilo.yaml` (`pandoc --list-highlight-styles` muestra las opciones) |
| Cambiar los colores de los cuadros | los dos `\definecolor` de la sección 3 de `defaults/estilo.tex` |
| Más o menos aire en listas o tablas | secciones 1 y 2 de `defaults/estilo.tex` |
| Sacar algo del estilo | borrar o comentar su sección en `defaults/estilo.tex` |
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
| `example_3` | Un apunte real y largo (85 páginas), con índice, fórmulas, saltos de página y márgenes propios en la cabecera. Tarda más en compilar (unos 15 segundos, contra 4 de los otros). |

## Problemas frecuentes

| Síntoma | Causa y solución |
|:--|:--|
| `estilo.yaml: ... does not exist` | Pandoc no encuentra el archivo. Revisá que los archivos estén en `~/.local/share/pandoc/defaults/` y que la carpeta de datos sea esa (`pandoc --version \| grep -i "user data"`). Si existe `~/.pandoc`, usa esa. |
| `File 'fvextra.sty' not found` | Falta un paquete: `sudo apt install texlive-latex-extra`. |
| `lualatex not found. Please select a different --pdf-engine...` | Falta el motor: `sudo apt install texlive-luatex`. |
| Los emojis salen en blanco, en negro o no salen | Falta la fuente: `sudo apt install fonts-noto-color-emoji`. |
| No se genera ningún PDF, error con `lmodern` | `sudo apt install lmodern texlive-fonts-recommended`. |
| Error de Lua o de `\directlua` | Mirá la sección 5 de `estilo.tex`. Si no lo necesitás, se puede borrar esa sección: el resto sigue funcionando. |
