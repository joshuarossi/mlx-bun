import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 256
host_chunk_read_tail_eager P 257
host_chunk_read_tail_eager P 258
host_chunk_read_tail_eager P 259
host_chunk_read_tail_eager P 260
host_chunk_read_tail_eager P 261
host_chunk_read_tail_eager P 262
host_chunk_read_tail_eager P 263
host_chunk_read_tail_eager P 264
host_chunk_read_tail_eager P 265
host_chunk_read_tail_eager P 266
host_chunk_read_tail_eager P 267
host_chunk_read_tail_eager P 268
host_chunk_read_tail_eager P 269
host_chunk_read_tail_eager P 270
host_chunk_read_tail_eager P 271
host_chunk_read_tail_eager P 272
host_chunk_read_tail_eager P 273
host_chunk_read_tail_eager P 274
host_chunk_read_tail_eager P 275
host_chunk_read_tail_eager P 276
host_chunk_read_tail_eager P 277
host_chunk_read_tail_eager P 278
host_chunk_read_tail_eager P 279
host_chunk_read_tail_eager P 280
host_chunk_read_tail_eager P 281
host_chunk_read_tail_eager P 282
host_chunk_read_tail_eager P 283
host_chunk_read_tail_eager P 284
host_chunk_read_tail_eager P 285
host_chunk_read_tail_eager P 286
host_chunk_read_tail_eager P 287

/- Chunks 256 … 287: boundary 256 to boundary 288 for every unread suffix. -/
tail_compose P P.tailGroup8 :=
  P.tac256 P.tac257 P.tac258 P.tac259 P.tac260 P.tac261 P.tac262 P.tac263
  P.tac264 P.tac265 P.tac266 P.tac267 P.tac268 P.tac269 P.tac270 P.tac271
  P.tac272 P.tac273 P.tac274 P.tac275 P.tac276 P.tac277 P.tac278 P.tac279
  P.tac280 P.tac281 P.tac282 P.tac283 P.tac284 P.tac285 P.tac286 P.tac287

end Host.Load.Run.Full
