import host.sim.compose.a4b.VWBodyGlue
import host.sim.compose.a4b.vw15.VWBodyChain
import host.sim.compose.a4b.vw15.VWBodyMap
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B34
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B15
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B14
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.VWFirst.VW15
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template
open Host.Ts.Sim.Lin Host.Ts.Sim.Lin.Cls Host.Load.Run.Tpl Host.Route
open Host.Ts.Sim.Compose.SetupEarly Host.Ts.Sim.Compose.SetupChunk

kernel_rfl bodyO1772 : PRE_first_tail_x15_r0_body.S1772.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1772.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1772 : bridgeOf PRE_first_tail_x15_r0_body.s1772.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1772 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1772 PRE_first_tail_x15_r0_body.S1772) = fun _ _ => true
kernel_rfl bodyAcc1773 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1773 PRE_first_tail_x15_r0_body.S1773) = fun _ _ => true
kernel_rfl bodyBr1774 : bridgeOf PRE_first_tail_x15_r0_body.s1774.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1773 : isHalt PRE_first_tail_x15_r0_body.s1773.ctl = false
kernel_rfl bodyTop1774 : noRetBlock PRE_first_tail_x15_r0_body.s1774 = true
kernel_rfl bodyCnt1772 : countersOkB PRE_first_tail_x15_r0_body.s1772 PRE_first_tail_x15_r0_body.s1774 = true
kernel_rfl bodyO1774 : PRE_first_tail_x15_r0_body.S1774.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1774.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1775 : bridgeOf PRE_first_tail_x15_r0_body.s1775.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1774 : countersOkB PRE_first_tail_x15_r0_body.s1774 PRE_first_tail_x15_r0_body.s1775 = true
kernel_rfl bodyO1775 : PRE_first_tail_x15_r0_body.S1775.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1775.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1775 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1775 PRE_first_tail_x15_r0_body.S1775) = fun _ _ => true
kernel_rfl bodyAcc1777 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1777 PRE_first_tail_x15_r0_body.S1777) = fun _ _ => true
kernel_rfl bodyBr1778 : bridgeOf PRE_first_tail_x15_r0_body.s1778.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1777 : isHalt PRE_first_tail_x15_r0_body.s1777.ctl = false
kernel_rfl bodyTop1778 : noRetBlock PRE_first_tail_x15_r0_body.s1778 = true
kernel_rfl bodyCnt1775 : countersOkB PRE_first_tail_x15_r0_body.s1775 PRE_first_tail_x15_r0_body.s1778 = true

theorem bodyGlue184 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨64306, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1772 PRE_first_tail_x15_r0_body.S1772)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64306, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1778 PRE_first_tail_x15_r0_body.S1778) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64306, 1226, 0, 981⟩) bodyAcc1772 PRE_first_tail_x15_r0_body.bodyRunSeg478 bodyAcc1773 bodyHalt1773 PRE_first_tail_x15_r0_body.bodyStepA479 bodyTop1774 (fun _ hm => bodyO1772 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1772).trans bodyInactive0) (bodyBr1774.trans bodyBr1772.symm) bodyCnt1772 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64306, 1226, 0, 981⟩) PRE_first_tail_x15_r0_body.sizeA479 PRE_first_tail_x15_r0_body.sizeArgsA479 PRE_first_tail_x15_r0_body.sizeSymA479 PRE_first_tail_x15_r0_body.sizeMlxA479 PRE_first_tail_x15_r0_body.sizePayA479 PRE_first_tail_x15_r0_body.sizeTaA479 PRE_first_tail_x15_r0_body.sizeDecA479 PRE_first_tail_x15_r0_body.sizePreA479 PRE_first_tail_x15_r0_body.bodyPatchB479 (fun _ hm => bodyO1774 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1774).trans bodyInactive0) (bodyBr1775.trans bodyBr1774.symm) bodyCnt1774 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64306, 1226, 0, 981⟩) bodyAcc1775 PRE_first_tail_x15_r0_body.bodyRunSeg479 bodyAcc1777 bodyHalt1777 PRE_first_tail_x15_r0_body.bodyStepA480 bodyTop1778 (fun _ hm => bodyO1775 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1775).trans bodyInactive0) (bodyBr1778.trans bodyBr1775.symm) bodyCnt1775 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
