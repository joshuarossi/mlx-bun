import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 387 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 387, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro387 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro387 0
host_chunk_read_tail_eager PTail.micro387 1
host_chunk_read_tail_eager PTail.micro387 2
host_chunk_read_tail_eager PTail.micro387 3
host_chunk_read_tail_eager PTail.micro387 4
host_chunk_read_tail_eager PTail.micro387 5
host_chunk_read_tail_eager PTail.micro387 6
host_chunk_read_tail_eager PTail.micro387 7
host_chunk_read_tail_eager PTail.micro387 8
host_chunk_read_tail_eager PTail.micro387 9
tail_compose PTail.micro387 PTail.micro387.run :=
  PTail.micro387.tac0 PTail.micro387.tac1 PTail.micro387.tac2 PTail.micro387.tac3 PTail.micro387.tac4 PTail.micro387.tac5 PTail.micro387.tac6 PTail.micro387.tac7
  PTail.micro387.tac8 PTail.micro387.tac9
tail_chunk_from P 387 := PTail.micro387.run

end Host.Load.Run.Full
