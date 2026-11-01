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

kernel_rfl bodyO975 : PRE_first_tail_x15_r0_body.S975.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S975.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr975 : bridgeOf PRE_first_tail_x15_r0_body.s975.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc975 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.S975) = fun _ _ => true
kernel_rfl bodyAcc976 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s976 PRE_first_tail_x15_r0_body.S976) = fun _ _ => true
kernel_rfl bodyBr977 : bridgeOf PRE_first_tail_x15_r0_body.s977.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt976 : isHalt PRE_first_tail_x15_r0_body.s976.ctl = false
kernel_rfl bodyTop977 : noRetBlock PRE_first_tail_x15_r0_body.s977 = true
kernel_rfl bodyCnt975 : countersOkB PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.s977 = true

theorem bodyGlue101 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨37276, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.S975)
      (bodyCut NB T tk π i x0 bodyΘ ⟨37276, 687, 0, 540⟩ bodyM PRE_first_tail_x15_r0_body.s977 PRE_first_tail_x15_r0_body.S977) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨37276, 687, 0, 540⟩) bodyAcc975 PRE_first_tail_x15_r0_body.bodyRunSeg263 bodyAcc976 bodyHalt976 PRE_first_tail_x15_r0_body.bodyStepA264 bodyTop977 (fun _ hm => bodyO975 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr975).trans bodyInactive0) (bodyBr977.trans bodyBr975.symm) bodyCnt975 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
