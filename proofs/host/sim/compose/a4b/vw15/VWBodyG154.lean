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

kernel_rfl bodyO1484 : PRE_first_tail_x15_r0_body.S1484.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1484.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1484 : bridgeOf PRE_first_tail_x15_r0_body.s1484.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1484 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1484 PRE_first_tail_x15_r0_body.S1484) = fun _ _ => true
kernel_rfl bodyAcc1485 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1485 PRE_first_tail_x15_r0_body.S1485) = fun _ _ => true
kernel_rfl bodyBr1486 : bridgeOf PRE_first_tail_x15_r0_body.s1486.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1485 : isHalt PRE_first_tail_x15_r0_body.s1485.ctl = false
kernel_rfl bodyTop1486 : noRetBlock PRE_first_tail_x15_r0_body.s1486 = true
kernel_rfl bodyCnt1484 : countersOkB PRE_first_tail_x15_r0_body.s1484 PRE_first_tail_x15_r0_body.s1486 = true
kernel_rfl bodyO1486 : PRE_first_tail_x15_r0_body.S1486.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1486.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1487 : bridgeOf PRE_first_tail_x15_r0_body.s1487.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt1486 : countersOkB PRE_first_tail_x15_r0_body.s1486 PRE_first_tail_x15_r0_body.s1487 = true
kernel_rfl bodyO1487 : PRE_first_tail_x15_r0_body.S1487.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1487.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc1487 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1487 PRE_first_tail_x15_r0_body.S1487) = fun _ _ => true
kernel_rfl bodyAcc1489 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1489 PRE_first_tail_x15_r0_body.S1489) = fun _ _ => true
kernel_rfl bodyBr1490 : bridgeOf PRE_first_tail_x15_r0_body.s1490.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1489 : isHalt PRE_first_tail_x15_r0_body.s1489.ctl = false
kernel_rfl bodyTop1490 : noRetBlock PRE_first_tail_x15_r0_body.s1490 = true
kernel_rfl bodyCnt1487 : countersOkB PRE_first_tail_x15_r0_body.s1487 PRE_first_tail_x15_r0_body.s1490 = true

theorem bodyGlue154 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨54231, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1484 PRE_first_tail_x15_r0_body.S1484)
      (bodyCut NB T tk π i x0 bodyΘ ⟨54231, 1022, 0, 819⟩ bodyM PRE_first_tail_x15_r0_body.s1490 PRE_first_tail_x15_r0_body.S1490) 5782 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54231, 1022, 0, 819⟩) bodyAcc1484 PRE_first_tail_x15_r0_body.bodyRunSeg400 bodyAcc1485 bodyHalt1485 PRE_first_tail_x15_r0_body.bodyStepA401 bodyTop1486 (fun _ hm => bodyO1484 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1484).trans bodyInactive0) (bodyBr1486.trans bodyBr1484.symm) bodyCnt1484 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54231, 1022, 0, 819⟩) PRE_first_tail_x15_r0_body.sizeA401 PRE_first_tail_x15_r0_body.sizeArgsA401 PRE_first_tail_x15_r0_body.sizeSymA401 PRE_first_tail_x15_r0_body.sizeMlxA401 PRE_first_tail_x15_r0_body.sizePayA401 PRE_first_tail_x15_r0_body.sizeTaA401 PRE_first_tail_x15_r0_body.sizeDecA401 PRE_first_tail_x15_r0_body.sizePreA401 PRE_first_tail_x15_r0_body.bodyPatchB401 (fun _ hm => bodyO1486 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1486).trans bodyInactive0) (bodyBr1487.trans bodyBr1486.symm) bodyCnt1486 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨54231, 1022, 0, 819⟩) bodyAcc1487 PRE_first_tail_x15_r0_body.bodyRunSeg401 bodyAcc1489 bodyHalt1489 PRE_first_tail_x15_r0_body.bodyStepA402 bodyTop1490 (fun _ hm => bodyO1487 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1487).trans bodyInactive0) (bodyBr1490.trans bodyBr1487.symm) bodyCnt1487 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
