local M = {}

-- Namespace propio
local ns = vim.api.nvim_create_namespace("cargo_diagnostics")

-- Almacén temporal para agrupar diagnósticos por archivo antes de pintar
-- Estructura: { [filename] = { diag1, diag2, ... } }
local cache = {}

---Limpia los diagnósticos anteriores
function M.start()
    cache = {}
    -- Opcional: limpiar todo el namespace al iniciar
    -- vim.diagnostic.reset(ns) 
end

---Agrega un diagnóstico al caché
---@param entry table { filename, diagnostic }
function M.add(entry)
    if not entry or not entry.filename then return end
    
    if not cache[entry.filename] then
        cache[entry.filename] = {}
    end
    
    table.insert(cache[entry.filename], entry.diagnostic)
end

---Aplica los diagnósticos acumulados al editor
function M.flush()
    -- vim.diagnostic.set requiere la lista completa por buffer
    vim.schedule(function()
	    for filename, diagnostics in pairs(cache) do
		-- Intentar obtener el bufnr si el archivo está abierto
		local bufnr = vim.fn.bufadd(filename)
		
		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		    vim.diagnostic.set(ns, bufnr, diagnostics)
		end

	    end
	end)
end

return M
