import host.load.run.tail.States
import host.load.run.tail.Command
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

host_chunk_read_tail_eager P 1280
host_chunk_read_tail_eager P 1281
host_chunk_read_tail_eager P 1282
host_chunk_read_tail_eager P 1283
host_chunk_read_tail_eager P 1284
host_chunk_read_tail_eager P 1285
host_chunk_read_tail_eager P 1286
host_chunk_read_tail_eager P 1287
host_chunk_read_tail_eager P 1288
host_chunk_read_tail_eager P 1289
host_chunk_read_tail_eager P 1290
host_chunk_read_tail_eager P 1291
host_chunk_read_tail_eager P 1292
host_chunk_read_tail_eager P 1293
host_chunk_read_tail_eager P 1294
host_chunk_read_tail_eager P 1295
host_chunk_read_tail_eager P 1296
host_chunk_read_tail_eager P 1297
host_chunk_read_tail_eager P 1298
host_chunk_read_tail_eager P 1299
host_chunk_read_tail_eager P 1300
host_chunk_read_tail_eager P 1301
host_chunk_read_tail_eager P 1302
host_chunk_read_tail_eager P 1303
host_chunk_read_tail_eager P 1304
host_chunk_read_tail_eager P 1305
host_chunk_read_tail_eager P 1306
host_chunk_read_tail_eager P 1307
host_chunk_read_tail_eager P 1308
host_chunk_read_tail_eager P 1309
host_chunk_read_tail_eager P 1310
host_chunk_read_tail_eager P 1311

/- Chunks 1280 … 1311: boundary 1280 to boundary 1312 for every unread suffix. -/
tail_compose P P.tailGroup40 :=
  P.tac1280 P.tac1281 P.tac1282 P.tac1283 P.tac1284 P.tac1285 P.tac1286 P.tac1287
  P.tac1288 P.tac1289 P.tac1290 P.tac1291 P.tac1292 P.tac1293 P.tac1294 P.tac1295
  P.tac1296 P.tac1297 P.tac1298 P.tac1299 P.tac1300 P.tac1301 P.tac1302 P.tac1303
  P.tac1304 P.tac1305 P.tac1306 P.tac1307 P.tac1308 P.tac1309 P.tac1310 P.tac1311

end Host.Load.Run.Full
