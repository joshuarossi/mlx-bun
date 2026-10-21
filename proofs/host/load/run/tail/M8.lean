import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 8 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 8, 500 chunks [500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 500, 500, 500, 500, 500, 500, 500, 500]
host_read_tail PTail.micro8 0, 69 keep 2
host_chunk_read_tail_eager PTail.micro8 0
host_chunk_read_tail_eager PTail.micro8 1
host_chunk_read_tail_eager PTail.micro8 2
host_chunk_read_tail_eager PTail.micro8 3
host_chunk_read_tail_eager PTail.micro8 4
host_chunk_read_tail_eager PTail.micro8 5
host_chunk_read_tail_eager PTail.micro8 6
host_chunk_read_tail_eager PTail.micro8 7
host_chunk_read_tail_eager PTail.micro8 8
host_chunk_read_tail_eager PTail.micro8 9
host_chunk_read_tail_eager PTail.micro8 10
host_chunk_read_tail_eager PTail.micro8 11
host_chunk_read_tail_eager PTail.micro8 12
host_chunk_read_tail_eager PTail.micro8 13
host_chunk_read_tail_eager PTail.micro8 14
host_chunk_read_tail_eager PTail.micro8 15
host_chunk_read_tail_eager PTail.micro8 16
host_chunk_read_tail_eager PTail.micro8 17
host_chunk_read_tail_eager PTail.micro8 18
host_chunk_read_tail_eager PTail.micro8 19
host_chunk_read_tail_eager PTail.micro8 20
host_chunk_read_tail_eager PTail.micro8 21
host_chunk_read_tail_eager PTail.micro8 22
host_chunk_read_tail_eager PTail.micro8 23
host_chunk_read_tail_eager PTail.micro8 24
host_chunk_read_tail_eager PTail.micro8 25
host_chunk_read_tail_eager PTail.micro8 26
host_chunk_read_tail_eager PTail.micro8 27
host_chunk_read_tail_eager PTail.micro8 28
host_chunk_read_tail_eager PTail.micro8 29
host_chunk_read_tail_eager PTail.micro8 30
host_chunk_read_tail_eager PTail.micro8 31
host_chunk_read_tail_eager PTail.micro8 32
host_chunk_read_tail_eager PTail.micro8 33
host_chunk_read_tail_eager PTail.micro8 34
host_chunk_read_tail_eager PTail.micro8 35
host_chunk_read_tail_eager PTail.micro8 36
host_chunk_read_tail_eager PTail.micro8 37
host_chunk_read_tail_eager PTail.micro8 38
host_chunk_read_tail_eager PTail.micro8 39
host_chunk_read_tail_eager PTail.micro8 40
host_chunk_read_tail_eager PTail.micro8 41
host_chunk_read_tail_eager PTail.micro8 42
host_chunk_read_tail_eager PTail.micro8 43
host_chunk_read_tail_eager PTail.micro8 44
host_chunk_read_tail_eager PTail.micro8 45
host_chunk_read_tail_eager PTail.micro8 46
host_chunk_read_tail_eager PTail.micro8 47
host_chunk_read_tail_eager PTail.micro8 48
host_chunk_read_tail_eager PTail.micro8 49
host_chunk_read_tail_eager PTail.micro8 50
host_chunk_read_tail_eager PTail.micro8 51
host_chunk_read_tail_eager PTail.micro8 52
host_chunk_read_tail_eager PTail.micro8 53
host_chunk_read_tail_eager PTail.micro8 54
host_chunk_read_tail_eager PTail.micro8 55
host_chunk_read_tail_eager PTail.micro8 56
host_chunk_read_tail_eager PTail.micro8 57
host_chunk_read_tail_eager PTail.micro8 58
host_chunk_read_tail_eager PTail.micro8 59
host_chunk_read_tail_eager PTail.micro8 60
host_chunk_read_tail_eager PTail.micro8 61
host_chunk_read_tail_eager PTail.micro8 62
host_chunk_read_tail_eager PTail.micro8 63
host_chunk_read_tail_eager PTail.micro8 64
host_chunk_read_tail_eager PTail.micro8 65
host_chunk_read_tail_eager PTail.micro8 66
host_chunk_read_tail_eager PTail.micro8 67
host_chunk_read_tail_eager PTail.micro8 68
tail_compose PTail.micro8 PTail.micro8.run :=
  PTail.micro8.tac0 PTail.micro8.tac1 PTail.micro8.tac2 PTail.micro8.tac3 PTail.micro8.tac4 PTail.micro8.tac5 PTail.micro8.tac6 PTail.micro8.tac7
  PTail.micro8.tac8 PTail.micro8.tac9 PTail.micro8.tac10 PTail.micro8.tac11 PTail.micro8.tac12 PTail.micro8.tac13 PTail.micro8.tac14 PTail.micro8.tac15
  PTail.micro8.tac16 PTail.micro8.tac17 PTail.micro8.tac18 PTail.micro8.tac19 PTail.micro8.tac20 PTail.micro8.tac21 PTail.micro8.tac22 PTail.micro8.tac23
  PTail.micro8.tac24 PTail.micro8.tac25 PTail.micro8.tac26 PTail.micro8.tac27 PTail.micro8.tac28 PTail.micro8.tac29 PTail.micro8.tac30 PTail.micro8.tac31
  PTail.micro8.tac32 PTail.micro8.tac33 PTail.micro8.tac34 PTail.micro8.tac35 PTail.micro8.tac36 PTail.micro8.tac37 PTail.micro8.tac38 PTail.micro8.tac39
  PTail.micro8.tac40 PTail.micro8.tac41 PTail.micro8.tac42 PTail.micro8.tac43 PTail.micro8.tac44 PTail.micro8.tac45 PTail.micro8.tac46 PTail.micro8.tac47
  PTail.micro8.tac48 PTail.micro8.tac49 PTail.micro8.tac50 PTail.micro8.tac51 PTail.micro8.tac52 PTail.micro8.tac53 PTail.micro8.tac54 PTail.micro8.tac55
  PTail.micro8.tac56 PTail.micro8.tac57 PTail.micro8.tac58 PTail.micro8.tac59 PTail.micro8.tac60 PTail.micro8.tac61 PTail.micro8.tac62 PTail.micro8.tac63
  PTail.micro8.tac64 PTail.micro8.tac65 PTail.micro8.tac66 PTail.micro8.tac67 PTail.micro8.tac68
tail_chunk_from P 8 := PTail.micro8.run

end Host.Load.Run.Full
