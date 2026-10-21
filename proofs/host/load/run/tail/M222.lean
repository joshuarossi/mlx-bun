import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 222 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 222, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro222 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro222 0
host_chunk_read_tail_eager PTail.micro222 1
host_chunk_read_tail_eager PTail.micro222 2
host_chunk_read_tail_eager PTail.micro222 3
host_chunk_read_tail_eager PTail.micro222 4
host_chunk_read_tail_eager PTail.micro222 5
host_chunk_read_tail_eager PTail.micro222 6
host_chunk_read_tail_eager PTail.micro222 7
host_chunk_read_tail_eager PTail.micro222 8
host_chunk_read_tail_eager PTail.micro222 9
tail_compose PTail.micro222 PTail.micro222.run :=
  PTail.micro222.tac0 PTail.micro222.tac1 PTail.micro222.tac2 PTail.micro222.tac3 PTail.micro222.tac4 PTail.micro222.tac5 PTail.micro222.tac6 PTail.micro222.tac7
  PTail.micro222.tac8 PTail.micro222.tac9
tail_chunk_from P 222 := PTail.micro222.run

end Host.Load.Run.Full
