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

kernel_rfl bodyO663 : PRE_first_tail_x15_r0_body.S663.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S663.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr663 : bridgeOf PRE_first_tail_x15_r0_body.s663.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc663 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.S663) = fun _ _ => true
kernel_rfl bodyAcc665 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s665 PRE_first_tail_x15_r0_body.S665) = fun _ _ => true
kernel_rfl bodyBr666 : bridgeOf PRE_first_tail_x15_r0_body.s666.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt665 : isHalt PRE_first_tail_x15_r0_body.s665.ctl = false
kernel_rfl bodyTop666 : noRetBlock PRE_first_tail_x15_r0_body.s666 = true
kernel_rfl bodyCnt663 : countersOkB PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.s666 = true
kernel_rfl bodyO666 : PRE_first_tail_x15_r0_body.S666.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S666.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr667 : bridgeOf PRE_first_tail_x15_r0_body.s667.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt666 : countersOkB PRE_first_tail_x15_r0_body.s666 PRE_first_tail_x15_r0_body.s667 = true
kernel_rfl bodyO667 : PRE_first_tail_x15_r0_body.S667.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S667.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc667 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s667 PRE_first_tail_x15_r0_body.S667) = fun _ _ => true
kernel_rfl bodyAcc669 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s669 PRE_first_tail_x15_r0_body.S669) = fun _ _ => true
kernel_rfl bodyBr670 : bridgeOf PRE_first_tail_x15_r0_body.s670.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt669 : isHalt PRE_first_tail_x15_r0_body.s669.ctl = false
kernel_rfl bodyTop670 : noRetBlock PRE_first_tail_x15_r0_body.s670 = true
kernel_rfl bodyCnt667 : countersOkB PRE_first_tail_x15_r0_body.s667 PRE_first_tail_x15_r0_body.s670 = true
kernel_rfl bodyO670 : PRE_first_tail_x15_r0_body.S670.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S670.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr671 : bridgeOf PRE_first_tail_x15_r0_body.s671.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt670 : countersOkB PRE_first_tail_x15_r0_body.s670 PRE_first_tail_x15_r0_body.s671 = true
kernel_rfl bodyO671 : PRE_first_tail_x15_r0_body.S671.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S671.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc671 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s671 PRE_first_tail_x15_r0_body.S671) = fun _ _ => true
kernel_rfl bodyAcc672 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s672 PRE_first_tail_x15_r0_body.S672) = fun _ _ => true
kernel_rfl bodyBr673 : bridgeOf PRE_first_tail_x15_r0_body.s673.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt672 : isHalt PRE_first_tail_x15_r0_body.s672.ctl = false
kernel_rfl bodyTop673 : noRetBlock PRE_first_tail_x15_r0_body.s673 = true
kernel_rfl bodyCnt671 : countersOkB PRE_first_tail_x15_r0_body.s671 PRE_first_tail_x15_r0_body.s673 = true
kernel_rfl bodyO673 : PRE_first_tail_x15_r0_body.S673.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S673.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr674 : bridgeOf PRE_first_tail_x15_r0_body.s674.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt673 : countersOkB PRE_first_tail_x15_r0_body.s673 PRE_first_tail_x15_r0_body.s674 = true
kernel_rfl bodyO674 : PRE_first_tail_x15_r0_body.S674.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S674.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc674 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s674 PRE_first_tail_x15_r0_body.S674) = fun _ _ => true
kernel_rfl bodyAcc676 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s676 PRE_first_tail_x15_r0_body.S676) = fun _ _ => true
kernel_rfl bodyBr677 : bridgeOf PRE_first_tail_x15_r0_body.s677.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt676 : isHalt PRE_first_tail_x15_r0_body.s676.ctl = false
kernel_rfl bodyTop677 : noRetBlock PRE_first_tail_x15_r0_body.s677 = true
kernel_rfl bodyCnt674 : countersOkB PRE_first_tail_x15_r0_body.s674 PRE_first_tail_x15_r0_body.s677 = true

theorem bodyGlue69 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨26885, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.S663)
      (bodyCut NB T tk π i x0 bodyΘ ⟨26885, 481, 0, 369⟩ bodyM PRE_first_tail_x15_r0_body.s677 PRE_first_tail_x15_r0_body.S677) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26885, 481, 0, 369⟩) bodyAcc663 PRE_first_tail_x15_r0_body.bodyRunSeg179 bodyAcc665 bodyHalt665 PRE_first_tail_x15_r0_body.bodyStepA180 bodyTop666 (fun _ hm => bodyO663 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr663).trans bodyInactive0) (bodyBr666.trans bodyBr663.symm) bodyCnt663 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26885, 481, 0, 369⟩) PRE_first_tail_x15_r0_body.sizeA180 PRE_first_tail_x15_r0_body.sizeArgsA180 PRE_first_tail_x15_r0_body.sizeSymA180 PRE_first_tail_x15_r0_body.sizeMlxA180 PRE_first_tail_x15_r0_body.sizePayA180 PRE_first_tail_x15_r0_body.sizeTaA180 PRE_first_tail_x15_r0_body.sizeDecA180 PRE_first_tail_x15_r0_body.sizePreA180 PRE_first_tail_x15_r0_body.bodyPatchB180 (fun _ hm => bodyO666 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr666).trans bodyInactive0) (bodyBr667.trans bodyBr666.symm) bodyCnt666 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26885, 481, 0, 369⟩) bodyAcc667 PRE_first_tail_x15_r0_body.bodyRunSeg180 bodyAcc669 bodyHalt669 PRE_first_tail_x15_r0_body.bodyStepA181 bodyTop670 (fun _ hm => bodyO667 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr667).trans bodyInactive0) (bodyBr670.trans bodyBr667.symm) bodyCnt667 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26885, 481, 0, 369⟩) PRE_first_tail_x15_r0_body.sizeA181 PRE_first_tail_x15_r0_body.sizeArgsA181 PRE_first_tail_x15_r0_body.sizeSymA181 PRE_first_tail_x15_r0_body.sizeMlxA181 PRE_first_tail_x15_r0_body.sizePayA181 PRE_first_tail_x15_r0_body.sizeTaA181 PRE_first_tail_x15_r0_body.sizeDecA181 PRE_first_tail_x15_r0_body.sizePreA181 PRE_first_tail_x15_r0_body.bodyPatchB181 (fun _ hm => bodyO670 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr670).trans bodyInactive0) (bodyBr671.trans bodyBr670.symm) bodyCnt670 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26885, 481, 0, 369⟩) bodyAcc671 PRE_first_tail_x15_r0_body.bodyRunSeg181 bodyAcc672 bodyHalt672 PRE_first_tail_x15_r0_body.bodyStepA182 bodyTop673 (fun _ hm => bodyO671 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr671).trans bodyInactive0) (bodyBr673.trans bodyBr671.symm) bodyCnt671 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26885, 481, 0, 369⟩) PRE_first_tail_x15_r0_body.sizeA182 PRE_first_tail_x15_r0_body.sizeArgsA182 PRE_first_tail_x15_r0_body.sizeSymA182 PRE_first_tail_x15_r0_body.sizeMlxA182 PRE_first_tail_x15_r0_body.sizePayA182 PRE_first_tail_x15_r0_body.sizeTaA182 PRE_first_tail_x15_r0_body.sizeDecA182 PRE_first_tail_x15_r0_body.sizePreA182 PRE_first_tail_x15_r0_body.bodyPatchB182 (fun _ hm => bodyO673 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr673).trans bodyInactive0) (bodyBr674.trans bodyBr673.symm) bodyCnt673 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨26885, 481, 0, 369⟩) bodyAcc674 PRE_first_tail_x15_r0_body.bodyRunSeg182 bodyAcc676 bodyHalt676 PRE_first_tail_x15_r0_body.bodyStepA183 bodyTop677 (fun _ hm => bodyO674 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr674).trans bodyInactive0) (bodyBr677.trans bodyBr674.symm) bodyCnt674 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
