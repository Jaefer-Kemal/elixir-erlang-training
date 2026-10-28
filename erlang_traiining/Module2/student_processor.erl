-module(student_processor).
-export([get_names/1, get_passed/1, get_failed/1, average/1, highest/1, wait_for_message/0]).

% -define(Students, [
%     {"Abebe", 85},
%     {"Kebede", 65},
%     {"Almaz", 92},
%     {"Hanna", 55},
%     {"Dawit", 78}
% ]
% ).

get_names(Students) ->
    % [Name || {Name, _} <- Students].
    lists:map(fun({Name, _}) -> Name end, Students).

get_passed(Students) ->
    get_passed(Students, []).

get_passed([], PassedStudents) ->
    PassedStudents;

get_passed([{Name, Score} | RestOfStudents], PassedStudents) when Score >= 60 ->
    get_passed(RestOfStudents, [{Name, Score} | PassedStudents]);
    
get_passed([_ | RestOfStudents], PassedStudents) ->
    get_passed(RestOfStudents, PassedStudents).


get_failed(Students) ->
    get_failed(Students, []).

get_failed([], FailedStudents) ->
    FailedStudents;
get_failed([{Name, Score} | RestOfStudents], FailedStudents) when Score < 60 ->
    get_failed(RestOfStudents, [{Name, Score} | FailedStudents]);
    
get_failed([_ | RestOfStudents], FailedStudents) ->
    get_failed(RestOfStudents, FailedStudents).

average(Students) ->
    Total = lists:foldl(fun({_, Score}, InAcc) -> Score + InAcc end, 0, Students),
    Length = recur:list_length(Students),
    Total / Length.

highest(Students) ->
    [First|Rest] = Students,
    highest(Rest, First).

highest([], High) ->
    High;

highest([{Name, Score} | RestOfStudent], {_, HighScore}) when Score > HighScore ->
    highest(RestOfStudent, {Name, Score});

highest([_| RestOfStudent], High) ->
    highest(RestOfStudent, High).


wait_for_message() ->
    receive
        {hello, Name} ->
            io:format("Hello ~p~n", [Name]);

        {calculate, A, B} ->
            io:format("Result: ~p~n", [A + B]);

        stop ->
            io:format("Stopping...~n");

        _ ->
            io:format("Unknown message~n")
    after
        10000 ->
            io:format("No message received~n")
    end.
