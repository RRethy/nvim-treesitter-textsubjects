(comment) @range

; TODO This query doesn't work for comment groups at the start and end of a
; file
; See https://github.com/tree-sitter/tree-sitter/issues/1138
(((_) @head . (comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment"))

([
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
] @range)

(formal_parameters (_) @range . ","? @range)

(arguments (_) @range . ","? @range)

(object (_) @range . ","? @range)

(array (_) @range . ","? @range)

(class_body (_) @range . ";"? @range)

(return_statement (_) @range)

; typescript
(object_type (_) @range . ";"? @range)
