(class_declaration
  body: (declaration_list . "{" . (_)+ @range . "}"))

(method_declaration
  body: (compound_statement . "{" . (_)+ @range . "}"))

(function_definition
  body: (compound_statement . "{" . (_)+ @range . "}"))

(if_statement
  body: (compound_statement . "{" . (_)+ @range . "}"))

(foreach_statement
  body: (compound_statement . "{" . (_)+ @range . "}"))

(for_statement
  (compound_statement . "{" . (_)+ @range . "}"))

(while_statement
  body: (compound_statement . "{" . (_)+ @range . "}"))

(switch_statement
  body: (switch_block . "{" . (_)+ @range . "}"))

(case_statement ."case" .(_)+ @range)

(array_creation_expression . "[" . (_)+ @range . "]")

(formal_parameters . "(" . (_)+ @range . ")")

(arguments . "(" . (_)+ @range . ")")

