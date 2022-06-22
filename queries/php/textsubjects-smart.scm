((comment) @_start @_end
     (#make-range! "range" @_start @_end))

(([
    (expression_statement)
    (function_definition)
    (method_declaration)
    (class_declaration)
    (for_statement)
    (foreach_statement)
    (if_statement)
    (property_declaration)
    (switch_statement)
    (while_statement)
    (case_statement)

] @_start @_end)
(#make-range! "range" @_start @_end))

((formal_parameters (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))

((argument (_) @_start @_end . ","? @_end)
    (#make-range! "range" @_start @_end))

((return_statement (_) @_start @_end)
    (#make-range! "range" @_start @_end))
