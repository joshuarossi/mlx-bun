import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 238 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 238, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro238 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro238 0
host_chunk_read_tail_eager PTail.micro238 1
host_chunk_read_tail_eager PTail.micro238 2
host_chunk_read_tail_eager PTail.micro238 3
host_chunk_read_tail_eager PTail.micro238 4
host_chunk_read_tail_eager PTail.micro238 5
host_chunk_read_tail_eager PTail.micro238 6
host_chunk_read_tail_eager PTail.micro238 7
host_chunk_read_tail_eager PTail.micro238 8
host_chunk_read_tail_eager PTail.micro238 9
tail_compose PTail.micro238 PTail.micro238.run :=
  PTail.micro238.tac0 PTail.micro238.tac1 PTail.micro238.tac2 PTail.micro238.tac3 PTail.micro238.tac4 PTail.micro238.tac5 PTail.micro238.tac6 PTail.micro238.tac7
  PTail.micro238.tac8 PTail.micro238.tac9
tail_chunk_from P 238 := PTail.micro238.run

end Host.Load.Run.Full
