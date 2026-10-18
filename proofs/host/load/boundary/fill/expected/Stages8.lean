import host.load.boundary.fill.expected.Stages7
namespace Host.Load.Run.Full.Fill64.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment32 : run (stageG id 255 (255 : Int) (256 : Int) stages[32] (fun k => InKey.stage 32 k) fragment31.1.1) fragment31.2
ffi_value_literal_eq fragment32 : run (stageG id 255 (255 : Int) (256 : Int) stages[32] (fun k => InKey.stage 32 k) fragment31.1.1) fragment31.2

ffi_value_literal fragment33 : run (stageG id 255 (255 : Int) (256 : Int) stages[33] (fun k => InKey.stage 33 k) fragment32.1.1) fragment32.2
ffi_value_literal_eq fragment33 : run (stageG id 255 (255 : Int) (256 : Int) stages[33] (fun k => InKey.stage 33 k) fragment32.1.1) fragment32.2

ffi_value_literal fragment34 : run (stageG id 255 (255 : Int) (256 : Int) stages[34] (fun k => InKey.stage 34 k) fragment33.1.1) fragment33.2
ffi_value_literal_eq fragment34 : run (stageG id 255 (255 : Int) (256 : Int) stages[34] (fun k => InKey.stage 34 k) fragment33.1.1) fragment33.2

ffi_value_literal fragment35 : run (stageG id 255 (255 : Int) (256 : Int) stages[35] (fun k => InKey.stage 35 k) fragment34.1.1) fragment34.2
ffi_value_literal_eq fragment35 : run (stageG id 255 (255 : Int) (256 : Int) stages[35] (fun k => InKey.stage 35 k) fragment34.1.1) fragment34.2

end Host.Load.Run.Full.Fill64.Expected
