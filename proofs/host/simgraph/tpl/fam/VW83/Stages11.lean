import host.simgraph.tpl.fam.VW83.Stages10
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.VW83
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment44 : run (F.layer id 0 124 44 stages[44] fragment43.1.1) fragment43.2
ffi_value_literal_eq fragment44 : run (F.layer id 0 124 44 stages[44] fragment43.1.1) fragment43.2

ffi_value_literal fragment45 : run (F.layer id 0 124 45 stages[45] fragment44.1.1) fragment44.2
ffi_value_literal_eq fragment45 : run (F.layer id 0 124 45 stages[45] fragment44.1.1) fragment44.2

ffi_value_literal fragment46 : run (F.layer id 0 124 46 stages[46] fragment45.1.1) fragment45.2
ffi_value_literal_eq fragment46 : run (F.layer id 0 124 46 stages[46] fragment45.1.1) fragment45.2

ffi_value_literal fragment47 : run (F.layer id 0 124 47 stages[47] fragment46.1.1) fragment46.2
ffi_value_literal_eq fragment47 : run (F.layer id 0 124 47 stages[47] fragment46.1.1) fragment46.2

end Host.Mlx.SimGraph.Tpl.Fam.VW83
