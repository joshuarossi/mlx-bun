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

kernel_rfl bodyO1784 : PRE_first_tail_x15_r0_body.S1784.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1784.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1784 : bridgeOf PRE_first_tail_x15_r0_body.s1784.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1784 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1784 PRE_first_tail_x15_r0_body.S1784) = fun _ _ => true
kernel_rfl bodyAcc1786 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1786 PRE_first_tail_x15_r0_body.S1786) = fun _ _ => true
kernel_rfl bodyBr1787 : bridgeOf PRE_first_tail_x15_r0_body.s1787.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1786 : isHalt PRE_first_tail_x15_r0_body.s1786.ctl = false
kernel_rfl bodyTop1787 : noRetBlock PRE_first_tail_x15_r0_body.s1787 = true
kernel_rfl bodyCnt1784 : countersOkB PRE_first_tail_x15_r0_body.s1784 PRE_first_tail_x15_r0_body.s1787 = true
kernel_rfl bodyO1787 : PRE_first_tail_x15_r0_body.S1787.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1787.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1788 : bridgeOf PRE_first_tail_x15_r0_body.s1788.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1787 : countersOkB PRE_first_tail_x15_r0_body.s1787 PRE_first_tail_x15_r0_body.s1788 = true
kernel_rfl bodyO1788 : PRE_first_tail_x15_r0_body.S1788.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1788.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1788 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1788 PRE_first_tail_x15_r0_body.S1788) = fun _ _ => true
kernel_rfl bodyAcc1789 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1789 PRE_first_tail_x15_r0_body.S1789) = fun _ _ => true
kernel_rfl bodyBr1790 : bridgeOf PRE_first_tail_x15_r0_body.s1790.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1789 : isHalt PRE_first_tail_x15_r0_body.s1789.ctl = false
kernel_rfl bodyTop1790 : noRetBlock PRE_first_tail_x15_r0_body.s1790 = true
kernel_rfl bodyCnt1788 : countersOkB PRE_first_tail_x15_r0_body.s1788 PRE_first_tail_x15_r0_body.s1790 = true
kernel_rfl bodyO1790 : PRE_first_tail_x15_r0_body.S1790.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1790.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1791 : bridgeOf PRE_first_tail_x15_r0_body.s1791.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1790 : countersOkB PRE_first_tail_x15_r0_body.s1790 PRE_first_tail_x15_r0_body.s1791 = true
kernel_rfl bodyO1791 : PRE_first_tail_x15_r0_body.S1791.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1791.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1791 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1791 PRE_first_tail_x15_r0_body.S1791) = fun _ _ => true
kernel_rfl bodyAcc1792 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1792 PRE_first_tail_x15_r0_body.S1792) = fun _ _ => true
kernel_rfl bodyBr1793 : bridgeOf PRE_first_tail_x15_r0_body.s1793.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1792 : isHalt PRE_first_tail_x15_r0_body.s1792.ctl = false
kernel_rfl bodyTop1793 : noRetBlock PRE_first_tail_x15_r0_body.s1793 = true
kernel_rfl bodyCnt1791 : countersOkB PRE_first_tail_x15_r0_body.s1791 PRE_first_tail_x15_r0_body.s1793 = true
kernel_rfl bodyO1793 : PRE_first_tail_x15_r0_body.S1793.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1793.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1794 : bridgeOf PRE_first_tail_x15_r0_body.s1794.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1793 : countersOkB PRE_first_tail_x15_r0_body.s1793 PRE_first_tail_x15_r0_body.s1794 = true
kernel_rfl bodyO1794 : PRE_first_tail_x15_r0_body.S1794.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1794.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1794 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1794 PRE_first_tail_x15_r0_body.S1794) = fun _ _ => true
kernel_rfl bodyAcc1795 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1795 PRE_first_tail_x15_r0_body.S1795) = fun _ _ => true
kernel_rfl bodyBr1796 : bridgeOf PRE_first_tail_x15_r0_body.s1796.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1795 : isHalt PRE_first_tail_x15_r0_body.s1795.ctl = false
kernel_rfl bodyTop1796 : noRetBlock PRE_first_tail_x15_r0_body.s1796 = true
kernel_rfl bodyCnt1794 : countersOkB PRE_first_tail_x15_r0_body.s1794 PRE_first_tail_x15_r0_body.s1796 = true
kernel_rfl bodyO1796 : PRE_first_tail_x15_r0_body.S1796.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1796.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1797 : bridgeOf PRE_first_tail_x15_r0_body.s1797.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1796 : countersOkB PRE_first_tail_x15_r0_body.s1796 PRE_first_tail_x15_r0_body.s1797 = true
kernel_rfl bodyO1797 : PRE_first_tail_x15_r0_body.S1797.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1797.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1797 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1797 PRE_first_tail_x15_r0_body.S1797) = fun _ _ => true
kernel_rfl bodyAcc1798 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1798 PRE_first_tail_x15_r0_body.S1798) = fun _ _ => true
kernel_rfl bodyBr1799 : bridgeOf PRE_first_tail_x15_r0_body.s1799.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1798 : isHalt PRE_first_tail_x15_r0_body.s1798.ctl = false
kernel_rfl bodyTop1799 : noRetBlock PRE_first_tail_x15_r0_body.s1799 = true
kernel_rfl bodyCnt1797 : countersOkB PRE_first_tail_x15_r0_body.s1797 PRE_first_tail_x15_r0_body.s1799 = true

theorem bodyGlue186 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨64327, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1784 PRE_first_tail_x15_r0_body.S1784)
      (bodyCut NB T tk π i x0 bodyΘ ⟨64327, 1226, 0, 981⟩ bodyM PRE_first_tail_x15_r0_body.s1799 PRE_first_tail_x15_r0_body.S1799) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64327, 1226, 0, 981⟩) bodyAcc1784 PRE_first_tail_x15_r0_body.bodyRunSeg481 bodyAcc1786 bodyHalt1786 PRE_first_tail_x15_r0_body.bodyStepA482 bodyTop1787 (fun _ hm => bodyO1784 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1784).trans bodyInactive0) (bodyBr1787.trans bodyBr1784.symm) bodyCnt1784 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64327, 1226, 0, 981⟩) PRE_first_tail_x15_r0_body.sizeA482 PRE_first_tail_x15_r0_body.sizeArgsA482 PRE_first_tail_x15_r0_body.sizeSymA482 PRE_first_tail_x15_r0_body.sizeMlxA482 PRE_first_tail_x15_r0_body.sizePayA482 PRE_first_tail_x15_r0_body.sizeTaA482 PRE_first_tail_x15_r0_body.sizeDecA482 PRE_first_tail_x15_r0_body.sizePreA482 PRE_first_tail_x15_r0_body.bodyPatchB482 (fun _ hm => bodyO1787 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1787).trans bodyInactive0) (bodyBr1788.trans bodyBr1787.symm) bodyCnt1787 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64327, 1226, 0, 981⟩) bodyAcc1788 PRE_first_tail_x15_r0_body.bodyRunSeg482 bodyAcc1789 bodyHalt1789 PRE_first_tail_x15_r0_body.bodyStepA483 bodyTop1790 (fun _ hm => bodyO1788 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1788).trans bodyInactive0) (bodyBr1790.trans bodyBr1788.symm) bodyCnt1788 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64327, 1226, 0, 981⟩) PRE_first_tail_x15_r0_body.sizeA483 PRE_first_tail_x15_r0_body.sizeArgsA483 PRE_first_tail_x15_r0_body.sizeSymA483 PRE_first_tail_x15_r0_body.sizeMlxA483 PRE_first_tail_x15_r0_body.sizePayA483 PRE_first_tail_x15_r0_body.sizeTaA483 PRE_first_tail_x15_r0_body.sizeDecA483 PRE_first_tail_x15_r0_body.sizePreA483 PRE_first_tail_x15_r0_body.bodyPatchB483 (fun _ hm => bodyO1790 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1790).trans bodyInactive0) (bodyBr1791.trans bodyBr1790.symm) bodyCnt1790 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64327, 1226, 0, 981⟩) bodyAcc1791 PRE_first_tail_x15_r0_body.bodyRunSeg483 bodyAcc1792 bodyHalt1792 PRE_first_tail_x15_r0_body.bodyStepA484 bodyTop1793 (fun _ hm => bodyO1791 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1791).trans bodyInactive0) (bodyBr1793.trans bodyBr1791.symm) bodyCnt1791 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64327, 1226, 0, 981⟩) PRE_first_tail_x15_r0_body.sizeA484 PRE_first_tail_x15_r0_body.sizeArgsA484 PRE_first_tail_x15_r0_body.sizeSymA484 PRE_first_tail_x15_r0_body.sizeMlxA484 PRE_first_tail_x15_r0_body.sizePayA484 PRE_first_tail_x15_r0_body.sizeTaA484 PRE_first_tail_x15_r0_body.sizeDecA484 PRE_first_tail_x15_r0_body.sizePreA484 PRE_first_tail_x15_r0_body.bodyPatchB484 (fun _ hm => bodyO1793 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1793).trans bodyInactive0) (bodyBr1794.trans bodyBr1793.symm) bodyCnt1793 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64327, 1226, 0, 981⟩) bodyAcc1794 PRE_first_tail_x15_r0_body.bodyRunSeg484 bodyAcc1795 bodyHalt1795 PRE_first_tail_x15_r0_body.bodyStepA485 bodyTop1796 (fun _ hm => bodyO1794 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1794).trans bodyInactive0) (bodyBr1796.trans bodyBr1794.symm) bodyCnt1794 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64327, 1226, 0, 981⟩) PRE_first_tail_x15_r0_body.sizeA485 PRE_first_tail_x15_r0_body.sizeArgsA485 PRE_first_tail_x15_r0_body.sizeSymA485 PRE_first_tail_x15_r0_body.sizeMlxA485 PRE_first_tail_x15_r0_body.sizePayA485 PRE_first_tail_x15_r0_body.sizeTaA485 PRE_first_tail_x15_r0_body.sizeDecA485 PRE_first_tail_x15_r0_body.sizePreA485 PRE_first_tail_x15_r0_body.bodyPatchB485 (fun _ hm => bodyO1796 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1796).trans bodyInactive0) (bodyBr1797.trans bodyBr1796.symm) bodyCnt1796 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨64327, 1226, 0, 981⟩) bodyAcc1797 PRE_first_tail_x15_r0_body.bodyRunSeg485 bodyAcc1798 bodyHalt1798 PRE_first_tail_x15_r0_body.bodyStepA486 bodyTop1799 (fun _ hm => bodyO1797 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1797).trans bodyInactive0) (bodyBr1799.trans bodyBr1797.symm) bodyCnt1797 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
