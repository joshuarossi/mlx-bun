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

kernel_rfl bodyO88 : PRE_first_tail_x15_r0_body.S88.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S88.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr88 : bridgeOf PRE_first_tail_x15_r0_body.s88.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc88 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s88 PRE_first_tail_x15_r0_body.S88) = fun _ _ => true
kernel_rfl bodyAcc90 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s90 PRE_first_tail_x15_r0_body.S90) = fun _ _ => true
kernel_rfl bodyBr91 : bridgeOf PRE_first_tail_x15_r0_body.s91.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt90 : isHalt PRE_first_tail_x15_r0_body.s90.ctl = false
kernel_rfl bodyTop91 : noRetBlock PRE_first_tail_x15_r0_body.s91 = true
kernel_rfl bodyCnt88 : countersOkB PRE_first_tail_x15_r0_body.s88 PRE_first_tail_x15_r0_body.s91 = true
kernel_rfl bodyO91 : PRE_first_tail_x15_r0_body.S91.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S91.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr92 : bridgeOf PRE_first_tail_x15_r0_body.s92.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt91 : countersOkB PRE_first_tail_x15_r0_body.s91 PRE_first_tail_x15_r0_body.s92 = true
kernel_rfl bodyO92 : PRE_first_tail_x15_r0_body.S92.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S92.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc92 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s92 PRE_first_tail_x15_r0_body.S92) = fun _ _ => true
kernel_rfl bodyAcc94 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s94 PRE_first_tail_x15_r0_body.S94) = fun _ _ => true
kernel_rfl bodyBr95 : bridgeOf PRE_first_tail_x15_r0_body.s95.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt94 : isHalt PRE_first_tail_x15_r0_body.s94.ctl = false
kernel_rfl bodyTop95 : noRetBlock PRE_first_tail_x15_r0_body.s95 = true
kernel_rfl bodyCnt92 : countersOkB PRE_first_tail_x15_r0_body.s92 PRE_first_tail_x15_r0_body.s95 = true
kernel_rfl bodyO95 : PRE_first_tail_x15_r0_body.S95.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S95.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr96 : bridgeOf PRE_first_tail_x15_r0_body.s96.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt95 : countersOkB PRE_first_tail_x15_r0_body.s95 PRE_first_tail_x15_r0_body.s96 = true
kernel_rfl bodyO96 : PRE_first_tail_x15_r0_body.S96.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S96.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc96 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s96 PRE_first_tail_x15_r0_body.S96) = fun _ _ => true
kernel_rfl bodyAcc97 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s97 PRE_first_tail_x15_r0_body.S97) = fun _ _ => true
kernel_rfl bodyBr98 : bridgeOf PRE_first_tail_x15_r0_body.s98.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt97 : isHalt PRE_first_tail_x15_r0_body.s97.ctl = false
kernel_rfl bodyTop98 : noRetBlock PRE_first_tail_x15_r0_body.s98 = true
kernel_rfl bodyCnt96 : countersOkB PRE_first_tail_x15_r0_body.s96 PRE_first_tail_x15_r0_body.s98 = true
kernel_rfl bodyO98 : PRE_first_tail_x15_r0_body.S98.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S98.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr99 : bridgeOf PRE_first_tail_x15_r0_body.s99.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt98 : countersOkB PRE_first_tail_x15_r0_body.s98 PRE_first_tail_x15_r0_body.s99 = true
kernel_rfl bodyO99 : PRE_first_tail_x15_r0_body.S99.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S99.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc99 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s99 PRE_first_tail_x15_r0_body.S99) = fun _ _ => true
kernel_rfl bodyAcc101 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s101 PRE_first_tail_x15_r0_body.S101) = fun _ _ => true
kernel_rfl bodyBr102 : bridgeOf PRE_first_tail_x15_r0_body.s102.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt101 : isHalt PRE_first_tail_x15_r0_body.s101.ctl = false
kernel_rfl bodyTop102 : noRetBlock PRE_first_tail_x15_r0_body.s102 = true
kernel_rfl bodyCnt99 : countersOkB PRE_first_tail_x15_r0_body.s99 PRE_first_tail_x15_r0_body.s102 = true

theorem bodyGlue9 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7606, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s88 PRE_first_tail_x15_r0_body.S88)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7606, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s102 PRE_first_tail_x15_r0_body.S102) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) bodyAcc88 PRE_first_tail_x15_r0_body.bodyRunSeg24 bodyAcc90 bodyHalt90 PRE_first_tail_x15_r0_body.bodyStepA25 bodyTop91 (fun _ hm => bodyO88 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr88).trans bodyInactive0) (bodyBr91.trans bodyBr88.symm) bodyCnt88 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) PRE_first_tail_x15_r0_body.sizeA25 PRE_first_tail_x15_r0_body.sizeArgsA25 PRE_first_tail_x15_r0_body.sizeSymA25 PRE_first_tail_x15_r0_body.sizeMlxA25 PRE_first_tail_x15_r0_body.sizePayA25 PRE_first_tail_x15_r0_body.sizeTaA25 PRE_first_tail_x15_r0_body.sizeDecA25 PRE_first_tail_x15_r0_body.sizePreA25 PRE_first_tail_x15_r0_body.bodyPatchB25 (fun _ hm => bodyO91 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr91).trans bodyInactive0) (bodyBr92.trans bodyBr91.symm) bodyCnt91 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) bodyAcc92 PRE_first_tail_x15_r0_body.bodyRunSeg25 bodyAcc94 bodyHalt94 PRE_first_tail_x15_r0_body.bodyStepA26 bodyTop95 (fun _ hm => bodyO92 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr92).trans bodyInactive0) (bodyBr95.trans bodyBr92.symm) bodyCnt92 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) PRE_first_tail_x15_r0_body.sizeA26 PRE_first_tail_x15_r0_body.sizeArgsA26 PRE_first_tail_x15_r0_body.sizeSymA26 PRE_first_tail_x15_r0_body.sizeMlxA26 PRE_first_tail_x15_r0_body.sizePayA26 PRE_first_tail_x15_r0_body.sizeTaA26 PRE_first_tail_x15_r0_body.sizeDecA26 PRE_first_tail_x15_r0_body.sizePreA26 PRE_first_tail_x15_r0_body.bodyPatchB26 (fun _ hm => bodyO95 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr95).trans bodyInactive0) (bodyBr96.trans bodyBr95.symm) bodyCnt95 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) bodyAcc96 PRE_first_tail_x15_r0_body.bodyRunSeg26 bodyAcc97 bodyHalt97 PRE_first_tail_x15_r0_body.bodyStepA27 bodyTop98 (fun _ hm => bodyO96 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr96).trans bodyInactive0) (bodyBr98.trans bodyBr96.symm) bodyCnt96 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) PRE_first_tail_x15_r0_body.sizeA27 PRE_first_tail_x15_r0_body.sizeArgsA27 PRE_first_tail_x15_r0_body.sizeSymA27 PRE_first_tail_x15_r0_body.sizeMlxA27 PRE_first_tail_x15_r0_body.sizePayA27 PRE_first_tail_x15_r0_body.sizeTaA27 PRE_first_tail_x15_r0_body.sizeDecA27 PRE_first_tail_x15_r0_body.sizePreA27 PRE_first_tail_x15_r0_body.bodyPatchB27 (fun _ hm => bodyO98 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr98).trans bodyInactive0) (bodyBr99.trans bodyBr98.symm) bodyCnt98 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7606, 96, 0, 54⟩) bodyAcc99 PRE_first_tail_x15_r0_body.bodyRunSeg27 bodyAcc101 bodyHalt101 PRE_first_tail_x15_r0_body.bodyStepA28 bodyTop102 (fun _ hm => bodyO99 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr99).trans bodyInactive0) (bodyBr102.trans bodyBr99.symm) bodyCnt99 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
