(([
   (paragraph)
   (fenced_code_block)
   (list_item)
   (list)
   (atx_heading)
] @_start @_end)
(#make-range! "range" @_start @_end))

; Basic paragraph selection
((paragraph) @_start @_end
    (#make-range! "range" @_start @_end))

; Code blocks
((fenced_code_block) @_start @_end
    (#make-range! "range" @_start @_end))

; Individual list items
((list_item) @_start @_end
    (#make-range! "range" @_start @_end))

; Entire lists (containing multiple items)
((list) @_start @_end
    (#make-range! "range" @_start @_end))

; Headers
((atx_heading) @_start @_end
    (#make-range! "range" @_start @_end))
