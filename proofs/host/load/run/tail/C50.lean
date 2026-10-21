import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 1600
host_chunk_read_tail_eager P 1601
host_chunk_read_tail_eager P 1602
host_chunk_read_tail_eager P 1603
host_chunk_read_tail_eager P 1604
host_chunk_read_tail_eager P 1605
host_chunk_read_tail_eager P 1606
host_chunk_read_tail_eager P 1607
host_chunk_read_tail_eager P 1608
host_chunk_read_tail_eager P 1609
host_chunk_read_tail_eager P 1610
host_chunk_read_tail_eager P 1611
host_chunk_read_tail_eager P 1612
host_chunk_read_tail_eager P 1613
host_chunk_read_tail_eager P 1614
host_chunk_read_tail_eager P 1615
host_chunk_read_tail_eager P 1616
host_chunk_read_tail_eager P 1617
host_chunk_read_tail_eager P 1618
host_chunk_read_tail_eager P 1619
host_chunk_read_tail_eager P 1620
host_chunk_read_tail_eager P 1621
host_chunk_read_tail_eager P 1622
host_chunk_read_tail_eager P 1623
host_chunk_read_tail_eager P 1624
host_chunk_read_tail_eager P 1625
host_chunk_read_tail_eager P 1626
host_chunk_read_tail_eager P 1627
host_chunk_read_tail_eager P 1628
host_chunk_read_tail_eager P 1629
host_chunk_read_tail_eager P 1630
host_chunk_read_tail_eager P 1631

/- Chunks 1600 … 1631: boundary 1600 to boundary 1632 for every unread suffix. -/
tail_compose P P.tailGroup50 :=
  P.tac1600 P.tac1601 P.tac1602 P.tac1603 P.tac1604 P.tac1605 P.tac1606 P.tac1607
  P.tac1608 P.tac1609 P.tac1610 P.tac1611 P.tac1612 P.tac1613 P.tac1614 P.tac1615
  P.tac1616 P.tac1617 P.tac1618 P.tac1619 P.tac1620 P.tac1621 P.tac1622 P.tac1623
  P.tac1624 P.tac1625 P.tac1626 P.tac1627 P.tac1628 P.tac1629 P.tac1630 P.tac1631

end Host.Load.Run.Full
