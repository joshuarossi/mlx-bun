import host.simgraph.prompt.ChooseFamily
import host.simgraph.tpl.FamJoin
import host.load.run.full.expected.Base
import host.simgraph.ref.Steps
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Tpl.Fam.VW33
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Expected (stages)

/-- The family. -/
def F : RowOps SimGraph.PKey := (vw Ref.refRows 3 ⟨8, 3⟩).ops

ffi_value_literal embedded : run (F.embed (δ := PDim) id) []
ffi_value_literal_eq embedded : run (F.embed (δ := PDim) id) []

ffi_value_literal fragment0 : run (F.layer id 0 124 0 stages[0] embedded.1) embedded.2
ffi_value_literal_eq fragment0 : run (F.layer id 0 124 0 stages[0] embedded.1) embedded.2

ffi_value_literal fragment1 : run (F.layer id 0 124 1 stages[1] fragment0.1.1) fragment0.2
ffi_value_literal_eq fragment1 : run (F.layer id 0 124 1 stages[1] fragment0.1.1) fragment0.2

ffi_value_literal fragment2 : run (F.layer id 0 124 2 stages[2] fragment1.1.1) fragment1.2
ffi_value_literal_eq fragment2 : run (F.layer id 0 124 2 stages[2] fragment1.1.1) fragment1.2

ffi_value_literal fragment3 : run (F.layer id 0 124 3 stages[3] fragment2.1.1) fragment2.2
ffi_value_literal_eq fragment3 : run (F.layer id 0 124 3 stages[3] fragment2.1.1) fragment2.2

end Host.Mlx.SimGraph.Tpl.Fam.VW33
