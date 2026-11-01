import host.sim.compose.PostPath
import host.sim.template.a4pre_pl_t1.Good
import host.sim.template.a4pre_pl_t1.K0
import host.sim.template.a4pre_pl_t1.Accept
import host.sim.template.a4pre_pl_t1.Len0
import host.sim.template.a4pre_pl_t1.H0
import host.sim.template.a4pre_pl_t1.K3
import host.sim.template.a4pre_pl_t1.Len1
import host.sim.template.a4pre_pl_t1.Tail
import host.sim.template.a4pre_pl_t1.TailSteps
import host.sim.template.a4pre_pl_t1.TailRest
import host.sim.template.a4pre_pl_t1.Endpoint
import host.sim.template.a4pre_pl_t1.SpreadData
import host.sim.template.BootEq
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.T1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl live1 : isHalt PRE_pl_t1.s1.ctl = false
kernel_rfl br0_2 : bridgeOf PRE_pl_t1.s2.ffi = bridgeOf PRE_pl_t1.s0.ffi
kernel_rfl oa2 : PRE_pl_t1.S2.oracle = List.drop (PRE_pl_t1.S0.oracle.length - PRE_pl_t1.S2.oracle.length) PRE_pl_t1.S0.oracle
kernel_rfl lst2 : PRE_pl_t1.s2.stack = .e (.member kLength false) :: PRE_pl_t1.s2.stack.tail
kernel_rfl cnt2_3 : countersOkB PRE_pl_t1.s2 PRE_pl_t1.s3 = true
kernel_rfl oa3 : PRE_pl_t1.S3.oracle = List.drop (PRE_pl_t1.S0.oracle.length - PRE_pl_t1.S3.oracle.length) PRE_pl_t1.S0.oracle
kernel_rfl live4 : isHalt PRE_pl_t1.s4.ctl = false
kernel_rfl br3_5 : bridgeOf PRE_pl_t1.s5.ffi = bridgeOf PRE_pl_t1.s3.ffi
kernel_rfl cnt3_5 : countersOkB PRE_pl_t1.s3 PRE_pl_t1.s5 = true
kernel_rfl oa5 : PRE_pl_t1.S5.oracle = List.drop (PRE_pl_t1.S0.oracle.length - PRE_pl_t1.S5.oracle.length) PRE_pl_t1.S0.oracle
kernel_rfl lst5 : PRE_pl_t1.s5.stack = .e (.member kLength false) :: PRE_pl_t1.s5.stack.tail
kernel_rfl cnt5_6 : countersOkB PRE_pl_t1.s5 PRE_pl_t1.s6 = true
kernel_rfl oa6 : PRE_pl_t1.S6.oracle = List.drop (PRE_pl_t1.S0.oracle.length - PRE_pl_t1.S6.oracle.length) PRE_pl_t1.S0.oracle
boot_rfl accTail from PRE_pl_t1.s6 to PRE_pl_t1.s6 : PostOk.ok PRE_pl_t1.s6 PRE_pl_t1.S6 = true
kernel_rfl liveSp : isHalt PRE_pl_t1.spPre.ctl = false
kernel_rfl topSp : noRetBlock PRE_pl_t1.spOpen = true
kernel_rfl brSp : bridgeOf PRE_pl_t1.spOpen.ffi = bridgeOf PRE_pl_t1.s6.ffi
kernel_rfl cntSp : countersOkB PRE_pl_t1.s6 PRE_pl_t1.spOpen = true
kernel_rfl wFwd : wideP 2673435 = none
kernel_rfl openNoOr : PRE_pl_t1.spOpenSrv.oracle = []
kernel_rfl cntClose : countersOkB PRE_pl_t1.spOpen PRE_pl_t1.spAfter = true
kernel_rfl proto : (PRE_pl_t1.spClose.heap.get aArrayProto).isSome = true
theorem afterInactive : (bridgeOf PRE_pl_t1.spAfter.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl topEnd : noRetBlock PRE_pl_t1.s7 = true
kernel_rfl brEnd : bridgeOf PRE_pl_t1.s7.ffi = bridgeOf PRE_pl_t1.spAfter.ffi
kernel_rfl cntEnd : countersOkB PRE_pl_t1.spAfter PRE_pl_t1.s7 = true

noncomputable abbrev n0 : Nat := (((((((((nth? PRE_pl_t1.ks 0).getD 0) + 1) + 1) + (((nth? PRE_pl_t1.ks 3).getD 0) + 1)) + 1) + (32 + 1)) + 3) + PRE_pl_t1.restFuel)

theorem c0 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_t1.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrackV x y → Tr x → Tr y) (hP : ∀ x y : SegInst FF, (indexedCut NB T tk cap nI π PRE_pl_t1.s0 PRE_pl_t1.S0).R x PRE_pl_t1.s0 ⟨PRE_pl_t1.S0.tab, []⟩ →
      (indexedCut NB T tk cap nI π PRE_pl_t1.s2 PRE_pl_t1.S2).R y PRE_pl_t1.s2 ⟨PRE_pl_t1.S2.tab, []⟩ → CSrv.Le x.C y.C → y.M.node = x.M.node →
      y.M.a 12504 = x.M.a 12504 → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_t1.s0 PRE_pl_t1.S0)) (withMem Tr (endCut NB T tk cap [2673435, PRE_pl_t1.cacheArray] PRE_pl_t1.s7 PRE_pl_t1.S7)) n0 :=
  (((((((popCallM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeOk NB T tk cap hcap) PRE_pl_t1.accepted0 PRE_pl_t1.run0 PRE_pl_t1.accepted1 live1 PRE_pl_t1.b0.enter PRE_pl_t1.b0.top hg (Host.Load.Boot.replay_active _) br0_2 hP rfl)).trans (lenM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_t1.b0.ctl lst2 PRE_pl_t1.b0.objGet PRE_pl_t1.b0.kind PRE_pl_t1.b0.patch (fun ν h => by rw [oa2]; exact good_drop _ (hg ν h)) PRE_pl_t1.b0.inactive PRE_pl_t1.b0.bridge cnt2_3 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeOk NB T tk cap hcap) PRE_pl_t1.accepted3 PRE_pl_t1.run3 PRE_pl_t1.accepted4 live4 PRE_pl_t1.b1.enter PRE_pl_t1.b1.top (fun ν h => by rw [oa3]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br3_5 cnt3_5 hT rfl)).trans (lenM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_t1.b1.ctl lst5 PRE_pl_t1.b1.objGet PRE_pl_t1.b1.kind PRE_pl_t1.b1.patch (fun ν h => by rw [oa5]; exact good_drop _ (hg ν h)) PRE_pl_t1.b1.inactive PRE_pl_t1.b1.bridge cnt5_6 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (n := 32) (sb := PRE_pl_t1.spPre) (Sb := PRE_pl_t1.spPreSrv) (sc := PRE_pl_t1.spOpen) (Sc := PRE_pl_t1.spOpenSrv) (modeOk NB T tk cap hcap) accTail (by have h := PRE_pl_t1.checkedTail; rw [← PRE_pl_t1.spreadStart, ← PRE_pl_t1.tailSrv] at h; exact h) PRE_pl_t1.acceptedSpPre liveSp PRE_pl_t1.spInto topSp (fun ν h => by rw [oa6]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) brSp cntSp hT rfl)).trans (spreadM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_t1.spCtl PRE_pl_t1.spStack PRE_pl_t1.spOpenStep PRE_pl_t1.spIdCtl PRE_pl_t1.spLookup PRE_pl_t1.spCellVal PRE_pl_t1.spCellNoW PRE_pl_t1.spIdStep PRE_pl_t1.spCloseCtl PRE_pl_t1.spCloseStack PRE_pl_t1.spFwd PRE_pl_t1.spFwdKind (by decide) wFwd PRE_pl_t1.spCloseStep PRE_pl_t1.spRoom proto PRE_pl_t1.spNewNoW openNoOr PRE_pl_t1.spAfterNoOracle PRE_pl_t1.spInactive PRE_pl_t1.spBridge cntClose hT)).trans (glueE (extra := [2673435, PRE_pl_t1.cacheArray]) (NB := NB) (T := T) (tk := tk) (cap := cap) hcap PRE_pl_t1.acceptedRest PRE_pl_t1.checkedRest topEnd PRE_pl_t1.spAfterNoOracle afterInactive brEnd cntEnd hT)

end Host.Ts.Sim.Compose.Post.PL.T1
