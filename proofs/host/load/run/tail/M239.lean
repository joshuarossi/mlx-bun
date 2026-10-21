import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 239 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 239, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro239 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro239 0
host_chunk_read_tail_eager PTail.micro239 1
host_chunk_read_tail_eager PTail.micro239 2
host_chunk_read_tail_eager PTail.micro239 3
host_chunk_read_tail_eager PTail.micro239 4
host_chunk_read_tail_eager PTail.micro239 5
host_chunk_read_tail_eager PTail.micro239 6
host_chunk_read_tail_eager PTail.micro239 7
host_chunk_read_tail_eager PTail.micro239 8
host_chunk_read_tail_eager PTail.micro239 9
tail_compose PTail.micro239 PTail.micro239.run :=
  PTail.micro239.tac0 PTail.micro239.tac1 PTail.micro239.tac2 PTail.micro239.tac3 PTail.micro239.tac4 PTail.micro239.tac5 PTail.micro239.tac6 PTail.micro239.tac7
  PTail.micro239.tac8 PTail.micro239.tac9
tail_chunk_from P 239 := PTail.micro239.run

end Host.Load.Run.Full
