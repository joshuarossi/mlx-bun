import host.simgraph.tpl.fam.VW83.Stages14
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.VW83
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment60 : run (F.layer id 0 124 60 stages[60] fragment59.1.1) fragment59.2
ffi_value_literal_eq fragment60 : run (F.layer id 0 124 60 stages[60] fragment59.1.1) fragment59.2

ffi_value_literal fragment61 : run (F.layer id 0 124 61 stages[61] fragment60.1.1) fragment60.2
ffi_value_literal_eq fragment61 : run (F.layer id 0 124 61 stages[61] fragment60.1.1) fragment60.2

ffi_value_literal fragment62 : run (F.layer id 0 124 62 stages[62] fragment61.1.1) fragment61.2
ffi_value_literal_eq fragment62 : run (F.layer id 0 124 62 stages[62] fragment61.1.1) fragment61.2

ffi_value_literal fragment63 : run (F.layer id 0 124 63 stages[63] fragment62.1.1) fragment62.2
ffi_value_literal_eq fragment63 : run (F.layer id 0 124 63 stages[63] fragment62.1.1) fragment62.2

end Host.Mlx.SimGraph.Tpl.Fam.VW83
