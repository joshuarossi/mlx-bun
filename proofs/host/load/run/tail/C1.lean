import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M38
import host.load.run.tail.M48
import host.load.run.tail.M49
import host.load.run.tail.M59
import host.load.run.tail.M60
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 32
host_chunk_read_tail_eager P 33
host_chunk_read_tail_eager P 34
host_chunk_read_tail_eager P 35
host_chunk_read_tail_eager P 36
host_chunk_read_tail_eager P 37
host_chunk_read_tail_eager P 39
host_chunk_read_tail_eager P 40
host_chunk_read_tail_eager P 41
host_chunk_read_tail_eager P 42
host_chunk_read_tail_eager P 43
host_chunk_read_tail_eager P 44
host_chunk_read_tail_eager P 45
host_chunk_read_tail_eager P 46
host_chunk_read_tail_eager P 47
host_chunk_read_tail_eager P 50
host_chunk_read_tail_eager P 51
host_chunk_read_tail_eager P 52
host_chunk_read_tail_eager P 53
host_chunk_read_tail_eager P 54
host_chunk_read_tail_eager P 55
host_chunk_read_tail_eager P 56
host_chunk_read_tail_eager P 57
host_chunk_read_tail_eager P 58
host_chunk_read_tail_eager P 61
host_chunk_read_tail_eager P 62
host_chunk_read_tail_eager P 63

/- Chunks 32 … 63: boundary 32 to boundary 64 for every unread suffix. Chunks 38, 48, 49, 59, 60 are subdivided (M<k>). -/
tail_compose P P.tailGroup1 :=
  P.tac32 P.tac33 P.tac34 P.tac35 P.tac36 P.tac37 P.tac38 P.tac39
  P.tac40 P.tac41 P.tac42 P.tac43 P.tac44 P.tac45 P.tac46 P.tac47
  P.tac48 P.tac49 P.tac50 P.tac51 P.tac52 P.tac53 P.tac54 P.tac55
  P.tac56 P.tac57 P.tac58 P.tac59 P.tac60 P.tac61 P.tac62 P.tac63

end Host.Load.Run.Full
