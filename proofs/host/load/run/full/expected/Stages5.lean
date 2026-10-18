import host.load.run.full.expected.Stages4
namespace Host.Load.Run.Full.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment40 : run (stageG id 0 (0 : Int) (1 : Int) stages[40] (fun k => InKey.stage 40 k) fragment39.1.1) fragment39.2
ffi_value_literal_eq fragment40 : run (stageG id 0 (0 : Int) (1 : Int) stages[40] (fun k => InKey.stage 40 k) fragment39.1.1) fragment39.2

ffi_value_literal fragment41 : run (stageG id 0 (0 : Int) (1 : Int) stages[41] (fun k => InKey.stage 41 k) fragment40.1.1) fragment40.2
ffi_value_literal_eq fragment41 : run (stageG id 0 (0 : Int) (1 : Int) stages[41] (fun k => InKey.stage 41 k) fragment40.1.1) fragment40.2

ffi_value_literal fragment42 : run (stageG id 0 (0 : Int) (1 : Int) stages[42] (fun k => InKey.stage 42 k) fragment41.1.1) fragment41.2
ffi_value_literal_eq fragment42 : run (stageG id 0 (0 : Int) (1 : Int) stages[42] (fun k => InKey.stage 42 k) fragment41.1.1) fragment41.2

ffi_value_literal fragment43 : run (stageG id 0 (0 : Int) (1 : Int) stages[43] (fun k => InKey.stage 43 k) fragment42.1.1) fragment42.2
ffi_value_literal_eq fragment43 : run (stageG id 0 (0 : Int) (1 : Int) stages[43] (fun k => InKey.stage 43 k) fragment42.1.1) fragment42.2

ffi_value_literal fragment44 : run (stageG id 0 (0 : Int) (1 : Int) stages[44] (fun k => InKey.stage 44 k) fragment43.1.1) fragment43.2
ffi_value_literal_eq fragment44 : run (stageG id 0 (0 : Int) (1 : Int) stages[44] (fun k => InKey.stage 44 k) fragment43.1.1) fragment43.2

ffi_value_literal fragment45 : run (stageG id 0 (0 : Int) (1 : Int) stages[45] (fun k => InKey.stage 45 k) fragment44.1.1) fragment44.2
ffi_value_literal_eq fragment45 : run (stageG id 0 (0 : Int) (1 : Int) stages[45] (fun k => InKey.stage 45 k) fragment44.1.1) fragment44.2

ffi_value_literal fragment46 : run (stageG id 0 (0 : Int) (1 : Int) stages[46] (fun k => InKey.stage 46 k) fragment45.1.1) fragment45.2
ffi_value_literal_eq fragment46 : run (stageG id 0 (0 : Int) (1 : Int) stages[46] (fun k => InKey.stage 46 k) fragment45.1.1) fragment45.2

ffi_value_literal fragment47 : run (stageG id 0 (0 : Int) (1 : Int) stages[47] (fun k => InKey.stage 47 k) fragment46.1.1) fragment46.2
ffi_value_literal_eq fragment47 : run (stageG id 0 (0 : Int) (1 : Int) stages[47] (fun k => InKey.stage 47 k) fragment46.1.1) fragment46.2

end Host.Load.Run.Full.Expected
