local M = {}

function M.test_run()
    local _ = vim.diagnostic
    local root = require("cargo_diagnostics.root")
    local cmd = require("cargo_diagnostics.cmd")
    local runner = require("cargo_diagnostics.runner")
    local jsonl = require("cargo_diagnostics.parser.jsonl")
    local router = require("cargo_diagnostics.parser.cargo_router")
    local mapper = require("cargo_diagnostics.mapper")
    local diag_sink = require("cargo_diagnostics.sinks.diagnostic")
    local logger = require("cargo_diagnostics.log")

    --  Paso 1: Obtener el contexto del buffer actual
    local ctx = root.get_run_context(0)
    if not ctx then
        logger.error("No se detectó un proyecto Rust válido.")
        return
    end

    --  Paso 2: Construir el comando (check por defecto)
    local cargo_cmd = cmd.build_command(ctx, "check")
    logger.info("Iniciando test en: " .. cargo_cmd.cwd)

    --  Paso 3: Preparar el 'sink' de diagnósticos (limpiar previos)
    diag_sink.start()

    --  Paso 4: Ejecutar de forma asíncrona
    runner.run_cargo(cargo_cmd, function(line)
        --  Decodificar JSON
        local data = jsonl.parse_line(line)

        --  Filtrar solo mensajes del compilador
        local event = router.route(data)

        if event and event.type == "diagnostic" then
            --  Convertir formato Rust a Neovim (0-indexado)
            local mapped = mapper.map_diagnostic(event.message, ctx)

            if mapped then
                --  Acumular en el sink
                diag_sink.add(mapped)
            end
        end
    end, function(code)
        --  Paso 5: Al terminar, volcar los diagnósticos al buffer
        diag_sink.flush()
        logger.info("Test finalizado con código: " .. code)
    end)
end

return M
