local module = {}
local fs = require("hologram.fs")

local parsers = {
    png = require('hologram.parsers.png'),
    jpg = require("hologram.parsers.jpg"),
}

function module.detect(filename)
    local fd = fs.open_file(filename)

    for _, parser in pairs(parsers) do
        if parser.has_valid_signature(fd, filename) then
            assert(vim.loop.fs_close(fd))
            return parser
        end
    end

    assert(vim.loop.fs_close(fd))
end

return module
