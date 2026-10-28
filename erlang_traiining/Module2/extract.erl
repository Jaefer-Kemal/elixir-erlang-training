-module(extract).
-export([extract_user/1, extract_list/1]).

extract_user(User) ->
    {    user,
        {name, Name},
        {age, Age},
        {address, City}
    } = User,

    io:format("Name = ~p~n", [Name]),
    io:format("Age = ~p~n", [Age]),
    io:format("City = ~p~n", [City]).


extract_list(Numbers) ->
    [First , Second | Rest] = Numbers,

    io:format("First = ~p~n", [First]),
    io:format("Second = ~p~n", [Second]),
    io:format("Rest = ~p~n", [Rest]).

