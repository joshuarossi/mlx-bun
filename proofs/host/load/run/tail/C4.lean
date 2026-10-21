import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M139
import host.load.run.tail.M140
import host.load.run.tail.M141
import host.load.run.tail.M142
import host.load.run.tail.M143
import host.load.run.tail.M151
import host.load.run.tail.M152
import host.load.run.tail.M153
import host.load.run.tail.M154
import host.load.run.tail.M155
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 128
host_chunk_read_tail_eager P 129
host_chunk_read_tail_eager P 130
host_chunk_read_tail_eager P 131
host_chunk_read_tail_eager P 132
host_chunk_read_tail_eager P 133
host_chunk_read_tail_eager P 134
host_chunk_read_tail_eager P 135
host_chunk_read_tail_eager P 136
host_chunk_read_tail_eager P 137
host_chunk_read_tail_eager P 138
host_chunk_read_tail_eager P 144
host_chunk_read_tail_eager P 145
host_chunk_read_tail_eager P 146
host_chunk_read_tail_eager P 147
host_chunk_read_tail_eager P 148
host_chunk_read_tail_eager P 149
host_chunk_read_tail_eager P 150
host_chunk_read_tail_eager P 156
host_chunk_read_tail_eager P 157
host_chunk_read_tail_eager P 158
host_chunk_read_tail_eager P 159

/- Chunks 128 … 159: boundary 128 to boundary 160 for every unread suffix. Chunks 139, 140, 141, 142, 143, 151, 152, 153, 154, 155 are subdivided (M<k>). -/
tail_compose P P.tailGroup4 :=
  P.tac128 P.tac129 P.tac130 P.tac131 P.tac132 P.tac133 P.tac134 P.tac135
  P.tac136 P.tac137 P.tac138 P.tac139 P.tac140 P.tac141 P.tac142 P.tac143
  P.tac144 P.tac145 P.tac146 P.tac147 P.tac148 P.tac149 P.tac150 P.tac151
  P.tac152 P.tac153 P.tac154 P.tac155 P.tac156 P.tac157 P.tac158 P.tac159

end Host.Load.Run.Full
