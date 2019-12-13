-module(http_service).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
                        terminate/2,code_change/3]).

-export([start/2]).
-export([stop/1]).

-behaviour(gen_server).

-include("ejabberd.hrl").
-include("logger.hrl").

-record(state, {info}).

start_link(Info) ->
    gen_server:start_link(?MODULE, [Info], [Info]).

init([Info]) ->
    {ok, #state{info = Info}, 0}.

handle_call(Msg, _From, State) ->
    {reply, {ok, Msg}, State}.

handle_cast(stop, State) ->
    {stop, normal, State}.

handle_info(timeout,State =  #state{info = Opts} ) ->
    start(<<"">>,Opts),
    {noreply,State}.

terminate(_Reason, State) ->
    {ok,State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

start(_Type, Args) ->
    ?DEBUG("this is start http service ~p ~n", [Args]),
    HttpName = gen_mod:get_opt(name, Args, fun(A) -> A end, []),
    Dispatches = gen_mod:get_opt(dispatches, Args, fun(A) -> A end, []),
    Dispatchers = lists:map(fun(Dp) ->
                      [Map, Mod] = re:split(Dp,"[:]",[{return,list}]),
                      {Map, erlang:list_to_atom(Mod), []}
              end, Dispatches),
    Dispatch = cowboy_router:compile([{'_', Dispatchers}]),
    Http_port = gen_mod:get_opt(http_port, Args, fun(A) -> A end, 10050),
    cowboy:stop_listener(HttpName),

    {ok,_} = cowboy:start_http(HttpName, 200, [{port,Http_port}], [
        {env, [{dispatch, Dispatch},{max_connections, infinity}]}
    ]).

stop(_State) ->
    ok.
