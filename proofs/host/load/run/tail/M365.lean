import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 365 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 365, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro365 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro365 0
host_chunk_read_tail_eager PTail.micro365 1
host_chunk_read_tail_eager PTail.micro365 2
host_chunk_read_tail_eager PTail.micro365 3
host_chunk_read_tail_eager PTail.micro365 4
host_chunk_read_tail_eager PTail.micro365 5
host_chunk_read_tail_eager PTail.micro365 6
host_chunk_read_tail_eager PTail.micro365 7
host_chunk_read_tail_eager PTail.micro365 8
host_chunk_read_tail_eager PTail.micro365 9
tail_compose PTail.micro365 PTail.micro365.run :=
  PTail.micro365.tac0 PTail.micro365.tac1 PTail.micro365.tac2 PTail.micro365.tac3 PTail.micro365.tac4 PTail.micro365.tac5 PTail.micro365.tac6 PTail.micro365.tac7
  PTail.micro365.tac8 PTail.micro365.tac9
tail_chunk_from P 365 := PTail.micro365.run

end Host.Load.Run.Full
