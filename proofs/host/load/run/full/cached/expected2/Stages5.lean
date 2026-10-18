import host.load.run.full.cached.expected2.Stages4
namespace Host.Load.Run.Full.Cached.Expected2
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment20 : run (stageG id 1 (1 : Int) (2 : Int) stages[20] (fun k => InKey.stage 20 k) fragment19.1.1) fragment19.2
ffi_value_literal_eq fragment20 : run (stageG id 1 (1 : Int) (2 : Int) stages[20] (fun k => InKey.stage 20 k) fragment19.1.1) fragment19.2

ffi_value_literal fragment21 : run (stageG id 1 (1 : Int) (2 : Int) stages[21] (fun k => InKey.stage 21 k) fragment20.1.1) fragment20.2
ffi_value_literal_eq fragment21 : run (stageG id 1 (1 : Int) (2 : Int) stages[21] (fun k => InKey.stage 21 k) fragment20.1.1) fragment20.2

ffi_value_literal fragment22 : run (stageG id 1 (1 : Int) (2 : Int) stages[22] (fun k => InKey.stage 22 k) fragment21.1.1) fragment21.2
ffi_value_literal_eq fragment22 : run (stageG id 1 (1 : Int) (2 : Int) stages[22] (fun k => InKey.stage 22 k) fragment21.1.1) fragment21.2

ffi_value_literal fragment23 : run (stageG id 1 (1 : Int) (2 : Int) stages[23] (fun k => InKey.stage 23 k) fragment22.1.1) fragment22.2
ffi_value_literal_eq fragment23 : run (stageG id 1 (1 : Int) (2 : Int) stages[23] (fun k => InKey.stage 23 k) fragment22.1.1) fragment22.2

end Host.Load.Run.Full.Cached.Expected2
