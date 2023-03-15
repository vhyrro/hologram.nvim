local module = {}

local parsers = {
    png = require('hologram.parsers.png'),
    -- jpg = require("hologram.parsers.jpg"),
}

function module.detect(fd)
    for _, parser in pairs(parsers) do
        if parser.has_valid_signature(fd) then
            return parser
        end
    end
end

return module
