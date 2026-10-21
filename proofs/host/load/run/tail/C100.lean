import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 3200
host_chunk_read_tail_eager P 3201
host_chunk_read_tail_eager P 3202
host_chunk_read_tail_eager P 3203
host_chunk_read_tail_eager P 3204
host_chunk_read_tail_eager P 3205
host_chunk_read_tail_eager P 3206
host_chunk_read_tail_eager P 3207
host_chunk_read_tail_eager P 3208
host_chunk_read_tail_eager P 3209
host_chunk_read_tail_eager P 3210
host_chunk_read_tail_eager P 3211
host_chunk_read_tail_eager P 3212
host_chunk_read_tail_eager P 3213
host_chunk_read_tail_eager P 3214
host_chunk_read_tail_eager P 3215
host_chunk_read_tail_eager P 3216
host_chunk_read_tail_eager P 3217
host_chunk_read_tail_eager P 3218
host_chunk_read_tail_eager P 3219
host_chunk_read_tail_eager P 3220
host_chunk_read_tail_eager P 3221
host_chunk_read_tail_eager P 3222
host_chunk_read_tail_eager P 3223
host_chunk_read_tail_eager P 3224
host_chunk_read_tail_eager P 3225
host_chunk_read_tail_eager P 3226
host_chunk_read_tail_eager P 3227
host_chunk_read_tail_eager P 3228
host_chunk_read_tail_eager P 3229
host_chunk_read_tail_eager P 3230
host_chunk_read_tail_eager P 3231

/- Chunks 3200 … 3231: boundary 3200 to boundary 3232 for every unread suffix. -/
tail_compose P P.tailGroup100 :=
  P.tac3200 P.tac3201 P.tac3202 P.tac3203 P.tac3204 P.tac3205 P.tac3206 P.tac3207
  P.tac3208 P.tac3209 P.tac3210 P.tac3211 P.tac3212 P.tac3213 P.tac3214 P.tac3215
  P.tac3216 P.tac3217 P.tac3218 P.tac3219 P.tac3220 P.tac3221 P.tac3222 P.tac3223
  P.tac3224 P.tac3225 P.tac3226 P.tac3227 P.tac3228 P.tac3229 P.tac3230 P.tac3231

end Host.Load.Run.Full
