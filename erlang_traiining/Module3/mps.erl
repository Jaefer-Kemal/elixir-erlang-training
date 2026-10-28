-module(mps).
-export([create_student/3, student_info/1, update_student/2, classify_student/1, get_employee_name/1, get_user_by_dynamic_key/1]).

% Exersie 1
create_student(Name, Department, Gpa) ->
    Student = #{name => Name, department =>Department, gpa => Gpa},
    student_info(Student).

% Exersise 2
update_student(#{name := Name, age := Age, gpa := Gpa}, {new_gpa, NewGpa}) ->
    Student = #{name => Name, age => Age, gpa => Gpa},
    UpdatedStudent = Student#{gpa := NewGpa},
    UpdatedStudent#{status => active}.


% Exercise 3
student_info(#{name := Name, department := Department, gpa := Gpa}) ->
    io:format("Name ~p~n", [Name]),
    io:format("Department ~p~n", [Department]),
    io:format("Gpa ~p~n", [Gpa]),

    {Name, Gpa}.

% Exerxise 4
classify_student(#{gpa := Gpa}) when is_number(Gpa), 4 =< Gpa orelse 0 > Gpa ->
    {error, out_of_scale}; 
classify_student(#{gpa := Gpa}) when is_number(Gpa), 3.5 =< Gpa ->
    excellent; 
classify_student(#{gpa := Gpa}) when is_number(Gpa), 3.0 =< Gpa ->
    good; 
classify_student(#{gpa := Gpa}) when is_number(Gpa), 2.0 =< Gpa ->
    average; 
classify_student(#{gpa := Gpa}) when is_number(Gpa), 2.0 < Gpa ->
    poor.

% Exerxise 5 Dynamic Keys
get_user_by_dynamic_key(UserId) ->
    ID1 = 1001,
    ID2 = 1002,
    ID3 = 1003,
    Users = #{
              ID1 => "Abebe",
              ID2 => "Kebede",
              ID3 => "Almaz"  
            },
    maps:get(UserId, Users).

% Exersie 6 Records
-record(employee, {
    name,
    department = "IT",
    active = true
}).

get_employee_name(#employee{name = Name}) ->
    Name.

% Exercise 7 Record=x vs Map=y
% x- Its done at compile time, y- its done at runtime
% x- nowdays its a prefered part for JSON, y- Most old OTP libraries require the use of Record

