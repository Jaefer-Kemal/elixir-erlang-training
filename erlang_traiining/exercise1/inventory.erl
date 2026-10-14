-module(inventory).
-export([
    process_order/2,
    calculate_order_total/2,
    restock/2
]).



process_helper( [], _, NewInventory) ->
    lists:reverse(NewInventory);

process_helper([{product, Id, Name, Price, Stock} | RestOfProduct], 
                    {order, ProductId, Quantity},
                    NewInventory) 
                    when Id == ProductId,
                         Stock >= Quantity ->

                    NewStock = Stock - Quantity,
                
            process_helper(
                            [], 
                            {order, ProductId, Quantity},
                             lists:reverse(RestOfProduct) ++ [{product, Id, Name, Price, NewStock} | NewInventory] 
                            );

process_helper([{product, Id, Name, Price, Stock} | RestOfProduct], 
                    {order, ProductId, Quantity},
                    NewInventory) 
                    when Id == ProductId ->
                            process_helper(
                            [], 
                            {order, ProductId, Quantity},
                             lists:reverse(RestOfProduct) ++ [{product, Id, Name, Price, Stock} | NewInventory] 
                            );

process_helper( [Product | RestOfProduct], Order, NewInventory) ->
    process_helper( RestOfProduct, Order, [Product | NewInventory]).

restock_helper([], _, NewInventory) ->
    lists:reverse(NewInventory);

restock_helper([{product, Id, Name, Price, Stock} | RestOfProduct], 
                    {ProductId, Quantity},
                    NewInventory) 
                    when Id == ProductId ->

                    NewStock = Stock + Quantity,
                
            restock_helper(
                            [], 
                            {ProductId, Quantity},
                               lists:reverse(RestOfProduct) ++ [{product, Id, Name, Price, NewStock} | NewInventory] 
                            );

restock_helper( [Product | RestOfProduct], Restock, NewInventory) ->
    restock_helper( RestOfProduct, Restock, [Product | NewInventory]).
    

calculate_order_helper( [], _, NewTotal) ->
    NewTotal;

calculate_order_helper( [{product, Id, _, Price, Stock}|_], 
                    {order, ProductId, Quantity},
                    _) 
                    when Id == ProductId,
                         Stock >= Quantity ->

                    NewTotal = Quantity * Price,
                    
                
            calculate_order_helper(
                            [], 
                            {order, ProductId, Quantity},
                            NewTotal
                            );

calculate_order_helper( [_ | RestOfProduct], Order, Total) ->
    calculate_order_helper( RestOfProduct, Order, Total).
    


process_order(Inventory, []) ->
    Inventory;

process_order(Inventory, Orders) ->
    [Order|RestOfOrder] = Orders,
    
    NewInventory = process_helper(Inventory, Order, []),

    process_order(NewInventory, RestOfOrder).




calculate_order_total(Inventory, Orders) ->
    calculate_order_total(Inventory, Orders, 0).

calculate_order_total(_, [], SubTotal) ->
    SubTotal;

calculate_order_total(Inventory, [Order | RestOfOrder], SubTotal) ->
    CurrTotal = calculate_order_helper( Inventory, Order, 0),
    
    calculate_order_total(Inventory, RestOfOrder, SubTotal + CurrTotal).


restock(NewInventory, []) ->
    NewInventory;

restock(Inventory, Restocks) ->
    [Restock | RestOfRestock]  = Restocks,

    NewInventory = restock_helper( Inventory, Restock, []),

    restock(NewInventory, RestOfRestock).