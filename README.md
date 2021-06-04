<h1 align="center">
  <a href="https://github.com/RRethy/nvim-treesitter-textsubjects">nvim-treesitter-textsubjects</a>
</h1>

<h4 align="center">Location and syntax aware text objects which *do what you mean*</h4>

# Quick Start

```lua
require'nvim-treesitter.configs'.setup {
    textsubjects = {
        enable = true,
        keymaps = {
            ['.'] = 'textsubjects-smart',
        }
    },
}
```

This will enable the `.` text object which will select a different part of the syntax tree depending on your location in it. Whether the selection is by character or by line will also depend on your location. See below for more details on what parts of the syntax tree are matched.

# Text Subjects

## textsubjects-smart

**Supported Languages**: `Lua`, `Rust`, `Go`, `Ruby`.

**Patterns**: function calls, function definitions, class definitions, loops, if statements, return values, arguments.

See `queries/*/textsubjects-smart.scm` for full information on the query.

## Custom Query

You can create your own text subjects by creating a Tree-sitter query that has ranges named `range`. This query file name can be provided in the `keymaps` about.

Ranges can be created as follows:

```scheme
((comment) @_start @_end
     (#make-range! "range" @_start @_end))
```

# Alternatives

- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects): I use this and it's a great plugin. If you want to target the textobject exactly then this is the way to go, however, it can quickly lead to having too many text object mappings. As well, it will always deal with whitespace based on the way you invoked it rather than handling this heuristically.
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)-incremental-selection-mod: This is similar but doesn't act as a text objects, it's more strict when expanding the selection, too fined grain for my tastes, and doesn't handle whitespace around the text objects.
