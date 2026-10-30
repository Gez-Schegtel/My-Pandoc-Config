-- ==============================================================================
-- centrar-imagenes.lua — Filtro de pandoc: centra las imágenes sueltas
--
-- EL PROBLEMA
--   Una imagen sola en su párrafo y SIN texto entre los corchetes, por ejemplo
--       ![](foto.png)
--   pandoc la pone como parte del texto, así que queda pegada a la izquierda.
--   Se nota cuando la imagen es más angosta que la hoja.
--   (Con texto entre los corchetes, ![Epígrafe](foto.png), pandoc la convierte
--   en una figura con epígrafe, y esa ya sale centrada.)
--
-- QUÉ HACE
--   Cada párrafo que tiene SOLO imágenes (una, o varias seguidas, sin otro
--   texto) se encierra en un entorno "center" de LaTeX: quedan centradas, en
--   el mismo lugar donde están en el Markdown. Las imágenes dentro de una
--   línea de texto ("mirá esto ![](icono.png) acá") no se tocan.
--
-- A LA IZQUIERDA O A LA DERECHA
--   Para una imagen puntual, se le agrega la clase al lado:
--       ![](foto.png){.izquierda}
--       ![](foto.png){.derecha}
--       ![](foto.png){.derecha width=40%}     (se combina con el tamaño)
--   Si en un mismo párrafo hay varias imágenes, manda la clase de la primera
--   que la tenga. Esto vale para las imágenes sin epígrafe; las que tienen
--   epígrafe (![Texto](foto.png)) son figuras y siempre salen centradas.
--
-- CÓMO SE USA
--   Lo carga defaults/estilo.yaml (opción "filters"). No hay que hacer nada en
--   la nota para el centrado. Solo actúa al generar PDF (LaTeX); con otros formatos no hace nada.
-- ==============================================================================

if FORMAT ~= 'latex' and FORMAT ~= 'beamer' then
  return {}
end

-- Entorno de LaTeX según la clase de la imagen.
local ENTORNO = { izquierda = 'flushleft', derecha = 'flushright' }

function Para(para)
  local imagenes, otros = 0, 0
  local entorno = nil
  for _, el in ipairs(para.content) do
    if el.t == 'Image' then
      imagenes = imagenes + 1
      for _, clase in ipairs(el.classes) do
        if entorno == nil and ENTORNO[clase] then entorno = ENTORNO[clase] end
      end
    elseif el.t ~= 'Space' and el.t ~= 'SoftBreak' and el.t ~= 'LineBreak' then
      otros = otros + 1
    end
  end
  if imagenes == 0 or otros > 0 then
    return nil
  end
  entorno = entorno or 'center'
  return {
    pandoc.RawBlock('latex', '\\begin{' .. entorno .. '}'),
    para,
    pandoc.RawBlock('latex', '\\end{' .. entorno .. '}'),
  }
end
