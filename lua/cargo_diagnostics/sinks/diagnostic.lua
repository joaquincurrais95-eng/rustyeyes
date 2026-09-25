local M = {}
local ns = vim.api.nvim_create_namespace("cargo_diagnostics")
local cache = {}
function M.start() cache = {} end
function M.add(entry)
    if not entry or not entry.filename then return end
    cache[entry.filename] = cache[entry.filename] or {}
    table.insert(cache[entry.filename], entry.diagnostic)
end
function M.flush()
    vim.diagnostic.reset(ns)
    for filename, diagnostics in pairs(cache) do
        local bufnr = vim.fn.bufadd(filename)
        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.diagnostic.set(ns, bufnr, diagnostics)
        end
    end
end
return M
