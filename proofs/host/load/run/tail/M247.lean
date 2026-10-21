import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 247 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 247, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro247 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro247 0
host_chunk_read_tail_eager PTail.micro247 1
host_chunk_read_tail_eager PTail.micro247 2
host_chunk_read_tail_eager PTail.micro247 3
host_chunk_read_tail_eager PTail.micro247 4
host_chunk_read_tail_eager PTail.micro247 5
host_chunk_read_tail_eager PTail.micro247 6
host_chunk_read_tail_eager PTail.micro247 7
host_chunk_read_tail_eager PTail.micro247 8
host_chunk_read_tail_eager PTail.micro247 9
tail_compose PTail.micro247 PTail.micro247.run :=
  PTail.micro247.tac0 PTail.micro247.tac1 PTail.micro247.tac2 PTail.micro247.tac3 PTail.micro247.tac4 PTail.micro247.tac5 PTail.micro247.tac6 PTail.micro247.tac7
  PTail.micro247.tac8 PTail.micro247.tac9
tail_chunk_from P 247 := PTail.micro247.run

end Host.Load.Run.Full
