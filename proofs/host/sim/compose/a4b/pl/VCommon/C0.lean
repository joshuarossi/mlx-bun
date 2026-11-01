import host.sim.compose.PostChain
import host.sim.template.a4pre_plvw_common.Good
import host.sim.template.a4pre_plvw_common.K0
import host.sim.template.a4pre_plvw_common.Accept
import host.sim.template.a4pre_plvw_common.Size0
import host.sim.template.a4pre_plvw_common.H0
import host.sim.template.a4pre_plvw_common.K3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.VCommon
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl live1 : isHalt PRE_plvw_common.s1.ctl = false
kernel_rfl br0_2 : bridgeOf PRE_plvw_common.s2.ffi = bridgeOf PRE_plvw_common.s0.ffi
kernel_rfl cnt0_2 : countersOkB PRE_plvw_common.s0 PRE_plvw_common.s2 = true
kernel_rfl oa2 : PRE_plvw_common.S2.oracle = List.drop (PRE_plvw_common.S0.oracle.length - PRE_plvw_common.S2.oracle.length) PRE_plvw_common.S0.oracle
kernel_rfl cnt2_3 : countersOkB PRE_plvw_common.s2 PRE_plvw_common.s3 = true
kernel_rfl oa3 : PRE_plvw_common.S3.oracle = List.drop (PRE_plvw_common.S0.oracle.length - PRE_plvw_common.S3.oracle.length) PRE_plvw_common.S0.oracle
kernel_rfl top4 : noRetBlock PRE_plvw_common.s4 = true
kernel_rfl br3_4 : bridgeOf PRE_plvw_common.s4.ffi = bridgeOf PRE_plvw_common.s3.ffi
kernel_rfl cnt3_4 : countersOkB PRE_plvw_common.s3 PRE_plvw_common.s4 = true

abbrev n0 : Nat := (((((nth? PRE_plvw_common.ks 0).getD 0) + 1) + 3) + ((nth? PRE_plvw_common.ks 3).getD 0))

theorem c0 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_plvw_common.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrackV x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_plvw_common.s0 PRE_plvw_common.S0)) (withMem Tr (indexedCut NB T tk cap nI π PRE_plvw_common.s4 PRE_plvw_common.S4)) n0 :=
  (((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_plvw_common.accepted0 PRE_plvw_common.run0 PRE_plvw_common.accepted1 live1 PRE_plvw_common.b0.step PRE_plvw_common.b0.top hg (Host.Load.Boot.replay_active _) br0_2 cnt0_2 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_plvw_common.b0.parts PRE_plvw_common.b0.args_ok PRE_plvw_common.b0.sym PRE_plvw_common.b0.mlx PRE_plvw_common.b0.pay (by decide) PRE_plvw_common.b0.decode PRE_plvw_common.b0.pre PRE_plvw_common.b0.runS (fun ν h => by rw [oa2]; exact good_drop _ (hg ν h)) PRE_plvw_common.b0.inactive PRE_plvw_common.b0.bridge cnt2_3 hT)).trans (glueM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_plvw_common.accepted3 PRE_plvw_common.run3 top4 (fun ν h => by rw [oa3]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br3_4 cnt3_4 hT rfl)

end Host.Ts.Sim.Compose.Post.PL.VCommon
