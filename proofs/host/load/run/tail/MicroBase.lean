import host.load.run.tail.States
import host.load.run.tail.MicroCommand
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full

/- Endpoints of the subdivided chunks under the prefix `PTail`, so the
subdivided chains `PTail.micro<k>` are distinct from the original `P.micro<k>`. -/
tail_alias PTail := P at
  8 9 19 20 21 23 24 38 39 48 49 50 59 60 61 69
  70 71 72 75 76 77 78 83 84 85 86 87 88 89 126 127
  139 140 141 142 143 144 151 152 153 154 155 156 163 164 165 166
  167 168 175 176 177 178 179 180 189 190 191 192 200 201 202 203
  204 212 213 215 216 220 221 222 223 224 225 226 227 228 236 237
  238 239 240 241 242 243 244 245 246 247 248 348 349 350 351 352
  364 365 366 367 368 369 370 371 372 373 374 375 376 377 378 379
  380 381 382 383 384 385 386 387 388 389 390 391 392 393 394 395
  396 397 398 399 400 401 402 403 404

end Host.Load.Run.Full
