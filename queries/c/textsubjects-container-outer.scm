(([
    ; definition blocks
    (declaration)
    (function_definition)
    (field_declaration)
    (preproc_call)
    (preproc_def)
    (preproc_function_def)
    (preproc_if)
    (preproc_ifdef)
    (preproc_include)

    ; things that look like class definitions
    (enum_specifier)
    (struct_specifier)
    (union_specifier)
  ] @_start @_end)
    (#make-range! "range" @_start @_end))

