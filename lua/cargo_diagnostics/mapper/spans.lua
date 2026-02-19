local M = {}

---Busca el span primario y lo convierte a coordenadas de Neovim
---@param spans table[] Lista de spans del mensaje de Cargo
---@return table|nil {lnum, col, end_lnum, end_col} o nil si no hay span útil
function M.get_primary_range(spans)
    if not spans or #spans == 0 then return nil end

    -- Elegir el span "primario"
    local primary = nil
    for _, span in ipairs(spans) do
        if span.is_primary then
            primary = span
            break
        end
    end

    -- Fallback: si no hay primario, usar el primero
    if not primary then primary = spans[1] end

    -- Conversión de índices
    -- Rust: 1-based. Neovim Diagnostics: 0-based.
    return {
        lnum = primary.line_start - 1,
        col = primary.column_start - 1,
        end_lnum = primary.line_end - 1,
        end_col = primary.column_end - 1,
    }
end

return M
