import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 576
host_chunk_read_tail_eager P 577
host_chunk_read_tail_eager P 578
host_chunk_read_tail_eager P 579
host_chunk_read_tail_eager P 580
host_chunk_read_tail_eager P 581
host_chunk_read_tail_eager P 582
host_chunk_read_tail_eager P 583
host_chunk_read_tail_eager P 584
host_chunk_read_tail_eager P 585
host_chunk_read_tail_eager P 586
host_chunk_read_tail_eager P 587
host_chunk_read_tail_eager P 588
host_chunk_read_tail_eager P 589
host_chunk_read_tail_eager P 590
host_chunk_read_tail_eager P 591
host_chunk_read_tail_eager P 592
host_chunk_read_tail_eager P 593
host_chunk_read_tail_eager P 594
host_chunk_read_tail_eager P 595
host_chunk_read_tail_eager P 596
host_chunk_read_tail_eager P 597
host_chunk_read_tail_eager P 598
host_chunk_read_tail_eager P 599
host_chunk_read_tail_eager P 600
host_chunk_read_tail_eager P 601
host_chunk_read_tail_eager P 602
host_chunk_read_tail_eager P 603
host_chunk_read_tail_eager P 604
host_chunk_read_tail_eager P 605
host_chunk_read_tail_eager P 606
host_chunk_read_tail_eager P 607

/- Chunks 576 … 607: boundary 576 to boundary 608 for every unread suffix. -/
tail_compose P P.tailGroup18 :=
  P.tac576 P.tac577 P.tac578 P.tac579 P.tac580 P.tac581 P.tac582 P.tac583
  P.tac584 P.tac585 P.tac586 P.tac587 P.tac588 P.tac589 P.tac590 P.tac591
  P.tac592 P.tac593 P.tac594 P.tac595 P.tac596 P.tac597 P.tac598 P.tac599
  P.tac600 P.tac601 P.tac602 P.tac603 P.tac604 P.tac605 P.tac606 P.tac607

end Host.Load.Run.Full
