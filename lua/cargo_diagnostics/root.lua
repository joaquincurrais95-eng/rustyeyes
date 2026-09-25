local M = {}
function M.get_run_context(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then return nil end
    local manifest = vim.fs.find("Cargo.toml", { path = vim.fs.dirname(name), upward = true })[1]
    if not manifest then return nil end
    local dir = vim.fs.dirname(manifest)
    return { cwd = dir, crate_root = dir, workspace_root = nil, is_workspace = false }
end
return M
