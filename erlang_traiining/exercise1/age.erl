-module(age).
-export([classify_age/1]).

classify_age(N) when is_integer(N) andalso N < 0 ->
    invalid;
classify_age(N) when is_integer(N) andalso N =< 12->
    child;
classify_age(N) when is_integer(N) andalso N =< 19 ->
    teenager;
classify_age(N) when is_integer(N) ->
    adult;
classify_age(_) ->
    {error, "Only integer is accepted as an argument"}.
