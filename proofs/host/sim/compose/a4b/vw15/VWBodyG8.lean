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

kernel_rfl bodyO84 : PRE_first_tail_x15_r0_body.S84.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S84.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr84 : bridgeOf PRE_first_tail_x15_r0_body.s84.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc84 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s84 PRE_first_tail_x15_r0_body.S84) = fun _ _ => true
kernel_rfl bodyAcc85 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s85 PRE_first_tail_x15_r0_body.S85) = fun _ _ => true
kernel_rfl bodyBr86 : bridgeOf PRE_first_tail_x15_r0_body.s86.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt85 : isHalt PRE_first_tail_x15_r0_body.s85.ctl = false
kernel_rfl bodyTop86 : noRetBlock PRE_first_tail_x15_r0_body.s86 = true
kernel_rfl bodyCnt84 : countersOkB PRE_first_tail_x15_r0_body.s84 PRE_first_tail_x15_r0_body.s86 = true

theorem bodyGlue8 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨7596, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s84 PRE_first_tail_x15_r0_body.S84)
      (bodyCut NB T tk π i x0 bodyΘ ⟨7596, 96, 0, 54⟩ bodyM PRE_first_tail_x15_r0_body.s86 PRE_first_tail_x15_r0_body.S86) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨7596, 96, 0, 54⟩) bodyAcc84 PRE_first_tail_x15_r0_body.bodyRunSeg23 bodyAcc85 bodyHalt85 PRE_first_tail_x15_r0_body.bodyStepA24 bodyTop86 (fun _ hm => bodyO84 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr84).trans bodyInactive0) (bodyBr86.trans bodyBr84.symm) bodyCnt84 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
