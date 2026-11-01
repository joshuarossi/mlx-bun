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

kernel_rfl bodyO720 : PRE_first_tail_x15_r0_body.S720.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S720.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr720 : bridgeOf PRE_first_tail_x15_r0_body.s720.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc720 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.S720) = fun _ _ => true
kernel_rfl bodyAcc722 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s722 PRE_first_tail_x15_r0_body.S722) = fun _ _ => true
kernel_rfl bodyBr723 : bridgeOf PRE_first_tail_x15_r0_body.s723.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt722 : isHalt PRE_first_tail_x15_r0_body.s722.ctl = false
kernel_rfl bodyTop723 : noRetBlock PRE_first_tail_x15_r0_body.s723 = true
kernel_rfl bodyCnt720 : countersOkB PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.s723 = true
kernel_rfl bodyO723 : PRE_first_tail_x15_r0_body.S723.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S723.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr724 : bridgeOf PRE_first_tail_x15_r0_body.s724.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt723 : countersOkB PRE_first_tail_x15_r0_body.s723 PRE_first_tail_x15_r0_body.s724 = true
kernel_rfl bodyO724 : PRE_first_tail_x15_r0_body.S724.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S724.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc724 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s724 PRE_first_tail_x15_r0_body.S724) = fun _ _ => true
kernel_rfl bodyAcc725 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s725 PRE_first_tail_x15_r0_body.S725) = fun _ _ => true
kernel_rfl bodyBr726 : bridgeOf PRE_first_tail_x15_r0_body.s726.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt725 : isHalt PRE_first_tail_x15_r0_body.s725.ctl = false
kernel_rfl bodyTop726 : noRetBlock PRE_first_tail_x15_r0_body.s726 = true
kernel_rfl bodyCnt724 : countersOkB PRE_first_tail_x15_r0_body.s724 PRE_first_tail_x15_r0_body.s726 = true
kernel_rfl bodyO726 : PRE_first_tail_x15_r0_body.S726.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S726.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr727 : bridgeOf PRE_first_tail_x15_r0_body.s727.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt726 : countersOkB PRE_first_tail_x15_r0_body.s726 PRE_first_tail_x15_r0_body.s727 = true
kernel_rfl bodyO727 : PRE_first_tail_x15_r0_body.S727.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S727.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc727 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s727 PRE_first_tail_x15_r0_body.S727) = fun _ _ => true
kernel_rfl bodyAcc728 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s728 PRE_first_tail_x15_r0_body.S728) = fun _ _ => true
kernel_rfl bodyBr729 : bridgeOf PRE_first_tail_x15_r0_body.s729.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt728 : isHalt PRE_first_tail_x15_r0_body.s728.ctl = false
kernel_rfl bodyTop729 : noRetBlock PRE_first_tail_x15_r0_body.s729 = true
kernel_rfl bodyCnt727 : countersOkB PRE_first_tail_x15_r0_body.s727 PRE_first_tail_x15_r0_body.s729 = true
kernel_rfl bodyO729 : PRE_first_tail_x15_r0_body.S729.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S729.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr730 : bridgeOf PRE_first_tail_x15_r0_body.s730.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt729 : countersOkB PRE_first_tail_x15_r0_body.s729 PRE_first_tail_x15_r0_body.s730 = true
kernel_rfl bodyO730 : PRE_first_tail_x15_r0_body.S730.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S730.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc730 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s730 PRE_first_tail_x15_r0_body.S730) = fun _ _ => true
kernel_rfl bodyAcc731 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s731 PRE_first_tail_x15_r0_body.S731) = fun _ _ => true
kernel_rfl bodyBr732 : bridgeOf PRE_first_tail_x15_r0_body.s732.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt731 : isHalt PRE_first_tail_x15_r0_body.s731.ctl = false
kernel_rfl bodyTop732 : noRetBlock PRE_first_tail_x15_r0_body.s732 = true
kernel_rfl bodyCnt730 : countersOkB PRE_first_tail_x15_r0_body.s730 PRE_first_tail_x15_r0_body.s732 = true
kernel_rfl bodyO732 : PRE_first_tail_x15_r0_body.S732.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S732.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr733 : bridgeOf PRE_first_tail_x15_r0_body.s733.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt732 : countersOkB PRE_first_tail_x15_r0_body.s732 PRE_first_tail_x15_r0_body.s733 = true
kernel_rfl bodyO733 : PRE_first_tail_x15_r0_body.S733.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S733.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc733 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s733 PRE_first_tail_x15_r0_body.S733) = fun _ _ => true
kernel_rfl bodyAcc734 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s734 PRE_first_tail_x15_r0_body.S734) = fun _ _ => true
kernel_rfl bodyBr735 : bridgeOf PRE_first_tail_x15_r0_body.s735.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt734 : isHalt PRE_first_tail_x15_r0_body.s734.ctl = false
kernel_rfl bodyTop735 : noRetBlock PRE_first_tail_x15_r0_body.s735 = true
kernel_rfl bodyCnt733 : countersOkB PRE_first_tail_x15_r0_body.s733 PRE_first_tail_x15_r0_body.s735 = true

theorem bodyGlue75 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨28408, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.S720)
      (bodyCut NB T tk π i x0 bodyΘ ⟨28408, 508, 0, 396⟩ bodyM PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.S735) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28408, 508, 0, 396⟩) bodyAcc720 PRE_first_tail_x15_r0_body.bodyRunSeg194 bodyAcc722 bodyHalt722 PRE_first_tail_x15_r0_body.bodyStepA195 bodyTop723 (fun _ hm => bodyO720 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr720).trans bodyInactive0) (bodyBr723.trans bodyBr720.symm) bodyCnt720 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28408, 508, 0, 396⟩) PRE_first_tail_x15_r0_body.sizeA195 PRE_first_tail_x15_r0_body.sizeArgsA195 PRE_first_tail_x15_r0_body.sizeSymA195 PRE_first_tail_x15_r0_body.sizeMlxA195 PRE_first_tail_x15_r0_body.sizePayA195 PRE_first_tail_x15_r0_body.sizeTaA195 PRE_first_tail_x15_r0_body.sizeDecA195 PRE_first_tail_x15_r0_body.sizePreA195 PRE_first_tail_x15_r0_body.bodyPatchB195 (fun _ hm => bodyO723 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr723).trans bodyInactive0) (bodyBr724.trans bodyBr723.symm) bodyCnt723 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28408, 508, 0, 396⟩) bodyAcc724 PRE_first_tail_x15_r0_body.bodyRunSeg195 bodyAcc725 bodyHalt725 PRE_first_tail_x15_r0_body.bodyStepA196 bodyTop726 (fun _ hm => bodyO724 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr724).trans bodyInactive0) (bodyBr726.trans bodyBr724.symm) bodyCnt724 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28408, 508, 0, 396⟩) PRE_first_tail_x15_r0_body.sizeA196 PRE_first_tail_x15_r0_body.sizeArgsA196 PRE_first_tail_x15_r0_body.sizeSymA196 PRE_first_tail_x15_r0_body.sizeMlxA196 PRE_first_tail_x15_r0_body.sizePayA196 PRE_first_tail_x15_r0_body.sizeTaA196 PRE_first_tail_x15_r0_body.sizeDecA196 PRE_first_tail_x15_r0_body.sizePreA196 PRE_first_tail_x15_r0_body.bodyPatchB196 (fun _ hm => bodyO726 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr726).trans bodyInactive0) (bodyBr727.trans bodyBr726.symm) bodyCnt726 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28408, 508, 0, 396⟩) bodyAcc727 PRE_first_tail_x15_r0_body.bodyRunSeg196 bodyAcc728 bodyHalt728 PRE_first_tail_x15_r0_body.bodyStepA197 bodyTop729 (fun _ hm => bodyO727 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr727).trans bodyInactive0) (bodyBr729.trans bodyBr727.symm) bodyCnt727 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28408, 508, 0, 396⟩) PRE_first_tail_x15_r0_body.sizeA197 PRE_first_tail_x15_r0_body.sizeArgsA197 PRE_first_tail_x15_r0_body.sizeSymA197 PRE_first_tail_x15_r0_body.sizeMlxA197 PRE_first_tail_x15_r0_body.sizePayA197 PRE_first_tail_x15_r0_body.sizeTaA197 PRE_first_tail_x15_r0_body.sizeDecA197 PRE_first_tail_x15_r0_body.sizePreA197 PRE_first_tail_x15_r0_body.bodyPatchB197 (fun _ hm => bodyO729 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr729).trans bodyInactive0) (bodyBr730.trans bodyBr729.symm) bodyCnt729 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28408, 508, 0, 396⟩) bodyAcc730 PRE_first_tail_x15_r0_body.bodyRunSeg197 bodyAcc731 bodyHalt731 PRE_first_tail_x15_r0_body.bodyStepA198 bodyTop732 (fun _ hm => bodyO730 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr730).trans bodyInactive0) (bodyBr732.trans bodyBr730.symm) bodyCnt730 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28408, 508, 0, 396⟩) PRE_first_tail_x15_r0_body.sizeA198 PRE_first_tail_x15_r0_body.sizeArgsA198 PRE_first_tail_x15_r0_body.sizeSymA198 PRE_first_tail_x15_r0_body.sizeMlxA198 PRE_first_tail_x15_r0_body.sizePayA198 PRE_first_tail_x15_r0_body.sizeTaA198 PRE_first_tail_x15_r0_body.sizeDecA198 PRE_first_tail_x15_r0_body.sizePreA198 PRE_first_tail_x15_r0_body.bodyPatchB198 (fun _ hm => bodyO732 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr732).trans bodyInactive0) (bodyBr733.trans bodyBr732.symm) bodyCnt732 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨28408, 508, 0, 396⟩) bodyAcc733 PRE_first_tail_x15_r0_body.bodyRunSeg198 bodyAcc734 bodyHalt734 PRE_first_tail_x15_r0_body.bodyStepA199 bodyTop735 (fun _ hm => bodyO733 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr733).trans bodyInactive0) (bodyBr735.trans bodyBr733.symm) bodyCnt733 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
