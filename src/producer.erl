-module(producer).
-behaviour(gen_server).
-export([start_link/1, init/1, handle_info/2, handle_cast/2, handle_call/3]).

start_link(Filelist) ->
	gen_server:start_link({global, ?MODULE}, ?MODULE, Filelist, []).

init(Filelist) ->
	io:format("producer: Получен список из ~b файлов.~n", [length(Filelist)]),
	{ok, {Filelist, []}}.

handle_info({consumerlist, ConsumerPids}, {Filelist, _}) ->
	{noreply, {Filelist, ConsumerPids}};

handle_info({get, Consumer}, {[], ConsumerPids}) ->
	Consumer ! stop,
	UpdConsumerPids = lists:delete(Consumer, ConsumerPids),
	case UpdConsumerPids of
		[] -> erlang:halt(0);
		_  -> ok
	end,
	{noreply, {[], UpdConsumerPids}};

handle_info({get, Consumer}, {[Fname | Filenames], ConsumerPids}) ->
	Consumer ! {next, Fname},
	{noreply, {Filenames, ConsumerPids}}.

handle_call(_, _, State) -> {reply, no, State}.
handle_cast(_, State) -> {noreply, State}.
