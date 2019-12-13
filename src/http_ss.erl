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
    %% {<<"chat">>,<<"b7065d1015294608b1c61c2f2a345389">>,<<"qtalk">>,<<"shop_1">>,<<"qtalk">>,<<"<message msec_times='1576223382035' type='consult' from='b7065d1015294608b1c61c2f2a345389@qtalk/web-5812118' to='shop_1@qtalk' realfrom='b7065d1015294608b1c61c2f2a345389@qtalk' realto='admin@qtalk' channelid='{&quot;cn&quot;:&quot;consult&quot;,&quot;d&quot;:&quot;send&quot;,&quot;usrType&quot;:&quot;usr&quot;}' qchatid='4' isHiddenMsg='0'><body msgType='1' maType='6' id='7B56C32CF8874C19FDFEA7BB60202D33'>1</body><active xmlns='http://jabber.org/protocol/chatstates'/></message>">>,1576223382035,<<"7B56C32CF8874C19FDFEA7BB60202D33">>,<<"b7065d1015294608b1c61c2f2a345389@qtalk">>,<<"admin@qtalk">>,undefined}
    %% MucID = MFrom,
    %% MucName = MTo,
    %% MucOwner = MTo,
    %% MucOwnerHost = ToHost,
    %% MucDesc = MTo,
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
            http_muc_add_user:add_muc_users(MucAddUserArgs);
        false ->
            ignore
    end,
    %% 3. 发送消息
    %% From = proplists:get_value("From",Args),
    %% To = proplists:get_value("To",Args),
    %% Body = proplists:get_value("Body",Args),
    %% Type = proplists:get_value("Type",Args,<<"chat">>),
    %% Msg_Type  = proplists:get_value("Msg_Type",Args),
    %% Host = proplists:get_value("Host",Args,Server),
    %% Domain = proplists:get_value("Domain",Args),
    %% Extend_Info = proplists:get_value("Extend_Info",Args,<<"">>),
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
    Topic = proplists:get_value("topic",Args),
    MucRoomName = proplists:get_value("muc_room_name",Args),
    RoomHost = proplists:get_value("room_host",Args),
    Host  = proplists:get_value("host",Args),
    Nick = proplists:get_value("nick",Args),
    Packet = proplists:get_value("packet",Args),
    HaveSubject = proplists:get_value("have_subject",Args),
    Size = proplists:get_value("size",Args),
    CreateTime = proplists:get_value("create_time",Args),
    MsgID = proplists:get_value("msg_id",Args),
    RealFrom = proplists:get_value("realfrom",Args),
    UserList = proplists:get_value("userlist",Args),
    ?INFO_MSG("######### args ~p ~n", [{Topic, MucRoomName, RoomHost, Host, Nick, Packet, HaveSubject, Size, CreateTime, MsgID, RealFrom, UserList}]),
    http_utils:gen_success_result().

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_seats(LServer, ShopID) ->
    BusID = get_busid(LServer, ShopID),
    SeatIDs = get_seatids(LServer, BusID),
    case catch ss_sql:get_seats(LServer, SeatIDs) of
        {selected, _, [SeatNames]} ->
            SeatNames;
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
        {selected, _, [SeatIds]} ->
            SeatIds;
        Error ->
            ?ERROR_MSG("get seatids error ~p ~n", [Error]),
            []
    end.

check_http_result(RetJson) ->
    case rfc4627:decode(RetJson) of
        {ok,{obj,Ret}, []} ->
            case proplists:get_value(errcode, Ret, undefined) of
                <<"0">> ->
                    true;
                _Other ->
                    false
            end;
        _ ->
            false
    end.
