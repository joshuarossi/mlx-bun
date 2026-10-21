import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 179 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 179, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro179 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro179 0
host_chunk_read_tail_eager PTail.micro179 1
host_chunk_read_tail_eager PTail.micro179 2
host_chunk_read_tail_eager PTail.micro179 3
host_chunk_read_tail_eager PTail.micro179 4
host_chunk_read_tail_eager PTail.micro179 5
host_chunk_read_tail_eager PTail.micro179 6
host_chunk_read_tail_eager PTail.micro179 7
host_chunk_read_tail_eager PTail.micro179 8
host_chunk_read_tail_eager PTail.micro179 9
tail_compose PTail.micro179 PTail.micro179.run :=
  PTail.micro179.tac0 PTail.micro179.tac1 PTail.micro179.tac2 PTail.micro179.tac3 PTail.micro179.tac4 PTail.micro179.tac5 PTail.micro179.tac6 PTail.micro179.tac7
  PTail.micro179.tac8 PTail.micro179.tac9
tail_chunk_from P 179 := PTail.micro179.run

end Host.Load.Run.Full
