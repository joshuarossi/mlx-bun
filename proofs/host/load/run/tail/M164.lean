import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 164 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 164, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro164 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro164 0
host_chunk_read_tail_eager PTail.micro164 1
host_chunk_read_tail_eager PTail.micro164 2
host_chunk_read_tail_eager PTail.micro164 3
host_chunk_read_tail_eager PTail.micro164 4
host_chunk_read_tail_eager PTail.micro164 5
host_chunk_read_tail_eager PTail.micro164 6
host_chunk_read_tail_eager PTail.micro164 7
host_chunk_read_tail_eager PTail.micro164 8
host_chunk_read_tail_eager PTail.micro164 9
tail_compose PTail.micro164 PTail.micro164.run :=
  PTail.micro164.tac0 PTail.micro164.tac1 PTail.micro164.tac2 PTail.micro164.tac3 PTail.micro164.tac4 PTail.micro164.tac5 PTail.micro164.tac6 PTail.micro164.tac7
  PTail.micro164.tac8 PTail.micro164.tac9
tail_chunk_from P 164 := PTail.micro164.run

end Host.Load.Run.Full
