import host.sim.compose.a4b.GraphColdFamilyProofs
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph

theorem hiddenG_join {δ : Type} (L : Int → δ) (n : Nat) (nD n1D : δ) (ss : List StageLayout)
    (x y : Nat) (cs : List (Nat × Nat)) (h : Nat) (g g1 g2 g3 : List (RNode δ InKey))
    (he : run (embedG id) g = (x,g1))
    (hc : run (chainG L n nD n1D id 0 ss x) g1 = ((y,cs),g2))
    (hn : run (normG InKey.finalNorm y) g2 = (h,g3)) :
    run (hiddenG L n nD n1D ss) g = ((h,cs),g3) := by
  change (let (x,g1) := run (embedG (δ := δ) (κ := InKey) id) g
          let (r,g2) := run (chainG L n nD n1D id 0 ss x) g1
          let (h,g3) := run (normG (δ := δ) InKey.finalNorm r.1) g2
          ((h,r.2),g3)) = _
  rw [he]
  dsimp only
  rw [hc]
  dsimp only
  rw [hn]

theorem hidden_familyGraph {δ : Type} (I : PDim → δ) (ss : List StageLayout) :
    familyGraph hiddenFamily.ops I 0 1 ss =
      let r := run (hiddenG (fun i => I (.lit i)) 0 (I (.lit 0)) (I (.lit 1)) ss) []
      (r.2,r.1) := by
  unfold familyGraph
  rw [show hiddenFamily.ops = hiddenOps from rfl, hidden_forward]
end Host.Ts.Sim.Compose.ColdGraph
