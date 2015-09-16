-module(beam_stats_process).

-include("include/beam_stats_process.hrl").

-export_type(
    [ t/0
    , status/0
    ]).

-export(
    [ of_pid/1
    , print/1
    ]).

-type status() ::
      exiting
    | garbage_collecting
    | runnable
    | running
    | suspended
    | waiting
    .

-define(T, #?MODULE).

-type t() ::
    ?T{}.

%% ============================================================================
%% Public API
%% ============================================================================

-spec of_pid(pid()) ->
    t().
of_pid(Pid) ->
    Dict = pid_info_exn(Pid, dictionary),
    ?T
    { pid               = Pid
    , registered_name   = pid_info_opt(Pid, registered_name)
    , raw_initial_call  = pid_info_exn(Pid, initial_call)
    , otp_initial_call  = hope_kv_list:get(Dict, '$initial_call')
    , otp_ancestors     = hope_kv_list:get(Dict, '$ancestors')
    , status            = pid_info_exn(Pid, status)
    , memory            = pid_info_exn(Pid, memory)
    , total_heap_size   = pid_info_exn(Pid, total_heap_size)
    , stack_size        = pid_info_exn(Pid, stack_size)
    , message_queue_len = pid_info_exn(Pid, message_queue_len)
    }.

-spec print(t()) ->
    ok.
print(
    ?T
    { pid               = Pid
    , registered_name   = RegisteredNameOpt
    , raw_initial_call  = InitialCallRaw
    , otp_initial_call  = InitialCallOTPOpt
    , otp_ancestors     = AncestorsOpt
    , status            = Status
    , memory            = Memory
    , total_heap_size   = TotalHeapSize
    , stack_size        = StackSize
    , message_queue_len = MsgQueueLen
    }
) ->
    io:format("--------------------------------------------------~n"),
    io:format(
        "Pid               : ~p~n"
        "RegisteredNameOpt : ~p~n"
        "InitialCallRaw    : ~p~n"
        "InitialCallOTPOpt : ~p~n"
        "AncestorsOpt      : ~p~n"
        "Status            : ~p~n"
        "Memory            : ~p~n"
        "TotalHeapSize     : ~p~n"
        "StackSize         : ~p~n"
        "MsgQueueLen       : ~p~n"
        "~n",
        [ Pid
        , RegisteredNameOpt
        , InitialCallRaw
        , InitialCallOTPOpt
        , AncestorsOpt
        , Status
        , Memory
        , TotalHeapSize
        , StackSize
        , MsgQueueLen
        ]
    ).

%% ============================================================================
%% Private helpers
%% ============================================================================

pid_info_exn(Pid, Key) ->
    {some, Value} = pid_info_opt(Pid, Key),
    Value.

pid_info_opt(Pid, Key) ->
    case {Key, erlang:process_info(Pid, Key)}
    of  {registered_name, []}           -> none
    ;   {_              , {Key, Value}} -> {some, Value}
    end.