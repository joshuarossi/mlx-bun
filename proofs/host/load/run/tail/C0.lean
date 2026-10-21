import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M8
import host.load.run.tail.M19
import host.load.run.tail.M20
import host.load.run.tail.M23
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 0
host_chunk_read_tail_eager P 1
host_chunk_read_tail_eager P 2
host_chunk_read_tail_eager P 3
host_chunk_read_tail_eager P 4
host_chunk_read_tail_eager P 5
host_chunk_read_tail_eager P 6
host_chunk_read_tail_eager P 7
host_chunk_read_tail_eager P 9
host_chunk_read_tail_eager P 10
host_chunk_read_tail_eager P 11
host_chunk_read_tail_eager P 12
host_chunk_read_tail_eager P 13
host_chunk_read_tail_eager P 14
host_chunk_read_tail_eager P 15
host_chunk_read_tail_eager P 16
host_chunk_read_tail_eager P 17
host_chunk_read_tail_eager P 18
host_chunk_read_tail_eager P 21
host_chunk_read_tail_eager P 22
host_chunk_read_tail_eager P 24
host_chunk_read_tail_eager P 25
host_chunk_read_tail_eager P 26
host_chunk_read_tail_eager P 27
host_chunk_read_tail_eager P 28
host_chunk_read_tail_eager P 29
host_chunk_read_tail_eager P 30
host_chunk_read_tail_eager P 31

/- Chunks 0 … 31: boundary 0 to boundary 32 for every unread suffix. Chunks 8, 19, 20, 23 are subdivided (M<k>). -/
tail_compose P P.tailGroup0 :=
  P.tac0 P.tac1 P.tac2 P.tac3 P.tac4 P.tac5 P.tac6 P.tac7
  P.tac8 P.tac9 P.tac10 P.tac11 P.tac12 P.tac13 P.tac14 P.tac15
  P.tac16 P.tac17 P.tac18 P.tac19 P.tac20 P.tac21 P.tac22 P.tac23
  P.tac24 P.tac25 P.tac26 P.tac27 P.tac28 P.tac29 P.tac30 P.tac31

end Host.Load.Run.Full
