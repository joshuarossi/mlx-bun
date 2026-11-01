import host.simgraph.prompt.PromptBuild
namespace Host.Mlx.SimGraph
open Host.Mlx.FfiEval

/-! # Joining a row family's per-layer literals

A family's expected graph is too large for the kernel to build at once (each node appends to the whole graph). As the
decode templates do (`chainG_join`), each layer is a literal checked on its own (`ffi_value_literal_eq`), and these join
them to `familyGraph` without rebuilding a prefix. -/

theorem chainP_join {δ κ : Type} (R : RowOps κ) (I : PDim → δ) (o n p : Nat) (s : StageLayout) (ss : List StageLayout)
    (x y c1 c2 z : Nat) (cs : List (Nat × Nat)) (g g1 g2 : List (RNode δ κ))
    (hs : run (R.layer I o n p s x) g = ((y, c1, c2), g1))
    (hr : run (chainP R I o n (p + 1) ss y) g1 = ((z, cs), g2)) :
    run (chainP R I o n p (s :: ss) x) g = ((z, (c1, c2) :: cs), g2) := by
  change (match run (R.layer I o n p s x) g with
    | ((y, c1, c2), g1) => match run (chainP R I o n (p + 1) ss y) g1 with
      | ((z, cs), g2) => ((z, (c1, c2) :: cs), g2)) = _
  rw [hs]
  dsimp only
  rw [hr]

theorem chainP_nil {δ κ : Type} (R : RowOps κ) (I : PDim → δ) (o n p x : Nat) (g : List (RNode δ κ)) :
    run (chainP R I o n p [] x) g = ((x, []), g) := rfl

theorem familyGraph_join {δ κ : Type} (R : RowOps κ) (I : PDim → δ) (o n : Nat) (ss : List StageLayout)
    (x y r : Nat) (cs : List (Nat × Nat)) (g1 g2 g3 : List (RNode δ κ))
    (he : run (R.embed I) [] = (x, g1))
    (hc : run (chainP R I o n 0 ss x) g1 = ((y, cs), g2))
    (hf : run (R.final I y) g2 = (r, g3)) :
    familyGraph R I o n ss = (g3, r, cs) := by
  change (match run (R.embed I) [] with
    | (x, g1) => match run (chainP R I o n 0 ss x) g1 with
      | ((y, cs), g2) => match run (R.final I y) g2 with
        | (r, g3) => (g3, r, cs)) = _
  rw [he]
  dsimp only
  rw [hc]
  dsimp only
  rw [hf]

end Host.Mlx.SimGraph
