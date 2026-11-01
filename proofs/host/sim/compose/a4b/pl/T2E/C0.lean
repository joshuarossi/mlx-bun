import host.sim.compose.PostPath
import host.sim.template.a4pre_pl_t2_eos.Good
import host.sim.template.a4pre_pl_t2_eos.K0
import host.sim.template.a4pre_pl_t2_eos.Accept
import host.sim.template.a4pre_pl_t2_eos.Len0
import host.sim.template.a4pre_pl_t2_eos.H0
import host.sim.template.a4pre_pl_t2_eos.K3
import host.sim.template.a4pre_pl_t2_eos.Len1
import host.sim.template.a4pre_pl_t2_eos.Tail
import host.sim.template.a4pre_pl_t2_eos.TailSteps
import host.sim.template.a4pre_pl_t2_eos.TailRest
import host.sim.template.a4pre_pl_t2_eos.SpreadData
import host.sim.template.BootEq
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.T2E
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl live1 : isHalt PRE_pl_t2_eos.s1.ctl = false
kernel_rfl br0_2 : bridgeOf PRE_pl_t2_eos.s2.ffi = bridgeOf PRE_pl_t2_eos.s0.ffi
kernel_rfl oa2 : PRE_pl_t2_eos.S2.oracle = List.drop (PRE_pl_t2_eos.S0.oracle.length - PRE_pl_t2_eos.S2.oracle.length) PRE_pl_t2_eos.S0.oracle
kernel_rfl lst2 : PRE_pl_t2_eos.s2.stack = .e (.member kLength false) :: PRE_pl_t2_eos.s2.stack.tail
kernel_rfl cnt2_3 : countersOkB PRE_pl_t2_eos.s2 PRE_pl_t2_eos.s3 = true
kernel_rfl oa3 : PRE_pl_t2_eos.S3.oracle = List.drop (PRE_pl_t2_eos.S0.oracle.length - PRE_pl_t2_eos.S3.oracle.length) PRE_pl_t2_eos.S0.oracle
kernel_rfl live4 : isHalt PRE_pl_t2_eos.s4.ctl = false
kernel_rfl br3_5 : bridgeOf PRE_pl_t2_eos.s5.ffi = bridgeOf PRE_pl_t2_eos.s3.ffi
kernel_rfl cnt3_5 : countersOkB PRE_pl_t2_eos.s3 PRE_pl_t2_eos.s5 = true
kernel_rfl oa5 : PRE_pl_t2_eos.S5.oracle = List.drop (PRE_pl_t2_eos.S0.oracle.length - PRE_pl_t2_eos.S5.oracle.length) PRE_pl_t2_eos.S0.oracle
kernel_rfl lst5 : PRE_pl_t2_eos.s5.stack = .e (.member kLength false) :: PRE_pl_t2_eos.s5.stack.tail
kernel_rfl cnt5_6 : countersOkB PRE_pl_t2_eos.s5 PRE_pl_t2_eos.s6 = true
kernel_rfl oa6 : PRE_pl_t2_eos.S6.oracle = List.drop (PRE_pl_t2_eos.S0.oracle.length - PRE_pl_t2_eos.S6.oracle.length) PRE_pl_t2_eos.S0.oracle
boot_rfl accTail from PRE_pl_t2_eos.s6 to PRE_pl_t2_eos.s6 : PostOk.ok PRE_pl_t2_eos.s6 PRE_pl_t2_eos.S6 = true
kernel_rfl liveSp : isHalt PRE_pl_t2_eos.spPre.ctl = false
kernel_rfl topSp : noRetBlock PRE_pl_t2_eos.spOpen = true
kernel_rfl brSp : bridgeOf PRE_pl_t2_eos.spOpen.ffi = bridgeOf PRE_pl_t2_eos.s6.ffi
kernel_rfl cntSp : countersOkB PRE_pl_t2_eos.s6 PRE_pl_t2_eos.spOpen = true
kernel_rfl wFwd : wideP 2673435 = none
kernel_rfl openNoOr : PRE_pl_t2_eos.spOpenSrv.oracle = []
kernel_rfl cntClose : countersOkB PRE_pl_t2_eos.spOpen PRE_pl_t2_eos.spAfter = true
kernel_rfl proto : (PRE_pl_t2_eos.spClose.heap.get aArrayProto).isSome = true
theorem afterInactive : (bridgeOf PRE_pl_t2_eos.spAfter.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl topEnd : noRetBlock PRE_pl_t2_eos.s7 = true
kernel_rfl brEnd : bridgeOf PRE_pl_t2_eos.s7.ffi = bridgeOf PRE_pl_t2_eos.spAfter.ffi
kernel_rfl cntEnd : countersOkB PRE_pl_t2_eos.spAfter PRE_pl_t2_eos.s7 = true

noncomputable abbrev n0 : Nat := (((((((((nth? PRE_pl_t2_eos.ks 0).getD 0) + 1) + 1) + (((nth? PRE_pl_t2_eos.ks 3).getD 0) + 1)) + 1) + (33 + 1)) + 3) + PRE_pl_t2_eos.restFuel)

theorem c0 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_t2_eos.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrackV x y → Tr x → Tr y) (hP : ∀ x y : SegInst FF, (indexedCut NB T tk cap nI π PRE_pl_t2_eos.s0 PRE_pl_t2_eos.S0).R x PRE_pl_t2_eos.s0 ⟨PRE_pl_t2_eos.S0.tab, []⟩ →
      (indexedCut NB T tk cap nI π PRE_pl_t2_eos.s2 PRE_pl_t2_eos.S2).R y PRE_pl_t2_eos.s2 ⟨PRE_pl_t2_eos.S2.tab, []⟩ → CSrv.Le x.C y.C → y.M.node = x.M.node →
      y.M.a 12504 = x.M.a 12504 → Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi) → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_t2_eos.s0 PRE_pl_t2_eos.S0)) (withMem Tr (endCut NB T tk cap [2673435, PRE_pl_t2_eos.cacheArray] PRE_pl_t2_eos.s7 PRE_pl_t2_eos.S7)) n0 :=
  (((((((popCallM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeOk NB T tk cap hcap) PRE_pl_t2_eos.accepted0 PRE_pl_t2_eos.run0 PRE_pl_t2_eos.accepted1 live1 PRE_pl_t2_eos.b0.enter PRE_pl_t2_eos.b0.top hg (Host.Load.Boot.replay_active _) br0_2 hP rfl)).trans (lenM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_t2_eos.b0.ctl lst2 PRE_pl_t2_eos.b0.objGet PRE_pl_t2_eos.b0.kind PRE_pl_t2_eos.b0.patch (fun ν h => by rw [oa2]; exact good_drop _ (hg ν h)) PRE_pl_t2_eos.b0.inactive PRE_pl_t2_eos.b0.bridge cnt2_3 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeOk NB T tk cap hcap) PRE_pl_t2_eos.accepted3 PRE_pl_t2_eos.run3 PRE_pl_t2_eos.accepted4 live4 PRE_pl_t2_eos.b1.enter PRE_pl_t2_eos.b1.top (fun ν h => by rw [oa3]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br3_5 cnt3_5 hT rfl)).trans (lenM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_t2_eos.b1.ctl lst5 PRE_pl_t2_eos.b1.objGet PRE_pl_t2_eos.b1.kind PRE_pl_t2_eos.b1.patch (fun ν h => by rw [oa5]; exact good_drop _ (hg ν h)) PRE_pl_t2_eos.b1.inactive PRE_pl_t2_eos.b1.bridge cnt5_6 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (n := 33) (sb := PRE_pl_t2_eos.spPre) (Sb := PRE_pl_t2_eos.spPreSrv) (sc := PRE_pl_t2_eos.spOpen) (Sc := PRE_pl_t2_eos.spOpenSrv) (modeOk NB T tk cap hcap) accTail (by have h := PRE_pl_t2_eos.checkedTail; rw [← PRE_pl_t2_eos.spreadStart, ← PRE_pl_t2_eos.tailSrv] at h; exact h) PRE_pl_t2_eos.acceptedSpPre liveSp PRE_pl_t2_eos.spInto topSp (fun ν h => by rw [oa6]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) brSp cntSp hT rfl)).trans (spreadM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_t2_eos.spCtl PRE_pl_t2_eos.spStack PRE_pl_t2_eos.spOpenStep PRE_pl_t2_eos.spIdCtl PRE_pl_t2_eos.spLookup PRE_pl_t2_eos.spCellVal PRE_pl_t2_eos.spCellNoW PRE_pl_t2_eos.spIdStep PRE_pl_t2_eos.spCloseCtl PRE_pl_t2_eos.spCloseStack PRE_pl_t2_eos.spFwd PRE_pl_t2_eos.spFwdKind (by decide) wFwd PRE_pl_t2_eos.spCloseStep PRE_pl_t2_eos.spRoom proto PRE_pl_t2_eos.spNewNoW openNoOr PRE_pl_t2_eos.spAfterNoOracle PRE_pl_t2_eos.spInactive PRE_pl_t2_eos.spBridge cntClose hT)).trans (glueE (extra := [2673435, PRE_pl_t2_eos.cacheArray]) (NB := NB) (T := T) (tk := tk) (cap := cap) hcap PRE_pl_t2_eos.acceptedRest PRE_pl_t2_eos.checkedRest topEnd PRE_pl_t2_eos.spAfterNoOracle afterInactive brEnd cntEnd hT)

end Host.Ts.Sim.Compose.Post.PL.T2E
