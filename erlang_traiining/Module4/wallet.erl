-module(wallet).
-export([start/1, deposit/2, withdrawal/2, get_balance/1, transfer_money/3]).

% Exercise 13 — Wallet Actor

start(Balance) when is_integer(Balance), Balance >= 0 ->
    account(Balance).

account(Balance) ->
    receive
        {deposit, Amount, From} when is_integer(Amount), Amount > 0 ->
            NewBalance = Balance + Amount,
            From ! {deposit_result, success, NewBalance},
            account(NewBalance);

        {deposit, Amount, From} when is_integer(Amount) ->
            From ! {deposit_result, {error, amount_should_be_greater_than_Zero}},
            account(Balance);

        {deposit, _, From} ->
            From ! {deposit_result, {error, invalid_amount}},
            account(Balance);

        {withdrawal, Amount, From}
            when is_integer(Amount), Amount > 0,
                 Balance >= Amount ->
            NewBalance = Balance - Amount,
            From ! {withdrawal_result, success, NewBalance},
            account(NewBalance);

        {withdrawal, Amount, From}
            when is_integer(Amount), Amount >= 0 ->
            From ! {withdrawal_result, {error, insufficient_funds}},
            account(Balance);

        {withdrawal, Amount, From} when is_integer(Amount) ->
            From ! {withdrawal_result, {error, amount_should_be_greater_than_Zero}},
            account(Balance);

        {withdrawal, _, From} ->
            From ! {withdrawal_result, {error, invalid_amount}},
            account(Balance);

        {get_balance, From} ->
            From ! {balance, Balance},
            account(Balance);

        stop ->
            io:format("Wallet stopped~n"),
            ok;

        _ ->
            account(Balance)
    end.

deposit(Pid, Amount) ->
    Pid ! {deposit, Amount, self()},
    receive
        {deposit_result, Result, NewBalance} ->
            {Result, NewBalance};
        {deposit_result, Error} ->
            Error
    after
        3000 ->
            {error, timeout}
    end.

withdrawal(Pid, Amount) ->
    Pid ! {withdrawal, Amount, self()},
    receive
        {withdrawal_result, Result, NewBalance} ->
            {Result, NewBalance};
        {withdrawal_result, Error} ->
            Error
    after
        3000 ->
            {error, timeout}
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

% Exercise 14
transfer_money(SenderPid, ReceiverPid, Amount) when is_integer(Amount), Amount > 0 ->

    SenderBalance = get_balance(SenderPid),
    
    case SenderBalance of
        {balance, Balance} when Balance >= Amount ->
            case withdrawal(SenderPid, Amount) of
                {success, _} ->
                    case deposit(ReceiverPid, Amount) of
                        {success, _} ->
                            NewSenderBalance = get_balance(SenderPid),
                            NewReceiverBalance = get_balance(ReceiverPid),
                            {success, {sender, NewSenderBalance}, {receiver, NewReceiverBalance}};
                        Error ->
                            {error, {deposit_failed, Error}}
                    end;
                Error ->
                    {error, {withdrawal_failed, Error}}
            end;

        {balance, _} ->
            {error, insufficient_funds};

        _ ->
            {error, unknown_error}
    end;
transfer_money(_, _, _) ->
    {error, invalid_amount}.


% The two-message transfer is not automatically atomic because
% there is no transaction rollback. Even if the sender has
% sufficient funds, either the withdrawal or the deposit could
% fail. If the withdrawal succeeds but the deposit fails, the
% money is removed from the sender's wallet but not added to
% the receiver's wallet.
%
% This can leave the wallets inconsistent, even if their state
% is stored only in memory rather than persisted in a database.
% Atomicity means that either the entire transaction succeeds
% or none of it does.



% 32> c(wallet).
% {ok,wallet}
% 33> Pid = spawn(wallet, start, []).
% <0.150.0>
% 34> wallet:deposit(Pid, 500).
% {success,1500}
% 35> wallet:withdrawal(Pid, 200).
% {success,1300}
% 36> wallet:get_balance(Pid).
% {balance,1300}
% 37> wallet:deposit(Pid, -50).
% {error,invalid_amount}
% 38> wallet:deposit(Pid, hello).
% {error,invalid_amount}
% 39> wallet:withdrawal(Pid, 5000).
% {error,insufficient_funds}
% 40> wallet:withdrawal(Pid, -20).
% {error,invalid_amount}
% 41> Pid ! stop.
% Wallet stopped
% stop
% 42> is_process_alive(Pid).
% false
% 43> 

% Exercise 11
%  A = spawn(wallet, start, [1000]).
% <0.188.0>
% 55> B = spawn(wallet, start, [500]).
% <0.190.0>
% 56> 
%     wallet:transfer_money(A, B, 300).
% {success,{balance,700},{balance,800}}
% 57> 