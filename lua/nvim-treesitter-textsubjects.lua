local queries = require("nvim-treesitter.query")

local M = {}

function M.init()
    require "nvim-treesitter".define_modules {
        textsubjects = {
            module_path = "nvim-treesitter.textsubjects",
            enable = false,
            disable = {},
            prev_selection = nil,
            keymaps = {},
            is_supported = function(lang)
                return queries.has_query_files(lang, 'textsubjects')
            end,
        }
    }
end

return M
