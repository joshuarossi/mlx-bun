import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 768
host_chunk_read_tail_eager P 769
host_chunk_read_tail_eager P 770
host_chunk_read_tail_eager P 771
host_chunk_read_tail_eager P 772
host_chunk_read_tail_eager P 773
host_chunk_read_tail_eager P 774
host_chunk_read_tail_eager P 775
host_chunk_read_tail_eager P 776
host_chunk_read_tail_eager P 777
host_chunk_read_tail_eager P 778
host_chunk_read_tail_eager P 779
host_chunk_read_tail_eager P 780
host_chunk_read_tail_eager P 781
host_chunk_read_tail_eager P 782
host_chunk_read_tail_eager P 783
host_chunk_read_tail_eager P 784
host_chunk_read_tail_eager P 785
host_chunk_read_tail_eager P 786
host_chunk_read_tail_eager P 787
host_chunk_read_tail_eager P 788
host_chunk_read_tail_eager P 789
host_chunk_read_tail_eager P 790
host_chunk_read_tail_eager P 791
host_chunk_read_tail_eager P 792
host_chunk_read_tail_eager P 793
host_chunk_read_tail_eager P 794
host_chunk_read_tail_eager P 795
host_chunk_read_tail_eager P 796
host_chunk_read_tail_eager P 797
host_chunk_read_tail_eager P 798
host_chunk_read_tail_eager P 799

/- Chunks 768 … 799: boundary 768 to boundary 800 for every unread suffix. -/
tail_compose P P.tailGroup24 :=
  P.tac768 P.tac769 P.tac770 P.tac771 P.tac772 P.tac773 P.tac774 P.tac775
  P.tac776 P.tac777 P.tac778 P.tac779 P.tac780 P.tac781 P.tac782 P.tac783
  P.tac784 P.tac785 P.tac786 P.tac787 P.tac788 P.tac789 P.tac790 P.tac791
  P.tac792 P.tac793 P.tac794 P.tac795 P.tac796 P.tac797 P.tac798 P.tac799

end Host.Load.Run.Full
