local queries = require("nvim-treesitter.query")

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

        if queries.has_query_files(nested_lang, 'textsubjects-smart')
            or queries.has_query_files(nested_lang, 'textsubjects-container-outer')
            or queries.has_query_files(nested_lang, 'textsubjects-container-inner') then
            return true
        end
        if seen[nested_lang] then
            return false
        end
        seen[nested_lang] = true

        if queries.has_query_files(nested_lang, 'injections') then
            local query = queries.get_query(nested_lang, 'injections')
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

function M.init()
    if vim.fn.has('nvim-0.9') == 1 then
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
    else
        require "nvim-treesitter".define_modules {
            textsubjects = {
                module_path = "nvim-treesitter.textsubjects",
                enable = false,
                disable = {},
                prev_selection = nil,
                keymaps = {},
                is_supported = M.is_supported,
            }
        }
    end
end

return M
