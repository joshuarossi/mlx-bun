import host.load.run.full.CachedLayout
import host.load.run.full.cached.expected2.Base
import host.simgraph.Layout
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Mlx.SimGraph.Mach
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval

/-- Populated cache shapes determine the decode layout independently of weight bytes. -/
theorem decode_layout (bytes : Nat → Nat → Nat) :
    chainLayout (stageWeights (weights (headerValues bytes))) (populatedLayoutHandles 256) =
      Host.Load.Run.Full.Cached.Expected2.stages := by rfl

theorem decode_head_layout (bytes : Nat → Nat → Nat) :
    linLayout .affineRow (weights (headerValues bytes)).head =
      Host.Load.Run.Full.Cached.Expected2.head := by rfl

theorem caps_populated (c : Nat) :
    ∀ ws : List StageWeights, CapsFor c ws (populatedHandlesFor ws c)
  | [] => .nil
  | .delta _ :: ws => .cons trivial (caps_populated c ws)
  | .attention _ :: ws => .cons ⟨rfl, rfl⟩ (caps_populated c ws)

theorem decode_layout_caps (bytes : Nat → Nat → Nat) :
    CapsFor 256 (stageWeights (weights (headerValues bytes))) (populatedLayoutHandles 256) := by
  rw [← populatedHandlesFor_loaded bytes 256]
  exact caps_populated 256 _

end Host.Mlx.SimGraph.Mach
