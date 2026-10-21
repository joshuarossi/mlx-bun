import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 221 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 221, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro221 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro221 0
host_chunk_read_tail_eager PTail.micro221 1
host_chunk_read_tail_eager PTail.micro221 2
host_chunk_read_tail_eager PTail.micro221 3
host_chunk_read_tail_eager PTail.micro221 4
host_chunk_read_tail_eager PTail.micro221 5
host_chunk_read_tail_eager PTail.micro221 6
host_chunk_read_tail_eager PTail.micro221 7
host_chunk_read_tail_eager PTail.micro221 8
host_chunk_read_tail_eager PTail.micro221 9
tail_compose PTail.micro221 PTail.micro221.run :=
  PTail.micro221.tac0 PTail.micro221.tac1 PTail.micro221.tac2 PTail.micro221.tac3 PTail.micro221.tac4 PTail.micro221.tac5 PTail.micro221.tac6 PTail.micro221.tac7
  PTail.micro221.tac8 PTail.micro221.tac9
tail_chunk_from P 221 := PTail.micro221.run

end Host.Load.Run.Full
