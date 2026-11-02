import host.simgraph.tpl.fam.V586.Stages7
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.V586
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment32 : run (F.layer id 0 124 32 stages[32] fragment31.1.1) fragment31.2
ffi_value_literal_eq fragment32 : run (F.layer id 0 124 32 stages[32] fragment31.1.1) fragment31.2

ffi_value_literal fragment33 : run (F.layer id 0 124 33 stages[33] fragment32.1.1) fragment32.2
ffi_value_literal_eq fragment33 : run (F.layer id 0 124 33 stages[33] fragment32.1.1) fragment32.2

ffi_value_literal fragment34 : run (F.layer id 0 124 34 stages[34] fragment33.1.1) fragment33.2
ffi_value_literal_eq fragment34 : run (F.layer id 0 124 34 stages[34] fragment33.1.1) fragment33.2

ffi_value_literal fragment35 : run (F.layer id 0 124 35 stages[35] fragment34.1.1) fragment34.2
ffi_value_literal_eq fragment35 : run (F.layer id 0 124 35 stages[35] fragment34.1.1) fragment34.2

end Host.Mlx.SimGraph.Tpl.Fam.V586
