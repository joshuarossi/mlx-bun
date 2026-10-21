import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 896
host_chunk_read_tail_eager P 897
host_chunk_read_tail_eager P 898
host_chunk_read_tail_eager P 899
host_chunk_read_tail_eager P 900
host_chunk_read_tail_eager P 901
host_chunk_read_tail_eager P 902
host_chunk_read_tail_eager P 903
host_chunk_read_tail_eager P 904
host_chunk_read_tail_eager P 905
host_chunk_read_tail_eager P 906
host_chunk_read_tail_eager P 907
host_chunk_read_tail_eager P 908
host_chunk_read_tail_eager P 909
host_chunk_read_tail_eager P 910
host_chunk_read_tail_eager P 911
host_chunk_read_tail_eager P 912
host_chunk_read_tail_eager P 913
host_chunk_read_tail_eager P 914
host_chunk_read_tail_eager P 915
host_chunk_read_tail_eager P 916
host_chunk_read_tail_eager P 917
host_chunk_read_tail_eager P 918
host_chunk_read_tail_eager P 919
host_chunk_read_tail_eager P 920
host_chunk_read_tail_eager P 921
host_chunk_read_tail_eager P 922
host_chunk_read_tail_eager P 923
host_chunk_read_tail_eager P 924
host_chunk_read_tail_eager P 925
host_chunk_read_tail_eager P 926
host_chunk_read_tail_eager P 927

/- Chunks 896 … 927: boundary 896 to boundary 928 for every unread suffix. -/
tail_compose P P.tailGroup28 :=
  P.tac896 P.tac897 P.tac898 P.tac899 P.tac900 P.tac901 P.tac902 P.tac903
  P.tac904 P.tac905 P.tac906 P.tac907 P.tac908 P.tac909 P.tac910 P.tac911
  P.tac912 P.tac913 P.tac914 P.tac915 P.tac916 P.tac917 P.tac918 P.tac919
  P.tac920 P.tac921 P.tac922 P.tac923 P.tac924 P.tac925 P.tac926 P.tac927

end Host.Load.Run.Full
