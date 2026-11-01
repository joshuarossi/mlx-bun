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

kernel_rfl bodyO478 : PRE_first_tail_x15_r0_body.S478.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S478.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr478 : bridgeOf PRE_first_tail_x15_r0_body.s478.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc478 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.S478) = fun _ _ => true
kernel_rfl bodyAcc479 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s479 PRE_first_tail_x15_r0_body.S479) = fun _ _ => true
kernel_rfl bodyBr480 : bridgeOf PRE_first_tail_x15_r0_body.s480.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt479 : isHalt PRE_first_tail_x15_r0_body.s479.ctl = false
kernel_rfl bodyTop480 : noRetBlock PRE_first_tail_x15_r0_body.s480 = true
kernel_rfl bodyCnt478 : countersOkB PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.s480 = true
kernel_rfl bodyO480 : PRE_first_tail_x15_r0_body.S480.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S480.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr481 : bridgeOf PRE_first_tail_x15_r0_body.s481.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyCnt480 : countersOkB PRE_first_tail_x15_r0_body.s480 PRE_first_tail_x15_r0_body.s481 = true
kernel_rfl bodyO481 : PRE_first_tail_x15_r0_body.S481.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S481.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyAcc481 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s481 PRE_first_tail_x15_r0_body.S481) = fun _ _ => true
kernel_rfl bodyAcc483 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s483 PRE_first_tail_x15_r0_body.S483) = fun _ _ => true
kernel_rfl bodyBr484 : bridgeOf PRE_first_tail_x15_r0_body.s484.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt483 : isHalt PRE_first_tail_x15_r0_body.s483.ctl = false
kernel_rfl bodyTop484 : noRetBlock PRE_first_tail_x15_r0_body.s484 = true
kernel_rfl bodyCnt481 : countersOkB PRE_first_tail_x15_r0_body.s481 PRE_first_tail_x15_r0_body.s484 = true

theorem bodyGlue49 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20679, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.S478)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20679, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s484 PRE_first_tail_x15_r0_body.S484) 4909 :=
  (((bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20679, 354, 0, 270⟩) bodyAcc478 PRE_first_tail_x15_r0_body.bodyRunSeg129 bodyAcc479 bodyHalt479 PRE_first_tail_x15_r0_body.bodyStepA130 bodyTop480 (fun _ hm => bodyO478 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr478).trans bodyInactive0) (bodyBr480.trans bodyBr478.symm) bodyCnt478 (BodyTrail.ofTrack x0)).trans (bodySize (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20679, 354, 0, 270⟩) PRE_first_tail_x15_r0_body.sizeA130 PRE_first_tail_x15_r0_body.sizeArgsA130 PRE_first_tail_x15_r0_body.sizeSymA130 PRE_first_tail_x15_r0_body.sizeMlxA130 PRE_first_tail_x15_r0_body.sizePayA130 PRE_first_tail_x15_r0_body.sizeTaA130 PRE_first_tail_x15_r0_body.sizeDecA130 PRE_first_tail_x15_r0_body.sizePreA130 PRE_first_tail_x15_r0_body.bodyPatchB130 (fun _ hm => bodyO480 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr480).trans bodyInactive0) (bodyBr481.trans bodyBr480.symm) bodyCnt480 (BodyTrail.ofTrack x0))).trans (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20679, 354, 0, 270⟩) bodyAcc481 PRE_first_tail_x15_r0_body.bodyRunSeg130 bodyAcc483 bodyHalt483 PRE_first_tail_x15_r0_body.bodyStepA131 bodyTop484 (fun _ hm => bodyO481 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr481).trans bodyInactive0) (bodyBr484.trans bodyBr481.symm) bodyCnt481 (BodyTrail.ofTrack x0))).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
