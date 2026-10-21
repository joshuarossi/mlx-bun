import host.simgraph.tpl.ordinary.Stages0
namespace Host.Mlx.SimGraph.Tpl.Ordinary
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment4 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[4] (fun k => InKey.stage 4 k) fragment3.1.1) fragment3.2
ffi_value_literal_eq fragment4 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[4] (fun k => InKey.stage 4 k) fragment3.1.1) fragment3.2

ffi_value_literal fragment5 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[5] (fun k => InKey.stage 5 k) fragment4.1.1) fragment4.2
ffi_value_literal_eq fragment5 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[5] (fun k => InKey.stage 5 k) fragment4.1.1) fragment4.2

ffi_value_literal fragment6 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[6] (fun k => InKey.stage 6 k) fragment5.1.1) fragment5.2
ffi_value_literal_eq fragment6 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[6] (fun k => InKey.stage 6 k) fragment5.1.1) fragment5.2

ffi_value_literal fragment7 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[7] (fun k => InKey.stage 7 k) fragment6.1.1) fragment6.2
ffi_value_literal_eq fragment7 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[7] (fun k => InKey.stage 7 k) fragment6.1.1) fragment6.2

end Host.Mlx.SimGraph.Tpl.Ordinary
