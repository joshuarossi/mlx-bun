import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 223 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 223, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro223 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro223 0
host_chunk_read_tail_eager PTail.micro223 1
host_chunk_read_tail_eager PTail.micro223 2
host_chunk_read_tail_eager PTail.micro223 3
host_chunk_read_tail_eager PTail.micro223 4
host_chunk_read_tail_eager PTail.micro223 5
host_chunk_read_tail_eager PTail.micro223 6
host_chunk_read_tail_eager PTail.micro223 7
host_chunk_read_tail_eager PTail.micro223 8
host_chunk_read_tail_eager PTail.micro223 9
tail_compose PTail.micro223 PTail.micro223.run :=
  PTail.micro223.tac0 PTail.micro223.tac1 PTail.micro223.tac2 PTail.micro223.tac3 PTail.micro223.tac4 PTail.micro223.tac5 PTail.micro223.tac6 PTail.micro223.tac7
  PTail.micro223.tac8 PTail.micro223.tac9
tail_chunk_from P 223 := PTail.micro223.run

end Host.Load.Run.Full
