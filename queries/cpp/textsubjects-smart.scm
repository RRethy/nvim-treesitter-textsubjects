(comment) @range

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment"))

([
    ; definition blocks
    (alias_declaration)
    (concept_definition)
    (declaration)
    (field_declaration)
    (function_definition)
    (lambda_expression)
    (linkage_specification)
    (namespace_alias_definition)
    (namespace_definition)
    (preproc_call)
    (preproc_def)
    (preproc_function_def)
    (preproc_if)
    (preproc_ifdef)
    (preproc_include)
    (template_declaration)
    (template_instantiation)
    (using_declaration)

    ; things that look like class definitions
    (class_specifier)
    (enum_specifier)
    (struct_specifier)
    (union_specifier)

    ; control flow statements and statements
    (catch_clause)
    (do_statement)
    (expression_statement)
    (for_range_loop)
    (for_statement)
    (if_statement)
    (switch_statement)
    (try_statement)
    (while_statement)

    ; expressions that look like function calls
    (call_expression)
    (cast_expression)
    (decltype)
    (sizeof_expression)
    (static_assert_declaration)

    ; {} blocks
    (compound_statement)
    (declaration_list)
    (field_declaration_list)

    ; {} blocks with delimited lists
    (enumerator_list)
    (initializer_list)

    ; delimited lists
    (argument_list)
    (field_initializer_list)
    (parameter_list)
    (template_argument_list)
    (template_parameter_list)
] @range)

; elements of delimited lists
([
    (argument_list (_) @range . ","? @range)
    (enumerator_list (_) @range . ","? @range)
    (field_initializer_list (_) @range . ","? @range)
    (initializer_list (_) @range . ","? @range)
    (parameter_list (_) @range . ","? @range)
    (template_argument_list (_) @range . ","? @range)
    (template_parameter_list (_) @range . ","? @range)
])

; contents of keyword statements
([
    (return_statement (_) @range)
    (throw_statement (_) @range)
    (co_return_statement (_) @range)
    (co_yield_statement (_) @range)
    (co_await_expression (_) @range)
    (new_expression
        ; exclude placement field
        type: (_) @range
        arguments: (_) @range)
    (delete_expression (_) @range)
])

; the parenthesized parts of control flow statements
([
    ; if, while, switch
    (condition_clause) @range

    ; do-while
    (do_statement condition: (_) @range)

    ; for contents, initializer, condition and update
    (for_statement . "(" @range (_)* @range ")" @range . (_))
    (for_statement initializer: (_) @range . ";" @range)
    (for_statement condition: (_) @range . ";" @range)
    (for_statement update: (_) @range)

    ; for range contents
    (for_range_loop . "(" @range (_)* @range ")" @range . (_))
])
