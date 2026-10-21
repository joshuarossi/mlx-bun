import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 512
host_chunk_read_tail_eager P 513
host_chunk_read_tail_eager P 514
host_chunk_read_tail_eager P 515
host_chunk_read_tail_eager P 516
host_chunk_read_tail_eager P 517
host_chunk_read_tail_eager P 518
host_chunk_read_tail_eager P 519
host_chunk_read_tail_eager P 520
host_chunk_read_tail_eager P 521
host_chunk_read_tail_eager P 522
host_chunk_read_tail_eager P 523
host_chunk_read_tail_eager P 524
host_chunk_read_tail_eager P 525
host_chunk_read_tail_eager P 526
host_chunk_read_tail_eager P 527
host_chunk_read_tail_eager P 528
host_chunk_read_tail_eager P 529
host_chunk_read_tail_eager P 530
host_chunk_read_tail_eager P 531
host_chunk_read_tail_eager P 532
host_chunk_read_tail_eager P 533
host_chunk_read_tail_eager P 534
host_chunk_read_tail_eager P 535
host_chunk_read_tail_eager P 536
host_chunk_read_tail_eager P 537
host_chunk_read_tail_eager P 538
host_chunk_read_tail_eager P 539
host_chunk_read_tail_eager P 540
host_chunk_read_tail_eager P 541
host_chunk_read_tail_eager P 542
host_chunk_read_tail_eager P 543

/- Chunks 512 … 543: boundary 512 to boundary 544 for every unread suffix. -/
tail_compose P P.tailGroup16 :=
  P.tac512 P.tac513 P.tac514 P.tac515 P.tac516 P.tac517 P.tac518 P.tac519
  P.tac520 P.tac521 P.tac522 P.tac523 P.tac524 P.tac525 P.tac526 P.tac527
  P.tac528 P.tac529 P.tac530 P.tac531 P.tac532 P.tac533 P.tac534 P.tac535
  P.tac536 P.tac537 P.tac538 P.tac539 P.tac540 P.tac541 P.tac542 P.tac543

end Host.Load.Run.Full
