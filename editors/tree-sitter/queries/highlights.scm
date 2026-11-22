(line_comment) @comment
(block_comment) @comment
(keyword) @keyword
(builtin_type) @type.builtin
(boolean) @boolean
(number) @number
(attribute) @attribute
[(string) (raw_string) (format_string)] @string
[(rune) (byte)] @string.special
(interpolation ["{" "}"] @punctuation.special)
(interpolation (identifier) @variable)
((keyword) @_decl . (identifier) @function
 (#eq? @_decl "fn"))
((keyword) @_type . (identifier) @type
 (#match? @_type "^(struct|enum|trait)$"))
((identifier) @function . (punctuation) @_paren
 (#eq? @_paren "("))
