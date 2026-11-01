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

kernel_rfl bodyO1755 : PRE_first_tail_x15_r0_body.S1755.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1755.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1755 : bridgeOf PRE_first_tail_x15_r0_body.s1755.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1755 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1755 PRE_first_tail_x15_r0_body.S1755) = fun _ _ => true
kernel_rfl bodyAcc1757 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1757 PRE_first_tail_x15_r0_body.S1757) = fun _ _ => true
kernel_rfl bodyBr1758 : bridgeOf PRE_first_tail_x15_r0_body.s1758.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1757 : isHalt PRE_first_tail_x15_r0_body.s1757.ctl = false
kernel_rfl bodyTop1758 : noRetBlock PRE_first_tail_x15_r0_body.s1758 = true
kernel_rfl bodyCnt1755 : countersOkB PRE_first_tail_x15_r0_body.s1755 PRE_first_tail_x15_r0_body.s1758 = true
kernel_rfl bodyO1758 : PRE_first_tail_x15_r0_body.S1758.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1758.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1759 : bridgeOf PRE_first_tail_x15_r0_body.s1759.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1758 : countersOkB PRE_first_tail_x15_r0_body.s1758 PRE_first_tail_x15_r0_body.s1759 = true
kernel_rfl bodyO1759 : PRE_first_tail_x15_r0_body.S1759.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1759.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1759 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1759 PRE_first_tail_x15_r0_body.S1759) = fun _ _ => true
kernel_rfl bodyAcc1760 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1760 PRE_first_tail_x15_r0_body.S1760) = fun _ _ => true
kernel_rfl bodyBr1761 : bridgeOf PRE_first_tail_x15_r0_body.s1761.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1760 : isHalt PRE_first_tail_x15_r0_body.s1760.ctl = false
kernel_rfl bodyTop1761 : noRetBlock PRE_first_tail_x15_r0_body.s1761 = true
kernel_rfl bodyCnt1759 : countersOkB PRE_first_tail_x15_r0_body.s1759 PRE_first_tail_x15_r0_body.s1761 = true
kernel_rfl bodyO1761 : PRE_first_tail_x15_r0_body.S1761.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1761.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1762 : bridgeOf PRE_first_tail_x15_r0_body.s1762.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1761 : countersOkB PRE_first_tail_x15_r0_body.s1761 PRE_first_tail_x15_r0_body.s1762 = true
kernel_rfl bodyO1762 : PRE_first_tail_x15_r0_body.S1762.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1762.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1762 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1762 PRE_first_tail_x15_r0_body.S1762) = fun _ _ => true
kernel_rfl bodyAcc1763 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1763 PRE_first_tail_x15_r0_body.S1763) = fun _ _ => true
kernel_rfl bodyBr1764 : bridgeOf PRE_first_tail_x15_r0_body.s1764.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1763 : isHalt PRE_first_tail_x15_r0_body.s1763.ctl = false
kernel_rfl bodyTop1764 : noRetBlock PRE_first_tail_x15_r0_body.s1764 = true
kernel_rfl bodyCnt1762 : countersOkB PRE_first_tail_x15_r0_body.s1762 PRE_first_tail_x15_r0_body.s1764 = true
kernel_rfl bodyO1764 : PRE_first_tail_x15_r0_body.S1764.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1764.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1765 : bridgeOf PRE_first_tail_x15_r0_body.s1765.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1764 : countersOkB PRE_first_tail_x15_r0_body.s1764 PRE_first_tail_x15_r0_body.s1765 = true
kernel_rfl bodyO1765 : PRE_first_tail_x15_r0_body.S1765.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1765.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1765 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1765 PRE_first_tail_x15_r0_body.S1765) = fun _ _ => true
kernel_rfl bodyAcc1766 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1766 PRE_first_tail_x15_r0_body.S1766) = fun _ _ => true
kernel_rfl bodyBr1767 : bridgeOf PRE_first_tail_x15_r0_body.s1767.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1766 : isHalt PRE_first_tail_x15_r0_body.s1766.ctl = false
kernel_rfl bodyTop1767 : noRetBlock PRE_first_tail_x15_r0_body.s1767 = true
kernel_rfl bodyCnt1765 : countersOkB PRE_first_tail_x15_r0_body.s1765 PRE_first_tail_x15_r0_body.s1767 = true
kernel_rfl bodyO1767 : PRE_first_tail_x15_r0_body.S1767.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1767.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1768 : bridgeOf PRE_first_tail_x15_r0_body.s1768.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1767 : countersOkB PRE_first_tail_x15_r0_body.s1767 PRE_first_tail_x15_r0_body.s1768 = true
kernel_rfl bodyO1768 : PRE_first_tail_x15_r0_body.S1768.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1768.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1768 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1768 PRE_first_tail_x15_r0_body.S1768) = fun _ _ => true
kernel_rfl bodyAcc1769 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1769 PRE_first_tail_x15_r0_body.S1769) = fun _ _ => true
kernel_rfl bodyBr1770 : bridgeOf PRE_first_tail_x15_r0_body.s1770.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1769 : isHalt PRE_first_tail_x15_r0_body.s1769.ctl = false
kernel_rfl bodyTop1770 : noRetBlock PRE_first_tail_x15_r0_body.s1770 = true
kernel_rfl bodyCnt1768 : countersOkB PRE_first_tail_x15_r0_body.s1768 PRE_first_tail_x15_r0_body.s1770 = true

theorem bodyGlue183 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨63157, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1755 PRE_first_tail_x15_r0_body.S1755)
      (bodyCut NB T tk π i x0 bodyΘ ⟨63157, 1201, 0, 963⟩ bodyM PRE_first_tail_x15_r0_body.s1770 PRE_first_tail_x15_r0_body.S1770) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63157, 1201, 0, 963⟩) bodyAcc1755 PRE_first_tail_x15_r0_body.bodyRunSeg473 bodyAcc1757 bodyHalt1757 PRE_first_tail_x15_r0_body.bodyStepA474 bodyTop1758 (fun _ hm => bodyO1755 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1755).trans bodyInactive0) (bodyBr1758.trans bodyBr1755.symm) bodyCnt1755 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63157, 1201, 0, 963⟩) PRE_first_tail_x15_r0_body.sizeA474 PRE_first_tail_x15_r0_body.sizeArgsA474 PRE_first_tail_x15_r0_body.sizeSymA474 PRE_first_tail_x15_r0_body.sizeMlxA474 PRE_first_tail_x15_r0_body.sizePayA474 PRE_first_tail_x15_r0_body.sizeTaA474 PRE_first_tail_x15_r0_body.sizeDecA474 PRE_first_tail_x15_r0_body.sizePreA474 PRE_first_tail_x15_r0_body.bodyPatchB474 (fun _ hm => bodyO1758 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1758).trans bodyInactive0) (bodyBr1759.trans bodyBr1758.symm) bodyCnt1758 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63157, 1201, 0, 963⟩) bodyAcc1759 PRE_first_tail_x15_r0_body.bodyRunSeg474 bodyAcc1760 bodyHalt1760 PRE_first_tail_x15_r0_body.bodyStepA475 bodyTop1761 (fun _ hm => bodyO1759 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1759).trans bodyInactive0) (bodyBr1761.trans bodyBr1759.symm) bodyCnt1759 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63157, 1201, 0, 963⟩) PRE_first_tail_x15_r0_body.sizeA475 PRE_first_tail_x15_r0_body.sizeArgsA475 PRE_first_tail_x15_r0_body.sizeSymA475 PRE_first_tail_x15_r0_body.sizeMlxA475 PRE_first_tail_x15_r0_body.sizePayA475 PRE_first_tail_x15_r0_body.sizeTaA475 PRE_first_tail_x15_r0_body.sizeDecA475 PRE_first_tail_x15_r0_body.sizePreA475 PRE_first_tail_x15_r0_body.bodyPatchB475 (fun _ hm => bodyO1761 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1761).trans bodyInactive0) (bodyBr1762.trans bodyBr1761.symm) bodyCnt1761 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63157, 1201, 0, 963⟩) bodyAcc1762 PRE_first_tail_x15_r0_body.bodyRunSeg475 bodyAcc1763 bodyHalt1763 PRE_first_tail_x15_r0_body.bodyStepA476 bodyTop1764 (fun _ hm => bodyO1762 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1762).trans bodyInactive0) (bodyBr1764.trans bodyBr1762.symm) bodyCnt1762 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63157, 1201, 0, 963⟩) PRE_first_tail_x15_r0_body.sizeA476 PRE_first_tail_x15_r0_body.sizeArgsA476 PRE_first_tail_x15_r0_body.sizeSymA476 PRE_first_tail_x15_r0_body.sizeMlxA476 PRE_first_tail_x15_r0_body.sizePayA476 PRE_first_tail_x15_r0_body.sizeTaA476 PRE_first_tail_x15_r0_body.sizeDecA476 PRE_first_tail_x15_r0_body.sizePreA476 PRE_first_tail_x15_r0_body.bodyPatchB476 (fun _ hm => bodyO1764 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1764).trans bodyInactive0) (bodyBr1765.trans bodyBr1764.symm) bodyCnt1764 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63157, 1201, 0, 963⟩) bodyAcc1765 PRE_first_tail_x15_r0_body.bodyRunSeg476 bodyAcc1766 bodyHalt1766 PRE_first_tail_x15_r0_body.bodyStepA477 bodyTop1767 (fun _ hm => bodyO1765 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1765).trans bodyInactive0) (bodyBr1767.trans bodyBr1765.symm) bodyCnt1765 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63157, 1201, 0, 963⟩) PRE_first_tail_x15_r0_body.sizeA477 PRE_first_tail_x15_r0_body.sizeArgsA477 PRE_first_tail_x15_r0_body.sizeSymA477 PRE_first_tail_x15_r0_body.sizeMlxA477 PRE_first_tail_x15_r0_body.sizePayA477 PRE_first_tail_x15_r0_body.sizeTaA477 PRE_first_tail_x15_r0_body.sizeDecA477 PRE_first_tail_x15_r0_body.sizePreA477 PRE_first_tail_x15_r0_body.bodyPatchB477 (fun _ hm => bodyO1767 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1767).trans bodyInactive0) (bodyBr1768.trans bodyBr1767.symm) bodyCnt1767 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨63157, 1201, 0, 963⟩) bodyAcc1768 PRE_first_tail_x15_r0_body.bodyRunSeg477 bodyAcc1769 bodyHalt1769 PRE_first_tail_x15_r0_body.bodyStepA478 bodyTop1770 (fun _ hm => bodyO1768 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1768).trans bodyInactive0) (bodyBr1770.trans bodyBr1768.symm) bodyCnt1768 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
