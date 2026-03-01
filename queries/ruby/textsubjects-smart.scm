(comment) @range

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment"))

([
    (method)
    (call)
    (module)
    (class)
    (block)
    (do_block)
    (if)
    (unless)
    (for)
    (until)
    (while)
] @range)

; sorbet type *annotation*
(((call method: (identifier) @range) . (method) @range)
    (#match? @range "sig"))

(return (_) @range)
