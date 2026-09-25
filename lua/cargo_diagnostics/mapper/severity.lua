local M = {}

-- Definimos las constantes manualmente para evitar llamar a vim.diagnostic
-- en hilos secundarios. Estos valores son estándar en Neovim.
local SEVERITY = {
    ERROR = 1,
    WARN = 2,
    INFO = 3,
    HINT = 4,
}

---@param level string "error" | "warning" | "note" | "help" | etc.
function M.get(level)
    local map = {
        ["error"] = SEVERITY.ERROR,
        ["warning"] = SEVERITY.WARN,
        ["note"] = SEVERITY.INFO,
        ["help"] = SEVERITY.HINT,
        ["failure-note"] = SEVERITY.INFO,
    }
    return map[level] or SEVERITY.INFO
end

return M
