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

kernel_rfl bodyO544 : PRE_first_tail_x15_r0_body.S544.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S544.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr544 : bridgeOf PRE_first_tail_x15_r0_body.s544.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc544 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.S544) = fun _ _ => true
kernel_rfl bodyAcc545 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s545 PRE_first_tail_x15_r0_body.S545) = fun _ _ => true
kernel_rfl bodyBr546 : bridgeOf PRE_first_tail_x15_r0_body.s546.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt545 : isHalt PRE_first_tail_x15_r0_body.s545.ctl = false
kernel_rfl bodyTop546 : noRetBlock PRE_first_tail_x15_r0_body.s546 = true
kernel_rfl bodyCnt544 : countersOkB PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.s546 = true

theorem bodyGlue56 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23021, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s544 PRE_first_tail_x15_r0_body.S544)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23021, 404, 0, 306⟩ bodyM PRE_first_tail_x15_r0_body.s546 PRE_first_tail_x15_r0_body.S546) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23021, 404, 0, 306⟩) bodyAcc544 PRE_first_tail_x15_r0_body.bodyRunSeg147 bodyAcc545 bodyHalt545 PRE_first_tail_x15_r0_body.bodyStepA148 bodyTop546 (fun _ hm => bodyO544 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr544).trans bodyInactive0) (bodyBr546.trans bodyBr544.symm) bodyCnt544 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
