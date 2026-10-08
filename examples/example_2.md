---
title: "Prueba de tablas"
subtitle: "Casos que pueden salirse de la hoja"
author: "Juani"
date: "8 de octubre de 2026"
---

# 1. Tabla chica (caso normal)

| Concepto  | Descripción        |
|-----------|--------------------|
| Defaults  | Opciones de pandoc |
| Preámbulo | Aspecto en LaTeX   |

# 2. Texto largo en las celdas (todo en una línea)

| Concepto | Descripción |
|----------|-------------|
| Modelo OSI | Es un modelo de referencia dividido en siete capas que describe cómo se comunican dos sistemas a través de una red, desde el medio físico hasta la aplicación que usa el usuario final |
| Modelo TCP/IP | Es el modelo que realmente se usa en Internet, con menos capas que el OSI, y agrupa varias funciones de las capas superiores en una sola capa de aplicación |

# 3. Texto largo con anchos relativos (guiones de distinta longitud)

| Concepto | Descripción | Ejemplo |
|----------|----------------------------------------------|---------------|
| Modelo OSI | Es un modelo de referencia dividido en siete capas que describe cómo se comunican dos sistemas a través de una red | HTTP, TCP, IP |
| Modelo TCP/IP | Es el modelo que realmente se usa en Internet, con menos capas que el OSI | HTTP, TCP, IP |

# 4. Muchas columnas

| A | Columna B | Columna C | Columna D | Columna E | Columna F | Columna G | Columna H | Columna I |
|---|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|
| 1 | dato largo número uno | dato largo número dos | dato largo número tres | dato largo número cuatro | dato largo número cinco | dato largo número seis | dato siete | dato ocho |

# 5. Palabra larga sin espacios en una celda

| Campo | Valor |
|-------|-------|
| URL | https://www.ejemplo.com/una/ruta/muy/larga/que/no/tiene/espacios/ni/forma/de/cortarse/facilmente/index.html |
| Hash | 5f4dcc3b5aa765d61d8327deb882cf995f4dcc3b5aa765d61d8327deb882cf99 |

# 6. Código en línea muy largo

Esto es un párrafo con código en línea: `pandoc -d estilo -M date="$(date +%d/%m/%Y)" -V geometry:margin=4cm --toc --number-sections archivo.md -o archivo.pdf` y sigue el texto.
