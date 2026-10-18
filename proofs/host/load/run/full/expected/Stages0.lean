import host.load.run.full.expected.Base
namespace Host.Load.Run.Full.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment0 : run (stageG id 0 (0 : Int) (1 : Int) stages[0] (fun k => InKey.stage 0 k) embedded.1) embedded.2
ffi_value_literal_eq fragment0 : run (stageG id 0 (0 : Int) (1 : Int) stages[0] (fun k => InKey.stage 0 k) embedded.1) embedded.2

ffi_value_literal fragment1 : run (stageG id 0 (0 : Int) (1 : Int) stages[1] (fun k => InKey.stage 1 k) fragment0.1.1) fragment0.2
ffi_value_literal_eq fragment1 : run (stageG id 0 (0 : Int) (1 : Int) stages[1] (fun k => InKey.stage 1 k) fragment0.1.1) fragment0.2

ffi_value_literal fragment2 : run (stageG id 0 (0 : Int) (1 : Int) stages[2] (fun k => InKey.stage 2 k) fragment1.1.1) fragment1.2
ffi_value_literal_eq fragment2 : run (stageG id 0 (0 : Int) (1 : Int) stages[2] (fun k => InKey.stage 2 k) fragment1.1.1) fragment1.2

ffi_value_literal fragment3 : run (stageG id 0 (0 : Int) (1 : Int) stages[3] (fun k => InKey.stage 3 k) fragment2.1.1) fragment2.2
ffi_value_literal_eq fragment3 : run (stageG id 0 (0 : Int) (1 : Int) stages[3] (fun k => InKey.stage 3 k) fragment2.1.1) fragment2.2

ffi_value_literal fragment4 : run (stageG id 0 (0 : Int) (1 : Int) stages[4] (fun k => InKey.stage 4 k) fragment3.1.1) fragment3.2
ffi_value_literal_eq fragment4 : run (stageG id 0 (0 : Int) (1 : Int) stages[4] (fun k => InKey.stage 4 k) fragment3.1.1) fragment3.2

ffi_value_literal fragment5 : run (stageG id 0 (0 : Int) (1 : Int) stages[5] (fun k => InKey.stage 5 k) fragment4.1.1) fragment4.2
ffi_value_literal_eq fragment5 : run (stageG id 0 (0 : Int) (1 : Int) stages[5] (fun k => InKey.stage 5 k) fragment4.1.1) fragment4.2

ffi_value_literal fragment6 : run (stageG id 0 (0 : Int) (1 : Int) stages[6] (fun k => InKey.stage 6 k) fragment5.1.1) fragment5.2
ffi_value_literal_eq fragment6 : run (stageG id 0 (0 : Int) (1 : Int) stages[6] (fun k => InKey.stage 6 k) fragment5.1.1) fragment5.2

ffi_value_literal fragment7 : run (stageG id 0 (0 : Int) (1 : Int) stages[7] (fun k => InKey.stage 7 k) fragment6.1.1) fragment6.2
ffi_value_literal_eq fragment7 : run (stageG id 0 (0 : Int) (1 : Int) stages[7] (fun k => InKey.stage 7 k) fragment6.1.1) fragment6.2

end Host.Load.Run.Full.Expected
