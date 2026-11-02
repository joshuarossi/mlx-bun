import host.sim.compose.a4b.pl.T2.C0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.T2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

abbrev N : Nat := 1534
kernel_rfl stepsEq : N = n0

/-- **The chain**, in 1534 steps. -/
theorem all (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV tail T tk π.length ν → Good ν PRE_pl_t2.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrackV x y → Tr x → Tr y) (hP : ∀ x y : SegInst FF, (indexedCut NB T tk cap nI π PRE_pl_t2.s0 PRE_pl_t2.S0).R x PRE_pl_t2.s0 ⟨PRE_pl_t2.S0.tab, []⟩ →
      (indexedCut NB T tk cap nI π PRE_pl_t2.s2 PRE_pl_t2.S2).R y PRE_pl_t2.s2 ⟨PRE_pl_t2.S2.tab, []⟩ → CSrv.Le x.C y.C → y.M.node = x.M.node →
      y.M.a 12504 = x.M.a 12504 → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_t2.s0 PRE_pl_t2.S0)) (withMem Tr (endCut NB T tk cap [2673435, PRE_pl_t2.cacheArray] PRE_pl_t2.s7 PRE_pl_t2.S7)) N :=
  ((c0 NB T tk cap nI π hcap hg Tr hT hP)).cast rfl rfl stepsEq

end Host.Ts.Sim.Compose.Post.PL.T2
