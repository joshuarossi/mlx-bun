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

kernel_rfl bodyO400 : PRE_first_tail_x15_r0_body.S400.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S400.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr400 : bridgeOf PRE_first_tail_x15_r0_body.s400.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc400 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.S400) = fun _ _ => true
kernel_rfl bodyAcc401 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s401 PRE_first_tail_x15_r0_body.S401) = fun _ _ => true
kernel_rfl bodyBr402 : bridgeOf PRE_first_tail_x15_r0_body.s402.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt401 : isHalt PRE_first_tail_x15_r0_body.s401.ctl = false
kernel_rfl bodyTop402 : noRetBlock PRE_first_tail_x15_r0_body.s402 = true
kernel_rfl bodyCnt400 : countersOkB PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.s402 = true

theorem bodyGlue41 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨17979, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s400 PRE_first_tail_x15_r0_body.S400)
      (bodyCut NB T tk π i x0 bodyΘ ⟨17979, 302, 0, 225⟩ bodyM PRE_first_tail_x15_r0_body.s402 PRE_first_tail_x15_r0_body.S402) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨17979, 302, 0, 225⟩) bodyAcc400 PRE_first_tail_x15_r0_body.bodyRunSeg108 bodyAcc401 bodyHalt401 PRE_first_tail_x15_r0_body.bodyStepA109 bodyTop402 (fun _ hm => bodyO400 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr400).trans bodyInactive0) (bodyBr402.trans bodyBr400.symm) bodyCnt400 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
