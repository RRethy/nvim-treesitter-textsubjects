(class_declaration
  body: (declaration_list . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "range" @_start @_end)))

(method_declaration
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "range" @_start @_end)))

(function_definition
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "range" @_start @_end)))

(if_statement
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "range" @_start @_end)))

(foreach_statement
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "range" @_start @_end)))

(for_statement
  (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "range" @_start @_end)))

(while_statement
  body: (compound_statement . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "range" @_start @_end)))

(switch_statement
  body: (switch_block . "{" . (_) @_start @_end (_)? @_end . "}"
 (#make-range! "range" @_start @_end)))

((case_statement ."case" .(_) @_start @_end (_)? @_end) (#make-range! "range" @_start @_end))

((array_creation_expression . "[" . (_) @_start @_end (_)? @_end . "]") (#make-range! "range" @_start @_end))

((formal_parameters . "(" . (_) @_start @_end (_)? @_end . ")") (#make-range! "range" @_start @_end))

((arguments . "(" . (_) @_start @_end (_)? @_end . ")") (#make-range! "range" @_start @_end))

