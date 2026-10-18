import host.ts.renameOrdinary.micro.middle65.CG0
import host.ts.renameOrdinary.micro.middle65.CG1
import host.ts.renameOrdinary.micro.middle65.CG2
import host.ts.renameOrdinary.micro.middle65.CG3
import host.ts.renameOrdinary.micro.middle65.CG4
import host.ts.renameOrdinary.micro.middle65.CG5
import host.ts.renameOrdinary.micro.middle65.CG6
import host.ts.renameOrdinary.micro.middle65.CG7
import host.ts.renameOrdinary.micro.middle65.CG8
import host.ts.renameOrdinary.micro.middle65.CG9
import host.ts.renameOrdinary.micro.middle65.CG10
import host.ts.renameOrdinary.micro.middle65.CG11
import host.ts.renameOrdinary.micro.middle65.CG12
import host.ts.renameOrdinary.micro.middle65.CG13
import host.ts.renameOrdinary.micro.middle65.CG14
import host.ts.renameOrdinary.micro.middle65.CG15
import host.ts.renameOrdinary.micro.middle65.CG16
import host.ts.renameOrdinary.micro.middle65.CG17
import host.ts.renameOrdinary.micro.middle65.CG18
import host.ts.renameOrdinary.micro.middle65.CG19
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.P.HotMiddle.micro0
open Host.Ts
theorem full_prefix_run (fw : List Val) (tail : List NumV) : runS F 2560 (pfa0 fw tail) S0 = some (pfa2560 fw tail,S2560) := by
  exact (@runS_trans F 2432 128 _ _ _ _ _ _ ((@runS_trans F 2304 128 _ _ _ _ _ _ ((@runS_trans F 2176 128 _ _ _ _ _ _ ((@runS_trans F 2048 128 _ _ _ _ _ _ ((@runS_trans F 1920 128 _ _ _ _ _ _ ((@runS_trans F 1792 128 _ _ _ _ _ _ ((@runS_trans F 1664 128 _ _ _ _ _ _ ((@runS_trans F 1536 128 _ _ _ _ _ _ ((@runS_trans F 1408 128 _ _ _ _ _ _ ((@runS_trans F 1280 128 _ _ _ _ _ _ ((@runS_trans F 1152 128 _ _ _ _ _ _ ((@runS_trans F 1024 128 _ _ _ _ _ _ ((@runS_trans F 896 128 _ _ _ _ _ _ ((@runS_trans F 768 128 _ _ _ _ _ _ ((@runS_trans F 640 128 _ _ _ _ _ _ ((@runS_trans F 512 128 _ _ _ _ _ _ ((@runS_trans F 384 128 _ _ _ _ _ _ ((@runS_trans F 256 128 _ _ _ _ _ _ ((@runS_trans F 128 128 _ _ _ _ _ _ (prefixRun0_128 fw tail) (prefixRun128_256 fw tail))) (prefixRun256_384 fw tail))) (prefixRun384_512 fw tail))) (prefixRun512_640 fw tail))) (prefixRun640_768 fw tail))) (prefixRun768_896 fw tail))) (prefixRun896_1024 fw tail))) (prefixRun1024_1152 fw tail))) (prefixRun1152_1280 fw tail))) (prefixRun1280_1408 fw tail))) (prefixRun1408_1536 fw tail))) (prefixRun1536_1664 fw tail))) (prefixRun1664_1792 fw tail))) (prefixRun1792_1920 fw tail))) (prefixRun1920_2048 fw tail))) (prefixRun2048_2176 fw tail))) (prefixRun2176_2304 fw tail))) (prefixRun2304_2432 fw tail))) (prefixRun2432_2560 fw tail))
end Host.Load.Run.Full.P.HotMiddle.micro0
namespace Host.Load.Run.Full.P.Hot65.micro0
open Host.Ts
theorem prefixRun768_1024 (fw : List Val) (tail : List NumV) : runS F 2560 (pfa768 fw tail) S768 = some (pfa1024 fw tail,S1024) := _root_.Host.Load.Run.Full.P.HotMiddle.micro0.full_prefix_run fw tail
end Host.Load.Run.Full.P.Hot65.micro0
