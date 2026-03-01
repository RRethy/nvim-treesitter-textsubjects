(comment) @range

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment"))

([
    ; definition blocks
    (declaration)
    (function_definition)
    (field_declaration)
    (preproc_call)
    (preproc_def)
    (preproc_function_def)
    (preproc_if)
    (preproc_ifdef)
    (preproc_include)

    ; things that look like class definitions
    (enum_specifier)
    (struct_specifier)
    (union_specifier)

    ; control flow, statements
    (do_statement)
    (expression_statement)
    (for_statement)
    (if_statement)
    (switch_statement)
    (while_statement)

    ; expressions that look like function calls
    (call_expression)
    (cast_expression)
    (sizeof_expression)

    ; {} blocks
    (compound_statement)
    (declaration_list)
    (field_declaration_list)

    ; {} blocks with delimited lists
    (enumerator_list)
    (initializer_list)

    ; delimited lists
    (argument_list)
    (parameter_list)
] @range)

; elements of delimited lists
([
    (argument_list (_) @range . ","? @range)
    (enumerator_list (_) @range . ","? @range)
    (initializer_list (_) @range . ","? @range)
    (parameter_list (_) @range . ","? @range)
])

; contents of keyword statements
(return_statement (_) @range)

; the parenthesized parts of control flow statements
([
    (do_statement condition: (_) @range)
    (if_statement condition: (_) @range)
    (switch_statement condition: (_) @range)
    (while_statement condition: (_) @range)

    ; for contents, initializer, condition and update
    (for_statement . "(" @range (_)* @range ")" @range . (_))
    (for_statement . "(" . (_) @range (_)? @range . ";" . (_))
    (for_statement condition: (_) @range . ";"? @range)
    (for_statement update: (_) @range)
])
