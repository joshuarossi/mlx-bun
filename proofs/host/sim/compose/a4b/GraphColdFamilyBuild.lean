import host.sim.compose.a4b.GraphColdFamilyCore
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Load.Run.Full.Expected
def hiddenG {δ : Type} (L : Int → δ) (n : Nat) (nD n1D : δ) (ss : List StageLayout) : Build δ InKey (Nat × List (Nat × Nat)) := do
  let x ← embedG id
  let (y, cs) ← chainG L n nD n1D id 0 ss x
  let h ← normG InKey.finalNorm y
  pure (h, cs)

end Host.Ts.Sim.Compose.ColdGraph
