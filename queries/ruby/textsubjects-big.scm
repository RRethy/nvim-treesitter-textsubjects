([
    (method)
    (singleton_method)
    (module)
    (class)
] @range)

; sorbet type *annotation*
(((call method: (identifier) @range) . (method) @range)
    (#match? @range "sig"))
