-module(bin).
-export([get_size/1, extract/0, parse_bin/1, 
parse_flag/1, encode_message/1, decode_message/1,
build_packet/3, parse_packet/1, parse_endianness/1,
parse_frames/1, encode_file/2, decode_file/1,
encode_payment/4, decode_payment/1 ]).

% Exercise 8
get_size(Name) -> 

    io:format("byte size: ~p~n",[byte_size(Name)]),
    io:format("bit size: ~p~n",[bit_size(Name)]).

% Exercise 9
extract() ->
    Data = <<"Hello World">>,
    <<First:40, Rest/binary>> = Data,
    io:format("First: ~p~n",[<<First:40>>]),
    io:format("Rest: ~p~n",[Rest]).
    % <<First:5/binary, Rest/binary>> = Data,
    % io:format("First: ~p~n",[First]),
    % io:format("Rest: ~p~n",[Rest]).

% Exercise 10
parse_bin(<<Id:16, Age:8, Status:8>>) ->
    <<Id, Age, Status>>.

% Exercise 11
parse_flag(<<Active:1, Verified:1, Admin:1, Reserved:5>>) ->
    Data = #{
            active => Active,
            verified => Verified,
            admin => Admin,
            reserved => Reserved
            },
    Data.

% Excerise 12
build_packet(Version, Type, Payload) ->
    Length = byte_size(Payload),
    <<
        Version:8,
        Type:8,
        Length:16,
        Payload/binary
    >>.

% Exercise 13
parse_packet(
        <<
        Version:8,
        Type:8,
        Length:16,
        Payload:Length/binary
        >>
) ->
    #{
    version => Version,
    type => Type,
    length => Length,
    payload => Payload
}.

% Exercise 14
parse_endianness(Binary) ->
    <<Big:16/big>> = Binary,
    <<Little:16/little>> = Binary,

    io:format("currently the binary is: ~p~n", [Binary]),
    io:format("using big endian result: ~p~n", [Big]),
    io:format("using little endian result: ~p~n", [Little]).
% % bin:parse_endianness(<<3,232>>).
% currently the binary is: <<3,232>>

% using big endian result: 1000 - <<3,232>>
% using little endian result: 59395 - <<232,3>>

% % bin:parse_endianness(<<232, 3>>).
% currently the binary is: <<232,3>>

% using big endian result: 59395 - <<232,3>>
% using little endian result: 1000 - <<3,232>>
% The default in erlang is big endian... and it means that it takes the most significant byte
% little endian will reverse the order, so it be considered to be taking the least significant byte

% Exercise 15
encode_message(Message) ->
    MessageLength = byte_size(Message),
    <<MessageLength:16, Message/binary>>.

decode_message(
            <<MessageLength:16,
              Message:MessageLength/binary>>
) ->
    #{
    length => MessageLength,
    message => Message
    }.

% Exercise 16
parse_frames(Bin) ->
    parse_frames(Bin, []).

parse_frames(<<>>, Acc) ->
    lists:reverse(Acc);

parse_frames(<<Length:16, Payload:Length/binary, Rest/binary>>, Acc) ->
    parse_frames(Rest, [Payload | Acc]).
%  bin:parse_frames(<<0, 3, "cat", 0, 2, "hi">>).

% Exercise 17
encode_file(Magic, Payload) ->
    Version = 1,
    Flags = 0,
    Length = byte_size(Payload),
    <<Magic:4/binary, Version:8, Flags:8, Length:32, Payload/binary>>.

decode_file(
            <<  "ETAI",
                Version: 8,
                Flags: 8,
                Length: 32,
                Payload:Length/binary>>
    ) ->
        #{
            version => Version,
            flags => Flags,
            payload => Payload}.



% Mini Projecy
encode_payment(UserId, Amount, Currency, MsgType) 
    when 
        is_integer(UserId) andalso UserId =< 16#FFFFFFFF,
        is_integer(MsgType) andalso MsgType > 0 andalso MsgType < 2, 
        is_binary(Currency) andalso byte_size(Currency) =:= 3,
        is_integer(Amount) andalso Amount >= 0 andalso Amount =< 16#FFFFFFFFFFFFFFFF->
            
    <<1:8,MsgType:8, UserId:32, Amount:64, Currency:3/binary>>;

encode_payment(_,_,_,_) ->
    {error, invalid_packet}.

decode_payment(<<1:8, MsgType:8, UserId:32, Amount:64, Currency:3/binary>>) 
    when 
        is_integer(UserId) andalso UserId =< 16#FFFFFFFF andalso UserId >= 0,
        is_integer(MsgType) andalso MsgType > 0 andalso MsgType < 2, 
        is_binary(Currency) andalso byte_size(Currency) =:= 3,
        is_integer(Amount) andalso Amount >= 0 andalso Amount =< 16#FFFFFFFFFFFFFFFF ->

    #{
    version => 1,
    msg_type => MsgType,
    user_id => UserId,
    amount => Amount,
    currency => Currency
    };

decode_payment(_) ->
    {error, invalid_packet}.

