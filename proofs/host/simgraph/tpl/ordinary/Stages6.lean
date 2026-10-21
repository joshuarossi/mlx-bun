import host.simgraph.tpl.ordinary.Stages5
namespace Host.Mlx.SimGraph.Tpl.Ordinary
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment24 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[24] (fun k => InKey.stage 24 k) fragment23.1.1) fragment23.2
ffi_value_literal_eq fragment24 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[24] (fun k => InKey.stage 24 k) fragment23.1.1) fragment23.2

ffi_value_literal fragment25 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[25] (fun k => InKey.stage 25 k) fragment24.1.1) fragment24.2
ffi_value_literal_eq fragment25 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[25] (fun k => InKey.stage 25 k) fragment24.1.1) fragment24.2

ffi_value_literal fragment26 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[26] (fun k => InKey.stage 26 k) fragment25.1.1) fragment25.2
ffi_value_literal_eq fragment26 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[26] (fun k => InKey.stage 26 k) fragment25.1.1) fragment25.2

ffi_value_literal fragment27 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[27] (fun k => InKey.stage 27 k) fragment26.1.1) fragment26.2
ffi_value_literal_eq fragment27 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[27] (fun k => InKey.stage 27 k) fragment26.1.1) fragment26.2

end Host.Mlx.SimGraph.Tpl.Ordinary
