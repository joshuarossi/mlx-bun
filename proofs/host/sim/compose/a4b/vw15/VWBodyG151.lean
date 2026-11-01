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

kernel_rfl bodyO1456 : PRE_first_tail_x15_r0_body.S1456.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1456.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1456 : bridgeOf PRE_first_tail_x15_r0_body.s1456.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1456 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1456 PRE_first_tail_x15_r0_body.S1456) = fun _ _ => true
kernel_rfl bodyAcc1457 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1457 PRE_first_tail_x15_r0_body.S1457) = fun _ _ => true
kernel_rfl bodyBr1458 : bridgeOf PRE_first_tail_x15_r0_body.s1458.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1457 : isHalt PRE_first_tail_x15_r0_body.s1457.ctl = false
kernel_rfl bodyTop1458 : noRetBlock PRE_first_tail_x15_r0_body.s1458 = true
kernel_rfl bodyCnt1456 : countersOkB PRE_first_tail_x15_r0_body.s1456 PRE_first_tail_x15_r0_body.s1458 = true
kernel_rfl bodyO1458 : PRE_first_tail_x15_r0_body.S1458.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1458.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1459 : bridgeOf PRE_first_tail_x15_r0_body.s1459.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1458 : countersOkB PRE_first_tail_x15_r0_body.s1458 PRE_first_tail_x15_r0_body.s1459 = true
kernel_rfl bodyO1459 : PRE_first_tail_x15_r0_body.S1459.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1459.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1459 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1459 PRE_first_tail_x15_r0_body.S1459) = fun _ _ => true
kernel_rfl bodyAcc1461 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1461 PRE_first_tail_x15_r0_body.S1461) = fun _ _ => true
kernel_rfl bodyBr1462 : bridgeOf PRE_first_tail_x15_r0_body.s1462.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1461 : isHalt PRE_first_tail_x15_r0_body.s1461.ctl = false
kernel_rfl bodyTop1462 : noRetBlock PRE_first_tail_x15_r0_body.s1462 = true
kernel_rfl bodyCnt1459 : countersOkB PRE_first_tail_x15_r0_body.s1459 PRE_first_tail_x15_r0_body.s1462 = true

theorem bodyGlue151 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53869, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1456 PRE_first_tail_x15_r0_body.S1456)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53869, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1462 PRE_first_tail_x15_r0_body.S1462) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53869, 1020, 0, 810⟩) bodyAcc1456 PRE_first_tail_x15_r0_body.bodyRunSeg393 bodyAcc1457 bodyHalt1457 PRE_first_tail_x15_r0_body.bodyStepA394 bodyTop1458 (fun _ hm => bodyO1456 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1456).trans bodyInactive0) (bodyBr1458.trans bodyBr1456.symm) bodyCnt1456 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53869, 1020, 0, 810⟩) PRE_first_tail_x15_r0_body.sizeA394 PRE_first_tail_x15_r0_body.sizeArgsA394 PRE_first_tail_x15_r0_body.sizeSymA394 PRE_first_tail_x15_r0_body.sizeMlxA394 PRE_first_tail_x15_r0_body.sizePayA394 PRE_first_tail_x15_r0_body.sizeTaA394 PRE_first_tail_x15_r0_body.sizeDecA394 PRE_first_tail_x15_r0_body.sizePreA394 PRE_first_tail_x15_r0_body.bodyPatchB394 (fun _ hm => bodyO1458 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1458).trans bodyInactive0) (bodyBr1459.trans bodyBr1458.symm) bodyCnt1458 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53869, 1020, 0, 810⟩) bodyAcc1459 PRE_first_tail_x15_r0_body.bodyRunSeg394 bodyAcc1461 bodyHalt1461 PRE_first_tail_x15_r0_body.bodyStepA395 bodyTop1462 (fun _ hm => bodyO1459 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1459).trans bodyInactive0) (bodyBr1462.trans bodyBr1459.symm) bodyCnt1459 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
