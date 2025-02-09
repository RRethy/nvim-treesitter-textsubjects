local M = {}

local config = {
    prev_selection = ',',
    keymaps = {
        ['.'] = 'textsubjects-smart',
        [';'] = 'textsubjects-container-outer',
        ['i;'] = 'textsubjects-container-inner',
    },
}

function M.set(config_overrides)
    config = vim.tbl_extend('force', config, config_overrides or {})
end

function M.get()
    local ok, configs = pcall(require, 'nvim-treesitter.configs')
    if not ok then
        return config
    end

    local ts_config = configs.get_module('textsubjects')
    if ts_config then
        return ts_config
    end

    return config
end

return M
