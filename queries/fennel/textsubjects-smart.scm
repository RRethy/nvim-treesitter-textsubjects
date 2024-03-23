;; Symbol
((symbol) @_start @_end
  (#make-range! "range" @_start @_end))

;; Strings
;; :abc
;;  ^^^
((string_content) @_start @_end
 (#make-range! "range" @_start @_end))
;; :abc "abc"
;; ^^^^ ^^^^^
((string) @_start @_end
 (#make-range! "range" @_start @_end))

;; Inner Seq
;; [...]
;;  ^^^
((sequence . (_) @_start @_end (_)? @_end .)
 (#make-range! "range" @_start @_end))

;; Outer Seq
;; [...]
;; ^^^^^
((sequence) @_start @_end
 (#make-range! "range" @_start @_end))

;; Assoc k-v pair
;; {... :x y ...}
;;      ^^^^
;; {... : y ...}
;;      ^^^
((table_pair) @_start @_end
  (#make-range! "range" @_start @_end))

;; Inner Assoc
;; {...}
;;  ^^^
 ((table . (_) @_start @_end (_)? @_end .)
  (#make-range! "range" @_start @_end))

;; Outer Assoc
;; {...}
;; ^^^^^
((table) @_start @_end
 (#make-range! "range" @_start @_end))

;; List arguments
;; (x ... ...)
;;    ^^^^^^^
((list (symbol) . (_) @_start @_end (_)* @_end)
 (#make-range! "range" @_start @_end))
;; (x ...)
;;  ^^^^^
((list . (_) @_start (_)* @_end)
 (#make-range! "range" @_start @_end))
;; (x ...)
;; ^^^^^^^
((list) @_start @_end
 (#make-range! "range" @_start @_end))
