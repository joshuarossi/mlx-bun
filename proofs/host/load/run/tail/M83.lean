import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 83 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 83, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 687, 1, 1000, 1000, 312]
host_read_tail PTail.micro83 0, 12 keep 2
host_chunk_read_tail_eager PTail.micro83 0
host_chunk_read_tail_eager PTail.micro83 1
host_chunk_read_tail_eager PTail.micro83 2
host_chunk_read_tail_eager PTail.micro83 3
host_chunk_read_tail_eager PTail.micro83 4
host_chunk_read_tail_eager PTail.micro83 5
host_chunk_read_tail_eager PTail.micro83 6
host_chunk_read_tail_eager PTail.micro83 7
host_sha256_step_tail PTail.micro83 8
host_chunk_read_tail_eager PTail.micro83 9
host_chunk_read_tail_eager PTail.micro83 10
host_chunk_read_tail_eager PTail.micro83 11
tail_compose PTail.micro83 PTail.micro83.run :=
  PTail.micro83.tac0 PTail.micro83.tac1 PTail.micro83.tac2 PTail.micro83.tac3 PTail.micro83.tac4 PTail.micro83.tac5 PTail.micro83.tac6 PTail.micro83.tac7
  PTail.micro83.tac8 PTail.micro83.tac9 PTail.micro83.tac10 PTail.micro83.tac11
tail_chunk_from P 83 := PTail.micro83.run

end Host.Load.Run.Full
