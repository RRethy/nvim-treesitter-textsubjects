local M = {}

function M.configure(config_overrides)
    require('textsubjects.config').set(config_overrides)
end

function M.is_supported(lang)
    local seen = {}
    local function has_nested_textsubjects_language(nested_lang)
        if not nested_lang then
            return false
        end

        -- Officially documented way to check for parser availability
        if not vim.treesitter.language.add(nested_lang) then
            return false
        end

        if vim.treesitter.query.get(nested_lang, 'textsubjects-smart')
            or vim.treesitter.query.get(nested_lang, 'textsubjects-container-outer')
            or vim.treesitter.query.get(nested_lang, 'textsubjects-container-inner') then
            return true
        end
        if seen[nested_lang] then
            return false
        end
        seen[nested_lang] = true

        local query = vim.treesitter.query.get(nested_lang, 'injections')
        if query then
            for _, capture in ipairs(query.info.captures) do
                if capture == 'language' or has_nested_textsubjects_language(capture) then
                    return true
                end
            end

            for _, info in ipairs(query.info.patterns) do
                -- we're looking for #set injection.language <whatever>
                if info[1][1] == "set!" and info[1][2] == "injection.language" then
                    if has_nested_textsubjects_language(info[1][3]) then
                        return true
                    end
                end
            end
        end

        return false
    end

    return has_nested_textsubjects_language(lang)
end

---@param match table<integer, TSNode[]>
---@param source integer|string
---@param predicate any[]
---@param metadata vim.treesitter.query.TSMetadata
local function make_range_handler(match, _, source, predicate, metadata)
    if #predicate ~= 4 then
        print("make-range directive requires exactly three arguments, got" .. #predicate - 1)
        return
    end

    local name, start, end_ = predicate[2], predicate[3], predicate[4]
    if type(name) ~= "string" then
        print("make-range directive first argument must be a string, defining the range's name")
        return
    end

    if type(start) ~= "number" or type(end_) ~= "number" then
        print("make-range directive second and third arguments must be captures, defining the range's start and end")
        return
    end

    -- LuaLS does not understand the type() above guarantees these are numbers
    ---@type number, number
    local start_capture, end_capture = start, end_

    ---@type number?, number?, number?
    local start_row, start_col, start_bytes = nil, nil, nil
    for _, node in ipairs(match[start]) do
        local range = vim.treesitter.get_range(node, source, metadata[start_capture])
        local row, col, bytes = range[1], range[2], range[3]
        if not start_row or row < start_row or (row == start_row and col < start_col) then
            start_row, start_col, start_bytes = row, col, bytes
        end
    end


    ---@type number?, number?, number?
    local end_row, end_col, end_bytes = nil, nil, nil
    for _, node in ipairs(match[end_capture]) do
        local range = vim.treesitter.get_range(node, source, metadata[end_capture])
        local row, col, bytes = range[4], range[5], range[6]
        if not end_row or row > end_row or (row == end_row and col > end_col) then
            end_row, end_col, end_bytes = row, col, bytes
        end
    end

    metadata.ranges = metadata.ranges or {}
    metadata.ranges[name] = metadata.ranges[name] or {}
    table.insert(metadata.ranges[name], {
        start_row, start_col, start_bytes,
        end_row, end_col, end_bytes,
    })
end

function M.init()
    vim.treesitter.query.add_directive("make-range!", make_range_handler, {
        force = true,
        all = true,
    })

    vim.api.nvim_create_autocmd({ 'FileType' }, {
        callback = function(details)
            require('nvim-treesitter.textsubjects').detach(details.buf)

            local lang = vim.treesitter.language.get_lang(details.match)
            if not M.is_supported(lang) then
                return
            end

            require('nvim-treesitter.textsubjects').attach(details.buf)
        end,
    })
    vim.api.nvim_create_autocmd({ 'BufUnload' }, {
        callback = function(details)
            require('nvim-treesitter.textsubjects').detach(details.buf)
        end,
    })
end

return M
