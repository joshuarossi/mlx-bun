import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 402 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 402, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro402 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro402 0
host_chunk_read_tail_eager PTail.micro402 1
host_chunk_read_tail_eager PTail.micro402 2
host_chunk_read_tail_eager PTail.micro402 3
host_chunk_read_tail_eager PTail.micro402 4
host_chunk_read_tail_eager PTail.micro402 5
host_chunk_read_tail_eager PTail.micro402 6
host_chunk_read_tail_eager PTail.micro402 7
host_chunk_read_tail_eager PTail.micro402 8
host_chunk_read_tail_eager PTail.micro402 9
tail_compose PTail.micro402 PTail.micro402.run :=
  PTail.micro402.tac0 PTail.micro402.tac1 PTail.micro402.tac2 PTail.micro402.tac3 PTail.micro402.tac4 PTail.micro402.tac5 PTail.micro402.tac6 PTail.micro402.tac7
  PTail.micro402.tac8 PTail.micro402.tac9
tail_chunk_from P 402 := PTail.micro402.run

end Host.Load.Run.Full
