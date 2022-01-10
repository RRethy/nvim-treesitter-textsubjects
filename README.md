<h1 align="center">
  <a href="https://github.com/RRethy/nvim-treesitter-textsubjects">nvim-treesitter-textsubjects</a>
</h1>

<h4 align="center">Location and syntax aware text objects which *do what you mean*</h4>

https://user-images.githubusercontent.com/21000943/148718905-afb4eed4-0adf-4dad-8f37-5179f9ddd055.mov

# Quick Start

```lua
require'nvim-treesitter.configs'.setup {
    textsubjects = {
        enable = true,
        prev_selection = ',', -- (Optional) keymap to select the previous selection
        keymaps = {
            ['.'] = 'textsubjects-smart',
            [';'] = 'textsubjects-container-outer',
        },
    },
}
```

This will enable the `.` (this is the mapping I use but `<cr>` is quite ergonomic too) and `;` text objects which will select a different part of the syntax tree depending on your location in it. See below for what each query matches.

Whether the selection is by character or by line will also depend on your location in the syntax tree (handled by a few simple heuristics). See below for more details on what parts of the syntax tree are matched.

*Note: I know these names are a bit confusing, but naming them is quite difficult.*

# Text Subjects

**Note**: I'm open to adding more queries or support for another language, just open and issue or a PR and I can work with you to get the query working.

## textsubjects-smart

**Supported Languages**: `Lua`, `Rust`, `Go`, `Ruby`, `Python`, `JavaScript / JSX`, `TypeScript / TSX`, `Elixir`, `Julia`.

**Patterns**: comments, consecutive line comments, function calls, function definitions, class definitions, loops, if statements, return values, arguments.

See `queries/*/textsubjects-smart.scm` for full information on the query.

## textsubjects-container-outer

**Supported Languages**: `Lua`, `Rust`, `Go`, `Ruby`, `Python`, `JavaScript / JSX`, `TypeScript / TSX`, `Elixir`, `Julia`.

**Patterns**: Classes, structs, functions, methods.

See `queries/*/textsubjects-container-outer.scm` for full information on the query.

## Custom Query

You can create your own text subjects by creating a Tree-sitter query that has ranges named `range`. This query file name can be provided in the `keymaps` about.

Ranges can be created as follows:

```scheme
((comment) @_start @_end
     (#make-range! "range" @_start @_end))
```

See `queries/*/textsubjects-smart.scm` for examples or open an issue if you need any help writing a query.

# Alternatives

- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects): I still use this and it's a great plugin (especially the `lookahead` feature 😉). If you want to target the textobject exactly then this plugin is the way to go. However, it can quickly lead to having too many text object mappings (I had 8 before making this plugin) and it will always deal with whitespace based on the way you invoked it rather than handling this heuristically.
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)-incremental-selection-mod: This is similar but doesn't act as a text objects. When incrementing the selection it will do so strictly by scope or by looking at the parent node which is often way too strict for practical use. For example, it will select all the arguments in `(`,`)` then can be expanded a few times to reach the next scope inside `{`,`}`, but these can both be selected more directly with `ib` and `iB` respectively so it would make more sense to skip them since the user probably doesn't want to select them. Incremental selection sounds nice but often isn't how people edit text (at least not me). On top of all this, it's strict with whitespace whereas this plugin will try to handle it heuristically.
