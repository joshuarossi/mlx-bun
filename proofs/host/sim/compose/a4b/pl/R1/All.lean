import host.sim.compose.a4b.pl.R1.C0
import host.sim.compose.a4b.pl.R1.C1
import host.sim.compose.a4b.pl.R1.C2
import host.sim.compose.a4b.pl.R1.C3
import host.sim.compose.a4b.pl.R1.C4
import host.sim.compose.a4b.pl.R1.C5
import host.sim.compose.a4b.pl.R1.C6
import host.sim.compose.a4b.pl.R1.C7
import host.sim.compose.a4b.pl.R1.C8
import host.sim.compose.a4b.pl.R1.C9
import host.sim.compose.a4b.pl.R1.C10
import host.sim.compose.a4b.pl.R1.C11
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.R1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

abbrev N : Nat := 1491519
kernel_rfl stepsEq : N = (((((((((((n0 + n1) + n2) + n3) + n4) + n5) + n6) + n7) + n8) + n9) + n10) + n11)

/-- **The chain**, in 1491519 steps. -/
theorem all (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_r1.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s0 PRE_pl_r1.S0)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s890 PRE_pl_r1.S890)) N :=
  (((((((((((((c0 NB T tk cap nI π hcap hg Tr hT)).trans (c1 NB T tk cap nI π hcap hg Tr hT)).trans (c2 NB T tk cap nI π hcap hg Tr hT)).trans (c3 NB T tk cap nI π hcap hg Tr hT)).trans (c4 NB T tk cap nI π hcap hg Tr hT)).trans (c5 NB T tk cap nI π hcap hg Tr hT)).trans (c6 NB T tk cap nI π hcap hg Tr hT)).trans (c7 NB T tk cap nI π hcap hg Tr hT)).trans (c8 NB T tk cap nI π hcap hg Tr hT)).trans (c9 NB T tk cap nI π hcap hg Tr hT)).trans (c10 NB T tk cap nI π hcap hg Tr hT)).trans (c11 NB T tk cap nI π hcap hg Tr hT)).cast rfl rfl stepsEq

end Host.Ts.Sim.Compose.Post.PL.R1
