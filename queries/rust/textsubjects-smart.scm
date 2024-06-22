((line_comment) @_start @_end
     (#make-range! "range" @_start @_end))

((block_comment) @_start @_end
     (#make-range! "range" @_start @_end))

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (line_comment) @_start . (line_comment)+ @_end (_) @tail)
    (#not-kind-eq? @tail "line_comment")
    (#not-kind-eq? @head "line_comment")
    (#make-range! "range" @_start @_end))

(([
    (call_expression)
    (generic_function)
    (macro_invocation)
    (macro_definition)
    (function_item)
    (function_signature_item)
    (for_expression)
    (while_expression)
    (loop_expression)
    (if_expression)
    (match_expression)
    (match_arm)
    (struct_item)
    (enum_item)
    (impl_item)
] @_start @_end)
(#make-range! "range" @_start @_end))

((parameters (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))

((arguments (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))

((array_expression (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))

((return_expression (_) @_start @_end)
    (#make-range! "range" @_start @_end))
