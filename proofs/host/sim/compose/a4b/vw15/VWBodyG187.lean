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

kernel_rfl bodyO1801 : PRE_first_tail_x15_r0_body.S1801.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1801.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1801 : bridgeOf PRE_first_tail_x15_r0_body.s1801.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1801 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1801 PRE_first_tail_x15_r0_body.S1801) = fun _ _ => true
kernel_rfl bodyAcc1802 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1802 PRE_first_tail_x15_r0_body.S1802) = fun _ _ => true
kernel_rfl bodyBr1803 : bridgeOf PRE_first_tail_x15_r0_body.s1803.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1802 : isHalt PRE_first_tail_x15_r0_body.s1802.ctl = false
kernel_rfl bodyTop1803 : noRetBlock PRE_first_tail_x15_r0_body.s1803 = true
kernel_rfl bodyCnt1801 : countersOkB PRE_first_tail_x15_r0_body.s1801 PRE_first_tail_x15_r0_body.s1803 = true
kernel_rfl bodyO1803 : PRE_first_tail_x15_r0_body.S1803.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1803.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1804 : bridgeOf PRE_first_tail_x15_r0_body.s1804.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1803 : countersOkB PRE_first_tail_x15_r0_body.s1803 PRE_first_tail_x15_r0_body.s1804 = true
kernel_rfl bodyO1804 : PRE_first_tail_x15_r0_body.S1804.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1804.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1804 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1804 PRE_first_tail_x15_r0_body.S1804) = fun _ _ => true
kernel_rfl bodyAcc1806 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1806 PRE_first_tail_x15_r0_body.S1806) = fun _ _ => true
kernel_rfl bodyBr1807 : bridgeOf PRE_first_tail_x15_r0_body.s1807.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1806 : isHalt PRE_first_tail_x15_r0_body.s1806.ctl = false
kernel_rfl bodyTop1807 : noRetBlock PRE_first_tail_x15_r0_body.s1807 = true
kernel_rfl bodyCnt1804 : countersOkB PRE_first_tail_x15_r0_body.s1804 PRE_first_tail_x15_r0_body.s1807 = true

theorem bodyGlue187 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨65476, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1801 PRE_first_tail_x15_r0_body.S1801)
      (bodyCut NB T tk π i x0 bodyΘ ⟨65476, 1251, 0, 999⟩ bodyM PRE_first_tail_x15_r0_body.s1807 PRE_first_tail_x15_r0_body.S1807) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65476, 1251, 0, 999⟩) bodyAcc1801 PRE_first_tail_x15_r0_body.bodyRunSeg486 bodyAcc1802 bodyHalt1802 PRE_first_tail_x15_r0_body.bodyStepA487 bodyTop1803 (fun _ hm => bodyO1801 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1801).trans bodyInactive0) (bodyBr1803.trans bodyBr1801.symm) bodyCnt1801 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65476, 1251, 0, 999⟩) PRE_first_tail_x15_r0_body.sizeA487 PRE_first_tail_x15_r0_body.sizeArgsA487 PRE_first_tail_x15_r0_body.sizeSymA487 PRE_first_tail_x15_r0_body.sizeMlxA487 PRE_first_tail_x15_r0_body.sizePayA487 PRE_first_tail_x15_r0_body.sizeTaA487 PRE_first_tail_x15_r0_body.sizeDecA487 PRE_first_tail_x15_r0_body.sizePreA487 PRE_first_tail_x15_r0_body.bodyPatchB487 (fun _ hm => bodyO1803 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1803).trans bodyInactive0) (bodyBr1804.trans bodyBr1803.symm) bodyCnt1803 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨65476, 1251, 0, 999⟩) bodyAcc1804 PRE_first_tail_x15_r0_body.bodyRunSeg487 bodyAcc1806 bodyHalt1806 PRE_first_tail_x15_r0_body.bodyStepA488 bodyTop1807 (fun _ hm => bodyO1804 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1804).trans bodyInactive0) (bodyBr1807.trans bodyBr1804.symm) bodyCnt1804 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
