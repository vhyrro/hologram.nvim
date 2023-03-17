local ffi = require('ffi')
local utils = require('hologram.utils')
local fs = require("hologram.fs")
local png = {}

png.open = fs.open_file
png.close = function(fd) vim.loop.fs_close(fd) end

function png.has_valid_signature(fd, _)
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

function png.get_dimensions(fd, _)
    local buf = ffi.new('const unsigned char[?]', 25, assert(vim.loop.fs_read(fd, 24, 0)))

    local width = utils.bytes2int(buf + 16)
    local height = utils.bytes2int(buf + 20)

    return width, height
end

function png.get_transmit_data(_, filename)
    return {
        keys = {
            format = 100,
            transmission_type = "f",
        },

        payload = filename,
    }
end

return png
