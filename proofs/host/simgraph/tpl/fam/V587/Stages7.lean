import host.simgraph.tpl.fam.V587.Stages6
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.V587
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment28 : run (F.layer id 0 124 28 stages[28] fragment27.1.1) fragment27.2
ffi_value_literal_eq fragment28 : run (F.layer id 0 124 28 stages[28] fragment27.1.1) fragment27.2

ffi_value_literal fragment29 : run (F.layer id 0 124 29 stages[29] fragment28.1.1) fragment28.2
ffi_value_literal_eq fragment29 : run (F.layer id 0 124 29 stages[29] fragment28.1.1) fragment28.2

ffi_value_literal fragment30 : run (F.layer id 0 124 30 stages[30] fragment29.1.1) fragment29.2
ffi_value_literal_eq fragment30 : run (F.layer id 0 124 30 stages[30] fragment29.1.1) fragment29.2

ffi_value_literal fragment31 : run (F.layer id 0 124 31 stages[31] fragment30.1.1) fragment30.2
ffi_value_literal_eq fragment31 : run (F.layer id 0 124 31 stages[31] fragment30.1.1) fragment30.2

end Host.Mlx.SimGraph.Tpl.Fam.V587
