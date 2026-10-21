import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 154 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 154, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro154 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro154 0
host_chunk_read_tail_eager PTail.micro154 1
host_chunk_read_tail_eager PTail.micro154 2
host_chunk_read_tail_eager PTail.micro154 3
host_chunk_read_tail_eager PTail.micro154 4
host_chunk_read_tail_eager PTail.micro154 5
host_chunk_read_tail_eager PTail.micro154 6
host_chunk_read_tail_eager PTail.micro154 7
host_chunk_read_tail_eager PTail.micro154 8
host_chunk_read_tail_eager PTail.micro154 9
tail_compose PTail.micro154 PTail.micro154.run :=
  PTail.micro154.tac0 PTail.micro154.tac1 PTail.micro154.tac2 PTail.micro154.tac3 PTail.micro154.tac4 PTail.micro154.tac5 PTail.micro154.tac6 PTail.micro154.tac7
  PTail.micro154.tac8 PTail.micro154.tac9
tail_chunk_from P 154 := PTail.micro154.run

end Host.Load.Run.Full
