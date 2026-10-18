import host.load.run.full.cached.expected4.Stages10
namespace Host.Load.Run.Full.Cached.Expected4
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment44 : run (stageG id 3 (3 : Int) (4 : Int) stages[44] (fun k => InKey.stage 44 k) fragment43.1.1) fragment43.2
ffi_value_literal_eq fragment44 : run (stageG id 3 (3 : Int) (4 : Int) stages[44] (fun k => InKey.stage 44 k) fragment43.1.1) fragment43.2

ffi_value_literal fragment45 : run (stageG id 3 (3 : Int) (4 : Int) stages[45] (fun k => InKey.stage 45 k) fragment44.1.1) fragment44.2
ffi_value_literal_eq fragment45 : run (stageG id 3 (3 : Int) (4 : Int) stages[45] (fun k => InKey.stage 45 k) fragment44.1.1) fragment44.2

ffi_value_literal fragment46 : run (stageG id 3 (3 : Int) (4 : Int) stages[46] (fun k => InKey.stage 46 k) fragment45.1.1) fragment45.2
ffi_value_literal_eq fragment46 : run (stageG id 3 (3 : Int) (4 : Int) stages[46] (fun k => InKey.stage 46 k) fragment45.1.1) fragment45.2

ffi_value_literal fragment47 : run (stageG id 3 (3 : Int) (4 : Int) stages[47] (fun k => InKey.stage 47 k) fragment46.1.1) fragment46.2
ffi_value_literal_eq fragment47 : run (stageG id 3 (3 : Int) (4 : Int) stages[47] (fun k => InKey.stage 47 k) fragment46.1.1) fragment46.2

end Host.Load.Run.Full.Cached.Expected4
