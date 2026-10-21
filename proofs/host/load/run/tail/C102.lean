import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 3264
host_chunk_read_tail_eager P 3265
host_chunk_read_tail_eager P 3266
host_chunk_read_tail_eager P 3267
host_chunk_read_tail_eager P 3268
host_chunk_read_tail_eager P 3269
host_chunk_read_tail_eager P 3270
host_chunk_read_tail_eager P 3271

/- Chunks 3264 … 3271: boundary 3264 to boundary 3272 for every unread suffix. -/
tail_compose P P.tailGroup102 :=
  P.tac3264 P.tac3265 P.tac3266 P.tac3267 P.tac3268 P.tac3269 P.tac3270 P.tac3271

end Host.Load.Run.Full
