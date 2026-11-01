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

kernel_rfl bodyO1698 : PRE_first_tail_x15_r0_body.S1698.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1698.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1698 : bridgeOf PRE_first_tail_x15_r0_body.s1698.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1698 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1698 PRE_first_tail_x15_r0_body.S1698) = fun _ _ => true
kernel_rfl bodyAcc1700 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1700 PRE_first_tail_x15_r0_body.S1700) = fun _ _ => true
kernel_rfl bodyBr1701 : bridgeOf PRE_first_tail_x15_r0_body.s1701.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1700 : isHalt PRE_first_tail_x15_r0_body.s1700.ctl = false
kernel_rfl bodyTop1701 : noRetBlock PRE_first_tail_x15_r0_body.s1701 = true
kernel_rfl bodyCnt1698 : countersOkB PRE_first_tail_x15_r0_body.s1698 PRE_first_tail_x15_r0_body.s1701 = true
kernel_rfl bodyO1701 : PRE_first_tail_x15_r0_body.S1701.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1701.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1702 : bridgeOf PRE_first_tail_x15_r0_body.s1702.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1701 : countersOkB PRE_first_tail_x15_r0_body.s1701 PRE_first_tail_x15_r0_body.s1702 = true
kernel_rfl bodyO1702 : PRE_first_tail_x15_r0_body.S1702.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1702.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1702 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1702 PRE_first_tail_x15_r0_body.S1702) = fun _ _ => true
kernel_rfl bodyAcc1704 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1704 PRE_first_tail_x15_r0_body.S1704) = fun _ _ => true
kernel_rfl bodyBr1705 : bridgeOf PRE_first_tail_x15_r0_body.s1705.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1704 : isHalt PRE_first_tail_x15_r0_body.s1704.ctl = false
kernel_rfl bodyTop1705 : noRetBlock PRE_first_tail_x15_r0_body.s1705 = true
kernel_rfl bodyCnt1702 : countersOkB PRE_first_tail_x15_r0_body.s1702 PRE_first_tail_x15_r0_body.s1705 = true
kernel_rfl bodyO1705 : PRE_first_tail_x15_r0_body.S1705.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1705.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1706 : bridgeOf PRE_first_tail_x15_r0_body.s1706.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1705 : countersOkB PRE_first_tail_x15_r0_body.s1705 PRE_first_tail_x15_r0_body.s1706 = true
kernel_rfl bodyO1706 : PRE_first_tail_x15_r0_body.S1706.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1706.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1706 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1706 PRE_first_tail_x15_r0_body.S1706) = fun _ _ => true
kernel_rfl bodyAcc1707 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1707 PRE_first_tail_x15_r0_body.S1707) = fun _ _ => true
kernel_rfl bodyBr1708 : bridgeOf PRE_first_tail_x15_r0_body.s1708.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1707 : isHalt PRE_first_tail_x15_r0_body.s1707.ctl = false
kernel_rfl bodyTop1708 : noRetBlock PRE_first_tail_x15_r0_body.s1708 = true
kernel_rfl bodyCnt1706 : countersOkB PRE_first_tail_x15_r0_body.s1706 PRE_first_tail_x15_r0_body.s1708 = true
kernel_rfl bodyO1708 : PRE_first_tail_x15_r0_body.S1708.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1708.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1709 : bridgeOf PRE_first_tail_x15_r0_body.s1709.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1708 : countersOkB PRE_first_tail_x15_r0_body.s1708 PRE_first_tail_x15_r0_body.s1709 = true
kernel_rfl bodyO1709 : PRE_first_tail_x15_r0_body.S1709.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1709.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1709 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1709 PRE_first_tail_x15_r0_body.S1709) = fun _ _ => true
kernel_rfl bodyAcc1711 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1711 PRE_first_tail_x15_r0_body.S1711) = fun _ _ => true
kernel_rfl bodyBr1712 : bridgeOf PRE_first_tail_x15_r0_body.s1712.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1711 : isHalt PRE_first_tail_x15_r0_body.s1711.ctl = false
kernel_rfl bodyTop1712 : noRetBlock PRE_first_tail_x15_r0_body.s1712 = true
kernel_rfl bodyCnt1709 : countersOkB PRE_first_tail_x15_r0_body.s1709 PRE_first_tail_x15_r0_body.s1712 = true

theorem bodyGlue177 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61616, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1698 PRE_first_tail_x15_r0_body.S1698)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61616, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1712 PRE_first_tail_x15_r0_body.S1712) 17025 :=
  (((((((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61616, 1174, 0, 936⟩) bodyAcc1698 PRE_first_tail_x15_r0_body.bodyRunSeg458 bodyAcc1700 bodyHalt1700 PRE_first_tail_x15_r0_body.bodyStepA459 bodyTop1701 (fun _ hm => bodyO1698 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1698).trans bodyInactive0) (bodyBr1701.trans bodyBr1698.symm) bodyCnt1698 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61616, 1174, 0, 936⟩) PRE_first_tail_x15_r0_body.sizeA459 PRE_first_tail_x15_r0_body.sizeArgsA459 PRE_first_tail_x15_r0_body.sizeSymA459 PRE_first_tail_x15_r0_body.sizeMlxA459 PRE_first_tail_x15_r0_body.sizePayA459 PRE_first_tail_x15_r0_body.sizeTaA459 PRE_first_tail_x15_r0_body.sizeDecA459 PRE_first_tail_x15_r0_body.sizePreA459 PRE_first_tail_x15_r0_body.bodyPatchB459 (fun _ hm => bodyO1701 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1701).trans bodyInactive0) (bodyBr1702.trans bodyBr1701.symm) bodyCnt1701 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61616, 1174, 0, 936⟩) bodyAcc1702 PRE_first_tail_x15_r0_body.bodyRunSeg459 bodyAcc1704 bodyHalt1704 PRE_first_tail_x15_r0_body.bodyStepA460 bodyTop1705 (fun _ hm => bodyO1702 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1702).trans bodyInactive0) (bodyBr1705.trans bodyBr1702.symm) bodyCnt1702 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61616, 1174, 0, 936⟩) PRE_first_tail_x15_r0_body.sizeA460 PRE_first_tail_x15_r0_body.sizeArgsA460 PRE_first_tail_x15_r0_body.sizeSymA460 PRE_first_tail_x15_r0_body.sizeMlxA460 PRE_first_tail_x15_r0_body.sizePayA460 PRE_first_tail_x15_r0_body.sizeTaA460 PRE_first_tail_x15_r0_body.sizeDecA460 PRE_first_tail_x15_r0_body.sizePreA460 PRE_first_tail_x15_r0_body.bodyPatchB460 (fun _ hm => bodyO1705 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1705).trans bodyInactive0) (bodyBr1706.trans bodyBr1705.symm) bodyCnt1705 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61616, 1174, 0, 936⟩) bodyAcc1706 PRE_first_tail_x15_r0_body.bodyRunSeg460 bodyAcc1707 bodyHalt1707 PRE_first_tail_x15_r0_body.bodyStepA461 bodyTop1708 (fun _ hm => bodyO1706 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1706).trans bodyInactive0) (bodyBr1708.trans bodyBr1706.symm) bodyCnt1706 (BodyTrail.ofTrack x0))).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61616, 1174, 0, 936⟩) PRE_first_tail_x15_r0_body.sizeA461 PRE_first_tail_x15_r0_body.sizeArgsA461 PRE_first_tail_x15_r0_body.sizeSymA461 PRE_first_tail_x15_r0_body.sizeMlxA461 PRE_first_tail_x15_r0_body.sizePayA461 PRE_first_tail_x15_r0_body.sizeTaA461 PRE_first_tail_x15_r0_body.sizeDecA461 PRE_first_tail_x15_r0_body.sizePreA461 PRE_first_tail_x15_r0_body.bodyPatchB461 (fun _ hm => bodyO1708 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1708).trans bodyInactive0) (bodyBr1709.trans bodyBr1708.symm) bodyCnt1708 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61616, 1174, 0, 936⟩) bodyAcc1709 PRE_first_tail_x15_r0_body.bodyRunSeg461 bodyAcc1711 bodyHalt1711 PRE_first_tail_x15_r0_body.bodyStepA462 bodyTop1712 (fun _ hm => bodyO1709 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1709).trans bodyInactive0) (bodyBr1712.trans bodyBr1709.symm) bodyCnt1709 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
