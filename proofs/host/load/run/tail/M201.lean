import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 201 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 201, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro201 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro201 0
host_chunk_read_tail_eager PTail.micro201 1
host_chunk_read_tail_eager PTail.micro201 2
host_chunk_read_tail_eager PTail.micro201 3
host_chunk_read_tail_eager PTail.micro201 4
host_chunk_read_tail_eager PTail.micro201 5
host_chunk_read_tail_eager PTail.micro201 6
host_chunk_read_tail_eager PTail.micro201 7
host_chunk_read_tail_eager PTail.micro201 8
host_chunk_read_tail_eager PTail.micro201 9
tail_compose PTail.micro201 PTail.micro201.run :=
  PTail.micro201.tac0 PTail.micro201.tac1 PTail.micro201.tac2 PTail.micro201.tac3 PTail.micro201.tac4 PTail.micro201.tac5 PTail.micro201.tac6 PTail.micro201.tac7
  PTail.micro201.tac8 PTail.micro201.tac9
tail_chunk_from P 201 := PTail.micro201.run

end Host.Load.Run.Full
