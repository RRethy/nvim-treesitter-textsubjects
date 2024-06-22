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
    (function_declaration)
    (expression_statement)
    (lexical_declaration)
    (class_declaration)
    (method_definition)
    (for_statement)
    (for_in_statement)
    (if_statement)
    (switch_statement)
    ; typescript
    (type_alias_declaration)
    (interface_declaration)
    ; jsx
    (jsx_element)
    (jsx_self_closing_element)
    (jsx_attribute)
] @_start @_end)
(#make-range! "range" @_start @_end))

((formal_parameters (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))

((arguments (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))

((object (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))

((array (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))

((class_body (_) @_start @_end . ";"? @_end)
    (#make-range! "range" @_start @_end))

((return_statement (_) @_start @_end)
    (#make-range! "range" @_start @_end))

; typescript
((object_type (_) @_start @_end . ";"? @_end)
    (#make-range! "range" @_start @_end))
