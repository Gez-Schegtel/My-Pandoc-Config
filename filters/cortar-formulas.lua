-- ==============================================================================
-- cortar-formulas.lua — Filtro de pandoc: parte las fórmulas largas en filas
--
-- QUÉ HACE
--   Pandoc no corta una fórmula en bloque ($$ ... $$) cuando es más ancha que
--   la hoja: se sale por la derecha. Este filtro revisa cada fórmula en bloque
--   y, SOLO si no entra en la hoja, la reparte en varias filas cortando en los
--   signos + y -, como en una suma larga escrita a mano. Lo que ya entra no se
--   toca. Las fórmulas en línea ($ ... $) tampoco.
--
--   Qué corta:
--     - El numerador y el denominador de una fracción (\frac{N}{D}), cada uno
--       en filas dentro de un \begin{aligned} ... \end{aligned}.
--     - Un numerador que es un producto tipo \left(A\right) \left(B\right): se
--       corta dentro del último factor, cuyos paréntesis pasan a \bigl( y
--       \bigr) para poder abarcar dos filas.
--     - Una fórmula sin fracción (a = b + c + ...): se corta a la derecha del
--       último signo igual.
--     - Si la misma fracción está escrita dos veces seguidas
--       (a = F = F), deja una sola.
--   Qué NO corta: una parte que ya trae \\ o \begin (alguien ya la cortó a
--   mano), ni una parte que no tiene signos + o - donde cortar. Si una fórmula
--   sigue sin entrar, avisa por pantalla (stderr).
--
-- CÓMO DECIDE "NO ENTRA"
--   Estima el ancho de la fórmula en puntos con una fórmula calibrada contra
--   los anchos reales que mide LaTeX (error de ±2 % en fórmulas anchas) y lo
--   compara con el ancho del texto de la hoja. Lee de la cabecera del
--   documento: fontsize, geometry (solo "margin=...") y papersize (a4 o letter).
--
-- CÓMO SE USA
--   Lo carga defaults/estilo.yaml (opción "filters"), así que se aplica solo
--   con "pandoc -d estilo". Solo actúa al generar PDF (LaTeX); con otros
--   formatos de salida no hace nada.
--
-- PARA PROBARLO / AJUSTARLO
--   CORTAR_FORMULAS_DEBUG=1 pandoc -d estilo nota.md -o nota.pdf
--   muestra por pantalla el ancho estimado de cada fórmula larga y qué hizo.
--   El número LIMITE_RELATIVO (más abajo) es qué fracción del ancho del texto
--   se permite antes de cortar; bajarlo corta más temprano.
-- ==============================================================================

if FORMAT ~= 'latex' and FORMAT ~= 'beamer' then
  return {}
end

local DEBUG = os.getenv('CORTAR_FORMULAS_DEBUG') == '1'

-- Ancho en puntos de cada elemento a 11 pt (calibrado midiendo con lualatex).
local PT = { letra = 10.5, sub = 2.98, op = 14.03, par = 5.05, cmd = 9.26, num = 5.5, texto = 5.0 }
local TEXTO = { text = true, mbox = true, textbf = true, textit = true, textrm = true,
                mathrm = true, mathbf = true, operatorname = true }

local LIMITE_RELATIVO = 0.96   -- fracción del ancho del texto que puede ocupar una fórmula
local FILA_MAX = 0.85          -- tope del ancho de una fila al cortar (fracción del texto)
local FILA_MIN = 0.35          -- piso del ancho de una fila

local escala = 1               -- tamaño de letra / 11 pt
local ancho_texto = 489        -- pt; se recalcula con la cabecera del documento

-- ------------------------------------------------------------------------------
-- Utilidades de texto
-- ------------------------------------------------------------------------------

local function recortar(s)
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

-- Dado s[i] == '{', devuelve el índice de la llave que lo cierra (o nil).
local function cierre(s, i)
  local prof, j = 0, i
  while j <= #s do
    local c = s:sub(j, j)
    if c == '\\' then
      j = j + 1                       -- salta el carácter escapado (\{ \} ...)
    elseif c == '{' then
      prof = prof + 1
    elseif c == '}' then
      prof = prof - 1
      if prof == 0 then return j end
    end
    j = j + 1
  end
  return nil
end

-- Recorre s a nivel superior (fuera de llaves y de \left...\right) y llama a
-- f(i, c) en cada posición; si f devuelve un número, el recorrido sigue desde
-- ese índice. Sirve para buscar signos y delimitadores "del nivel de arriba".
local function recorrer(s, f)
  local prof, lr, i = 0, 0, 1
  while i <= #s do
    local c = s:sub(i, i)
    if c == '\\' then
      if s:find('^\\left%f[%A]', i) then
        lr = lr + 1; i = i + 5
      elseif s:find('^\\right%f[%A]', i) then
        lr = lr - 1; i = i + 6
      else
        i = i + 2
      end
    else
      if c == '{' then prof = prof + 1 elseif c == '}' then prof = prof - 1 end
      if prof == 0 and lr == 0 then
        local salto = f(i, c)
        if salto then i = salto else i = i + 1 end
      else
        i = i + 1
      end
    end
  end
end

-- Parte una suma en términos conservando el signo: "A + B - C" -> {"A", "+ B", "- C"}.
local function terminos(s)
  local piezas, ini = {}, 1
  recorrer(s, function(i, c)
    if (c == '+' or c == '-') and i > 1
       and s:sub(i - 1, i - 1) == ' ' and s:sub(i + 1, i + 1) == ' ' then
      piezas[#piezas + 1] = s:sub(ini, i - 2)
      ini = i
    end
  end)
  piezas[#piezas + 1] = s:sub(ini)
  return piezas
end

-- ------------------------------------------------------------------------------
-- Estimación del ancho (en puntos, a 11 pt; después se multiplica por "escala")
-- ------------------------------------------------------------------------------

local ancho  -- se define abajo (es recursiva)

-- Ancho de lo que va en un subíndice o superíndice: los dígitos son más finos.
local function ancho_sub(t)
  local _, digitos = t:gsub('%d', '')
  return digitos * PT.sub + ancho((t:gsub('%d', '')))
end

ancho = function(s)
  local w, i, n = 0, 1, #s
  while i <= n do
    local c = s:sub(i, i)
    if c == '\\' then
      local cmd = s:match('^\\(%a+)', i)
      if cmd == 'frac' then
        local j = s:find('%S', i + 5)
        local e1 = j and s:sub(j, j) == '{' and cierre(s, j)
        local k = e1 and s:find('%S', e1 + 1)
        local e2 = k and s:sub(k, k) == '{' and cierre(s, k)
        if e2 then
          w = w + math.max(ancho(s:sub(j + 1, e1 - 1)), ancho(s:sub(k + 1, e2 - 1)))
          i = e2 + 1
        else
          w = w + PT.cmd; i = i + 5
        end
      elseif cmd == 'begin' then
        local nombre, desde = s:match('^\\begin{([%a*]+)}()', i)
        local fin = nombre and s:find('\\end{' .. nombre .. '}', desde, true)
        if fin then
          local cuerpo, mayor, ini = s:sub(desde, fin - 1), 0, 1
          while true do
            local a, b = cuerpo:find('\\\\', ini, true)
            local fila = cuerpo:sub(ini, (a or 0) - 1)
            if not a then fila = cuerpo:sub(ini) end
            mayor = math.max(mayor, ancho((fila:gsub('&', ''))))
            if not a then break end
            ini = b + 1
          end
          w = w + mayor
          i = fin + #('\\end{' .. nombre .. '}')
        else
          i = i + 6
        end
      elseif cmd and TEXTO[cmd] then
        -- \text{...}: letras de texto normal, más finas que las de matemática
        local j = s:find('%S', i + #cmd + 1)
        local e = j and s:sub(j, j) == '{' and cierre(s, j)
        if e then
          w = w + (e - j - 1) * PT.texto; i = e + 1
        else
          w = w + PT.cmd; i = i + #cmd + 1
        end
      elseif cmd == 'left' or cmd == 'right'
             or (cmd and cmd:match('^[Bb]ig+[lr]?$')) then
        local j = s:find('%S', i + #cmd + 1)
        local d = j and s:sub(j, j) or ''
        if d == '.' then
          i = j + 1
        elseif d == '\\' then
          w = w + PT.par; i = j + 2
        else
          w = w + PT.par; i = (j or i + #cmd) + 1
        end
      elseif cmd then
        w = w + PT.cmd; i = i + #cmd + 1
      else
        i = i + 2                      -- \, \; \{ ...: espacio o símbolo escapado
      end
    elseif c == '_' or c == '^' then
      local j = s:find('%S', i + 1)
      if j and s:sub(j, j) == '{' then
        local e = cierre(s, j) or n
        w = w + ancho_sub(s:sub(j + 1, e - 1)); i = e + 1
      elseif j then
        w = w + ancho_sub(s:sub(j, j)); i = j + 1
      else
        i = i + 1
      end
    elseif c:match('%a') then
      w = w + PT.letra; i = i + 1
    elseif c:match('%d') then
      w = w + PT.num; i = i + 1
    elseif c == '+' or c == '-' then
      w = w + PT.op; i = i + 1
    elseif c == '(' or c == ')' or c == '[' or c == ']' then
      w = w + PT.par; i = i + 1
    else
      i = i + 1                        -- = , . { } espacios: no suman
    end
  end
  return w
end

local function medir(s) return ancho(s) * escala end

-- ------------------------------------------------------------------------------
-- Cortes
-- ------------------------------------------------------------------------------

-- Junta términos en filas que no pasen de "tope" puntos (la primera fila tiene
-- "reservado" puntos menos, porque lleva algo delante).
local function agrupar(piezas, tope, reservado)
  local filas, actual = {}, ''
  for _, p in ipairs(piezas) do
    local cand = actual == '' and p or (actual .. ' ' .. p)
    local lim = tope - (#filas == 0 and reservado or 0)
    if actual ~= '' and medir(cand) > lim then
      filas[#filas + 1] = actual
      actual = p
    else
      actual = cand
    end
  end
  filas[#filas + 1] = actual
  return filas
end

local function aligned(filas)
  return '\\begin{aligned}' .. table.concat(filas, ' \\\\ ') .. '\\end{aligned}'
end

local function ya_cortado(t)
  return t:find('\\\\', 1, true) or t:find('\\begin', 1, true)
end

-- Último grupo \left ... \right de nivel superior: devuelve índice de su \left
-- y del carácter que sigue a su \right (el delimitador de cierre).
local function ultimo_grupo(s)
  local lr, ini, ultimo_i, ultimo_f, i = 0, nil, nil, nil, 1
  while i <= #s do
    if s:sub(i, i) == '\\' then
      if s:find('^\\left%f[%A]', i) then
        if lr == 0 then ini = i end
        lr = lr + 1; i = i + 5
      elseif s:find('^\\right%f[%A]', i) then
        lr = lr - 1
        if lr == 0 and ini then ultimo_i, ultimo_f = ini, i + 6 end
        i = i + 6
      else
        i = i + 2
      end
    else
      i = i + 1
    end
  end
  return ultimo_i, ultimo_f
end

-- Corta una suma t (numerador o denominador) en filas de hasta "tope" puntos.
-- Devuelve el texto nuevo, o nil si no hace falta o no se puede cortar.
local function cortar_suma(t, tope)
  if ya_cortado(t) or medir(t) <= tope then return nil end
  local ts = terminos(t)
  if #ts > 1 then
    local filas = agrupar(ts, tope, 0)
    if #filas > 1 then return aligned(filas) end
    return nil
  end
  -- Producto cuyo último factor es \left( ... \right): se corta adentro de ese factor.
  local ini, fin = ultimo_grupo(t)
  if ini and fin == #t and t:sub(ini, ini + 5) == '\\left(' and t:sub(fin - 6, fin) == '\\right)' then
    local pre = recortar(t:sub(1, ini - 1)) .. ' \\bigl('
    local ts2 = terminos(recortar(t:sub(ini + 6, fin - 7)))
    if #ts2 > 1 then
      local filas = agrupar(ts2, tope, medir(pre))
      if #filas > 1 then
        filas[1] = pre .. filas[1]
        filas[#filas] = filas[#filas] .. '\\bigr)'
        return aligned(filas)
      end
    end
  end
  return nil
end

-- Si el trozo es exactamente \frac{N}{D}, devuelve N y D.
local function como_fraccion(p)
  if not p:find('^\\frac%s*{') then return nil end
  local j = p:find('{', 1, true)
  local e1 = cierre(p, j)
  local k = e1 and p:find('%S', e1 + 1)
  if not (k and p:sub(k, k) == '{') then return nil end
  local e2 = cierre(p, k)
  if e2 and e2 == #p then return p:sub(j + 1, e1 - 1), p:sub(k + 1, e2 - 1) end
  return nil
end

-- Parte s en los "=" de nivel superior.
local function por_igual(s)
  local piezas, ini = {}, 1
  recorrer(s, function(i, c)
    if c == '=' then
      piezas[#piezas + 1] = recortar(s:sub(ini, i - 1)); ini = i + 1
    end
  end)
  piezas[#piezas + 1] = recortar(s:sub(ini))
  return piezas
end

-- Devuelve la fórmula cortada, o nil si se deja como está.
local function procesar(texto)
  local t = recortar(texto)
  local limite = LIMITE_RELATIVO * ancho_texto
  local w0 = medir(t)
  if w0 <= limite then return nil end
  if DEBUG then io.stderr:write(string.format('[cortar-formulas] %.0f pt de %.0f: %s\n', w0, limite, t:sub(1, 60))) end

  local piezas = por_igual(t)
  -- La misma expresión repetida a continuación (a = F = F): se deja una sola.
  local sin_rep = { piezas[1] }
  for k = 2, #piezas do
    if piezas[k] ~= piezas[k - 1] then sin_rep[#sin_rep + 1] = piezas[k] end
  end
  piezas = sin_rep

  local cambio, hechas = false, {}
  while true do
    local total = medir(table.concat(piezas, '='))
    if total <= limite then break end
    -- fracción sin tocar más ancha
    local mejor, mw = nil, -1
    for k, p in ipairs(piezas) do
      local n, d = como_fraccion(p)
      if n and not hechas[k] then
        local w = medir(p)
        if w > mw then mejor, mw = k, w end
      end
    end
    if not mejor then break end
    hechas[mejor] = true
    local n, d = como_fraccion(piezas[mejor])
    local tope = math.min(limite - (total - mw), FILA_MAX * ancho_texto)
    tope = math.max(tope, FILA_MIN * ancho_texto)
    local n2, d2 = cortar_suma(recortar(n), tope), cortar_suma(recortar(d), tope)
    if n2 or d2 then
      piezas[mejor] = '\\frac{' .. (n2 or n) .. '}{' .. (d2 or d) .. '}'
      cambio = true
    end
  end

  -- Sin fracciones que cortar: se corta la derecha del último "=".
  if not cambio and not ya_cortado(t) and medir(table.concat(piezas, '=')) > limite then
    local ult = piezas[#piezas]
    local izq = table.concat(piezas, '=', 1, #piezas - 1)
    local tope = math.max(limite - medir(izq .. '='), FILA_MIN * ancho_texto)
    local filas = agrupar(terminos(ult), tope, 0)
    if #filas > 1 then
      for k = 2, #filas do filas[k] = '&\\quad ' .. filas[k] end
      filas[1] = (#piezas > 1 and (izq .. ' &= ') or '&') .. filas[1]
      return aligned(filas)
    end
  end

  if not cambio and #piezas == #por_igual(t) then return nil end
  local nuevo = table.concat(piezas, '=')
  if medir(nuevo) > ancho_texto then
    io.stderr:write(string.format(
      '[cortar-formulas] aviso: una fórmula sigue sin entrar en la hoja (%.0f pt de %.0f): %s...\n',
      medir(nuevo), ancho_texto, t:sub(1, 50)))
  end
  return nuevo
end

-- ------------------------------------------------------------------------------
-- Tamaño de la hoja y de la letra (se leen de la cabecera del documento)
-- ------------------------------------------------------------------------------

local UNIDAD = { pt = 1, bp = 72.27 / 72, mm = 72.27 / 25.4, cm = 72.27 / 2.54, ['in'] = 72.27 }

local function configurar(meta)
  local function texto(v) return v and pandoc.utils.stringify(v) or '' end
  local tam = tonumber(texto(meta.fontsize):match('([%d.]+)'))
  escala = (tam or 11) / 11
  local papel = 612                                  -- carta (letter), en pt
  if texto(meta.papersize):lower():find('a4') then papel = 595.28 end
  local geo = meta.geometry
  local margen = 62.4                                -- 2.2 cm
  if geo then
    local lista = geo.t == 'MetaList' and geo or { geo }
    for _, g in ipairs(lista) do
      local g_txt = texto(g)
      if g_txt:lower():find('a4') then papel = 595.28 end
      local num, un = g_txt:match('margin%s*=%s*([%d.]+)%s*(%a+)')
      if num and UNIDAD[un] then margen = tonumber(num) * UNIDAD[un] end
    end
  end
  ancho_texto = papel - 2 * margen
end

-- ------------------------------------------------------------------------------

return {
  {
    Pandoc = function(doc)
      configurar(doc.meta)
      return doc:walk({
        Math = function(el)
          if el.mathtype ~= 'DisplayMath' then return nil end
          local ok, nuevo = pcall(procesar, el.text)
          if not ok then
            io.stderr:write('[cortar-formulas] error al procesar una fórmula, se deja igual: ' .. tostring(nuevo) .. '\n')
            return nil
          end
          if nuevo then return pandoc.Math('DisplayMath', nuevo) end
          return nil
        end,
      })
    end,
  },
}
