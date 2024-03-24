;; :abc "abc"
;; ^^^^ ^^^^^
((string) @_start @_end
 (#make-range! "range" @_start @_end))

;; [...]
;; ^^^^^
((sequence) @_start @_end
 (#make-range! "range" @_start @_end))

;; {...}
;; ^^^^^
((table) @_start @_end
 (#make-range! "range" @_start @_end))

;; (x ...)
;; ^^^^^^^
((list) @_start @_end
 (#make-range! "range" @_start @_end))
