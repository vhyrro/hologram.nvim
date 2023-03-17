local ffi = require('ffi')
local fs = require('hologram.fs')
local jpg = {}
local magick = require("magick")

jpg.open = fs.open_file
jpg.close = function(fd) vim.loop.fs_close(fd) end

function jpg.has_valid_signature(fd)
    if fd == nil then
        return
    end

    -- Read the first two bytes from the file descriptor.
    local buffer = ffi.new('const unsigned char[2]', assert(vim.loop.fs_read(fd, 2)))

    -- Check if the bytes match the JPEG signature.
    return buffer[0] == 0xff and buffer[1] == 0xd8
end

function jpg.get_dimensions(fd)
    return 100, 100
end

function jpg.get_transmit_data(_, filename)
    local image = assert(magick.load_image(filename))

    image:set_format("PNG")

    return {
        keys = {
            format = 100,
            transmission_type = "d",
        },
        payload = image:get_blob(),
    }
end

return jpg
