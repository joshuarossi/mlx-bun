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

kernel_rfl bodyO679 : PRE_first_tail_x15_r0_body.S679.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S679.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr679 : bridgeOf PRE_first_tail_x15_r0_body.s679.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc679 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.S679) = fun _ _ => true
kernel_rfl bodyAcc680 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s680 PRE_first_tail_x15_r0_body.S680) = fun _ _ => true
kernel_rfl bodyBr681 : bridgeOf PRE_first_tail_x15_r0_body.s681.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt680 : isHalt PRE_first_tail_x15_r0_body.s680.ctl = false
kernel_rfl bodyTop681 : noRetBlock PRE_first_tail_x15_r0_body.s681 = true
kernel_rfl bodyCnt679 : countersOkB PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.s681 = true
kernel_rfl bodyO681 : PRE_first_tail_x15_r0_body.S681.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S681.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr682 : bridgeOf PRE_first_tail_x15_r0_body.s682.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt681 : countersOkB PRE_first_tail_x15_r0_body.s681 PRE_first_tail_x15_r0_body.s682 = true
kernel_rfl bodyO682 : PRE_first_tail_x15_r0_body.S682.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S682.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc682 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s682 PRE_first_tail_x15_r0_body.S682) = fun _ _ => true
kernel_rfl bodyAcc684 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s684 PRE_first_tail_x15_r0_body.S684) = fun _ _ => true
kernel_rfl bodyBr685 : bridgeOf PRE_first_tail_x15_r0_body.s685.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt684 : isHalt PRE_first_tail_x15_r0_body.s684.ctl = false
kernel_rfl bodyTop685 : noRetBlock PRE_first_tail_x15_r0_body.s685 = true
kernel_rfl bodyCnt682 : countersOkB PRE_first_tail_x15_r0_body.s682 PRE_first_tail_x15_r0_body.s685 = true

theorem bodyGlue70 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨27235, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s679 PRE_first_tail_x15_r0_body.S679)
      (bodyCut NB T tk π i x0 bodyΘ ⟨27235, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s685 PRE_first_tail_x15_r0_body.S685) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27235, 483, 0, 378⟩) bodyAcc679 PRE_first_tail_x15_r0_body.bodyRunSeg183 bodyAcc680 bodyHalt680 PRE_first_tail_x15_r0_body.bodyStepA184 bodyTop681 (fun _ hm => bodyO679 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr679).trans bodyInactive0) (bodyBr681.trans bodyBr679.symm) bodyCnt679 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27235, 483, 0, 378⟩) PRE_first_tail_x15_r0_body.sizeA184 PRE_first_tail_x15_r0_body.sizeArgsA184 PRE_first_tail_x15_r0_body.sizeSymA184 PRE_first_tail_x15_r0_body.sizeMlxA184 PRE_first_tail_x15_r0_body.sizePayA184 PRE_first_tail_x15_r0_body.sizeTaA184 PRE_first_tail_x15_r0_body.sizeDecA184 PRE_first_tail_x15_r0_body.sizePreA184 PRE_first_tail_x15_r0_body.bodyPatchB184 (fun _ hm => bodyO681 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr681).trans bodyInactive0) (bodyBr682.trans bodyBr681.symm) bodyCnt681 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27235, 483, 0, 378⟩) bodyAcc682 PRE_first_tail_x15_r0_body.bodyRunSeg184 bodyAcc684 bodyHalt684 PRE_first_tail_x15_r0_body.bodyStepA185 bodyTop685 (fun _ hm => bodyO682 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr682).trans bodyInactive0) (bodyBr685.trans bodyBr682.symm) bodyCnt682 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
