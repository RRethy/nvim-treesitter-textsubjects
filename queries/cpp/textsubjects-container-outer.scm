(([
    ; definition blocks
    (alias_declaration)
    (concept_definition)
    (declaration)
    (field_declaration)
    (function_definition)
    (lambda_expression)
    (linkage_specification)
    (namespace_alias_definition)
    (namespace_definition)
    (preproc_call)
    (preproc_def)
    (preproc_function_def)
    (preproc_if)
    (preproc_ifdef)
    (preproc_include)
    (template_declaration)
    (template_instantiation)
    (using_declaration)

    ; things that look like class definitions
    (class_specifier)
    (enum_specifier)
    (struct_specifier)
    (union_specifier)
  ] @_start @_end)
    (#make-range! "range" @_start @_end))
