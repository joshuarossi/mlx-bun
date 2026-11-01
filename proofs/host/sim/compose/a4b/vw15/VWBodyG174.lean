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

kernel_rfl bodyO1669 : PRE_first_tail_x15_r0_body.S1669.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1669.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1669 : bridgeOf PRE_first_tail_x15_r0_body.s1669.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1669 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1669 PRE_first_tail_x15_r0_body.S1669) = fun _ _ => true
kernel_rfl bodyAcc1671 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1671 PRE_first_tail_x15_r0_body.S1671) = fun _ _ => true
kernel_rfl bodyBr1672 : bridgeOf PRE_first_tail_x15_r0_body.s1672.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1671 : isHalt PRE_first_tail_x15_r0_body.s1671.ctl = false
kernel_rfl bodyTop1672 : noRetBlock PRE_first_tail_x15_r0_body.s1672 = true
kernel_rfl bodyCnt1669 : countersOkB PRE_first_tail_x15_r0_body.s1669 PRE_first_tail_x15_r0_body.s1672 = true
kernel_rfl bodyO1672 : PRE_first_tail_x15_r0_body.S1672.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1672.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1673 : bridgeOf PRE_first_tail_x15_r0_body.s1673.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1672 : countersOkB PRE_first_tail_x15_r0_body.s1672 PRE_first_tail_x15_r0_body.s1673 = true
kernel_rfl bodyO1673 : PRE_first_tail_x15_r0_body.S1673.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1673.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1673 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1673 PRE_first_tail_x15_r0_body.S1673) = fun _ _ => true
kernel_rfl bodyAcc1674 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1674 PRE_first_tail_x15_r0_body.S1674) = fun _ _ => true
kernel_rfl bodyBr1675 : bridgeOf PRE_first_tail_x15_r0_body.s1675.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1674 : isHalt PRE_first_tail_x15_r0_body.s1674.ctl = false
kernel_rfl bodyTop1675 : noRetBlock PRE_first_tail_x15_r0_body.s1675 = true
kernel_rfl bodyCnt1673 : countersOkB PRE_first_tail_x15_r0_body.s1673 PRE_first_tail_x15_r0_body.s1675 = true
kernel_rfl bodyO1675 : PRE_first_tail_x15_r0_body.S1675.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1675.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1676 : bridgeOf PRE_first_tail_x15_r0_body.s1676.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1675 : countersOkB PRE_first_tail_x15_r0_body.s1675 PRE_first_tail_x15_r0_body.s1676 = true
kernel_rfl bodyO1676 : PRE_first_tail_x15_r0_body.S1676.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1676.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1676 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1676 PRE_first_tail_x15_r0_body.S1676) = fun _ _ => true
kernel_rfl bodyAcc1677 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1677 PRE_first_tail_x15_r0_body.S1677) = fun _ _ => true
kernel_rfl bodyBr1678 : bridgeOf PRE_first_tail_x15_r0_body.s1678.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1677 : isHalt PRE_first_tail_x15_r0_body.s1677.ctl = false
kernel_rfl bodyTop1678 : noRetBlock PRE_first_tail_x15_r0_body.s1678 = true
kernel_rfl bodyCnt1676 : countersOkB PRE_first_tail_x15_r0_body.s1676 PRE_first_tail_x15_r0_body.s1678 = true
kernel_rfl bodyO1678 : PRE_first_tail_x15_r0_body.S1678.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1678.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1679 : bridgeOf PRE_first_tail_x15_r0_body.s1679.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1678 : countersOkB PRE_first_tail_x15_r0_body.s1678 PRE_first_tail_x15_r0_body.s1679 = true
kernel_rfl bodyO1679 : PRE_first_tail_x15_r0_body.S1679.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1679.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1679 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1679 PRE_first_tail_x15_r0_body.S1679) = fun _ _ => true
kernel_rfl bodyAcc1680 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1680 PRE_first_tail_x15_r0_body.S1680) = fun _ _ => true
kernel_rfl bodyBr1681 : bridgeOf PRE_first_tail_x15_r0_body.s1681.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1680 : isHalt PRE_first_tail_x15_r0_body.s1680.ctl = false
kernel_rfl bodyTop1681 : noRetBlock PRE_first_tail_x15_r0_body.s1681 = true
kernel_rfl bodyCnt1679 : countersOkB PRE_first_tail_x15_r0_body.s1679 PRE_first_tail_x15_r0_body.s1681 = true
kernel_rfl bodyO1681 : PRE_first_tail_x15_r0_body.S1681.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1681.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1682 : bridgeOf PRE_first_tail_x15_r0_body.s1682.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1681 : countersOkB PRE_first_tail_x15_r0_body.s1681 PRE_first_tail_x15_r0_body.s1682 = true
kernel_rfl bodyO1682 : PRE_first_tail_x15_r0_body.S1682.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1682.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1682 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1682 PRE_first_tail_x15_r0_body.S1682) = fun _ _ => true
kernel_rfl bodyAcc1683 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1683 PRE_first_tail_x15_r0_body.S1683) = fun _ _ => true
kernel_rfl bodyBr1684 : bridgeOf PRE_first_tail_x15_r0_body.s1684.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1683 : isHalt PRE_first_tail_x15_r0_body.s1683.ctl = false
kernel_rfl bodyTop1684 : noRetBlock PRE_first_tail_x15_r0_body.s1684 = true
kernel_rfl bodyCnt1682 : countersOkB PRE_first_tail_x15_r0_body.s1682 PRE_first_tail_x15_r0_body.s1684 = true

theorem bodyGlue174 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨60446, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1669 PRE_first_tail_x15_r0_body.S1669)
      (bodyCut NB T tk π i x0 bodyΘ ⟨60446, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1684 PRE_first_tail_x15_r0_body.S1684) 14550 :=
  (((((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60446, 1149, 0, 918⟩) bodyAcc1669 PRE_first_tail_x15_r0_body.bodyRunSeg450 bodyAcc1671 bodyHalt1671 PRE_first_tail_x15_r0_body.bodyStepA451 bodyTop1672 (fun _ hm => bodyO1669 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1669).trans bodyInactive0) (bodyBr1672.trans bodyBr1669.symm) bodyCnt1669 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60446, 1149, 0, 918⟩) PRE_first_tail_x15_r0_body.sizeA451 PRE_first_tail_x15_r0_body.sizeArgsA451 PRE_first_tail_x15_r0_body.sizeSymA451 PRE_first_tail_x15_r0_body.sizeMlxA451 PRE_first_tail_x15_r0_body.sizePayA451 PRE_first_tail_x15_r0_body.sizeTaA451 PRE_first_tail_x15_r0_body.sizeDecA451 PRE_first_tail_x15_r0_body.sizePreA451 PRE_first_tail_x15_r0_body.bodyPatchB451 (fun _ hm => bodyO1672 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1672).trans bodyInactive0) (bodyBr1673.trans bodyBr1672.symm) bodyCnt1672 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60446, 1149, 0, 918⟩) bodyAcc1673 PRE_first_tail_x15_r0_body.bodyRunSeg451 bodyAcc1674 bodyHalt1674 PRE_first_tail_x15_r0_body.bodyStepA452 bodyTop1675 (fun _ hm => bodyO1673 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1673).trans bodyInactive0) (bodyBr1675.trans bodyBr1673.symm) bodyCnt1673 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60446, 1149, 0, 918⟩) PRE_first_tail_x15_r0_body.sizeA452 PRE_first_tail_x15_r0_body.sizeArgsA452 PRE_first_tail_x15_r0_body.sizeSymA452 PRE_first_tail_x15_r0_body.sizeMlxA452 PRE_first_tail_x15_r0_body.sizePayA452 PRE_first_tail_x15_r0_body.sizeTaA452 PRE_first_tail_x15_r0_body.sizeDecA452 PRE_first_tail_x15_r0_body.sizePreA452 PRE_first_tail_x15_r0_body.bodyPatchB452 (fun _ hm => bodyO1675 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1675).trans bodyInactive0) (bodyBr1676.trans bodyBr1675.symm) bodyCnt1675 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60446, 1149, 0, 918⟩) bodyAcc1676 PRE_first_tail_x15_r0_body.bodyRunSeg452 bodyAcc1677 bodyHalt1677 PRE_first_tail_x15_r0_body.bodyStepA453 bodyTop1678 (fun _ hm => bodyO1676 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1676).trans bodyInactive0) (bodyBr1678.trans bodyBr1676.symm) bodyCnt1676 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60446, 1149, 0, 918⟩) PRE_first_tail_x15_r0_body.sizeA453 PRE_first_tail_x15_r0_body.sizeArgsA453 PRE_first_tail_x15_r0_body.sizeSymA453 PRE_first_tail_x15_r0_body.sizeMlxA453 PRE_first_tail_x15_r0_body.sizePayA453 PRE_first_tail_x15_r0_body.sizeTaA453 PRE_first_tail_x15_r0_body.sizeDecA453 PRE_first_tail_x15_r0_body.sizePreA453 PRE_first_tail_x15_r0_body.bodyPatchB453 (fun _ hm => bodyO1678 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1678).trans bodyInactive0) (bodyBr1679.trans bodyBr1678.symm) bodyCnt1678 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60446, 1149, 0, 918⟩) bodyAcc1679 PRE_first_tail_x15_r0_body.bodyRunSeg453 bodyAcc1680 bodyHalt1680 PRE_first_tail_x15_r0_body.bodyStepA454 bodyTop1681 (fun _ hm => bodyO1679 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1679).trans bodyInactive0) (bodyBr1681.trans bodyBr1679.symm) bodyCnt1679 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60446, 1149, 0, 918⟩) PRE_first_tail_x15_r0_body.sizeA454 PRE_first_tail_x15_r0_body.sizeArgsA454 PRE_first_tail_x15_r0_body.sizeSymA454 PRE_first_tail_x15_r0_body.sizeMlxA454 PRE_first_tail_x15_r0_body.sizePayA454 PRE_first_tail_x15_r0_body.sizeTaA454 PRE_first_tail_x15_r0_body.sizeDecA454 PRE_first_tail_x15_r0_body.sizePreA454 PRE_first_tail_x15_r0_body.bodyPatchB454 (fun _ hm => bodyO1681 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1681).trans bodyInactive0) (bodyBr1682.trans bodyBr1681.symm) bodyCnt1681 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60446, 1149, 0, 918⟩) bodyAcc1682 PRE_first_tail_x15_r0_body.bodyRunSeg454 bodyAcc1683 bodyHalt1683 PRE_first_tail_x15_r0_body.bodyStepA455 bodyTop1684 (fun _ hm => bodyO1682 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1682).trans bodyInactive0) (bodyBr1684.trans bodyBr1682.symm) bodyCnt1682 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
