-module(employee_processor).
-export([
        list_employees/1,
        get_developers/1,
        get_managers/1,
        get_high_salary/1,
        find_highest_paid/1,
        calculate_total_salary/1,
        calculate_average_salary/1]).


list_employees(Employees) ->
    Employees.

% Helper
process_employee_by_role(Employees, Role) ->
    lists:filter(fun({employee,_,_,Curr_role}) -> Curr_role =:= Role end, Employees).

get_developers(Employees) ->
    process_employee_by_role(Employees, developer).

get_managers(Employees) ->
    process_employee_by_role(Employees, manager).


get_high_salary(Employees) ->
    Salaries = lists:map(fun({_,_,Salary,_}) -> Salary end, Employees),
    lists:max(Salaries).

    
find_highest_paid(Employees) ->
    HighestSalary = get_high_salary(Employees),
    % [{_, TopName, _, _}] = lists:filter(fun({_,_, Salary,_}) -> Salary =:= HighestSalary end, Employees),
     lists:filter(fun({_,_, Salary,_}) -> Salary =:= HighestSalary end, Employees).
    % TopName. %This will only work if theres only one employee with highest salary, otherwise it will cause an match error
    % 

calculate_total_salary(Employees) ->
    Salaries = lists:map(fun({_,_,Salary,_}) -> Salary end, Employees),
    lists:foldl(fun(Salary, InAcc) -> Salary + InAcc end, 0, Salaries).

calculate_average_salary(Employees) ->
    Total = calculate_total_salary(Employees),
    Length = recur:list_length(Employees),
    Total / Length.


