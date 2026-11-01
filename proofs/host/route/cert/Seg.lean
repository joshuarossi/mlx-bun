import host.simgraph.Command
namespace Host.Route.Cert
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph

/-! # A certificate's check of part of an expected graph -/

section
variable {δ κ : Type} [DecidableEq δ] [DecidableEq κ]

/-- Node `k`'s check, below `K`. -/
def headOk (K : Nat) (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat) (e : RNode δ κ) : Bool :=
  !(decide (k < K)) || nodeOkD G cert k e

/-- Node `k`'s check, from `K`. -/
def tailOk (K : Nat) (G : Nat → Option (RNode δ κ)) (cert : List Nat) (k : Nat) (e : RNode δ κ) : Bool :=
  !(decide (K ≤ k)) || nodeOkD G cert k e

end

end Host.Route.Cert
