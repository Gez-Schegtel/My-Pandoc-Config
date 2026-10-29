-- ==============================================================================
-- preambulo.lua — Filtro de pandoc: arma el preámbulo LaTeX de cada documento
--
-- QUÉ HACE
--   Agrega al preámbulo (la parte de arriba del LaTeX, antes del texto), en
--   este orden:
--     1. Si la nota pide otra letra con "mainfont: ...", la definición
--        \fuenteprincipal con ese nombre (ver "LA LETRA" más abajo).
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
