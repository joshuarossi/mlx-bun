import host.simgraph.tpl.Common
namespace Host.Mlx.SimGraph.Tpl.Ordinary
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
open Host.Mlx.SimGraph.Tpl (embedded)

ffi_value_literal fragment0 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[0] (fun k => InKey.stage 0 k) embedded.1) embedded.2
ffi_value_literal_eq fragment0 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[0] (fun k => InKey.stage 0 k) embedded.1) embedded.2

ffi_value_literal fragment1 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[1] (fun k => InKey.stage 1 k) fragment0.1.1) fragment0.2
ffi_value_literal_eq fragment1 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[1] (fun k => InKey.stage 1 k) fragment0.1.1) fragment0.2

ffi_value_literal fragment2 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[2] (fun k => InKey.stage 2 k) fragment1.1.1) fragment1.2
ffi_value_literal_eq fragment2 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[2] (fun k => InKey.stage 2 k) fragment1.1.1) fragment1.2

ffi_value_literal fragment3 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[3] (fun k => InKey.stage 3 k) fragment2.1.1) fragment2.2
ffi_value_literal_eq fragment3 : run (stageG SDim.lit 1 SDim.pos SDim.pos1 stages[3] (fun k => InKey.stage 3 k) fragment2.1.1) fragment2.2

end Host.Mlx.SimGraph.Tpl.Ordinary
