local ffi = require('ffi')
local fs = {}

function fs.open_file(filepath)
    return assert(vim.loop.fs_open(filepath, 'r', 438))
end

function fs.get_chunked(buf)
    local len = ffi.sizeof(buf)
    local i, j, chunks = 0, 0, {}
    while i < len - 4096 do
        chunks[j] = ffi.string(buf + i, 4096)
        i, j = i + 4096, j + 1
    end
    chunks[j] = ffi.string(buf + i)
    return chunks
end

return fs
