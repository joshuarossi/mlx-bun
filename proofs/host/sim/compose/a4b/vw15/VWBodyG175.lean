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

kernel_rfl bodyO1686 : PRE_first_tail_x15_r0_body.S1686.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1686.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1686 : bridgeOf PRE_first_tail_x15_r0_body.s1686.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1686 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1686 PRE_first_tail_x15_r0_body.S1686) = fun _ _ => true
kernel_rfl bodyAcc1687 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1687 PRE_first_tail_x15_r0_body.S1687) = fun _ _ => true
kernel_rfl bodyBr1688 : bridgeOf PRE_first_tail_x15_r0_body.s1688.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1687 : isHalt PRE_first_tail_x15_r0_body.s1687.ctl = false
kernel_rfl bodyTop1688 : noRetBlock PRE_first_tail_x15_r0_body.s1688 = true
kernel_rfl bodyCnt1686 : countersOkB PRE_first_tail_x15_r0_body.s1686 PRE_first_tail_x15_r0_body.s1688 = true
kernel_rfl bodyO1688 : PRE_first_tail_x15_r0_body.S1688.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1688.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1689 : bridgeOf PRE_first_tail_x15_r0_body.s1689.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1688 : countersOkB PRE_first_tail_x15_r0_body.s1688 PRE_first_tail_x15_r0_body.s1689 = true
kernel_rfl bodyO1689 : PRE_first_tail_x15_r0_body.S1689.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1689.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1689 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1689 PRE_first_tail_x15_r0_body.S1689) = fun _ _ => true
kernel_rfl bodyAcc1691 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1691 PRE_first_tail_x15_r0_body.S1691) = fun _ _ => true
kernel_rfl bodyBr1692 : bridgeOf PRE_first_tail_x15_r0_body.s1692.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1691 : isHalt PRE_first_tail_x15_r0_body.s1691.ctl = false
kernel_rfl bodyTop1692 : noRetBlock PRE_first_tail_x15_r0_body.s1692 = true
kernel_rfl bodyCnt1689 : countersOkB PRE_first_tail_x15_r0_body.s1689 PRE_first_tail_x15_r0_body.s1692 = true

theorem bodyGlue175 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61595, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1686 PRE_first_tail_x15_r0_body.S1686)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61595, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1692 PRE_first_tail_x15_r0_body.S1692) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61595, 1174, 0, 936⟩) bodyAcc1686 PRE_first_tail_x15_r0_body.bodyRunSeg455 bodyAcc1687 bodyHalt1687 PRE_first_tail_x15_r0_body.bodyStepA456 bodyTop1688 (fun _ hm => bodyO1686 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1686).trans bodyInactive0) (bodyBr1688.trans bodyBr1686.symm) bodyCnt1686 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61595, 1174, 0, 936⟩) PRE_first_tail_x15_r0_body.sizeA456 PRE_first_tail_x15_r0_body.sizeArgsA456 PRE_first_tail_x15_r0_body.sizeSymA456 PRE_first_tail_x15_r0_body.sizeMlxA456 PRE_first_tail_x15_r0_body.sizePayA456 PRE_first_tail_x15_r0_body.sizeTaA456 PRE_first_tail_x15_r0_body.sizeDecA456 PRE_first_tail_x15_r0_body.sizePreA456 PRE_first_tail_x15_r0_body.bodyPatchB456 (fun _ hm => bodyO1688 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1688).trans bodyInactive0) (bodyBr1689.trans bodyBr1688.symm) bodyCnt1688 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61595, 1174, 0, 936⟩) bodyAcc1689 PRE_first_tail_x15_r0_body.bodyRunSeg456 bodyAcc1691 bodyHalt1691 PRE_first_tail_x15_r0_body.bodyStepA457 bodyTop1692 (fun _ hm => bodyO1689 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1689).trans bodyInactive0) (bodyBr1692.trans bodyBr1689.symm) bodyCnt1689 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
