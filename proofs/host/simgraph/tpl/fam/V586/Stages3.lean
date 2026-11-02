import host.simgraph.tpl.fam.V586.Stages2
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.V586
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment12 : run (F.layer id 0 124 12 stages[12] fragment11.1.1) fragment11.2
ffi_value_literal_eq fragment12 : run (F.layer id 0 124 12 stages[12] fragment11.1.1) fragment11.2

ffi_value_literal fragment13 : run (F.layer id 0 124 13 stages[13] fragment12.1.1) fragment12.2
ffi_value_literal_eq fragment13 : run (F.layer id 0 124 13 stages[13] fragment12.1.1) fragment12.2

ffi_value_literal fragment14 : run (F.layer id 0 124 14 stages[14] fragment13.1.1) fragment13.2
ffi_value_literal_eq fragment14 : run (F.layer id 0 124 14 stages[14] fragment13.1.1) fragment13.2

ffi_value_literal fragment15 : run (F.layer id 0 124 15 stages[15] fragment14.1.1) fragment14.2
ffi_value_literal_eq fragment15 : run (F.layer id 0 124 15 stages[15] fragment14.1.1) fragment14.2

end Host.Mlx.SimGraph.Tpl.Fam.V586
