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
    return config
end

return M
