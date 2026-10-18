import host.ts.renameOrdinary.micro.hot65.CG0
import host.ts.renameOrdinary.micro.hot65.CG1
import host.ts.renameOrdinary.micro.hot65.CG2
import host.ts.renameOrdinary.micro.hot65.CG3
import host.ts.renameOrdinary.micro.hot65.CG4
import host.ts.renameOrdinary.micro.hot65.CG5
import host.ts.renameOrdinary.micro.hot65.CG8
import host.ts.renameOrdinary.micro.hot65.CG9
import host.ts.renameOrdinary.micro.middle65.Result
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.P.Hot65.micro0
open Host.Ts
theorem full_prefix_run (fw : List Val) (tail : List NumV) : runS F 12800 (pfa0 fw tail) S0 = some (pfa1280 fw tail,S1280) := by
  exact (@runS_trans F 11520 1280 _ _ _ _ _ _ ((@runS_trans F 10240 1280 _ _ _ _ _ _ ((@runS_trans F 7680 2560 _ _ _ _ _ _ ((@runS_trans F 6400 1280 _ _ _ _ _ _ ((@runS_trans F 5120 1280 _ _ _ _ _ _ ((@runS_trans F 3840 1280 _ _ _ _ _ _ ((@runS_trans F 2560 1280 _ _ _ _ _ _ ((@runS_trans F 1280 1280 _ _ _ _ _ _ (prefixRun0_128 fw tail) (prefixRun128_256 fw tail))) (prefixRun256_384 fw tail))) (prefixRun384_512 fw tail))) (prefixRun512_640 fw tail))) (prefixRun640_768 fw tail))) (prefixRun768_1024 fw tail))) (prefixRun1024_1152 fw tail))) (prefixRun1152_1280 fw tail))
end Host.Load.Run.Full.P.Hot65.micro0
namespace Host.Load.Run.Full.P.RestStream.micro0
open Host.Ts
theorem prefixRun8320_8448 (fw : List Val) (tail : List NumV) : runS F 12800 (pfa8320 fw tail) S8320 = some (pfa8448 fw tail,S8448) := _root_.Host.Load.Run.Full.P.Hot65.micro0.full_prefix_run fw tail
end Host.Load.Run.Full.P.RestStream.micro0
