%%! -kernel standard_io_encoding unicode
-module(jpeg2web).
-export([main/1]).

main(Args) ->
    FilesCount  = length(Args),
    case FilesCount of
        0 ->
            %% io:format("пустой список.~n"),
            io:format("~nИспользование: jpeg2web СписокФайлов~n~n", []),
            erlang:halt(0);
        _ ->
            DirName = filename:dirname(hd(Args)),
            ok = file:set_cwd(DirName),
            file:make_dir("_web"),
            io:format("Принято в обработку ~p файлов.~n~n", [FilesCount])
    end,
    NumCores    = erlang:system_info(logical_processors_available),
    NumWorkers  = if
        NumCores >= FilesCount -> FilesCount;
        true -> NumCores
    end,
    {ok, ProducerPid} = gen_server:start_link(producer, Args, []),
    io:format("Запускаю ~b потоков для обработки~n", [NumWorkers]),
    WorkerPids = lists:foldr(fun(_N, WorkerPids) ->
                    {ok, WPid} = gen_server:start_link(worker, ProducerPid, []),
                    [WPid| WorkerPids]
    end, [], lists:seq(1, NumWorkers) ),
    ProducerPid ! {consumerlist, WorkerPids},
    [WPid ! start || WPid <- WorkerPids],
    timer:sleep(infinity),
    ok.
