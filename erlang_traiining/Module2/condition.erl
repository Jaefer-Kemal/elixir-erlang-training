-module(condition).
-export([login/1, temperature/1]).


login({user, Username, Password}) ->
    % case Username of
    %     "admin" -> case Password of
    %                     "1234" ->
    %                         {ok, "Welcome admin"};
    %                         _  ->
    %                             {error, invalid_credentials}
    %                end;
    %         _ ->
    %             {error, invalid_credentials}
    % end.

    case {Username, Password} of
        {"admin", "1234"} -> {ok, "Welcom admin"};
        _ -> {error, invalid_credentials}
    end.


temperature(Temp) ->
    if
        Temp >= 30 -> hot;
        Temp >= 20 andalso Temp =< 29 -> warm;
        Temp >= 10 andalso Temp =< 19 -> cool;           
        true -> cold
            
    end.