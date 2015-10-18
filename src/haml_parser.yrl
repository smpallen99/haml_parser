Nonterminals list elems elem key_elem doc tags tg tg_first div_attr div_attrs.
Terminals '[' ']' ',' int atom key tag id class tag_content.
Rootsymbol doc.

doc ->  tags          : '$1'.


tags -> tg_first     : '$1'.
tags -> tg           : '$1'.
tags -> div_attr div_attrs  : 'Elixir.Helpers':gen_div('$1', '$2').
tags -> tg tags      : ['$1'|'$2'].

div_attrs -> div_attr  : '$1'.
div_attrs -> div_attr div_attrs  : '$1' ++ '$2'.

list -> '[' ']'       : [].
list -> '[' elems ']' : '$2'.

key_elem ->  elem elem       : {'$1', '$2'}.
elems -> elem                : ['$1'].
elems -> key_elem            : ['$1'].
elems -> key_elem ',' elems  : ['$1'|'$3'].
elems -> elem ',' elems      : ['$1'|'$3'].

elem -> int  : 'Elixir.Helpers':extract_token('$1').
elem -> atom : 'Elixir.Helpers':extract_token('$1').
elem -> key :  'Elixir.Helpers':extract_token('$1').

elem -> list : '$1'.

tg -> tag   : 'Elixir.Helpers':gen_tag('$1').

tg_first -> id  : 'Elixir.Helpers':gen_div('$1').
tg_first -> class  : 'Elixir.Helpers':gen_div('$1').

div_attr -> id     : 'Elixir.Helpers':div_attr('$1').
div_attr -> class  : 'Elixir.Helpers':div_attr('$1').
div_attr -> tag_content  : 'Elixir.Helpers':div_attr('$1').



Erlang code.

