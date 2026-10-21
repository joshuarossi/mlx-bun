import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 141 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 141, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro141 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro141 0
host_chunk_read_tail_eager PTail.micro141 1
host_chunk_read_tail_eager PTail.micro141 2
host_chunk_read_tail_eager PTail.micro141 3
host_chunk_read_tail_eager PTail.micro141 4
host_chunk_read_tail_eager PTail.micro141 5
host_chunk_read_tail_eager PTail.micro141 6
host_chunk_read_tail_eager PTail.micro141 7
host_chunk_read_tail_eager PTail.micro141 8
host_chunk_read_tail_eager PTail.micro141 9
tail_compose PTail.micro141 PTail.micro141.run :=
  PTail.micro141.tac0 PTail.micro141.tac1 PTail.micro141.tac2 PTail.micro141.tac3 PTail.micro141.tac4 PTail.micro141.tac5 PTail.micro141.tac6 PTail.micro141.tac7
  PTail.micro141.tac8 PTail.micro141.tac9
tail_chunk_from P 141 := PTail.micro141.run

end Host.Load.Run.Full
