;; Symbol
(symbol) @range

;; Strings
;; :abc
;;  ^^^
(string_content) @range
;; :abc "abc"
;; ^^^^ ^^^^^
(string) @range

;; Inner Seq
;; [...]
;;  ^^^
(sequence . (_)+ @range .)

;; Outer Seq
;; [...]
;; ^^^^^
(sequence) @range

;; Assoc k-v pair
;; {... :x y ...}
;;      ^^^^
;; {... : y ...}
;;      ^^^
(table_pair) @range

;; Inner Assoc
;; {...}
;;  ^^^
(table . (_)+ @range .)

;; Outer Assoc
;; {...}
;; ^^^^^
(table) @range

;; List arguments
;; (x ... ...)
;;    ^^^^^^^
(list (symbol) . (_)+ @range)
;; (x ...)
;;  ^^^^^
(list . (_)+ @range)
;; (x ...)
;; ^^^^^^^
(list) @range
