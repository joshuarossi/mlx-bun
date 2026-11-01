import host.simgraph.tpl.fam.VW83.Stages3
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.VW83
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment16 : run (F.layer id 0 124 16 stages[16] fragment15.1.1) fragment15.2
ffi_value_literal_eq fragment16 : run (F.layer id 0 124 16 stages[16] fragment15.1.1) fragment15.2

ffi_value_literal fragment17 : run (F.layer id 0 124 17 stages[17] fragment16.1.1) fragment16.2
ffi_value_literal_eq fragment17 : run (F.layer id 0 124 17 stages[17] fragment16.1.1) fragment16.2

ffi_value_literal fragment18 : run (F.layer id 0 124 18 stages[18] fragment17.1.1) fragment17.2
ffi_value_literal_eq fragment18 : run (F.layer id 0 124 18 stages[18] fragment17.1.1) fragment17.2

ffi_value_literal fragment19 : run (F.layer id 0 124 19 stages[19] fragment18.1.1) fragment18.2
ffi_value_literal_eq fragment19 : run (F.layer id 0 124 19 stages[19] fragment18.1.1) fragment18.2

end Host.Mlx.SimGraph.Tpl.Fam.VW83
