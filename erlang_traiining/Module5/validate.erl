-module(validate).
-export([worker/0, worker2/0,  validate_email/1, safe_divide/2,
test_process_link/0, trap_test_process_link/0, test_process_monitor/0,
test_noproc_monitor/0, test_process_demonitor/0, process_resource/1,
process_payment/1]).


check_email(Email) ->
    case re:run(Email, "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$") of 
        {match, _} -> {ok, Email};
        nomatch -> throw(invalid_email)

    end.

% Exercise 1
validate_email(Email) ->
    try
        check_email(Email)
    catch
        throw:Reason -> {error, Reason}
    end.

% Throwing an exception means raising an exception to signal that a problem or special condition has occurred. 
% The exception propagates up the call stack until a matching catch clause handles it. 
% If it is not caught, it may cause the process to terminate.

% Catching an exception means handling a raised exception 
% so that the program can recover or return an appropriate result 
% instead of letting the exception propagate further.

% Exercise 2
safe_divide(X, Y) when is_number(X), is_number(Y), 
    Y == 0 ->
        {error, division_by_zero};

safe_divide(X, Y) when is_number(X), is_number(Y)->
        {ok, X/Y};
safe_divide(_, _) ->
    {error, invalid_input}.


% Exercise 3
worker() ->
    timer:sleep(1000),
    exit(worker_failed).

test_process_link()->
    Pid = spawn_link(?MODULE, worker, []),
    timer:sleep(2000),
    {self(), Pid}.

% 42> validate:test_process_link().
% ** exception exit: worker_failed

% - What happens to a linked process when its partner exits abnormally?
% When a linked process exits with an abnormal reason,
%  such as worker_failed, the exit signal is propagated 
% to its linked partner. 
% If the receiving process isn't trapping exits, 
% it also terminates.

% - Does a normal exit have the same effect?
% No. An exit reason of normal generally does not terminate a linked partner that isn't trapping exits. 
% Abnormal exit reasons normally do.

% - Why can linking be useful in fault-tolerant systems?
% Linking is useful when processes are closely related 
% and a failure in one should affect the other. 
% It allows failures to propagate instead of leaving dependent 
% processes running in an invalid state.

% In OTP systems, supervisors use links to detect worker 
% failures and restart processes according to a supervision 
% strategy. This helps build systems that recover from 
% individual process failures.


% Exercise 4
trap_test_process_link()->
    process_flag(trap_exit, true),
    WorkerPid = spawn_link(?MODULE, worker, []),
    receive
        {'EXIT', WorkerPid, worker_failed} ->
            io:format("Worker exited: worker_failed~n")
    after 3000 ->
        io:format("No exit message received~n")
    end.


% When `process_flag(trap_exit, true)` is enabled, 
% an exit signal is converted into a message with the structure
% `{'EXIT', Pid, Reason}`. The process can then receive 
% and inspect the message, log the failure, perform cleanup, 
% or take other recovery actions.

% This is useful in fault-tolerant systems because a 
% process can respond to another process's failure rather than 
% immediately terminating itself. A supervisor can use this 
% mechanism to detect worker failures and restart workers 
% according to its supervision strategy.

worker2() ->
    timer:sleep(2000),
    ok.

% Exercise 5
test_process_monitor() ->
    WorkerPid = spawn(?MODULE, worker2, []),
    MonitorRef = monitor(process, WorkerPid),
    
    receive
        {'DOWN', MonitorRef, process, WorkerPid, Reason} ->
            io:format("Worker ~p stopped: ~p~n", [WorkerPid, Reason])
    
    after 3000 ->
        erlang:demonitor(MonitorRef, [flush]),
        io:format("Monitor timeout~n")
    end.

% Monitoring a worker won't automatically terminate the 
% monitoring process because monitoring is one-way observation.
% It allows the monitoring process to receive a `DOWN` message 
% when the worker terminates, so it can inspect the reason and 
% decide what to do next.

% Exercise 6
test_noproc_monitor() ->
    WorkerPid = spawn(fun() -> ok end),
    timer:sleep(1000),
    MonitorRef = monitor(process, WorkerPid),
    
    receive
        {'DOWN', MonitorRef, process, WorkerPid, Reason} ->
            io:format("Worker ~p stopped: ~p~n", [WorkerPid, Reason])
    
    after 3000 ->
        erlang:demonitor(MonitorRef, [flush]),
        io:format("Monitor timeout~n")
    end.

% Because monitoring observes a process directly, 
% Erlang can determine whether the process is still alive 
% when the monitor is created. If the process has already 
% terminated or doesn't exist, the monitor can immediately 
% send a DOWN message with the reason noproc, 
% instead of waiting for a timeout.

% Exercise 7
test_process_demonitor() ->
    WorkerPid = spawn(?MODULE, worker2, []),
    MonitorRef = monitor(process, WorkerPid),
    
    receive
        {'DOWN', MonitorRef, process, WorkerPid, Reason} ->
            io:format("Worker ~p stopped: ~p~n", [WorkerPid, Reason])
    
    after 1000 ->
        erlang:demonitor(MonitorRef, [flush]),
        receive
            {'DOWN', MonitorRef, process, WorkerPid, Reason} ->
                io:format("Unexpected DOWN: ~p~n", [Reason])
        after 0 ->
            io:format("No pending DOWN message for this monitor~n")
    end
      
    end.
% 75> validate:test_process_demonitor().
% Monitor timeout
% ok

% If an old `DOWN` message remains in the mailbox, 
% a later task might accidentally process it and 
% mistake an earlier worker's termination for the 
% current worker's failure. This can cause incorrect 
% decisions or unwanted actions. That's why we use 
% `demonitor(Ref, [flush])` to cancel the monitor and 
% remove any pending `DOWN` message associated with that 
% monitor.


% Exercise 9
resource_check(Resource) ->
    case Resource of
        success -> {ok, success};
        failure -> throw(failure);
        _ -> throw(something_went_wrong)
    end.

process_resource(Resource) ->
    io:format("Opening resource~n"),
    try 
    resource_check(Resource)
    catch
        throw:Reason -> {error, Reason}
    after 
        io:format("Closing the resource ~n"),
        ok
    end.


% The `after` block ensures that cleanup code runs 
% whether processing finishes successfully or an exception 
% occurs. However, it does not catch or prevent an exception 
% from propagating. It simply guarantees that the cleanup code
% executes when control reaches the `after` block, after which
% the original result or exception continues as appropriate.


% Exercise 10
% process_payment(Amount) ->
%     try
%         1000 / Amount
%     catch
%         _:_ ->
%             ignored
%     end.

% 1. If Amount is zero, 1000 / Amount raises an 
% arithmetic exception (error:badarith). 
% The catch block catches it. In the original function, 
% the exception is hidden and the function returns ignored.

% 2. It catches every exception regardless of what caused it.
% We can't identify the issue or reason behind the failure 
% from the returned value, and the application may continue 
% as if nothing went wrong.

% 3.
process_payment(Amount) ->
    try
        1000 / Amount
    catch
        Class:Reason:Stacktrace ->
        logger:error("Processing failed: ~p:~p ~p",
                    [Class, Reason, Stacktrace]),
        {error, {Class, Reason}}
    end.

% 4.
% Supervision: Helps restart failed processes according to a
%  defined strategy.
% Monitoring: Lets a process receive a DOWN message when 
% another process terminates, so it can inspect the
% exit reason and decide what to do.
% Clear error reporting: Shows what failed and why, 
% helping the application or developer decide whether to retry,
% report the error, recover, or terminate related work


% % Discussion question: Why is “Let It Crash” about controlled failure and recovery rather than ignoring errors?
% We don't want a process to crash because of errors that can 
% reasonably be handled, such as invalid input from a user. 
% However, when an unexpected failure occurs, 
% it's often better to let the process fail clearly rather 
% than hide the problem and leave it in an unknown or 
% incorrect state.
% Erlang isolates processes, so one process crashing 
% does not automatically crash unrelated processes. 
% Supervisors can detect failures and restart processes 
% according to a recovery strategy. However, we shouldn't a
% ssume that every crash will fix itself through restarting.
% A process that repeatedly crashes and restarts can consume
% resources, and restarting won't fix a persistent underlying 
% problem.

% Let It Crash means allowing failures to be visible and c
% ontained so the system can recover deliberately and 
% not ignoring errors or restarting blindly.
