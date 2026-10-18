import host.load.run.full.expected.Stages2
namespace Host.Load.Run.Full.Expected
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment24 : run (stageG id 0 (0 : Int) (1 : Int) stages[24] (fun k => InKey.stage 24 k) fragment23.1.1) fragment23.2
ffi_value_literal_eq fragment24 : run (stageG id 0 (0 : Int) (1 : Int) stages[24] (fun k => InKey.stage 24 k) fragment23.1.1) fragment23.2

ffi_value_literal fragment25 : run (stageG id 0 (0 : Int) (1 : Int) stages[25] (fun k => InKey.stage 25 k) fragment24.1.1) fragment24.2
ffi_value_literal_eq fragment25 : run (stageG id 0 (0 : Int) (1 : Int) stages[25] (fun k => InKey.stage 25 k) fragment24.1.1) fragment24.2

ffi_value_literal fragment26 : run (stageG id 0 (0 : Int) (1 : Int) stages[26] (fun k => InKey.stage 26 k) fragment25.1.1) fragment25.2
ffi_value_literal_eq fragment26 : run (stageG id 0 (0 : Int) (1 : Int) stages[26] (fun k => InKey.stage 26 k) fragment25.1.1) fragment25.2

ffi_value_literal fragment27 : run (stageG id 0 (0 : Int) (1 : Int) stages[27] (fun k => InKey.stage 27 k) fragment26.1.1) fragment26.2
ffi_value_literal_eq fragment27 : run (stageG id 0 (0 : Int) (1 : Int) stages[27] (fun k => InKey.stage 27 k) fragment26.1.1) fragment26.2

ffi_value_literal fragment28 : run (stageG id 0 (0 : Int) (1 : Int) stages[28] (fun k => InKey.stage 28 k) fragment27.1.1) fragment27.2
ffi_value_literal_eq fragment28 : run (stageG id 0 (0 : Int) (1 : Int) stages[28] (fun k => InKey.stage 28 k) fragment27.1.1) fragment27.2

ffi_value_literal fragment29 : run (stageG id 0 (0 : Int) (1 : Int) stages[29] (fun k => InKey.stage 29 k) fragment28.1.1) fragment28.2
ffi_value_literal_eq fragment29 : run (stageG id 0 (0 : Int) (1 : Int) stages[29] (fun k => InKey.stage 29 k) fragment28.1.1) fragment28.2

ffi_value_literal fragment30 : run (stageG id 0 (0 : Int) (1 : Int) stages[30] (fun k => InKey.stage 30 k) fragment29.1.1) fragment29.2
ffi_value_literal_eq fragment30 : run (stageG id 0 (0 : Int) (1 : Int) stages[30] (fun k => InKey.stage 30 k) fragment29.1.1) fragment29.2

ffi_value_literal fragment31 : run (stageG id 0 (0 : Int) (1 : Int) stages[31] (fun k => InKey.stage 31 k) fragment30.1.1) fragment30.2
ffi_value_literal_eq fragment31 : run (stageG id 0 (0 : Int) (1 : Int) stages[31] (fun k => InKey.stage 31 k) fragment30.1.1) fragment30.2

end Host.Load.Run.Full.Expected
