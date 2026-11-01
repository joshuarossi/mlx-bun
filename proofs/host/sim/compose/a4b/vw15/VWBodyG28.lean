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

kernel_rfl bodyO277 : PRE_first_tail_x15_r0_body.S277.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S277.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr277 : bridgeOf PRE_first_tail_x15_r0_body.s277.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc277 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s277 PRE_first_tail_x15_r0_body.S277) = fun _ _ => true
kernel_rfl bodyAcc278 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s278 PRE_first_tail_x15_r0_body.S278) = fun _ _ => true
kernel_rfl bodyBr279 : bridgeOf PRE_first_tail_x15_r0_body.s279.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt278 : isHalt PRE_first_tail_x15_r0_body.s278.ctl = false
kernel_rfl bodyTop279 : noRetBlock PRE_first_tail_x15_r0_body.s279 = true
kernel_rfl bodyCnt277 : countersOkB PRE_first_tail_x15_r0_body.s277 PRE_first_tail_x15_r0_body.s279 = true
kernel_rfl bodyO279 : PRE_first_tail_x15_r0_body.S279.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S279.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr280 : bridgeOf PRE_first_tail_x15_r0_body.s280.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt279 : countersOkB PRE_first_tail_x15_r0_body.s279 PRE_first_tail_x15_r0_body.s280 = true
kernel_rfl bodyO280 : PRE_first_tail_x15_r0_body.S280.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S280.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc280 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s280 PRE_first_tail_x15_r0_body.S280) = fun _ _ => true
kernel_rfl bodyAcc282 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s282 PRE_first_tail_x15_r0_body.S282) = fun _ _ => true
kernel_rfl bodyBr283 : bridgeOf PRE_first_tail_x15_r0_body.s283.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt282 : isHalt PRE_first_tail_x15_r0_body.s282.ctl = false
kernel_rfl bodyTop283 : noRetBlock PRE_first_tail_x15_r0_body.s283 = true
kernel_rfl bodyCnt280 : countersOkB PRE_first_tail_x15_r0_body.s280 PRE_first_tail_x15_r0_body.s283 = true

theorem bodyGlue28 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14123, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s277 PRE_first_tail_x15_r0_body.S277)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14123, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s283 PRE_first_tail_x15_r0_body.S283) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14123, 225, 0, 162⟩) bodyAcc277 PRE_first_tail_x15_r0_body.bodyRunSeg75 bodyAcc278 bodyHalt278 PRE_first_tail_x15_r0_body.bodyStepA76 bodyTop279 (fun _ hm => bodyO277 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr277).trans bodyInactive0) (bodyBr279.trans bodyBr277.symm) bodyCnt277 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14123, 225, 0, 162⟩) PRE_first_tail_x15_r0_body.sizeA76 PRE_first_tail_x15_r0_body.sizeArgsA76 PRE_first_tail_x15_r0_body.sizeSymA76 PRE_first_tail_x15_r0_body.sizeMlxA76 PRE_first_tail_x15_r0_body.sizePayA76 PRE_first_tail_x15_r0_body.sizeTaA76 PRE_first_tail_x15_r0_body.sizeDecA76 PRE_first_tail_x15_r0_body.sizePreA76 PRE_first_tail_x15_r0_body.bodyPatchB76 (fun _ hm => bodyO279 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr279).trans bodyInactive0) (bodyBr280.trans bodyBr279.symm) bodyCnt279 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14123, 225, 0, 162⟩) bodyAcc280 PRE_first_tail_x15_r0_body.bodyRunSeg76 bodyAcc282 bodyHalt282 PRE_first_tail_x15_r0_body.bodyStepA77 bodyTop283 (fun _ hm => bodyO280 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr280).trans bodyInactive0) (bodyBr283.trans bodyBr280.symm) bodyCnt280 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
