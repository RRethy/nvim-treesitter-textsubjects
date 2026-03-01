(comment) @range

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment"))

([
    (function_definition)
    (class_definition)
    (while_statement)
    (for_statement)
    (if_statement)
    (with_statement)
    (try_statement)
] @range)

(parameters (_) @range . ","? @range)

(argument_list (_) @range . ","? @range)

(tuple (_) @range . ","? @range)

(list (_) @range . ","? @range)

(set (_) @range . ","? @range)

(dictionary (_) @range . ","? @range)

(return_statement (_) @range)
