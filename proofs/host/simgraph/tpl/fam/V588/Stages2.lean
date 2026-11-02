import host.simgraph.tpl.fam.V588.Stages1
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.V588
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment8 : run (F.layer id 0 124 8 stages[8] fragment7.1.1) fragment7.2
ffi_value_literal_eq fragment8 : run (F.layer id 0 124 8 stages[8] fragment7.1.1) fragment7.2

ffi_value_literal fragment9 : run (F.layer id 0 124 9 stages[9] fragment8.1.1) fragment8.2
ffi_value_literal_eq fragment9 : run (F.layer id 0 124 9 stages[9] fragment8.1.1) fragment8.2

ffi_value_literal fragment10 : run (F.layer id 0 124 10 stages[10] fragment9.1.1) fragment9.2
ffi_value_literal_eq fragment10 : run (F.layer id 0 124 10 stages[10] fragment9.1.1) fragment9.2

ffi_value_literal fragment11 : run (F.layer id 0 124 11 stages[11] fragment10.1.1) fragment10.2
ffi_value_literal_eq fragment11 : run (F.layer id 0 124 11 stages[11] fragment10.1.1) fragment10.2

end Host.Mlx.SimGraph.Tpl.Fam.V588
