-module(recur).
-export([sum/1, list_length/1, maximum/1]).

% Excersie 8
% Normal Recursion
% sum([]) -> 0;

% sum([Head | Tail]) ->
%     Head + sum(Tail).

% Excerise 9
% Tail Recursion
sum(L) -> sum(L, 0).

sum([], Acc) ->
    Acc;

sum([Head | Tail], Acc) ->
    sum(Tail, Acc + Head).

% Excerise 10
list_length(L) ->
    list_length(L, 0).

list_length([], Acc) ->
    Acc;

list_length([_ | Tail], Acc) ->
    list_length(Tail, Acc + 1).

% Excerise 11
maximum(L) ->
    case L of
        [] -> {error, list_is_empty};
        _  -> [Head | Tail] = L,
            maximum(Tail, Head)
    end.

maximum([], Max) ->
    Max;

maximum([Head | Tail], Max) when Head > Max ->
    maximum(Tail, Head);
    
maximum([_ | Tail], Max) ->
    maximum(Tail, Max).

    

