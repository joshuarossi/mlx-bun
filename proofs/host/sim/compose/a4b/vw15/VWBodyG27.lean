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

kernel_rfl bodyO260 : PRE_first_tail_x15_r0_body.S260.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S260.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr260 : bridgeOf PRE_first_tail_x15_r0_body.s260.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc260 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s260 PRE_first_tail_x15_r0_body.S260) = fun _ _ => true
kernel_rfl bodyAcc262 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s262 PRE_first_tail_x15_r0_body.S262) = fun _ _ => true
kernel_rfl bodyBr263 : bridgeOf PRE_first_tail_x15_r0_body.s263.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt262 : isHalt PRE_first_tail_x15_r0_body.s262.ctl = false
kernel_rfl bodyTop263 : noRetBlock PRE_first_tail_x15_r0_body.s263 = true
kernel_rfl bodyCnt260 : countersOkB PRE_first_tail_x15_r0_body.s260 PRE_first_tail_x15_r0_body.s263 = true
kernel_rfl bodyO263 : PRE_first_tail_x15_r0_body.S263.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S263.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr264 : bridgeOf PRE_first_tail_x15_r0_body.s264.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt263 : countersOkB PRE_first_tail_x15_r0_body.s263 PRE_first_tail_x15_r0_body.s264 = true
kernel_rfl bodyO264 : PRE_first_tail_x15_r0_body.S264.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S264.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc264 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s264 PRE_first_tail_x15_r0_body.S264) = fun _ _ => true
kernel_rfl bodyAcc265 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s265 PRE_first_tail_x15_r0_body.S265) = fun _ _ => true
kernel_rfl bodyBr266 : bridgeOf PRE_first_tail_x15_r0_body.s266.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt265 : isHalt PRE_first_tail_x15_r0_body.s265.ctl = false
kernel_rfl bodyTop266 : noRetBlock PRE_first_tail_x15_r0_body.s266 = true
kernel_rfl bodyCnt264 : countersOkB PRE_first_tail_x15_r0_body.s264 PRE_first_tail_x15_r0_body.s266 = true
kernel_rfl bodyO266 : PRE_first_tail_x15_r0_body.S266.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S266.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr267 : bridgeOf PRE_first_tail_x15_r0_body.s267.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt266 : countersOkB PRE_first_tail_x15_r0_body.s266 PRE_first_tail_x15_r0_body.s267 = true
kernel_rfl bodyO267 : PRE_first_tail_x15_r0_body.S267.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S267.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc267 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s267 PRE_first_tail_x15_r0_body.S267) = fun _ _ => true
kernel_rfl bodyAcc268 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s268 PRE_first_tail_x15_r0_body.S268) = fun _ _ => true
kernel_rfl bodyBr269 : bridgeOf PRE_first_tail_x15_r0_body.s269.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt268 : isHalt PRE_first_tail_x15_r0_body.s268.ctl = false
kernel_rfl bodyTop269 : noRetBlock PRE_first_tail_x15_r0_body.s269 = true
kernel_rfl bodyCnt267 : countersOkB PRE_first_tail_x15_r0_body.s267 PRE_first_tail_x15_r0_body.s269 = true
kernel_rfl bodyO269 : PRE_first_tail_x15_r0_body.S269.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S269.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr270 : bridgeOf PRE_first_tail_x15_r0_body.s270.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt269 : countersOkB PRE_first_tail_x15_r0_body.s269 PRE_first_tail_x15_r0_body.s270 = true
kernel_rfl bodyO270 : PRE_first_tail_x15_r0_body.S270.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S270.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc270 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s270 PRE_first_tail_x15_r0_body.S270) = fun _ _ => true
kernel_rfl bodyAcc271 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s271 PRE_first_tail_x15_r0_body.S271) = fun _ _ => true
kernel_rfl bodyBr272 : bridgeOf PRE_first_tail_x15_r0_body.s272.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt271 : isHalt PRE_first_tail_x15_r0_body.s271.ctl = false
kernel_rfl bodyTop272 : noRetBlock PRE_first_tail_x15_r0_body.s272 = true
kernel_rfl bodyCnt270 : countersOkB PRE_first_tail_x15_r0_body.s270 PRE_first_tail_x15_r0_body.s272 = true
kernel_rfl bodyO272 : PRE_first_tail_x15_r0_body.S272.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S272.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr273 : bridgeOf PRE_first_tail_x15_r0_body.s273.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt272 : countersOkB PRE_first_tail_x15_r0_body.s272 PRE_first_tail_x15_r0_body.s273 = true
kernel_rfl bodyO273 : PRE_first_tail_x15_r0_body.S273.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S273.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc273 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s273 PRE_first_tail_x15_r0_body.S273) = fun _ _ => true
kernel_rfl bodyAcc274 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s274 PRE_first_tail_x15_r0_body.S274) = fun _ _ => true
kernel_rfl bodyBr275 : bridgeOf PRE_first_tail_x15_r0_body.s275.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt274 : isHalt PRE_first_tail_x15_r0_body.s274.ctl = false
kernel_rfl bodyTop275 : noRetBlock PRE_first_tail_x15_r0_body.s275 = true
kernel_rfl bodyCnt273 : countersOkB PRE_first_tail_x15_r0_body.s273 PRE_first_tail_x15_r0_body.s275 = true

theorem bodyGlue27 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12974, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s260 PRE_first_tail_x15_r0_body.S260)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12974, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s275 PRE_first_tail_x15_r0_body.S275) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc260 PRE_first_tail_x15_r0_body.bodyRunSeg70 bodyAcc262 bodyHalt262 PRE_first_tail_x15_r0_body.bodyStepA71 bodyTop263 (fun _ hm => bodyO260 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr260).trans bodyInactive0) (bodyBr263.trans bodyBr260.symm) bodyCnt260 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) PRE_first_tail_x15_r0_body.sizeA71 PRE_first_tail_x15_r0_body.sizeArgsA71 PRE_first_tail_x15_r0_body.sizeSymA71 PRE_first_tail_x15_r0_body.sizeMlxA71 PRE_first_tail_x15_r0_body.sizePayA71 PRE_first_tail_x15_r0_body.sizeTaA71 PRE_first_tail_x15_r0_body.sizeDecA71 PRE_first_tail_x15_r0_body.sizePreA71 PRE_first_tail_x15_r0_body.bodyPatchB71 (fun _ hm => bodyO263 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr263).trans bodyInactive0) (bodyBr264.trans bodyBr263.symm) bodyCnt263 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc264 PRE_first_tail_x15_r0_body.bodyRunSeg71 bodyAcc265 bodyHalt265 PRE_first_tail_x15_r0_body.bodyStepA72 bodyTop266 (fun _ hm => bodyO264 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr264).trans bodyInactive0) (bodyBr266.trans bodyBr264.symm) bodyCnt264 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) PRE_first_tail_x15_r0_body.sizeA72 PRE_first_tail_x15_r0_body.sizeArgsA72 PRE_first_tail_x15_r0_body.sizeSymA72 PRE_first_tail_x15_r0_body.sizeMlxA72 PRE_first_tail_x15_r0_body.sizePayA72 PRE_first_tail_x15_r0_body.sizeTaA72 PRE_first_tail_x15_r0_body.sizeDecA72 PRE_first_tail_x15_r0_body.sizePreA72 PRE_first_tail_x15_r0_body.bodyPatchB72 (fun _ hm => bodyO266 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr266).trans bodyInactive0) (bodyBr267.trans bodyBr266.symm) bodyCnt266 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc267 PRE_first_tail_x15_r0_body.bodyRunSeg72 bodyAcc268 bodyHalt268 PRE_first_tail_x15_r0_body.bodyStepA73 bodyTop269 (fun _ hm => bodyO267 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr267).trans bodyInactive0) (bodyBr269.trans bodyBr267.symm) bodyCnt267 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) PRE_first_tail_x15_r0_body.sizeA73 PRE_first_tail_x15_r0_body.sizeArgsA73 PRE_first_tail_x15_r0_body.sizeSymA73 PRE_first_tail_x15_r0_body.sizeMlxA73 PRE_first_tail_x15_r0_body.sizePayA73 PRE_first_tail_x15_r0_body.sizeTaA73 PRE_first_tail_x15_r0_body.sizeDecA73 PRE_first_tail_x15_r0_body.sizePreA73 PRE_first_tail_x15_r0_body.bodyPatchB73 (fun _ hm => bodyO269 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr269).trans bodyInactive0) (bodyBr270.trans bodyBr269.symm) bodyCnt269 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc270 PRE_first_tail_x15_r0_body.bodyRunSeg73 bodyAcc271 bodyHalt271 PRE_first_tail_x15_r0_body.bodyStepA74 bodyTop272 (fun _ hm => bodyO270 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr270).trans bodyInactive0) (bodyBr272.trans bodyBr270.symm) bodyCnt270 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) PRE_first_tail_x15_r0_body.sizeA74 PRE_first_tail_x15_r0_body.sizeArgsA74 PRE_first_tail_x15_r0_body.sizeSymA74 PRE_first_tail_x15_r0_body.sizeMlxA74 PRE_first_tail_x15_r0_body.sizePayA74 PRE_first_tail_x15_r0_body.sizeTaA74 PRE_first_tail_x15_r0_body.sizeDecA74 PRE_first_tail_x15_r0_body.sizePreA74 PRE_first_tail_x15_r0_body.bodyPatchB74 (fun _ hm => bodyO272 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr272).trans bodyInactive0) (bodyBr273.trans bodyBr272.symm) bodyCnt272 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12974, 200, 0, 144⟩) bodyAcc273 PRE_first_tail_x15_r0_body.bodyRunSeg74 bodyAcc274 bodyHalt274 PRE_first_tail_x15_r0_body.bodyStepA75 bodyTop275 (fun _ hm => bodyO273 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr273).trans bodyInactive0) (bodyBr275.trans bodyBr273.symm) bodyCnt273 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
