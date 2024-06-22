((comment) @_start @_end
    (#make-range! "range" @_start @_end))

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment) @_start . (comment)+ @_end (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment")
    (#make-range! "range" @_start @_end))

(([
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
] @_start @_end)
    (#make-range! "range" @_start @_end))

; elements of delimited lists
([
    (argument_list (_) @_start @_end . ","? @_end)
    (enumerator_list (_) @_start @_end . ","? @_end)
    (initializer_list (_) @_start @_end . ","? @_end)
    (parameter_list (_) @_start @_end . ","? @_end)
] (#make-range! "range" @_start @_end))

; contents of keyword statements
((return_statement (_) @_start @_end)
    (#make-range! "range" @_start @_end))

; the parenthesized parts of control flow statements
([
    (do_statement condition: (_) @_start @_end)
    (if_statement condition: (_) @_start @_end)
    (switch_statement condition: (_) @_start @_end)
    (while_statement condition: (_) @_start @_end)

    ; for contents, initializer, condition and update
    (for_statement . "(" @_start (_)* ")" @_end . (_))
    (for_statement . "(" . (_) @_start @_end (_)? @_end . ";" . (_))
    (for_statement condition: (_) @_start @_end . ";"? @_end)
    (for_statement update: (_) @_start @_end)
] (#make-range! "range" @_start @_end))
