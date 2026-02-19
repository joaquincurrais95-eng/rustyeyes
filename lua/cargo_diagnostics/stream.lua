local M = {}

---Crea un procesador que acumula pedazos de texto y emite líneas completas
---@param callback function Función a llamar por cada línea completa
---@return function Una función que acepta chunks de texto
function M.new_line_processor(callback)
    local buffer = ""
    
    return function(chunk)
        if not chunk then return end
        
        buffer = buffer .. chunk
        
        -- Buscamos saltos de línea para procesar líneas completas 
        while true do
            local start_idx, end_idx = string.find(buffer, "\n")
            if not start_idx then break end
            
            local line = string.sub(buffer, 1, start_idx - 1)
            buffer = string.sub(buffer, end_idx + 1)
            
            if line ~= "" then
                callback(line)
            end
        end
    end
end

return M
