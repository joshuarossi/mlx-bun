import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M69
import host.load.run.tail.M70
import host.load.run.tail.M71
import host.load.run.tail.M75
import host.load.run.tail.M76
import host.load.run.tail.M77
import host.load.run.tail.M83
import host.load.run.tail.M84
import host.load.run.tail.M86
import host.load.run.tail.M87
import host.load.run.tail.M88
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 64
host_chunk_read_tail_eager P 65
host_chunk_read_tail_eager P 66
host_chunk_read_tail_eager P 67
host_chunk_read_tail_eager P 68
host_chunk_read_tail_eager P 72
host_chunk_read_tail_eager P 73
host_chunk_read_tail_eager P 74
host_chunk_read_tail_eager P 78
host_chunk_read_tail_eager P 79
host_chunk_read_tail_eager P 80
host_chunk_read_tail_eager P 81
host_chunk_read_tail_eager P 82
host_chunk_read_tail_eager P 85
host_chunk_read_tail_eager P 89
host_chunk_read_tail_eager P 90
host_chunk_read_tail_eager P 91
host_chunk_read_tail_eager P 92
host_chunk_read_tail_eager P 93
host_chunk_read_tail_eager P 94
host_chunk_read_tail_eager P 95

/- Chunks 64 … 95: boundary 64 to boundary 96 for every unread suffix. Chunks 69, 70, 71, 75, 76, 77, 83, 84, 86, 87, 88 are subdivided (M<k>). -/
tail_compose P P.tailGroup2 :=
  P.tac64 P.tac65 P.tac66 P.tac67 P.tac68 P.tac69 P.tac70 P.tac71
  P.tac72 P.tac73 P.tac74 P.tac75 P.tac76 P.tac77 P.tac78 P.tac79
  P.tac80 P.tac81 P.tac82 P.tac83 P.tac84 P.tac85 P.tac86 P.tac87
  P.tac88 P.tac89 P.tac90 P.tac91 P.tac92 P.tac93 P.tac94 P.tac95

end Host.Load.Run.Full
