import host.load.run.full.cached.expected2.Stages8
namespace Host.Load.Run.Full.Cached.Expected2
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment36 : run (stageG id 1 (1 : Int) (2 : Int) stages[36] (fun k => InKey.stage 36 k) fragment35.1.1) fragment35.2
ffi_value_literal_eq fragment36 : run (stageG id 1 (1 : Int) (2 : Int) stages[36] (fun k => InKey.stage 36 k) fragment35.1.1) fragment35.2

ffi_value_literal fragment37 : run (stageG id 1 (1 : Int) (2 : Int) stages[37] (fun k => InKey.stage 37 k) fragment36.1.1) fragment36.2
ffi_value_literal_eq fragment37 : run (stageG id 1 (1 : Int) (2 : Int) stages[37] (fun k => InKey.stage 37 k) fragment36.1.1) fragment36.2

ffi_value_literal fragment38 : run (stageG id 1 (1 : Int) (2 : Int) stages[38] (fun k => InKey.stage 38 k) fragment37.1.1) fragment37.2
ffi_value_literal_eq fragment38 : run (stageG id 1 (1 : Int) (2 : Int) stages[38] (fun k => InKey.stage 38 k) fragment37.1.1) fragment37.2

ffi_value_literal fragment39 : run (stageG id 1 (1 : Int) (2 : Int) stages[39] (fun k => InKey.stage 39 k) fragment38.1.1) fragment38.2
ffi_value_literal_eq fragment39 : run (stageG id 1 (1 : Int) (2 : Int) stages[39] (fun k => InKey.stage 39 k) fragment38.1.1) fragment38.2

end Host.Load.Run.Full.Cached.Expected2
