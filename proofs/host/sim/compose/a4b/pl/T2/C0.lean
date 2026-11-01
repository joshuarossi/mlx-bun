import host.sim.compose.PostPath
import host.sim.template.a4pre_pl_t2.Good
import host.sim.template.a4pre_pl_t2.K0
import host.sim.template.a4pre_pl_t2.Accept
import host.sim.template.a4pre_pl_t2.Len0
import host.sim.template.a4pre_pl_t2.H0
import host.sim.template.a4pre_pl_t2.K3
import host.sim.template.a4pre_pl_t2.Len1
import host.sim.template.a4pre_pl_t2.Tail
import host.sim.template.a4pre_pl_t2.TailSteps
import host.sim.template.a4pre_pl_t2.TailRest
import host.sim.template.a4pre_pl_t2.Endpoint
import host.sim.template.a4pre_pl_t2.SpreadData
import host.sim.template.BootEq
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.T2
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl live1 : isHalt PRE_pl_t2.s1.ctl = false
kernel_rfl br0_2 : bridgeOf PRE_pl_t2.s2.ffi = bridgeOf PRE_pl_t2.s0.ffi
kernel_rfl cnt0_2 : countersOkB PRE_pl_t2.s0 PRE_pl_t2.s2 = true
kernel_rfl oa2 : PRE_pl_t2.S2.oracle = List.drop (PRE_pl_t2.S0.oracle.length - PRE_pl_t2.S2.oracle.length) PRE_pl_t2.S0.oracle
kernel_rfl lst2 : PRE_pl_t2.s2.stack = .e (.member kLength false) :: PRE_pl_t2.s2.stack.tail
kernel_rfl cnt2_3 : countersOkB PRE_pl_t2.s2 PRE_pl_t2.s3 = true
kernel_rfl oa3 : PRE_pl_t2.S3.oracle = List.drop (PRE_pl_t2.S0.oracle.length - PRE_pl_t2.S3.oracle.length) PRE_pl_t2.S0.oracle
kernel_rfl live4 : isHalt PRE_pl_t2.s4.ctl = false
kernel_rfl br3_5 : bridgeOf PRE_pl_t2.s5.ffi = bridgeOf PRE_pl_t2.s3.ffi
kernel_rfl cnt3_5 : countersOkB PRE_pl_t2.s3 PRE_pl_t2.s5 = true
kernel_rfl oa5 : PRE_pl_t2.S5.oracle = List.drop (PRE_pl_t2.S0.oracle.length - PRE_pl_t2.S5.oracle.length) PRE_pl_t2.S0.oracle
kernel_rfl lst5 : PRE_pl_t2.s5.stack = .e (.member kLength false) :: PRE_pl_t2.s5.stack.tail
kernel_rfl cnt5_6 : countersOkB PRE_pl_t2.s5 PRE_pl_t2.s6 = true
kernel_rfl oa6 : PRE_pl_t2.S6.oracle = List.drop (PRE_pl_t2.S0.oracle.length - PRE_pl_t2.S6.oracle.length) PRE_pl_t2.S0.oracle
boot_rfl accTail from PRE_pl_t2.s6 to PRE_pl_t2.s6 : PostOk.ok PRE_pl_t2.s6 PRE_pl_t2.S6 = true
kernel_rfl liveSp : isHalt PRE_pl_t2.spPre.ctl = false
kernel_rfl topSp : noRetBlock PRE_pl_t2.spOpen = true
kernel_rfl brSp : bridgeOf PRE_pl_t2.spOpen.ffi = bridgeOf PRE_pl_t2.s6.ffi
kernel_rfl cntSp : countersOkB PRE_pl_t2.s6 PRE_pl_t2.spOpen = true
kernel_rfl wFwd : wideP 2673435 = none
kernel_rfl openNoOr : PRE_pl_t2.spOpenSrv.oracle = []
kernel_rfl cntClose : countersOkB PRE_pl_t2.spOpen PRE_pl_t2.spAfter = true
kernel_rfl proto : Present PRE_pl_t2.spClose aArrayProto
theorem afterInactive : (bridgeOf PRE_pl_t2.spAfter.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl topEnd : noRetBlock PRE_pl_t2.s7 = true
kernel_rfl brEnd : bridgeOf PRE_pl_t2.s7.ffi = bridgeOf PRE_pl_t2.spAfter.ffi
kernel_rfl cntEnd : countersOkB PRE_pl_t2.spAfter PRE_pl_t2.s7 = true

abbrev n0 : Nat := (((((((((nth? PRE_pl_t2.ks 0).getD 0) + 1) + 1) + (((nth? PRE_pl_t2.ks 3).getD 0) + 1)) + 1) + (32 + 1)) + 3) + PRE_pl_t2.restFuel)

theorem c0 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_t2.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_t2.s0 PRE_pl_t2.S0)) (withMem Tr (endCut NB T tk cap [2673435, PRE_pl_t2.cacheArray] PRE_pl_t2.s7 PRE_pl_t2.S7)) n0 :=
  (((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeOk NB T tk cap hcap) PRE_pl_t2.accepted0 PRE_pl_t2.run0 PRE_pl_t2.accepted1 live1 PRE_pl_t2.b0.enter PRE_pl_t2.b0.top hg (Host.Load.Boot.replay_active _) br0_2 cnt0_2 hT rfl)).trans (lenM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_t2.b0.ctl lst2 PRE_pl_t2.b0.objGet PRE_pl_t2.b0.kind PRE_pl_t2.b0.patch (fun ν h => by rw [oa2]; exact good_drop _ (hg ν h)) PRE_pl_t2.b0.inactive PRE_pl_t2.b0.bridge cnt2_3 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeOk NB T tk cap hcap) PRE_pl_t2.accepted3 PRE_pl_t2.run3 PRE_pl_t2.accepted4 live4 PRE_pl_t2.b1.enter PRE_pl_t2.b1.top (fun ν h => by rw [oa3]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br3_5 cnt3_5 hT rfl)).trans (lenM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_t2.b1.ctl lst5 PRE_pl_t2.b1.objGet PRE_pl_t2.b1.kind PRE_pl_t2.b1.patch (fun ν h => by rw [oa5]; exact good_drop _ (hg ν h)) PRE_pl_t2.b1.inactive PRE_pl_t2.b1.bridge cnt5_6 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (n := 32) (sb := PRE_pl_t2.spPre) (Sb := PRE_pl_t2.spPreSrv) (sc := PRE_pl_t2.spOpen) (Sc := PRE_pl_t2.spOpenSrv) (modeOk NB T tk cap hcap) accTail (by have h := PRE_pl_t2.checkedTail; rw [← PRE_pl_t2.spreadStart, ← PRE_pl_t2.tailSrv] at h; exact h) PRE_pl_t2.acceptedSpPre liveSp PRE_pl_t2.spInto topSp (fun ν h => by rw [oa6]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) brSp cntSp hT rfl)).trans (spreadM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_t2.spCtl PRE_pl_t2.spStack PRE_pl_t2.spOpenStep PRE_pl_t2.spIdCtl PRE_pl_t2.spLookup PRE_pl_t2.spCellVal PRE_pl_t2.spCellNoW PRE_pl_t2.spIdStep PRE_pl_t2.spCloseCtl PRE_pl_t2.spCloseStack PRE_pl_t2.spFwd PRE_pl_t2.spFwdKind (by decide) wFwd PRE_pl_t2.spCloseStep PRE_pl_t2.spRoom proto PRE_pl_t2.spNewNoW openNoOr PRE_pl_t2.spAfterNoOracle PRE_pl_t2.spInactive PRE_pl_t2.spBridge cntClose hT)).trans (glueE (extra := [2673435, PRE_pl_t2.cacheArray]) (NB := NB) (T := T) (tk := tk) (cap := cap) hcap PRE_pl_t2.acceptedRest PRE_pl_t2.checkedRest topEnd PRE_pl_t2.spAfterNoOracle afterInactive brEnd cntEnd hT)

end Host.Ts.Sim.Compose.Post.PL.T2
