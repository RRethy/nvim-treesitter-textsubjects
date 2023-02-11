([ ; '' blah ''
  (indented_string_expression)
  ; a: a + 2
  (function_expression)
  ; [ 1 2 3 ]
  (list_expression)
  ; a = {some rhs}
  (binding)
  ; { a = 2; }
  (attrset_expression)
 ] @_start @_end
 (#make-range! "range" @_start @_end)
)
