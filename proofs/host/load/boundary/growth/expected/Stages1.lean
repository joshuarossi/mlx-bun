import host.load.boundary.growth.expected.Stages0
namespace Host.Load.Run.Full.Growth64.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment4 : run (stageG id 256 (256 : Int) (257 : Int) stages[4] (fun k => InKey.stage 4 k) fragment3.1.1) fragment3.2
ffi_value_literal_eq fragment4 : run (stageG id 256 (256 : Int) (257 : Int) stages[4] (fun k => InKey.stage 4 k) fragment3.1.1) fragment3.2

ffi_value_literal fragment5 : run (stageG id 256 (256 : Int) (257 : Int) stages[5] (fun k => InKey.stage 5 k) fragment4.1.1) fragment4.2
ffi_value_literal_eq fragment5 : run (stageG id 256 (256 : Int) (257 : Int) stages[5] (fun k => InKey.stage 5 k) fragment4.1.1) fragment4.2

ffi_value_literal fragment6 : run (stageG id 256 (256 : Int) (257 : Int) stages[6] (fun k => InKey.stage 6 k) fragment5.1.1) fragment5.2
ffi_value_literal_eq fragment6 : run (stageG id 256 (256 : Int) (257 : Int) stages[6] (fun k => InKey.stage 6 k) fragment5.1.1) fragment5.2

ffi_value_literal fragment7 : run (stageG id 256 (256 : Int) (257 : Int) stages[7] (fun k => InKey.stage 7 k) fragment6.1.1) fragment6.2
ffi_value_literal_eq fragment7 : run (stageG id 256 (256 : Int) (257 : Int) stages[7] (fun k => InKey.stage 7 k) fragment6.1.1) fragment6.2

end Host.Load.Run.Full.Growth64.Expected
