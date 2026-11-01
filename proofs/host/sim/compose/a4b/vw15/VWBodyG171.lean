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

kernel_rfl bodyO1640 : PRE_first_tail_x15_r0_body.S1640.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1640.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1640 : bridgeOf PRE_first_tail_x15_r0_body.s1640.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1640 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1640 PRE_first_tail_x15_r0_body.S1640) = fun _ _ => true
kernel_rfl bodyAcc1642 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1642 PRE_first_tail_x15_r0_body.S1642) = fun _ _ => true
kernel_rfl bodyBr1643 : bridgeOf PRE_first_tail_x15_r0_body.s1643.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1642 : isHalt PRE_first_tail_x15_r0_body.s1642.ctl = false
kernel_rfl bodyTop1643 : noRetBlock PRE_first_tail_x15_r0_body.s1643 = true
kernel_rfl bodyCnt1640 : countersOkB PRE_first_tail_x15_r0_body.s1640 PRE_first_tail_x15_r0_body.s1643 = true
kernel_rfl bodyO1643 : PRE_first_tail_x15_r0_body.S1643.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1643.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1644 : bridgeOf PRE_first_tail_x15_r0_body.s1644.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1643 : countersOkB PRE_first_tail_x15_r0_body.s1643 PRE_first_tail_x15_r0_body.s1644 = true
kernel_rfl bodyO1644 : PRE_first_tail_x15_r0_body.S1644.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1644.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1644 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1644 PRE_first_tail_x15_r0_body.S1644) = fun _ _ => true
kernel_rfl bodyAcc1645 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1645 PRE_first_tail_x15_r0_body.S1645) = fun _ _ => true
kernel_rfl bodyBr1646 : bridgeOf PRE_first_tail_x15_r0_body.s1646.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1645 : isHalt PRE_first_tail_x15_r0_body.s1645.ctl = false
kernel_rfl bodyTop1646 : noRetBlock PRE_first_tail_x15_r0_body.s1646 = true
kernel_rfl bodyCnt1644 : countersOkB PRE_first_tail_x15_r0_body.s1644 PRE_first_tail_x15_r0_body.s1646 = true
kernel_rfl bodyO1646 : PRE_first_tail_x15_r0_body.S1646.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1646.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1647 : bridgeOf PRE_first_tail_x15_r0_body.s1647.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1646 : countersOkB PRE_first_tail_x15_r0_body.s1646 PRE_first_tail_x15_r0_body.s1647 = true
kernel_rfl bodyO1647 : PRE_first_tail_x15_r0_body.S1647.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1647.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1647 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1647 PRE_first_tail_x15_r0_body.S1647) = fun _ _ => true
kernel_rfl bodyAcc1648 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1648 PRE_first_tail_x15_r0_body.S1648) = fun _ _ => true
kernel_rfl bodyBr1649 : bridgeOf PRE_first_tail_x15_r0_body.s1649.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1648 : isHalt PRE_first_tail_x15_r0_body.s1648.ctl = false
kernel_rfl bodyTop1649 : noRetBlock PRE_first_tail_x15_r0_body.s1649 = true
kernel_rfl bodyCnt1647 : countersOkB PRE_first_tail_x15_r0_body.s1647 PRE_first_tail_x15_r0_body.s1649 = true
kernel_rfl bodyO1649 : PRE_first_tail_x15_r0_body.S1649.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1649.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1650 : bridgeOf PRE_first_tail_x15_r0_body.s1650.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1649 : countersOkB PRE_first_tail_x15_r0_body.s1649 PRE_first_tail_x15_r0_body.s1650 = true
kernel_rfl bodyO1650 : PRE_first_tail_x15_r0_body.S1650.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1650.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1650 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1650 PRE_first_tail_x15_r0_body.S1650) = fun _ _ => true
kernel_rfl bodyAcc1651 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1651 PRE_first_tail_x15_r0_body.S1651) = fun _ _ => true
kernel_rfl bodyBr1652 : bridgeOf PRE_first_tail_x15_r0_body.s1652.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1651 : isHalt PRE_first_tail_x15_r0_body.s1651.ctl = false
kernel_rfl bodyTop1652 : noRetBlock PRE_first_tail_x15_r0_body.s1652 = true
kernel_rfl bodyCnt1650 : countersOkB PRE_first_tail_x15_r0_body.s1650 PRE_first_tail_x15_r0_body.s1652 = true
kernel_rfl bodyO1652 : PRE_first_tail_x15_r0_body.S1652.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1652.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1653 : bridgeOf PRE_first_tail_x15_r0_body.s1653.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1652 : countersOkB PRE_first_tail_x15_r0_body.s1652 PRE_first_tail_x15_r0_body.s1653 = true
kernel_rfl bodyO1653 : PRE_first_tail_x15_r0_body.S1653.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1653.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1653 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1653 PRE_first_tail_x15_r0_body.S1653) = fun _ _ => true
kernel_rfl bodyAcc1654 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1654 PRE_first_tail_x15_r0_body.S1654) = fun _ _ => true
kernel_rfl bodyBr1655 : bridgeOf PRE_first_tail_x15_r0_body.s1655.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1654 : isHalt PRE_first_tail_x15_r0_body.s1654.ctl = false
kernel_rfl bodyTop1655 : noRetBlock PRE_first_tail_x15_r0_body.s1655 = true
kernel_rfl bodyCnt1653 : countersOkB PRE_first_tail_x15_r0_body.s1653 PRE_first_tail_x15_r0_body.s1655 = true

theorem bodyGlue171 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨59276, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1640 PRE_first_tail_x15_r0_body.S1640)
      (bodyCut NB T tk π i x0 bodyΘ ⟨59276, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1655 PRE_first_tail_x15_r0_body.S1655) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59276, 1124, 0, 900⟩) bodyAcc1640 PRE_first_tail_x15_r0_body.bodyRunSeg442 bodyAcc1642 bodyHalt1642 PRE_first_tail_x15_r0_body.bodyStepA443 bodyTop1643 (fun _ hm => bodyO1640 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1640).trans bodyInactive0) (bodyBr1643.trans bodyBr1640.symm) bodyCnt1640 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59276, 1124, 0, 900⟩) PRE_first_tail_x15_r0_body.sizeA443 PRE_first_tail_x15_r0_body.sizeArgsA443 PRE_first_tail_x15_r0_body.sizeSymA443 PRE_first_tail_x15_r0_body.sizeMlxA443 PRE_first_tail_x15_r0_body.sizePayA443 PRE_first_tail_x15_r0_body.sizeTaA443 PRE_first_tail_x15_r0_body.sizeDecA443 PRE_first_tail_x15_r0_body.sizePreA443 PRE_first_tail_x15_r0_body.bodyPatchB443 (fun _ hm => bodyO1643 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1643).trans bodyInactive0) (bodyBr1644.trans bodyBr1643.symm) bodyCnt1643 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59276, 1124, 0, 900⟩) bodyAcc1644 PRE_first_tail_x15_r0_body.bodyRunSeg443 bodyAcc1645 bodyHalt1645 PRE_first_tail_x15_r0_body.bodyStepA444 bodyTop1646 (fun _ hm => bodyO1644 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1644).trans bodyInactive0) (bodyBr1646.trans bodyBr1644.symm) bodyCnt1644 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59276, 1124, 0, 900⟩) PRE_first_tail_x15_r0_body.sizeA444 PRE_first_tail_x15_r0_body.sizeArgsA444 PRE_first_tail_x15_r0_body.sizeSymA444 PRE_first_tail_x15_r0_body.sizeMlxA444 PRE_first_tail_x15_r0_body.sizePayA444 PRE_first_tail_x15_r0_body.sizeTaA444 PRE_first_tail_x15_r0_body.sizeDecA444 PRE_first_tail_x15_r0_body.sizePreA444 PRE_first_tail_x15_r0_body.bodyPatchB444 (fun _ hm => bodyO1646 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1646).trans bodyInactive0) (bodyBr1647.trans bodyBr1646.symm) bodyCnt1646 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59276, 1124, 0, 900⟩) bodyAcc1647 PRE_first_tail_x15_r0_body.bodyRunSeg444 bodyAcc1648 bodyHalt1648 PRE_first_tail_x15_r0_body.bodyStepA445 bodyTop1649 (fun _ hm => bodyO1647 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1647).trans bodyInactive0) (bodyBr1649.trans bodyBr1647.symm) bodyCnt1647 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59276, 1124, 0, 900⟩) PRE_first_tail_x15_r0_body.sizeA445 PRE_first_tail_x15_r0_body.sizeArgsA445 PRE_first_tail_x15_r0_body.sizeSymA445 PRE_first_tail_x15_r0_body.sizeMlxA445 PRE_first_tail_x15_r0_body.sizePayA445 PRE_first_tail_x15_r0_body.sizeTaA445 PRE_first_tail_x15_r0_body.sizeDecA445 PRE_first_tail_x15_r0_body.sizePreA445 PRE_first_tail_x15_r0_body.bodyPatchB445 (fun _ hm => bodyO1649 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1649).trans bodyInactive0) (bodyBr1650.trans bodyBr1649.symm) bodyCnt1649 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59276, 1124, 0, 900⟩) bodyAcc1650 PRE_first_tail_x15_r0_body.bodyRunSeg445 bodyAcc1651 bodyHalt1651 PRE_first_tail_x15_r0_body.bodyStepA446 bodyTop1652 (fun _ hm => bodyO1650 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1650).trans bodyInactive0) (bodyBr1652.trans bodyBr1650.symm) bodyCnt1650 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59276, 1124, 0, 900⟩) PRE_first_tail_x15_r0_body.sizeA446 PRE_first_tail_x15_r0_body.sizeArgsA446 PRE_first_tail_x15_r0_body.sizeSymA446 PRE_first_tail_x15_r0_body.sizeMlxA446 PRE_first_tail_x15_r0_body.sizePayA446 PRE_first_tail_x15_r0_body.sizeTaA446 PRE_first_tail_x15_r0_body.sizeDecA446 PRE_first_tail_x15_r0_body.sizePreA446 PRE_first_tail_x15_r0_body.bodyPatchB446 (fun _ hm => bodyO1652 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1652).trans bodyInactive0) (bodyBr1653.trans bodyBr1652.symm) bodyCnt1652 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59276, 1124, 0, 900⟩) bodyAcc1653 PRE_first_tail_x15_r0_body.bodyRunSeg446 bodyAcc1654 bodyHalt1654 PRE_first_tail_x15_r0_body.bodyStepA447 bodyTop1655 (fun _ hm => bodyO1653 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1653).trans bodyInactive0) (bodyBr1655.trans bodyBr1653.symm) bodyCnt1653 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
