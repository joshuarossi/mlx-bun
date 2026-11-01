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

kernel_rfl bodyO745 : PRE_first_tail_x15_r0_body.S745.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S745.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr745 : bridgeOf PRE_first_tail_x15_r0_body.s745.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc745 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s745 PRE_first_tail_x15_r0_body.S745) = fun _ _ => true
kernel_rfl bodyAcc746 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s746 PRE_first_tail_x15_r0_body.S746) = fun _ _ => true
kernel_rfl bodyBr747 : bridgeOf PRE_first_tail_x15_r0_body.s747.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt746 : isHalt PRE_first_tail_x15_r0_body.s746.ctl = false
kernel_rfl bodyTop747 : noRetBlock PRE_first_tail_x15_r0_body.s747 = true
kernel_rfl bodyCnt745 : countersOkB PRE_first_tail_x15_r0_body.s745 PRE_first_tail_x15_r0_body.s747 = true

theorem bodyGlue77 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨29559, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s745 PRE_first_tail_x15_r0_body.S745)
      (bodyCut NB T tk π i x0 bodyΘ ⟨29559, 533, 0, 414⟩ bodyM PRE_first_tail_x15_r0_body.s747 PRE_first_tail_x15_r0_body.S747) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨29559, 533, 0, 414⟩) bodyAcc745 PRE_first_tail_x15_r0_body.bodyRunSeg201 bodyAcc746 bodyHalt746 PRE_first_tail_x15_r0_body.bodyStepA202 bodyTop747 (fun _ hm => bodyO745 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr745).trans bodyInactive0) (bodyBr747.trans bodyBr745.symm) bodyCnt745 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
