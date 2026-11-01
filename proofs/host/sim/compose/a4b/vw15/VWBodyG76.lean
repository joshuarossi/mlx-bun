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

kernel_rfl bodyO737 : PRE_first_tail_x15_r0_body.S737.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S737.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr737 : bridgeOf PRE_first_tail_x15_r0_body.s737.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc737 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.S737) = fun _ _ => true
kernel_rfl bodyAcc738 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s738 PRE_first_tail_x15_r0_body.S738) = fun _ _ => true
kernel_rfl bodyBr739 : bridgeOf PRE_first_tail_x15_r0_body.s739.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt738 : isHalt PRE_first_tail_x15_r0_body.s738.ctl = false
kernel_rfl bodyTop739 : noRetBlock PRE_first_tail_x15_r0_body.s739 = true
kernel_rfl bodyCnt737 : countersOkB PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.s739 = true
kernel_rfl bodyO739 : PRE_first_tail_x15_r0_body.S739.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S739.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr740 : bridgeOf PRE_first_tail_x15_r0_body.s740.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt739 : countersOkB PRE_first_tail_x15_r0_body.s739 PRE_first_tail_x15_r0_body.s740 = true
kernel_rfl bodyO740 : PRE_first_tail_x15_r0_body.S740.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S740.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc740 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s740 PRE_first_tail_x15_r0_body.S740) = fun _ _ => true
kernel_rfl bodyAcc742 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s742 PRE_first_tail_x15_r0_body.S742) = fun _ _ => true
kernel_rfl bodyBr743 : bridgeOf PRE_first_tail_x15_r0_body.s743.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt742 : isHalt PRE_first_tail_x15_r0_body.s742.ctl = false
kernel_rfl bodyTop743 : noRetBlock PRE_first_tail_x15_r0_body.s743 = true
kernel_rfl bodyCnt740 : countersOkB PRE_first_tail_x15_r0_body.s740 PRE_first_tail_x15_r0_body.s743 = true

theorem bodyGlue76 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨29557, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s737 PRE_first_tail_x15_r0_body.S737)
      (bodyCut NB T tk π i x0 bodyΘ ⟨29557, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s743 PRE_first_tail_x15_r0_body.S743) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29557, 533, 0, 414⟩) bodyAcc737 PRE_first_tail_x15_r0_body.bodyRunSeg199 bodyAcc738 bodyHalt738 PRE_first_tail_x15_r0_body.bodyStepA200 bodyTop739 (fun _ hm => bodyO737 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr737).trans bodyInactive0) (bodyBr739.trans bodyBr737.symm) bodyCnt737 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29557, 533, 0, 414⟩) PRE_first_tail_x15_r0_body.sizeA200 PRE_first_tail_x15_r0_body.sizeArgsA200 PRE_first_tail_x15_r0_body.sizeSymA200 PRE_first_tail_x15_r0_body.sizeMlxA200 PRE_first_tail_x15_r0_body.sizePayA200 PRE_first_tail_x15_r0_body.sizeTaA200 PRE_first_tail_x15_r0_body.sizeDecA200 PRE_first_tail_x15_r0_body.sizePreA200 PRE_first_tail_x15_r0_body.bodyPatchB200 (fun _ hm => bodyO739 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr739).trans bodyInactive0) (bodyBr740.trans bodyBr739.symm) bodyCnt739 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29557, 533, 0, 414⟩) bodyAcc740 PRE_first_tail_x15_r0_body.bodyRunSeg200 bodyAcc742 bodyHalt742 PRE_first_tail_x15_r0_body.bodyStepA201 bodyTop743 (fun _ hm => bodyO740 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr740).trans bodyInactive0) (bodyBr743.trans bodyBr740.symm) bodyCnt740 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
