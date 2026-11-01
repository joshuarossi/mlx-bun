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

kernel_rfl bodyO548 : PRE_first_tail_x15_r0_body.S548.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S548.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr548 : bridgeOf PRE_first_tail_x15_r0_body.s548.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc548 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s548 PRE_first_tail_x15_r0_body.S548) = fun _ _ => true
kernel_rfl bodyAcc550 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s550 PRE_first_tail_x15_r0_body.S550) = fun _ _ => true
kernel_rfl bodyBr551 : bridgeOf PRE_first_tail_x15_r0_body.s551.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt550 : isHalt PRE_first_tail_x15_r0_body.s550.ctl = false
kernel_rfl bodyTop551 : noRetBlock PRE_first_tail_x15_r0_body.s551 = true
kernel_rfl bodyCnt548 : countersOkB PRE_first_tail_x15_r0_body.s548 PRE_first_tail_x15_r0_body.s551 = true
kernel_rfl bodyO551 : PRE_first_tail_x15_r0_body.S551.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S551.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr552 : bridgeOf PRE_first_tail_x15_r0_body.s552.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt551 : countersOkB PRE_first_tail_x15_r0_body.s551 PRE_first_tail_x15_r0_body.s552 = true
kernel_rfl bodyO552 : PRE_first_tail_x15_r0_body.S552.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S552.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc552 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s552 PRE_first_tail_x15_r0_body.S552) = fun _ _ => true
kernel_rfl bodyAcc554 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s554 PRE_first_tail_x15_r0_body.S554) = fun _ _ => true
kernel_rfl bodyBr555 : bridgeOf PRE_first_tail_x15_r0_body.s555.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt554 : isHalt PRE_first_tail_x15_r0_body.s554.ctl = false
kernel_rfl bodyTop555 : noRetBlock PRE_first_tail_x15_r0_body.s555 = true
kernel_rfl bodyCnt552 : countersOkB PRE_first_tail_x15_r0_body.s552 PRE_first_tail_x15_r0_body.s555 = true
kernel_rfl bodyO555 : PRE_first_tail_x15_r0_body.S555.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S555.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr556 : bridgeOf PRE_first_tail_x15_r0_body.s556.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt555 : countersOkB PRE_first_tail_x15_r0_body.s555 PRE_first_tail_x15_r0_body.s556 = true
kernel_rfl bodyO556 : PRE_first_tail_x15_r0_body.S556.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S556.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc556 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s556 PRE_first_tail_x15_r0_body.S556) = fun _ _ => true
kernel_rfl bodyAcc557 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s557 PRE_first_tail_x15_r0_body.S557) = fun _ _ => true
kernel_rfl bodyBr558 : bridgeOf PRE_first_tail_x15_r0_body.s558.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt557 : isHalt PRE_first_tail_x15_r0_body.s557.ctl = false
kernel_rfl bodyTop558 : noRetBlock PRE_first_tail_x15_r0_body.s558 = true
kernel_rfl bodyCnt556 : countersOkB PRE_first_tail_x15_r0_body.s556 PRE_first_tail_x15_r0_body.s558 = true
kernel_rfl bodyO558 : PRE_first_tail_x15_r0_body.S558.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S558.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr559 : bridgeOf PRE_first_tail_x15_r0_body.s559.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt558 : countersOkB PRE_first_tail_x15_r0_body.s558 PRE_first_tail_x15_r0_body.s559 = true
kernel_rfl bodyO559 : PRE_first_tail_x15_r0_body.S559.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S559.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc559 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s559 PRE_first_tail_x15_r0_body.S559) = fun _ _ => true
kernel_rfl bodyAcc561 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s561 PRE_first_tail_x15_r0_body.S561) = fun _ _ => true
kernel_rfl bodyBr562 : bridgeOf PRE_first_tail_x15_r0_body.s562.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt561 : isHalt PRE_first_tail_x15_r0_body.s561.ctl = false
kernel_rfl bodyTop562 : noRetBlock PRE_first_tail_x15_r0_body.s562 = true
kernel_rfl bodyCnt559 : countersOkB PRE_first_tail_x15_r0_body.s559 PRE_first_tail_x15_r0_body.s562 = true

theorem bodyGlue57 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23040, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s548 PRE_first_tail_x15_r0_body.S548)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23040, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s562 PRE_first_tail_x15_r0_body.S562) 17025 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23040, 404, 0, 306⟩) bodyAcc548 PRE_first_tail_x15_r0_body.bodyRunSeg148 bodyAcc550 bodyHalt550 PRE_first_tail_x15_r0_body.bodyStepA149 bodyTop551 (fun _ hm => bodyO548 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr548).trans bodyInactive0) (bodyBr551.trans bodyBr548.symm) bodyCnt548 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23040, 404, 0, 306⟩) PRE_first_tail_x15_r0_body.sizeA149 PRE_first_tail_x15_r0_body.sizeArgsA149 PRE_first_tail_x15_r0_body.sizeSymA149 PRE_first_tail_x15_r0_body.sizeMlxA149 PRE_first_tail_x15_r0_body.sizePayA149 PRE_first_tail_x15_r0_body.sizeTaA149 PRE_first_tail_x15_r0_body.sizeDecA149 PRE_first_tail_x15_r0_body.sizePreA149 PRE_first_tail_x15_r0_body.bodyPatchB149 (fun _ hm => bodyO551 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr551).trans bodyInactive0) (bodyBr552.trans bodyBr551.symm) bodyCnt551 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23040, 404, 0, 306⟩) bodyAcc552 PRE_first_tail_x15_r0_body.bodyRunSeg149 bodyAcc554 bodyHalt554 PRE_first_tail_x15_r0_body.bodyStepA150 bodyTop555 (fun _ hm => bodyO552 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr552).trans bodyInactive0) (bodyBr555.trans bodyBr552.symm) bodyCnt552 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23040, 404, 0, 306⟩) PRE_first_tail_x15_r0_body.sizeA150 PRE_first_tail_x15_r0_body.sizeArgsA150 PRE_first_tail_x15_r0_body.sizeSymA150 PRE_first_tail_x15_r0_body.sizeMlxA150 PRE_first_tail_x15_r0_body.sizePayA150 PRE_first_tail_x15_r0_body.sizeTaA150 PRE_first_tail_x15_r0_body.sizeDecA150 PRE_first_tail_x15_r0_body.sizePreA150 PRE_first_tail_x15_r0_body.bodyPatchB150 (fun _ hm => bodyO555 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr555).trans bodyInactive0) (bodyBr556.trans bodyBr555.symm) bodyCnt555 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23040, 404, 0, 306⟩) bodyAcc556 PRE_first_tail_x15_r0_body.bodyRunSeg150 bodyAcc557 bodyHalt557 PRE_first_tail_x15_r0_body.bodyStepA151 bodyTop558 (fun _ hm => bodyO556 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr556).trans bodyInactive0) (bodyBr558.trans bodyBr556.symm) bodyCnt556 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23040, 404, 0, 306⟩) PRE_first_tail_x15_r0_body.sizeA151 PRE_first_tail_x15_r0_body.sizeArgsA151 PRE_first_tail_x15_r0_body.sizeSymA151 PRE_first_tail_x15_r0_body.sizeMlxA151 PRE_first_tail_x15_r0_body.sizePayA151 PRE_first_tail_x15_r0_body.sizeTaA151 PRE_first_tail_x15_r0_body.sizeDecA151 PRE_first_tail_x15_r0_body.sizePreA151 PRE_first_tail_x15_r0_body.bodyPatchB151 (fun _ hm => bodyO558 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr558).trans bodyInactive0) (bodyBr559.trans bodyBr558.symm) bodyCnt558 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23040, 404, 0, 306⟩) bodyAcc559 PRE_first_tail_x15_r0_body.bodyRunSeg151 bodyAcc561 bodyHalt561 PRE_first_tail_x15_r0_body.bodyStepA152 bodyTop562 (fun _ hm => bodyO559 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr559).trans bodyInactive0) (bodyBr562.trans bodyBr559.symm) bodyCnt559 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
