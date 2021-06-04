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

**TODO** finish README
