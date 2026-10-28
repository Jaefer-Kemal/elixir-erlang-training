-module(process).
-export([hello/0, receive_message/0, receive_multi_messages/0,
        receive_with_timeout/0, start_counter/0, result_counter/0,
        selective_receive/0, chat_receiver/0]).

% Exercise 1
hello() ->
    spawn(fun() -> 
        io:format("Hello from Erlang process: ~p~n", [self()]) end).

% Exercise 3
receive_message() ->
    spawn(fun() -> 
    receive
        
        hello -> io:format("Hello received~n")
    end
end).

% 2> Pid = process:receive_message().
% <0.91.0>
% 3> Pid ! hello.
% Hello received
% hello
% 4> Pid ! hello.
% hello
% 5> 
% If the second message is sent, 
% nothing really happens because the process has already terminated. 
% There is no longer a receiving process to handle the message, 
% but the send operator still returns the message sent.

% Excersie 4
receive_multi_messages() ->
    receive
        hello -> io:format("Hi everybody~n"),
                 receive_multi_messages();
        goodbye -> io:format("Goodbye everybody~n"),
                    receive_multi_messages();
        {payment, Amount} -> io:format("payment received: ~p~n", [Amount]),
        receive_multi_messages();
        stop -> io:format("process terminated~n"),
        ok
end.
% 6> c(process).
% {ok,process}
% 9> Pid = spawn(process, receive_multi_messages,[]).
% <0.108.0>
% 10> Pid ! hello.
% Hi everybody
% hello
% 11> Pid ! goodbye.
% Goodbye everybody
% goodbye
% 13> Pid ! {payment, 222}.
% payment received: 222
% {payment,222}
% 14> Pid ! stop.
% process terminated
% stop
% 15> is_process_alive(Pid).
% false
% 

% Exercise 5
receive_with_timeout() ->
    receive 
        hello -> io:format("Message Received ~n")
    after
        3000 -> io:format("Timeout ~n")
    end.
% 2> self() ! hello.
% hello
% 3> process:receive_with_timeout().
% Message Received 
% ok
% 4> process:receive_with_timeout().
% Timeout 
% ok


% Exercise 6
start_counter() ->
    % Exercise 8 (Added to register the counter)
    register(counter, self()),
    counter(0).

counter(Count) ->
    receive 
        increment -> counter(Count + 1);
        decrement -> counter(Count - 1);
        {get, From} ->
            % Exercise 11
            From ! {result, Count},
            counter(Count);
        stop ->
        io:format("Terminated the Process~n"),
        % Exercise 8: unregister the counter
        unregister(counter);
        _ -> counter(Count)
end.

result_counter() ->
    receive
        {result, Count} ->
            {result, Count}
after
    3000 -> io:format("Timeout~n")
end.
% 7> c(process).
% {ok,process}
% 8> Pid = spawn(process, start_counter, []).
% <0.104.0>
% 9> Pid ! increment.
% increment
% 10> Pid ! increment.
% increment
% 11> Pid ! decrement.
% decrement
% 12> Pid ! {get, self()}.
% {get,<0.84.0>}
% 15> Pid ! {get, self()}.
% {get,<0.110.0>}
% 16> process:result_counter().
% {result,1}
% 17> process:result_counter().
% Timeout
% ok
% 18> Pid ! {get, self()}.
% {get,<0.110.0>}
% 19> process:result_counter().
% {result,1}
% 20> Pid ! wrong_format.
% wrong_format
% 21> Pid ! {get, self()}.
% {get,<0.110.0>}
% 22> process:result_counter().
% {result,1}
% 23> Pid ! stop.
% Terminated the Process
% stop
% 24> is_process_alive(Pid).
% false


% %%%% Exercise 8
% 61> c(process).
% {ok,process}
% 62> Pid = spawn(process, start_counter, []).
% <0.204.0>
% 63> whereis(counter).
% <0.204.0>
% 64> counter ! increment.
% increment
% 65> counter ! increment.
% increment
% 66> counter ! decrement.
% decrement
% 67> counter ! {get, self()}.
% {get,<0.187.0>}
% 68> process:result_counter().
% {result,1}
% 69> counter ! stop.
% Terminated the Process
% stop
% 70> whereis(counter).
% undefined


% Exercise 10
selective_receive() ->
    receive
        {payment, Amount} when is_number(Amount)-> 
            io:format("Received payment of: ~p~n", [Amount]),
            selective_receive()
    end.

% It will only match a tuple whose first element is the atom
% payment and whose second element is a numeric value.
% The other messages will be skipped and remain in the mailbox
% until a matching message is found. If unmatched messages keep
% accumulating, they can consume more memory and potentially
% exhaust the process's available memory.

% 15> c(process).
% {ok,process}
% 16> Pid = spawn(process, selective_receive,[]).
% <0.113.0>
% 17> Pid ! hello.
% hello
% 18> Pid ! {notification, "Welcome"}.
% {notification,"Welcome"}
% 19> Pid ! {payment, 500}.
% Received payment of: 500
% {payment,500}
% 20> 

chat_receiver() ->
    receive
        {send, Username, Message} ->
            io:format("user ~p sent a Message: ~p~n", [Username, Message]),
            chat_receiver();
        stop ->
            io:format("process terminated~n")
    end.

% 23> c(process).
% {ok,process}
% 24> Pid = spawn(process, chat_receiver, []).
% <0.132.0>
% 25> Pid ! {send, jaefer, "Hello everyone!"}.
% user jaefer sent a Message: "Hello everyone!"
% {send,jaefer,"Hello everyone!"}
% 26> Pid ! {send, alice, "Hi there!"}.
% user alice sent a Message: "Hi there!"
% {send,alice,"Hi there!"}
% 27> Pid ! {send, bob, "How are you?"}.
% user bob sent a Message: "How are you?"
% {send,bob,"How are you?"}
% 28> Pid ! stop.
% process terminated
% stop
% 29> is_process_alive(Pid).
% false