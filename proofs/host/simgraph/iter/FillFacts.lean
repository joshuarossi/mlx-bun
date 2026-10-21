import host.simgraph.iter.FillCert
import host.load.CacheCarriersCommand
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Mlx.SimGraph.Iter.Fill
open Host.Load Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph

/-! Concrete kernel facts of the FILL template's end state. -/

/-- The fed-back token node of the template, over the previous iteration's output. -/
theorem token_node : Gs tokenNode = some ⟨.reshape [.lit 1, .lit 1], [22538]⟩ := by decide +kernel

theorem token_input : insT .tokenIds = some tokenNode := by decide +kernel

/-- The template's next caches are carried by the expected graph's cache outputs. -/
theorem outputs_check : choice.outputs = Tpl.Fill.cacheOutputs.map (certifiedCachePair choice.cert) := by
  decide +kernel

end Host.Mlx.SimGraph.Iter.Fill
