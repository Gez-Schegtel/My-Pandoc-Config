-- ==============================================================================
-- preambulo.lua — Filtro de pandoc: arma el preámbulo LaTeX de cada documento
--
-- QUÉ HACE
--   Agrega al preámbulo (la parte de arriba del LaTeX, antes del texto), en
--   este orden:
--     1. Si la nota pide otra letra con "mainfont: ...", la definición
--        \fuenteprincipal con ese nombre (ver "LA LETRA" más abajo).
--        Y si tiene "ancho-imagenes: ...", el ancho máximo de las imágenes
--        (ver "LAS IMÁGENES").
--     2. defaults/estilo.tex (el aspecto: emojis, cuadros, tablas, código...).
--     3. El "header-includes" de la cabecera de la nota, si tiene.
--
-- POR QUÉ ES UN FILTRO (y no "include-in-header" en estilo.yaml)
--   Con "include-in-header", pandoc IGNORA el header-includes de la nota: lo
--   que la nota agregara al preámbulo (por ejemplo \usepackage{float}) se
--   perdía sin aviso. Este filtro junta las dos cosas: primero el estilo y
--   después lo de la nota, así la nota puede cambiar algo del estilo.
--
-- LA LETRA
--   Los emojis a color salen porque estilo.tex (sección 0) carga la letra
--   principal con un "respaldo" de emojis. Si pandoc cargara por su cuenta la
--   letra del "mainfont" de la nota, la cargaría sin ese respaldo y los emojis
--   desaparecerían. Por eso este filtro le saca el "mainfont" a pandoc y le
--   pasa el nombre a estilo.tex, que carga esa letra con el respaldo.
--   Sin "mainfont", la letra es Latin Modern Roman.
--
-- LAS IMÁGENES
--   "ancho-imagenes" es el ancho máximo de las imágenes, como porcentaje del
--   ancho del texto (70% o 0.7 significan lo mismo). Las imágenes más
--   anchas se achican hasta ese ancho; las más chicas quedan como están. Se
--   pasa a estilo.tex (sección 7) como \anchoimagenes. El valor por defecto
--   está en metadatos.yaml, y cada nota puede poner el suyo.
--
-- CÓMO SE USA
--   Lo carga defaults/estilo.yaml (opción "filters"). En la nota:
--       mainfont: Libertinus Serif
--       header-includes: \usepackage{float}
--   El nombre de la letra es el que muestra:  fc-list | grep -i "nombre"
--   Solo actúa al generar PDF (LaTeX); con otros formatos no hace nada.
-- ==============================================================================

if FORMAT ~= 'latex' and FORMAT ~= 'beamer' then
  return {}
end

-- estilo.tex está en ../defaults/ respecto de este archivo.
local carpeta = pandoc.path.directory(pandoc.path.directory(PANDOC_SCRIPT_FILE))
local ESTILO = pandoc.path.join({ carpeta, 'defaults', 'estilo.tex' })

local function bloque(latex)
  return pandoc.MetaBlocks({ pandoc.RawBlock('latex', latex) })
end

local function avisar(texto)
  io.stderr:write('[preambulo] ' .. texto .. '\n')
end

function Meta(meta)
  local partes = pandoc.List({})

  -- 1. La letra principal
  if meta.mainfont ~= nil then
    local nombre = pandoc.utils.stringify(meta.mainfont)
    meta.mainfont = nil
    if nombre == '' or nombre:find('[{}\\%%#]') then
      avisar('nombre de letra no válido, se usa la de siempre: ' .. nombre)
    else
      partes:insert(bloque('\\def\\fuenteprincipal{' .. nombre .. '}'))
    end
  end

  -- 1b. El ancho máximo de las imágenes
  if meta['ancho-imagenes'] ~= nil then
    local texto = pandoc.utils.stringify(meta['ancho-imagenes'])
    local numero = tonumber((texto:gsub('%s', ''):gsub('%%$', '')))
    if numero and texto:find('%%') then numero = numero / 100 end
    if numero and numero > 1 then numero = numero / 100 end   -- "70" = 70 %
    if numero and numero > 0 and numero <= 1 then
      partes:insert(bloque(string.format('\\def\\anchoimagenes{%.3f\\linewidth}', numero)))
    else
      avisar('ancho-imagenes no válido (se usa el ancho completo): ' .. texto)
    end
  end

  -- 2. El estilo
  local f = io.open(ESTILO, 'r')
  if f then
    f:close()
    if ESTILO:find('[%%#{}\\"]') then
      avisar('la ruta de estilo.tex tiene caracteres que LaTeX no acepta: ' .. ESTILO)
    else
      partes:insert(bloque('\\input{"' .. ESTILO .. '"}'))
    end
  else
    avisar('no encontré ' .. ESTILO .. '; el PDF sale sin el estilo')
  end

  -- 3. Lo que la nota agregue al preámbulo
  local de_la_nota = meta['header-includes']
  if de_la_nota ~= nil then
    if pandoc.utils.type(de_la_nota) == 'List' then
      partes:extend(de_la_nota)
    else
      partes:insert(de_la_nota)
    end
  end

  meta['header-includes'] = partes
  return meta
end
