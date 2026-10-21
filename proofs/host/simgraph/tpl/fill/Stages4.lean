import host.simgraph.tpl.fill.Stages3
namespace Host.Mlx.SimGraph.Tpl.Fill
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment16 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[16] (fun k => InKey.stage 16 k) fragment15.1.1) fragment15.2
ffi_value_literal_eq fragment16 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[16] (fun k => InKey.stage 16 k) fragment15.1.1) fragment15.2

ffi_value_literal fragment17 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[17] (fun k => InKey.stage 17 k) fragment16.1.1) fragment16.2
ffi_value_literal_eq fragment17 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[17] (fun k => InKey.stage 17 k) fragment16.1.1) fragment16.2

ffi_value_literal fragment18 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[18] (fun k => InKey.stage 18 k) fragment17.1.1) fragment17.2
ffi_value_literal_eq fragment18 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[18] (fun k => InKey.stage 18 k) fragment17.1.1) fragment17.2

ffi_value_literal fragment19 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[19] (fun k => InKey.stage 19 k) fragment18.1.1) fragment18.2
ffi_value_literal_eq fragment19 : run (stageG SDim.lit 255 SDim.pos SDim.pos1 stages[19] (fun k => InKey.stage 19 k) fragment18.1.1) fragment18.2

end Host.Mlx.SimGraph.Tpl.Fill
