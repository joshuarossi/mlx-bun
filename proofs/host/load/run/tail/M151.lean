import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 151 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 151, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro151 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro151 0
host_chunk_read_tail_eager PTail.micro151 1
host_chunk_read_tail_eager PTail.micro151 2
host_chunk_read_tail_eager PTail.micro151 3
host_chunk_read_tail_eager PTail.micro151 4
host_chunk_read_tail_eager PTail.micro151 5
host_chunk_read_tail_eager PTail.micro151 6
host_chunk_read_tail_eager PTail.micro151 7
host_chunk_read_tail_eager PTail.micro151 8
host_chunk_read_tail_eager PTail.micro151 9
tail_compose PTail.micro151 PTail.micro151.run :=
  PTail.micro151.tac0 PTail.micro151.tac1 PTail.micro151.tac2 PTail.micro151.tac3 PTail.micro151.tac4 PTail.micro151.tac5 PTail.micro151.tac6 PTail.micro151.tac7
  PTail.micro151.tac8 PTail.micro151.tac9
tail_chunk_from P 151 := PTail.micro151.run

end Host.Load.Run.Full
