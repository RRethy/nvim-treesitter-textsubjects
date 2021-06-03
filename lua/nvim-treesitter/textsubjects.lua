local parsers = require('nvim-treesitter.parsers')
local queries = require'nvim-treesitter.query'
local ts_utils = require'nvim-treesitter.ts_utils'

local M = {}

--- @return boolean: true iff the range @a surrounds the range @b. @a == @b => false.
local function does_surround(a, b)
    local a_start_row, a_start_col, a_end_row, a_end_col = a[1], a[2], a[3], a[4]
    local b_start_row, b_start_col, b_end_row, b_end_col = b[1], b[2], b[3], b[4]

    if a_start_row > b_start_row or a_start_row == b_start_row and a_start_col > b_start_col then
        return false
    end
    if a_end_row < b_end_row or a_end_row == b_end_row and a_end_col < b_end_col then
        return false
    end
    return a_start_row < b_start_row or
        a_start_col < b_start_col or
        a_end_row > b_end_row or
        a_end_col > b_end_col
end

-- this comment describes the function
-- this comment describes the function again
function M.select(sel_bigger, sel_start, sel_end)
    local bufnr =  vim.api.nvim_get_current_buf()
    local lang = parsers.get_buf_lang(bufnr)
    if not lang then return end

    local _, sel_start_row, sel_start_col = unpack(sel_start)
    local _, sel_end_row, sel_end_col = unpack(sel_end)
    if sel_start_row > sel_end_row or sel_start_row == sel_end_row and sel_start_col > sel_end_col then
        sel_start_row, sel_start_col, sel_end_row, sel_end_col = sel_end_row, sel_end_col, sel_start_row, sel_start_col
    end
    sel_start_row = sel_start_row - 1
    sel_end_row = sel_end_row - 1
    sel_start_col = sel_start_col - 1
    local sel = {sel_start_row, sel_start_col, sel_end_row, sel_end_col}

    local best
    -- TODO allow custom queries
    local matches = queries.get_capture_matches_recursively(bufnr, '@range', 'textsubjects')
    for _, m in pairs(matches) do
        local match_start_row, match_start_col = unpack(m.node.start_pos)
        local match_end_row, match_end_col = unpack(m.node.end_pos)
        local match = {match_start_row, match_start_col, match_end_row, match_end_col}

        -- match must cover an exclusively bigger range than the current selection
        -- TODO allow reverse logic
        -- print(vim.inspect(match))
        if does_surround(match, sel) then
            if not best or does_surround(best, match) then
                best = match
            end
        end
    end

    -- TODO change selection based on whitespace
    -- TODO ensure cursor is at upper end of visual selection
    if best then
        ts_utils.update_selection(bufnr, best, 'v')
    else
        ts_utils.update_selection(bufnr, sel, 'v')
    end
end

function M.attach(bufnr, _)
    local buf = bufnr or vim.api.nvim_get_current_buf()
    local cmd_o = ':lua require("nvim-treesitter.textsubjects").select(true, vim.fn.getpos("."), vim.fn.getpos("."))<cr>'
    vim.api.nvim_buf_set_keymap(buf, 'o', ';', cmd_o, { silent = true, noremap = true  })
    local cmd_x = ':lua require("nvim-treesitter.textsubjects").select(true, vim.fn.getpos("\'<"), vim.fn.getpos("\'>"))<cr>'
    vim.api.nvim_buf_set_keymap(buf, 'x', ';', cmd_x, { silent = true, noremap = true  })
end

function M.detach(bufnr)
    local buf = bufnr or vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_del_keymap(buf, 'o', '.')
    vim.api.nvim_buf_del_keymap(buf, 'x', '.')
end

return M
