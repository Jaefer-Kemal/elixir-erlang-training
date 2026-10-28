-module(payment_server).
-export([start/0, process_payment/2, get_stats/1]).

start() ->
    case whereis(payment_server) of
        undefined ->
            Stats = #{
                    total => 0, 
                    successful => 0,
                    failed => 0},
            register(payment_server, self()),
            server(Stats);
        _Pid ->
            {error, already_started}
    end.



server(#{
    total := Total, 
    successful := Successful,
    failed := Failed
    }) ->

    receive
        {payment, Amount, From} when is_integer(Amount) 
        andalso Amount > 0 ->
            Stats = #{
                    total => Total + 1, 
                    successful => Successful + 1,
                    failed => Failed},
            From ! {payment_result, ok, Stats},
            server(Stats);

        {payment, _, From} ->
                    Stats = #{
                            total => Total + 1, 
                            successful => Successful,
                            failed => Failed + 1},
            From ! {payment_result, error, Stats},
            
            server(Stats);
        {stats, From} ->
            Stats = #{
                    total => Total, 
                    successful => Successful,
                    failed => Failed},
            From ! {stats_result, Stats},
            server(Stats);
        stop ->
            unregister(payment_server),
            io:format("Terminating the Process...~n"),
            ok
            
    end.

process_payment(Pid, Amount) ->
    Pid ! {payment, Amount, self()},

    receive
        {payment_result, ok, Stats} ->
            {payment_success, Stats};
        {payment_result, error, Stats} ->
            {payment_fail, Stats}
    after
        3000 ->
            {error, timeout_occured}
        
    end.

get_stats(Pid) ->
    Pid ! {stats, self()},
    receive
        {stats_result, Stats} ->
            {result, Stats}
    
    after
        3000 ->
            {error, timeout_occured}
    
    end.
