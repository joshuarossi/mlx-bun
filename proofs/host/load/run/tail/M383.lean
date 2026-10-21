import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 383 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 383, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro383 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro383 0
host_chunk_read_tail_eager PTail.micro383 1
host_chunk_read_tail_eager PTail.micro383 2
host_chunk_read_tail_eager PTail.micro383 3
host_chunk_read_tail_eager PTail.micro383 4
host_chunk_read_tail_eager PTail.micro383 5
host_chunk_read_tail_eager PTail.micro383 6
host_chunk_read_tail_eager PTail.micro383 7
host_chunk_read_tail_eager PTail.micro383 8
host_chunk_read_tail_eager PTail.micro383 9
tail_compose PTail.micro383 PTail.micro383.run :=
  PTail.micro383.tac0 PTail.micro383.tac1 PTail.micro383.tac2 PTail.micro383.tac3 PTail.micro383.tac4 PTail.micro383.tac5 PTail.micro383.tac6 PTail.micro383.tac7
  PTail.micro383.tac8 PTail.micro383.tac9
tail_chunk_from P 383 := PTail.micro383.run

end Host.Load.Run.Full
