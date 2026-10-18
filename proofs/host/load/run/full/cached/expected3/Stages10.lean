import host.load.run.full.cached.expected3.Stages9
namespace Host.Load.Run.Full.Cached.Expected3
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment40 : run (stageG id 2 (2 : Int) (3 : Int) stages[40] (fun k => InKey.stage 40 k) fragment39.1.1) fragment39.2
ffi_value_literal_eq fragment40 : run (stageG id 2 (2 : Int) (3 : Int) stages[40] (fun k => InKey.stage 40 k) fragment39.1.1) fragment39.2

ffi_value_literal fragment41 : run (stageG id 2 (2 : Int) (3 : Int) stages[41] (fun k => InKey.stage 41 k) fragment40.1.1) fragment40.2
ffi_value_literal_eq fragment41 : run (stageG id 2 (2 : Int) (3 : Int) stages[41] (fun k => InKey.stage 41 k) fragment40.1.1) fragment40.2

ffi_value_literal fragment42 : run (stageG id 2 (2 : Int) (3 : Int) stages[42] (fun k => InKey.stage 42 k) fragment41.1.1) fragment41.2
ffi_value_literal_eq fragment42 : run (stageG id 2 (2 : Int) (3 : Int) stages[42] (fun k => InKey.stage 42 k) fragment41.1.1) fragment41.2

ffi_value_literal fragment43 : run (stageG id 2 (2 : Int) (3 : Int) stages[43] (fun k => InKey.stage 43 k) fragment42.1.1) fragment42.2
ffi_value_literal_eq fragment43 : run (stageG id 2 (2 : Int) (3 : Int) stages[43] (fun k => InKey.stage 43 k) fragment42.1.1) fragment42.2

end Host.Load.Run.Full.Cached.Expected3
