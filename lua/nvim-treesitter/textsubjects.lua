local config = require('textsubjects.config')

local M = {}
-- array of { changedtick = number, selection: number, mode: string }
-- TODO: we could use extmarks with each selection to avoid using buf
-- changedtick, it would be a lot smarter and more accurate, but it'd be pretty
-- hard to implement
local prev_selections = {}

--- @return boolean: true iff the range @a is equal to the range @b
local function is_equal(a, b)
    return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
end

--- @return boolean: true iff the range @a strictly surrounds the range @b. @a == @b => false.
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
                end_col = math.max(#vim.fn.getline(end_row + 2), 1)
                end_row = end_row + 1
            elseif string.match(vim.fn.getline(start_row), '^%s*$', 1) then
                -- we have a blank line above AND NOT below, we extend to the line above
                start_col = math.max(#vim.fn.getline(start_row), 1)
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


    return { start_row, start_col, end_row, end_col }, sel_mode
end

local function normalize_selection(sel_start, sel_end)
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

    return { sel_start_row, sel_start_col, sel_end_row, sel_end_col }
end

-- Helper function to update selection (replacement for ts_utils.update_selection)
local function update_selection(bufnr, range, mode)
    local start_row, start_col, end_row, end_col = unpack(range)

    -- Convert to 1-indexed for vim
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })

    if mode == 'V' then
        vim.cmd('normal! V')
        vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
    else
        vim.cmd('normal! v')
        vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
    end
end

-- Extract a tree-sitter node from either userdata or table wrapper
local function extract_node(node_or_table)
    if type(node_or_table) == "userdata" then
        return node_or_table
    elseif type(node_or_table) == "table" and node_or_table[1] and type(node_or_table[1]) == "userdata" then
        return node_or_table[1]
    end
    return nil
end

-- Helper function to process make-range! directives and get captures
local function get_capture_matches_recursively(bufnr, capture_name, query_name)
    local matches = {}

    -- Strip @ from capture name
    local strip_capture = capture_name:sub(2)

    local function process_language(lang, tree, root)
        local ok, query = pcall(vim.treesitter.query.get, lang, query_name)
        if not ok or not query then
            return
        end

        -- Iterate over matches
        for pattern, match, metadata in query:iter_matches(root, bufnr) do
            local prepared_match = {}

            -- Get all captures from the match
            for id, node in pairs(match) do
                local name = query.captures[id]
                if name then
                    prepared_match[name] = node
                end
            end

            -- Process make-range! directives from the query patterns
            -- This creates virtual "range" captures from @_start and @_end captures
            local preds = query.info.patterns[pattern]
            if preds then
                for _, pred in ipairs(preds) do
                    if pred[1] == "make-range!" and #pred >= 4 then
                        local range_name = pred[2]
                        -- pred[3] and pred[4] are capture IDs (numbers)
                        local start_capture_id = pred[3]
                        local end_capture_id = pred[4]

                        -- Look up the nodes from the match table
                        local start_node = extract_node(match[start_capture_id])
                        local end_node = extract_node(match[end_capture_id])

                        if start_node and end_node then
                            local start_row, start_col = start_node:start()
                            local end_row, end_col = end_node:end_()

                            -- Add this as a new capture in prepared_match
                            -- This mimics the old TSRange behavior
                            prepared_match[range_name] = {
                                start_pos = { start_row, start_col },
                                end_pos = { end_row, end_col }
                            }
                        end
                    end
                end
            end

            -- If this match has the capture we're looking for, add it to matches
            -- The make-range! directive should have created a "range" capture
            if prepared_match[strip_capture] then
                local node_or_range = prepared_match[strip_capture]
                table.insert(matches, {
                    node = node_or_range
                })
            end
        end
    end

    -- Get the parser
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok then
        return matches
    end

    -- Process all language trees
    parser:for_each_tree(function(tree, lang_tree)
        local lang = lang_tree:lang()
        local root = tree:root()
        process_language(lang, tree, root)
    end)

    return matches
end

function M.select(query, restore_visual, sel_start, sel_end)
    local bufnr = vim.api.nvim_get_current_buf()

    -- Get language using native API
    local lang = vim.bo[bufnr].filetype
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if ok and parser then
        lang = parser:lang() or lang
    end
    if not lang then return end

    local sel = normalize_selection(sel_start, sel_end)
    local best
    local matches = get_capture_matches_recursively(bufnr, '@range', query)
    for _, m in pairs(matches) do
        local match_start_row, match_start_col, match_end_row, match_end_col

        -- Handle both regular nodes and virtual range objects
        if m.node.start_pos and m.node.end_pos then
            -- Virtual range object created by make-range!
            match_start_row, match_start_col = unpack(m.node.start_pos)
            match_end_row, match_end_col = unpack(m.node.end_pos)
        elseif type(m.node) == "userdata" then
            -- Regular tree-sitter node
            match_start_row, match_start_col = m.node:start()
            match_end_row, match_end_col = m.node:end_()
        else
            -- Unknown type, skip
            goto continue
        end

        local match = { match_start_row, match_start_col, match_end_row, match_end_col }

        -- match must cover an exclusively bigger range than the current selection
        if does_surround(match, sel) then
            if not best or does_surround(best, match) then
                best = match
            end
        end

        ::continue::
    end

    if best then
        local new_best, sel_mode = extend_range_with_whitespace(best)
        update_selection(bufnr, new_best, sel_mode)
        local selections = prev_selections[bufnr]
        if selections == nil or not does_surround(new_best, selections[#selections][1]) then
            prev_selections[bufnr] = {
                {
                    changedtick = vim.api.nvim_buf_get_changedtick(bufnr),
                    new_best,
                    sel_mode
                }
            }
        else
            table.insert(selections, {
                changedtick = vim.api.nvim_buf_get_changedtick(bufnr),
                new_best,
                sel_mode
            })
        end
        -- I prefer going to start of text object while in visual mode
        vim.cmd('normal! o')
    else
        if restore_visual then
            vim.cmd('normal! gv')
        end
    end
end

function M.prev_select(sel_start, sel_end)
    local bufnr = vim.api.nvim_get_current_buf()
    local selections = prev_selections[bufnr]
    local sel = normalize_selection(sel_start, sel_end)
    if #vim.fn.getline(sel[1] + 1) == 0 then sel[2] = 1 end
    if #vim.fn.getline(sel[3] + 1) == 0 then sel[4] = 1 end
    local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)

    -- TODO: this could use extmarks
    -- We are removing any previous selections which have a different
    -- changedtick because that means the text is *probably* different and the
    -- selection range *may* now be invalid
    while selections ~= nil and selections[#selections].changedtick ~= changedtick do
        table.remove(selections)
        if #selections == 0 then
            selections = nil
        end
    end

    if selections == nil then
        prev_selections[bufnr] = nil
        vim.cmd("normal! v")
        return
    end

    local head = selections[#selections][1]
    if is_equal(sel, head) or does_surround(sel, head) then
        table.remove(selections)
        if #selections == 0 then
            prev_selections[bufnr] = nil
            vim.cmd("normal! v")
            return
        end
    end

    local new_sel, sel_mode = unpack(selections[#selections])
    update_selection(bufnr, new_sel, sel_mode)
    vim.cmd('normal! o')
end

function M.attach(bufnr, _)
    local buf = bufnr or vim.api.nvim_get_current_buf()
    for keymap, query in pairs(config.get().keymaps) do
        local query_name, desc
        if type(query) == 'table' then
            query_name = query[1]
            desc = query['desc']
        else
            query_name = query
        end

        local cmd_o = string.format(
            ':lua require("nvim-treesitter.textsubjects").select("%s", false, vim.fn.getpos("."), vim.fn.getpos("."))<cr>',
            query_name)
        vim.api.nvim_buf_set_keymap(buf, 'o', keymap, cmd_o, { silent = true, noremap = true, desc = desc })
        local cmd_x = string.format(
            ':lua require("nvim-treesitter.textsubjects").select("%s", true, vim.fn.getpos("\'<"), vim.fn.getpos("\'>"))<cr>',
            query_name)
        vim.api.nvim_buf_set_keymap(buf, 'x', keymap, cmd_x, { silent = true, noremap = true, desc = desc })
    end

    local prev_selection = config.get().prev_selection
    if prev_selection ~= nil and #prev_selection > 0 then
        local cmd_o =
        ':lua require("nvim-treesitter.textsubjects").prev_select(vim.fn.getpos("."), vim.fn.getpos("."))<cr>'
        vim.api.nvim_buf_set_keymap(buf, 'o', prev_selection, cmd_o,
            { silent = true, noremap = true, desc = 'Previous textsubjects selection' })
        local cmd_x =
        ':lua require("nvim-treesitter.textsubjects").prev_select(vim.fn.getpos("\'<"), vim.fn.getpos("\'>"))<cr>'
        vim.api.nvim_buf_set_keymap(buf, 'x', prev_selection, cmd_x,
            { silent = true, noremap = true, desc = 'Previous textsubjects selection' })
    end
end

function M.detach(bufnr)
    -- we wrap this because nvim_buf_del_keymap can error if we haven't yet created the keymaps
    -- it's a big tedious to check for each keymap so we just wrap it in a pcall
    pcall(function()
        local buf = bufnr or vim.api.nvim_get_current_buf()
        for keymap, _ in pairs(config.get().keymaps) do
            vim.api.nvim_buf_del_keymap(buf, 'o', keymap)
            vim.api.nvim_buf_del_keymap(buf, 'x', keymap)
        end

        local prev_selection = config.get().prev_selection
        if prev_selection ~= nil and #prev_selection > 0 then
            vim.api.nvim_buf_del_keymap(buf, 'o', prev_selection)
            vim.api.nvim_buf_del_keymap(buf, 'x', prev_selection)
        end
    end)
end

return M