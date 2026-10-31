import host.sim.footprint.Core
import host.load.LayerLift

namespace Host.Mlx.Ffi.Footprint
open Host.Ts
open FullKeep (AllX)
open Host.Ts.Sim

section
variable {H I : Nat → Prop} {s₀ s : St}

/-- Ordinary inference may add a node and writes only the decoded output handle. -/
theorem opOut_w (w : Writes H I s₀ s) (o : Arg) (p : Prim) (ins : List Nat)
    (hs : ∀ b off slot, slotOf o = some (b, off, slot) → slot = 0 ∨ H slot) :
    AllX (Result H I s₀ id) (opOut s o p ins) := by
  unfold opOut
  repeat' (first
    | with_reducible refine AllX.bind' (NativeLawful.infer_l _ _) fun _ => ?_
    | with_reducible exact result_stuck
    | with_reducible refine result_okW ?_
    | with_reducible exact w
    | with_reducible refine Writes.setArr ?_ _ _ (by apply hs; assumption)
    | with_reducible refine Writes.addNode ?_ _
    | split)

theorem leafOut_w (w : Writes H I s₀ s) (o : Arg) (p : Prim) (sh : List Dim) (dt : Nat)
    (hs : ∀ b off slot, slotOf o = some (b, off, slot) → slot = 0 ∨ H slot) :
    AllX (Result H I s₀ id) (leafOut s o p sh dt) := by
  unfold leafOut
  split
  · exact result_okW ((w.addNode _).setArr _ _ (hs _ _ _ (by assumption)))
  · exact result_stuck

/-- The fallback for symbolic reshape and convolution has the same write support. -/
theorem opOutSym_w (w : Writes H I s₀ s) (o : Arg) (p : Prim) (ins : List Nat)
    (hs : ∀ b off slot, slotOf o = some (b, off, slot) → slot = 0 ∨ H slot) :
    AllX (Result H I s₀ id) (SymShape.opOutSym s o p ins) := by
  unfold SymShape.opOutSym
  repeat' (first
    | with_reducible refine AllX.bind' (Host.Load.LayerLift.inferSym_l _ _) fun _ => ?_
    | with_reducible exact result_stuck
    | with_reducible refine result_okW ?_
    | with_reducible exact w
    | with_reducible refine Writes.setArr ?_ _ _ (by apply hs; assumption)
    | with_reducible refine Writes.addNode ?_ _
    | split)

end

/-- The symbolic-shape fallback has no other native writes. -/
theorem symShapeCall_w (s : St) (name : Name) (args : List Arg) :
    AllX (Result (Output args) (fun _ => False) s id) (SymShape.symShapeCall s name args) := by
  have w : Writes (Output args) (fun _ => False) s s := Writes.refl s
  unfold SymShape.symShapeCall
  repeat' (first
    | with_reducible refine opOutSym_w w _ _ _ ?_
    | (intro b off slot he
       rcases slot_support he with hz | hp
       · exact Or.inl hz
       · exact Or.inr (output_cons _ _ _ hp))
    | with_reducible refine AllX.bind' (NativeLawful.dProd_l _) fun _ => ?_
    | with_reducible refine AllX.cond _ ?_ ?_
    | with_reducible exact result_stuck
    | with_reducible exact result_ok w
    | split)

end Host.Mlx.Ffi.Footprint
