import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M224
import host.load.run.tail.M225
import host.load.run.tail.M226
import host.load.run.tail.M227
import host.load.run.tail.M236
import host.load.run.tail.M237
import host.load.run.tail.M238
import host.load.run.tail.M239
import host.load.run.tail.M240
import host.load.run.tail.M241
import host.load.run.tail.M242
import host.load.run.tail.M243
import host.load.run.tail.M244
import host.load.run.tail.M245
import host.load.run.tail.M246
import host.load.run.tail.M247
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 228
host_chunk_read_tail_eager P 229
host_chunk_read_tail_eager P 230
host_chunk_read_tail_eager P 231
host_chunk_read_tail_eager P 232
host_chunk_read_tail_eager P 233
host_chunk_read_tail_eager P 234
host_chunk_read_tail_eager P 235
host_chunk_read_tail_eager P 248
host_chunk_read_tail_eager P 249
host_chunk_read_tail_eager P 250
host_chunk_read_tail_eager P 251
host_chunk_read_tail_eager P 252
host_chunk_read_tail_eager P 253
host_chunk_read_tail_eager P 254
host_chunk_read_tail_eager P 255

/- Chunks 224 … 255: boundary 224 to boundary 256 for every unread suffix. Chunks 224, 225, 226, 227, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247 are subdivided (M<k>). -/
tail_compose P P.tailGroup7 :=
  P.tac224 P.tac225 P.tac226 P.tac227 P.tac228 P.tac229 P.tac230 P.tac231
  P.tac232 P.tac233 P.tac234 P.tac235 P.tac236 P.tac237 P.tac238 P.tac239
  P.tac240 P.tac241 P.tac242 P.tac243 P.tac244 P.tac245 P.tac246 P.tac247
  P.tac248 P.tac249 P.tac250 P.tac251 P.tac252 P.tac253 P.tac254 P.tac255

end Host.Load.Run.Full
