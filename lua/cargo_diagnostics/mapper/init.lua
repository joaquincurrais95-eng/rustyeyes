local M = {}
local severity = require("cargo_diagnostics.mapper.severity")
local paths = require("cargo_diagnostics.mapper.paths")
local spans = require("cargo_diagnostics.mapper.spans")

---Convierte un mensaje de Cargo en un diagnóstico de Neovim
---@param msg table El objeto 'message' dentro del JSON de cargo
---@param ctx table Contexto de ejecución
---@return table|nil { filename, diagnostic }
function M.map_diagnostic(msg, ctx)
    -- Validación defensiva
    if not msg or not msg.spans or #msg.spans == 0 then
        -- Aquí podríamos devolver un error global, pero por ahora ignoramos
        return nil
    end

    local range = spans.get_primary_range(msg.spans)
    if not range then return nil end

    -- Obtener el nombre del archivo del span primario
    -- Nota: asumimos que el span primario tiene el file_name correcto
    local primary_span = nil
    for _, s in ipairs(msg.spans) do
        if s.is_primary then primary_span = s break end
    end
    if not primary_span then primary_span = msg.spans[1] end

    local abs_path = paths.resolve(primary_span.file_name, ctx)

    -- Construir objeto final para vim.diagnostic
    local diagnostic = {
        lnum = range.lnum,
        col = range.col,
        end_lnum = range.end_lnum,
        end_col = range.end_col,
        severity = severity.get(msg.level),
        message = msg.message,
        source = "cargo",
        user_data = {
            -- Guardamos el original por si queremos mostrar 'rendered' luego
            original = msg
        }
    }

    return {
        filename = abs_path,
        diagnostic = diagnostic
    }
end

return M
