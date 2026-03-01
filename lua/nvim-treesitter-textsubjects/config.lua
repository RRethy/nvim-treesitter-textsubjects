local M = {}

local config = {
    prev_selection = ',',
    greedy_whitespace = false,
    keymaps = {
        ['.'] = 'textsubjects-smart',
        [';'] = 'textsubjects-container-outer',
        ['i;'] = 'textsubjects-container-inner',
    },
}

---@type string[]
local configured_queries = {}

local function update_configured_queries()
    local query_names = {}
    for _, query in pairs(config.keymaps) do
        local name = type(query) == 'table' and query[1] or query
        name = name:gsub('^textsubjects%-', '')
        query_names[name] = true
    end
    configured_queries = vim.tbl_keys(query_names)
end

---@param config_overrides table
function M.set(config_overrides)
    config = vim.tbl_extend('force', config, config_overrides or {})
    update_configured_queries()
end

---@return table
function M.get()
    return config
end

---@return string[]
function M.get_configured_queries()
    return configured_queries
end

-- Initialize the cache with default values
update_configured_queries()

return M
