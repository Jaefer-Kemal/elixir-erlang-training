% Remaining: making the requestId unique
-module(payment_system).
-export([start_worker/0, payment_worker/1, process_payment/3,
get_payment_pid/1]).

start_worker() ->
    % spawn(?MODULE, payment_worker, []),
    spawn(fun() -> watcher(0, undefined, undefined) end).


watcher(Attempt, PaymentPid, MonitorRef) ->
    Pid = if
        PaymentPid =:= undefined ->
        spawn(fun() -> payment_worker(#{}) end);
        
        true -> 
            PaymentPid
    
    end,

    Ref = if
        MonitorRef =:= undefined ->
            monitor(process, Pid);
        
        true -> 
           MonitorRef
    
    end,

    receive
        {'DOWN', Ref, process, Pid, Reason} ->
            io:format("Payment Worker ~p stopped: ~p~n", [Pid, Reason]),
            if
                Attempt < 3 ->
                    watcher(Attempt + 1, undefined, undefined);
                    
                true ->
                    io:format("It reached the maximum attempts for payment_worker, restart the watcher ~n")
                    
            end;
        {get_payment_pid, ReplyTo} ->
            ReplyTo ! {payment_worker_pid, Pid},
            watcher(Attempt, Pid, Ref)
    
    end.

get_payment_pid(WatcherPid) ->
    WatcherPid ! {get_payment_pid, self()},
    receive
        {payment_worker_pid, Pid} -> 
            Pid
    after 3000->
        io:format("Payment worker process doesnt exist ~n"),
        ok   
    end.



payment_worker(ProcessedRequests) ->
    receive
        crash_test ->
            io:format("Starting Crash Test~n"),
            % exit("Abnormally Terminated the Process~n");
            exit(simulated_failure);

        % 2nd version (with Idempotency)
        {charge, RequestId, Amount, ReplyTo} ->
            case maps:find({RequestId, ReplyTo}, ProcessedRequests) of
                {ok, StoredAmount} ->
                    if
                        Amount =/= StoredAmount ->
                            ReplyTo ! {error, RequestId, request_id_conflict, StoredAmount};
                            
                        true ->
                            ReplyTo ! {success, RequestId, StoredAmount}         
                    end,

                    payment_worker(ProcessedRequests);

                error 
                    when is_number(Amount), Amount =< 0 ->
                        ReplyTo ! {error, RequestId, invalid_amount},
                        payment_worker(ProcessedRequests); 
                
                error 
                    when is_number(Amount)->
                    ReplyTo ! {success, RequestId,  Amount},
                    UpdatedProcessedRequests = ProcessedRequests#{{RequestId, ReplyTo} => Amount},
                    payment_worker(UpdatedProcessedRequests);

                error ->
                    ReplyTo ! {error, RequestId, invalid_amount},
                    payment_worker(ProcessedRequests)
            end;
      
        _ ->
           payment_worker(ProcessedRequests)
        end.
                            


        % 1st version(No Idempotency)
        % {charge, RequestId, Amount, ReplyTo} 
        %     when is_number(Amount), Amount =< 0->
        %         ReplyTo ! {error, RequestId, invalid_amount},
        %         payment_worker();

        % {charge, RequestId, Amount, ReplyTo} 
        %     when is_number(Amount)->
        %         ReplyTo ! {success, RequestId,  Amount},
        %         payment_worker();

        % {charge, RequestId, _Amount, ReplyTo} ->
        %         ReplyTo ! {error, RequestId, invalid_amount},
        %         payment_worker();

        
        % _ ->
        %     payment_worker()
    % end.

process_payment(PaymentPid, RequestId, Amount) ->
    PaymentPid ! {charge, RequestId, Amount, self()},
    receive
        {error, RequestId, request_id_conflict, StoredAmount} ->
            io:format("The StoredAmount: ~p is not the same with the Current Amount: ~p~n",[StoredAmount, Amount]),
            {payment_result, RequestId, {error, request_id_conflict, StoredAmount}};

        {error, RequestId, invalid_amount} ->
            {payment_result, RequestId, {error, invalid_amount}};

        {success, RequestId,  Amount} ->
             {payment_result, RequestId, {ok, Amount}}

    after 5000 ->
        {payment_result, RequestId, {error, timeout}}
    end.



% - Why the watcher monitors the worker.
% Because it will be able to restart the process, when crash
% occurs 

% -Whether the watcher and worker should also be linked
% No need since we dont want the exit signal to be sent to the
% watcher if its purpose is only to observe. we can also do link 
% but we need to trap the signal 

% - What happens to in-flight requests when a worker crashes.
% That request will be lost as we cant store the state of the crashed
% process, so we need another way to handle this to ensure idompotency

% - Why restarting a worker does not guarantee that a payment was not already completed.
% Because the state is already lost when crashing happened, unless we have persistant means 
% we wont cant verify the payment completion


% 9> c(payment_system).
% {ok,payment_system}
% 10> f().
% ok
% 11> WPid = payment_system:start_worker().
% <0.121.0>
% 12> PPid = payment_system:get_payment_pid(WPid).
% <0.122.0>
% 13> payment_system:process_payment(PPid, 11, 1000).
% {payment_result,11,{ok,1000}}
% 14> payment_system:process_payment(PPid, 11, wrong_input).
% {payment_result,11,{error,invalid_amount}}
% 15> payment_system:process_payment(PPid, 11, 44).
% {payment_result,11,{ok,44}}
% 16> payment_system:process_payment(PPid, 11, 0).
% {payment_result,11,{error,invalid_amount}}
% 17> payment_system:process_payment(PPid, 11, -32).
% {payment_result,11,{error,invalid_amount}}
% 18> PPid ! crash_test.
% Starting Crash Test
% crash_test
% Payment Worker <0.122.0> stopped: "Abnormally Terminated the Process~n"
% 19> f(PPid).
% ok
% 20> PPid = payment_system:get_payment_pid(WPid).
% <0.131.0>
% 21> payment_system:process_payment(PPid, 11, 1000).
% {payment_result,11,{ok,1000}}
% 22> PPid ! crash_test.
% Starting Crash Test
% crash_test
% Payment Worker <0.131.0> stopped: "Abnormally Terminated the Process~n"
% 23> f(PPid).
% ok
% 25> PPid = payment_system:get_payment_pid(WPid).
% <0.136.0>
% 26> PPid ! crash_test.
% Starting Crash Test
% crash_test
% Payment Worker <0.136.0> stopped: "Abnormally Terminated the Process~n"
% 27> f(PPid).
% ok
% 28> PPid = payment_system:get_payment_pid(WPid).
% <0.141.0>
% 29> PPid ! crash_test.
% Starting Crash Test
% crash_test
% Payment Worker <0.141.0> stopped: "Abnormally Terminated the Process~n"
% It reached the Attempts limit for payment_worker 
% 30> 
% 30> is_process_alive(WPid).
% false
% 31> f().
% ok
% 32> WPid = payment_system:start_worker().
% <0.148.0>
% 33> PPid = payment_system:get_payment_pid(WPid).
% <0.149.0>
% 34> payment_system:process_payment(PPid, 11, 1000).
% {payment_result,11,{ok,1000}}
% 35> payment_system:process_payment(PPid, 11, 0).
% {payment_result,11,{error,invalid_amount}}
