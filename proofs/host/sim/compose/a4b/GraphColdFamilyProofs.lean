import host.sim.compose.a4b.GraphColdFamilyBuild
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Load.Run.Full.Expected
theorem hiddenG_natural {δ δ' : Type} (f : δ → δ') (L : Int → δ) (n : Nat) (nD n1D : δ) (ss : List StageLayout) :
    Natural f (hiddenG L n nD n1D ss) (hiddenG (fun i => f (L i)) n (f nD) (f n1D) ss) := by
  unfold hiddenG
  refine natural_bind (nat_embedG f id) fun _ => natural_bind (nat_chainG f n L nD n1D id 0 ss _) fun ⟨_, _⟩ => ?_
  exact natural_bind (nat_normG f InKey.finalNorm _) fun _ => natural_pure _

theorem hidden_chain {δ : Type} (I : PDim → δ) (o n p : Nat) (ss : List StageLayout) (x : Nat) :
    chainP hiddenOps I o n p ss x = chainG (fun i => I (.lit i)) o (I (.lit 0)) (I (.lit 1)) id p ss x := by
  induction ss generalizing p x with
  | nil => rfl
  | cons s ss ih =>
    change (stageG _ o _ _ s _ x >>= _) = (stageG _ o _ _ s _ x >>= _)
    congr 1
    funext r
    obtain ⟨y, c1, c2⟩ := r
    dsimp only
    rw [ih]

theorem hidden_forward {δ : Type} (I : PDim → δ) (ss : List StageLayout) :
    forwardP hiddenOps I 0 1 ss = hiddenG (fun i => I (.lit i)) 0 (I (.lit 0)) (I (.lit 1)) ss := by
  unfold forwardP hiddenG
  congr 1
  funext x
  rw [hidden_chain]
  rfl

end Host.Ts.Sim.Compose.ColdGraph
