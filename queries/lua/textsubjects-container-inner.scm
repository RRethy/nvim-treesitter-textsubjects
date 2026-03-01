(function_declaration parameters: (_) @range.extended (_)+ @range "end" @range.extended)
(function_definition parameters: (_) @range.extended (_)+ @range "end" @range.extended)

(while_statement "do" @range.extended (_)+ @range "end" @range.extended)
(for_statement "do" @range.extended (_)+ @range "end" @range.extended)
(repeat_statement "repeat" @range.extended (_)+ @range "until" @range.extended)

(if_statement "then" @range.extended (_)+ @range . ["elseif" (elseif_statement) "else" (else_statement) "end"] @range.extended)
(if_statement (elseif_statement "then" @range.extended (_)+ @range) . [(elseif_statement) (else_statement) "end"] @range.extended)
(if_statement (else_statement "else" @range.extended (_)+ @range) . "end" @range.extended)

(do_statement "do" @range.extended (_)+ @range "end" @range.extended)
