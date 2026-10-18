import host.load.run.full.cached.expected5.Stages12
namespace Host.Load.Run.Full.Cached.Expected5
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment52 : run (stageG id 4 (4 : Int) (5 : Int) stages[52] (fun k => InKey.stage 52 k) fragment51.1.1) fragment51.2
ffi_value_literal_eq fragment52 : run (stageG id 4 (4 : Int) (5 : Int) stages[52] (fun k => InKey.stage 52 k) fragment51.1.1) fragment51.2

ffi_value_literal fragment53 : run (stageG id 4 (4 : Int) (5 : Int) stages[53] (fun k => InKey.stage 53 k) fragment52.1.1) fragment52.2
ffi_value_literal_eq fragment53 : run (stageG id 4 (4 : Int) (5 : Int) stages[53] (fun k => InKey.stage 53 k) fragment52.1.1) fragment52.2

ffi_value_literal fragment54 : run (stageG id 4 (4 : Int) (5 : Int) stages[54] (fun k => InKey.stage 54 k) fragment53.1.1) fragment53.2
ffi_value_literal_eq fragment54 : run (stageG id 4 (4 : Int) (5 : Int) stages[54] (fun k => InKey.stage 54 k) fragment53.1.1) fragment53.2

ffi_value_literal fragment55 : run (stageG id 4 (4 : Int) (5 : Int) stages[55] (fun k => InKey.stage 55 k) fragment54.1.1) fragment54.2
ffi_value_literal_eq fragment55 : run (stageG id 4 (4 : Int) (5 : Int) stages[55] (fun k => InKey.stage 55 k) fragment54.1.1) fragment54.2

end Host.Load.Run.Full.Cached.Expected5
