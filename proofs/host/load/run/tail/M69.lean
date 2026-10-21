import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 69 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 69, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro69 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro69 0
host_chunk_read_tail_eager PTail.micro69 1
host_chunk_read_tail_eager PTail.micro69 2
host_chunk_read_tail_eager PTail.micro69 3
host_chunk_read_tail_eager PTail.micro69 4
host_chunk_read_tail_eager PTail.micro69 5
host_chunk_read_tail_eager PTail.micro69 6
host_chunk_read_tail_eager PTail.micro69 7
host_chunk_read_tail_eager PTail.micro69 8
host_chunk_read_tail_eager PTail.micro69 9
tail_compose PTail.micro69 PTail.micro69.run :=
  PTail.micro69.tac0 PTail.micro69.tac1 PTail.micro69.tac2 PTail.micro69.tac3 PTail.micro69.tac4 PTail.micro69.tac5 PTail.micro69.tac6 PTail.micro69.tac7
  PTail.micro69.tac8 PTail.micro69.tac9
tail_chunk_from P 69 := PTail.micro69.run

end Host.Load.Run.Full
