local M = {}
function M.setup()
    local group = vim.api.nvim_create_augroup("CargoDiagnosticsCleanup", { clear = true })
    if require("cargo_diagnostics.config").options.check_on_save then
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = group, pattern = "*.rs",
            callback = function() require("cargo_diagnostics").check() end,
        })
    end
end
return M
