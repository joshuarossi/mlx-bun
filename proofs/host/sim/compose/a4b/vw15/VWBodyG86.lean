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

kernel_rfl bodyO831 : PRE_first_tail_x15_r0_body.S831.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S831.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr831 : bridgeOf PRE_first_tail_x15_r0_body.s831.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc831 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.S831) = fun _ _ => true
kernel_rfl bodyAcc832 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s832 PRE_first_tail_x15_r0_body.S832) = fun _ _ => true
kernel_rfl bodyBr833 : bridgeOf PRE_first_tail_x15_r0_body.s833.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt832 : isHalt PRE_first_tail_x15_r0_body.s832.ctl = false
kernel_rfl bodyTop833 : noRetBlock PRE_first_tail_x15_r0_body.s833 = true
kernel_rfl bodyCnt831 : countersOkB PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.s833 = true

theorem bodyGlue86 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨32243, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s831 PRE_first_tail_x15_r0_body.S831)
      (bodyCut NB T tk π i x0 bodyΘ ⟨32243, 585, 0, 459⟩ bodyM PRE_first_tail_x15_r0_body.s833 PRE_first_tail_x15_r0_body.S833) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨32243, 585, 0, 459⟩) bodyAcc831 PRE_first_tail_x15_r0_body.bodyRunSeg224 bodyAcc832 bodyHalt832 PRE_first_tail_x15_r0_body.bodyStepA225 bodyTop833 (fun _ hm => bodyO831 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr831).trans bodyInactive0) (bodyBr833.trans bodyBr831.symm) bodyCnt831 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
