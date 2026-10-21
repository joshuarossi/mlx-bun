import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 385 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 385, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro385 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro385 0
host_chunk_read_tail_eager PTail.micro385 1
host_chunk_read_tail_eager PTail.micro385 2
host_chunk_read_tail_eager PTail.micro385 3
host_chunk_read_tail_eager PTail.micro385 4
host_chunk_read_tail_eager PTail.micro385 5
host_chunk_read_tail_eager PTail.micro385 6
host_chunk_read_tail_eager PTail.micro385 7
host_chunk_read_tail_eager PTail.micro385 8
host_chunk_read_tail_eager PTail.micro385 9
tail_compose PTail.micro385 PTail.micro385.run :=
  PTail.micro385.tac0 PTail.micro385.tac1 PTail.micro385.tac2 PTail.micro385.tac3 PTail.micro385.tac4 PTail.micro385.tac5 PTail.micro385.tac6 PTail.micro385.tac7
  PTail.micro385.tac8 PTail.micro385.tac9
tail_chunk_from P 385 := PTail.micro385.run

end Host.Load.Run.Full
