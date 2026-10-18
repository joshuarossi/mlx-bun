import host.load.run.full.InputValues
import host.load.run.full.expected.Join
namespace Host.Load.Run.Full
open Host.Load.Extract Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

theorem initial_stage_layout (contents : Nat → Nat → Nat) :
    chainLayout (stageWeights (weights (headerValues contents))) initialHandles = Expected.stages := by rfl

theorem initial_head_layout (contents : Nat → Nat → Nat) :
    linLayout .affineRow (weights (headerValues contents)).head = Expected.head := by rfl

/-- The staged finite checker uses exactly the graph expected by the existing
mathematical step theorem for these loaded parameters and empty caches. -/
theorem initial_step_graph (contents : Nat → Nat → Nat) :
    stepGraphOf (weights (headerValues contents)) initialHandles 0 =
      (Expected.graph, Expected.tokenNode, Expected.cacheOutputs) := by
  change stepGraph (chainLayout (stageWeights (weights (headerValues contents))) initialHandles)
    (linLayout .affineRow (weights (headerValues contents)).head) 0 = _
  rw [initial_stage_layout, initial_head_layout]
  exact Expected.graph_original

end Host.Load.Run.Full
