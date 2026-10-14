-module(shopping_cart).
-export([
item_total/1,
calculate_subtotal/1,
filter_zero_qty/1,
apply_discount/2
]).

% 
item_total(Item) ->
    {_, _,_, Price, Quantity}  = Item,

    Price * Quantity.

calculate_subtotal(Cart) ->
    calculate_subtotal(Cart, 0).

calculate_subtotal([], SubTotal) -> 
    SubTotal;

calculate_subtotal([CartItem | RestOfCart], SubTotal) ->
    calculate_subtotal(RestOfCart, SubTotal + item_total(CartItem)).


filter_zero_qty(Cart) ->
    filter_zero_qty(Cart, []).

filter_zero_qty([], FilteredCart) ->
    FilteredCart;

filter_zero_qty([CartItem | RestOfCart], FilteredCart) ->
    {_, _, _,_, Quantity} = CartItem,
    
    if
        Quantity =< 0 ->
            filter_zero_qty(RestOfCart, FilteredCart);
        
        true ->
            filter_zero_qty(RestOfCart, [CartItem| FilteredCart])
    end.


apply_discount(Cart, DiscountCode) ->
    SubTotal = calculate_subtotal(Cart),


    FinalAmount = case DiscountCode of 
        vip -> SubTotal * 0.80;
        student -> SubTotal * 0.90;
        _ -> SubTotal
    end,

    {ok, FinalAmount}.



% c(shopping_cart).
% {ok,shopping_cart}
% 32> shopping_cart:item_total({item, 1, "Keyboard", 45, 2}).
% 90
% 33> shopping_cart:item_total({item, 2, "Mouse", 20, 1}).
% 20
% 34> shopping_cart:item_total({item, 3, "Monitor", 150, 0}).
% 0
% 35> shopping_cart:item_total({item, 4, "Laptop", 999.99, 3}).
% 2999.9700000000003
% 36> shopping_cart:calculate_subtotal([]).
% 0
% 37> shopping_cart:calculate_subtotal([
%         {item, 1, "Keyboard", 45, 2},
%         {item, 2, "Mouse", 20, 1}
%     ]).
% 110
% 38> shopping_cart:calculate_subtotal([
%         {item, 1, "Keyboard", 45, 2},
%         {item, 2, "Mouse", 20, 1},
%         {item, 3, "Monitor", 150, 0}
%     ]).
% 110
% 39> shopping_cart:calculate_subtotal([
%         {item, 1, "Laptop", 999.99, 1},
%         {item, 2, "Mouse", 25.5, 2},
%         {item, 3, "Keyboard", 50, 3},
%         {item, 4, "Headset", 75.75, 1}
%     ]).
% 1276.74
% 40> shopping_cart:filter_zero_qty([]).
% []
% 41> shopping_cart:filter_zero_qty([
%         {item, 1, "Keyboard", 45, 2},
%         {item, 2, "Mouse", 20, 1}
%     ]).
% [{item,2,"Mouse",20,1},{item,1,"Keyboard",45,2}]
% 42> shopping_cart:filter_zero_qty([
%         {item, 1, "Keyboard", 45, 0},
%         {item, 2, "Mouse", 20, 1},
%         {item, 3, "Monitor", 150, 0}
%     ]).
% [{item,2,"Mouse",20,1}]
% 43> shopping_cart:filter_zero_qty([
%         {item, 1, "Keyboard", 45, 0},
%         {item, 2, "Mouse", 20, 0}
%     ]).
% []
% 44> shopping_cart:filter_zero_qty([
%         {item, 1, "Keyboard", 45, -1},
%         {item, 2, "Mouse", 20, 2},
%         {item, 3, "Monitor", 150, -5},
%         {item, 4, "Laptop", 1000, 1}
%     ]).
% [{item,4,"Laptop",1000,1},{item,2,"Mouse",20,2}]
% 45> shopping_cart:apply_discount([
%         {item, 1, "Keyboard", 45, 2},
%         {item, 2, "Mouse", 20, 1}
%     ], vip).
% 88.0
% 46> shopping_cart:apply_discount([
%         {item, 1, "Keyboard", 45, 2},
%         {item, 2, "Mouse", 20, 1}
%     ], student).
% 99.0
% 47> shopping_cart:apply_discount([
%         {item, 1, "Keyboard", 45, 2},
%         {item, 2, "Mouse", 20, 1}
%     ], none).
% 110
% 48> shopping_cart:apply_discount([
%         {item, 1, "Keyboard", 45, 2},
%         {item, 2, "Mouse", 20, 1}
%     ], abc).
% 110
% 49> shopping_cart:apply_discount([], vip).
% 0.0
% 50> shopping_cart:apply_discount([], student).
% 0.0
% 51> shopping_cart:apply_discount([], none).
% 0
% 52> Cart = [
%         {item, 1, "Keyboard", 45, 2},
%         {item, 2, "Mouse", 20, 1},
%         {item, 3, "Monitor", 150, 0},
%         {item, 4, "Laptop", 999.99, 1},
%         {item, 5, "USB Cable", 7.5, 4},
%         {item, 6, "Headset", 75, 0}
%     ].
% [{item,1,"Keyboard",45,2},
%  {item,2,"Mouse",20,1},
%  {item,3,"Monitor",150,0},
%  {item,4,"Laptop",999.99,1},
%  {item,5,"USB Cable",7.5,4},
%  {item,6,"Headset",75,0}]
% 53> shopping_cart:calculate_subtotal(Cart).
% 1139.99
% 54> shopping_cart:filter_zero_qty(Cart).
% [{item,5,"USB Cable",7.5,4},
%  {item,4,"Laptop",999.99,1},
%  {item,2,"Mouse",20,1},
%  {item,1,"Keyboard",45,2}]
% 55> shopping_cart:apply_discount(Cart, vip).
% 911.9920000000001
% 56> shopping_cart:apply_discount(Cart, student).
% 1025.991
% 57> shopping_cart:apply_discount(Cart, none).
% 1139.99
% 58> shopping_cart:apply_discount(Cart, something_else).
% 1139.99
% 59> shopping_cart:apply_discount(Cart, something_else).
% 1139.99
% 60> c(shopping_cart).
% {ok,shopping_cart}
% 61> shopping_cart:apply_discount(Cart, something_else).
% {ok,1139.99}
% 62> 