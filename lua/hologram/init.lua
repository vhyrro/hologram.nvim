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

            if not info then
                return
            end

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

            if not info then
                return
            end

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

    if not opts.auto_display then
        return
    end

    local managed_buffers = {}

    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = group,
        callback = function(event)
            local buffer = event.buf

            if managed_buffers[buffer] then
                return
            end

            local query = vim.treesitter.get_query(vim.api.nvim_buf_get_option(buffer, "filetype") or "", "images")

            if not query then
                return
            end

            local top_level_node = vim.treesitter.get_parser(buffer):parse()[1]

            if not top_level_node then
                return
            end

            for capture_id, node in query:iter_captures(top_level_node:root(), buffer) do
                local capture = query.captures[capture_id]

                if capture == "path" then
                    local path = vim.treesitter.get_node_text(node, buffer)

                    if not path then
                        return
                    end

                    -- For now, hardcode the behaviour such that the image gets placed one line
                    -- below the path. This should be customizable in the future.
                    local start, col = node:range()

                    local image = Image:new(path)

                    if image then
                        image:display(start + 1, col, buffer, {})
                    end
                end
            end

            managed_buffers[buffer] = true
        end,
    })
end

return hologram
