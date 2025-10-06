local M = {}

-- Register make-range! as a NO-OP directive to prevent Neovim from throwing errors
-- We handle the logic manually in our query processing
-- This must happen when the module loads, not when configure() is called
pcall(function()
    vim.treesitter.query.add_directive("make-range!", function() end, { force = true })
end)

function M.configure(config_overrides)
    require('textsubjects.config').set(config_overrides)
end

-- Helper function to check if a query file exists
local function has_query_file(lang, query_name)
    local runtime_paths = vim.api.nvim_get_runtime_file(
        string.format('queries/%s/%s.scm', lang, query_name),
        false
    )
    return #runtime_paths > 0
end

function M.is_supported(lang)
    local seen = {}
    local function has_nested_textsubjects_language(nested_lang)
        if not nested_lang then
            return false
        end

        -- Use native vim.treesitter API to check for parser
        local ok = pcall(vim.treesitter.get_parser, 0, nested_lang)
        if not ok then
            return false
        end

        if has_query_file(nested_lang, 'textsubjects-smart')
            or has_query_file(nested_lang, 'textsubjects-container-outer')
            or has_query_file(nested_lang, 'textsubjects-container-inner') then
            return true
        end
        if seen[nested_lang] then
            return false
        end
        seen[nested_lang] = true

        if has_query_file(nested_lang, 'injections') then
            -- Use native vim.treesitter.query.get() instead
            local ok, query = pcall(vim.treesitter.query.get, nested_lang, 'injections')
            if ok and query then
                -- Parse the query captures
                for id, name in pairs(query.captures or {}) do
                    if name == 'language' or has_nested_textsubjects_language(name) then
                        return true
                    end
                end

                -- Check for injection.language patterns
                -- Note: Direct pattern inspection is more complex with the new API
                -- For now, we'll assume injections exist if the query exists
                return true
            end
        end

        return false
    end

    return has_nested_textsubjects_language(lang)
end

function M.init()
    -- nvim-treesitter main branch requires Neovim 0.9+
    -- The old define_modules system has been removed
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
