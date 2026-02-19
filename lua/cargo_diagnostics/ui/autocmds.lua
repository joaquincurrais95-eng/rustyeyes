local M = {}
local ns = vim.api.nvim_create_namespace("cargo_diagnostics")

---Limpia los diagnósticos solo para la línea actual del cursor
function M.clear_current_line_diagnostics()
    local bufnr = vim.api.nvim_get_current_buf()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed

    -- 1. Obtener todos los diagnósticos actuales de nuestro plugin
    local diagnostics = vim.diagnostic.get(bufnr, { namespace = ns })
    local new_diagnostics = {}
    local changed = false

    -- 2. Filtrar: mantener todos excepto los de la línea actual
    for _, diag in ipairs(diagnostics) do
        if diag.lnum == row then
            changed = true
        else
            table.insert(new_diagnostics, diag)
        end
    end

    -- 3. Si hubo cambios, actualizar el buffer
    if changed then
        vim.diagnostic.set(ns, bufnr, new_diagnostics)
    end
end

function M.setup()
    local group = vim.api.nvim_create_augroup("CargoDiagnosticsCleanup", { clear = true })

    -- Se dispara cada vez que cambia el texto en modo normal o al salir de modo insertar
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = group,
        pattern = "*.rs",
        callback = function()
            M.clear_current_line_diagnostics()
        end,
    })

    -- [Opcional] Ejecutar cargo check automáticamente al guardar
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = "*.rs",
        callback = function()
            require("cargo_diagnostics.ui.commands").execute_cargo("check")
        end,
    })
end

return M
