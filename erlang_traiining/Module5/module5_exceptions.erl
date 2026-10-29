-module(module5_exceptions).
-export([check_amount/1, safe_check/1,
 check_payment/1]).

check_amount(Amount) when is_number(Amount), Amount > 0 ->
    {ok, Amount};
check_amount(_) ->
    throw(invalid_payment_amount).

safe_check(Amount) ->
    try
        module5_exceptions:check_amount(Amount)
    catch
        throw:Reason -> {error, Reason};
        error:Reason -> {error, {runtime_error, Reason}};
        exit:Reason -> {error, {exit_reason, Reason}}
    end.



check_payment(0) ->
    throw(amount_must_be_positive);

check_payment(Amount) when Amount < 0 ->
    error(negative_amount);

check_payment(Amount) when is_number(Amount) ->
    {ok, Amount};

check_payment(_) ->
    exit(invalid_payment_data).


