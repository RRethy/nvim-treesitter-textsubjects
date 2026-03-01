([
    (method)
    (singleton_method)
    (module)
    (class)
    (singleton_class)
] @range)

; sorbet type *annotation*
(((call method: (identifier) @range) . [(singleton_method) (method)] @range)
    (#match? @range "sig"))
