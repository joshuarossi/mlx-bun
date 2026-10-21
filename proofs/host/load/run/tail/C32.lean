import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 1024
host_chunk_read_tail_eager P 1025
host_chunk_read_tail_eager P 1026
host_chunk_read_tail_eager P 1027
host_chunk_read_tail_eager P 1028
host_chunk_read_tail_eager P 1029
host_chunk_read_tail_eager P 1030
host_chunk_read_tail_eager P 1031
host_chunk_read_tail_eager P 1032
host_chunk_read_tail_eager P 1033
host_chunk_read_tail_eager P 1034
host_chunk_read_tail_eager P 1035
host_chunk_read_tail_eager P 1036
host_chunk_read_tail_eager P 1037
host_chunk_read_tail_eager P 1038
host_chunk_read_tail_eager P 1039
host_chunk_read_tail_eager P 1040
host_chunk_read_tail_eager P 1041
host_chunk_read_tail_eager P 1042
host_chunk_read_tail_eager P 1043
host_chunk_read_tail_eager P 1044
host_chunk_read_tail_eager P 1045
host_chunk_read_tail_eager P 1046
host_chunk_read_tail_eager P 1047
host_chunk_read_tail_eager P 1048
host_chunk_read_tail_eager P 1049
host_chunk_read_tail_eager P 1050
host_chunk_read_tail_eager P 1051
host_chunk_read_tail_eager P 1052
host_chunk_read_tail_eager P 1053
host_chunk_read_tail_eager P 1054
host_chunk_read_tail_eager P 1055

/- Chunks 1024 … 1055: boundary 1024 to boundary 1056 for every unread suffix. -/
tail_compose P P.tailGroup32 :=
  P.tac1024 P.tac1025 P.tac1026 P.tac1027 P.tac1028 P.tac1029 P.tac1030 P.tac1031
  P.tac1032 P.tac1033 P.tac1034 P.tac1035 P.tac1036 P.tac1037 P.tac1038 P.tac1039
  P.tac1040 P.tac1041 P.tac1042 P.tac1043 P.tac1044 P.tac1045 P.tac1046 P.tac1047
  P.tac1048 P.tac1049 P.tac1050 P.tac1051 P.tac1052 P.tac1053 P.tac1054 P.tac1055

end Host.Load.Run.Full
