-module(func).
-export([describe/1,transform/0]).

describe({student, Name}) ->
    {student, Name};

describe({teacher, Name}) ->
    {teacher, Name};

describe({admin, Name}) ->
    {admin, Name};

describe(_) ->
    {unknown, "Not supported value"}.
    

% Excerse 12
% Square = fun(X) -> X * X end.
% Square(5).


% Exercise 13
% lists:map(fun(X) -> X * 10 end,[1,2,3,4,5]).

% Exercise 14
% Numbers = [1,2,3,4,5,6,7,8,9,10].
% lists:filter(fun(X) -> X rem 2 =/= 0 end,Numbers).

% Excerise 15
% lists:foldl(function(elem, acc), acc, list)
% Numbers = [1,2,3,4,5,6].
% lists:foldl(fun(Elem, InAcc) -> Elem + InAcc end, 0, Numbers).

% Excerise 16
% filter_even_numbers -> multiply_by_3 -> calculate_total 
transform() ->
    Numbers = [1,2,3,4,5,6,7,8,9,10],
    Even = lists:filter(fun(X) -> X rem 2 =:= 0 end, Numbers),
    Multiply = lists:map(fun(X) -> X * 3 end, Even),
    Total = lists:foldl(fun(Elem, InAcc) -> Elem + InAcc end, 0, Multiply),

    io:format("Even: ~p~n",[Even]),
    io:format("Multiply: ~p~n",[Multiply]),
    io:format("Total: ~p~n",[Total]).
    