(comment) @range

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment"))

([
    (call_expression)
    (function_declaration)
    (method_declaration)
    (func_literal)
    (for_statement)
    (if_statement)
    (expression_switch_statement)
] @range)

(parameter_list (_) @range . ","? @range)

(argument_list (_) @range . ","? @range)

(literal_value (_) @range . ","? @range)

(return_statement (_) @range)

(import_declaration) @range
