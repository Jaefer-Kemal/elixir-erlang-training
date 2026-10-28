-module(length).
-export([len/1, len_normal/1]).

% Tail Recursion
len(L) -> len(L, 0).

len([], Acc) -> 
    Acc;

len([_|Tail], Acc) -> 
    len(Tail, Acc + 1);
    
len(_,_) -> 
    {error, invalid_pattern}.

% normal Recursion
len_normal([]) ->
    0;
len_normal(L) when is_list(L) -> 
    [_ | Tail] = L,
    1 + len_normal(Tail);

len_normal(_) ->
    {error, invalid_pattern}.



