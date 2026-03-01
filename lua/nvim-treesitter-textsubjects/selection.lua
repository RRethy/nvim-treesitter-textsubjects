local matcher = require('nvim-treesitter-textsubjects.matcher')
local Range = require('nvim-treesitter-textsubjects.range').Range
local Position = require('nvim-treesitter-textsubjects.range').Position

local M = {}

---@class textsubjects.Selection
---@field changedtick number The buffer's changedtick when the selection was made
---@field range textsubjects.Range The actual selected range (after mode normalization and whitespace extension)
---@field raw_range textsubjects.Range The original Tree-sitter range before expansion
---@field mode string The selection mode ('v', 'V', or '<C-v>')

---@type table<number, textsubjects.Selection[]>
local prev_selections = {}

--- Returns the last selection for the given buffer if it matches the current changedtick.
--- @param bufnr number
--- @return textsubjects.Selection?
local function get_last_selection(bufnr)
    local selections = prev_selections[bufnr]
    if not selections or #selections == 0 then
        return nil
    end

    local last = selections[#selections]
    if last.changedtick ~= vim.api.nvim_buf_get_changedtick(bufnr) then
        return nil
    end

    return last
end

--- Returns a substring of a line from the current buffer.
---
--- Note on coordinates:
--- - Tree-sitter uses 0-based, end-exclusive coordinates [start, end).
--- - Vim uses 1-based row indices for functions like getline().
--- - Lua's string.sub uses 1-based, inclusive coordinates.
--- This function bridges them: vim.fn.getline(row + 1) and string.sub(start + 1, end).
---
--- @param row integer 0-based row index
--- @param start_col? integer 0-based start column (inclusive). Defaults to 0.
--- @param end_col? integer 0-based end column (exclusive). Defaults to end of line.
--- @return string slice of the line
local function get_line_slice(row, start_col, end_col)
    local line = vim.fn.getline(row + 1)
    return string.sub(line, (start_col or 0) + 1, end_col or #line)
end

--- Extends the range to select surrounding whitespace as part of the text object,
--- and provides optimal selection mode for the range.
---
--- It heuristically determines if the selection should be line-wise (V) or
--- character-wise (v). If the selection encompasses the entire content of its
--- start and end lines, it switches to line-wise mode and attempts to include a
--- surrounding blank line (preferring the one below). Otherwise, it stays in
--- character-wise mode and includes surrounding whitespace on the same lines.
---
--- @param range textsubjects.Range
--- @return textsubjects.Range, string extended updated range and selection mode
local function extend_range_with_whitespace(range)
    local config = require('nvim-treesitter-textsubjects.config').get()
    local start_row, start_col, end_row, end_col = range:unpack()

    -- everything before the selection on the same lines as the start of the range
    local startline = get_line_slice(start_row, 0, start_col)
    local startline_len = #startline
    local startline_whitespace_len = #string.match(startline, '(%s*)$', 1)

    -- everything after the selection on the same lines as the end of the range
    local endline = get_line_slice(end_row, end_col)
    local endline_len = #endline
    local endline_whitespace_len = #string.match(endline, '^(%s*)', 1)

    local sel_mode
    if startline_whitespace_len == startline_len and endline_whitespace_len == endline_len then
        -- the text objects is the only thing on the lines in the range so we
        -- should use visual line mode
        sel_mode = 'V'
        start_col = 0
        if config.greedy_whitespace then
            while end_row + 1 < vim.fn.line('$') and string.match(get_line_slice(end_row + 1), '^%s*$', 1) do
                end_row = end_row + 1
            end
            while start_row > 0 and string.match(get_line_slice(start_row - 1), '^%s*$', 1) do
                start_row = start_row - 1
            end
        else
            if end_row + 1 < vim.fn.line('$') and string.match(get_line_slice(end_row + 1), '^%s*$', 1) then
                -- we have a blank line below, we want extend to it
                end_row = end_row + 1
            elseif start_row > 0 and string.match(get_line_slice(start_row - 1), '^%s*$', 1) then
                -- we have a blank line above, we extend to it
                start_row = start_row - 1
            end
        end
        end_col = #get_line_slice(end_row)
    else
        sel_mode = 'v'
        if config.greedy_whitespace then
            start_col = start_col - startline_whitespace_len
            end_col = end_col + endline_whitespace_len
        else
            -- for non-greedy character-wise we just include immediate whitespace
            -- which is already what the original code did
            end_col = end_col + endline_whitespace_len
            start_col = start_col - startline_whitespace_len
        end
    end

    return Range.new(Position.new(start_row, start_col), Position.new(end_row, end_col)), sel_mode
end

--- Converts selection to a range, extending it as needed in case the editor
--- is in visual line mode.
--- @param start_pos textsubjects.Position
--- @param end_pos textsubjects.Position
--- @return textsubjects.Range
local function selection_to_range(start_pos, end_pos)
    -- Ensure start_pos is before end_pos
    if end_pos:lt(start_pos) then
        start_pos, end_pos = end_pos, start_pos
    else
        -- Clone to avoid mutating inputs
        start_pos = start_pos:clone()
        end_pos = end_pos:clone()
    end

    if vim.fn.visualmode() == 'V' then
        start_pos.col = 0
        end_pos.col = #get_line_slice(end_pos.row)
    elseif vim.o.selection ~= 'exclusive' then
        -- Position.from_vim subtracted 1, but for inclusive selection we want
        -- the exclusive end to be exactly the 1-based column (which is pos.col + 1).
        if end_pos.col ~= vim.v.maxcol then
            end_pos.col = end_pos.col + 1
        end
    end

    local line_len = #get_line_slice(end_pos.row)
    if end_pos.col > line_len then
        end_pos.col = line_len
    end

    return Range.new(start_pos, end_pos)
end

--- Selects the given canonical range in the buffer using the specified visual
--- mode. It handles the translation from internal coordinates to Vim's
--- inclusive/exclusive cursor positions.
--- @param range textsubjects.Range
--- @param selection_mode string
local function update_selection(range, selection_mode)
    local start_row, start_col, end_row, end_col = range:unpack()
    selection_mode = selection_mode or 'v'

    local mode = vim.api.nvim_get_mode()
    if mode.mode ~= selection_mode then
        selection_mode = vim.api.nvim_replace_termcodes(selection_mode, true, true, true)
        vim.cmd.normal({ selection_mode, bang = true })
    end

    if end_col > 0 and (selection_mode ~= 'v' or vim.o.selection ~= 'exclusive') then
        end_col = end_col - 1
    end

    -- Select from end to start so that we end up with the cursor at the
    -- beginning of selection.
    -- Note: nvim_win_set_cursor uses 1-based rows and 0-based columns.
    vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
    vim.cmd('normal! o')
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
end

--- Finds the smallest range from the query that strictly surrounds the given range.
--- @param bufnr number
--- @param query string
--- @param current_range textsubjects.Range
--- @return textsubjects.Range?
local function find_best_range(bufnr, query, current_range)
    local best
    local matches = matcher.get_matches(bufnr, '@range', query)
    for _, m in ipairs(matches) do
        ---@type textsubjects.Range?
        local target

        if m.range:strictly_surrounds(current_range) then
            -- We are inside the inner range, so it's a candidate.
            target = m.range
        elseif m.extended and m.extended:strictly_surrounds(current_range) then
            -- We are in the "gap" between the extended boundary and the primary range.
            -- Select the primary range right away, unless it is already selected.
            -- This allows "stepping out" to the next construct when triggered repeatedly.
            if not m.range:equals(current_range) then
                target = m.range
            end
        end

        if target then
            -- We want the smallest valid target.
            if not best or best:strictly_surrounds(target) then
                best = target
            end
        end
    end
    return best
end

---Attempts to select a text object for the current visual selection.
---@param query string
---@param sel_start textsubjects.Position
---@param sel_end textsubjects.Position
function M.select(query, sel_start, sel_end)
    local bufnr = vim.api.nvim_get_current_buf()
    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    if not lang then
        return
    end

    local sel = selection_to_range(sel_start, sel_end)
    local last_selection = get_last_selection(bufnr)
    local raw_sel = sel
    if last_selection and (sel:equals(last_selection.range) or sel:equals(last_selection.raw_range)) then
        raw_sel = last_selection.raw_range
    elseif sel_start:equals(sel_end) then
        -- If we are starting from a single point (no selection), we use a 0-width
        -- range for surrounding checks so that we can pick up 1-character nodes.
        raw_sel = Range.new(sel_start, sel_start)
    end

    local best = find_best_range(bufnr, query, raw_sel)

    if best then
        local new_best, sel_mode = extend_range_with_whitespace(best)
        update_selection(new_best, sel_mode)

        local last = get_last_selection(bufnr)
        if not last then
            prev_selections[bufnr] = {}
        end
        table.insert(
            prev_selections[bufnr],
            ---@type textsubjects.Selection
            {
                changedtick = vim.api.nvim_buf_get_changedtick(bufnr),
                range = new_best,
                raw_range = best,
                mode = sel_mode,
            }
        )
    end
end

---Attempts to select a previously selected object.
---@param sel_start textsubjects.Position
---@param sel_end textsubjects.Position
function M.prev_select(sel_start, sel_end)
    local bufnr = vim.api.nvim_get_current_buf()
    local sel = selection_to_range(sel_start, sel_end)

    local last = get_last_selection(bufnr)
    if last and sel:equals(last.range) then
        -- If current selection matches the last one, discard it and go
        -- to the previous one.
        table.remove(prev_selections[bufnr])
        last = get_last_selection(bufnr)
    end

    if not last then
        -- If the last selection is invalid (e.g. changedtick mismatch), the
        -- entire history for this buffer is invalid.
        prev_selections[bufnr] = nil
        return
    end

    update_selection(last.range, last.mode)
end

return M
