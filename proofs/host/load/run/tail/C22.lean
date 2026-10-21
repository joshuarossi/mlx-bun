import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 704
host_chunk_read_tail_eager P 705
host_chunk_read_tail_eager P 706
host_chunk_read_tail_eager P 707
host_chunk_read_tail_eager P 708
host_chunk_read_tail_eager P 709
host_chunk_read_tail_eager P 710
host_chunk_read_tail_eager P 711
host_chunk_read_tail_eager P 712
host_chunk_read_tail_eager P 713
host_chunk_read_tail_eager P 714
host_chunk_read_tail_eager P 715
host_chunk_read_tail_eager P 716
host_chunk_read_tail_eager P 717
host_chunk_read_tail_eager P 718
host_chunk_read_tail_eager P 719
host_chunk_read_tail_eager P 720
host_chunk_read_tail_eager P 721
host_chunk_read_tail_eager P 722
host_chunk_read_tail_eager P 723
host_chunk_read_tail_eager P 724
host_chunk_read_tail_eager P 725
host_chunk_read_tail_eager P 726
host_chunk_read_tail_eager P 727
host_chunk_read_tail_eager P 728
host_chunk_read_tail_eager P 729
host_chunk_read_tail_eager P 730
host_chunk_read_tail_eager P 731
host_chunk_read_tail_eager P 732
host_chunk_read_tail_eager P 733
host_chunk_read_tail_eager P 734
host_chunk_read_tail_eager P 735

/- Chunks 704 … 735: boundary 704 to boundary 736 for every unread suffix. -/
tail_compose P P.tailGroup22 :=
  P.tac704 P.tac705 P.tac706 P.tac707 P.tac708 P.tac709 P.tac710 P.tac711
  P.tac712 P.tac713 P.tac714 P.tac715 P.tac716 P.tac717 P.tac718 P.tac719
  P.tac720 P.tac721 P.tac722 P.tac723 P.tac724 P.tac725 P.tac726 P.tac727
  P.tac728 P.tac729 P.tac730 P.tac731 P.tac732 P.tac733 P.tac734 P.tac735

end Host.Load.Run.Full
