import host.sim.compose.a4b.pl.T2E.C0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.T2E
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

abbrev N : Nat := 1358
kernel_rfl stepsEq : N = n0

/-- **The chain**, in 1358 steps. -/
theorem all (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_t2_eos.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_t2_eos.s0 PRE_pl_t2_eos.S0)) (withMem Tr (endCut NB T tk cap [2673435, PRE_pl_t2_eos.cacheArray] PRE_pl_t2_eos.s7 PRE_pl_t2_eos.S7)) N :=
  ((c0 NB T tk cap nI π hcap hg Tr hT)).cast rfl rfl stepsEq

end Host.Ts.Sim.Compose.Post.PL.T2E
