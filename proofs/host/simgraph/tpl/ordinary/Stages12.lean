import host.simgraph.tpl.ordinary.Stages11
namespace Host.Mlx.SimGraph.Tpl.Ordinary
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment48 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[48] (fun k => InKey.stage 48 k) fragment47.1.1) fragment47.2
ffi_value_literal_eq fragment48 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[48] (fun k => InKey.stage 48 k) fragment47.1.1) fragment47.2

ffi_value_literal fragment49 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[49] (fun k => InKey.stage 49 k) fragment48.1.1) fragment48.2
ffi_value_literal_eq fragment49 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[49] (fun k => InKey.stage 49 k) fragment48.1.1) fragment48.2

ffi_value_literal fragment50 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[50] (fun k => InKey.stage 50 k) fragment49.1.1) fragment49.2
ffi_value_literal_eq fragment50 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[50] (fun k => InKey.stage 50 k) fragment49.1.1) fragment49.2

ffi_value_literal fragment51 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[51] (fun k => InKey.stage 51 k) fragment50.1.1) fragment50.2
ffi_value_literal_eq fragment51 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[51] (fun k => InKey.stage 51 k) fragment50.1.1) fragment50.2

end Host.Mlx.SimGraph.Tpl.Ordinary
