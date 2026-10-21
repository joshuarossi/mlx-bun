import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 126 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 126, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro126 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro126 0
host_chunk_read_tail_eager PTail.micro126 1
host_chunk_read_tail_eager PTail.micro126 2
host_chunk_read_tail_eager PTail.micro126 3
host_chunk_read_tail_eager PTail.micro126 4
host_chunk_read_tail_eager PTail.micro126 5
host_chunk_read_tail_eager PTail.micro126 6
host_chunk_read_tail_eager PTail.micro126 7
host_chunk_read_tail_eager PTail.micro126 8
host_chunk_read_tail_eager PTail.micro126 9
tail_compose PTail.micro126 PTail.micro126.run :=
  PTail.micro126.tac0 PTail.micro126.tac1 PTail.micro126.tac2 PTail.micro126.tac3 PTail.micro126.tac4 PTail.micro126.tac5 PTail.micro126.tac6 PTail.micro126.tac7
  PTail.micro126.tac8 PTail.micro126.tac9
tail_chunk_from P 126 := PTail.micro126.run

end Host.Load.Run.Full
