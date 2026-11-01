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

kernel_rfl bodyO1726 : PRE_first_tail_x15_r0_body.S1726.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1726.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1726 : bridgeOf PRE_first_tail_x15_r0_body.s1726.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1726 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1726 PRE_first_tail_x15_r0_body.S1726) = fun _ _ => true
kernel_rfl bodyAcc1728 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1728 PRE_first_tail_x15_r0_body.S1728) = fun _ _ => true
kernel_rfl bodyBr1729 : bridgeOf PRE_first_tail_x15_r0_body.s1729.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1728 : isHalt PRE_first_tail_x15_r0_body.s1728.ctl = false
kernel_rfl bodyTop1729 : noRetBlock PRE_first_tail_x15_r0_body.s1729 = true
kernel_rfl bodyCnt1726 : countersOkB PRE_first_tail_x15_r0_body.s1726 PRE_first_tail_x15_r0_body.s1729 = true
kernel_rfl bodyO1729 : PRE_first_tail_x15_r0_body.S1729.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1729.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1730 : bridgeOf PRE_first_tail_x15_r0_body.s1730.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1729 : countersOkB PRE_first_tail_x15_r0_body.s1729 PRE_first_tail_x15_r0_body.s1730 = true
kernel_rfl bodyO1730 : PRE_first_tail_x15_r0_body.S1730.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1730.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1730 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1730 PRE_first_tail_x15_r0_body.S1730) = fun _ _ => true
kernel_rfl bodyAcc1731 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1731 PRE_first_tail_x15_r0_body.S1731) = fun _ _ => true
kernel_rfl bodyBr1732 : bridgeOf PRE_first_tail_x15_r0_body.s1732.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1731 : isHalt PRE_first_tail_x15_r0_body.s1731.ctl = false
kernel_rfl bodyTop1732 : noRetBlock PRE_first_tail_x15_r0_body.s1732 = true
kernel_rfl bodyCnt1730 : countersOkB PRE_first_tail_x15_r0_body.s1730 PRE_first_tail_x15_r0_body.s1732 = true
kernel_rfl bodyO1732 : PRE_first_tail_x15_r0_body.S1732.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1732.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1733 : bridgeOf PRE_first_tail_x15_r0_body.s1733.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1732 : countersOkB PRE_first_tail_x15_r0_body.s1732 PRE_first_tail_x15_r0_body.s1733 = true
kernel_rfl bodyO1733 : PRE_first_tail_x15_r0_body.S1733.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1733.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1733 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1733 PRE_first_tail_x15_r0_body.S1733) = fun _ _ => true
kernel_rfl bodyAcc1734 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1734 PRE_first_tail_x15_r0_body.S1734) = fun _ _ => true
kernel_rfl bodyBr1735 : bridgeOf PRE_first_tail_x15_r0_body.s1735.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1734 : isHalt PRE_first_tail_x15_r0_body.s1734.ctl = false
kernel_rfl bodyTop1735 : noRetBlock PRE_first_tail_x15_r0_body.s1735 = true
kernel_rfl bodyCnt1733 : countersOkB PRE_first_tail_x15_r0_body.s1733 PRE_first_tail_x15_r0_body.s1735 = true
kernel_rfl bodyO1735 : PRE_first_tail_x15_r0_body.S1735.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1735.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1736 : bridgeOf PRE_first_tail_x15_r0_body.s1736.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1735 : countersOkB PRE_first_tail_x15_r0_body.s1735 PRE_first_tail_x15_r0_body.s1736 = true
kernel_rfl bodyO1736 : PRE_first_tail_x15_r0_body.S1736.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1736.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1736 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1736 PRE_first_tail_x15_r0_body.S1736) = fun _ _ => true
kernel_rfl bodyAcc1737 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1737 PRE_first_tail_x15_r0_body.S1737) = fun _ _ => true
kernel_rfl bodyBr1738 : bridgeOf PRE_first_tail_x15_r0_body.s1738.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1737 : isHalt PRE_first_tail_x15_r0_body.s1737.ctl = false
kernel_rfl bodyTop1738 : noRetBlock PRE_first_tail_x15_r0_body.s1738 = true
kernel_rfl bodyCnt1736 : countersOkB PRE_first_tail_x15_r0_body.s1736 PRE_first_tail_x15_r0_body.s1738 = true
kernel_rfl bodyO1738 : PRE_first_tail_x15_r0_body.S1738.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1738.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1739 : bridgeOf PRE_first_tail_x15_r0_body.s1739.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1738 : countersOkB PRE_first_tail_x15_r0_body.s1738 PRE_first_tail_x15_r0_body.s1739 = true
kernel_rfl bodyO1739 : PRE_first_tail_x15_r0_body.S1739.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1739.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1739 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1739 PRE_first_tail_x15_r0_body.S1739) = fun _ _ => true
kernel_rfl bodyAcc1740 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1740 PRE_first_tail_x15_r0_body.S1740) = fun _ _ => true
kernel_rfl bodyBr1741 : bridgeOf PRE_first_tail_x15_r0_body.s1741.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1740 : isHalt PRE_first_tail_x15_r0_body.s1740.ctl = false
kernel_rfl bodyTop1741 : noRetBlock PRE_first_tail_x15_r0_body.s1741 = true
kernel_rfl bodyCnt1739 : countersOkB PRE_first_tail_x15_r0_body.s1739 PRE_first_tail_x15_r0_body.s1741 = true

theorem bodyGlue180 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61987, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1726 PRE_first_tail_x15_r0_body.S1726)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61987, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1741 PRE_first_tail_x15_r0_body.S1741) 14768 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61987, 1176, 0, 945⟩) bodyAcc1726 PRE_first_tail_x15_r0_body.bodyRunSeg465 bodyAcc1728 bodyHalt1728 PRE_first_tail_x15_r0_body.bodyStepA466 bodyTop1729 (fun _ hm => bodyO1726 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1726).trans bodyInactive0) (bodyBr1729.trans bodyBr1726.symm) bodyCnt1726 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61987, 1176, 0, 945⟩) PRE_first_tail_x15_r0_body.sizeA466 PRE_first_tail_x15_r0_body.sizeArgsA466 PRE_first_tail_x15_r0_body.sizeSymA466 PRE_first_tail_x15_r0_body.sizeMlxA466 PRE_first_tail_x15_r0_body.sizePayA466 PRE_first_tail_x15_r0_body.sizeTaA466 PRE_first_tail_x15_r0_body.sizeDecA466 PRE_first_tail_x15_r0_body.sizePreA466 PRE_first_tail_x15_r0_body.bodyPatchB466 (fun _ hm => bodyO1729 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1729).trans bodyInactive0) (bodyBr1730.trans bodyBr1729.symm) bodyCnt1729 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61987, 1176, 0, 945⟩) bodyAcc1730 PRE_first_tail_x15_r0_body.bodyRunSeg466 bodyAcc1731 bodyHalt1731 PRE_first_tail_x15_r0_body.bodyStepA467 bodyTop1732 (fun _ hm => bodyO1730 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1730).trans bodyInactive0) (bodyBr1732.trans bodyBr1730.symm) bodyCnt1730 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61987, 1176, 0, 945⟩) PRE_first_tail_x15_r0_body.sizeA467 PRE_first_tail_x15_r0_body.sizeArgsA467 PRE_first_tail_x15_r0_body.sizeSymA467 PRE_first_tail_x15_r0_body.sizeMlxA467 PRE_first_tail_x15_r0_body.sizePayA467 PRE_first_tail_x15_r0_body.sizeTaA467 PRE_first_tail_x15_r0_body.sizeDecA467 PRE_first_tail_x15_r0_body.sizePreA467 PRE_first_tail_x15_r0_body.bodyPatchB467 (fun _ hm => bodyO1732 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1732).trans bodyInactive0) (bodyBr1733.trans bodyBr1732.symm) bodyCnt1732 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61987, 1176, 0, 945⟩) bodyAcc1733 PRE_first_tail_x15_r0_body.bodyRunSeg467 bodyAcc1734 bodyHalt1734 PRE_first_tail_x15_r0_body.bodyStepA468 bodyTop1735 (fun _ hm => bodyO1733 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1733).trans bodyInactive0) (bodyBr1735.trans bodyBr1733.symm) bodyCnt1733 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61987, 1176, 0, 945⟩) PRE_first_tail_x15_r0_body.sizeA468 PRE_first_tail_x15_r0_body.sizeArgsA468 PRE_first_tail_x15_r0_body.sizeSymA468 PRE_first_tail_x15_r0_body.sizeMlxA468 PRE_first_tail_x15_r0_body.sizePayA468 PRE_first_tail_x15_r0_body.sizeTaA468 PRE_first_tail_x15_r0_body.sizeDecA468 PRE_first_tail_x15_r0_body.sizePreA468 PRE_first_tail_x15_r0_body.bodyPatchB468 (fun _ hm => bodyO1735 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1735).trans bodyInactive0) (bodyBr1736.trans bodyBr1735.symm) bodyCnt1735 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61987, 1176, 0, 945⟩) bodyAcc1736 PRE_first_tail_x15_r0_body.bodyRunSeg468 bodyAcc1737 bodyHalt1737 PRE_first_tail_x15_r0_body.bodyStepA469 bodyTop1738 (fun _ hm => bodyO1736 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1736).trans bodyInactive0) (bodyBr1738.trans bodyBr1736.symm) bodyCnt1736 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61987, 1176, 0, 945⟩) PRE_first_tail_x15_r0_body.sizeA469 PRE_first_tail_x15_r0_body.sizeArgsA469 PRE_first_tail_x15_r0_body.sizeSymA469 PRE_first_tail_x15_r0_body.sizeMlxA469 PRE_first_tail_x15_r0_body.sizePayA469 PRE_first_tail_x15_r0_body.sizeTaA469 PRE_first_tail_x15_r0_body.sizeDecA469 PRE_first_tail_x15_r0_body.sizePreA469 PRE_first_tail_x15_r0_body.bodyPatchB469 (fun _ hm => bodyO1738 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1738).trans bodyInactive0) (bodyBr1739.trans bodyBr1738.symm) bodyCnt1738 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61987, 1176, 0, 945⟩) bodyAcc1739 PRE_first_tail_x15_r0_body.bodyRunSeg469 bodyAcc1740 bodyHalt1740 PRE_first_tail_x15_r0_body.bodyStepA470 bodyTop1741 (fun _ hm => bodyO1739 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1739).trans bodyInactive0) (bodyBr1741.trans bodyBr1739.symm) bodyCnt1739 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
