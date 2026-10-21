import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M126
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 96
host_chunk_read_tail_eager P 97
host_chunk_read_tail_eager P 98
host_chunk_read_tail_eager P 99
host_chunk_read_tail_eager P 100
host_chunk_read_tail_eager P 101
host_chunk_read_tail_eager P 102
host_chunk_read_tail_eager P 103
host_chunk_read_tail_eager P 104
host_chunk_read_tail_eager P 105
host_chunk_read_tail_eager P 106
host_chunk_read_tail_eager P 107
host_chunk_read_tail_eager P 108
host_chunk_read_tail_eager P 109
host_chunk_read_tail_eager P 110
host_chunk_read_tail_eager P 111
host_chunk_read_tail_eager P 112
host_chunk_read_tail_eager P 113
host_chunk_read_tail_eager P 114
host_chunk_read_tail_eager P 115
host_chunk_read_tail_eager P 116
host_chunk_read_tail_eager P 117
host_chunk_read_tail_eager P 118
host_chunk_read_tail_eager P 119
host_chunk_read_tail_eager P 120
host_chunk_read_tail_eager P 121
host_chunk_read_tail_eager P 122
host_chunk_read_tail_eager P 123
host_chunk_read_tail_eager P 124
host_chunk_read_tail_eager P 125
host_chunk_read_tail_eager P 127

/- Chunks 96 … 127: boundary 96 to boundary 128 for every unread suffix. Chunks 126 are subdivided (M<k>). -/
tail_compose P P.tailGroup3 :=
  P.tac96 P.tac97 P.tac98 P.tac99 P.tac100 P.tac101 P.tac102 P.tac103
  P.tac104 P.tac105 P.tac106 P.tac107 P.tac108 P.tac109 P.tac110 P.tac111
  P.tac112 P.tac113 P.tac114 P.tac115 P.tac116 P.tac117 P.tac118 P.tac119
  P.tac120 P.tac121 P.tac122 P.tac123 P.tac124 P.tac125 P.tac126 P.tac127

end Host.Load.Run.Full
