import host.load.run.full.cached.expected3.Stages13
namespace Host.Load.Run.Full.Cached.Expected3
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment56 : run (stageG id 2 (2 : Int) (3 : Int) stages[56] (fun k => InKey.stage 56 k) fragment55.1.1) fragment55.2
ffi_value_literal_eq fragment56 : run (stageG id 2 (2 : Int) (3 : Int) stages[56] (fun k => InKey.stage 56 k) fragment55.1.1) fragment55.2

ffi_value_literal fragment57 : run (stageG id 2 (2 : Int) (3 : Int) stages[57] (fun k => InKey.stage 57 k) fragment56.1.1) fragment56.2
ffi_value_literal_eq fragment57 : run (stageG id 2 (2 : Int) (3 : Int) stages[57] (fun k => InKey.stage 57 k) fragment56.1.1) fragment56.2

ffi_value_literal fragment58 : run (stageG id 2 (2 : Int) (3 : Int) stages[58] (fun k => InKey.stage 58 k) fragment57.1.1) fragment57.2
ffi_value_literal_eq fragment58 : run (stageG id 2 (2 : Int) (3 : Int) stages[58] (fun k => InKey.stage 58 k) fragment57.1.1) fragment57.2

ffi_value_literal fragment59 : run (stageG id 2 (2 : Int) (3 : Int) stages[59] (fun k => InKey.stage 59 k) fragment58.1.1) fragment58.2
ffi_value_literal_eq fragment59 : run (stageG id 2 (2 : Int) (3 : Int) stages[59] (fun k => InKey.stage 59 k) fragment58.1.1) fragment58.2

end Host.Load.Run.Full.Cached.Expected3
