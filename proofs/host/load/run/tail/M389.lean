import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 389 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 389, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro389 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro389 0
host_chunk_read_tail_eager PTail.micro389 1
host_chunk_read_tail_eager PTail.micro389 2
host_chunk_read_tail_eager PTail.micro389 3
host_chunk_read_tail_eager PTail.micro389 4
host_chunk_read_tail_eager PTail.micro389 5
host_chunk_read_tail_eager PTail.micro389 6
host_chunk_read_tail_eager PTail.micro389 7
host_chunk_read_tail_eager PTail.micro389 8
host_chunk_read_tail_eager PTail.micro389 9
tail_compose PTail.micro389 PTail.micro389.run :=
  PTail.micro389.tac0 PTail.micro389.tac1 PTail.micro389.tac2 PTail.micro389.tac3 PTail.micro389.tac4 PTail.micro389.tac5 PTail.micro389.tac6 PTail.micro389.tac7
  PTail.micro389.tac8 PTail.micro389.tac9
tail_chunk_from P 389 := PTail.micro389.run

end Host.Load.Run.Full
