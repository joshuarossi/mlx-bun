import host.simgraph.tpl.fill.Stages9
namespace Host.Mlx.SimGraph.Tpl.Fill
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment40 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[40] (fun k => InKey.stage 40 k) fragment39.1.1) fragment39.2
ffi_value_literal_eq fragment40 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[40] (fun k => InKey.stage 40 k) fragment39.1.1) fragment39.2

ffi_value_literal fragment41 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[41] (fun k => InKey.stage 41 k) fragment40.1.1) fragment40.2
ffi_value_literal_eq fragment41 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[41] (fun k => InKey.stage 41 k) fragment40.1.1) fragment40.2

ffi_value_literal fragment42 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[42] (fun k => InKey.stage 42 k) fragment41.1.1) fragment41.2
ffi_value_literal_eq fragment42 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[42] (fun k => InKey.stage 42 k) fragment41.1.1) fragment41.2

ffi_value_literal fragment43 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[43] (fun k => InKey.stage 43 k) fragment42.1.1) fragment42.2
ffi_value_literal_eq fragment43 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[43] (fun k => InKey.stage 43 k) fragment42.1.1) fragment42.2

end Host.Mlx.SimGraph.Tpl.Fill
