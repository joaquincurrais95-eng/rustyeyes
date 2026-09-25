local M = {}

-- Dependencias internas
local root = require("cargo_diagnostics.root")
local cmd = require("cargo_diagnostics.cmd")
local runner = require("cargo_diagnostics.runner")
local jsonl = require("cargo_diagnostics.parser.jsonl")
local router = require("cargo_diagnostics.parser.cargo_router")
local mapper = require("cargo_diagnostics.mapper")
local diag_sink = require("cargo_diagnostics.sinks.diagnostic")
local qf_sink = require("cargo_diagnostics.sinks.quickfix")

---Función genérica para ejecutar cargo basado en un preset
---@param preset string 'check' | 'build'
function M.execute_cargo(preset)
    local ctx = root.get_run_context(0) --
    if not ctx then
        print("Error: No se encontró un proyecto Rust (Cargo.toml)")
        return
    end

    local cargo_cmd = cmd.build_command(ctx, preset) --

    -- Inicializar recolectores
    diag_sink.start()
    qf_sink.start()

    print(string.format("[Cargo] Ejecutando %s...", preset))

    runner.run_cargo(cargo_cmd, function(line)
        local data = jsonl.parse_line(line) --
        local event = router.route(data)    --

        if event and event.type == "diagnostic" then
            local mapped = mapper.map_diagnostic(event.message, ctx) --
            if mapped then
                diag_sink.add(mapped)
                qf_sink.add(mapped)
            end
        end
    end, function(code)
        -- Finalizar y mostrar resultados
        vim.schedule(function()
            diag_sink.flush()
            qf_sink.flush()
        end)
    end)
end

---Registra los comandos de usuario en Neovim
function M.setup()
    -- Comando :CargoCheck
    vim.api.nvim_create_user_command("CargoCheck", function()
        M.execute_cargo("check")
    end, { desc = "Ejecuta cargo check y muestra diagnósticos" })

    -- Comando :CargoBuild
    vim.api.nvim_create_user_command("CargoBuild", function()
        M.execute_cargo("build")
    end, { desc = "Ejecuta cargo build y muestra diagnósticos" })
end

return M
