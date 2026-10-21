import host.load.run.tail.MicroBase
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option interpreter.prefer_native true
namespace Host.Load.Run.Full

/- Chunk 60 subdivided as in the original chain; native restoration only
chooses the intermediate boundaries. -/
host_micro_states PTail 60, 100 chunks [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100]
host_read_tail PTail.micro60 0, 109 keep 2
host_chunk_read_tail_eager PTail.micro60 0
host_chunk_read_tail_eager PTail.micro60 1
host_chunk_read_tail_eager PTail.micro60 2
host_chunk_read_tail_eager PTail.micro60 3
host_chunk_read_tail_eager PTail.micro60 4
host_chunk_read_tail_eager PTail.micro60 5
host_chunk_read_tail_eager PTail.micro60 6
host_chunk_read_tail_eager PTail.micro60 7
host_chunk_read_tail_eager PTail.micro60 8
host_chunk_read_tail_eager PTail.micro60 9
host_chunk_read_tail_eager PTail.micro60 10
host_chunk_read_tail_eager PTail.micro60 11
host_chunk_read_tail_eager PTail.micro60 12
host_chunk_read_tail_eager PTail.micro60 13
host_chunk_read_tail_eager PTail.micro60 14
host_chunk_read_tail_eager PTail.micro60 15
host_chunk_read_tail_eager PTail.micro60 16
host_chunk_read_tail_eager PTail.micro60 17
host_chunk_read_tail_eager PTail.micro60 18
host_chunk_read_tail_eager PTail.micro60 19
host_chunk_read_tail_eager PTail.micro60 20
host_chunk_read_tail_eager PTail.micro60 21
host_chunk_read_tail_eager PTail.micro60 22
host_chunk_read_tail_eager PTail.micro60 23
host_chunk_read_tail_eager PTail.micro60 24
host_chunk_read_tail_eager PTail.micro60 25
host_chunk_read_tail_eager PTail.micro60 26
host_chunk_read_tail_eager PTail.micro60 27
host_chunk_read_tail_eager PTail.micro60 28
host_chunk_read_tail_eager PTail.micro60 29
host_chunk_read_tail_eager PTail.micro60 30
host_chunk_read_tail_eager PTail.micro60 31
host_chunk_read_tail_eager PTail.micro60 32
host_chunk_read_tail_eager PTail.micro60 33
host_chunk_read_tail_eager PTail.micro60 34
host_chunk_read_tail_eager PTail.micro60 35
host_chunk_read_tail_eager PTail.micro60 36
host_chunk_read_tail_eager PTail.micro60 37
host_chunk_read_tail_eager PTail.micro60 38
host_chunk_read_tail_eager PTail.micro60 39
host_chunk_read_tail_eager PTail.micro60 40
host_chunk_read_tail_eager PTail.micro60 41
host_chunk_read_tail_eager PTail.micro60 42
host_chunk_read_tail_eager PTail.micro60 43
host_chunk_read_tail_eager PTail.micro60 44
host_chunk_read_tail_eager PTail.micro60 45
host_chunk_read_tail_eager PTail.micro60 46
host_chunk_read_tail_eager PTail.micro60 47
host_chunk_read_tail_eager PTail.micro60 48
host_chunk_read_tail_eager PTail.micro60 49
host_chunk_read_tail_eager PTail.micro60 50
host_chunk_read_tail_eager PTail.micro60 51
host_chunk_read_tail_eager PTail.micro60 52
host_chunk_read_tail_eager PTail.micro60 53
host_chunk_read_tail_eager PTail.micro60 54
host_chunk_read_tail_eager PTail.micro60 55
host_chunk_read_tail_eager PTail.micro60 56
host_chunk_read_tail_eager PTail.micro60 57
host_chunk_read_tail_eager PTail.micro60 58
host_chunk_read_tail_eager PTail.micro60 59
host_chunk_read_tail_eager PTail.micro60 60
host_chunk_read_tail_eager PTail.micro60 61
host_chunk_read_tail_eager PTail.micro60 62
host_chunk_read_tail_eager PTail.micro60 63
host_chunk_read_tail_eager PTail.micro60 64
host_chunk_read_tail_eager PTail.micro60 65
host_chunk_read_tail_eager PTail.micro60 66
host_chunk_read_tail_eager PTail.micro60 67
host_chunk_read_tail_eager PTail.micro60 68
host_chunk_read_tail_eager PTail.micro60 69
host_chunk_read_tail_eager PTail.micro60 70
host_chunk_read_tail_eager PTail.micro60 71
host_chunk_read_tail_eager PTail.micro60 72
host_chunk_read_tail_eager PTail.micro60 73
host_chunk_read_tail_eager PTail.micro60 74
host_chunk_read_tail_eager PTail.micro60 75
host_chunk_read_tail_eager PTail.micro60 76
host_chunk_read_tail_eager PTail.micro60 77
host_chunk_read_tail_eager PTail.micro60 78
host_chunk_read_tail_eager PTail.micro60 79
host_chunk_read_tail_eager PTail.micro60 80
host_chunk_read_tail_eager PTail.micro60 81
host_chunk_read_tail_eager PTail.micro60 82
host_chunk_read_tail_eager PTail.micro60 83
host_chunk_read_tail_eager PTail.micro60 84
host_chunk_read_tail_eager PTail.micro60 85
host_chunk_read_tail_eager PTail.micro60 86
host_chunk_read_tail_eager PTail.micro60 87
host_chunk_read_tail_eager PTail.micro60 88
host_chunk_read_tail_eager PTail.micro60 89
host_chunk_read_tail_eager PTail.micro60 90
host_chunk_read_tail_eager PTail.micro60 91
host_chunk_read_tail_eager PTail.micro60 92
host_chunk_read_tail_eager PTail.micro60 93
host_chunk_read_tail_eager PTail.micro60 94
host_chunk_read_tail_eager PTail.micro60 95
host_chunk_read_tail_eager PTail.micro60 96
host_chunk_read_tail_eager PTail.micro60 97
host_chunk_read_tail_eager PTail.micro60 98
host_chunk_read_tail_eager PTail.micro60 99
host_chunk_read_tail_eager PTail.micro60 100
host_chunk_read_tail_eager PTail.micro60 101
host_chunk_read_tail_eager PTail.micro60 102
host_chunk_read_tail_eager PTail.micro60 103
host_chunk_read_tail_eager PTail.micro60 104
host_chunk_read_tail_eager PTail.micro60 105
host_chunk_read_tail_eager PTail.micro60 106
host_chunk_read_tail_eager PTail.micro60 107
host_chunk_read_tail_eager PTail.micro60 108
tail_compose PTail.micro60 PTail.micro60.run :=
  PTail.micro60.tac0 PTail.micro60.tac1 PTail.micro60.tac2 PTail.micro60.tac3 PTail.micro60.tac4 PTail.micro60.tac5 PTail.micro60.tac6 PTail.micro60.tac7
  PTail.micro60.tac8 PTail.micro60.tac9 PTail.micro60.tac10 PTail.micro60.tac11 PTail.micro60.tac12 PTail.micro60.tac13 PTail.micro60.tac14 PTail.micro60.tac15
  PTail.micro60.tac16 PTail.micro60.tac17 PTail.micro60.tac18 PTail.micro60.tac19 PTail.micro60.tac20 PTail.micro60.tac21 PTail.micro60.tac22 PTail.micro60.tac23
  PTail.micro60.tac24 PTail.micro60.tac25 PTail.micro60.tac26 PTail.micro60.tac27 PTail.micro60.tac28 PTail.micro60.tac29 PTail.micro60.tac30 PTail.micro60.tac31
  PTail.micro60.tac32 PTail.micro60.tac33 PTail.micro60.tac34 PTail.micro60.tac35 PTail.micro60.tac36 PTail.micro60.tac37 PTail.micro60.tac38 PTail.micro60.tac39
  PTail.micro60.tac40 PTail.micro60.tac41 PTail.micro60.tac42 PTail.micro60.tac43 PTail.micro60.tac44 PTail.micro60.tac45 PTail.micro60.tac46 PTail.micro60.tac47
  PTail.micro60.tac48 PTail.micro60.tac49 PTail.micro60.tac50 PTail.micro60.tac51 PTail.micro60.tac52 PTail.micro60.tac53 PTail.micro60.tac54 PTail.micro60.tac55
  PTail.micro60.tac56 PTail.micro60.tac57 PTail.micro60.tac58 PTail.micro60.tac59 PTail.micro60.tac60 PTail.micro60.tac61 PTail.micro60.tac62 PTail.micro60.tac63
  PTail.micro60.tac64 PTail.micro60.tac65 PTail.micro60.tac66 PTail.micro60.tac67 PTail.micro60.tac68 PTail.micro60.tac69 PTail.micro60.tac70 PTail.micro60.tac71
  PTail.micro60.tac72 PTail.micro60.tac73 PTail.micro60.tac74 PTail.micro60.tac75 PTail.micro60.tac76 PTail.micro60.tac77 PTail.micro60.tac78 PTail.micro60.tac79
  PTail.micro60.tac80 PTail.micro60.tac81 PTail.micro60.tac82 PTail.micro60.tac83 PTail.micro60.tac84 PTail.micro60.tac85 PTail.micro60.tac86 PTail.micro60.tac87
  PTail.micro60.tac88 PTail.micro60.tac89 PTail.micro60.tac90 PTail.micro60.tac91 PTail.micro60.tac92 PTail.micro60.tac93 PTail.micro60.tac94 PTail.micro60.tac95
  PTail.micro60.tac96 PTail.micro60.tac97 PTail.micro60.tac98 PTail.micro60.tac99 PTail.micro60.tac100 PTail.micro60.tac101 PTail.micro60.tac102 PTail.micro60.tac103
  PTail.micro60.tac104 PTail.micro60.tac105 PTail.micro60.tac106 PTail.micro60.tac107 PTail.micro60.tac108
tail_chunk_from P 60 := PTail.micro60.run

end Host.Load.Run.Full
