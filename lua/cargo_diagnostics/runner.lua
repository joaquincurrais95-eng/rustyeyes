local M = {}
local active_job
local generation = 0
function M.run_cargo(ctx, on_line, on_exit)
    generation = generation + 1
    local current = generation
    if active_job then pcall(active_job.kill, active_job, 15) end
    local process, flush = require("cargo_diagnostics.stream").new_line_processor(on_line)
    local ok, job = pcall(vim.system, ctx.args, {
        cwd = ctx.cwd,
        stdout = function(err, data)
            if not err and data then
                vim.schedule(function()
                    if current == generation then process(data) end
                end)
            end
        end,
        stderr = function(_, data)
            if data then vim.schedule(function()
                if current == generation then require("cargo_diagnostics.log").debug(data) end
            end) end
        end,
    }, function(result)
        vim.schedule(function()
            if current ~= generation then return end
            active_job = nil
            flush()
            if on_exit then on_exit(result.code) end
        end)
    end)
    if not ok then
        active_job = nil
        vim.notify("Rustyeyes: could not start Cargo: " .. tostring(job), vim.log.levels.ERROR)
        if on_exit then on_exit(-1) end
        return nil
    end
    active_job = job
    return job
end
return M
