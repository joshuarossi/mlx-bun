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

kernel_rfl bodyO30 : PRE_first_tail_x15_r0_body.S30.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S30.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr30 : bridgeOf PRE_first_tail_x15_r0_body.s30.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc30 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s30 PRE_first_tail_x15_r0_body.S30) = fun _ _ => true
kernel_rfl bodyAcc32 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s32 PRE_first_tail_x15_r0_body.S32) = fun _ _ => true
kernel_rfl bodyBr33 : bridgeOf PRE_first_tail_x15_r0_body.s33.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt32 : isHalt PRE_first_tail_x15_r0_body.s32.ctl = false
kernel_rfl bodyTop33 : noRetBlock PRE_first_tail_x15_r0_body.s33 = true
kernel_rfl bodyCnt30 : countersOkB PRE_first_tail_x15_r0_body.s30 PRE_first_tail_x15_r0_body.s33 = true
kernel_rfl bodyO33 : PRE_first_tail_x15_r0_body.S33.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S33.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr34 : bridgeOf PRE_first_tail_x15_r0_body.s34.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt33 : countersOkB PRE_first_tail_x15_r0_body.s33 PRE_first_tail_x15_r0_body.s34 = true
kernel_rfl bodyO34 : PRE_first_tail_x15_r0_body.S34.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S34.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc34 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s34 PRE_first_tail_x15_r0_body.S34) = fun _ _ => true
kernel_rfl bodyAcc35 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s35 PRE_first_tail_x15_r0_body.S35) = fun _ _ => true
kernel_rfl bodyBr36 : bridgeOf PRE_first_tail_x15_r0_body.s36.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt35 : isHalt PRE_first_tail_x15_r0_body.s35.ctl = false
kernel_rfl bodyTop36 : noRetBlock PRE_first_tail_x15_r0_body.s36 = true
kernel_rfl bodyCnt34 : countersOkB PRE_first_tail_x15_r0_body.s34 PRE_first_tail_x15_r0_body.s36 = true
kernel_rfl bodyO36 : PRE_first_tail_x15_r0_body.S36.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S36.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr37 : bridgeOf PRE_first_tail_x15_r0_body.s37.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt36 : countersOkB PRE_first_tail_x15_r0_body.s36 PRE_first_tail_x15_r0_body.s37 = true
kernel_rfl bodyO37 : PRE_first_tail_x15_r0_body.S37.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S37.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc37 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s37 PRE_first_tail_x15_r0_body.S37) = fun _ _ => true
kernel_rfl bodyAcc38 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s38 PRE_first_tail_x15_r0_body.S38) = fun _ _ => true
kernel_rfl bodyBr39 : bridgeOf PRE_first_tail_x15_r0_body.s39.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt38 : isHalt PRE_first_tail_x15_r0_body.s38.ctl = false
kernel_rfl bodyTop39 : noRetBlock PRE_first_tail_x15_r0_body.s39 = true
kernel_rfl bodyCnt37 : countersOkB PRE_first_tail_x15_r0_body.s37 PRE_first_tail_x15_r0_body.s39 = true
kernel_rfl bodyO39 : PRE_first_tail_x15_r0_body.S39.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S39.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr40 : bridgeOf PRE_first_tail_x15_r0_body.s40.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt39 : countersOkB PRE_first_tail_x15_r0_body.s39 PRE_first_tail_x15_r0_body.s40 = true
kernel_rfl bodyO40 : PRE_first_tail_x15_r0_body.S40.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S40.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc40 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s40 PRE_first_tail_x15_r0_body.S40) = fun _ _ => true
kernel_rfl bodyAcc41 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s41 PRE_first_tail_x15_r0_body.S41) = fun _ _ => true
kernel_rfl bodyBr42 : bridgeOf PRE_first_tail_x15_r0_body.s42.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt41 : isHalt PRE_first_tail_x15_r0_body.s41.ctl = false
kernel_rfl bodyTop42 : noRetBlock PRE_first_tail_x15_r0_body.s42 = true
kernel_rfl bodyCnt40 : countersOkB PRE_first_tail_x15_r0_body.s40 PRE_first_tail_x15_r0_body.s42 = true
kernel_rfl bodyO42 : PRE_first_tail_x15_r0_body.S42.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S42.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr43 : bridgeOf PRE_first_tail_x15_r0_body.s43.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt42 : countersOkB PRE_first_tail_x15_r0_body.s42 PRE_first_tail_x15_r0_body.s43 = true
kernel_rfl bodyO43 : PRE_first_tail_x15_r0_body.S43.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S43.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc43 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s43 PRE_first_tail_x15_r0_body.S43) = fun _ _ => true
kernel_rfl bodyAcc44 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s44 PRE_first_tail_x15_r0_body.S44) = fun _ _ => true
kernel_rfl bodyBr45 : bridgeOf PRE_first_tail_x15_r0_body.s45.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt44 : isHalt PRE_first_tail_x15_r0_body.s44.ctl = false
kernel_rfl bodyTop45 : noRetBlock PRE_first_tail_x15_r0_body.s45 = true
kernel_rfl bodyCnt43 : countersOkB PRE_first_tail_x15_r0_body.s43 PRE_first_tail_x15_r0_body.s45 = true

theorem bodyGlue3 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨5284, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s30 PRE_first_tail_x15_r0_body.S30)
      (bodyCut NB T tk π i x0 bodyΘ ⟨5284, 46, 0, 18⟩ bodyM PRE_first_tail_x15_r0_body.s45 PRE_first_tail_x15_r0_body.S45) 15470 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc30 PRE_first_tail_x15_r0_body.bodyRunSeg8 bodyAcc32 bodyHalt32 PRE_first_tail_x15_r0_body.bodyStepA9 bodyTop33 (fun _ hm => bodyO30 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr30).trans bodyInactive0) (bodyBr33.trans bodyBr30.symm) bodyCnt30 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) PRE_first_tail_x15_r0_body.sizeA9 PRE_first_tail_x15_r0_body.sizeArgsA9 PRE_first_tail_x15_r0_body.sizeSymA9 PRE_first_tail_x15_r0_body.sizeMlxA9 PRE_first_tail_x15_r0_body.sizePayA9 PRE_first_tail_x15_r0_body.sizeTaA9 PRE_first_tail_x15_r0_body.sizeDecA9 PRE_first_tail_x15_r0_body.sizePreA9 PRE_first_tail_x15_r0_body.bodyPatchB9 (fun _ hm => bodyO33 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr33).trans bodyInactive0) (bodyBr34.trans bodyBr33.symm) bodyCnt33 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc34 PRE_first_tail_x15_r0_body.bodyRunSeg9 bodyAcc35 bodyHalt35 PRE_first_tail_x15_r0_body.bodyStepA10 bodyTop36 (fun _ hm => bodyO34 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr34).trans bodyInactive0) (bodyBr36.trans bodyBr34.symm) bodyCnt34 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) PRE_first_tail_x15_r0_body.sizeA10 PRE_first_tail_x15_r0_body.sizeArgsA10 PRE_first_tail_x15_r0_body.sizeSymA10 PRE_first_tail_x15_r0_body.sizeMlxA10 PRE_first_tail_x15_r0_body.sizePayA10 PRE_first_tail_x15_r0_body.sizeTaA10 PRE_first_tail_x15_r0_body.sizeDecA10 PRE_first_tail_x15_r0_body.sizePreA10 PRE_first_tail_x15_r0_body.bodyPatchB10 (fun _ hm => bodyO36 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr36).trans bodyInactive0) (bodyBr37.trans bodyBr36.symm) bodyCnt36 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc37 PRE_first_tail_x15_r0_body.bodyRunSeg10 bodyAcc38 bodyHalt38 PRE_first_tail_x15_r0_body.bodyStepA11 bodyTop39 (fun _ hm => bodyO37 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr37).trans bodyInactive0) (bodyBr39.trans bodyBr37.symm) bodyCnt37 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) PRE_first_tail_x15_r0_body.sizeA11 PRE_first_tail_x15_r0_body.sizeArgsA11 PRE_first_tail_x15_r0_body.sizeSymA11 PRE_first_tail_x15_r0_body.sizeMlxA11 PRE_first_tail_x15_r0_body.sizePayA11 PRE_first_tail_x15_r0_body.sizeTaA11 PRE_first_tail_x15_r0_body.sizeDecA11 PRE_first_tail_x15_r0_body.sizePreA11 PRE_first_tail_x15_r0_body.bodyPatchB11 (fun _ hm => bodyO39 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr39).trans bodyInactive0) (bodyBr40.trans bodyBr39.symm) bodyCnt39 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc40 PRE_first_tail_x15_r0_body.bodyRunSeg11 bodyAcc41 bodyHalt41 PRE_first_tail_x15_r0_body.bodyStepA12 bodyTop42 (fun _ hm => bodyO40 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr40).trans bodyInactive0) (bodyBr42.trans bodyBr40.symm) bodyCnt40 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) PRE_first_tail_x15_r0_body.sizeA12 PRE_first_tail_x15_r0_body.sizeArgsA12 PRE_first_tail_x15_r0_body.sizeSymA12 PRE_first_tail_x15_r0_body.sizeMlxA12 PRE_first_tail_x15_r0_body.sizePayA12 PRE_first_tail_x15_r0_body.sizeTaA12 PRE_first_tail_x15_r0_body.sizeDecA12 PRE_first_tail_x15_r0_body.sizePreA12 PRE_first_tail_x15_r0_body.bodyPatchB12 (fun _ hm => bodyO42 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr42).trans bodyInactive0) (bodyBr43.trans bodyBr42.symm) bodyCnt42 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨5284, 46, 0, 18⟩) bodyAcc43 PRE_first_tail_x15_r0_body.bodyRunSeg12 bodyAcc44 bodyHalt44 PRE_first_tail_x15_r0_body.bodyStepA13 bodyTop45 (fun _ hm => bodyO43 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr43).trans bodyInactive0) (bodyBr45.trans bodyBr43.symm) bodyCnt43 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
