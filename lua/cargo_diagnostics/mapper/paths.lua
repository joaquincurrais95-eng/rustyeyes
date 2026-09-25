local M = {}
function M.resolve(filename, ctx)
    if filename:match("^/") or filename:match("^%a:[/\\]") or filename:match("^\\\\") then
        return vim.fs.normalize(filename)
    end
    return vim.fs.normalize(vim.fs.joinpath(ctx.cwd, filename))
end
return M
