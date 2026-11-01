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

kernel_rfl bodyO946 : PRE_first_tail_x15_r0_body.S946.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S946.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr946 : bridgeOf PRE_first_tail_x15_r0_body.s946.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc946 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s946 PRE_first_tail_x15_r0_body.S946) = fun _ _ => true
kernel_rfl bodyAcc947 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s947 PRE_first_tail_x15_r0_body.S947) = fun _ _ => true
kernel_rfl bodyBr948 : bridgeOf PRE_first_tail_x15_r0_body.s948.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt947 : isHalt PRE_first_tail_x15_r0_body.s947.ctl = false
kernel_rfl bodyTop948 : noRetBlock PRE_first_tail_x15_r0_body.s948 = true
kernel_rfl bodyCnt946 : countersOkB PRE_first_tail_x15_r0_body.s946 PRE_first_tail_x15_r0_body.s948 = true

theorem bodyGlue98 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨36106, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s946 PRE_first_tail_x15_r0_body.S946)
      (bodyCut NB T tk π i x0 bodyΘ ⟨36106, 662, 0, 522⟩ bodyM PRE_first_tail_x15_r0_body.s948 PRE_first_tail_x15_r0_body.S948) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨36106, 662, 0, 522⟩) bodyAcc946 PRE_first_tail_x15_r0_body.bodyRunSeg255 bodyAcc947 bodyHalt947 PRE_first_tail_x15_r0_body.bodyStepA256 bodyTop948 (fun _ hm => bodyO946 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr946).trans bodyInactive0) (bodyBr948.trans bodyBr946.symm) bodyCnt946 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
