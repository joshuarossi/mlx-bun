import host.simgraph.tpl.growth.Stages7
namespace Host.Mlx.SimGraph.Tpl.Growth
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment32 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[32] (fun k => InKey.stage 32 k) fragment31.1.1) fragment31.2
ffi_value_literal_eq fragment32 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[32] (fun k => InKey.stage 32 k) fragment31.1.1) fragment31.2

ffi_value_literal fragment33 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[33] (fun k => InKey.stage 33 k) fragment32.1.1) fragment32.2
ffi_value_literal_eq fragment33 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[33] (fun k => InKey.stage 33 k) fragment32.1.1) fragment32.2

ffi_value_literal fragment34 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[34] (fun k => InKey.stage 34 k) fragment33.1.1) fragment33.2
ffi_value_literal_eq fragment34 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[34] (fun k => InKey.stage 34 k) fragment33.1.1) fragment33.2

ffi_value_literal fragment35 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[35] (fun k => InKey.stage 35 k) fragment34.1.1) fragment34.2
ffi_value_literal_eq fragment35 : run (stageG SDim.lit 256 SDim.pos SDim.pos1 stages[35] (fun k => InKey.stage 35 k) fragment34.1.1) fragment34.2

end Host.Mlx.SimGraph.Tpl.Growth
