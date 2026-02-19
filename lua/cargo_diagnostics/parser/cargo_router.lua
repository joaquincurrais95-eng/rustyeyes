local M = {}

---Enruta el JSON a un evento conocido o lo ignora
---@param data table El JSON ya decodificado
---@return table|nil El evento filtrado
function M.route(data)
    if not data or type(data) ~= "table" then return nil end

    --  Detectar compiler-message (errores/warnings)
    if data.reason == "compiler-message" then
        return {
            type = "diagnostic",
            message = data.message -- Aquí está el grueso del error de rustc
        }
    end

    --  Detectar build-finished para saber cuándo limpiar o avisar
    if data.reason == "build-finished" then
        return {
            type = "finished",
            success = data.success
        }
    end

    --  Ignorar el resto por ahora para no saturar la memoria
    return nil
end

return M
