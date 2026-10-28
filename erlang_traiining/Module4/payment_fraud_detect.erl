-module(payment_fraud_detect).
-export([payment_check/1, fraud_detect/0, notification/0]).

payment_check(Amount) ->
    Pid = spawn(fun() -> fraud_detect() end),
    Pid2 = spawn(fun() -> notification() end),
    Pid ! {payment, self(), Amount},
    receive
        {payment_success, Msg} ->
            Pid2 ! {paymentsuccess, Msg},
            Msg
    after
        3000 ->
            {error, timeout}
    end.

fraud_detect() ->
    receive
        {payment, PaymentSenderId, Amount} when Amount > 0 ->
            PaymentSenderId ! {payment_success, "approved"};

        {payment, PaymentSenderId, _ } ->
            PaymentSenderId ! {payment_success, "rejected"}
    end.

notification() ->
    receive
        {paymentsuccess, Response} ->
            io:format("Your payment status: ~p~n", [Response])
    end.
