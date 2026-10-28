-module(guard).
-export([classify_number/1, grade/1]).

classify_number(N) when is_number(N), N > 0 ->
    positive;

classify_number(N) when is_number(N), N < 0 ->
    negative;

classify_number(N) when is_number(N) ->
    zero.


grade(Score) when is_number(Score), 101 =< Score orelse 0 > Score ->
    {error, out_of_scale}; 
grade(Score) when is_number(Score), 90 =< Score ->
    a; 
grade(Score) when is_number(Score), 80 =< Score ->
    b; 
grade(Score) when is_number(Score), 70 =< Score ->
    c; 
grade(Score) when is_number(Score), 60 =< Score ->
    d; 
grade(Score) when is_number(Score) ->
    f.
