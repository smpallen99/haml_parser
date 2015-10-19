Nonterminals list elems elem key_elem doc tags tg tg_first div_attr div_attrs 
             leading_ws terms term param_list param_item pterm pterms params
             key_list key_term key_set.

Terminals '[' ']' ',' int atom key dkey tag id class tag_content ws '(' ')' '{' '}' '-' '=' quote.

Rootsymbol doc.

doc ->  tags          : 'Elixir.Helpers':render_page('$1').

tags -> tg params : 'Elixir.Helpers':gen_params('$1', '$2').
tags -> tags tg params : '$1' ++  'Elixir.Helpers':gen_params('$2', '$3').
tags -> tg_first     : '$1'.
tags -> tg            : '$1'.
tags -> div_attr div_attrs  : 'Elixir.Helpers':gen_div('$1', '$2').
tags -> tags tg   : '$1' ++ '$2'.
tags -> tg tags      : '$1' ++ '$2'.
tags -> leading_ws tags : 'Elixir.Helpers':add_indent('$1', '$2').

div_attrs -> div_attr  : '$1'.
div_attrs -> div_attr div_attrs  : '$1' ++ '$2'.

list -> '[' ']'       : [].
list -> '[' elems ']' : '$2'.

key_elem ->  elem elem       : {'$1', '$2'}.
elems -> elem                : ['$1'].
elems -> key_elem            : ['$1'].
elems -> key_elem ',' elems  : ['$1'|'$3'].
elems -> elem ',' elems      : ['$1'|'$3'].

terms -> term                : ['$1'].
terms -> term terms          : ['$1' | '$2'].

params -> '(' param_list ')' : '$2'.
params -> '{' key_list '}'      : '$2'.

key_list -> key_set           : ['$1'].
key_list -> ws key_set        : ['$2'].
key_list ->  key_set ',' key_list : ['$1'|'$3'].

key_set -> key_term  elem     : {'$1', '$2'}.

pterms -> pterm              : ['$1'].
pterms -> pterm pterms       : ['$1' | '$2'].

elem -> int                  : 'Elixir.Helpers':extract_token('$1').
elem -> atom                 : 'Elixir.Helpers':extract_token('$1').
elem -> key                  : 'Elixir.Helpers':extract_token('$1').
elem -> quote                : 'Elixir.Helpers':get_enclosed('$1').

elem -> list : '$1'.

param_list ->  param_item             : '$1'.
param_list ->  param_item param_list  : '$1' ++ '$2'.

param_item -> pterms '=' quote         : [{'$1', 'Elixir.Helpers':get_enclosed('$3')}].

tg -> tag   : 'Elixir.Helpers':gen_tag('$1').

tg_first -> id  : 'Elixir.Helpers':gen_div('$1').
tg_first -> class  : 'Elixir.Helpers':gen_div('$1').

div_attr -> id           : 'Elixir.Helpers':div_attr('$1').
div_attr -> class        : 'Elixir.Helpers':div_attr('$1').
div_attr -> tag_content  : 'Elixir.Helpers':div_attr('$1').
leading_ws -> ws         : 'Elixir.Helpers':leading_ws('$1').

term -> '-'              : '-'.
term -> ','              : ','.
term -> int              : 'Elixir.Helpers':extract_token('$1').
term -> atom             : 'Elixir.Helpers':extract_token('$1').
term -> quote            : 'Elixir.Helpers':get_enclosed('$1').
term -> ws               : 'Elixir.Helpers':extract_token('$1').

key_term -> dkey          : 'Elixir.Helpers':extract_token('$1').

pterm -> '-'              : '-'.
pterm -> ','              : ','.
pterm -> int              : 'Elixir.Helpers':extract_token('$1').
pterm -> atom             : 'Elixir.Helpers':extract_token('$1').
pterm -> key              : 'Elixir.Helpers':extract_token('$1').
pterm -> quote            : 'Elixir.Helpers':get_enclosed('$1').
pterm -> ws               : nil.


Erlang code.

