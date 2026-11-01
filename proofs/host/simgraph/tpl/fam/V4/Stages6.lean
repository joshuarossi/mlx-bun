import host.simgraph.tpl.fam.V4.Stages5
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.V4
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

ffi_value_literal fragment24 : run (F.layer id 0 124 24 stages[24] fragment23.1.1) fragment23.2
ffi_value_literal_eq fragment24 : run (F.layer id 0 124 24 stages[24] fragment23.1.1) fragment23.2

ffi_value_literal fragment25 : run (F.layer id 0 124 25 stages[25] fragment24.1.1) fragment24.2
ffi_value_literal_eq fragment25 : run (F.layer id 0 124 25 stages[25] fragment24.1.1) fragment24.2

ffi_value_literal fragment26 : run (F.layer id 0 124 26 stages[26] fragment25.1.1) fragment25.2
ffi_value_literal_eq fragment26 : run (F.layer id 0 124 26 stages[26] fragment25.1.1) fragment25.2

ffi_value_literal fragment27 : run (F.layer id 0 124 27 stages[27] fragment26.1.1) fragment26.2
ffi_value_literal_eq fragment27 : run (F.layer id 0 124 27 stages[27] fragment26.1.1) fragment26.2

end Host.Mlx.SimGraph.Tpl.Fam.V4
