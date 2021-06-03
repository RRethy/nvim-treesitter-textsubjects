local M = {}

function M.init()
    require "nvim-treesitter".define_modules {
        textsubjects = {
            module_path = "nvim-treesitter.textsubjects",
            enable = false,
            is_supported = function(lang)
                -- TODO make this closer nvim-treesitter-textobjects
                if lang == 'lua' then
                    return true
                elseif lang == 'go' then
                    return false
                else
                    return false
                end
                return false
            end
        }
    }
end

return M
