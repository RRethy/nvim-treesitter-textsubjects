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
] @_start @_end)
(#make-range! "range" @_start @_end))

((arguments (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))
