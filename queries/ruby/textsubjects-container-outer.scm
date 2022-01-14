(([
    (method)
    (singleton_method)
    (module)
    (class)
    (singleton_class)
] @_start @_end)
(#make-range! "range" @_start @_end))

; sorbet type *annotation*
(((call method: (identifier) @_start) . (method) @_end)
    (#match? @_start "sig")
    (#make-range! "range" @_start @_end))
