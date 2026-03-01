;; Symbol
(symbol) @range

;; Strings
;; :abc
;;  ^^^
(string_content) @range

;; Inner Seq
;; [...]
;;  ^^^
(sequence . (_)+ @range)

;; Inner Assoc
;; {...}
;;  ^^^
(table . (_)+ @range)

;; (x ...)
;;  ^^^^^
(list . (_)+ @range)
