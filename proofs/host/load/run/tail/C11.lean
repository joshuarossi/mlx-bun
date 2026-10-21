import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M364
import host.load.run.tail.M365
import host.load.run.tail.M366
import host.load.run.tail.M367
import host.load.run.tail.M368
import host.load.run.tail.M369
import host.load.run.tail.M370
import host.load.run.tail.M371
import host.load.run.tail.M372
import host.load.run.tail.M373
import host.load.run.tail.M374
import host.load.run.tail.M375
import host.load.run.tail.M376
import host.load.run.tail.M377
import host.load.run.tail.M378
import host.load.run.tail.M379
import host.load.run.tail.M380
import host.load.run.tail.M381
import host.load.run.tail.M382
import host.load.run.tail.M383
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 352
host_chunk_read_tail_eager P 353
host_chunk_read_tail_eager P 354
host_chunk_read_tail_eager P 355
host_chunk_read_tail_eager P 356
host_chunk_read_tail_eager P 357
host_chunk_read_tail_eager P 358
host_chunk_read_tail_eager P 359
host_chunk_read_tail_eager P 360
host_chunk_read_tail_eager P 361
host_chunk_read_tail_eager P 362
host_chunk_read_tail_eager P 363

/- Chunks 352 … 383: boundary 352 to boundary 384 for every unread suffix. Chunks 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383 are subdivided (M<k>). -/
tail_compose P P.tailGroup11 :=
  P.tac352 P.tac353 P.tac354 P.tac355 P.tac356 P.tac357 P.tac358 P.tac359
  P.tac360 P.tac361 P.tac362 P.tac363 P.tac364 P.tac365 P.tac366 P.tac367
  P.tac368 P.tac369 P.tac370 P.tac371 P.tac372 P.tac373 P.tac374 P.tac375
  P.tac376 P.tac377 P.tac378 P.tac379 P.tac380 P.tac381 P.tac382 P.tac383

end Host.Load.Run.Full
