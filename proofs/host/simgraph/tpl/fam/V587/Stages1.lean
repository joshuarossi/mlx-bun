import host.simgraph.tpl.fam.V587.Stages0
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.V587
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment4 : run (F.layer id 0 124 4 stages[4] fragment3.1.1) fragment3.2
ffi_value_literal_eq fragment4 : run (F.layer id 0 124 4 stages[4] fragment3.1.1) fragment3.2

ffi_value_literal fragment5 : run (F.layer id 0 124 5 stages[5] fragment4.1.1) fragment4.2
ffi_value_literal_eq fragment5 : run (F.layer id 0 124 5 stages[5] fragment4.1.1) fragment4.2

ffi_value_literal fragment6 : run (F.layer id 0 124 6 stages[6] fragment5.1.1) fragment5.2
ffi_value_literal_eq fragment6 : run (F.layer id 0 124 6 stages[6] fragment5.1.1) fragment5.2

ffi_value_literal fragment7 : run (F.layer id 0 124 7 stages[7] fragment6.1.1) fragment6.2
ffi_value_literal_eq fragment7 : run (F.layer id 0 124 7 stages[7] fragment6.1.1) fragment6.2

end Host.Mlx.SimGraph.Tpl.Fam.V587
