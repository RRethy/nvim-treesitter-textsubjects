(line_comment) @range

(block_comment) @range

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (line_comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "line_comment")
    (#not-kind-eq? @head "line_comment"))

([
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
] @range)

(parameters (_) @range . ","?)

(arguments (_) @range . ","?)

(array_expression (_) @range . ","?)

(return_expression (_) @range)
