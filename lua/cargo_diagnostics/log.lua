local M = {}

-- Niveles de log para mayor claridad
M.levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

-- Configuración inicial (podría venir de config.lua luego)
local config = {
    level = M.levels.DEBUG,
    prefix = "[Cargo-Diag]"
}

local function log(level, msg)
    if level < config.level then return end
    
    -- Convertir tablas a string para que no explote el log
    if type(msg) == "table" then
        msg = vim.inspect(msg)
    end

    local level_name = "INFO"
    for name, val in pairs(M.levels) do
        if val == level then level_name = name break end
    end

    -- Usamos vim.notify para que el usuario pueda verlo si es grave, 
    -- o simplemente lo mandamos a los mensajes internos.
    local full_msg = string.format("%s [%s]: %s", config.prefix, level_name, msg)
    
    if level >= M.levels.WARN then
        vim.notify(full_msg, level)
    else
        -- Para DEBUG e INFO, solo lo mandamos al historial de mensajes (:messages)
        print(full_msg)
    end
end

function M.debug(msg) log(M.levels.DEBUG, msg) end
function M.info(msg)  log(M.levels.INFO, msg)  end
function M.warn(msg)  log(M.levels.WARN, msg)  end
function M.error(msg) log(M.levels.ERROR, msg) end

return M
