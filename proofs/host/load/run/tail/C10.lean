import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M348
import host.load.run.tail.M349
import host.load.run.tail.M350
import host.load.run.tail.M351
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 320
host_chunk_read_tail_eager P 321
host_chunk_read_tail_eager P 322
host_chunk_read_tail_eager P 323
host_chunk_read_tail_eager P 324
host_chunk_read_tail_eager P 325
host_chunk_read_tail_eager P 326
host_chunk_read_tail_eager P 327
host_chunk_read_tail_eager P 328
host_chunk_read_tail_eager P 329
host_chunk_read_tail_eager P 330
host_chunk_read_tail_eager P 331
host_chunk_read_tail_eager P 332
host_chunk_read_tail_eager P 333
host_chunk_read_tail_eager P 334
host_chunk_read_tail_eager P 335
host_chunk_read_tail_eager P 336
host_chunk_read_tail_eager P 337
host_chunk_read_tail_eager P 338
host_chunk_read_tail_eager P 339
host_chunk_read_tail_eager P 340
host_chunk_read_tail_eager P 341
host_chunk_read_tail_eager P 342
host_chunk_read_tail_eager P 343
host_chunk_read_tail_eager P 344
host_chunk_read_tail_eager P 345
host_chunk_read_tail_eager P 346
host_chunk_read_tail_eager P 347

/- Chunks 320 … 351: boundary 320 to boundary 352 for every unread suffix. Chunks 348, 349, 350, 351 are subdivided (M<k>). -/
tail_compose P P.tailGroup10 :=
  P.tac320 P.tac321 P.tac322 P.tac323 P.tac324 P.tac325 P.tac326 P.tac327
  P.tac328 P.tac329 P.tac330 P.tac331 P.tac332 P.tac333 P.tac334 P.tac335
  P.tac336 P.tac337 P.tac338 P.tac339 P.tac340 P.tac341 P.tac342 P.tac343
  P.tac344 P.tac345 P.tac346 P.tac347 P.tac348 P.tac349 P.tac350 P.tac351

end Host.Load.Run.Full
