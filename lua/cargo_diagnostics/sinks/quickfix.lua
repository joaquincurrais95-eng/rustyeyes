local M = {}

local qf_items = {}

---Limpia la lista temporal de items 
function M.start()
    qf_items = {}
end

---Agrega un diagnóstico al formato de quickfix 
---@param entry table { filename, diagnostic }
function M.add(entry)
    if not entry then return end
    
    table.insert(qf_items, {
        filename = entry.filename,
        lnum = entry.diagnostic.lnum + 1, -- Quickfix usa 1-index [cite: 16]
        col = entry.diagnostic.col + 1,
        text = entry.diagnostic.message,
        type = entry.diagnostic.severity == vim.diagnostic.severity.ERROR and "E" or "W"
    })
end

---Vuelca los items a la quickfix list de Neovim 
function M.flush()
    if #qf_items > 0 then
        vim.fn.setqflist(qf_items, 'r')
        vim.cmd("copen") -- Abre la ventana de quickfix si hay errores 
    else
        vim.fn.setqflist({}, 'r')
        print("[Cargo] No se detectaron errores.")
    end
end

return M
