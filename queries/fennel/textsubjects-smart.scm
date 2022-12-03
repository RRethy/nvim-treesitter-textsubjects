; ([(symbol) (number) (string) (binding)] @_start @_end
;   (#make-range! "range" @_start @_end))

;; Inner Seq
;; [...]
;;  ^^^
((sequential_table . (_) @_start @_end (_)? @_end .)
 (#make-range! "range" @_start @_end))

;; Outer Seq
;; [...]
;; ^^^^^
((sequential_table) @_start @_end
 (#make-range! "range" @_start @_end))

;; Assoc k-v pair
;; {... :x y ...}
;;      ^^^^
;; {... : y ...}
;;      ^^^
(table [":" (string)] @_start . (_) @_end
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

;; Strings
;; :abc "abc"
;; ^^^^ ^^^^^
(((string) @_start @_end)
 (#make-range! "range" @_start @_end))

;; List arguments
;; (x ... ...)
;;    ^^^^^^^
((_ . "(" . (_) . (_) @_start @_end (_)* @_end . ")" .)
 (#make-range! "range" @_start @_end))

;; Inner List
;; (...)
;;  ^^^
((_ . "(" . _ @_start @_end _* @_end . ")" .)
 (#make-range! "range" @_start @_end))

;; Outer List
;; (...)
;; ^^^^^
((_ . "(" @_start . _+ . ")" @_end .)
 (#make-range! "range" @_start @_end))

;;; Specialised forms
;;;
;;; Specialised forms *look* like the above, but have different node names in
;;; the tree sitter AST.

;; Binding name-value pairs
;; (local {... :x y ...} ...)
;;             ^^^^
;; (local {... : y ...} ...)
;;             ^^^
(table_binding [":" (string)] @_start . [(binding) (table_binding)] @_end
  (#make-range! "range" @_start @_end))

;; (local {...} ...)
;;         ^^^
((table_binding . "{" . _ @_start @_end _? @_end . "}" .)
 (#make-range! "range" @_start @_end))

;; (local {...} ...)
;;        ^^^^^
((table_binding . "{" @_start "}" @_end .)
 (#make-range! "range" @_start @_end))

;;; let_clause
;;; First expand to the nearest binding pair, then all the bindings (inner) then
;;; all the bindings (outer)
;;; So 10 -> `x 10`, x -> `x 10` then `x 10 y 20` then `[x 10 y 20]`
;; (let [a 10 b 20] (...))
;;       ^^^^
;; (or `b 20`)
((let_clause [(binding)
              (table_binding)
              (multi_value_binding)
              (sequential_table_binding)] @_start
             . (_) @_end)
 (#make-range! "range" @_start @_end))

;; (let [a 10 b 20] (...))
;;       ^^^^^^^^^
((let_clause . "[" . _ @_start @_end _+ @_end . "]" .)
 (#make-range! "range" @_start @_end))

;; (let [a 10 b 20] (...))
;;      ^^^^^^^^^^^
((let_clause . "[" @_start _? "]" @_end .)
 (#make-range! "range" @_start @_end))

;; iterators
;; It's probably not practical to assume how these should expand, so we will
;; just expand out to the binds
;; (icollect [a 10 b 20] (...))
;;            ^^^^^^^^^
((iter_bindings) @_start @_end
 (#make-range! "range" @_start @_end))

;; (icollect [a 10 b 20] (...))
;;           ^^^^^^^^^^^
;; cant use [(icollect) ...] here
((icollect "[" @_start (iter_bindings) "]" @_end)
 (#make-range! "range" @_start @_end))
((collect "[" @_start (iter_bindings) "]" @_end)
 (#make-range! "range" @_start @_end))
((each "[" @_start (iter_bindings) "]" @_end)
 (#make-range! "range" @_start @_end))
