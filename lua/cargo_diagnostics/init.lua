local M = {}
function M.setup(opts)
    require("cargo_diagnostics.config").setup(opts or {})
    require("cargo_diagnostics.ui.commands").setup()
    require("cargo_diagnostics.ui.autocmds").setup()
end
function M.check()
    return require("cargo_diagnostics.ui.commands").execute_cargo("check")
end
return M
