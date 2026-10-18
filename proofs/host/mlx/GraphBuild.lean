import host.mlx.FfiEval

namespace Host.Mlx.FfiEval

/-- A checked stage can be joined to the rest of the original chain without
reconstructing its emitted prefix during conversion. -/
theorem chainG_run_cons {δ κ : Type} (L : Int → δ) (n : Nat) (nD n1D : δ)
    (key : InKey → κ) (p : Nat) (s : StageLayout) (ss : List StageLayout) (x : Nat)
    (g : List (RNode δ κ)) :
    run (chainG L n nD n1D key p (s :: ss) x) g =
      let (r, g1) := run (stageG L n nD n1D s (fun k => key (.stage p k)) x) g
      let (r2, g2) := run (chainG L n nD n1D key (p + 1) ss r.1) g1
      ((r2.1, (r.2.1, r.2.2) :: r2.2), g2) := by
  rfl

theorem chainG_join {δ κ : Type} (L : Int → δ) (n : Nat) (nD n1D : δ)
    (key : InKey → κ) (p : Nat) (s : StageLayout) (ss : List StageLayout)
    (x y c1 c2 z : Nat) (cs : List (Nat × Nat)) (g g1 g2 : List (RNode δ κ))
    (hs : run (stageG L n nD n1D s (fun k => key (.stage p k)) x) g = ((y, c1, c2), g1))
    (hr : run (chainG L n nD n1D key (p + 1) ss y) g1 = ((z, cs), g2)) :
    run (chainG L n nD n1D key p (s :: ss) x) g = ((z, (c1, c2) :: cs), g2) := by
  rw [chainG_run_cons, hs]
  dsimp only
  rw [hr]

open Inference.Kernels

/-- The original post-chain part of `stepG`, separated only for checked joins. -/
def finishG {δ κ : Type} (L : Int → δ) (key : InKey → κ) (head : LinLayout)
    (y : Nat) (cs : List (Nat × Nat)) : Build δ κ (Nat × List (Nat × Nat)) := do
  let h ← normG (key .finalNorm) y
  let logits ← projectG L head (key ∘ .head) h
  let l ← emit (.reshape (D L [1, 248320])) [logits]
  let lse ← emit (.logsumexp 1 true) [l]
  let values ← emit (kern L chars!"normalized_argmax_partial" partialConfig 0) [l, lse]
  let indices ← emit (kern L chars!"normalized_argmax_partial" partialConfig 1) [l, lse]
  let tok ← emit (kern L chars!"normalized_argmax_finish" finishConfig 0) [values, indices]
  let r ← emit (.reshape (D L [1])) [tok]
  pure (r, cs)

theorem stepG_join {δ κ : Type} (L : Int → δ) (n : Nat) (nD n1D : δ)
    (key : InKey → κ) (stages : List StageLayout) (head : LinLayout)
    (x y : Nat) (cs : List (Nat × Nat)) (r : Nat × List (Nat × Nat))
    (g g1 g2 g3 : List (RNode δ κ))
    (he : run (embedG key) g = (x, g1))
    (hc : run (chainG L n nD n1D key 0 stages x) g1 = ((y, cs), g2))
    (hf : run (finishG L key head y cs) g2 = (r, g3)) :
    run (stepG L n nD n1D key stages head) g = (r, g3) := by
  change (let (x, g1) := run (embedG key) g
          let (r, g2) := run (chainG L n nD n1D key 0 stages x) g1
          run (finishG L key head r.1 r.2) g2) = (r, g3)
  rw [he]
  dsimp only
  rw [hc]
  exact hf

end Host.Mlx.FfiEval
