import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 84 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 84, 1000 chunks [1000, 1000, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 1000, 1000, 1000, 1000, 1000, 1000]
host_read_tail PTail.micro84 0, 28 keep 2
host_chunk_read_tail_eager PTail.micro84 0
host_chunk_read_tail_eager PTail.micro84 1
host_chunk_read_tail_eager PTail.micro84 2
host_chunk_read_tail_eager PTail.micro84 3
host_chunk_read_tail_eager PTail.micro84 4
host_chunk_read_tail_eager PTail.micro84 5
host_chunk_read_tail_eager PTail.micro84 6
host_chunk_read_tail_eager PTail.micro84 7
host_chunk_read_tail_eager PTail.micro84 8
host_chunk_read_tail_eager PTail.micro84 9
host_chunk_read_tail_eager PTail.micro84 10
host_chunk_read_tail_eager PTail.micro84 11
host_chunk_read_tail_eager PTail.micro84 12
host_chunk_read_tail_eager PTail.micro84 13
host_chunk_read_tail_eager PTail.micro84 14
host_chunk_read_tail_eager PTail.micro84 15
host_chunk_read_tail_eager PTail.micro84 16
host_chunk_read_tail_eager PTail.micro84 17
host_chunk_read_tail_eager PTail.micro84 18
host_chunk_read_tail_eager PTail.micro84 19
host_chunk_read_tail_eager PTail.micro84 20
host_chunk_read_tail_eager PTail.micro84 21
host_chunk_read_tail_eager PTail.micro84 22
host_chunk_read_tail_eager PTail.micro84 23
host_chunk_read_tail_eager PTail.micro84 24
host_chunk_read_tail_eager PTail.micro84 25
host_chunk_read_tail_eager PTail.micro84 26
host_chunk_read_tail_eager PTail.micro84 27
tail_compose PTail.micro84 PTail.micro84.run :=
  PTail.micro84.tac0 PTail.micro84.tac1 PTail.micro84.tac2 PTail.micro84.tac3 PTail.micro84.tac4 PTail.micro84.tac5 PTail.micro84.tac6 PTail.micro84.tac7
  PTail.micro84.tac8 PTail.micro84.tac9 PTail.micro84.tac10 PTail.micro84.tac11 PTail.micro84.tac12 PTail.micro84.tac13 PTail.micro84.tac14 PTail.micro84.tac15
  PTail.micro84.tac16 PTail.micro84.tac17 PTail.micro84.tac18 PTail.micro84.tac19 PTail.micro84.tac20 PTail.micro84.tac21 PTail.micro84.tac22 PTail.micro84.tac23
  PTail.micro84.tac24 PTail.micro84.tac25 PTail.micro84.tac26 PTail.micro84.tac27
tail_chunk_from P 84 := PTail.micro84.run

end Host.Load.Run.Full
