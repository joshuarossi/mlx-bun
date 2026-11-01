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

kernel_rfl bodyO1628 : PRE_first_tail_x15_r0_body.S1628.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1628.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1628 : bridgeOf PRE_first_tail_x15_r0_body.s1628.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1628 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1628 PRE_first_tail_x15_r0_body.S1628) = fun _ _ => true
kernel_rfl bodyAcc1629 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1629 PRE_first_tail_x15_r0_body.S1629) = fun _ _ => true
kernel_rfl bodyBr1630 : bridgeOf PRE_first_tail_x15_r0_body.s1630.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1629 : isHalt PRE_first_tail_x15_r0_body.s1629.ctl = false
kernel_rfl bodyTop1630 : noRetBlock PRE_first_tail_x15_r0_body.s1630 = true
kernel_rfl bodyCnt1628 : countersOkB PRE_first_tail_x15_r0_body.s1628 PRE_first_tail_x15_r0_body.s1630 = true
kernel_rfl bodyO1630 : PRE_first_tail_x15_r0_body.S1630.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1630.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1631 : bridgeOf PRE_first_tail_x15_r0_body.s1631.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1630 : countersOkB PRE_first_tail_x15_r0_body.s1630 PRE_first_tail_x15_r0_body.s1631 = true
kernel_rfl bodyO1631 : PRE_first_tail_x15_r0_body.S1631.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1631.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1631 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1631 PRE_first_tail_x15_r0_body.S1631) = fun _ _ => true
kernel_rfl bodyAcc1633 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1633 PRE_first_tail_x15_r0_body.S1633) = fun _ _ => true
kernel_rfl bodyBr1634 : bridgeOf PRE_first_tail_x15_r0_body.s1634.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1633 : isHalt PRE_first_tail_x15_r0_body.s1633.ctl = false
kernel_rfl bodyTop1634 : noRetBlock PRE_first_tail_x15_r0_body.s1634 = true
kernel_rfl bodyCnt1631 : countersOkB PRE_first_tail_x15_r0_body.s1631 PRE_first_tail_x15_r0_body.s1634 = true

theorem bodyGlue169 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨59255, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1628 PRE_first_tail_x15_r0_body.S1628)
      (bodyCut NB T tk π i x0 bodyΘ ⟨59255, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1634 PRE_first_tail_x15_r0_body.S1634) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59255, 1124, 0, 900⟩) bodyAcc1628 PRE_first_tail_x15_r0_body.bodyRunSeg439 bodyAcc1629 bodyHalt1629 PRE_first_tail_x15_r0_body.bodyStepA440 bodyTop1630 (fun _ hm => bodyO1628 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1628).trans bodyInactive0) (bodyBr1630.trans bodyBr1628.symm) bodyCnt1628 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59255, 1124, 0, 900⟩) PRE_first_tail_x15_r0_body.sizeA440 PRE_first_tail_x15_r0_body.sizeArgsA440 PRE_first_tail_x15_r0_body.sizeSymA440 PRE_first_tail_x15_r0_body.sizeMlxA440 PRE_first_tail_x15_r0_body.sizePayA440 PRE_first_tail_x15_r0_body.sizeTaA440 PRE_first_tail_x15_r0_body.sizeDecA440 PRE_first_tail_x15_r0_body.sizePreA440 PRE_first_tail_x15_r0_body.bodyPatchB440 (fun _ hm => bodyO1630 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1630).trans bodyInactive0) (bodyBr1631.trans bodyBr1630.symm) bodyCnt1630 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59255, 1124, 0, 900⟩) bodyAcc1631 PRE_first_tail_x15_r0_body.bodyRunSeg440 bodyAcc1633 bodyHalt1633 PRE_first_tail_x15_r0_body.bodyStepA441 bodyTop1634 (fun _ hm => bodyO1631 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1631).trans bodyInactive0) (bodyBr1634.trans bodyBr1631.symm) bodyCnt1631 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
