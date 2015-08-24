-module(beam_stats_state).

-include("include/beam_stats.hrl").

-export_type(
    [ t/0
    ]).

-export(
    [ new/0
    , update/1
    , export/1
    ]).

-record(?MODULE,
    { timestamp             :: erlang:timestamp()
    , node_id               :: atom()
    , memory                :: [{atom(), non_neg_integer()}]
    , previous_io_bytes_in  :: non_neg_integer()
    , previous_io_bytes_out :: non_neg_integer()
    , current_io_bytes_in   :: non_neg_integer()
    , current_io_bytes_out  :: non_neg_integer()
    }).

-define(T, #?MODULE).

-opaque t() ::
    ?T{}.

-spec new() ->
    t().
new() ->
    { {input  , CurrentIOBytesIn}
    , {output , CurrentIOBytesOut}
    } = erlang:statistics(io),
    ?T
    { timestamp             = os:timestamp()
    , node_id               = erlang:node()
    , memory                = erlang:memory()
    , previous_io_bytes_in  = 0
    , previous_io_bytes_out = 0
    , current_io_bytes_in   = CurrentIOBytesIn
    , current_io_bytes_out  = CurrentIOBytesOut
    }.

-spec update(t()) ->
    t().
update(?T
    { previous_io_bytes_in  = PreviousIOBytesIn
    , previous_io_bytes_out = PreviousIOBytesOut
    }
) ->
    { {input  , CurrentIOBytesIn}
    , {output , CurrentIOBytesOut}
    } = erlang:statistics(io),
    ?T
    { timestamp             = os:timestamp()
    , node_id               = erlang:node()
    , memory                = erlang:memory()
    , previous_io_bytes_in  = PreviousIOBytesIn
    , previous_io_bytes_out = PreviousIOBytesOut
    , current_io_bytes_in   = CurrentIOBytesIn
    , current_io_bytes_out  = CurrentIOBytesOut
    }.

-spec export(t()) ->
    beam_stats:t().
export(
    ?T
    { timestamp             = Timestamp
    , node_id               = NodeID
    , memory                = Memory
    , previous_io_bytes_in  = PreviousIOBytesIn
    , previous_io_bytes_out = PreviousIOBytesOut
    , current_io_bytes_in   = CurrentIOBytesIn
    , current_io_bytes_out  = CurrentIOBytesOut
    }
) ->
    #beam_stats
    { timestamp    = Timestamp
    , node_id      = NodeID
    , memory       = Memory
    , io_bytes_in  = CurrentIOBytesIn  - PreviousIOBytesIn
    , io_bytes_out = CurrentIOBytesOut - PreviousIOBytesOut
    }.