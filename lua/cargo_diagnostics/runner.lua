local M = {}

---@type vim.SystemObj|nil Guarda la referencia al proceso actual para poder cancelarlo
local active_job = nil

---Ejecuta el comando de cargo de forma asíncrona
---@param cmd_ctx table El objeto generado por cmd.lua (args y cwd)
---@param on_line function Callback que recibe una línea JSON completa
---@param on_exit function|nil Callback opcional al terminar el proceso
function M.run_cargo(cmd_ctx, on_line, on_exit)
    local stream = require("cargo_diagnostics.stream")
    
    -- Implementar cancelación desde el día 1
    if active_job and not active_job:is_closing() then
        active_job:kill(15) -- Enviar SIGTERM
        -- Si después de un momento sigue vivo, podrías usar SIGKILL (9)
    end

    -- Preparar el reconstructor de líneas
    local stdout_handler = stream.new_line_processor(on_line)

    -- Usar vim.system para ejecución asíncrona
    active_job = vim.system(cmd_ctx.args, {
        cwd = cmd_ctx.cwd,
        stdout = function(err, data)
            if err then
                -- Podríamos loguear el error aquí 
                return
            end
            if data then
		vim.schedule(function()
			stdout_handler(data)
		end)
            end
        end,
        stderr = function(_, data)
            if data then
                -- El stderr suele traer logs de progreso ("Compiling..."),
                -- por ahora lo mandamos al log silencioso.
                require("cargo_diagnostics.log").debug(data)
            end
        end
    }, function(completed)
        -- Callback de salida
        active_job = nil
        if on_exit then
		vim.schedule(function()
			on_exit(completed.code)
		end)
        end
    end)

    return active_job
end

return M
