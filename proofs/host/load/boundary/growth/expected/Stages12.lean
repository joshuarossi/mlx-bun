import host.load.boundary.growth.expected.Stages11
namespace Host.Load.Run.Full.Growth64.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment48 : run (stageG id 256 (256 : Int) (257 : Int) stages[48] (fun k => InKey.stage 48 k) fragment47.1.1) fragment47.2
ffi_value_literal_eq fragment48 : run (stageG id 256 (256 : Int) (257 : Int) stages[48] (fun k => InKey.stage 48 k) fragment47.1.1) fragment47.2

ffi_value_literal fragment49 : run (stageG id 256 (256 : Int) (257 : Int) stages[49] (fun k => InKey.stage 49 k) fragment48.1.1) fragment48.2
ffi_value_literal_eq fragment49 : run (stageG id 256 (256 : Int) (257 : Int) stages[49] (fun k => InKey.stage 49 k) fragment48.1.1) fragment48.2

ffi_value_literal fragment50 : run (stageG id 256 (256 : Int) (257 : Int) stages[50] (fun k => InKey.stage 50 k) fragment49.1.1) fragment49.2
ffi_value_literal_eq fragment50 : run (stageG id 256 (256 : Int) (257 : Int) stages[50] (fun k => InKey.stage 50 k) fragment49.1.1) fragment49.2

ffi_value_literal fragment51 : run (stageG id 256 (256 : Int) (257 : Int) stages[51] (fun k => InKey.stage 51 k) fragment50.1.1) fragment50.2
ffi_value_literal_eq fragment51 : run (stageG id 256 (256 : Int) (257 : Int) stages[51] (fun k => InKey.stage 51 k) fragment50.1.1) fragment50.2

end Host.Load.Run.Full.Growth64.Expected
