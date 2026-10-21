import host.load.run.tail.States
import host.load.run.tail.Command
import host.load.run.tail.M384
import host.load.run.tail.M385
import host.load.run.tail.M386
import host.load.run.tail.M387
import host.load.run.tail.M388
import host.load.run.tail.M389
import host.load.run.tail.M390
import host.load.run.tail.M391
import host.load.run.tail.M392
import host.load.run.tail.M393
import host.load.run.tail.M394
import host.load.run.tail.M395
import host.load.run.tail.M396
import host.load.run.tail.M397
import host.load.run.tail.M398
import host.load.run.tail.M399
import host.load.run.tail.M400
import host.load.run.tail.M401
import host.load.run.tail.M402
import host.load.run.tail.M403
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 404
host_chunk_read_tail_eager P 405
host_chunk_read_tail_eager P 406
host_chunk_read_tail_eager P 407
host_chunk_read_tail_eager P 408
host_chunk_read_tail_eager P 409
host_chunk_read_tail_eager P 410
host_chunk_read_tail_eager P 411
host_chunk_read_tail_eager P 412
host_chunk_read_tail_eager P 413
host_chunk_read_tail_eager P 414
host_chunk_read_tail_eager P 415

/- Chunks 384 … 415: boundary 384 to boundary 416 for every unread suffix. Chunks 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403 are subdivided (M<k>). -/
tail_compose P P.tailGroup12 :=
  P.tac384 P.tac385 P.tac386 P.tac387 P.tac388 P.tac389 P.tac390 P.tac391
  P.tac392 P.tac393 P.tac394 P.tac395 P.tac396 P.tac397 P.tac398 P.tac399
  P.tac400 P.tac401 P.tac402 P.tac403 P.tac404 P.tac405 P.tac406 P.tac407
  P.tac408 P.tac409 P.tac410 P.tac411 P.tac412 P.tac413 P.tac414 P.tac415

end Host.Load.Run.Full
