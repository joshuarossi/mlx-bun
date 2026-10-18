import host.load.boundary.fill.expected.Stages14
namespace Host.Load.Run.Full.Fill64.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment60 : run (stageG id 255 (255 : Int) (256 : Int) stages[60] (fun k => InKey.stage 60 k) fragment59.1.1) fragment59.2
ffi_value_literal_eq fragment60 : run (stageG id 255 (255 : Int) (256 : Int) stages[60] (fun k => InKey.stage 60 k) fragment59.1.1) fragment59.2

ffi_value_literal fragment61 : run (stageG id 255 (255 : Int) (256 : Int) stages[61] (fun k => InKey.stage 61 k) fragment60.1.1) fragment60.2
ffi_value_literal_eq fragment61 : run (stageG id 255 (255 : Int) (256 : Int) stages[61] (fun k => InKey.stage 61 k) fragment60.1.1) fragment60.2

ffi_value_literal fragment62 : run (stageG id 255 (255 : Int) (256 : Int) stages[62] (fun k => InKey.stage 62 k) fragment61.1.1) fragment61.2
ffi_value_literal_eq fragment62 : run (stageG id 255 (255 : Int) (256 : Int) stages[62] (fun k => InKey.stage 62 k) fragment61.1.1) fragment61.2

ffi_value_literal fragment63 : run (stageG id 255 (255 : Int) (256 : Int) stages[63] (fun k => InKey.stage 63 k) fragment62.1.1) fragment62.2
ffi_value_literal_eq fragment63 : run (stageG id 255 (255 : Int) (256 : Int) stages[63] (fun k => InKey.stage 63 k) fragment62.1.1) fragment62.2

end Host.Load.Run.Full.Fill64.Expected
