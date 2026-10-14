-module(length_temp).
-export([len/1, len/2]).

% Tail Recursion using Two Arguments
len([], Acc) ->
    Acc;
len([_|Tail], Acc) ->
    len(Tail, Acc + 1).

% Normal Recursion using one Argument
len([]) ->
    0;
len([_ | Tail]) -> 
    1 + len(Tail).