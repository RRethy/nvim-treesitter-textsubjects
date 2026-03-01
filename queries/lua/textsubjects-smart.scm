(comment) @range

; TODO: This query doesn't work for comment groups at the start and end of a file
;       See: https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment"))

([
    (function_call)
    (function_declaration)
    (function_definition)
    (do_statement)
    (while_statement)
    (repeat_statement)
    (if_statement)
    (for_statement)
] @range)

(parameters (_) @range . ","? @range)

(arguments (_) @range . ","? @range)

(table_constructor (_) @range . ["," ";"]? @range)

(return_statement (_) @range)
