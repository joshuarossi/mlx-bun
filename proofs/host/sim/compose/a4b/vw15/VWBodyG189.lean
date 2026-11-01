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

kernel_rfl bodyO1813 : PRE_first_tail_x15_r0_body.S1813.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1813.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1813 : bridgeOf PRE_first_tail_x15_r0_body.s1813.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1813 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.S1813) = fun _ _ => true
kernel_rfl bodyAcc1815 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1815 PRE_first_tail_x15_r0_body.S1815) = fun _ _ => true
kernel_rfl bodyBr1816 : bridgeOf PRE_first_tail_x15_r0_body.s1816.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1815 : isHalt PRE_first_tail_x15_r0_body.s1815.ctl = false
kernel_rfl bodyTop1816 : noRetBlock PRE_first_tail_x15_r0_body.s1816 = true
kernel_rfl bodyCnt1813 : countersOkB PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.s1816 = true
kernel_rfl bodyO1816 : PRE_first_tail_x15_r0_body.S1816.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1816.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1817 : bridgeOf PRE_first_tail_x15_r0_body.s1817.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1816 : countersOkB PRE_first_tail_x15_r0_body.s1816 PRE_first_tail_x15_r0_body.s1817 = true
kernel_rfl bodyO1817 : PRE_first_tail_x15_r0_body.S1817.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1817.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1817 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1817 PRE_first_tail_x15_r0_body.S1817) = fun _ _ => true
kernel_rfl bodyAcc1819 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1819 PRE_first_tail_x15_r0_body.S1819) = fun _ _ => true
kernel_rfl bodyBr1820 : bridgeOf PRE_first_tail_x15_r0_body.s1820.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1819 : isHalt PRE_first_tail_x15_r0_body.s1819.ctl = false
kernel_rfl bodyTop1820 : noRetBlock PRE_first_tail_x15_r0_body.s1820 = true
kernel_rfl bodyCnt1817 : countersOkB PRE_first_tail_x15_r0_body.s1817 PRE_first_tail_x15_r0_body.s1820 = true
kernel_rfl bodyO1820 : PRE_first_tail_x15_r0_body.S1820.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1820.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1821 : bridgeOf PRE_first_tail_x15_r0_body.s1821.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1820 : countersOkB PRE_first_tail_x15_r0_body.s1820 PRE_first_tail_x15_r0_body.s1821 = true
kernel_rfl bodyO1821 : PRE_first_tail_x15_r0_body.S1821.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1821.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1821 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1821 PRE_first_tail_x15_r0_body.S1821) = fun _ _ => true
kernel_rfl bodyAcc1822 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1822 PRE_first_tail_x15_r0_body.S1822) = fun _ _ => true
kernel_rfl bodyBr1823 : bridgeOf PRE_first_tail_x15_r0_body.s1823.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1822 : isHalt PRE_first_tail_x15_r0_body.s1822.ctl = false
kernel_rfl bodyTop1823 : noRetBlock PRE_first_tail_x15_r0_body.s1823 = true
kernel_rfl bodyCnt1821 : countersOkB PRE_first_tail_x15_r0_body.s1821 PRE_first_tail_x15_r0_body.s1823 = true
kernel_rfl bodyO1823 : PRE_first_tail_x15_r0_body.S1823.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1823.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1824 : bridgeOf PRE_first_tail_x15_r0_body.s1824.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1823 : countersOkB PRE_first_tail_x15_r0_body.s1823 PRE_first_tail_x15_r0_body.s1824 = true
kernel_rfl bodyO1824 : PRE_first_tail_x15_r0_body.S1824.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1824.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1824 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1824 PRE_first_tail_x15_r0_body.S1824) = fun _ _ => true
kernel_rfl bodyAcc1826 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1826 PRE_first_tail_x15_r0_body.S1826) = fun _ _ => true
kernel_rfl bodyBr1827 : bridgeOf PRE_first_tail_x15_r0_body.s1827.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1826 : isHalt PRE_first_tail_x15_r0_body.s1826.ctl = false
kernel_rfl bodyTop1827 : noRetBlock PRE_first_tail_x15_r0_body.s1827 = true
kernel_rfl bodyCnt1824 : countersOkB PRE_first_tail_x15_r0_body.s1824 PRE_first_tail_x15_r0_body.s1827 = true

theorem bodyGlue189 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65488, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1813 PRE_first_tail_x15_r0_body.S1813)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65488, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1827 PRE_first_tail_x15_r0_body.S1827) 16990 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65488, 1251, 0, 999⟩) bodyAcc1813 PRE_first_tail_x15_r0_body.bodyRunSeg489 bodyAcc1815 bodyHalt1815 PRE_first_tail_x15_r0_body.bodyStepA490 bodyTop1816 (fun _ hm => bodyO1813 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1813).trans bodyInactive0) (bodyBr1816.trans bodyBr1813.symm) bodyCnt1813 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65488, 1251, 0, 999⟩) PRE_first_tail_x15_r0_body.sizeA490 PRE_first_tail_x15_r0_body.sizeArgsA490 PRE_first_tail_x15_r0_body.sizeSymA490 PRE_first_tail_x15_r0_body.sizeMlxA490 PRE_first_tail_x15_r0_body.sizePayA490 PRE_first_tail_x15_r0_body.sizeTaA490 PRE_first_tail_x15_r0_body.sizeDecA490 PRE_first_tail_x15_r0_body.sizePreA490 PRE_first_tail_x15_r0_body.bodyPatchB490 (fun _ hm => bodyO1816 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1816).trans bodyInactive0) (bodyBr1817.trans bodyBr1816.symm) bodyCnt1816 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65488, 1251, 0, 999⟩) bodyAcc1817 PRE_first_tail_x15_r0_body.bodyRunSeg490 bodyAcc1819 bodyHalt1819 PRE_first_tail_x15_r0_body.bodyStepA491 bodyTop1820 (fun _ hm => bodyO1817 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1817).trans bodyInactive0) (bodyBr1820.trans bodyBr1817.symm) bodyCnt1817 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65488, 1251, 0, 999⟩) PRE_first_tail_x15_r0_body.sizeA491 PRE_first_tail_x15_r0_body.sizeArgsA491 PRE_first_tail_x15_r0_body.sizeSymA491 PRE_first_tail_x15_r0_body.sizeMlxA491 PRE_first_tail_x15_r0_body.sizePayA491 PRE_first_tail_x15_r0_body.sizeTaA491 PRE_first_tail_x15_r0_body.sizeDecA491 PRE_first_tail_x15_r0_body.sizePreA491 PRE_first_tail_x15_r0_body.bodyPatchB491 (fun _ hm => bodyO1820 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1820).trans bodyInactive0) (bodyBr1821.trans bodyBr1820.symm) bodyCnt1820 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65488, 1251, 0, 999⟩) bodyAcc1821 PRE_first_tail_x15_r0_body.bodyRunSeg491 bodyAcc1822 bodyHalt1822 PRE_first_tail_x15_r0_body.bodyStepA492 bodyTop1823 (fun _ hm => bodyO1821 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1821).trans bodyInactive0) (bodyBr1823.trans bodyBr1821.symm) bodyCnt1821 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65488, 1251, 0, 999⟩) PRE_first_tail_x15_r0_body.sizeA492 PRE_first_tail_x15_r0_body.sizeArgsA492 PRE_first_tail_x15_r0_body.sizeSymA492 PRE_first_tail_x15_r0_body.sizeMlxA492 PRE_first_tail_x15_r0_body.sizePayA492 PRE_first_tail_x15_r0_body.sizeTaA492 PRE_first_tail_x15_r0_body.sizeDecA492 PRE_first_tail_x15_r0_body.sizePreA492 PRE_first_tail_x15_r0_body.bodyPatchB492 (fun _ hm => bodyO1823 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1823).trans bodyInactive0) (bodyBr1824.trans bodyBr1823.symm) bodyCnt1823 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65488, 1251, 0, 999⟩) bodyAcc1824 PRE_first_tail_x15_r0_body.bodyRunSeg492 bodyAcc1826 bodyHalt1826 PRE_first_tail_x15_r0_body.bodyStepA493 bodyTop1827 (fun _ hm => bodyO1824 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1824).trans bodyInactive0) (bodyBr1827.trans bodyBr1824.symm) bodyCnt1824 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
