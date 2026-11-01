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

kernel_rfl bodyO1468 : PRE_first_tail_x15_r0_body.S1468.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1468.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1468 : bridgeOf PRE_first_tail_x15_r0_body.s1468.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1468 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1468 PRE_first_tail_x15_r0_body.S1468) = fun _ _ => true
kernel_rfl bodyAcc1470 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1470 PRE_first_tail_x15_r0_body.S1470) = fun _ _ => true
kernel_rfl bodyBr1471 : bridgeOf PRE_first_tail_x15_r0_body.s1471.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1470 : isHalt PRE_first_tail_x15_r0_body.s1470.ctl = false
kernel_rfl bodyTop1471 : noRetBlock PRE_first_tail_x15_r0_body.s1471 = true
kernel_rfl bodyCnt1468 : countersOkB PRE_first_tail_x15_r0_body.s1468 PRE_first_tail_x15_r0_body.s1471 = true
kernel_rfl bodyO1471 : PRE_first_tail_x15_r0_body.S1471.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1471.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1472 : bridgeOf PRE_first_tail_x15_r0_body.s1472.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1471 : countersOkB PRE_first_tail_x15_r0_body.s1471 PRE_first_tail_x15_r0_body.s1472 = true
kernel_rfl bodyO1472 : PRE_first_tail_x15_r0_body.S1472.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1472.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1472 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1472 PRE_first_tail_x15_r0_body.S1472) = fun _ _ => true
kernel_rfl bodyAcc1474 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1474 PRE_first_tail_x15_r0_body.S1474) = fun _ _ => true
kernel_rfl bodyBr1475 : bridgeOf PRE_first_tail_x15_r0_body.s1475.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1474 : isHalt PRE_first_tail_x15_r0_body.s1474.ctl = false
kernel_rfl bodyTop1475 : noRetBlock PRE_first_tail_x15_r0_body.s1475 = true
kernel_rfl bodyCnt1472 : countersOkB PRE_first_tail_x15_r0_body.s1472 PRE_first_tail_x15_r0_body.s1475 = true
kernel_rfl bodyO1475 : PRE_first_tail_x15_r0_body.S1475.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1475.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1476 : bridgeOf PRE_first_tail_x15_r0_body.s1476.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1475 : countersOkB PRE_first_tail_x15_r0_body.s1475 PRE_first_tail_x15_r0_body.s1476 = true
kernel_rfl bodyO1476 : PRE_first_tail_x15_r0_body.S1476.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1476.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1476 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1476 PRE_first_tail_x15_r0_body.S1476) = fun _ _ => true
kernel_rfl bodyAcc1477 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1477 PRE_first_tail_x15_r0_body.S1477) = fun _ _ => true
kernel_rfl bodyBr1478 : bridgeOf PRE_first_tail_x15_r0_body.s1478.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1477 : isHalt PRE_first_tail_x15_r0_body.s1477.ctl = false
kernel_rfl bodyTop1478 : noRetBlock PRE_first_tail_x15_r0_body.s1478 = true
kernel_rfl bodyCnt1476 : countersOkB PRE_first_tail_x15_r0_body.s1476 PRE_first_tail_x15_r0_body.s1478 = true
kernel_rfl bodyO1478 : PRE_first_tail_x15_r0_body.S1478.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1478.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1479 : bridgeOf PRE_first_tail_x15_r0_body.s1479.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1478 : countersOkB PRE_first_tail_x15_r0_body.s1478 PRE_first_tail_x15_r0_body.s1479 = true
kernel_rfl bodyO1479 : PRE_first_tail_x15_r0_body.S1479.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1479.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1479 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1479 PRE_first_tail_x15_r0_body.S1479) = fun _ _ => true
kernel_rfl bodyAcc1481 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1481 PRE_first_tail_x15_r0_body.S1481) = fun _ _ => true
kernel_rfl bodyBr1482 : bridgeOf PRE_first_tail_x15_r0_body.s1482.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1481 : isHalt PRE_first_tail_x15_r0_body.s1481.ctl = false
kernel_rfl bodyTop1482 : noRetBlock PRE_first_tail_x15_r0_body.s1482 = true
kernel_rfl bodyCnt1479 : countersOkB PRE_first_tail_x15_r0_body.s1479 PRE_first_tail_x15_r0_body.s1482 = true

theorem bodyGlue153 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53881, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1468 PRE_first_tail_x15_r0_body.S1468)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53881, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1482 PRE_first_tail_x15_r0_body.S1482) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53881, 1020, 0, 810⟩) bodyAcc1468 PRE_first_tail_x15_r0_body.bodyRunSeg396 bodyAcc1470 bodyHalt1470 PRE_first_tail_x15_r0_body.bodyStepA397 bodyTop1471 (fun _ hm => bodyO1468 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1468).trans bodyInactive0) (bodyBr1471.trans bodyBr1468.symm) bodyCnt1468 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53881, 1020, 0, 810⟩) PRE_first_tail_x15_r0_body.sizeA397 PRE_first_tail_x15_r0_body.sizeArgsA397 PRE_first_tail_x15_r0_body.sizeSymA397 PRE_first_tail_x15_r0_body.sizeMlxA397 PRE_first_tail_x15_r0_body.sizePayA397 PRE_first_tail_x15_r0_body.sizeTaA397 PRE_first_tail_x15_r0_body.sizeDecA397 PRE_first_tail_x15_r0_body.sizePreA397 PRE_first_tail_x15_r0_body.bodyPatchB397 (fun _ hm => bodyO1471 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1471).trans bodyInactive0) (bodyBr1472.trans bodyBr1471.symm) bodyCnt1471 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53881, 1020, 0, 810⟩) bodyAcc1472 PRE_first_tail_x15_r0_body.bodyRunSeg397 bodyAcc1474 bodyHalt1474 PRE_first_tail_x15_r0_body.bodyStepA398 bodyTop1475 (fun _ hm => bodyO1472 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1472).trans bodyInactive0) (bodyBr1475.trans bodyBr1472.symm) bodyCnt1472 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53881, 1020, 0, 810⟩) PRE_first_tail_x15_r0_body.sizeA398 PRE_first_tail_x15_r0_body.sizeArgsA398 PRE_first_tail_x15_r0_body.sizeSymA398 PRE_first_tail_x15_r0_body.sizeMlxA398 PRE_first_tail_x15_r0_body.sizePayA398 PRE_first_tail_x15_r0_body.sizeTaA398 PRE_first_tail_x15_r0_body.sizeDecA398 PRE_first_tail_x15_r0_body.sizePreA398 PRE_first_tail_x15_r0_body.bodyPatchB398 (fun _ hm => bodyO1475 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1475).trans bodyInactive0) (bodyBr1476.trans bodyBr1475.symm) bodyCnt1475 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53881, 1020, 0, 810⟩) bodyAcc1476 PRE_first_tail_x15_r0_body.bodyRunSeg398 bodyAcc1477 bodyHalt1477 PRE_first_tail_x15_r0_body.bodyStepA399 bodyTop1478 (fun _ hm => bodyO1476 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1476).trans bodyInactive0) (bodyBr1478.trans bodyBr1476.symm) bodyCnt1476 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53881, 1020, 0, 810⟩) PRE_first_tail_x15_r0_body.sizeA399 PRE_first_tail_x15_r0_body.sizeArgsA399 PRE_first_tail_x15_r0_body.sizeSymA399 PRE_first_tail_x15_r0_body.sizeMlxA399 PRE_first_tail_x15_r0_body.sizePayA399 PRE_first_tail_x15_r0_body.sizeTaA399 PRE_first_tail_x15_r0_body.sizeDecA399 PRE_first_tail_x15_r0_body.sizePreA399 PRE_first_tail_x15_r0_body.bodyPatchB399 (fun _ hm => bodyO1478 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1478).trans bodyInactive0) (bodyBr1479.trans bodyBr1478.symm) bodyCnt1478 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53881, 1020, 0, 810⟩) bodyAcc1479 PRE_first_tail_x15_r0_body.bodyRunSeg399 bodyAcc1481 bodyHalt1481 PRE_first_tail_x15_r0_body.bodyStepA400 bodyTop1482 (fun _ hm => bodyO1479 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1479).trans bodyInactive0) (bodyBr1482.trans bodyBr1479.symm) bodyCnt1479 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
