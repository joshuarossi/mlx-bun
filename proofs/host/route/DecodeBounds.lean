import host.sim.LoopFrames
import host.sim.Rel
set_option autoImplicit false
namespace Host.Route
open Host.Ts.Sim

/-- The six decode traces fit the machine counter ranges for every supported budget. -/
theorem decode_counter_bounds {T h n : Nat} {B : LoopBase}
    (hT : T ≤ 262144) (hh : h ≤ 131072) (hn : n ≤ 2 ^ 40)
    (hD : B.D ≤ 2 ^ 60) (hH : B.H ≤ 2 ^ 45) (hN : B.N ≤ 2 ^ 61) :
    T * 151312 + B.D < bound ∧
    h + T * 3867 + B.H + (131072 - h) < 2 ^ 46 ∧
    n + T * 4882 + B.N + (2 ^ 40 - n) < 2 ^ 62 := by
  unfold bound
  omega

end Host.Route
