local config = require('nvim-treesitter-textsubjects.config')
local selection = require('nvim-treesitter-textsubjects.selection')
local matcher = require('nvim-treesitter-textsubjects.matcher')
local Position = require('nvim-treesitter-textsubjects.range').Position

local M = {}

local function attach(bufnr)
    local buf = bufnr or vim.api.nvim_get_current_buf()
    for keymap, query in pairs(config.get().keymaps) do
        local query_name, desc
        if type(query) == 'table' then
            query_name = query[1]
            desc = query['desc']
        else
            query_name = query
        end

        vim.keymap.set('o', keymap, function()
            local pos = Position.from_vim(vim.fn.getpos('.'))
            selection.select(query_name, pos, pos)
        end, { buffer = buf, silent = true, desc = desc })

        vim.keymap.set('x', keymap, function()
            selection.select(query_name, Position.from_vim(vim.fn.getpos('v')), Position.from_vim(vim.fn.getpos('.')))
        end, { buffer = buf, silent = true, desc = desc })
    end

    local prev_selection = config.get().prev_selection
    if prev_selection ~= nil and #prev_selection > 0 then
        vim.keymap.set('o', prev_selection, function()
            local pos = Position.from_vim(vim.fn.getpos('.'))
            selection.prev_select(pos, pos)
        end, { buffer = buf, silent = true, desc = 'Previous textsubjects selection' })

        vim.keymap.set('x', prev_selection, function()
            selection.prev_select(Position.from_vim(vim.fn.getpos('v')), Position.from_vim(vim.fn.getpos('.')))
        end, { buffer = buf, silent = true, desc = 'Previous textsubjects selection' })
    end
end

local function detach(bufnr)
    -- we wrap this because vim.keymap.del can error if we haven't yet created the keymaps
    -- it's a big tedious to check for each keymap so we just wrap it in a pcall
    pcall(function()
        for keymap, _ in pairs(config.get().keymaps) do
            vim.keymap.del('o', keymap, { buffer = bufnr })
            vim.keymap.del('x', keymap, { buffer = bufnr })
        end

        local prev_selection = config.get().prev_selection
        if prev_selection ~= nil and #prev_selection > 0 then
            vim.keymap.del('o', prev_selection, { buffer = bufnr })
            vim.keymap.del('x', prev_selection, { buffer = bufnr })
        end
    end)
end

function M.configure(config_overrides)
    config.set(config_overrides)
end

-- An alias to allow lazy.nvim automatically apply user configuration
M.setup = M.configure

function M.init()
    vim.api.nvim_create_user_command('TextSubjectsDebug', function(opts)
        matcher.print_matches(opts.args)
    end, {
        nargs = '?',
        complete = config.get_configured_queries,
    })

    vim.api.nvim_create_autocmd('FileType', {
        callback = function(details)
            detach(details.buf)

            if matcher.is_supported(details.buf, config.get_configured_queries()) then
                attach(details.buf)
            end
        end,
    })
    vim.api.nvim_create_autocmd('BufUnload', {
        callback = function(details)
            detach(details.buf)
        end,
    })
end

return M
