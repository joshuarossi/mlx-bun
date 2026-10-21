import host.simgraph.tpl.growth.Stages12
namespace Host.Mlx.SimGraph.Tpl.Growth
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment52 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[52] (fun k => InKey.stage 52 k) fragment51.1.1) fragment51.2
ffi_value_literal_eq fragment52 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[52] (fun k => InKey.stage 52 k) fragment51.1.1) fragment51.2

ffi_value_literal fragment53 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[53] (fun k => InKey.stage 53 k) fragment52.1.1) fragment52.2
ffi_value_literal_eq fragment53 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[53] (fun k => InKey.stage 53 k) fragment52.1.1) fragment52.2

ffi_value_literal fragment54 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[54] (fun k => InKey.stage 54 k) fragment53.1.1) fragment53.2
ffi_value_literal_eq fragment54 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[54] (fun k => InKey.stage 54 k) fragment53.1.1) fragment53.2

ffi_value_literal fragment55 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[55] (fun k => InKey.stage 55 k) fragment54.1.1) fragment54.2
ffi_value_literal_eq fragment55 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[55] (fun k => InKey.stage 55 k) fragment54.1.1) fragment54.2

end Host.Mlx.SimGraph.Tpl.Growth
