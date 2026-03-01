(line_comment) @range

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (line_comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "line_comment")
    (#not-kind-eq? @head "line_comment"))

([
    (function_definition)
    (struct_definition)
    (module_definition)
    (macro_definition)
    (abstract_definition)
    (while_statement)
    (for_statement)
    (if_statement)
    (try_statement)
    (do_clause)
    (matrix_expression)
    (tuple_expression)
    (vector_expression)
    (compound_statement)
    (let_statement)
] @range)

(parameter_list (_) @range . ","? @range)

(argument_list (_) @range . ","? @range)

(tuple_expression (_) @range . ","? @range)

(matrix_expression (_) @range . ","? @range)

(tuple_expression (_) @range . ","? @range)

(vector_expression (_) @range . ","? @range)

(return_statement (_) @range)
