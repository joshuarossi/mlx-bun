import host.sim.compose.a4b.pl.Ta.C0
import host.sim.compose.a4b.pl.Ta.C1
import host.sim.compose.a4b.pl.Ta.C2
import host.sim.compose.a4b.pl.Ta.C3
import host.sim.compose.a4b.pl.Ta.C4
import host.sim.compose.a4b.pl.Ta.C5
import host.sim.compose.a4b.pl.Ta.C6
import host.sim.compose.a4b.pl.Ta.C7
import host.sim.compose.a4b.pl.Ta.C8
import host.sim.compose.a4b.pl.Ta.C9
import host.sim.compose.a4b.pl.Ta.C10
import host.sim.compose.a4b.pl.Ta.C11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.Ta
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

abbrev N : Nat := 1493502
kernel_rfl stepsEq : N = (((((((((((n0 + n1) + n2) + n3) + n4) + n5) + n6) + n7) + n8) + n9) + n10) + n11)

/-- **The chain**, in 1493502 steps. -/
theorem all (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_ta.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) (hP : ∀ x y : SegInst FF, (indexedCut NB T tk cap nI π PRE_pl_ta.s0 PRE_pl_ta.S0).R x PRE_pl_ta.s0 ⟨PRE_pl_ta.S0.tab, []⟩ →
      (indexedCut NB T tk cap nI π PRE_pl_ta.s6 PRE_pl_ta.S6).R y PRE_pl_ta.s6 ⟨PRE_pl_ta.S6.tab, []⟩ → CSrv.Le x.C y.C → y.M.node = x.M.node →
      y.M.a 12504 = x.M.a 12504 → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_ta.s0 PRE_pl_ta.S0)) (withMem Tr (endCut NB T tk cap [2673435, PRE_pl_ta.cacheArray] PRE_pl_ta.s896 PRE_pl_ta.S896)) N :=
  (((((((((((((c0 NB T tk cap nI π hcap hg Tr hT hP)).trans (c1 NB T tk cap nI π hcap hg Tr hT)).trans (c2 NB T tk cap nI π hcap hg Tr hT)).trans (c3 NB T tk cap nI π hcap hg Tr hT)).trans (c4 NB T tk cap nI π hcap hg Tr hT)).trans (c5 NB T tk cap nI π hcap hg Tr hT)).trans (c6 NB T tk cap nI π hcap hg Tr hT)).trans (c7 NB T tk cap nI π hcap hg Tr hT)).trans (c8 NB T tk cap nI π hcap hg Tr hT)).trans (c9 NB T tk cap nI π hcap hg Tr hT)).trans (c10 NB T tk cap nI π hcap hg Tr hT)).trans (c11 NB T tk cap nI π hcap hg Tr hT)).cast rfl rfl stepsEq

end Host.Ts.Sim.Compose.Post.PL.Ta
