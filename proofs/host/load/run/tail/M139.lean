import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 139 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 139, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro139 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro139 0
host_chunk_read_tail_eager PTail.micro139 1
host_chunk_read_tail_eager PTail.micro139 2
host_chunk_read_tail_eager PTail.micro139 3
host_chunk_read_tail_eager PTail.micro139 4
host_chunk_read_tail_eager PTail.micro139 5
host_chunk_read_tail_eager PTail.micro139 6
host_chunk_read_tail_eager PTail.micro139 7
host_chunk_read_tail_eager PTail.micro139 8
host_chunk_read_tail_eager PTail.micro139 9
tail_compose PTail.micro139 PTail.micro139.run :=
  PTail.micro139.tac0 PTail.micro139.tac1 PTail.micro139.tac2 PTail.micro139.tac3 PTail.micro139.tac4 PTail.micro139.tac5 PTail.micro139.tac6 PTail.micro139.tac7
  PTail.micro139.tac8 PTail.micro139.tac9
tail_chunk_from P 139 := PTail.micro139.run

end Host.Load.Run.Full
