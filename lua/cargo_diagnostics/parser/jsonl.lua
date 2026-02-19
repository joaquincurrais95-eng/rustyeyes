local M = {}

---Decodifica una línea JSON de forma segura
---@param line string
---@return table|nil
function M.parse_line(line)
    if not line or line == "" then return nil end

    --  Usar pcall para evitar que el plugin explote si llega basura
    local ok, data = pcall(vim.json.decode, line)
    if not ok then
        return nil
    end

    return data
end

return M
