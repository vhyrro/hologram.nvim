local hologram = {}
-- local Image = require('hologram.image')
-- local fs = require('hologram.fs')
local state = require('hologram.state')

function hologram.setup(opts)
    opts = vim.tbl_deep_extend('keep', opts or {}, {
        auto_display = true,
    })

    _ = opts

    -- Create autocommands
    -- local group = vim.api.nvim_create_augroup('Hologram', { clear = true })

    state.update_cell_size()
end

return hologram
