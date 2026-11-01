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

kernel_rfl bodyO486 : PRE_first_tail_x15_r0_body.S486.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S486.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr486 : bridgeOf PRE_first_tail_x15_r0_body.s486.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc486 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.S486) = fun _ _ => true
kernel_rfl bodyAcc487 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s487 PRE_first_tail_x15_r0_body.S487) = fun _ _ => true
kernel_rfl bodyBr488 : bridgeOf PRE_first_tail_x15_r0_body.s488.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt487 : isHalt PRE_first_tail_x15_r0_body.s487.ctl = false
kernel_rfl bodyTop488 : noRetBlock PRE_first_tail_x15_r0_body.s488 = true
kernel_rfl bodyCnt486 : countersOkB PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.s488 = true

theorem bodyGlue50 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨20681, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s486 PRE_first_tail_x15_r0_body.S486)
      (bodyCut NB T tk π i x0 bodyΘ ⟨20681, 354, 0, 270⟩ bodyM PRE_first_tail_x15_r0_body.s488 PRE_first_tail_x15_r0_body.S488) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨20681, 354, 0, 270⟩) bodyAcc486 PRE_first_tail_x15_r0_body.bodyRunSeg131 bodyAcc487 bodyHalt487 PRE_first_tail_x15_r0_body.bodyStepA132 bodyTop488 (fun _ hm => bodyO486 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr486).trans bodyInactive0) (bodyBr488.trans bodyBr486.symm) bodyCnt486 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
