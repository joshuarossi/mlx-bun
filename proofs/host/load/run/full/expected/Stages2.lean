import host.load.run.full.expected.Stages1
namespace Host.Load.Run.Full.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment16 : run (stageG id 0 (0 : Int) (1 : Int) stages[16] (fun k => InKey.stage 16 k) fragment15.1.1) fragment15.2
ffi_value_literal_eq fragment16 : run (stageG id 0 (0 : Int) (1 : Int) stages[16] (fun k => InKey.stage 16 k) fragment15.1.1) fragment15.2

ffi_value_literal fragment17 : run (stageG id 0 (0 : Int) (1 : Int) stages[17] (fun k => InKey.stage 17 k) fragment16.1.1) fragment16.2
ffi_value_literal_eq fragment17 : run (stageG id 0 (0 : Int) (1 : Int) stages[17] (fun k => InKey.stage 17 k) fragment16.1.1) fragment16.2

ffi_value_literal fragment18 : run (stageG id 0 (0 : Int) (1 : Int) stages[18] (fun k => InKey.stage 18 k) fragment17.1.1) fragment17.2
ffi_value_literal_eq fragment18 : run (stageG id 0 (0 : Int) (1 : Int) stages[18] (fun k => InKey.stage 18 k) fragment17.1.1) fragment17.2

ffi_value_literal fragment19 : run (stageG id 0 (0 : Int) (1 : Int) stages[19] (fun k => InKey.stage 19 k) fragment18.1.1) fragment18.2
ffi_value_literal_eq fragment19 : run (stageG id 0 (0 : Int) (1 : Int) stages[19] (fun k => InKey.stage 19 k) fragment18.1.1) fragment18.2

ffi_value_literal fragment20 : run (stageG id 0 (0 : Int) (1 : Int) stages[20] (fun k => InKey.stage 20 k) fragment19.1.1) fragment19.2
ffi_value_literal_eq fragment20 : run (stageG id 0 (0 : Int) (1 : Int) stages[20] (fun k => InKey.stage 20 k) fragment19.1.1) fragment19.2

ffi_value_literal fragment21 : run (stageG id 0 (0 : Int) (1 : Int) stages[21] (fun k => InKey.stage 21 k) fragment20.1.1) fragment20.2
ffi_value_literal_eq fragment21 : run (stageG id 0 (0 : Int) (1 : Int) stages[21] (fun k => InKey.stage 21 k) fragment20.1.1) fragment20.2

ffi_value_literal fragment22 : run (stageG id 0 (0 : Int) (1 : Int) stages[22] (fun k => InKey.stage 22 k) fragment21.1.1) fragment21.2
ffi_value_literal_eq fragment22 : run (stageG id 0 (0 : Int) (1 : Int) stages[22] (fun k => InKey.stage 22 k) fragment21.1.1) fragment21.2

ffi_value_literal fragment23 : run (stageG id 0 (0 : Int) (1 : Int) stages[23] (fun k => InKey.stage 23 k) fragment22.1.1) fragment22.2
ffi_value_literal_eq fragment23 : run (stageG id 0 (0 : Int) (1 : Int) stages[23] (fun k => InKey.stage 23 k) fragment22.1.1) fragment22.2

end Host.Load.Run.Full.Expected
