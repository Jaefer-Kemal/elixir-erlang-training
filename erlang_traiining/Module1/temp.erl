-module(temp).
-export([temp_converter/1]).

temp_converter(T) ->
    case T of
        {celsius, C} when is_number(C) -> 
            {fahrenheit, (C * 9/5) + 32};

        {fahrenheit, F} when is_number(F) -> 
            {celsius, (F - 32) * 5/9};
            
        _ -> {error, invalid_scale}
end.




