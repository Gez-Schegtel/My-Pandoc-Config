-- ==============================================================================
-- tablas-listas.lua — Filtro de pandoc: convierte viñetas en celdas de tablas
--                      en listas nativas (itemize en LaTeX, ul/li en HTML/EPUB)
--
-- EL PROBLEMA
--   En tablas de Markdown (pipe tables), Obsidian y la mayoría de editores no
--   admiten saltos de línea con enter dentro de una celda sin romper la fila.
--   Por ello, se suele recurrir a escribir viñetas unicode (•, ●, ○, ◦, ▪, ▫, ⁃)
--   en la misma línea, separadas por espacios, \newline o <br>.
--   Al compilar a PDF sin este filtro, LaTeX coloca todo en un solo párrafo
--   horizontal o rompe el alineamiento vertical dentro de la tabla.
--
-- QUÉ HACE
--   Detecta automáticamente si una celda contiene viñetas de lista:
--     1. Extrae cada ítem precedido por una viñeta unicode (•, ●, ○, ◦, ▪, ▫, ⁃).
--     2. Convierte el bloque en un pandoc.BulletList nativo, que el motor de
--        pandoc compila automáticamente a \begin{itemize} dentro de una columna
--        tipo p{...}/minipage en LaTeX/PDF, y a <ul><li> en EPUB/HTML.
--     3. Si la celda contiene texto introductorio antes del primer punto
--        (por ejemplo: "Requisitos: \newline • Punto 1 ..."), dicho texto se
--        preserva en un párrafo previo a la lista.
--     4. Si el punto medio se utiliza solo como separador tipográfico en una
--        misma línea continua (ej. "Inicio • Configuración • Perfil"), NO se
--        convierte en lista para evitar falsos positivos.
--     5. Celdas con fórmulas matemáticas o texto con \newline sin viñetas
--        permanecen completamente inalteradas.
--     6. Saltos internos (\newline o <br>) dentro de un mismo ítem se convierten
--        en LineBreak limpios (compatibles con LaTeX y EPUB).
--
-- CÓMO SE USA
--   Lo carga defaults/pdf.yaml y defaults/epub.yaml (o defaults/estilo.yaml).
--   No requiere ninguna sintaxis especial en los archivos Markdown: las tablas
--   estándar de Markdown se compilan de forma transparente y visualmente impecable.
-- ==============================================================================

local bullet_symbols = {
  ["•"] = true,
  ["●"] = true,
  ["○"] = true,
  ["◦"] = true,
  ["▪"] = true,
  ["▫"] = true,
  ["⁃"] = true,
}

local function check_bullet_prefix(s)
  if not s then return nil, nil end
  for b, _ in pairs(bullet_symbols) do
    if s == b then
      return b, ""
    elseif s:sub(1, #b) == b then
      return b, s:sub(#b + 1)
    end
  end
  return nil, nil
end

local function contains_any_bullet(inlines)
  for _, inline in ipairs(inlines) do
    if inline.tag == 'Str' then
      local b, _ = check_bullet_prefix(inline.text)
      if b then return true end
    end
  end
  return false
end

local function is_space(x)
  return x and (x.tag == 'Space' or x.tag == 'SoftBreak')
end

local function is_break(x)
  if not x then return false end
  if x.tag == 'LineBreak' then return true end
  if x.tag == 'RawInline' then
    if x.format == 'tex' and x.text:match('^\\newline') then
      return true
    elseif x.format == 'html' and x.text:match('^<br%s*/?>') then
      return true
    end
  end
  return false
end

local function trim_inlines(list)
  local i = 1
  while i <= #list and (is_space(list[i]) or is_break(list[i])) do
    i = i + 1
  end
  local j = #list
  while j >= i and (is_space(list[j]) or is_break(list[j])) do
    j = j - 1
  end
  local trimmed = {}
  for k = i, j do
    table.insert(trimmed, list[k])
  end
  return trimmed
end

local function had_break_before(leading_inlines)
  for i = #leading_inlines, 1, -1 do
    local x = leading_inlines[i]
    if is_break(x) then return true end
    if not is_space(x) then return false end
  end
  return false
end

local function process_inlines(inlines)
  if not contains_any_bullet(inlines) then
    return nil
  end

  local leading_inlines = {}
  local items = {}
  local current_item = nil

  for _, inline in ipairs(inlines) do
    local is_bullet = false
    local rest_text = nil

    if inline.tag == 'Str' then
      local b, rest = check_bullet_prefix(inline.text)
      if b then
        is_bullet = true
        rest_text = rest
      end
    end

    if is_bullet then
      if current_item == nil then
        -- Primer bullet encontrado: verificar si había texto previo
        local trimmed_lead = trim_inlines(leading_inlines)
        if #trimmed_lead > 0 then
          if not had_break_before(leading_inlines) then
            -- Había texto previo en la misma línea sin salto: es separador inline (breadcrumb), no lista
            return nil
          end
        end
        leading_inlines = trimmed_lead
        current_item = {}
        if rest_text and #rest_text > 0 then
          table.insert(current_item, pandoc.Str(rest_text))
        end
      else
        -- Siguiente viñeta: guardar el ítem acumulado
        local trimmed = trim_inlines(current_item)
        if #trimmed > 0 then
          table.insert(items, { pandoc.Plain(trimmed) })
        end
        current_item = {}
        if rest_text and #rest_text > 0 then
          table.insert(current_item, pandoc.Str(rest_text))
        end
      end
    else
      if current_item == nil then
        table.insert(leading_inlines, inline)
      else
        if is_break(inline) then
          -- Limpiar espacios antes del salto y normalizar a LineBreak
          while #current_item > 0 and is_space(current_item[#current_item]) do
            table.remove(current_item, #current_item)
          end
          table.insert(current_item, pandoc.LineBreak())
        else
          if #current_item > 0 and current_item[#current_item].tag == 'LineBreak' and is_space(inline) then
            -- Omitir espacios redundantes inmediatamente después de un salto de línea
          else
            table.insert(current_item, inline)
          end
        end
      end
    end
  end

  if current_item ~= nil then
    local trimmed = trim_inlines(current_item)
    if #trimmed > 0 then
      table.insert(items, { pandoc.Plain(trimmed) })
    end
  end

  if #items == 0 then
    return nil
  end

  local result = {}
  if #leading_inlines > 0 then
    table.insert(result, pandoc.Plain(leading_inlines))
  end
  table.insert(result, pandoc.BulletList(items))

  if #result == 1 then
    return result[1]
  else
    return result
  end
end

function Table(tbl)
  return pandoc.walk_block(tbl, {
    Plain = function(p) return process_inlines(p.content) end,
    Para = function(p) return process_inlines(p.content) end
  })
end
