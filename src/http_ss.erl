%%%-------------------------------------------------------------------
%%% @author 张超 <zhangchao@zhangchao>
%%% @copyright (C) 2019, 张超
%%% @doc
%%%
%%% @end
%%% Created : 13 Dec 2019 by 张超 <zhangchao@zhangchao>
%%%-------------------------------------------------------------------
-module(http_ss).

%% API
-export([init/3, handle/2, terminate/3]).

-include("ejabberd.hrl").
-include("logger.hrl").

%%%===================================================================
%%% API
%%%===================================================================
init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {Path, _} = cowboy_req:path_info(Req),
    {ok, Req1} = handle_process(Path, Req),
    {ok, Req1, State}.

terminate(_Reason, _Req, _State) ->
    ok.

handle_process([<<"consumerMsg">>], Req) ->
    {Method, Req1} = cowboy_req:method(Req),
    case Method of
        <<"POST">> ->
            handle_ss(Req1);
        _ ->
            http_utils:cowboy_req_reply_json(http_utils:gen_fail_result(1, <<Method/binary, " is not disable">>), Req1)
    end.

handle_ss(Req) ->
    {ok, Body, Req1} = cowboy_req:body(Req),
    case rfc4627:decode(Body) of
        {ok, {obj,Args},[]} ->
            Type = proplists:get_value("type",Args, <<"consult">>),
            Res = handle_ss_msg(Type, Args),
            http_utils:cowboy_req_reply_json(Res, Req1);
        _ ->
            http_utils:cowboy_req_reply_json(http_utils:gen_fail_result(1, <<"Josn parse error">>), Req1)
    end.

handle_ss_msg(<<"consult">>, Args) ->
    Topic = proplists:get_value("topic",Args),
    MFrom = proplists:get_value("m_from",Args),
    FromHost = proplists:get_value("from_host",Args),
    MTo = proplists:get_value("m_to",Args),
    ToHost = proplists:get_value("to_host",Args),
    MBody  = proplists:get_value("m_body",Args),
    CreateTime = proplists:get_value("create_time",Args),
    MsgID = proplists:get_value("msg_id",Args),
    RealFrom = proplists:get_value("realfrom",Args),
    RealTo = proplists:get_value("realto",Args),
    UserType = proplists:get_value("userType",Args),
    ?INFO_MSG("############# args ~p ~n", [{Topic, MFrom, FromHost, MTo, ToHost, MBody, CreateTime, MsgID, RealFrom, RealTo, UserType}]),
    %% 1. 创建群组
    MucDomain = <<<<"conference.">>/binary, ToHost/binary>>,
    Servers = ejabberd_config:get_myhosts(),
    LServer = lists:nth(1,Servers),
    MucCreateArgs = [
               {"muc_name", MTo},
               {"muc_id", MFrom},
               {"muc_owner", MTo},
               {"muc_owner_host", ToHost},
               {"muc_desc", <<"this is ss room">>},
               {"muc_domain", MucDomain}
              ],
    CreateMucRet = http_muc_create:create_muc(MucCreateArgs),
    ?INFO_MSG("this is create muc result ~p ~n", [CreateMucRet]),
    case check_http_result(CreateMucRet) of
        true ->
            %% 2. 添加客服人员进群
            %% 获取客服人员
            [_, ShopIDList] = re:split(MTo,"[_]",[{return,list}]),
            ShopID = erlang:list_to_binary(ShopIDList),
            Seats = get_seats(LServer, ShopID),
            %% 添加成员
            MucAddUserArgs = [
                              {"muc_id", MFrom},
                              {"muc_owner", MTo},
                              {"muc_owner_host", ToHost},
                              {"muc_domain", MucDomain},
                              {"muc_member", Seats}
                             ],
            http_muc_add_user:add_muc_users(MucAddUserArgs),
            [FirstSeat|_] = Seats,
            send_auto_reply(MTo, MFrom, FirstSeat, ToHost),
            insert_session_mapping(ShopID, RealTo, MTo, MFrom, MFrom, FirstSeat);
        false ->
            ?INFO_MSG("this is multi muc xxxxxxxx ~n", []),
            ignore
    end,
    %% 3. 发送消息
    %% 取出真正的消息
    Packet = fxml_stream:parse_element(MBody),
    Body = fxml:get_subtag_cdata(Packet, <<"body">>),
    SendMsgArgs = [
                   {"From", MTo},
                   {"To", [{obj,[{"User",MFrom}]}]},
                   {"Body", Body},
                   {"Type", <<"groupchat">>},
                   {"Msg_Type", <<"1">>},
                   {"Host", ToHost},
                   {"Domain", MucDomain}
                  ],
    ?INFO_MSG("starting send message to muc ~p ~n", [SendMsgArgs]),
    SendMsgRet = http_send_message:http_send_message(SendMsgArgs),
    ?INFO_MSG("ending send message ~p ~n", [SendMsgRet]),
    http_utils:gen_success_result();
handle_ss_msg(<<"groupchat">>, Args) ->
    %% {<<"groupchat">>,<<"dcce03d04eaf47e0a367a7805249fa73">>,<<"conference.qtalk">>,<<"qtalk">>,<<229,188,160,232,182,133>>,<<"<message from='dcce03d04eaf47e0a367a7805249fa73@conference.qtalk/chao.zhang_qtalk' to='dcce03d04eaf47e0a367a7805249fa73@conference.qtalk' sendjid='chao.zhang@qtalk' realfrom='chao.zhang@qtalk' msec_times='1576230549270' isHiddenMsg='0' type='groupchat'><body id='D439470324EF4FC8AAC4DAB77C83ADF6' maType='6' msgType='1'>111</body><active xmlns='http://jabber.org/protocol/chatstates'/></message>">>,<<"1">>,0,1576230549270,<<"D439470324EF4FC8AAC4DAB77C83ADF6">>,<<"chao.zhang@qtalk">>,[<<"chao.zhang@qtalk">>,<<"shop_1@qtalk">>]}
    Topic = proplists:get_value("topic",Args),
    MucRoomName = proplists:get_value("muc_room_name",Args),
    RoomHost = proplists:get_value("room_host",Args),
    Host  = proplists:get_value("host",Args),
    Nick = proplists:get_value("nick",Args),
    MBody = proplists:get_value("packet",Args),
    HaveSubject = proplists:get_value("have_subject",Args),
    Size = proplists:get_value("size",Args),
    CreateTime = proplists:get_value("create_time",Args),
    MsgID = proplists:get_value("msg_id",Args),
    RealFrom = proplists:get_value("realfrom",Args),
    UserList = proplists:get_value("userlist",Args),
    ?INFO_MSG("######### args ~p ~n", [{Topic, MucRoomName, RoomHost, Host, Nick, MBody, HaveSubject, Size, CreateTime, MsgID, RealFrom, UserList}]),
    Packet = fxml_stream:parse_element(MBody),
    Body = fxml:get_subtag_cdata(Packet, <<"body">>),
    case is_http_send(MsgID) == false andalso get_session(MucRoomName) of
        {SessionID, _SeatName, ShopName} ->
            SendMsgArgs = [
                           {"From", ShopName},
                           {"To", [{obj,[{"User",SessionID}]}]},
                           {"Body", Body},
                           {"Type", <<"chat">>},
                           {"Msg_Type", <<"1">>},
                           {"Host", Host},
                           {"Domain", Host}
                          ],
            ShopJIDStr = <<ShopName/binary, "@", Host/binary>>,
            case RealFrom =/= ShopJIDStr of
                true ->
                    ?INFO_MSG("starting send message to consutor ~p ~n", [{RealFrom, ShopName, Host, SendMsgArgs}]),
                    SendMsgRet = http_send_message:http_send_message(SendMsgArgs),
                    ?INFO_MSG("ending send message to consutor ~p ~n", [SendMsgRet]);
                false ->
                    ignore
            end;
        undefined ->
            ignore;
        false ->
            ignore
    end,
    http_utils:gen_success_result();
handle_ss_msg(Type, Args) ->
    ?INFO_MSG("this is ignore msg ~p ~n", [{Type, Args}]),
    http_utils:gen_success_result().

is_http_send(<<"http_", _/binary>>) ->
    true;
is_http_send(_) ->
    false.


%%%===================================================================
%%% Internal functions
%%%===================================================================
get_seats(LServer, ShopID) ->
    BusID = get_busid(LServer, ShopID),
    SeatIDs = get_seatids(LServer, BusID),
    case catch ss_sql:get_seats(LServer, SeatIDs) of
        {selected, _, SeatNames} ->
            lists:flatten(SeatNames);
        Error ->
            ?ERROR_MSG("get seats error ~p ~n", [Error]),
            []
    end.

get_busid(LServer, ShopID) ->
    case catch ss_sql:get_busid(LServer, ShopID) of
        {selected, _, [[BusID]]} ->
            BusID;
        Error ->
            ?ERROR_MSG("get busid error ~p ~n", [Error]),
            undefined
    end.

get_seatids(LServer, BusID) ->
    case catch ss_sql:get_seatids(LServer, BusID) of
        {selected, _, SeatIds} ->
            lists:flatten(SeatIds);
        Error ->
            ?ERROR_MSG("get seatids error ~p ~n", [Error]),
            []
    end.

check_http_result(RetJson) ->
    case rfc4627:decode(RetJson) of
        {ok,{obj,Ret}, []} ->
            case proplists:get_value("errcode", Ret, undefined) of
                <<"0">> ->
                    true;
                _Other ->
                    false
            end;
        _ ->
            false
    end.


send_auto_reply(From, To, RealFrom, Host) ->
    ?INFO_MSG("this is auto reply ~p ~n", [{From, To, RealFrom, Host}]),
    FromJID = jlib:make_jid(From, Host, <<>>),
    ToJID = jlib:make_jid(To, Host, <<>>),
    FromJIDStr = jlib:jid_to_string(FromJID),
    ToJIDStr = jlib:jid_to_string(ToJID),
    RealFromJIDStr = jlib:jid_to_string(jlib:make_jid(RealFrom, Host, <<>>)),
    Packet = make_message_packet(FromJIDStr, ToJIDStr, RealFromJIDStr),
    ejabberd_router:route(FromJID, ToJID, Packet),
    ok.
make_message_packet(FromJIDStr, ToJIDStr, RealFromJIDStr) ->
    Now = qtalk_public:get_exact_timestamp(),
    Bid = list_to_binary("qcadmin" ++ binary_to_list(randoms:get_string()) ++ integer_to_list(qtalk_public:get_exact_timestamp())),
    fxml:to_xmlel(
      {xmlel,
       <<"message">>,
       [{<<"from">>,FromJIDStr},
        {<<"to">>,ToJIDStr},
        {<<"msec_times">>,integer_to_binary(Now)},
        {<<"realfrom">>,RealFromJIDStr},
        {<<"realto">>,ToJIDStr},
        {<<"type">>,<<"consult">>},
        {<<"channelid">>,
         <<"{\"d\":\"recv\",\"usrType\":\"usr\",\"cn\":\"consult\"}">>},
        {<<"qchatid">>,<<"5">>},
        {<<"auto_reply">>,<<"true">>},
        {<<"no_update_msg_log">>,<<"true">>}],
       [{xmlel,<<"body">>,
         [{<<"id">>, Bid},
          {<<"msgType">>,<<"1">>},
          {<<"maType">>,<<"3">>}],
         [{xmlcdata, <<"HI, What can I do for you">>}]},
       {xmlel, <<"active">>, [], []}]}).


insert_session_mapping(ShopID, CustomName, ShopName, SessionID, MucID, SeatName) ->
    Servers = ejabberd_config:get_myhosts(),
    LServer = lists:nth(1,Servers),
    %% insert session
    ?INFO_MSG("init session mapping ~p ~n", [{ShopID, CustomName, ShopName, SessionID, MucID, SeatName}]),
    ss_sql:insert_session(LServer, SessionID, MucID, SeatName, ShopName),
    ss_sql:insert_session_mapping(LServer, CustomName, ShopID, SessionID, SeatName).

get_session(MucID) ->
    Servers = ejabberd_config:get_myhosts(),
    LServer = lists:nth(1,Servers),
    case catch ss_sql:get_session(LServer, MucID) of
        {selected, _, [[SessionID, SeatName, ShopName]]} ->
            {SessionID, SeatName, ShopName};
        Error ->
            ?DEBUG("get session error ~p ~n", [Error]),
            undefined
    end.
