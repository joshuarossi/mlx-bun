import host.simgraph.tpl.fill.Stages10
namespace Host.Mlx.SimGraph.Tpl.Fill
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment44 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[44] (fun k => InKey.stage 44 k) fragment43.1.1) fragment43.2
ffi_value_literal_eq fragment44 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[44] (fun k => InKey.stage 44 k) fragment43.1.1) fragment43.2

ffi_value_literal fragment45 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[45] (fun k => InKey.stage 45 k) fragment44.1.1) fragment44.2
ffi_value_literal_eq fragment45 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[45] (fun k => InKey.stage 45 k) fragment44.1.1) fragment44.2

ffi_value_literal fragment46 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[46] (fun k => InKey.stage 46 k) fragment45.1.1) fragment45.2
ffi_value_literal_eq fragment46 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[46] (fun k => InKey.stage 46 k) fragment45.1.1) fragment45.2

ffi_value_literal fragment47 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[47] (fun k => InKey.stage 47 k) fragment46.1.1) fragment46.2
ffi_value_literal_eq fragment47 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[47] (fun k => InKey.stage 47 k) fragment46.1.1) fragment46.2

end Host.Mlx.SimGraph.Tpl.Fill
