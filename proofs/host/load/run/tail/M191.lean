import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 191 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 191, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro191 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro191 0
host_chunk_read_tail_eager PTail.micro191 1
host_chunk_read_tail_eager PTail.micro191 2
host_chunk_read_tail_eager PTail.micro191 3
host_chunk_read_tail_eager PTail.micro191 4
host_chunk_read_tail_eager PTail.micro191 5
host_chunk_read_tail_eager PTail.micro191 6
host_chunk_read_tail_eager PTail.micro191 7
host_chunk_read_tail_eager PTail.micro191 8
host_chunk_read_tail_eager PTail.micro191 9
tail_compose PTail.micro191 PTail.micro191.run :=
  PTail.micro191.tac0 PTail.micro191.tac1 PTail.micro191.tac2 PTail.micro191.tac3 PTail.micro191.tac4 PTail.micro191.tac5 PTail.micro191.tac6 PTail.micro191.tac7
  PTail.micro191.tac8 PTail.micro191.tac9
tail_chunk_from P 191 := PTail.micro191.run

end Host.Load.Run.Full
