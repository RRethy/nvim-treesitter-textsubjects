; {} blocks
(compound_statement "{" @range.extended (_)+ @range "}" @range.extended)
(declaration_list "{" @range.extended (_)+ @range "}" @range.extended)
(enumerator_list "{" @range.extended _+ @range "}" @range.extended)
(field_declaration_list "{" @range.extended (_)+ @range "}" @range.extended)
(initializer_list "{" @range.extended _+ @range "}" @range.extended)

; () blocks
(argument_list "(" @range.extended _+ @range ")" @range.extended)
(parameter_list "(" @range.extended _+ @range ")" @range.extended)
(decltype "(" @range.extended (_) @range ")" @range.extended)
(sizeof_expression (parenthesized_expression "(" @range.extended (_) @range ")" @range.extended)) ; sizeof(expr)
(sizeof_expression "(" @range.extended (_) @range ")" @range.extended) ; sizeof(type)
(static_assert_declaration "(" @range.extended _+ @range ")" @range.extended)
(condition_clause "(" @range.extended (_) @range ")" @range.extended)
(do_statement condition: (parenthesized_expression "(" @range.extended (_) @range ")" @range.extended))
(for_statement "(" @range.extended _+ @range ")" @range.extended . (_))
(for_range_loop "(" @range.extended _+ @range ")" @range.extended . (_))

; <> blocks
(template_argument_list "<" @range.extended _+ @range ">" @range.extended)
(template_parameter_list "<" @range.extended _+ @range ">" @range.extended)
