-module(bank).
-export([start/0, get_balance/1]).
% Execise 7
start() ->
    account(1000).

account(Balance) ->
    receive
        {deposit, Amount} when is_integer(Amount), Amount > 0 ->
            account(Balance + Amount);

        {deposit, Amount} when is_integer(Amount) ->
            io:format("The deposit should be greater than 0~n"),
            account(Balance);

        {deposit, _} ->
            io:format("The input should be an integer~n"),
            account(Balance);

        {withdrawal, Amount}
            when is_integer(Amount), Amount >= 0,
                 Balance >= Amount ->
            account(Balance - Amount);

        {withdrawal, Amount}
            when is_integer(Amount), Amount > 0 ->
            io:format("Insufficient funds~n"),
            account(Balance);

        {withdrawal, Amount} when is_integer(Amount) ->
            io:format("The withdrawal should be greater than 0~n"),
            account(Balance);

        {withdrawal, _} ->
            io:format("The input should be an integer~n"),
            account(Balance);

        {get_balance, From} ->
            From ! {balance, Balance},
            account(Balance);
        stop -> 
            io:format("Stopped the process~n"),
            ok;
        _ -> account(Balance)
    end.

get_balance(Pid) ->
    Pid ! {get_balance, self()},
    receive
        {balance, Balance} ->
            {balance, Balance}
    after
        3000 ->
            {error, timeout}
    end.

% 50> Pid = spawn(bank, start, []).
% <0.176.0>
% 51> Pid ! {deposit, 500}.
% {deposit,500}
% 52> Pid ! {withdrawal, 200}.
% {withdrawal,200}
% 53> bank:get_balance(Pid).
% {balance,1300}
% 54> 