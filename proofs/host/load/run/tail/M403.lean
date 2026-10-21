import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 403 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 403, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro403 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro403 0
host_chunk_read_tail_eager PTail.micro403 1
host_chunk_read_tail_eager PTail.micro403 2
host_chunk_read_tail_eager PTail.micro403 3
host_chunk_read_tail_eager PTail.micro403 4
host_chunk_read_tail_eager PTail.micro403 5
host_chunk_read_tail_eager PTail.micro403 6
host_chunk_read_tail_eager PTail.micro403 7
host_chunk_read_tail_eager PTail.micro403 8
host_chunk_read_tail_eager PTail.micro403 9
tail_compose PTail.micro403 PTail.micro403.run :=
  PTail.micro403.tac0 PTail.micro403.tac1 PTail.micro403.tac2 PTail.micro403.tac3 PTail.micro403.tac4 PTail.micro403.tac5 PTail.micro403.tac6 PTail.micro403.tac7
  PTail.micro403.tac8 PTail.micro403.tac9
tail_chunk_from P 403 := PTail.micro403.run

end Host.Load.Run.Full
