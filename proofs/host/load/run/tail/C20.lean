import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 640
host_chunk_read_tail_eager P 641
host_chunk_read_tail_eager P 642
host_chunk_read_tail_eager P 643
host_chunk_read_tail_eager P 644
host_chunk_read_tail_eager P 645
host_chunk_read_tail_eager P 646
host_chunk_read_tail_eager P 647
host_chunk_read_tail_eager P 648
host_chunk_read_tail_eager P 649
host_chunk_read_tail_eager P 650
host_chunk_read_tail_eager P 651
host_chunk_read_tail_eager P 652
host_chunk_read_tail_eager P 653
host_chunk_read_tail_eager P 654
host_chunk_read_tail_eager P 655
host_chunk_read_tail_eager P 656
host_chunk_read_tail_eager P 657
host_chunk_read_tail_eager P 658
host_chunk_read_tail_eager P 659
host_chunk_read_tail_eager P 660
host_chunk_read_tail_eager P 661
host_chunk_read_tail_eager P 662
host_chunk_read_tail_eager P 663
host_chunk_read_tail_eager P 664
host_chunk_read_tail_eager P 665
host_chunk_read_tail_eager P 666
host_chunk_read_tail_eager P 667
host_chunk_read_tail_eager P 668
host_chunk_read_tail_eager P 669
host_chunk_read_tail_eager P 670
host_chunk_read_tail_eager P 671

/- Chunks 640 … 671: boundary 640 to boundary 672 for every unread suffix. -/
tail_compose P P.tailGroup20 :=
  P.tac640 P.tac641 P.tac642 P.tac643 P.tac644 P.tac645 P.tac646 P.tac647
  P.tac648 P.tac649 P.tac650 P.tac651 P.tac652 P.tac653 P.tac654 P.tac655
  P.tac656 P.tac657 P.tac658 P.tac659 P.tac660 P.tac661 P.tac662 P.tac663
  P.tac664 P.tac665 P.tac666 P.tac667 P.tac668 P.tac669 P.tac670 P.tac671

end Host.Load.Run.Full
