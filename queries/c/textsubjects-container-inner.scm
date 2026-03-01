; {} blocks
(compound_statement "{" @range.extended (_)+ @range "}" @range.extended)
(declaration_list "{" @range.extended (_)+ @range "}" @range.extended)
(enumerator_list "{" @range.extended _+ @range "}" @range.extended)
(field_declaration_list "{" @range.extended (_)+ @range "}" @range.extended)
(initializer_list "{" @range.extended . _+ @range . "}" @range.extended)

; () blocks
(argument_list "(" @range.extended _+ @range ")" @range.extended)
(parameter_list "(" @range.extended _+ @range ")" @range.extended)

(sizeof_expression (parenthesized_expression "(" @range.extended (_) @range ")" @range.extended)) ; sizeof(expr)
(sizeof_expression "(" @range.extended (_) @range ")" @range.extended) ; sizeof(type)

(do_statement condition: (parenthesized_expression "(" @range.extended _+ @range ")" @range.extended))
(if_statement condition: (parenthesized_expression "(" @range.extended _+ @range ")" @range.extended))
(switch_statement condition: (parenthesized_expression "(" @range.extended _+ @range ")" @range.extended))
(while_statement condition: (parenthesized_expression "(" @range.extended _+ @range ")" @range.extended))

(for_statement "(" @range.extended _+ @range ")" @range.extended . (_))
