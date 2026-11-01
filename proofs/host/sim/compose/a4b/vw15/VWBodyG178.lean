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

kernel_rfl bodyO1714 : PRE_first_tail_x15_r0_body.S1714.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1714.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1714 : bridgeOf PRE_first_tail_x15_r0_body.s1714.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1714 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1714 PRE_first_tail_x15_r0_body.S1714) = fun _ _ => true
kernel_rfl bodyAcc1715 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1715 PRE_first_tail_x15_r0_body.S1715) = fun _ _ => true
kernel_rfl bodyBr1716 : bridgeOf PRE_first_tail_x15_r0_body.s1716.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1715 : isHalt PRE_first_tail_x15_r0_body.s1715.ctl = false
kernel_rfl bodyTop1716 : noRetBlock PRE_first_tail_x15_r0_body.s1716 = true
kernel_rfl bodyCnt1714 : countersOkB PRE_first_tail_x15_r0_body.s1714 PRE_first_tail_x15_r0_body.s1716 = true
kernel_rfl bodyO1716 : PRE_first_tail_x15_r0_body.S1716.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1716.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1717 : bridgeOf PRE_first_tail_x15_r0_body.s1717.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1716 : countersOkB PRE_first_tail_x15_r0_body.s1716 PRE_first_tail_x15_r0_body.s1717 = true
kernel_rfl bodyO1717 : PRE_first_tail_x15_r0_body.S1717.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1717.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1717 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1717 PRE_first_tail_x15_r0_body.S1717) = fun _ _ => true
kernel_rfl bodyAcc1719 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1719 PRE_first_tail_x15_r0_body.S1719) = fun _ _ => true
kernel_rfl bodyBr1720 : bridgeOf PRE_first_tail_x15_r0_body.s1720.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1719 : isHalt PRE_first_tail_x15_r0_body.s1719.ctl = false
kernel_rfl bodyTop1720 : noRetBlock PRE_first_tail_x15_r0_body.s1720 = true
kernel_rfl bodyCnt1717 : countersOkB PRE_first_tail_x15_r0_body.s1717 PRE_first_tail_x15_r0_body.s1720 = true

theorem bodyGlue178 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61966, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1714 PRE_first_tail_x15_r0_body.S1714)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61966, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1720 PRE_first_tail_x15_r0_body.S1720) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61966, 1176, 0, 945⟩) bodyAcc1714 PRE_first_tail_x15_r0_body.bodyRunSeg462 bodyAcc1715 bodyHalt1715 PRE_first_tail_x15_r0_body.bodyStepA463 bodyTop1716 (fun _ hm => bodyO1714 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1714).trans bodyInactive0) (bodyBr1716.trans bodyBr1714.symm) bodyCnt1714 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61966, 1176, 0, 945⟩) PRE_first_tail_x15_r0_body.sizeA463 PRE_first_tail_x15_r0_body.sizeArgsA463 PRE_first_tail_x15_r0_body.sizeSymA463 PRE_first_tail_x15_r0_body.sizeMlxA463 PRE_first_tail_x15_r0_body.sizePayA463 PRE_first_tail_x15_r0_body.sizeTaA463 PRE_first_tail_x15_r0_body.sizeDecA463 PRE_first_tail_x15_r0_body.sizePreA463 PRE_first_tail_x15_r0_body.bodyPatchB463 (fun _ hm => bodyO1716 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1716).trans bodyInactive0) (bodyBr1717.trans bodyBr1716.symm) bodyCnt1716 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61966, 1176, 0, 945⟩) bodyAcc1717 PRE_first_tail_x15_r0_body.bodyRunSeg463 bodyAcc1719 bodyHalt1719 PRE_first_tail_x15_r0_body.bodyStepA464 bodyTop1720 (fun _ hm => bodyO1717 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1717).trans bodyInactive0) (bodyBr1720.trans bodyBr1717.symm) bodyCnt1717 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
