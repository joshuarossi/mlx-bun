import host.sim.BigFreeImage
namespace Host.Ts.Sim

/-! # Reassigning fresh handle images at a restart

`M.rebig a b d` sends the bigints in `[a, b)` (the template's fresh handles) to
`d + (i - a)` (the target's next handles) and keeps `M.big` elsewhere. -/

def Map.rebig (M : Map) (a b d : Nat) : Map :=
  { M with big := fun i => if (a : Int) ≤ i ∧ i < b then i - a + d else M.big i }

theorem Map.rebig_eq (M : Map) (a b d : Nat) :
    M.rebig a b d = M.withBig (fun i => if (a : Int) ≤ i ∧ i < b then i - a + d else M.big i) := rfl

end Host.Ts.Sim
