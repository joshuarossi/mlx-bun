import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 800
host_chunk_read_tail_eager P 801
host_chunk_read_tail_eager P 802
host_chunk_read_tail_eager P 803
host_chunk_read_tail_eager P 804
host_chunk_read_tail_eager P 805
host_chunk_read_tail_eager P 806
host_chunk_read_tail_eager P 807
host_chunk_read_tail_eager P 808
host_chunk_read_tail_eager P 809
host_chunk_read_tail_eager P 810
host_chunk_read_tail_eager P 811
host_chunk_read_tail_eager P 812
host_chunk_read_tail_eager P 813
host_chunk_read_tail_eager P 814
host_chunk_read_tail_eager P 815
host_chunk_read_tail_eager P 816
host_chunk_read_tail_eager P 817
host_chunk_read_tail_eager P 818
host_chunk_read_tail_eager P 819
host_chunk_read_tail_eager P 820
host_chunk_read_tail_eager P 821
host_chunk_read_tail_eager P 822
host_chunk_read_tail_eager P 823
host_chunk_read_tail_eager P 824
host_chunk_read_tail_eager P 825
host_chunk_read_tail_eager P 826
host_chunk_read_tail_eager P 827
host_chunk_read_tail_eager P 828
host_chunk_read_tail_eager P 829
host_chunk_read_tail_eager P 830
host_chunk_read_tail_eager P 831

/- Chunks 800 … 831: boundary 800 to boundary 832 for every unread suffix. -/
tail_compose P P.tailGroup25 :=
  P.tac800 P.tac801 P.tac802 P.tac803 P.tac804 P.tac805 P.tac806 P.tac807
  P.tac808 P.tac809 P.tac810 P.tac811 P.tac812 P.tac813 P.tac814 P.tac815
  P.tac816 P.tac817 P.tac818 P.tac819 P.tac820 P.tac821 P.tac822 P.tac823
  P.tac824 P.tac825 P.tac826 P.tac827 P.tac828 P.tac829 P.tac830 P.tac831

end Host.Load.Run.Full
