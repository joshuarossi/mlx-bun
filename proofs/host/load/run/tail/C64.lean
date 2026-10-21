import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 2048
host_chunk_read_tail_eager P 2049
host_chunk_read_tail_eager P 2050
host_chunk_read_tail_eager P 2051
host_chunk_read_tail_eager P 2052
host_chunk_read_tail_eager P 2053
host_chunk_read_tail_eager P 2054
host_chunk_read_tail_eager P 2055
host_chunk_read_tail_eager P 2056
host_chunk_read_tail_eager P 2057
host_chunk_read_tail_eager P 2058
host_chunk_read_tail_eager P 2059
host_chunk_read_tail_eager P 2060
host_chunk_read_tail_eager P 2061
host_chunk_read_tail_eager P 2062
host_chunk_read_tail_eager P 2063
host_chunk_read_tail_eager P 2064
host_chunk_read_tail_eager P 2065
host_chunk_read_tail_eager P 2066
host_chunk_read_tail_eager P 2067
host_chunk_read_tail_eager P 2068
host_chunk_read_tail_eager P 2069
host_chunk_read_tail_eager P 2070
host_chunk_read_tail_eager P 2071
host_chunk_read_tail_eager P 2072
host_chunk_read_tail_eager P 2073
host_chunk_read_tail_eager P 2074
host_chunk_read_tail_eager P 2075
host_chunk_read_tail_eager P 2076
host_chunk_read_tail_eager P 2077
host_chunk_read_tail_eager P 2078
host_chunk_read_tail_eager P 2079

/- Chunks 2048 … 2079: boundary 2048 to boundary 2080 for every unread suffix. -/
tail_compose P P.tailGroup64 :=
  P.tac2048 P.tac2049 P.tac2050 P.tac2051 P.tac2052 P.tac2053 P.tac2054 P.tac2055
  P.tac2056 P.tac2057 P.tac2058 P.tac2059 P.tac2060 P.tac2061 P.tac2062 P.tac2063
  P.tac2064 P.tac2065 P.tac2066 P.tac2067 P.tac2068 P.tac2069 P.tac2070 P.tac2071
  P.tac2072 P.tac2073 P.tac2074 P.tac2075 P.tac2076 P.tac2077 P.tac2078 P.tac2079

end Host.Load.Run.Full
