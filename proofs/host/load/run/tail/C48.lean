import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 1536
host_chunk_read_tail_eager P 1537
host_chunk_read_tail_eager P 1538
host_chunk_read_tail_eager P 1539
host_chunk_read_tail_eager P 1540
host_chunk_read_tail_eager P 1541
host_chunk_read_tail_eager P 1542
host_chunk_read_tail_eager P 1543
host_chunk_read_tail_eager P 1544
host_chunk_read_tail_eager P 1545
host_chunk_read_tail_eager P 1546
host_chunk_read_tail_eager P 1547
host_chunk_read_tail_eager P 1548
host_chunk_read_tail_eager P 1549
host_chunk_read_tail_eager P 1550
host_chunk_read_tail_eager P 1551
host_chunk_read_tail_eager P 1552
host_chunk_read_tail_eager P 1553
host_chunk_read_tail_eager P 1554
host_chunk_read_tail_eager P 1555
host_chunk_read_tail_eager P 1556
host_chunk_read_tail_eager P 1557
host_chunk_read_tail_eager P 1558
host_chunk_read_tail_eager P 1559
host_chunk_read_tail_eager P 1560
host_chunk_read_tail_eager P 1561
host_chunk_read_tail_eager P 1562
host_chunk_read_tail_eager P 1563
host_chunk_read_tail_eager P 1564
host_chunk_read_tail_eager P 1565
host_chunk_read_tail_eager P 1566
host_chunk_read_tail_eager P 1567

/- Chunks 1536 … 1567: boundary 1536 to boundary 1568 for every unread suffix. -/
tail_compose P P.tailGroup48 :=
  P.tac1536 P.tac1537 P.tac1538 P.tac1539 P.tac1540 P.tac1541 P.tac1542 P.tac1543
  P.tac1544 P.tac1545 P.tac1546 P.tac1547 P.tac1548 P.tac1549 P.tac1550 P.tac1551
  P.tac1552 P.tac1553 P.tac1554 P.tac1555 P.tac1556 P.tac1557 P.tac1558 P.tac1559
  P.tac1560 P.tac1561 P.tac1562 P.tac1563 P.tac1564 P.tac1565 P.tac1566 P.tac1567

end Host.Load.Run.Full
