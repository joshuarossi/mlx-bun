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

kernel_rfl bodyO490 : PRE_first_tail_x15_r0_body.S490.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S490.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr490 : bridgeOf PRE_first_tail_x15_r0_body.s490.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc490 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.S490) = fun _ _ => true
kernel_rfl bodyAcc492 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s492 PRE_first_tail_x15_r0_body.S492) = fun _ _ => true
kernel_rfl bodyBr493 : bridgeOf PRE_first_tail_x15_r0_body.s493.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt492 : isHalt PRE_first_tail_x15_r0_body.s492.ctl = false
kernel_rfl bodyTop493 : noRetBlock PRE_first_tail_x15_r0_body.s493 = true
kernel_rfl bodyCnt490 : countersOkB PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.s493 = true
kernel_rfl bodyO493 : PRE_first_tail_x15_r0_body.S493.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S493.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr494 : bridgeOf PRE_first_tail_x15_r0_body.s494.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt493 : countersOkB PRE_first_tail_x15_r0_body.s493 PRE_first_tail_x15_r0_body.s494 = true
kernel_rfl bodyO494 : PRE_first_tail_x15_r0_body.S494.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S494.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc494 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s494 PRE_first_tail_x15_r0_body.S494) = fun _ _ => true
kernel_rfl bodyAcc495 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s495 PRE_first_tail_x15_r0_body.S495) = fun _ _ => true
kernel_rfl bodyBr496 : bridgeOf PRE_first_tail_x15_r0_body.s496.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt495 : isHalt PRE_first_tail_x15_r0_body.s495.ctl = false
kernel_rfl bodyTop496 : noRetBlock PRE_first_tail_x15_r0_body.s496 = true
kernel_rfl bodyCnt494 : countersOkB PRE_first_tail_x15_r0_body.s494 PRE_first_tail_x15_r0_body.s496 = true
kernel_rfl bodyO496 : PRE_first_tail_x15_r0_body.S496.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S496.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr497 : bridgeOf PRE_first_tail_x15_r0_body.s497.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt496 : countersOkB PRE_first_tail_x15_r0_body.s496 PRE_first_tail_x15_r0_body.s497 = true
kernel_rfl bodyO497 : PRE_first_tail_x15_r0_body.S497.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S497.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc497 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s497 PRE_first_tail_x15_r0_body.S497) = fun _ _ => true
kernel_rfl bodyAcc498 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s498 PRE_first_tail_x15_r0_body.S498) = fun _ _ => true
kernel_rfl bodyBr499 : bridgeOf PRE_first_tail_x15_r0_body.s499.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt498 : isHalt PRE_first_tail_x15_r0_body.s498.ctl = false
kernel_rfl bodyTop499 : noRetBlock PRE_first_tail_x15_r0_body.s499 = true
kernel_rfl bodyCnt497 : countersOkB PRE_first_tail_x15_r0_body.s497 PRE_first_tail_x15_r0_body.s499 = true
kernel_rfl bodyO499 : PRE_first_tail_x15_r0_body.S499.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S499.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr500 : bridgeOf PRE_first_tail_x15_r0_body.s500.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt499 : countersOkB PRE_first_tail_x15_r0_body.s499 PRE_first_tail_x15_r0_body.s500 = true
kernel_rfl bodyO500 : PRE_first_tail_x15_r0_body.S500.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S500.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc500 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s500 PRE_first_tail_x15_r0_body.S500) = fun _ _ => true
kernel_rfl bodyAcc501 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s501 PRE_first_tail_x15_r0_body.S501) = fun _ _ => true
kernel_rfl bodyBr502 : bridgeOf PRE_first_tail_x15_r0_body.s502.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt501 : isHalt PRE_first_tail_x15_r0_body.s501.ctl = false
kernel_rfl bodyTop502 : noRetBlock PRE_first_tail_x15_r0_body.s502 = true
kernel_rfl bodyCnt500 : countersOkB PRE_first_tail_x15_r0_body.s500 PRE_first_tail_x15_r0_body.s502 = true
kernel_rfl bodyO502 : PRE_first_tail_x15_r0_body.S502.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S502.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr503 : bridgeOf PRE_first_tail_x15_r0_body.s503.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt502 : countersOkB PRE_first_tail_x15_r0_body.s502 PRE_first_tail_x15_r0_body.s503 = true
kernel_rfl bodyO503 : PRE_first_tail_x15_r0_body.S503.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S503.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc503 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s503 PRE_first_tail_x15_r0_body.S503) = fun _ _ => true
kernel_rfl bodyAcc504 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s504 PRE_first_tail_x15_r0_body.S504) = fun _ _ => true
kernel_rfl bodyBr505 : bridgeOf PRE_first_tail_x15_r0_body.s505.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt504 : isHalt PRE_first_tail_x15_r0_body.s504.ctl = false
kernel_rfl bodyTop505 : noRetBlock PRE_first_tail_x15_r0_body.s505 = true
kernel_rfl bodyCnt503 : countersOkB PRE_first_tail_x15_r0_body.s503 PRE_first_tail_x15_r0_body.s505 = true

theorem bodyGlue51 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20700, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.S490)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20700, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s505 PRE_first_tail_x15_r0_body.S505) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc490 PRE_first_tail_x15_r0_body.bodyRunSeg132 bodyAcc492 bodyHalt492 PRE_first_tail_x15_r0_body.bodyStepA133 bodyTop493 (fun _ hm => bodyO490 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr490).trans bodyInactive0) (bodyBr493.trans bodyBr490.symm) bodyCnt490 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA133 PRE_first_tail_x15_r0_body.sizeArgsA133 PRE_first_tail_x15_r0_body.sizeSymA133 PRE_first_tail_x15_r0_body.sizeMlxA133 PRE_first_tail_x15_r0_body.sizePayA133 PRE_first_tail_x15_r0_body.sizeTaA133 PRE_first_tail_x15_r0_body.sizeDecA133 PRE_first_tail_x15_r0_body.sizePreA133 PRE_first_tail_x15_r0_body.bodyPatchB133 (fun _ hm => bodyO493 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr493).trans bodyInactive0) (bodyBr494.trans bodyBr493.symm) bodyCnt493 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc494 PRE_first_tail_x15_r0_body.bodyRunSeg133 bodyAcc495 bodyHalt495 PRE_first_tail_x15_r0_body.bodyStepA134 bodyTop496 (fun _ hm => bodyO494 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr494).trans bodyInactive0) (bodyBr496.trans bodyBr494.symm) bodyCnt494 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA134 PRE_first_tail_x15_r0_body.sizeArgsA134 PRE_first_tail_x15_r0_body.sizeSymA134 PRE_first_tail_x15_r0_body.sizeMlxA134 PRE_first_tail_x15_r0_body.sizePayA134 PRE_first_tail_x15_r0_body.sizeTaA134 PRE_first_tail_x15_r0_body.sizeDecA134 PRE_first_tail_x15_r0_body.sizePreA134 PRE_first_tail_x15_r0_body.bodyPatchB134 (fun _ hm => bodyO496 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr496).trans bodyInactive0) (bodyBr497.trans bodyBr496.symm) bodyCnt496 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc497 PRE_first_tail_x15_r0_body.bodyRunSeg134 bodyAcc498 bodyHalt498 PRE_first_tail_x15_r0_body.bodyStepA135 bodyTop499 (fun _ hm => bodyO497 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr497).trans bodyInactive0) (bodyBr499.trans bodyBr497.symm) bodyCnt497 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA135 PRE_first_tail_x15_r0_body.sizeArgsA135 PRE_first_tail_x15_r0_body.sizeSymA135 PRE_first_tail_x15_r0_body.sizeMlxA135 PRE_first_tail_x15_r0_body.sizePayA135 PRE_first_tail_x15_r0_body.sizeTaA135 PRE_first_tail_x15_r0_body.sizeDecA135 PRE_first_tail_x15_r0_body.sizePreA135 PRE_first_tail_x15_r0_body.bodyPatchB135 (fun _ hm => bodyO499 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr499).trans bodyInactive0) (bodyBr500.trans bodyBr499.symm) bodyCnt499 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc500 PRE_first_tail_x15_r0_body.bodyRunSeg135 bodyAcc501 bodyHalt501 PRE_first_tail_x15_r0_body.bodyStepA136 bodyTop502 (fun _ hm => bodyO500 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr500).trans bodyInactive0) (bodyBr502.trans bodyBr500.symm) bodyCnt500 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA136 PRE_first_tail_x15_r0_body.sizeArgsA136 PRE_first_tail_x15_r0_body.sizeSymA136 PRE_first_tail_x15_r0_body.sizeMlxA136 PRE_first_tail_x15_r0_body.sizePayA136 PRE_first_tail_x15_r0_body.sizeTaA136 PRE_first_tail_x15_r0_body.sizeDecA136 PRE_first_tail_x15_r0_body.sizePreA136 PRE_first_tail_x15_r0_body.bodyPatchB136 (fun _ hm => bodyO502 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr502).trans bodyInactive0) (bodyBr503.trans bodyBr502.symm) bodyCnt502 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20700, 354, 0, 270⟩) bodyAcc503 PRE_first_tail_x15_r0_body.bodyRunSeg136 bodyAcc504 bodyHalt504 PRE_first_tail_x15_r0_body.bodyStepA137 bodyTop505 (fun _ hm => bodyO503 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr503).trans bodyInactive0) (bodyBr505.trans bodyBr503.symm) bodyCnt503 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
