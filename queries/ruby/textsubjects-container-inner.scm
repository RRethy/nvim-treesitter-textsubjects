((method name: (_) parameters: (_) . (_) @_start @_end (_)? @_end . "end") (#make-range! "range" @_start @_end))
((method name: (_) !parameters . (_) @_start @_end (_)? @_end . "end") (#make-range! "range" @_start @_end))

((singleton_method object: (_) name: (_) parameters: (_) . (_) @_start @_end (_)? @_end . "end") (#make-range! "range" @_start @_end))
((singleton_method object: (_) name: (_) !parameters . (_) @_start @_end (_)? @_end . "end") (#make-range! "range" @_start @_end))

((module name: (_) . (_) @_start @_end (_)? @_end . "end") (#make-range! "range" @_start @_end))

((class name: (_) superclass: (_) . (_) @_start @_end (_)? @_end . "end") (#make-range! "range" @_start @_end))
((class name: (_) !superclass . (_) @_start @_end (_)? @_end . "end") (#make-range! "range" @_start @_end))
