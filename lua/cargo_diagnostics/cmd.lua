local M = {}

---@class CargoCmd
---@field args string[] Lista de argumentos para vim.system o libuv
---@field cwd string Directorio donde debe ejecutarse el comando

---Construye el comando de cargo basado en el contexto y el preset
---@param ctx RunContext El contexto obtenido de root.lua
---@param preset string|nil 'check', 'build', 'clippy' (default: 'check')
---@param extra_args table|nil Argumentos adicionales del usuario
---@return CargoCmd
function M.build_command(ctx, preset, extra_args)
    preset = preset or "check"
    extra_args = extra_args or {}

    -- Forzamos el formato JSON para poder parsearlo después
    local args = { "cargo", preset, "--message-format=json" }

    -- Si estamos en un workspace, podemos querer compilar todo o el crate específico.
    -- Por defecto, al ejecutar en el workspace_root, cargo detecta los miembros.
    
    -- Unimos con argumentos adicionales si existen
    for _, arg in ipairs(extra_args) do
        table.insert(args, arg)
    end

    return {
        args = args,
        cwd = ctx.cwd --[cite: 4, 5]
    }
end

---Función de utilidad para depuración 
function M.log_debug_command(bufnr)
    local root = require("cargo_diagnostics.root")
    local ctx = root.get_run_context(bufnr)
    
    if not ctx then
        print("Error: No se encontró un proyecto Rust (Cargo.toml)")
        return
    end

    local cmd = M.build_command(ctx, "check")
    
    print(string.format("[Cargo Debug]"))
    print(string.format("  CWD: %s", cmd.cwd))
    print(string.format("  CMD: %s", table.concat(cmd.args, " ")))
    print(string.format("  Crate Root: %s", ctx.crate_root))
    print(string.format("  Is Workspace: %s", ctx.is_workspace))
end

return M
