;; Outer Seq
;; [...]
;; ^^^^^
((sequential_table) @_start @_end
 (#make-range! "range" @_start @_end))

;; Outer Assoc
;; {...}
;; ^^^^^
((table) @_start @_end
 (#make-range! "range" @_start @_end))

;; Outer List
;; (...)
;; ^^^^^
((_ . "(" @_start . _+ . ")" @_end .)
 (#make-range! "range" @_start @_end))

;; (local {...} ...)
;;        ^^^^^
((table_binding . "{" @_start "}" @_end .)
 (#make-range! "range" @_start @_end))

;; (let [a 10 b 20] (...))
;;      ^^^^^^^^^^^
((let_clause . "[" @_start _? "]" @_end .)
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
