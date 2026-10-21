import host.simgraph.tpl.growth.Stages2
namespace Host.Mlx.SimGraph.Tpl.Growth
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment12 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[12] (fun k => InKey.stage 12 k) fragment11.1.1) fragment11.2
ffi_value_literal_eq fragment12 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[12] (fun k => InKey.stage 12 k) fragment11.1.1) fragment11.2

ffi_value_literal fragment13 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[13] (fun k => InKey.stage 13 k) fragment12.1.1) fragment12.2
ffi_value_literal_eq fragment13 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[13] (fun k => InKey.stage 13 k) fragment12.1.1) fragment12.2

ffi_value_literal fragment14 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[14] (fun k => InKey.stage 14 k) fragment13.1.1) fragment13.2
ffi_value_literal_eq fragment14 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[14] (fun k => InKey.stage 14 k) fragment13.1.1) fragment13.2

ffi_value_literal fragment15 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[15] (fun k => InKey.stage 15 k) fragment14.1.1) fragment14.2
ffi_value_literal_eq fragment15 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[15] (fun k => InKey.stage 15 k) fragment14.1.1) fragment14.2

end Host.Mlx.SimGraph.Tpl.Growth
