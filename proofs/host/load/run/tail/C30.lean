import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 960
host_chunk_read_tail_eager P 961
host_chunk_read_tail_eager P 962
host_chunk_read_tail_eager P 963
host_chunk_read_tail_eager P 964
host_chunk_read_tail_eager P 965
host_chunk_read_tail_eager P 966
host_chunk_read_tail_eager P 967
host_chunk_read_tail_eager P 968
host_chunk_read_tail_eager P 969
host_chunk_read_tail_eager P 970
host_chunk_read_tail_eager P 971
host_chunk_read_tail_eager P 972
host_chunk_read_tail_eager P 973
host_chunk_read_tail_eager P 974
host_chunk_read_tail_eager P 975
host_chunk_read_tail_eager P 976
host_chunk_read_tail_eager P 977
host_chunk_read_tail_eager P 978
host_chunk_read_tail_eager P 979
host_chunk_read_tail_eager P 980
host_chunk_read_tail_eager P 981
host_chunk_read_tail_eager P 982
host_chunk_read_tail_eager P 983
host_chunk_read_tail_eager P 984
host_chunk_read_tail_eager P 985
host_chunk_read_tail_eager P 986
host_chunk_read_tail_eager P 987
host_chunk_read_tail_eager P 988
host_chunk_read_tail_eager P 989
host_chunk_read_tail_eager P 990
host_chunk_read_tail_eager P 991

/- Chunks 960 … 991: boundary 960 to boundary 992 for every unread suffix. -/
tail_compose P P.tailGroup30 :=
  P.tac960 P.tac961 P.tac962 P.tac963 P.tac964 P.tac965 P.tac966 P.tac967
  P.tac968 P.tac969 P.tac970 P.tac971 P.tac972 P.tac973 P.tac974 P.tac975
  P.tac976 P.tac977 P.tac978 P.tac979 P.tac980 P.tac981 P.tac982 P.tac983
  P.tac984 P.tac985 P.tac986 P.tac987 P.tac988 P.tac989 P.tac990 P.tac991

end Host.Load.Run.Full
