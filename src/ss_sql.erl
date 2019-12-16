%%%-------------------------------------------------------------------
%%% @author 张超 <zhangchao@zhangchao>
%%% @copyright (C) 2019, 张超
%%% @doc
%%%
%%% @end
%%% Created : 13 Dec 2019 by 张超 <zhangchao@zhangchao>
%%%-------------------------------------------------------------------
-module(ss_sql).

%% API
-export([get_seats/2,
         insert_session_mapping/5,
         insert_session/5,
         get_session/2]).

%%%===================================================================
%%% API
%%%===================================================================

get_seatids(LServer, BusID) ->
    ejabberd_sql:sql_query(LServer,
                           [<<"select seat_id from busi_seat_mapping where busi_id='">>, BusID, <<"';">>]).

%% busi_supplier_mapping (supplier_id, busi_id, busi_supplier_id, bsuid_and_type) VALUES (1, 1, '23', '231');
get_busid(LServer, ShopID) ->
    ejabberd_sql:sql_query(LServer,
                           [<<"select busi_id from busi_supplier_mapping where supplier_id='">>, ShopID, <<"';">>]).

get_seats(LServer, SeatIDs) ->
    SeatStr = append_binary(SeatIDs, <<",">>, <<>>),
    ejabberd_sql:sql_query(LServer,
                           [<<"select qunar_name from seat where id in ( ">>, SeatStr, <<" );">>]).

append_binary([Item], _Char, Str) ->
    <<Str/binary, Item/binary>>;
append_binary([Item|Last], Char, Str) ->
    append_binary(Last, Char, <<Str/binary, Item/binary, Char/binary>>).

insert_session_mapping(LServer, CustomName, ShopID, SessionID, SeatName) ->
    ejabberd_sql:sql_query(LServer,
                           [<<"insert into session_mapping(customer_name,shop_id,session_id, seat_name) values ('">>,
                            CustomName, <<"', '">>,
                            ShopID, <<"', '">>,
                            SessionID, <<"', '">>,
                            SeatName, <<"');">>]).

%% UserName = mucID
%% SeatName = FirstSeatName
insert_session(LServer, SessionID, MucID, SeatName, ShopName) ->
    ejabberd_sql:sql_query(LServer,
                           [<<"insert into session(session_id,user_name,seat_name, shop_name) values ('">>,
                            SessionID, <<"', '">>,
                            MucID, <<"', '">>,
                            SeatName, <<"', '">>,
                            ShopName, <<"');">>]).

get_session(LServer, MucID) ->
    ejabberd_sql:sql_query(LServer,
                           [<<"select session_id, seat_name, shop_name from session where user_name='">>, MucID, <<"';">>]).

%%%===================================================================
%%% Internal functions
%%%===================================================================
