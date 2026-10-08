---
title: "Ejemplo de apunte"
subtitle: "Muestra del estilo de pandoc"
author: "Juani"
date: "8 de octubre de 2026"
---

# Cómo usar este ejemplo

Este archivo sirve para probar la configuración de `defaults/`. Se compila así:

```bash
pandoc -d estilo example_1.md -o example_1.pdf
```

La cabecera de arriba es lo único que necesita cada nota. El resto del aspecto
(márgenes, fuentes, emojis, cuadros, listas y tablas) viene de la configuración.

# Texto y listas

Un párrafo con **negrita**, *cursiva* y `código en línea`. También se ven bien
los símbolos y los emojis: ✅ listo, ⚠️ cuidado, 📌 importante, α β γ.

Lista con viñetas:

- Primer punto
- Segundo punto, con un poco más de texto para ver cómo se separa de los demás
- Tercer punto

Lista numerada:

1. Escribir la nota
2. Compilar con `pandoc -d estilo`
3. Revisar el PDF

# Cuadros

> **💡 Idea clave:** los bloques de cita se muestran como un cuadro celeste con
> una barra azul a la izquierda.

> **⚠️ Ojo:** sirven para destacar advertencias o cosas que se suelen olvidar.

> **📝 Para el examen:** también se pueden usar para repasar lo más importante.

# Tablas

| Concepto   | Descripción                  | Ejemplo        |
|------------|------------------------------|----------------|
| Defaults   | Opciones de línea de comandos | `estilo.yaml`  |
| Metadatos  | Márgenes, letra, idioma      | `metadatos.yaml` |
| Preámbulo  | Aspecto en LaTeX             | `estilo.tex`   |

# Código

```python
def saludar(nombre):
    return f"Hola, {nombre}"

print(saludar("mundo"))
```

# Cambiar algo en una sola nota

Para pisar un valor solo en este documento, se agrega a la cabecera, por ejemplo
`geometry: margin=4cm`, o se pasa por la terminal con `-M`:

```bash
pandoc -d estilo -M date="$(date +%d/%m/%Y)" ejemplo.md -o ejemplo.pdf
```
