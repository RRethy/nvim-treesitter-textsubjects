((comment) @_start @_end
    (#make-range! "range" @_start @_end))

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment) @_start . (comment)+ @_end (_) @tail)
    (#not-has-type? @tail "comment")
    (#not-has-type? @head "comment")
    (#make-range! "range" @_start @_end))

(([
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
] @_start @_end)
    (#make-range! "range" @_start @_end))

; elements of delimited lists
([
    (argument_list (_) @_start @_end . ","? @_end)
    (enumerator_list (_) @_start @_end . ","? @_end)
    (field_initializer_list (_) @_start @_end . ","? @_end)
    (initializer_list (_) @_start @_end . ","? @_end)
    (parameter_list (_) @_start @_end . ","? @_end)
    (template_argument_list (_) @_start @_end . ","? @_end)
    (template_parameter_list (_) @_start @_end . ","? @_end)
] (#make-range! "range" @_start @_end))

; contents of keyword statements
([
    (return_statement (_) @_start @_end)
    (throw_statement (_) @_start @_end)
    (co_return_statement (_) @_start @_end)
    (co_yield_statement (_) @_start @_end)
    (co_await_expression (_) @_start @_end)
    (new_expression
        ; exclude placement field
        type: (_) @_start
        arguments: (_) @_end)
    (delete_expression (_) @_start @_end)
] (#make-range! "range" @_start @_end))

; the parenthesized parts of control flow statements
([
    ; if, while, switch
    (condition_clause) @_start @_end

    ; do-while
    (do_statement condition: (_) @_start @_end)

    ; for contents, initializer, condition and update
    (for_statement . "(" @_start (_)* ")" @_end . (_))
    (for_statement initializer: (_) @_start @_end . ";" @_end)
    (for_statement condition: (_) @_start @_end . ";" @_end)
    (for_statement update: (_) @_start @_end)

    ; for range contents
    (for_range_loop . "(" @_start (_)* ")" @_end . (_))
] (#make-range! "range" @_start @_end))
