local M = {}

---@class RunContext
---@field cwd string Directorio de trabajo para ejecutar cargo
---@field workspace_root string|nil Raíz del workspace de Rust
---@field crate_root string Raíz del crate actual (donde está el Cargo.toml más cercano)
---@field is_workspace boolean Si se detectó que es un workspace

---Busca las raíces de Rust para el buffer actual
---@param bufnr number
---@return RunContext|nil
function M.get_run_context(bufnr)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname == "" then return nil end

    local current_dir = vim.fs.dirname(bufname)

    -- 1. Encontrar el crate_root (el Cargo.toml más cercano hacia arriba)
    local crate_toml = vim.fs.find('Cargo.toml', {
        path = current_dir,
        upward = true,
        stop = vim.loop.os_homedir(),
    })[1]

    if not crate_toml then return nil end
    local crate_root = vim.fs.dirname(crate_toml)

    -- 2. Encontrar el workspace_root
    -- Buscamos el Cargo.toml más lejano que contenga un workspace o el mismo si no hay más
    local workspace_root = crate_root
    local all_tomls = vim.fs.find('Cargo.toml', {
        path = current_dir,
        upward = true,
        limit = math.huge,
        stop = vim.loop.os_homedir(),
    })

    -- El último de la lista suele ser el más cercano a la raíz del sistema/usuario
    if #all_tomls > 0 then
        workspace_root = vim.fs.dirname(all_tomls[#all_tomls])
    end

    local is_workspace = workspace_root ~= crate_root

    return {
        cwd = workspace_root or crate_root, -- Prioridad al workspace
        workspace_root = workspace_root,
        crate_root = crate_root,
        is_workspace = is_workspace
    }
end

return M
