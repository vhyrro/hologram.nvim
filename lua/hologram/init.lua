local hologram = {}
local Image = require('hologram.image')
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

    -- Routine to update the positions of all images
    vim.api.nvim_set_decoration_provider(state.namespace, {
        on_win = function(_, _, buf, top, bot)
            local exts = vim.api.nvim_buf_get_extmarks(
                buf,
                state.namespace,
                { math.max(top - 1, 0), 0 },
                { bot - 2, -1 },
                {}
            )

            for _, ext in ipairs(exts) do
                local id, row = unpack(ext)
                Image.instances[id]:display(row + 1, 0, buf, {})
            end
        end,
    })
end

return hologram
