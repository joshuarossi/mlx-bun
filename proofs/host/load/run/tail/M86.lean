import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 86 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 86, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro86 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro86 0
host_chunk_read_tail_eager PTail.micro86 1
host_chunk_read_tail_eager PTail.micro86 2
host_chunk_read_tail_eager PTail.micro86 3
host_chunk_read_tail_eager PTail.micro86 4
host_chunk_read_tail_eager PTail.micro86 5
host_chunk_read_tail_eager PTail.micro86 6
host_chunk_read_tail_eager PTail.micro86 7
host_chunk_read_tail_eager PTail.micro86 8
host_chunk_read_tail_eager PTail.micro86 9
tail_compose PTail.micro86 PTail.micro86.run :=
  PTail.micro86.tac0 PTail.micro86.tac1 PTail.micro86.tac2 PTail.micro86.tac3 PTail.micro86.tac4 PTail.micro86.tac5 PTail.micro86.tac6 PTail.micro86.tac7
  PTail.micro86.tac8 PTail.micro86.tac9
tail_chunk_from P 86 := PTail.micro86.run

end Host.Load.Run.Full
