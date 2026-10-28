% Exercise 9
-module(registry).
-export([server/0]).

server() ->
    receive
        stop -> ok;
        _ -> server()
    end.

% 1> c(registry).
% {ok,registry}
% 2> 
%    Payment = spawn(registry, server, []).
% <0.91.0>
% 3> register(payment_server, Payment).
% true
% 4> 
%    Notification = spawn(registry, server, []).
% <0.94.0>
% 5> register(notification_server, Notification).
% true
% 6> 
%    Fraud = spawn(registry, server, []).
% <0.97.0>
% 7> register(fraud_server, Fraud).
% true
% 8> whereis(payment_server).
% <0.91.0>
% 9> whereis(notification_server).
% <0.94.0>
% 10> whereis(fraud_server).
% <0.97.0>
% 11> whereis(unknown_server).
% undefined
% 12> payment_server ! stop.
% stop
% 13> unregister(payment_server).
% ** exception error: bad argument
%      in function  unregister/1
%         called as unregister(payment_server)
%         *** argument 1: not a pid
% 14> whereis(payment_server).
% undefined
% 15> 