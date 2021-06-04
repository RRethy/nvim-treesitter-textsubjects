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

This will enable the `.` text object which will select a different part of the
syntax tree depending on your location in it. Whether the selection is by
character or by line will also depend on your location. See below for more
details on what parts of the syntax tree are matched.

# Text Subjects

## textsubjects-smart

**Supported Languages**: `Lua`, `Rust`, `Go`, `Ruby`.

**Patterns**: function calls, function definitions, class definitions, loops, if statements, return values, arguments.

See `queries/*/textsubjects-smart.scm` for full information on the query.

## Custom Query
