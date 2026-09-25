local M = {}
local defaults = { check_on_save = false }
M.options = vim.deepcopy(defaults)
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", defaults, opts or {})
end
return M
