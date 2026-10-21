import host.simgraph.tpl.ordinary.Stages6
namespace Host.Mlx.SimGraph.Tpl.Ordinary
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

ffi_value_literal fragment28 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[28] (fun k => InKey.stage 28 k) fragment27.1.1) fragment27.2
ffi_value_literal_eq fragment28 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[28] (fun k => InKey.stage 28 k) fragment27.1.1) fragment27.2

ffi_value_literal fragment29 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[29] (fun k => InKey.stage 29 k) fragment28.1.1) fragment28.2
ffi_value_literal_eq fragment29 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[29] (fun k => InKey.stage 29 k) fragment28.1.1) fragment28.2

ffi_value_literal fragment30 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[30] (fun k => InKey.stage 30 k) fragment29.1.1) fragment29.2
ffi_value_literal_eq fragment30 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[30] (fun k => InKey.stage 30 k) fragment29.1.1) fragment29.2

ffi_value_literal fragment31 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[31] (fun k => InKey.stage 31 k) fragment30.1.1) fragment30.2
ffi_value_literal_eq fragment31 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[31] (fun k => InKey.stage 31 k) fragment30.1.1) fragment30.2

end Host.Mlx.SimGraph.Tpl.Ordinary
