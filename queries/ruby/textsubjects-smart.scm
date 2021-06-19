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
] @_start @_end)
(#make-range! "range" @_start @_end))

; sorbet type *annotation*
(((call method: (identifier) @_start) . (method) @_end)
    (#match? @_start "sig")
    (#make-range! "range" @_start @_end))

((return (_) @_start @_end)
    (#make-range! "range" @_start @_end))
