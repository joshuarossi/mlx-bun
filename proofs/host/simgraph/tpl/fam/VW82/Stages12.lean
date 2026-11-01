import host.simgraph.tpl.fam.VW82.Stages11
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.VW82
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment48 : run (F.layer id 0 124 48 stages[48] fragment47.1.1) fragment47.2
ffi_value_literal_eq fragment48 : run (F.layer id 0 124 48 stages[48] fragment47.1.1) fragment47.2

ffi_value_literal fragment49 : run (F.layer id 0 124 49 stages[49] fragment48.1.1) fragment48.2
ffi_value_literal_eq fragment49 : run (F.layer id 0 124 49 stages[49] fragment48.1.1) fragment48.2

ffi_value_literal fragment50 : run (F.layer id 0 124 50 stages[50] fragment49.1.1) fragment49.2
ffi_value_literal_eq fragment50 : run (F.layer id 0 124 50 stages[50] fragment49.1.1) fragment49.2

ffi_value_literal fragment51 : run (F.layer id 0 124 51 stages[51] fragment50.1.1) fragment50.2
ffi_value_literal_eq fragment51 : run (F.layer id 0 124 51 stages[51] fragment50.1.1) fragment50.2

end Host.Mlx.SimGraph.Tpl.Fam.VW82
