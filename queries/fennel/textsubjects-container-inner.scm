; ([(symbol) (number) (string) (binding)] @_start @_end
;   (#make-range! "range" @_start @_end))

;; Inner Seq
;; [...]
;;  ^^^
((sequential_table . (_) @_start @_end (_)? @_end .)
 (#make-range! "range" @_start @_end))

;; Inner Assoc
;; {...}
;;  ^^^
((table . (_) @_start @_end (_)? @_end .)
 (#make-range! "range" @_start @_end))

;; Inner List
;; (...)
;;  ^^^
((_ . "(" . _ @_start @_end _* @_end . ")" .)
 (#make-range! "range" @_start @_end))

;; (local {...} ...)
;;         ^^^
((table_binding . "{" . _ @_start @_end _? @_end . "}" .)
 (#make-range! "range" @_start @_end))

;; (let [a 10 b 20] (...))
;;       ^^^^^^^^^
((let_clause . "[" . _ @_start @_end _+ @_end . "]" .)
 (#make-range! "range" @_start @_end))

;; iterators
;; It's probably not practical to assume how these should expand, so we will
;; just expand out to the binds
;; (icollect [a 10 b 20] (...))
;;            ^^^^^^^^^
((iter_bindings) @_start @_end
 (#make-range! "range" @_start @_end))
