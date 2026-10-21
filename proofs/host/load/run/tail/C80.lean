import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 2560
host_chunk_read_tail_eager P 2561
host_chunk_read_tail_eager P 2562
host_chunk_read_tail_eager P 2563
host_chunk_read_tail_eager P 2564
host_chunk_read_tail_eager P 2565
host_chunk_read_tail_eager P 2566
host_chunk_read_tail_eager P 2567
host_chunk_read_tail_eager P 2568
host_chunk_read_tail_eager P 2569
host_chunk_read_tail_eager P 2570
host_chunk_read_tail_eager P 2571
host_chunk_read_tail_eager P 2572
host_chunk_read_tail_eager P 2573
host_chunk_read_tail_eager P 2574
host_chunk_read_tail_eager P 2575
host_chunk_read_tail_eager P 2576
host_chunk_read_tail_eager P 2577
host_chunk_read_tail_eager P 2578
host_chunk_read_tail_eager P 2579
host_chunk_read_tail_eager P 2580
host_chunk_read_tail_eager P 2581
host_chunk_read_tail_eager P 2582
host_chunk_read_tail_eager P 2583
host_chunk_read_tail_eager P 2584
host_chunk_read_tail_eager P 2585
host_chunk_read_tail_eager P 2586
host_chunk_read_tail_eager P 2587
host_chunk_read_tail_eager P 2588
host_chunk_read_tail_eager P 2589
host_chunk_read_tail_eager P 2590
host_chunk_read_tail_eager P 2591

/- Chunks 2560 … 2591: boundary 2560 to boundary 2592 for every unread suffix. -/
tail_compose P P.tailGroup80 :=
  P.tac2560 P.tac2561 P.tac2562 P.tac2563 P.tac2564 P.tac2565 P.tac2566 P.tac2567
  P.tac2568 P.tac2569 P.tac2570 P.tac2571 P.tac2572 P.tac2573 P.tac2574 P.tac2575
  P.tac2576 P.tac2577 P.tac2578 P.tac2579 P.tac2580 P.tac2581 P.tac2582 P.tac2583
  P.tac2584 P.tac2585 P.tac2586 P.tac2587 P.tac2588 P.tac2589 P.tac2590 P.tac2591

end Host.Load.Run.Full
