((comment) @_start @_end
     (#make-range! "range" @_start @_end))

(((_) @head . (comment) @_start . (comment)+ @_end (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment")
    (#make-range! "range" @_start @_end))

((key_value value: (_)* @_start (_)+ @_end)
    (#make-range! "range" @_start @_end))

((key_value) @_start @_end
    (#make-range! "range" @_start @_end)
)

((list item: (_)* @_start (_)+ @_end)
    (#make-range! "range" @_start @_end))

((list) @_start @_end
    (#make-range! "range" @_start @_end)
)
