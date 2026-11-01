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

kernel_rfl bodyO457 : PRE_first_tail_x15_r0_body.S457.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S457.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr457 : bridgeOf PRE_first_tail_x15_r0_body.s457.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc457 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.S457) = fun _ _ => true
kernel_rfl bodyAcc458 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s458 PRE_first_tail_x15_r0_body.S458) = fun _ _ => true
kernel_rfl bodyBr459 : bridgeOf PRE_first_tail_x15_r0_body.s459.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt458 : isHalt PRE_first_tail_x15_r0_body.s458.ctl = false
kernel_rfl bodyTop459 : noRetBlock PRE_first_tail_x15_r0_body.s459 = true
kernel_rfl bodyCnt457 : countersOkB PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.s459 = true

theorem bodyGlue47 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨19511, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.S457)
      (bodyCut NB T tk π i x0 bodyΘ ⟨19511, 329, 0, 252⟩ bodyM PRE_first_tail_x15_r0_body.s459 PRE_first_tail_x15_r0_body.S459) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨19511, 329, 0, 252⟩) bodyAcc457 PRE_first_tail_x15_r0_body.bodyRunSeg123 bodyAcc458 bodyHalt458 PRE_first_tail_x15_r0_body.bodyStepA124 bodyTop459 (fun _ hm => bodyO457 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr457).trans bodyInactive0) (bodyBr459.trans bodyBr457.symm) bodyCnt457 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
