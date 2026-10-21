import host.load.run.full.cached.expected2.Base
import host.simgraph.Command
namespace Host.Mlx.SimGraph.Tpl
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

/-! The decode-step templates' shared prefix: the embedding at symbolic dimensions.
The layout is the cached route's (`Expected2.stages`, `Expected2.head`: the loaded
weights with populated caches of capacity 256). -/

ffi_value_literal embedded : run (embedG (δ := SDim) (κ := InKey) id) []
ffi_value_literal_eq embedded : run (embedG (δ := SDim) (κ := InKey) id) []

end Host.Mlx.SimGraph.Tpl
