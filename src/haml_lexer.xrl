Definitions.

INT        = [0-9]+
L          = [a-z]
U          = [A-Z]
A          = ({U}|{L}|{INT}|_)
ATOM       = :{A}
WS         = [\s\t]
TAG        = [0-9a-zA-Z_\-]+
NL         = [\r\n]

Rules.

{INT}         : {token, {int,  TokenLine, list_to_integer(TokenChars)}}.
{ATOM}        : {token, {atom, TokenLine, to_atom(TokenChars)}}.
[a-z_]+:      : {token, {key,  TokenLine, list_to_atom(lists:sublist(TokenChars, 1, TokenLen - 1))}}.
"[^"]*?"         : {token, {quote, TokenLine, TokenChars}}.
'.*?'         : {token, {squote, TokenLine, TokenChars}}.
\[            : {token, {'[',  TokenLine}}.
\]            : {token, {']',  TokenLine}}.
\(            : {token, {'(',  TokenLine}}.
\)            : {token, {')',  TokenLine}}.
\{            : {token, {'{',  TokenLine}}.
\}            : {token, {'}',  TokenLine}}.
,             : {token, {',',  TokenLine}}.
\.            : {token, {'.',  TokenLine}}.
-             : {token, {'-',  TokenLine}}.
_             : {token, {'_',  TokenLine}}.
=             : {token, {'=',  TokenLine}}.
{WS}*         : {token, {ws, TokenLine, TokenChars}}.
\.{TAG}{WS}.* : [Tag, Content] = 'Elixir.Helpers':extract_first(TokenChars),
                  {token, {tag_content, TokenLine, Content}, Tag}.
\.{TAG}       : {token, {class, TokenLine, lstrip(TokenChars)}}.
#{TAG}        : {token, {id, TokenLine, lstrip(TokenChars)}}.
\%{TAG}       : {token, {tag, TokenLine, lstrip(TokenChars)}}.
{L}{A}*       : Atom = list_to_atom(TokenChars),
                {token,case reserved_word(Atom) of
                     true -> {Atom,TokenLine};
                     false -> {atom,TokenLine,Atom}
                end}.

->            : {token,{'->',TokenLine}}.
<-            : {token,{'<-',TokenLine}}.
{NL}          : {end_token, {nl, TokenLine}}.


Erlang code.

to_atom(Atom) ->
    'Elixir.Helpers':to_atom(Atom).
lstrip([_|Chars]) -> Chars.

%% reserved_word(Atom) -> Bool
%%   return 'true' if Atom is an Erlang reserved word, else 'false'.

reserved_word('after') -> true;
reserved_word('begin') -> true;
reserved_word('for') -> true;
reserved_word('do') -> true;
reserved_word('end') -> true;
reserved_word('case') -> true;
reserved_word('try') -> true;
reserved_word('cond') -> true;
reserved_word('catch') -> true;
reserved_word('andalso') -> true;
reserved_word('orelse') -> true;
reserved_word('fn') -> true;
reserved_word('if') -> true;
reserved_word('let') -> true;
reserved_word('of') -> true;
reserved_word('query') -> true;
reserved_word('receive') -> true;
reserved_word('when') -> true;
reserved_word('bnot') -> true;
reserved_word('not') -> true;
reserved_word('div') -> true;
reserved_word('rem') -> true;
reserved_word('band') -> true;
reserved_word('and') -> true;
reserved_word('bor') -> true;
reserved_word('bxor') -> true;
reserved_word('bsl') -> true;
reserved_word('bsr') -> true;
reserved_word('or') -> true;
reserved_word('xor') -> true;
reserved_word('spec') -> true;
reserved_word(_) -> false.
