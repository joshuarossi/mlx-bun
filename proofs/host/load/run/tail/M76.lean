import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 76 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 76, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro76 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro76 0
host_chunk_read_tail_eager PTail.micro76 1
host_chunk_read_tail_eager PTail.micro76 2
host_chunk_read_tail_eager PTail.micro76 3
host_chunk_read_tail_eager PTail.micro76 4
host_chunk_read_tail_eager PTail.micro76 5
host_chunk_read_tail_eager PTail.micro76 6
host_chunk_read_tail_eager PTail.micro76 7
host_chunk_read_tail_eager PTail.micro76 8
host_chunk_read_tail_eager PTail.micro76 9
tail_compose PTail.micro76 PTail.micro76.run :=
  PTail.micro76.tac0 PTail.micro76.tac1 PTail.micro76.tac2 PTail.micro76.tac3 PTail.micro76.tac4 PTail.micro76.tac5 PTail.micro76.tac6 PTail.micro76.tac7
  PTail.micro76.tac8 PTail.micro76.tac9
tail_chunk_from P 76 := PTail.micro76.run

end Host.Load.Run.Full
