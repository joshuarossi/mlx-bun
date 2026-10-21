import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 480
host_chunk_read_tail_eager P 481
host_chunk_read_tail_eager P 482
host_chunk_read_tail_eager P 483
host_chunk_read_tail_eager P 484
host_chunk_read_tail_eager P 485
host_chunk_read_tail_eager P 486
host_chunk_read_tail_eager P 487
host_chunk_read_tail_eager P 488
host_chunk_read_tail_eager P 489
host_chunk_read_tail_eager P 490
host_chunk_read_tail_eager P 491
host_chunk_read_tail_eager P 492
host_chunk_read_tail_eager P 493
host_chunk_read_tail_eager P 494
host_chunk_read_tail_eager P 495
host_chunk_read_tail_eager P 496
host_chunk_read_tail_eager P 497
host_chunk_read_tail_eager P 498
host_chunk_read_tail_eager P 499
host_chunk_read_tail_eager P 500
host_chunk_read_tail_eager P 501
host_chunk_read_tail_eager P 502
host_chunk_read_tail_eager P 503
host_chunk_read_tail_eager P 504
host_chunk_read_tail_eager P 505
host_chunk_read_tail_eager P 506
host_chunk_read_tail_eager P 507
host_chunk_read_tail_eager P 508
host_chunk_read_tail_eager P 509
host_chunk_read_tail_eager P 510
host_chunk_read_tail_eager P 511

/- Chunks 480 … 511: boundary 480 to boundary 512 for every unread suffix. -/
tail_compose P P.tailGroup15 :=
  P.tac480 P.tac481 P.tac482 P.tac483 P.tac484 P.tac485 P.tac486 P.tac487
  P.tac488 P.tac489 P.tac490 P.tac491 P.tac492 P.tac493 P.tac494 P.tac495
  P.tac496 P.tac497 P.tac498 P.tac499 P.tac500 P.tac501 P.tac502 P.tac503
  P.tac504 P.tac505 P.tac506 P.tac507 P.tac508 P.tac509 P.tac510 P.tac511

end Host.Load.Run.Full
