;; Symbol
((symbol) @_start @_end
  (#make-range! "range" @_start @_end))

;; Strings
;; :abc
;;  ^^^
((string_content) @_start @_end
 (#make-range! "range" @_start @_end))

;; Inner Seq
;; [...]
;;  ^^^
((sequence . (_) @_start @_end (_)? @_end .)
 (#make-range! "range" @_start @_end))

;; Inner Assoc
;; {...}
;;  ^^^
 ((table . (_) @_start @_end (_)? @_end .)
  (#make-range! "range" @_start @_end))

;; (x ...)
;;  ^^^^^
((list . (_) @_start (_)* @_end)
 (#make-range! "range" @_start @_end))
