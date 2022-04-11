; {} blocks
([
    (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}" .)
    (declaration_list . "{" . (_) @_start @_end (_)? @_end . "}" . )
    (enumerator_list . "{" . (_) @_start @_end (_)? @_end . "}" . )
    (field_declaration_list . "{" . (_) @_start @_end (_)? @_end . "}" . )
    (initializer_list . "{" . (_) @_start @_end (_)? @_end . "}" . )
] (#make-range! "range" @_start @_end))

; () blocks
([
    (argument_list . "(" . (_) @_start @_end (_)? @_end ")" . )
    (parameter_list . "(" . (_) @_start @_end (_)? @_end ")" . )
    (decltype (_) @_start @_end)
    (sizeof_expression (parenthesized_expression (_) @_start @_end)) ; sizeof(expr)
    (sizeof_expression . "(" . (_) @_start @_end . ")" . ) ; sizeof(type)
    (static_assert_declaration . "(" . (_) @_start @_end (_)? @_end . ")" . )
    (condition_clause (_) @_start @_end)
    (do_statement condition: (parenthesized_expression (_) @_start @_end))
    (for_statement . "(" . (_) @_start @_end (_)* @_end . ")" . (_))
    (for_range_loop . "(" . (_) @_start @_end (_)* @_end . ")" . (_))
] (#make-range! "range" @_start @_end))

; <> blocks
([
    (template_argument_list . "<" . (_) @_start @_end (_)? @_end . ">" . )
    (template_parameter_list . "<" . (_) @_start @_end (_)? @_end . ">" . )
] (#make-range! "range" @_start @_end))
