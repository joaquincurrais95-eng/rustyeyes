local M = {}
function M.new_line_processor(callback)
    local buffer = ""
    local function emit(line)
        line = line:gsub("\r$", "")
        if line ~= "" then callback(line) end
    end
    local function feed(chunk)
        if not chunk then return end
        buffer = buffer .. chunk
        while true do
            local pos = buffer:find("\n", 1, true)
            if not pos then break end
            emit(buffer:sub(1, pos - 1))
            buffer = buffer:sub(pos + 1)
        end
    end
    local function flush()
        emit(buffer)
        buffer = ""
    end
    return feed, flush
end
return M
