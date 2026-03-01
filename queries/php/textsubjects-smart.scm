(comment) @range

([
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

] @range)

(formal_parameters (_) @range . ","? @range)

(argument (_) @range . ","? @range)

(return_statement (_) @range)
