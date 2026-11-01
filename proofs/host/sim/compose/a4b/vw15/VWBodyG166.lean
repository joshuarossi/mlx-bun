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

kernel_rfl bodyO1599 : PRE_first_tail_x15_r0_body.S1599.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1599.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1599 : bridgeOf PRE_first_tail_x15_r0_body.s1599.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1599 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1599 PRE_first_tail_x15_r0_body.S1599) = fun _ _ => true
kernel_rfl bodyAcc1600 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1600 PRE_first_tail_x15_r0_body.S1600) = fun _ _ => true
kernel_rfl bodyBr1601 : bridgeOf PRE_first_tail_x15_r0_body.s1601.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1600 : isHalt PRE_first_tail_x15_r0_body.s1600.ctl = false
kernel_rfl bodyTop1601 : noRetBlock PRE_first_tail_x15_r0_body.s1601 = true
kernel_rfl bodyCnt1599 : countersOkB PRE_first_tail_x15_r0_body.s1599 PRE_first_tail_x15_r0_body.s1601 = true
kernel_rfl bodyO1601 : PRE_first_tail_x15_r0_body.S1601.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1601.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1602 : bridgeOf PRE_first_tail_x15_r0_body.s1602.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1601 : countersOkB PRE_first_tail_x15_r0_body.s1601 PRE_first_tail_x15_r0_body.s1602 = true
kernel_rfl bodyO1602 : PRE_first_tail_x15_r0_body.S1602.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1602.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1602 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1602 PRE_first_tail_x15_r0_body.S1602) = fun _ _ => true
kernel_rfl bodyAcc1604 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1604 PRE_first_tail_x15_r0_body.S1604) = fun _ _ => true
kernel_rfl bodyBr1605 : bridgeOf PRE_first_tail_x15_r0_body.s1605.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1604 : isHalt PRE_first_tail_x15_r0_body.s1604.ctl = false
kernel_rfl bodyTop1605 : noRetBlock PRE_first_tail_x15_r0_body.s1605 = true
kernel_rfl bodyCnt1602 : countersOkB PRE_first_tail_x15_r0_body.s1602 PRE_first_tail_x15_r0_body.s1605 = true

theorem bodyGlue166 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨58085, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1599 PRE_first_tail_x15_r0_body.S1599)
      (bodyCut NB T tk π i x0 bodyΘ ⟨58085, 1099, 0, 882⟩ bodyM PRE_first_tail_x15_r0_body.s1605 PRE_first_tail_x15_r0_body.S1605) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58085, 1099, 0, 882⟩) bodyAcc1599 PRE_first_tail_x15_r0_body.bodyRunSeg431 bodyAcc1600 bodyHalt1600 PRE_first_tail_x15_r0_body.bodyStepA432 bodyTop1601 (fun _ hm => bodyO1599 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1599).trans bodyInactive0) (bodyBr1601.trans bodyBr1599.symm) bodyCnt1599 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58085, 1099, 0, 882⟩) PRE_first_tail_x15_r0_body.sizeA432 PRE_first_tail_x15_r0_body.sizeArgsA432 PRE_first_tail_x15_r0_body.sizeSymA432 PRE_first_tail_x15_r0_body.sizeMlxA432 PRE_first_tail_x15_r0_body.sizePayA432 PRE_first_tail_x15_r0_body.sizeTaA432 PRE_first_tail_x15_r0_body.sizeDecA432 PRE_first_tail_x15_r0_body.sizePreA432 PRE_first_tail_x15_r0_body.bodyPatchB432 (fun _ hm => bodyO1601 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1601).trans bodyInactive0) (bodyBr1602.trans bodyBr1601.symm) bodyCnt1601 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨58085, 1099, 0, 882⟩) bodyAcc1602 PRE_first_tail_x15_r0_body.bodyRunSeg432 bodyAcc1604 bodyHalt1604 PRE_first_tail_x15_r0_body.bodyStepA433 bodyTop1605 (fun _ hm => bodyO1602 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1602).trans bodyInactive0) (bodyBr1605.trans bodyBr1602.symm) bodyCnt1602 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
