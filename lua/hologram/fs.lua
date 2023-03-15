local ffi = require('ffi')
local fs = {}

function fs.get_dims_PNG(path)
    local fd = assert(vim.loop.fs_open(path, 'r', 438))
    local buf = ffi.new('const unsigned char[?]', 25, assert(vim.loop.fs_read(fd, 24, 0)))
    assert(vim.loop.fs_close(fd))

    local width = fs.bytes2int(buf + 16)
    local height = fs.bytes2int(buf + 20)
    return width, height
end

function fs.check_sig_PNG(path)
    local fd = vim.loop.fs_open(path, 'r', 438)
    if fd == nil then
        return
    end

    local sig = ffi.new('const unsigned char[?]', 9, assert(vim.loop.fs_read(fd, 8, 0)))

    return sig[0] == 137
        and sig[1] == 80
        and sig[2] == 78
        and sig[3] == 71
        and sig[4] == 13
        and sig[5] == 10
        and sig[6] == 26
        and sig[7] == 10
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
