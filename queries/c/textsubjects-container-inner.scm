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
    (argument_list . "(" . (_) @_start @_end (_)? @_end . ")" . )
    (parameter_list . "(" . (_) @_start @_end (_)? @_end . ")" . )
    (sizeof_expression (parenthesized_expression (_) @_start @_end)) ; sizeof(expr)
    (sizeof_expression . "(" . (_) @_start @_end . ")" . ) ; sizeof(type)
    (do_statement condition: (parenthesized_expression (_) @_start @_end))
    (if_statement condition: (parenthesized_expression (_) @_start @_end))
    (switch_statement condition: (parenthesized_expression (_) @_start @_end))
    (while_statement condition: (parenthesized_expression (_) @_start @_end))
    (for_statement . "(" . (_) @_start @_end (_)? @_end . ")" . (_))
] (#make-range! "range" @_start @_end))

