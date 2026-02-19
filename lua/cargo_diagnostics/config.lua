local M = {}

---@class CargoConfig
---@field cargo_command string Comando base (default: "check")
---@field auto_clear_log boolean Limpiar log al iniciar
local defaults = {
    cargo_command = "check",
    auto_clear_log = true,
}

M.options = {}

function M.setup(user_opts)
    M.options = vim.tbl_deep_extend("force", defaults, user_opts or {})
end

return M
