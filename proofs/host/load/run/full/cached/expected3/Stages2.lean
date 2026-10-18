import host.load.run.full.cached.expected3.Stages1
namespace Host.Load.Run.Full.Cached.Expected3
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment8 : run (stageG id 2 (2 : Int) (3 : Int) stages[8] (fun k => InKey.stage 8 k) fragment7.1.1) fragment7.2
ffi_value_literal_eq fragment8 : run (stageG id 2 (2 : Int) (3 : Int) stages[8] (fun k => InKey.stage 8 k) fragment7.1.1) fragment7.2

ffi_value_literal fragment9 : run (stageG id 2 (2 : Int) (3 : Int) stages[9] (fun k => InKey.stage 9 k) fragment8.1.1) fragment8.2
ffi_value_literal_eq fragment9 : run (stageG id 2 (2 : Int) (3 : Int) stages[9] (fun k => InKey.stage 9 k) fragment8.1.1) fragment8.2

ffi_value_literal fragment10 : run (stageG id 2 (2 : Int) (3 : Int) stages[10] (fun k => InKey.stage 10 k) fragment9.1.1) fragment9.2
ffi_value_literal_eq fragment10 : run (stageG id 2 (2 : Int) (3 : Int) stages[10] (fun k => InKey.stage 10 k) fragment9.1.1) fragment9.2

ffi_value_literal fragment11 : run (stageG id 2 (2 : Int) (3 : Int) stages[11] (fun k => InKey.stage 11 k) fragment10.1.1) fragment10.2
ffi_value_literal_eq fragment11 : run (stageG id 2 (2 : Int) (3 : Int) stages[11] (fun k => InKey.stage 11 k) fragment10.1.1) fragment10.2

end Host.Load.Run.Full.Cached.Expected3
