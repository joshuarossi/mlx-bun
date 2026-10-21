import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 399 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 399, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro399 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro399 0
host_chunk_read_tail_eager PTail.micro399 1
host_chunk_read_tail_eager PTail.micro399 2
host_chunk_read_tail_eager PTail.micro399 3
host_chunk_read_tail_eager PTail.micro399 4
host_chunk_read_tail_eager PTail.micro399 5
host_chunk_read_tail_eager PTail.micro399 6
host_chunk_read_tail_eager PTail.micro399 7
host_chunk_read_tail_eager PTail.micro399 8
host_chunk_read_tail_eager PTail.micro399 9
tail_compose PTail.micro399 PTail.micro399.run :=
  PTail.micro399.tac0 PTail.micro399.tac1 PTail.micro399.tac2 PTail.micro399.tac3 PTail.micro399.tac4 PTail.micro399.tac5 PTail.micro399.tac6 PTail.micro399.tac7
  PTail.micro399.tac8 PTail.micro399.tac9
tail_chunk_from P 399 := PTail.micro399.run

end Host.Load.Run.Full
