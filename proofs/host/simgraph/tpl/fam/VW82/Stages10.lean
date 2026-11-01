import host.simgraph.tpl.fam.VW82.Stages9
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.VW82
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment40 : run (F.layer id 0 124 40 stages[40] fragment39.1.1) fragment39.2
ffi_value_literal_eq fragment40 : run (F.layer id 0 124 40 stages[40] fragment39.1.1) fragment39.2

ffi_value_literal fragment41 : run (F.layer id 0 124 41 stages[41] fragment40.1.1) fragment40.2
ffi_value_literal_eq fragment41 : run (F.layer id 0 124 41 stages[41] fragment40.1.1) fragment40.2

ffi_value_literal fragment42 : run (F.layer id 0 124 42 stages[42] fragment41.1.1) fragment41.2
ffi_value_literal_eq fragment42 : run (F.layer id 0 124 42 stages[42] fragment41.1.1) fragment41.2

ffi_value_literal fragment43 : run (F.layer id 0 124 43 stages[43] fragment42.1.1) fragment42.2
ffi_value_literal_eq fragment43 : run (F.layer id 0 124 43 stages[43] fragment42.1.1) fragment42.2

end Host.Mlx.SimGraph.Tpl.Fam.VW82
