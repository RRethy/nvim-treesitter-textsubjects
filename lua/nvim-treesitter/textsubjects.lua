local parsers = require('nvim-treesitter.parsers')
local queries = require('nvim-treesitter.query')
local ts_utils = require('nvim-treesitter.ts_utils')
local configs = require('nvim-treesitter.configs')

local M = {}
local prev_selections = {}

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

--- extend_range_with_whitespace extends the selection to select any surrounding whitespace as part of the text object
local function extend_range_with_whitespace(range)
    local start_row, start_col, end_row, end_col = unpack(range)

    -- everything before the selection on the same lines as the start of the range
    local startline = string.sub(vim.fn.getline(start_row + 1), 1, start_col)
    local startline_len = #startline
    local startline_whitespace_len = #string.match(startline, '(%s*)$', 1)

    -- everything after the selection on the same lines as the end of the range
    local endline = string.sub(vim.fn.getline(end_row + 1), end_col + 1, -1)
    local endline_len = #endline
    local endline_whitespace_len = #string.match(endline, '^(%s*)', 1)

    local sel_mode
    if startline_whitespace_len == startline_len and endline_whitespace_len == endline_len then
        -- the text objects is the only thing on the lines in the range so we
        -- should use visual line mode
        sel_mode = 'V'
        if end_row + 1 < vim.fn.line('$') and
            start_row > 0 then
            if string.match(vim.fn.getline(end_row + 2), '^%s*$', 1) then
                -- we either have a blank line below AND above OR just below, in either case we want extend to the line below
                end_row = end_row + 1
            elseif string.match(vim.fn.getline(start_row), '^%s*$', 1) then
                -- we have a blank line above AND NOT below, we extend to the line above
                start_row = start_row - 1
            end
        end
    else
        sel_mode = 'v'
        end_col = end_col + endline_whitespace_len
        if endline_whitespace_len == 0 and startline_whitespace_len ~= startline_len then
            start_col = start_col - startline_whitespace_len
        end
    end


    return {start_row, start_col, end_row, end_col}, sel_mode
end

function M.select(query, restore_visual, sel_start, sel_end)
    local bufnr =  vim.api.nvim_get_current_buf()
    local lang = parsers.get_buf_lang(bufnr)
    if not lang then return end

    local _, sel_start_row, sel_start_col = unpack(sel_start)
    local start_max_cols = #vim.fn.getline(sel_start_row)
    -- visual line mode results in getpos("'>") returning a massive number so
    -- we have to set it to the true end col
    if start_max_cols < sel_start_col then
        sel_start_col = start_max_cols
    end
    -- tree-sitter uses zero-indexed rows
    sel_start_row = sel_start_row - 1
    -- tree-sitter uses zero-indexed cols for the start
    sel_start_col = sel_start_col - 1

    local _, sel_end_row, sel_end_col = unpack(sel_end)
    local end_max_cols = #vim.fn.getline(sel_end_row)
    -- visual line mode results in getpos("'>") returning a massive number so
    -- we have to set it to the true end col
    if end_max_cols < sel_end_col then
        sel_end_col = end_max_cols
    end
    -- tree-sitter uses zero-indexed rows
    sel_end_row = sel_end_row - 1

    local sel = {sel_start_row, sel_start_col, sel_end_row, sel_end_col}

    local best
    local matches = queries.get_capture_matches_recursively(bufnr, '@range', query)
    for _, m in pairs(matches) do
        local match_start_row, match_start_col = unpack(m.node.start_pos)
        local match_end_row, match_end_col = unpack(m.node.end_pos)
        local match = {match_start_row, match_start_col, match_end_row, match_end_col}

        -- match must cover an exclusively bigger range than the current selection
        if does_surround(match, sel) then
            if not best or does_surround(best, match) then
                best = match
            end
        end
    end

    if best then
        local new_best, sel_mode = extend_range_with_whitespace(best)
        ts_utils.update_selection(bufnr, new_best, sel_mode)
        if prev_selections[bufnr] == nil then
            prev_selections[bufnr] = {{new_best, sel_mode}}
        else
            table.insert(prev_selections[bufnr], {{new_best, sel_mode}})
        end
        -- I prefer going to start of text object while in visual mode
        vim.cmd('normal! o')
    else
        if restore_visual then
            vim.cmd('normal! gv')
        end
    end
end

function M.prev_selection()
end

function M.attach(bufnr, _)
    local buf = bufnr or vim.api.nvim_get_current_buf()
    for keymap, query in pairs(configs.get_module('textsubjects').keymaps) do
        if type(keymap) == 'string' then
            local cmd_o = string.format(':lua require("nvim-treesitter.textsubjects").select("%s", false, vim.fn.getpos("."), vim.fn.getpos("."))<cr>', query)
            vim.api.nvim_buf_set_keymap(buf, 'o', keymap, cmd_o, { silent = true, noremap = true  })
            local cmd_x = string.format(':lua require("nvim-treesitter.textsubjects").select("%s", true, vim.fn.getpos("\'<"), vim.fn.getpos("\'>"))<cr>', query)
            vim.api.nvim_buf_set_keymap(buf, 'x', keymap, cmd_x, { silent = true, noremap = true  })
        elseif type(keymap) == 'table' then
        end
    end
end

function M.detach(bufnr)
    local buf = bufnr or vim.api.nvim_get_current_buf()
    for keymap in pairs(configs.get_module('textsubjects').keymaps) do
        vim.api.nvim_buf_del_keymap(buf, 'o', keymap)
        vim.api.nvim_buf_del_keymap(buf, 'x', keymap)
    end
end

return M
