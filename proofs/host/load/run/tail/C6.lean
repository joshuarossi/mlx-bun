import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M200
import host.load.run.tail.M201
import host.load.run.tail.M202
import host.load.run.tail.M203
import host.load.run.tail.M212
import host.load.run.tail.M215
import host.load.run.tail.M220
import host.load.run.tail.M221
import host.load.run.tail.M222
import host.load.run.tail.M223
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 192
host_chunk_read_tail_eager P 193
host_chunk_read_tail_eager P 194
host_chunk_read_tail_eager P 195
host_chunk_read_tail_eager P 196
host_chunk_read_tail_eager P 197
host_chunk_read_tail_eager P 198
host_chunk_read_tail_eager P 199
host_chunk_read_tail_eager P 204
host_chunk_read_tail_eager P 205
host_chunk_read_tail_eager P 206
host_chunk_read_tail_eager P 207
host_chunk_read_tail_eager P 208
host_chunk_read_tail_eager P 209
host_chunk_read_tail_eager P 210
host_chunk_read_tail_eager P 211
host_chunk_read_tail_eager P 213
host_chunk_read_tail_eager P 214
host_chunk_read_tail_eager P 216
host_chunk_read_tail_eager P 217
host_chunk_read_tail_eager P 218
host_chunk_read_tail_eager P 219

/- Chunks 192 … 223: boundary 192 to boundary 224 for every unread suffix. Chunks 200, 201, 202, 203, 212, 215, 220, 221, 222, 223 are subdivided (M<k>). -/
tail_compose P P.tailGroup6 :=
  P.tac192 P.tac193 P.tac194 P.tac195 P.tac196 P.tac197 P.tac198 P.tac199
  P.tac200 P.tac201 P.tac202 P.tac203 P.tac204 P.tac205 P.tac206 P.tac207
  P.tac208 P.tac209 P.tac210 P.tac211 P.tac212 P.tac213 P.tac214 P.tac215
  P.tac216 P.tac217 P.tac218 P.tac219 P.tac220 P.tac221 P.tac222 P.tac223

end Host.Load.Run.Full
