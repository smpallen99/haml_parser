-file("/usr/local/Cellar/erlang/17.4.1/lib/erlang/lib/parsetools-2.0.12/include/leexinc.hrl", 0).
%% The source of this file is part of leex distribution, as such it
%% has the same Copyright as the other files in the leex
%% distribution. The Copyright is defined in the accompanying file
%% COPYRIGHT. However, the resultant scanner generated by leex is the
%% property of the creator of the scanner and is not covered by that
%% Copyright.

-module(haml_lexer).

-export([string/1,string/2,token/2,token/3,tokens/2,tokens/3]).
-export([format_error/1]).

%% User code. This is placed here to allow extra attributes.
-file("src/haml_lexer.xrl", 50).

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

-file("/usr/local/Cellar/erlang/17.4.1/lib/erlang/lib/parsetools-2.0.12/include/leexinc.hrl", 14).

format_error({illegal,S}) -> ["illegal characters ",io_lib:write_string(S)];
format_error({user,S}) -> S.

string(String) -> string(String, 1).

string(String, Line) -> string(String, Line, String, []).

%% string(InChars, Line, TokenChars, Tokens) ->
%% {ok,Tokens,Line} | {error,ErrorInfo,Line}.
%% Note the line number going into yystate, L0, is line of token
%% start while line number returned is line of token end. We want line
%% of token start.

string([], L, [], Ts) ->                     % No partial tokens!
    {ok,yyrev(Ts),L};
string(Ics0, L0, Tcs, Ts) ->
    case yystate(yystate(), Ics0, L0, 0, reject, 0) of
        {A,Alen,Ics1,L1} ->                  % Accepting end state
            string_cont(Ics1, L1, yyaction(A, Alen, Tcs, L0), Ts);
        {A,Alen,Ics1,L1,_S1} ->              % Accepting transistion state
            string_cont(Ics1, L1, yyaction(A, Alen, Tcs, L0), Ts);
        {reject,_Alen,Tlen,_Ics1,L1,_S1} ->  % After a non-accepting state
            {error,{L0,?MODULE,{illegal,yypre(Tcs, Tlen+1)}},L1};
        {A,Alen,_Tlen,_Ics1,_L1,_S1} ->
            string_cont(yysuf(Tcs, Alen), L0, yyaction(A, Alen, Tcs, L0), Ts)
    end.

%% string_cont(RestChars, Line, Token, Tokens)
%% Test for and remove the end token wrapper. Push back characters
%% are prepended to RestChars.

string_cont(Rest, Line, {token,T}, Ts) ->
    string(Rest, Line, Rest, [T|Ts]);
string_cont(Rest, Line, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, [T|Ts]);
string_cont(Rest, Line, {end_token,T}, Ts) ->
    string(Rest, Line, Rest, [T|Ts]);
string_cont(Rest, Line, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, [T|Ts]);
string_cont(Rest, Line, skip_token, Ts) ->
    string(Rest, Line, Rest, Ts);
string_cont(Rest, Line, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, Ts);
string_cont(_Rest, Line, {error,S}, _Ts) ->
    {error,{Line,?MODULE,{user,S}},Line}.

%% token(Continuation, Chars) ->
%% token(Continuation, Chars, Line) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {token,State,CurrLine,TokenChars,TokenLen,TokenLine,AccAction,AccLen}

token(Cont, Chars) -> token(Cont, Chars, 1).

token([], Chars, Line) ->
    token(yystate(), Chars, Line, Chars, 0, Line, reject, 0);
token({token,State,Line,Tcs,Tlen,Tline,Action,Alen}, Chars, _) ->
    token(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Action, Alen).

%% token(State, InChars, Line, TokenChars, TokenLen, TokenLine,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% The argument order is chosen to be more efficient.

token(S0, Ics0, L0, Tcs, Tlen0, Tline, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1} ->
            token_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline));
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,S1} ->                  % Need more chars to check
            {more,{token,S1,L1,Tcs,Alen1,Tline,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->               % Take what we got
            token_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline));
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,S1} ->            % Need more chars to check
            {more,{token,S1,L1,Tcs,Tlen1,Tline,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,_S1} ->     % No token match
            %% Check for partial token which is error.
            Ret = if Tlen1 > 0 -> {error,{Tline,?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},L1};
                     true -> {eof,L1}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,Ics1,L1,_S1} ->    % No token match
            Error = {Tline,?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            {done,{error,Error,L1},Ics1};
        {A1,Alen1,_Tlen1,_Ics1,_L1,_S1} ->       % Use last accept match
            token_cont(yysuf(Tcs, Alen1), L0, yyaction(A1, Alen1, Tcs, Tline))
    end.

%% token_cont(RestChars, Line, Token)
%% If we have a token or error then return done, else if we have a
%% skip_token then continue.

token_cont(Rest, Line, {token,T}) ->
    {done,{ok,T,Line},Rest};
token_cont(Rest, Line, {token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,Line},NewRest};
token_cont(Rest, Line, {end_token,T}) ->
    {done,{ok,T,Line},Rest};
token_cont(Rest, Line, {end_token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,Line},NewRest};
token_cont(Rest, Line, skip_token) ->
    token(yystate(), Rest, Line, Rest, 0, Line, reject, 0);
token_cont(Rest, Line, {skip_token,Push}) ->
    NewRest = Push ++ Rest,
    token(yystate(), NewRest, Line, NewRest, 0, Line, reject, 0);
token_cont(Rest, Line, {error,S}) ->
    {done,{error,{Line,?MODULE,{user,S}},Line},Rest}.

%% tokens(Continuation, Chars, Line) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {tokens,State,CurrLine,TokenChars,TokenLen,TokenLine,Tokens,AccAction,AccLen}
%% {skip_tokens,State,CurrLine,TokenChars,TokenLen,TokenLine,Error,AccAction,AccLen}

tokens(Cont, Chars) -> tokens(Cont, Chars, 1).

tokens([], Chars, Line) ->
    tokens(yystate(), Chars, Line, Chars, 0, Line, [], reject, 0);
tokens({tokens,State,Line,Tcs,Tlen,Tline,Ts,Action,Alen}, Chars, _) ->
    tokens(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Ts, Action, Alen);
tokens({skip_tokens,State,Line,Tcs,Tlen,Tline,Error,Action,Alen}, Chars, _) ->
    skip_tokens(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Error, Action, Alen).

%% tokens(State, InChars, Line, TokenChars, TokenLen, TokenLine, Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

tokens(S0, Ics0, L0, Tcs, Tlen0, Tline, Ts, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1} ->
            tokens_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Ts);
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,S1} ->                  % Need more chars to check
            {more,{tokens,S1,L1,Tcs,Alen1,Tline,Ts,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->               % Take what we got
            tokens_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Ts);
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,S1} ->            % Need more chars to check
            {more,{tokens,S1,L1,Tcs,Tlen1,Tline,Ts,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,_S1} ->     % No token match
            %% Check for partial token which is error, no need to skip here.
            Ret = if Tlen1 > 0 -> {error,{Tline,?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},L1};
                     Ts == [] -> {eof,L1};
                     true -> {ok,yyrev(Ts),L1}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,_S1} ->
            %% Skip rest of tokens.
            Error = {L1,?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, Error);
        {A1,Alen1,_Tlen1,_Ics1,_L1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline),
            tokens_cont(yysuf(Tcs, Alen1), L0, Token, Ts)
    end.

%% tokens_cont(RestChars, Line, Token, Tokens)
%% If we have an end_token or error then return done, else if we have
%% a token then save it and continue, else if we have a skip_token
%% just continue.

tokens_cont(Rest, Line, {token,T}, Ts) ->
    tokens(yystate(), Rest, Line, Rest, 0, Line, [T|Ts], reject, 0);
tokens_cont(Rest, Line, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, NewRest, 0, Line, [T|Ts], reject, 0);
tokens_cont(Rest, Line, {end_token,T}, Ts) ->
    {done,{ok,yyrev(Ts, [T]),Line},Rest};
tokens_cont(Rest, Line, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    {done,{ok,yyrev(Ts, [T]),Line},NewRest};
tokens_cont(Rest, Line, skip_token, Ts) ->
    tokens(yystate(), Rest, Line, Rest, 0, Line, Ts, reject, 0);
tokens_cont(Rest, Line, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, NewRest, 0, Line, Ts, reject, 0);
tokens_cont(Rest, Line, {error,S}, _Ts) ->
    skip_tokens(Rest, Line, {Line,?MODULE,{user,S}}).

%%skip_tokens(InChars, Line, Error) -> {done,{error,Error,Line},Ics}.
%% Skip tokens until an end token, junk everything and return the error.

skip_tokens(Ics, Line, Error) ->
    skip_tokens(yystate(), Ics, Line, Ics, 0, Line, Error, reject, 0).

%% skip_tokens(State, InChars, Line, TokenChars, TokenLen, TokenLine, Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

skip_tokens(S0, Ics0, L0, Tcs, Tlen0, Tline, Error, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        {A1,Alen1,Ics1,L1} ->                  % Accepting end state
            skip_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Error);
        {A1,Alen1,[],L1,S1} ->                 % After an accepting state
            {more,{skip_tokens,S1,L1,Tcs,Alen1,Tline,Error,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->
            skip_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Error);
        {A1,Alen1,Tlen1,[],L1,S1} ->           % After a non-accepting state
            {more,{skip_tokens,S1,L1,Tcs,Tlen1,Tline,Error,A1,Alen1}};
        {reject,_Alen1,_Tlen1,eof,L1,_S1} ->
            {done,{error,Error,L1},eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,_S1} ->
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, Error);
        {A1,Alen1,_Tlen1,_Ics1,L1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline),
            skip_cont(yysuf(Tcs, Alen1), L1, Token, Error)
    end.

%% skip_cont(RestChars, Line, Token, Error)
%% Skip tokens until we have an end_token or error then return done
%% with the original rror.

skip_cont(Rest, Line, {token,_T}, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, NewRest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {end_token,_T}, Error) ->
    {done,{error,Error,Line},Rest};
skip_cont(Rest, Line, {end_token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    {done,{error,Error,Line},NewRest};
skip_cont(Rest, Line, skip_token, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {skip_token,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, NewRest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {error,_S}, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0).

yyrev(List) -> lists:reverse(List).
yyrev(List, Tail) -> lists:reverse(List, Tail).
yypre(List, N) -> lists:sublist(List, N).
yysuf(List, N) -> lists:nthtail(N, List).

%% yystate() -> InitialState.
%% yystate(State, InChars, Line, CurrTokLen, AcceptAction, AcceptLen) ->
%% {Action, AcceptLen, RestChars, Line} |
%% {Action, AcceptLen, RestChars, Line, State} |
%% {reject, AcceptLen, CurrTokLen, RestChars, Line, State} |
%% {Action, AcceptLen, CurrTokLen, RestChars, Line, State}.
%% Generated state transition functions. The non-accepting end state
%% return signal either an unrecognised character or end of current
%% input.

-file("src/haml_lexer.erl", 316).
yystate() -> 38.

yystate(41, Ics, Line, Tlen, _, _) ->
    {1,Tlen,Ics,Line};
yystate(40, [32|Ics], Line, Tlen, _, _) ->
    yystate(40, Ics, Line, Tlen+1, 17, Tlen);
yystate(40, [9|Ics], Line, Tlen, _, _) ->
    yystate(40, Ics, Line, Tlen+1, 17, Tlen);
yystate(40, Ics, Line, Tlen, _, _) ->
    {17,Tlen,Ics,Line,40};
yystate(39, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(39, Ics, Line, Tlen+1, 1, Tlen);
yystate(39, Ics, Line, Tlen, _, _) ->
    {1,Tlen,Ics,Line,39};
yystate(38, [125|Ics], Line, Tlen, _, _) ->
    yystate(34, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [123|Ics], Line, Tlen, _, _) ->
    yystate(30, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [95|Ics], Line, Tlen, _, _) ->
    yystate(5, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [93|Ics], Line, Tlen, _, _) ->
    yystate(13, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [91|Ics], Line, Tlen, _, _) ->
    yystate(17, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [61|Ics], Line, Tlen, _, _) ->
    yystate(25, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [60|Ics], Line, Tlen, _, _) ->
    yystate(29, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [58|Ics], Line, Tlen, _, _) ->
    yystate(37, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [46|Ics], Line, Tlen, _, _) ->
    yystate(27, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [45|Ics], Line, Tlen, _, _) ->
    yystate(15, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [44|Ics], Line, Tlen, _, _) ->
    yystate(7, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [41|Ics], Line, Tlen, _, _) ->
    yystate(3, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [40|Ics], Line, Tlen, _, _) ->
    yystate(0, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [39|Ics], Line, Tlen, _, _) ->
    yystate(8, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [37|Ics], Line, Tlen, _, _) ->
    yystate(12, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [35|Ics], Line, Tlen, _, _) ->
    yystate(20, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [34|Ics], Line, Tlen, _, _) ->
    yystate(32, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [32|Ics], Line, Tlen, _, _) ->
    yystate(40, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [13|Ics], Line, Tlen, _, _) ->
    yystate(36, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [10|Ics], Line, Tlen, _, _) ->
    yystate(36, Ics, Line+1, Tlen+1, 17, Tlen);
yystate(38, [9|Ics], Line, Tlen, _, _) ->
    yystate(40, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(35, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(21, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(26, Ics, Line, Tlen+1, 17, Tlen);
yystate(38, Ics, Line, Tlen, _, _) ->
    {17,Tlen,Ics,Line,38};
yystate(37, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(41, Ics, Line, Tlen+1, Action, Alen);
yystate(37, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(39, Ics, Line, Tlen+1, Action, Alen);
yystate(37, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(41, Ics, Line, Tlen+1, Action, Alen);
yystate(37, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(41, Ics, Line, Tlen+1, Action, Alen);
yystate(37, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,37};
yystate(36, Ics, Line, Tlen, _, _) ->
    {25,Tlen,Ics,Line};
yystate(35, [95|Ics], Line, Tlen, _, _) ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(35, [58|Ics], Line, Tlen, _, _) ->
    yystate(10, Ics, Line, Tlen+1, 0, Tlen);
yystate(35, [45|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 0, Tlen);
yystate(35, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(31, Ics, Line, Tlen+1, 0, Tlen);
yystate(35, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(35, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(35, Ics, Line, Tlen, _, _) ->
    {0,Tlen,Ics,Line,35};
yystate(34, Ics, Line, Tlen, _, _) ->
    {11,Tlen,Ics,Line};
yystate(33, Ics, Line, Tlen, _, _) ->
    {24,Tlen,Ics,Line};
yystate(32, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(28, Ics, Line, Tlen+1, Action, Alen);
yystate(32, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(32, Ics, Line+1, Tlen+1, Action, Alen);
yystate(32, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(32, Ics, Line, Tlen+1, Action, Alen);
yystate(32, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 33 ->
    yystate(32, Ics, Line, Tlen+1, Action, Alen);
yystate(32, [C|Ics], Line, Tlen, Action, Alen) when C >= 35 ->
    yystate(32, Ics, Line, Tlen+1, Action, Alen);
yystate(32, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,32};
yystate(31, [95|Ics], Line, Tlen, _, _) ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(31, [58|Ics], Line, Tlen, _, _) ->
    yystate(18, Ics, Line, Tlen+1, 0, Tlen);
yystate(31, [45|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 0, Tlen);
yystate(31, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(31, Ics, Line, Tlen+1, 0, Tlen);
yystate(31, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(31, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(9, Ics, Line, Tlen+1, 0, Tlen);
yystate(31, Ics, Line, Tlen, _, _) ->
    {0,Tlen,Ics,Line,31};
yystate(30, Ics, Line, Tlen, _, _) ->
    {10,Tlen,Ics,Line};
yystate(29, [45|Ics], Line, Tlen, Action, Alen) ->
    yystate(33, Ics, Line, Tlen+1, Action, Alen);
yystate(29, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,29};
yystate(28, Ics, Line, Tlen, _, _) ->
    {4,Tlen,Ics,Line};
yystate(27, [95|Ics], Line, Tlen, _, _) ->
    yystate(23, Ics, Line, Tlen+1, 13, Tlen);
yystate(27, [45|Ics], Line, Tlen, _, _) ->
    yystate(23, Ics, Line, Tlen+1, 13, Tlen);
yystate(27, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(23, Ics, Line, Tlen+1, 13, Tlen);
yystate(27, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(23, Ics, Line, Tlen+1, 13, Tlen);
yystate(27, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(23, Ics, Line, Tlen+1, 13, Tlen);
yystate(27, Ics, Line, Tlen, _, _) ->
    {13,Tlen,Ics,Line,27};
yystate(26, [95|Ics], Line, Tlen, _, _) ->
    yystate(22, Ics, Line, Tlen+1, 22, Tlen);
yystate(26, [58|Ics], Line, Tlen, _, _) ->
    yystate(10, Ics, Line, Tlen+1, 22, Tlen);
yystate(26, [45|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 22, Tlen);
yystate(26, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(22, Ics, Line, Tlen+1, 22, Tlen);
yystate(26, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(22, Ics, Line, Tlen+1, 22, Tlen);
yystate(26, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(22, Ics, Line, Tlen+1, 22, Tlen);
yystate(26, Ics, Line, Tlen, _, _) ->
    {22,Tlen,Ics,Line,26};
yystate(25, Ics, Line, Tlen, _, _) ->
    {16,Tlen,Ics,Line};
yystate(24, [95|Ics], Line, Tlen, _, _) ->
    yystate(24, Ics, Line, Tlen+1, 20, Tlen);
yystate(24, [45|Ics], Line, Tlen, _, _) ->
    yystate(24, Ics, Line, Tlen+1, 20, Tlen);
yystate(24, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(24, Ics, Line, Tlen+1, 20, Tlen);
yystate(24, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(24, Ics, Line, Tlen+1, 20, Tlen);
yystate(24, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(24, Ics, Line, Tlen+1, 20, Tlen);
yystate(24, Ics, Line, Tlen, _, _) ->
    {20,Tlen,Ics,Line,24};
yystate(23, [95|Ics], Line, Tlen, _, _) ->
    yystate(23, Ics, Line, Tlen+1, 19, Tlen);
yystate(23, [45|Ics], Line, Tlen, _, _) ->
    yystate(23, Ics, Line, Tlen+1, 19, Tlen);
yystate(23, [32|Ics], Line, Tlen, _, _) ->
    yystate(19, Ics, Line, Tlen+1, 19, Tlen);
yystate(23, [9|Ics], Line, Tlen, _, _) ->
    yystate(19, Ics, Line, Tlen+1, 19, Tlen);
yystate(23, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(23, Ics, Line, Tlen+1, 19, Tlen);
yystate(23, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(23, Ics, Line, Tlen+1, 19, Tlen);
yystate(23, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(23, Ics, Line, Tlen+1, 19, Tlen);
yystate(23, Ics, Line, Tlen, _, _) ->
    {19,Tlen,Ics,Line,23};
yystate(22, [95|Ics], Line, Tlen, _, _) ->
    yystate(22, Ics, Line, Tlen+1, 22, Tlen);
yystate(22, [58|Ics], Line, Tlen, _, _) ->
    yystate(18, Ics, Line, Tlen+1, 22, Tlen);
yystate(22, [45|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 22, Tlen);
yystate(22, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(22, Ics, Line, Tlen+1, 22, Tlen);
yystate(22, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(22, Ics, Line, Tlen+1, 22, Tlen);
yystate(22, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(22, Ics, Line, Tlen+1, 22, Tlen);
yystate(22, Ics, Line, Tlen, _, _) ->
    {22,Tlen,Ics,Line,22};
yystate(21, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(21, [58|Ics], Line, Tlen, Action, Alen) ->
    yystate(10, Ics, Line, Tlen+1, Action, Alen);
yystate(21, [45|Ics], Line, Tlen, Action, Alen) ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(21, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(21, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(21, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(21, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,21};
yystate(20, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(20, [45|Ics], Line, Tlen, Action, Alen) ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(20, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(20, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(20, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(24, Ics, Line, Tlen+1, Action, Alen);
yystate(20, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,20};
yystate(19, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(19, Ics, Line, Tlen+1, 18, Tlen);
yystate(19, [C|Ics], Line, Tlen, _, _) when C >= 11 ->
    yystate(19, Ics, Line, Tlen+1, 18, Tlen);
yystate(19, Ics, Line, Tlen, _, _) ->
    {18,Tlen,Ics,Line,19};
yystate(18, [32|Ics], Line, Tlen, _, _) ->
    yystate(14, Ics, Line, Tlen+1, 2, Tlen);
yystate(18, [9|Ics], Line, Tlen, _, _) ->
    yystate(14, Ics, Line, Tlen+1, 2, Tlen);
yystate(18, Ics, Line, Tlen, _, _) ->
    {2,Tlen,Ics,Line,18};
yystate(17, Ics, Line, Tlen, _, _) ->
    {6,Tlen,Ics,Line};
yystate(16, [95|Ics], Line, Tlen, _, _) ->
    yystate(16, Ics, Line, Tlen+1, 21, Tlen);
yystate(16, [45|Ics], Line, Tlen, _, _) ->
    yystate(16, Ics, Line, Tlen+1, 21, Tlen);
yystate(16, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(16, Ics, Line, Tlen+1, 21, Tlen);
yystate(16, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(16, Ics, Line, Tlen+1, 21, Tlen);
yystate(16, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(16, Ics, Line, Tlen+1, 21, Tlen);
yystate(16, Ics, Line, Tlen, _, _) ->
    {21,Tlen,Ics,Line,16};
yystate(15, [62|Ics], Line, Tlen, _, _) ->
    yystate(11, Ics, Line, Tlen+1, 14, Tlen);
yystate(15, Ics, Line, Tlen, _, _) ->
    {14,Tlen,Ics,Line,15};
yystate(14, Ics, Line, Tlen, _, _) ->
    {3,Tlen,Ics,Line};
yystate(13, Ics, Line, Tlen, _, _) ->
    {7,Tlen,Ics,Line};
yystate(12, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(16, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [45|Ics], Line, Tlen, Action, Alen) ->
    yystate(16, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(16, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(16, Ics, Line, Tlen+1, Action, Alen);
yystate(12, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(16, Ics, Line, Tlen+1, Action, Alen);
yystate(12, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,12};
yystate(11, Ics, Line, Tlen, _, _) ->
    {23,Tlen,Ics,Line};
yystate(10, Ics, Line, Tlen, _, _) ->
    {2,Tlen,Ics,Line};
yystate(9, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(9, [58|Ics], Line, Tlen, Action, Alen) ->
    yystate(18, Ics, Line, Tlen+1, Action, Alen);
yystate(9, [45|Ics], Line, Tlen, Action, Alen) ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(9, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(9, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(9, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(9, Ics, Line, Tlen+1, Action, Alen);
yystate(9, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,9};
yystate(8, [39|Ics], Line, Tlen, Action, Alen) ->
    yystate(4, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 38 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(8, [C|Ics], Line, Tlen, Action, Alen) when C >= 40 ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(8, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,8};
yystate(7, Ics, Line, Tlen, _, _) ->
    {12,Tlen,Ics,Line};
yystate(6, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(6, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(6, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(6, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(6, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,6};
yystate(5, [95|Ics], Line, Tlen, _, _) ->
    yystate(9, Ics, Line, Tlen+1, 15, Tlen);
yystate(5, [58|Ics], Line, Tlen, _, _) ->
    yystate(10, Ics, Line, Tlen+1, 15, Tlen);
yystate(5, [45|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 15, Tlen);
yystate(5, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(9, Ics, Line, Tlen+1, 15, Tlen);
yystate(5, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(9, Ics, Line, Tlen+1, 15, Tlen);
yystate(5, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(9, Ics, Line, Tlen+1, 15, Tlen);
yystate(5, Ics, Line, Tlen, _, _) ->
    {15,Tlen,Ics,Line,5};
yystate(4, [39|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 5, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(8, Ics, Line, Tlen+1, 5, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 38 ->
    yystate(8, Ics, Line, Tlen+1, 5, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 40 ->
    yystate(8, Ics, Line, Tlen+1, 5, Tlen);
yystate(4, Ics, Line, Tlen, _, _) ->
    {5,Tlen,Ics,Line,4};
yystate(3, Ics, Line, Tlen, _, _) ->
    {9,Tlen,Ics,Line};
yystate(2, [95|Ics], Line, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(2, [58|Ics], Line, Tlen, Action, Alen) ->
    yystate(1, Ics, Line, Tlen+1, Action, Alen);
yystate(2, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(2, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(2, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(2, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,2};
yystate(1, [32|Ics], Line, Tlen, Action, Alen) ->
    yystate(14, Ics, Line, Tlen+1, Action, Alen);
yystate(1, [9|Ics], Line, Tlen, Action, Alen) ->
    yystate(14, Ics, Line, Tlen+1, Action, Alen);
yystate(1, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,1};
yystate(0, Ics, Line, Tlen, _, _) ->
    {8,Tlen,Ics,Line};
yystate(S, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,S}.

%% yyaction(Action, TokenLength, TokenChars, TokenLine) ->
%% {token,Token} | {end_token, Token} | skip_token | {error,String}.
%% Generated action function.

yyaction(0, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_0(TokenChars, TokenLine);
yyaction(1, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_1(TokenChars, TokenLine);
yyaction(2, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_2(TokenChars, TokenLen, TokenLine);
yyaction(3, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_3(TokenChars, TokenLen, TokenLine);
yyaction(4, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_4(TokenChars, TokenLine);
yyaction(5, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_5(TokenChars, TokenLine);
yyaction(6, _, _, TokenLine) ->
    yyaction_6(TokenLine);
yyaction(7, _, _, TokenLine) ->
    yyaction_7(TokenLine);
yyaction(8, _, _, TokenLine) ->
    yyaction_8(TokenLine);
yyaction(9, _, _, TokenLine) ->
    yyaction_9(TokenLine);
yyaction(10, _, _, TokenLine) ->
    yyaction_10(TokenLine);
yyaction(11, _, _, TokenLine) ->
    yyaction_11(TokenLine);
yyaction(12, _, _, TokenLine) ->
    yyaction_12(TokenLine);
yyaction(13, _, _, TokenLine) ->
    yyaction_13(TokenLine);
yyaction(14, _, _, TokenLine) ->
    yyaction_14(TokenLine);
yyaction(15, _, _, TokenLine) ->
    yyaction_15(TokenLine);
yyaction(16, _, _, TokenLine) ->
    yyaction_16(TokenLine);
yyaction(17, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_17(TokenChars, TokenLine);
yyaction(18, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_18(TokenChars, TokenLine);
yyaction(19, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_19(TokenChars, TokenLine);
yyaction(20, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_20(TokenChars, TokenLine);
yyaction(21, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_21(TokenChars, TokenLine);
yyaction(22, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_22(TokenChars, TokenLine);
yyaction(23, _, _, TokenLine) ->
    yyaction_23(TokenLine);
yyaction(24, _, _, TokenLine) ->
    yyaction_24(TokenLine);
yyaction(25, _, _, TokenLine) ->
    yyaction_25(TokenLine);
yyaction(_, _, _, _) -> error.

-compile({inline,yyaction_0/2}).
-file("src/haml_lexer.xrl", 13).
yyaction_0(TokenChars, TokenLine) ->
     { token, { int, TokenLine, list_to_integer (TokenChars) } } .

-compile({inline,yyaction_1/2}).
-file("src/haml_lexer.xrl", 14).
yyaction_1(TokenChars, TokenLine) ->
     { token, { atom, TokenLine, to_atom (TokenChars) } } .

-compile({inline,yyaction_2/3}).
-file("src/haml_lexer.xrl", 15).
yyaction_2(TokenChars, TokenLen, TokenLine) ->
     { token, { key, TokenLine, list_to_atom (lists : sublist (TokenChars, 1, TokenLen - 1)) } } .

-compile({inline,yyaction_3/3}).
-file("src/haml_lexer.xrl", 16).
yyaction_3(TokenChars, TokenLen, TokenLine) ->
     { token, { dkey, TokenLine, list_to_atom (lists : sublist (TokenChars, 1, TokenLen - 2)) } } .

-compile({inline,yyaction_4/2}).
-file("src/haml_lexer.xrl", 18).
yyaction_4(TokenChars, TokenLine) ->
     { token, { quote, TokenLine, TokenChars } } .

-compile({inline,yyaction_5/2}).
-file("src/haml_lexer.xrl", 19).
yyaction_5(TokenChars, TokenLine) ->
     { token, { squote, TokenLine, TokenChars } } .

-compile({inline,yyaction_6/1}).
-file("src/haml_lexer.xrl", 20).
yyaction_6(TokenLine) ->
     { token, { '[', TokenLine } } .

-compile({inline,yyaction_7/1}).
-file("src/haml_lexer.xrl", 21).
yyaction_7(TokenLine) ->
     { token, { ']', TokenLine } } .

-compile({inline,yyaction_8/1}).
-file("src/haml_lexer.xrl", 22).
yyaction_8(TokenLine) ->
     { token, { '(', TokenLine } } .

-compile({inline,yyaction_9/1}).
-file("src/haml_lexer.xrl", 23).
yyaction_9(TokenLine) ->
     { token, { ')', TokenLine } } .

-compile({inline,yyaction_10/1}).
-file("src/haml_lexer.xrl", 24).
yyaction_10(TokenLine) ->
     { token, { '{', TokenLine } } .

-compile({inline,yyaction_11/1}).
-file("src/haml_lexer.xrl", 25).
yyaction_11(TokenLine) ->
     { token, { '}', TokenLine } } .

-compile({inline,yyaction_12/1}).
-file("src/haml_lexer.xrl", 26).
yyaction_12(TokenLine) ->
     { token, { ',', TokenLine } } .

-compile({inline,yyaction_13/1}).
-file("src/haml_lexer.xrl", 27).
yyaction_13(TokenLine) ->
     { token, { '.', TokenLine } } .

-compile({inline,yyaction_14/1}).
-file("src/haml_lexer.xrl", 28).
yyaction_14(TokenLine) ->
     { token, { '-', TokenLine } } .

-compile({inline,yyaction_15/1}).
-file("src/haml_lexer.xrl", 29).
yyaction_15(TokenLine) ->
     { token, { '_', TokenLine } } .

-compile({inline,yyaction_16/1}).
-file("src/haml_lexer.xrl", 30).
yyaction_16(TokenLine) ->
     { token, { '=', TokenLine } } .

-compile({inline,yyaction_17/2}).
-file("src/haml_lexer.xrl", 31).
yyaction_17(TokenChars, TokenLine) ->
     { token, { ws, TokenLine, TokenChars } } .

-compile({inline,yyaction_18/2}).
-file("src/haml_lexer.xrl", 32).
yyaction_18(TokenChars, TokenLine) ->
     [Tag, Content ] = 'Elixir.Helpers' : extract_first (TokenChars),
     { token, { tag_content, TokenLine, Content }, Tag } .

-compile({inline,yyaction_19/2}).
-file("src/haml_lexer.xrl", 34).
yyaction_19(TokenChars, TokenLine) ->
     { token, { class, TokenLine, lstrip (TokenChars) } } .

-compile({inline,yyaction_20/2}).
-file("src/haml_lexer.xrl", 35).
yyaction_20(TokenChars, TokenLine) ->
     { token, { id, TokenLine, lstrip (TokenChars) } } .

-compile({inline,yyaction_21/2}).
-file("src/haml_lexer.xrl", 36).
yyaction_21(TokenChars, TokenLine) ->
     { token, { tag, TokenLine, lstrip (TokenChars) } } .

-compile({inline,yyaction_22/2}).
-file("src/haml_lexer.xrl", 37).
yyaction_22(TokenChars, TokenLine) ->
     Atom = list_to_atom (TokenChars),
     { token, case reserved_word (Atom) of
     true -> { Atom, TokenLine } ;
     false -> { atom, TokenLine, Atom }
     end } .

-compile({inline,yyaction_23/1}).
-file("src/haml_lexer.xrl", 43).
yyaction_23(TokenLine) ->
     { token, { '->', TokenLine } } .

-compile({inline,yyaction_24/1}).
-file("src/haml_lexer.xrl", 44).
yyaction_24(TokenLine) ->
     { token, { '<-', TokenLine } } .

-compile({inline,yyaction_25/1}).
-file("src/haml_lexer.xrl", 45).
yyaction_25(TokenLine) ->
     { end_token, { nl, TokenLine } } .

-file("/usr/local/Cellar/erlang/17.4.1/lib/erlang/lib/parsetools-2.0.12/include/leexinc.hrl", 282).
