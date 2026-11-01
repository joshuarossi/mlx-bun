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

kernel_rfl bodyO802 : PRE_first_tail_x15_r0_body.S802.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S802.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr802 : bridgeOf PRE_first_tail_x15_r0_body.s802.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc802 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s802 PRE_first_tail_x15_r0_body.S802) = fun _ _ => true
kernel_rfl bodyAcc803 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s803 PRE_first_tail_x15_r0_body.S803) = fun _ _ => true
kernel_rfl bodyBr804 : bridgeOf PRE_first_tail_x15_r0_body.s804.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt803 : isHalt PRE_first_tail_x15_r0_body.s803.ctl = false
kernel_rfl bodyTop804 : noRetBlock PRE_first_tail_x15_r0_body.s804 = true
kernel_rfl bodyCnt802 : countersOkB PRE_first_tail_x15_r0_body.s802 PRE_first_tail_x15_r0_body.s804 = true

theorem bodyGlue83 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨31082, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s802 PRE_first_tail_x15_r0_body.S802)
      (bodyCut NB T tk π i x0 bodyΘ ⟨31082, 560, 0, 441⟩ bodyM PRE_first_tail_x15_r0_body.s804 PRE_first_tail_x15_r0_body.S804) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨31082, 560, 0, 441⟩) bodyAcc802 PRE_first_tail_x15_r0_body.bodyRunSeg216 bodyAcc803 bodyHalt803 PRE_first_tail_x15_r0_body.bodyStepA217 bodyTop804 (fun _ hm => bodyO802 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr802).trans bodyInactive0) (bodyBr804.trans bodyBr802.symm) bodyCnt802 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
