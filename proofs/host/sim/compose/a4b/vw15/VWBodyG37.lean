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

kernel_rfl bodyO363 : PRE_first_tail_x15_r0_body.S363.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S363.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr363 : bridgeOf PRE_first_tail_x15_r0_body.s363.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc363 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s363 PRE_first_tail_x15_r0_body.S363) = fun _ _ => true
kernel_rfl bodyAcc364 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s364 PRE_first_tail_x15_r0_body.S364) = fun _ _ => true
kernel_rfl bodyBr365 : bridgeOf PRE_first_tail_x15_r0_body.s365.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt364 : isHalt PRE_first_tail_x15_r0_body.s364.ctl = false
kernel_rfl bodyTop365 : noRetBlock PRE_first_tail_x15_r0_body.s365 = true
kernel_rfl bodyCnt363 : countersOkB PRE_first_tail_x15_r0_body.s363 PRE_first_tail_x15_r0_body.s365 = true
kernel_rfl bodyO365 : PRE_first_tail_x15_r0_body.S365.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S365.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr366 : bridgeOf PRE_first_tail_x15_r0_body.s366.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt365 : countersOkB PRE_first_tail_x15_r0_body.s365 PRE_first_tail_x15_r0_body.s366 = true
kernel_rfl bodyO366 : PRE_first_tail_x15_r0_body.S366.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S366.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc366 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s366 PRE_first_tail_x15_r0_body.S366) = fun _ _ => true
kernel_rfl bodyAcc368 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s368 PRE_first_tail_x15_r0_body.S368) = fun _ _ => true
kernel_rfl bodyBr369 : bridgeOf PRE_first_tail_x15_r0_body.s369.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt368 : isHalt PRE_first_tail_x15_r0_body.s368.ctl = false
kernel_rfl bodyTop369 : noRetBlock PRE_first_tail_x15_r0_body.s369 = true
kernel_rfl bodyCnt366 : countersOkB PRE_first_tail_x15_r0_body.s366 PRE_first_tail_x15_r0_body.s369 = true

theorem bodyGlue37 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16816, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s363 PRE_first_tail_x15_r0_body.S363)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16816, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s369 PRE_first_tail_x15_r0_body.S369) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16816, 277, 0, 207⟩) bodyAcc363 PRE_first_tail_x15_r0_body.bodyRunSeg98 bodyAcc364 bodyHalt364 PRE_first_tail_x15_r0_body.bodyStepA99 bodyTop365 (fun _ hm => bodyO363 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr363).trans bodyInactive0) (bodyBr365.trans bodyBr363.symm) bodyCnt363 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16816, 277, 0, 207⟩) PRE_first_tail_x15_r0_body.sizeA99 PRE_first_tail_x15_r0_body.sizeArgsA99 PRE_first_tail_x15_r0_body.sizeSymA99 PRE_first_tail_x15_r0_body.sizeMlxA99 PRE_first_tail_x15_r0_body.sizePayA99 PRE_first_tail_x15_r0_body.sizeTaA99 PRE_first_tail_x15_r0_body.sizeDecA99 PRE_first_tail_x15_r0_body.sizePreA99 PRE_first_tail_x15_r0_body.bodyPatchB99 (fun _ hm => bodyO365 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr365).trans bodyInactive0) (bodyBr366.trans bodyBr365.symm) bodyCnt365 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16816, 277, 0, 207⟩) bodyAcc366 PRE_first_tail_x15_r0_body.bodyRunSeg99 bodyAcc368 bodyHalt368 PRE_first_tail_x15_r0_body.bodyStepA100 bodyTop369 (fun _ hm => bodyO366 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr366).trans bodyInactive0) (bodyBr369.trans bodyBr366.symm) bodyCnt366 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
