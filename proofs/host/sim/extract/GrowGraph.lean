import host.sim.extract.Grow
import host.simgraph.Grow

/-! # Native growth keeps the graph's nodes and kernels

The graph-level consequences of `NGrow`, apart from `host.sim.extract.Grow`, whose importers are the
simulation's and need no graph. -/

namespace Host.Mlx.Ffi
open Host.Ts

namespace NGrow
variable {x y : St}

/-- Resolved kernel names are kept. -/
theorem kernelName (h : NGrow x y) (Ks : Host.Mlx.FfiEval.KernelSources) (k : Nat) (name : List Char)
    (hk : Host.Mlx.FfiEval.kernelName? Ks x k = some name) : Host.Mlx.FfiEval.kernelName? Ks y k = some name := by
  unfold Host.Mlx.FfiEval.kernelName? at hk ⊢
  cases ho : x.obj? k with
  | none => rw [ho] at hk; cases hk
  | some o =>
    rw [ho] at hk
    cases o with
    | kernel nm sc hd a b =>
      rw [show y.obj? k = some (.kernel nm sc hd a b) from h.kernels k _ ho ⟨nm, sc, hd, a, b, rfl⟩]
      exact hk
    | _ => cases hk

theorem grows (h : NGrow x y) (Ks : Host.Mlx.FfiEval.KernelSources) : Host.Mlx.SimGraph.Grows Ks x y :=
  ⟨h.nodes, h.kernelName Ks⟩

end NGrow

end Host.Mlx.Ffi
