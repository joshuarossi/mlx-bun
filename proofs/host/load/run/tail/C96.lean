import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 3072
host_chunk_read_tail_eager P 3073
host_chunk_read_tail_eager P 3074
host_chunk_read_tail_eager P 3075
host_chunk_read_tail_eager P 3076
host_chunk_read_tail_eager P 3077
host_chunk_read_tail_eager P 3078
host_chunk_read_tail_eager P 3079
host_chunk_read_tail_eager P 3080
host_chunk_read_tail_eager P 3081
host_chunk_read_tail_eager P 3082
host_chunk_read_tail_eager P 3083
host_chunk_read_tail_eager P 3084
host_chunk_read_tail_eager P 3085
host_chunk_read_tail_eager P 3086
host_chunk_read_tail_eager P 3087
host_chunk_read_tail_eager P 3088
host_chunk_read_tail_eager P 3089
host_chunk_read_tail_eager P 3090
host_chunk_read_tail_eager P 3091
host_chunk_read_tail_eager P 3092
host_chunk_read_tail_eager P 3093
host_chunk_read_tail_eager P 3094
host_chunk_read_tail_eager P 3095
host_chunk_read_tail_eager P 3096
host_chunk_read_tail_eager P 3097
host_chunk_read_tail_eager P 3098
host_chunk_read_tail_eager P 3099
host_chunk_read_tail_eager P 3100
host_chunk_read_tail_eager P 3101
host_chunk_read_tail_eager P 3102
host_chunk_read_tail_eager P 3103

/- Chunks 3072 … 3103: boundary 3072 to boundary 3104 for every unread suffix. -/
tail_compose P P.tailGroup96 :=
  P.tac3072 P.tac3073 P.tac3074 P.tac3075 P.tac3076 P.tac3077 P.tac3078 P.tac3079
  P.tac3080 P.tac3081 P.tac3082 P.tac3083 P.tac3084 P.tac3085 P.tac3086 P.tac3087
  P.tac3088 P.tac3089 P.tac3090 P.tac3091 P.tac3092 P.tac3093 P.tac3094 P.tac3095
  P.tac3096 P.tac3097 P.tac3098 P.tac3099 P.tac3100 P.tac3101 P.tac3102 P.tac3103

end Host.Load.Run.Full
