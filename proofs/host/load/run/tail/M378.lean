import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 378 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 378, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro378 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro378 0
host_chunk_read_tail_eager PTail.micro378 1
host_chunk_read_tail_eager PTail.micro378 2
host_chunk_read_tail_eager PTail.micro378 3
host_chunk_read_tail_eager PTail.micro378 4
host_chunk_read_tail_eager PTail.micro378 5
host_chunk_read_tail_eager PTail.micro378 6
host_chunk_read_tail_eager PTail.micro378 7
host_chunk_read_tail_eager PTail.micro378 8
host_chunk_read_tail_eager PTail.micro378 9
tail_compose PTail.micro378 PTail.micro378.run :=
  PTail.micro378.tac0 PTail.micro378.tac1 PTail.micro378.tac2 PTail.micro378.tac3 PTail.micro378.tac4 PTail.micro378.tac5 PTail.micro378.tac6 PTail.micro378.tac7
  PTail.micro378.tac8 PTail.micro378.tac9
tail_chunk_from P 378 := PTail.micro378.run

end Host.Load.Run.Full
