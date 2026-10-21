import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 390 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 390, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro390 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro390 0
host_chunk_read_tail_eager PTail.micro390 1
host_chunk_read_tail_eager PTail.micro390 2
host_chunk_read_tail_eager PTail.micro390 3
host_chunk_read_tail_eager PTail.micro390 4
host_chunk_read_tail_eager PTail.micro390 5
host_chunk_read_tail_eager PTail.micro390 6
host_chunk_read_tail_eager PTail.micro390 7
host_chunk_read_tail_eager PTail.micro390 8
host_chunk_read_tail_eager PTail.micro390 9
tail_compose PTail.micro390 PTail.micro390.run :=
  PTail.micro390.tac0 PTail.micro390.tac1 PTail.micro390.tac2 PTail.micro390.tac3 PTail.micro390.tac4 PTail.micro390.tac5 PTail.micro390.tac6 PTail.micro390.tac7
  PTail.micro390.tac8 PTail.micro390.tac9
tail_chunk_from P 390 := PTail.micro390.run

end Host.Load.Run.Full
