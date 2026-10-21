import host.simgraph.tpl.fill.Stages8
namespace Host.Mlx.SimGraph.Tpl.Fill
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment36 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[36] (fun k => InKey.stage 36 k) fragment35.1.1) fragment35.2
ffi_value_literal_eq fragment36 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[36] (fun k => InKey.stage 36 k) fragment35.1.1) fragment35.2

ffi_value_literal fragment37 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[37] (fun k => InKey.stage 37 k) fragment36.1.1) fragment36.2
ffi_value_literal_eq fragment37 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[37] (fun k => InKey.stage 37 k) fragment36.1.1) fragment36.2

ffi_value_literal fragment38 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[38] (fun k => InKey.stage 38 k) fragment37.1.1) fragment37.2
ffi_value_literal_eq fragment38 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[38] (fun k => InKey.stage 38 k) fragment37.1.1) fragment37.2

ffi_value_literal fragment39 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[39] (fun k => InKey.stage 39 k) fragment38.1.1) fragment38.2
ffi_value_literal_eq fragment39 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[39] (fun k => InKey.stage 39 k) fragment38.1.1) fragment38.2

end Host.Mlx.SimGraph.Tpl.Fill
