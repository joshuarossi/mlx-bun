import host.load.run.full.cached.expected3.Stages6
namespace Host.Load.Run.Full.Cached.Expected3
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment28 : run (stageG id 2 (2 : Int) (3 : Int) stages[28] (fun k => InKey.stage 28 k) fragment27.1.1) fragment27.2
ffi_value_literal_eq fragment28 : run (stageG id 2 (2 : Int) (3 : Int) stages[28] (fun k => InKey.stage 28 k) fragment27.1.1) fragment27.2

ffi_value_literal fragment29 : run (stageG id 2 (2 : Int) (3 : Int) stages[29] (fun k => InKey.stage 29 k) fragment28.1.1) fragment28.2
ffi_value_literal_eq fragment29 : run (stageG id 2 (2 : Int) (3 : Int) stages[29] (fun k => InKey.stage 29 k) fragment28.1.1) fragment28.2

ffi_value_literal fragment30 : run (stageG id 2 (2 : Int) (3 : Int) stages[30] (fun k => InKey.stage 30 k) fragment29.1.1) fragment29.2
ffi_value_literal_eq fragment30 : run (stageG id 2 (2 : Int) (3 : Int) stages[30] (fun k => InKey.stage 30 k) fragment29.1.1) fragment29.2

ffi_value_literal fragment31 : run (stageG id 2 (2 : Int) (3 : Int) stages[31] (fun k => InKey.stage 31 k) fragment30.1.1) fragment30.2
ffi_value_literal_eq fragment31 : run (stageG id 2 (2 : Int) (3 : Int) stages[31] (fun k => InKey.stage 31 k) fragment30.1.1) fragment30.2

end Host.Load.Run.Full.Cached.Expected3
