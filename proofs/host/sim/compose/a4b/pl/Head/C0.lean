import host.sim.compose.PostChain
import host.sim.template.a4pre_pl_head.Good
import host.sim.template.a4pre_pl_head.K0
import host.sim.template.a4pre_pl_head.Accept
import host.sim.template.a4pre_pl_head.H0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.Head
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl top1 : noRetBlock PRE_pl_head.s1 = true
kernel_rfl br0_1 : bridgeOf PRE_pl_head.s1.ffi = bridgeOf PRE_pl_head.s0.ffi
kernel_rfl cnt0_1 : countersOkB PRE_pl_head.s0 PRE_pl_head.s1 = true

abbrev n0 : Nat := ((nth? PRE_pl_head.ks 0).getD 0)

theorem c0 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV head T tk π.length ν → Good ν PRE_pl_head.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrackV x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut0 NB T tk cap nI π PRE_pl_head.s0 PRE_pl_head.S0)) (withMem Tr (indexedCut0 NB T tk cap nI π PRE_pl_head.s1 PRE_pl_head.S1)) n0 :=
  (glueM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeOk0 NB T tk cap hcap) PRE_pl_head.accepted0 PRE_pl_head.run0 top1 hg (Host.Load.Boot.replay_active _) br0_1 cnt0_1 hT rfl)

end Host.Ts.Sim.Compose.Post.PL.Head
