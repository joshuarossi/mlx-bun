import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 163 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 163, 1000 chunks [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro163 0, 10 keep 2
host_chunk_read_tail_eager PTail.micro163 0
host_chunk_read_tail_eager PTail.micro163 1
host_chunk_read_tail_eager PTail.micro163 2
host_chunk_read_tail_eager PTail.micro163 3
host_chunk_read_tail_eager PTail.micro163 4
host_chunk_read_tail_eager PTail.micro163 5
host_chunk_read_tail_eager PTail.micro163 6
host_chunk_read_tail_eager PTail.micro163 7
host_chunk_read_tail_eager PTail.micro163 8
host_chunk_read_tail_eager PTail.micro163 9
tail_compose PTail.micro163 PTail.micro163.run :=
  PTail.micro163.tac0 PTail.micro163.tac1 PTail.micro163.tac2 PTail.micro163.tac3 PTail.micro163.tac4 PTail.micro163.tac5 PTail.micro163.tac6 PTail.micro163.tac7
  PTail.micro163.tac8 PTail.micro163.tac9
tail_chunk_from P 163 := PTail.micro163.run

end Host.Load.Run.Full
