local Range = require('nvim-treesitter-textsubjects.range').Range
local Position = require('nvim-treesitter-textsubjects.range').Position

local M = {}

---@param name string
---@return string
local function get_full_query_name(name)
    return 'textsubjects-' .. name:gsub('^textsubjects%-', '')
end

local function is_language_supported(lang, query_names, seen)
    if not lang then
        return false
    end

    local lang_ok, _ = vim.treesitter.language.add(lang)
    if not lang_ok then
        return false
    end

    for _, query_name in ipairs(query_names) do
        if #vim.treesitter.query.get_files(lang, get_full_query_name(query_name)) > 0 then
            return true
        end
    end

    if seen[lang] then
        return false
    end
    seen[lang] = true

    local query = vim.treesitter.query.get(lang, 'injections')
    if query then
        for _, capture in ipairs(query.info.captures) do
            if capture == 'language' or is_language_supported(capture, query_names, seen) then
                return true
            end
        end

        for _, info in ipairs(query.info.patterns) do
            -- we're looking for #set injection.language <whatever>
            if info[1][1] == 'set!' and info[1][2] == 'injection.language' then
                if is_language_supported(info[1][3], query_names, seen) then
                    return true
                end
            end
        end
    end

    return false
end

---@param bufnr number
---@param query_names string[]
---@return boolean
function M.is_supported(bufnr, query_names)
    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    return lang ~= nil and is_language_supported(lang, query_names, {})
end

---@class (exact) textsubjects.Match
---@field range textsubjects.Range The primary target range
---@field extended? textsubjects.Range The optional boundary range (for gap detection)

---@param match table<integer, TSNode[]>
---@param captures string[]
---@param target_capture string
---@return textsubjects.Match?
local function match_to_obj(match, captures, target_capture)
    ---@type textsubjects.Range?
    local range
    ---@type textsubjects.Range?
    local extended_range

    for id, nodes in pairs(match) do
        local capture_name = captures[id]
        local first_node = nodes[1]
        local last_node = nodes[#nodes]

        if capture_name == target_capture then
            range = Range.from_nodes(first_node, last_node)
        elseif capture_name == target_capture .. '.extended' then
            if #nodes ~= 2 then
                error('Invalid extended capture: wrong number of nodes' .. #nodes)
            end
            extended_range = Range.from_nodes_inner(first_node, last_node)
        end
    end

    if range then
        if extended_range and range:equals(extended_range) then
            extended_range = nil
        end

        return ---@type textsubjects.Match
        {
            range = range,
            extended = extended_range,
        }
    end
end

---"Memoize" a function using hash_fn to hash the arguments.
---This caches results of a function call for given set of arguments.
---
---@generic F: function
---@param fn F
---@param hash_fn fun(...): any
---@return F
local function memoize(fn, hash_fn)
    local cache = setmetatable({}, { __mode = 'kv' }) ---@type table<any,any>

    return function(...)
        local key = hash_fn(...)
        if cache[key] == nil then
            local v = fn(...) ---@type any
            cache[key] = v ~= nil and v or vim.NIL
        end

        local v = cache[key]
        return v ~= vim.NIL and v or nil
    end
end

--- Prepare matches for given query_group and parsed tree.
--- Memoize by buffer tick and query group.
---
---@param bufnr integer the buffer
---@param query_group string the query file to use
---@param root TSNode the root node
---@param root_lang string the root node lang, if known
---@param capture_name string the target capture name
---@return textsubjects.Match[]
local get_query_matches = memoize(function(bufnr, query_group, root, root_lang, capture_name)
    local query = vim.treesitter.query.get(root_lang, query_group)
    if not query then
        return {}
    end

    local matches = {} ---@type textsubjects.Match[]
    for _, match, _ in query:iter_matches(root, bufnr) do
        local match_obj = match_to_obj(match, query.captures, capture_name)
        if match_obj then
            table.insert(matches, match_obj)
        end
    end
    return matches
end, function(bufnr, query_group, root, _, capture_name)
    return string.format('%d-%s-%s-%s', bufnr, root:id(), query_group, capture_name)
end)

---Returns list of match objects from nodes matching given capture name and query
---@param bufnr integer
---@param capture_name string
---@param query_name string
---@return textsubjects.Match[]
function M.get_matches(bufnr, capture_name, query_name)
    capture_name = capture_name:sub(2) -- drop leading '@'
    query_name = get_full_query_name(query_name)

    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    if not lang then
        return {}
    end

    local parser = vim.treesitter.get_parser(bufnr, lang, { error = false })
    if not parser then
        return {}
    end

    parser:parse(true)

    local matches = {}
    parser:for_each_tree(function(tstree, language_tree)
        vim.list_extend(
            matches,
            get_query_matches(bufnr, query_name, tstree:root(), language_tree:lang(), capture_name)
        )
    end)
    return matches
end

---Prints matches for a given query suffix for debugging
---@param query_name string
function M.print_matches(query_name)
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = Position.from_vim(vim.fn.getpos('.'))

    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
    if not lang then
        print('No treesitter support for filetype ' .. vim.bo[bufnr].filetype)
        return
    end

    query_name = query_name == '' and 'smart' or query_name
    if not M.is_supported(bufnr, { query_name }) then
        print("Query '" .. query_name .. "' does not exist for language '" .. lang .. "'")
        return
    end

    print('Cursor: ' .. cursor.row .. ', ' .. cursor.col)
    print('Query: ' .. query_name)

    local matches = M.get_matches(bufnr, '@range', query_name)
    if #matches > 0 then
        for _, m in ipairs(matches) do
            local line = '  Match: ' .. m.range:to_string()

            if m.extended then
                line = line .. ' EXT: ' .. m.extended:to_string()
            end

            -- Use the outermost range (extended if available, otherwise primary) for cursor matching
            local match_range = m.extended or m.range
            if match_range.start_pos:le(cursor) and cursor:lt(match_range.end_pos) then
                line = line .. ' *'
            end

            print(line)
        end
    else
        print('No matches')
    end
end

return M
