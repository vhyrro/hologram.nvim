local hologram = {}
local Image = require('hologram.image')
-- local fs = require('hologram.fs')
local state = require('hologram.state')

function hologram.setup(opts)
    opts = vim.tbl_deep_extend('keep', opts or {}, {
        auto_display = true,
    })

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

    local group = vim.api.nvim_create_augroup('Hologram', { clear = true })

    vim.api.nvim_create_autocmd("BufWinLeave", {
        group = group,
        callback = function(event)
            local win = vim.fn.bufwinid(event.buf)
            local info = vim.fn.getwininfo(win)[1]

            local exts = vim.api.nvim_buf_get_extmarks(
                event.buf,
                state.namespace,
                { math.max(info.topline - 1, 0), 0 },
                { info.botline - 2, -1 },
                {}
            )

            for _, ext in ipairs(exts) do
                local id = ext[1]
                Image.instances[id]:delete(event.buf, {})
            end
        end,
    })

    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = group,
        callback = function(event)
            local win = vim.fn.bufwinid(event.buf)
            local info = vim.fn.getwininfo(win)[1]

            local exts = vim.api.nvim_buf_get_extmarks(
                event.buf,
                state.namespace,
                { math.max(info.topline - 1, 0), 0 },
                { info.botline - 2, -1 },
                {}
            )

            for _, ext in ipairs(exts) do
                local id, row, col = unpack(ext)
                Image.instances[id]:display(row + 1, col, event.buf, {})
            end
        end,
    })
end

return hologram
