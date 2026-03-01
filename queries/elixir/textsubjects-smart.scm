(comment) @range

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment"))

([
    (call)
    (anonymous_function)
    (stab_clause)
    (map)
    (list)
    (tuple)
    (struct)
    (unary_operator operator: "@")
    (binary_operator operator: "=>")
    (binary_operator operator: "|>")
    (binary_operator operator: "<-")
] @range)

(arguments (_) @range . ","? @range)
