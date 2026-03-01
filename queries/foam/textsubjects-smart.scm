(comment) @range

(((_) @head . (comment)+ @range (_) @tail)
    (#not-kind-eq? @tail "comment")
    (#not-kind-eq? @head "comment"))

(key_value value: (_)+ @range)

(list item: (_)+ @range)

(list) @range
