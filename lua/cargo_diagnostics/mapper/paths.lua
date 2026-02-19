local M = {}

---Resuelve la ruta absoluta del archivo
---@param filename string Ruta que viene de cargo (puede ser relativa)
---@param ctx table RunContext con el cwd
---@return string
function M.resolve(filename, ctx)
    -- Absolutizar desde ctx.cwd
    if vim.fn.filereadable(filename) == 1 then
        -- Si ya es absoluta o accesible directamente
        return vim.fs.normalize(filename)
    end

    -- Si es relativa, unir con cwd
    return vim.fs.normalize(vim.fs.joinpath(ctx.cwd, filename))
end

return M
