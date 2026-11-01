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

kernel_rfl bodyO55 : PRE_first_tail_x15_r0_body.S55.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S55.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr55 : bridgeOf PRE_first_tail_x15_r0_body.s55.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc55 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s55 PRE_first_tail_x15_r0_body.S55) = fun _ _ => true
kernel_rfl bodyAcc56 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s56 PRE_first_tail_x15_r0_body.S56) = fun _ _ => true
kernel_rfl bodyBr57 : bridgeOf PRE_first_tail_x15_r0_body.s57.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt56 : isHalt PRE_first_tail_x15_r0_body.s56.ctl = false
kernel_rfl bodyTop57 : noRetBlock PRE_first_tail_x15_r0_body.s57 = true
kernel_rfl bodyCnt55 : countersOkB PRE_first_tail_x15_r0_body.s55 PRE_first_tail_x15_r0_body.s57 = true

theorem bodyGlue5 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨6435, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s55 PRE_first_tail_x15_r0_body.S55)
      (bodyCut NB T tk π i x0 bodyΘ ⟨6435, 71, 0, 36⟩ bodyM PRE_first_tail_x15_r0_body.s57 PRE_first_tail_x15_r0_body.S57) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨6435, 71, 0, 36⟩) bodyAcc55 PRE_first_tail_x15_r0_body.bodyRunSeg15 bodyAcc56 bodyHalt56 PRE_first_tail_x15_r0_body.bodyStepA16 bodyTop57 (fun _ hm => bodyO55 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr55).trans bodyInactive0) (bodyBr57.trans bodyBr55.symm) bodyCnt55 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
