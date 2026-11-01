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

kernel_rfl bodyO1554 : PRE_first_tail_x15_r0_body.S1554.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1554.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1554 : bridgeOf PRE_first_tail_x15_r0_body.s1554.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1554 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.S1554) = fun _ _ => true
kernel_rfl bodyAcc1556 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1556 PRE_first_tail_x15_r0_body.S1556) = fun _ _ => true
kernel_rfl bodyBr1557 : bridgeOf PRE_first_tail_x15_r0_body.s1557.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1556 : isHalt PRE_first_tail_x15_r0_body.s1556.ctl = false
kernel_rfl bodyTop1557 : noRetBlock PRE_first_tail_x15_r0_body.s1557 = true
kernel_rfl bodyCnt1554 : countersOkB PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.s1557 = true
kernel_rfl bodyO1557 : PRE_first_tail_x15_r0_body.S1557.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1557.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1558 : bridgeOf PRE_first_tail_x15_r0_body.s1558.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1557 : countersOkB PRE_first_tail_x15_r0_body.s1557 PRE_first_tail_x15_r0_body.s1558 = true
kernel_rfl bodyO1558 : PRE_first_tail_x15_r0_body.S1558.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1558.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1558 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1558 PRE_first_tail_x15_r0_body.S1558) = fun _ _ => true
kernel_rfl bodyAcc1559 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1559 PRE_first_tail_x15_r0_body.S1559) = fun _ _ => true
kernel_rfl bodyBr1560 : bridgeOf PRE_first_tail_x15_r0_body.s1560.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1559 : isHalt PRE_first_tail_x15_r0_body.s1559.ctl = false
kernel_rfl bodyTop1560 : noRetBlock PRE_first_tail_x15_r0_body.s1560 = true
kernel_rfl bodyCnt1558 : countersOkB PRE_first_tail_x15_r0_body.s1558 PRE_first_tail_x15_r0_body.s1560 = true
kernel_rfl bodyO1560 : PRE_first_tail_x15_r0_body.S1560.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1560.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1561 : bridgeOf PRE_first_tail_x15_r0_body.s1561.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1560 : countersOkB PRE_first_tail_x15_r0_body.s1560 PRE_first_tail_x15_r0_body.s1561 = true
kernel_rfl bodyO1561 : PRE_first_tail_x15_r0_body.S1561.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1561.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1561 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1561 PRE_first_tail_x15_r0_body.S1561) = fun _ _ => true
kernel_rfl bodyAcc1562 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1562 PRE_first_tail_x15_r0_body.S1562) = fun _ _ => true
kernel_rfl bodyBr1563 : bridgeOf PRE_first_tail_x15_r0_body.s1563.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1562 : isHalt PRE_first_tail_x15_r0_body.s1562.ctl = false
kernel_rfl bodyTop1563 : noRetBlock PRE_first_tail_x15_r0_body.s1563 = true
kernel_rfl bodyCnt1561 : countersOkB PRE_first_tail_x15_r0_body.s1561 PRE_first_tail_x15_r0_body.s1563 = true
kernel_rfl bodyO1563 : PRE_first_tail_x15_r0_body.S1563.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1563.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1564 : bridgeOf PRE_first_tail_x15_r0_body.s1564.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1563 : countersOkB PRE_first_tail_x15_r0_body.s1563 PRE_first_tail_x15_r0_body.s1564 = true
kernel_rfl bodyO1564 : PRE_first_tail_x15_r0_body.S1564.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1564.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1564 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1564 PRE_first_tail_x15_r0_body.S1564) = fun _ _ => true
kernel_rfl bodyAcc1565 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1565 PRE_first_tail_x15_r0_body.S1565) = fun _ _ => true
kernel_rfl bodyBr1566 : bridgeOf PRE_first_tail_x15_r0_body.s1566.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1565 : isHalt PRE_first_tail_x15_r0_body.s1565.ctl = false
kernel_rfl bodyTop1566 : noRetBlock PRE_first_tail_x15_r0_body.s1566 = true
kernel_rfl bodyCnt1564 : countersOkB PRE_first_tail_x15_r0_body.s1564 PRE_first_tail_x15_r0_body.s1566 = true
kernel_rfl bodyO1566 : PRE_first_tail_x15_r0_body.S1566.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1566.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1567 : bridgeOf PRE_first_tail_x15_r0_body.s1567.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1566 : countersOkB PRE_first_tail_x15_r0_body.s1566 PRE_first_tail_x15_r0_body.s1567 = true
kernel_rfl bodyO1567 : PRE_first_tail_x15_r0_body.S1567.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1567.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1567 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1567 PRE_first_tail_x15_r0_body.S1567) = fun _ _ => true
kernel_rfl bodyAcc1568 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1568 PRE_first_tail_x15_r0_body.S1568) = fun _ _ => true
kernel_rfl bodyBr1569 : bridgeOf PRE_first_tail_x15_r0_body.s1569.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1568 : isHalt PRE_first_tail_x15_r0_body.s1568.ctl = false
kernel_rfl bodyTop1569 : noRetBlock PRE_first_tail_x15_r0_body.s1569 = true
kernel_rfl bodyCnt1567 : countersOkB PRE_first_tail_x15_r0_body.s1567 PRE_first_tail_x15_r0_body.s1569 = true

theorem bodyGlue162 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨56565, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.S1554)
      (bodyCut NB T tk π i x0 bodyΘ ⟨56565, 1072, 0, 855⟩ bodyM PRE_first_tail_x15_r0_body.s1569 PRE_first_tail_x15_r0_body.S1569) 14515 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56565, 1072, 0, 855⟩) bodyAcc1554 PRE_first_tail_x15_r0_body.bodyRunSeg419 bodyAcc1556 bodyHalt1556 PRE_first_tail_x15_r0_body.bodyStepA420 bodyTop1557 (fun _ hm => bodyO1554 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1554).trans bodyInactive0) (bodyBr1557.trans bodyBr1554.symm) bodyCnt1554 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56565, 1072, 0, 855⟩) PRE_first_tail_x15_r0_body.sizeA420 PRE_first_tail_x15_r0_body.sizeArgsA420 PRE_first_tail_x15_r0_body.sizeSymA420 PRE_first_tail_x15_r0_body.sizeMlxA420 PRE_first_tail_x15_r0_body.sizePayA420 PRE_first_tail_x15_r0_body.sizeTaA420 PRE_first_tail_x15_r0_body.sizeDecA420 PRE_first_tail_x15_r0_body.sizePreA420 PRE_first_tail_x15_r0_body.bodyPatchB420 (fun _ hm => bodyO1557 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1557).trans bodyInactive0) (bodyBr1558.trans bodyBr1557.symm) bodyCnt1557 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56565, 1072, 0, 855⟩) bodyAcc1558 PRE_first_tail_x15_r0_body.bodyRunSeg420 bodyAcc1559 bodyHalt1559 PRE_first_tail_x15_r0_body.bodyStepA421 bodyTop1560 (fun _ hm => bodyO1558 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1558).trans bodyInactive0) (bodyBr1560.trans bodyBr1558.symm) bodyCnt1558 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56565, 1072, 0, 855⟩) PRE_first_tail_x15_r0_body.sizeA421 PRE_first_tail_x15_r0_body.sizeArgsA421 PRE_first_tail_x15_r0_body.sizeSymA421 PRE_first_tail_x15_r0_body.sizeMlxA421 PRE_first_tail_x15_r0_body.sizePayA421 PRE_first_tail_x15_r0_body.sizeTaA421 PRE_first_tail_x15_r0_body.sizeDecA421 PRE_first_tail_x15_r0_body.sizePreA421 PRE_first_tail_x15_r0_body.bodyPatchB421 (fun _ hm => bodyO1560 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1560).trans bodyInactive0) (bodyBr1561.trans bodyBr1560.symm) bodyCnt1560 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56565, 1072, 0, 855⟩) bodyAcc1561 PRE_first_tail_x15_r0_body.bodyRunSeg421 bodyAcc1562 bodyHalt1562 PRE_first_tail_x15_r0_body.bodyStepA422 bodyTop1563 (fun _ hm => bodyO1561 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1561).trans bodyInactive0) (bodyBr1563.trans bodyBr1561.symm) bodyCnt1561 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56565, 1072, 0, 855⟩) PRE_first_tail_x15_r0_body.sizeA422 PRE_first_tail_x15_r0_body.sizeArgsA422 PRE_first_tail_x15_r0_body.sizeSymA422 PRE_first_tail_x15_r0_body.sizeMlxA422 PRE_first_tail_x15_r0_body.sizePayA422 PRE_first_tail_x15_r0_body.sizeTaA422 PRE_first_tail_x15_r0_body.sizeDecA422 PRE_first_tail_x15_r0_body.sizePreA422 PRE_first_tail_x15_r0_body.bodyPatchB422 (fun _ hm => bodyO1563 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1563).trans bodyInactive0) (bodyBr1564.trans bodyBr1563.symm) bodyCnt1563 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56565, 1072, 0, 855⟩) bodyAcc1564 PRE_first_tail_x15_r0_body.bodyRunSeg422 bodyAcc1565 bodyHalt1565 PRE_first_tail_x15_r0_body.bodyStepA423 bodyTop1566 (fun _ hm => bodyO1564 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1564).trans bodyInactive0) (bodyBr1566.trans bodyBr1564.symm) bodyCnt1564 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56565, 1072, 0, 855⟩) PRE_first_tail_x15_r0_body.sizeA423 PRE_first_tail_x15_r0_body.sizeArgsA423 PRE_first_tail_x15_r0_body.sizeSymA423 PRE_first_tail_x15_r0_body.sizeMlxA423 PRE_first_tail_x15_r0_body.sizePayA423 PRE_first_tail_x15_r0_body.sizeTaA423 PRE_first_tail_x15_r0_body.sizeDecA423 PRE_first_tail_x15_r0_body.sizePreA423 PRE_first_tail_x15_r0_body.bodyPatchB423 (fun _ hm => bodyO1566 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1566).trans bodyInactive0) (bodyBr1567.trans bodyBr1566.symm) bodyCnt1566 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨56565, 1072, 0, 855⟩) bodyAcc1567 PRE_first_tail_x15_r0_body.bodyRunSeg423 bodyAcc1568 bodyHalt1568 PRE_first_tail_x15_r0_body.bodyStepA424 bodyTop1569 (fun _ hm => bodyO1567 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1567).trans bodyInactive0) (bodyBr1569.trans bodyBr1567.symm) bodyCnt1567 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
