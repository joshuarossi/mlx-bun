import host.simgraph.tpl.fam.V4.Stages4
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.V4
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment20 : run (F.layer id 0 124 20 stages[20] fragment19.1.1) fragment19.2
ffi_value_literal_eq fragment20 : run (F.layer id 0 124 20 stages[20] fragment19.1.1) fragment19.2

ffi_value_literal fragment21 : run (F.layer id 0 124 21 stages[21] fragment20.1.1) fragment20.2
ffi_value_literal_eq fragment21 : run (F.layer id 0 124 21 stages[21] fragment20.1.1) fragment20.2

ffi_value_literal fragment22 : run (F.layer id 0 124 22 stages[22] fragment21.1.1) fragment21.2
ffi_value_literal_eq fragment22 : run (F.layer id 0 124 22 stages[22] fragment21.1.1) fragment21.2

ffi_value_literal fragment23 : run (F.layer id 0 124 23 stages[23] fragment22.1.1) fragment22.2
ffi_value_literal_eq fragment23 : run (F.layer id 0 124 23 stages[23] fragment22.1.1) fragment22.2

end Host.Mlx.SimGraph.Tpl.Fam.V4
