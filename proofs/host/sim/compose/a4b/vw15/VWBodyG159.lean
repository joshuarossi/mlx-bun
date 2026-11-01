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

kernel_rfl bodyO1525 : PRE_first_tail_x15_r0_body.S1525.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1525.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1525 : bridgeOf PRE_first_tail_x15_r0_body.s1525.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1525 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1525 PRE_first_tail_x15_r0_body.S1525) = fun _ _ => true
kernel_rfl bodyAcc1527 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1527 PRE_first_tail_x15_r0_body.S1527) = fun _ _ => true
kernel_rfl bodyBr1528 : bridgeOf PRE_first_tail_x15_r0_body.s1528.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1527 : isHalt PRE_first_tail_x15_r0_body.s1527.ctl = false
kernel_rfl bodyTop1528 : noRetBlock PRE_first_tail_x15_r0_body.s1528 = true
kernel_rfl bodyCnt1525 : countersOkB PRE_first_tail_x15_r0_body.s1525 PRE_first_tail_x15_r0_body.s1528 = true
kernel_rfl bodyO1528 : PRE_first_tail_x15_r0_body.S1528.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1528.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1529 : bridgeOf PRE_first_tail_x15_r0_body.s1529.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1528 : countersOkB PRE_first_tail_x15_r0_body.s1528 PRE_first_tail_x15_r0_body.s1529 = true
kernel_rfl bodyO1529 : PRE_first_tail_x15_r0_body.S1529.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1529.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1529 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1529 PRE_first_tail_x15_r0_body.S1529) = fun _ _ => true
kernel_rfl bodyAcc1530 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1530 PRE_first_tail_x15_r0_body.S1530) = fun _ _ => true
kernel_rfl bodyBr1531 : bridgeOf PRE_first_tail_x15_r0_body.s1531.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1530 : isHalt PRE_first_tail_x15_r0_body.s1530.ctl = false
kernel_rfl bodyTop1531 : noRetBlock PRE_first_tail_x15_r0_body.s1531 = true
kernel_rfl bodyCnt1529 : countersOkB PRE_first_tail_x15_r0_body.s1529 PRE_first_tail_x15_r0_body.s1531 = true
kernel_rfl bodyO1531 : PRE_first_tail_x15_r0_body.S1531.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1531.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1532 : bridgeOf PRE_first_tail_x15_r0_body.s1532.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1531 : countersOkB PRE_first_tail_x15_r0_body.s1531 PRE_first_tail_x15_r0_body.s1532 = true
kernel_rfl bodyO1532 : PRE_first_tail_x15_r0_body.S1532.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1532.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1532 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1532 PRE_first_tail_x15_r0_body.S1532) = fun _ _ => true
kernel_rfl bodyAcc1533 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1533 PRE_first_tail_x15_r0_body.S1533) = fun _ _ => true
kernel_rfl bodyBr1534 : bridgeOf PRE_first_tail_x15_r0_body.s1534.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1533 : isHalt PRE_first_tail_x15_r0_body.s1533.ctl = false
kernel_rfl bodyTop1534 : noRetBlock PRE_first_tail_x15_r0_body.s1534 = true
kernel_rfl bodyCnt1532 : countersOkB PRE_first_tail_x15_r0_body.s1532 PRE_first_tail_x15_r0_body.s1534 = true
kernel_rfl bodyO1534 : PRE_first_tail_x15_r0_body.S1534.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1534.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1535 : bridgeOf PRE_first_tail_x15_r0_body.s1535.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1534 : countersOkB PRE_first_tail_x15_r0_body.s1534 PRE_first_tail_x15_r0_body.s1535 = true
kernel_rfl bodyO1535 : PRE_first_tail_x15_r0_body.S1535.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1535.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1535 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1535 PRE_first_tail_x15_r0_body.S1535) = fun _ _ => true
kernel_rfl bodyAcc1536 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1536 PRE_first_tail_x15_r0_body.S1536) = fun _ _ => true
kernel_rfl bodyBr1537 : bridgeOf PRE_first_tail_x15_r0_body.s1537.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1536 : isHalt PRE_first_tail_x15_r0_body.s1536.ctl = false
kernel_rfl bodyTop1537 : noRetBlock PRE_first_tail_x15_r0_body.s1537 = true
kernel_rfl bodyCnt1535 : countersOkB PRE_first_tail_x15_r0_body.s1535 PRE_first_tail_x15_r0_body.s1537 = true
kernel_rfl bodyO1537 : PRE_first_tail_x15_r0_body.S1537.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1537.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1538 : bridgeOf PRE_first_tail_x15_r0_body.s1538.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1537 : countersOkB PRE_first_tail_x15_r0_body.s1537 PRE_first_tail_x15_r0_body.s1538 = true
kernel_rfl bodyO1538 : PRE_first_tail_x15_r0_body.S1538.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1538.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1538 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1538 PRE_first_tail_x15_r0_body.S1538) = fun _ _ => true
kernel_rfl bodyAcc1539 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1539 PRE_first_tail_x15_r0_body.S1539) = fun _ _ => true
kernel_rfl bodyBr1540 : bridgeOf PRE_first_tail_x15_r0_body.s1540.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1539 : isHalt PRE_first_tail_x15_r0_body.s1539.ctl = false
kernel_rfl bodyTop1540 : noRetBlock PRE_first_tail_x15_r0_body.s1540 = true
kernel_rfl bodyCnt1538 : countersOkB PRE_first_tail_x15_r0_body.s1538 PRE_first_tail_x15_r0_body.s1540 = true

theorem bodyGlue159 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨55404, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1525 PRE_first_tail_x15_r0_body.S1525)
      (bodyCut NB T tk π i x0 bodyΘ ⟨55404, 1047, 0, 837⟩ bodyM PRE_first_tail_x15_r0_body.s1540 PRE_first_tail_x15_r0_body.S1540) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55404, 1047, 0, 837⟩) bodyAcc1525 PRE_first_tail_x15_r0_body.bodyRunSeg411 bodyAcc1527 bodyHalt1527 PRE_first_tail_x15_r0_body.bodyStepA412 bodyTop1528 (fun _ hm => bodyO1525 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1525).trans bodyInactive0) (bodyBr1528.trans bodyBr1525.symm) bodyCnt1525 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55404, 1047, 0, 837⟩) PRE_first_tail_x15_r0_body.sizeA412 PRE_first_tail_x15_r0_body.sizeArgsA412 PRE_first_tail_x15_r0_body.sizeSymA412 PRE_first_tail_x15_r0_body.sizeMlxA412 PRE_first_tail_x15_r0_body.sizePayA412 PRE_first_tail_x15_r0_body.sizeTaA412 PRE_first_tail_x15_r0_body.sizeDecA412 PRE_first_tail_x15_r0_body.sizePreA412 PRE_first_tail_x15_r0_body.bodyPatchB412 (fun _ hm => bodyO1528 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1528).trans bodyInactive0) (bodyBr1529.trans bodyBr1528.symm) bodyCnt1528 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55404, 1047, 0, 837⟩) bodyAcc1529 PRE_first_tail_x15_r0_body.bodyRunSeg412 bodyAcc1530 bodyHalt1530 PRE_first_tail_x15_r0_body.bodyStepA413 bodyTop1531 (fun _ hm => bodyO1529 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1529).trans bodyInactive0) (bodyBr1531.trans bodyBr1529.symm) bodyCnt1529 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55404, 1047, 0, 837⟩) PRE_first_tail_x15_r0_body.sizeA413 PRE_first_tail_x15_r0_body.sizeArgsA413 PRE_first_tail_x15_r0_body.sizeSymA413 PRE_first_tail_x15_r0_body.sizeMlxA413 PRE_first_tail_x15_r0_body.sizePayA413 PRE_first_tail_x15_r0_body.sizeTaA413 PRE_first_tail_x15_r0_body.sizeDecA413 PRE_first_tail_x15_r0_body.sizePreA413 PRE_first_tail_x15_r0_body.bodyPatchB413 (fun _ hm => bodyO1531 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1531).trans bodyInactive0) (bodyBr1532.trans bodyBr1531.symm) bodyCnt1531 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55404, 1047, 0, 837⟩) bodyAcc1532 PRE_first_tail_x15_r0_body.bodyRunSeg413 bodyAcc1533 bodyHalt1533 PRE_first_tail_x15_r0_body.bodyStepA414 bodyTop1534 (fun _ hm => bodyO1532 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1532).trans bodyInactive0) (bodyBr1534.trans bodyBr1532.symm) bodyCnt1532 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55404, 1047, 0, 837⟩) PRE_first_tail_x15_r0_body.sizeA414 PRE_first_tail_x15_r0_body.sizeArgsA414 PRE_first_tail_x15_r0_body.sizeSymA414 PRE_first_tail_x15_r0_body.sizeMlxA414 PRE_first_tail_x15_r0_body.sizePayA414 PRE_first_tail_x15_r0_body.sizeTaA414 PRE_first_tail_x15_r0_body.sizeDecA414 PRE_first_tail_x15_r0_body.sizePreA414 PRE_first_tail_x15_r0_body.bodyPatchB414 (fun _ hm => bodyO1534 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1534).trans bodyInactive0) (bodyBr1535.trans bodyBr1534.symm) bodyCnt1534 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55404, 1047, 0, 837⟩) bodyAcc1535 PRE_first_tail_x15_r0_body.bodyRunSeg414 bodyAcc1536 bodyHalt1536 PRE_first_tail_x15_r0_body.bodyStepA415 bodyTop1537 (fun _ hm => bodyO1535 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1535).trans bodyInactive0) (bodyBr1537.trans bodyBr1535.symm) bodyCnt1535 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55404, 1047, 0, 837⟩) PRE_first_tail_x15_r0_body.sizeA415 PRE_first_tail_x15_r0_body.sizeArgsA415 PRE_first_tail_x15_r0_body.sizeSymA415 PRE_first_tail_x15_r0_body.sizeMlxA415 PRE_first_tail_x15_r0_body.sizePayA415 PRE_first_tail_x15_r0_body.sizeTaA415 PRE_first_tail_x15_r0_body.sizeDecA415 PRE_first_tail_x15_r0_body.sizePreA415 PRE_first_tail_x15_r0_body.bodyPatchB415 (fun _ hm => bodyO1537 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1537).trans bodyInactive0) (bodyBr1538.trans bodyBr1537.symm) bodyCnt1537 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨55404, 1047, 0, 837⟩) bodyAcc1538 PRE_first_tail_x15_r0_body.bodyRunSeg415 bodyAcc1539 bodyHalt1539 PRE_first_tail_x15_r0_body.bodyStepA416 bodyTop1540 (fun _ hm => bodyO1538 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1538).trans bodyInactive0) (bodyBr1540.trans bodyBr1538.symm) bodyCnt1538 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
