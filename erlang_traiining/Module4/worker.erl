-module(worker).
-export([start/0, greet/1]).

% Exercise 2: spawning exported functions with arguments.
start() ->
    io:format("Worker started~n").

greet(Name) ->
    io:format("Hello, ~s!~n", [Name]).

% 15> c(worker).
% {ok,worker}
% 16> spawn(worker, start, []).
% Worker started
% <0.134.0>
% 17> spawn(worker, greet, ["Jaefer"]).
% Hello, Jaefer!
% <0.137.0>
% 18>

% The third argument of spawn/3 is the list of arguments passed to the
% function named by the second argument. Use an empty list for a zero-arity
% function such as start/0.