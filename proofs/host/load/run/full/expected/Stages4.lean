import host.load.run.full.expected.Stages3
namespace Host.Load.Run.Full.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment32 : run (stageG id 0 (0 : Int) (1 : Int) stages[32] (fun k => InKey.stage 32 k) fragment31.1.1) fragment31.2
ffi_value_literal_eq fragment32 : run (stageG id 0 (0 : Int) (1 : Int) stages[32] (fun k => InKey.stage 32 k) fragment31.1.1) fragment31.2

ffi_value_literal fragment33 : run (stageG id 0 (0 : Int) (1 : Int) stages[33] (fun k => InKey.stage 33 k) fragment32.1.1) fragment32.2
ffi_value_literal_eq fragment33 : run (stageG id 0 (0 : Int) (1 : Int) stages[33] (fun k => InKey.stage 33 k) fragment32.1.1) fragment32.2

ffi_value_literal fragment34 : run (stageG id 0 (0 : Int) (1 : Int) stages[34] (fun k => InKey.stage 34 k) fragment33.1.1) fragment33.2
ffi_value_literal_eq fragment34 : run (stageG id 0 (0 : Int) (1 : Int) stages[34] (fun k => InKey.stage 34 k) fragment33.1.1) fragment33.2

ffi_value_literal fragment35 : run (stageG id 0 (0 : Int) (1 : Int) stages[35] (fun k => InKey.stage 35 k) fragment34.1.1) fragment34.2
ffi_value_literal_eq fragment35 : run (stageG id 0 (0 : Int) (1 : Int) stages[35] (fun k => InKey.stage 35 k) fragment34.1.1) fragment34.2

ffi_value_literal fragment36 : run (stageG id 0 (0 : Int) (1 : Int) stages[36] (fun k => InKey.stage 36 k) fragment35.1.1) fragment35.2
ffi_value_literal_eq fragment36 : run (stageG id 0 (0 : Int) (1 : Int) stages[36] (fun k => InKey.stage 36 k) fragment35.1.1) fragment35.2

ffi_value_literal fragment37 : run (stageG id 0 (0 : Int) (1 : Int) stages[37] (fun k => InKey.stage 37 k) fragment36.1.1) fragment36.2
ffi_value_literal_eq fragment37 : run (stageG id 0 (0 : Int) (1 : Int) stages[37] (fun k => InKey.stage 37 k) fragment36.1.1) fragment36.2

ffi_value_literal fragment38 : run (stageG id 0 (0 : Int) (1 : Int) stages[38] (fun k => InKey.stage 38 k) fragment37.1.1) fragment37.2
ffi_value_literal_eq fragment38 : run (stageG id 0 (0 : Int) (1 : Int) stages[38] (fun k => InKey.stage 38 k) fragment37.1.1) fragment37.2

ffi_value_literal fragment39 : run (stageG id 0 (0 : Int) (1 : Int) stages[39] (fun k => InKey.stage 39 k) fragment38.1.1) fragment38.2
ffi_value_literal_eq fragment39 : run (stageG id 0 (0 : Int) (1 : Int) stages[39] (fun k => InKey.stage 39 k) fragment38.1.1) fragment38.2

end Host.Load.Run.Full.Expected
