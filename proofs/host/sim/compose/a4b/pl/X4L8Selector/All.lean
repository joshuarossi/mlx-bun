import host.sim.compose.a4b.pl.X4L8Selector.C0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.X4L8Selector
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

abbrev N : Nat := 128
kernel_rfl stepsEq : N = n0

/-- **The chain**, in 128 steps. -/
theorem all (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV (head [2834427]) T tk π.length ν → Good ν PRE_plx4_L8_selector.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrackV x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut0 [2834427] NB T tk cap nI π PRE_plx4_L8_selector.s0 PRE_plx4_L8_selector.S0)) (withMem Tr (indexedCut0 [2834427] NB T tk cap nI π PRE_plx4_L8_selector.s1 PRE_plx4_L8_selector.S1)) N :=
  ((c0 NB T tk cap nI π hcap hg Tr hT)).cast rfl rfl stepsEq

end Host.Ts.Sim.Compose.Post.PL.X4L8Selector
