-module(worker).
-behaviour(gen_server).
-export([start_link/1, init/1, handle_info/2, handle_cast/2, handle_call/3]).

start_link(ProducerPid) ->
	gen_server:start_link([], ?MODULE, ProducerPid, []).

init(ProducerPid) ->
	{ok, ProducerPid}.

handle_info(start, ProducerPid) ->
	ProducerPid ! {get, self()},
	{noreply, ProducerPid};

handle_info({next, Fname}, ProducerPid) ->
	case run_process(Fname) of
		ok -> ok;
		_  -> io:format("Error happened with ~ts~n", [Fname])
	end,
	ProducerPid ! {get, self()},
	{noreply, ProducerPid};

handle_info(stop, ProducerPid) ->
	{stop, normal, ProducerPid}.

run_process(Filename) ->
	io:format("~ts~n", [Filename]),
	BaseName = filename:basename(Filename),
	os:cmd(io_lib:format("/usr/bin/magick '~ts' -scale 1600x -strip '_web/~ts'", [Filename, BaseName])),
	ok.

handle_call(_, _, State) -> {reply, no, State}.
handle_cast(_, State) -> {noreply, State}.
