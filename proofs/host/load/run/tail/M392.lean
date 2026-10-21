import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 392 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 392, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro392 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro392 0
host_chunk_read_tail_eager PTail.micro392 1
host_chunk_read_tail_eager PTail.micro392 2
host_chunk_read_tail_eager PTail.micro392 3
host_chunk_read_tail_eager PTail.micro392 4
host_chunk_read_tail_eager PTail.micro392 5
host_chunk_read_tail_eager PTail.micro392 6
host_chunk_read_tail_eager PTail.micro392 7
host_chunk_read_tail_eager PTail.micro392 8
host_chunk_read_tail_eager PTail.micro392 9
tail_compose PTail.micro392 PTail.micro392.run :=
  PTail.micro392.tac0 PTail.micro392.tac1 PTail.micro392.tac2 PTail.micro392.tac3 PTail.micro392.tac4 PTail.micro392.tac5 PTail.micro392.tac6 PTail.micro392.tac7
  PTail.micro392.tac8 PTail.micro392.tac9
tail_chunk_from P 392 := PTail.micro392.run

end Host.Load.Run.Full
