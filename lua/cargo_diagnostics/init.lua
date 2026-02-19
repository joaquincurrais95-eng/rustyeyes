local M = {}

-- Función setup estándar para plugins de Neovim
function M.setup(opts)
    -- Aquí podrías fusionar las opciones del usuario con tu config.lua
    require("cargo_diagnostics.config").setup(opts or {})
    
    -- Inicializar comandos y autocmds
    require("cargo_diagnostics.ui.commands").setup()
    -- require("cargo_diagnostics.ui.autocmds").setup() -- (Cuando lo implementemos)
end

-- Exponer la función de ejecución directamente por si alguien quiere mapearla
function M.check()
    require("cargo_diagnostics.ui.commands").execute_cargo("check")
    require("cargo_diagnostics.ui.autocmds").setup()
end

return M
