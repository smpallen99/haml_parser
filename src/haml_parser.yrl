Nonterminals list elems elem key_elem doc tags tg tg_first.
Terminals '[' ']' ',' int atom key tag id class.
Rootsymbol doc.

doc ->  tags          : '$1'.


tags -> tg_first     : '$1'.
tags -> tg           : '$1'.
tags -> tg_first tags  : ['$1' | '$2'].
tags -> tg tags      : ['$1'|'$2'].

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

Erlang code.

