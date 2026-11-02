import host.simgraph.tpl.fam.V588.Stages8
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.V588
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment36 : run (F.layer id 0 124 36 stages[36] fragment35.1.1) fragment35.2
ffi_value_literal_eq fragment36 : run (F.layer id 0 124 36 stages[36] fragment35.1.1) fragment35.2

ffi_value_literal fragment37 : run (F.layer id 0 124 37 stages[37] fragment36.1.1) fragment36.2
ffi_value_literal_eq fragment37 : run (F.layer id 0 124 37 stages[37] fragment36.1.1) fragment36.2

ffi_value_literal fragment38 : run (F.layer id 0 124 38 stages[38] fragment37.1.1) fragment37.2
ffi_value_literal_eq fragment38 : run (F.layer id 0 124 38 stages[38] fragment37.1.1) fragment37.2

ffi_value_literal fragment39 : run (F.layer id 0 124 39 stages[39] fragment38.1.1) fragment38.2
ffi_value_literal_eq fragment39 : run (F.layer id 0 124 39 stages[39] fragment38.1.1) fragment38.2

end Host.Mlx.SimGraph.Tpl.Fam.V588
