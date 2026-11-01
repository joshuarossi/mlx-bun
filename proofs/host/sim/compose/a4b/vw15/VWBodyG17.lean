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

kernel_rfl bodyO170 : PRE_first_tail_x15_r0_body.S170.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S170.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr170 : bridgeOf PRE_first_tail_x15_r0_body.s170.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc170 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s170 PRE_first_tail_x15_r0_body.S170) = fun _ _ => true
kernel_rfl bodyAcc171 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s171 PRE_first_tail_x15_r0_body.S171) = fun _ _ => true
kernel_rfl bodyBr172 : bridgeOf PRE_first_tail_x15_r0_body.s172.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt171 : isHalt PRE_first_tail_x15_r0_body.s171.ctl = false
kernel_rfl bodyTop172 : noRetBlock PRE_first_tail_x15_r0_body.s172 = true
kernel_rfl bodyCnt170 : countersOkB PRE_first_tail_x15_r0_body.s170 PRE_first_tail_x15_r0_body.s172 = true

theorem bodyGlue17 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨10280, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s170 PRE_first_tail_x15_r0_body.S170)
      (bodyCut NB T tk π i x0 bodyΘ ⟨10280, 148, 0, 99⟩ bodyM PRE_first_tail_x15_r0_body.s172 PRE_first_tail_x15_r0_body.S172) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨10280, 148, 0, 99⟩) bodyAcc170 PRE_first_tail_x15_r0_body.bodyRunSeg46 bodyAcc171 bodyHalt171 PRE_first_tail_x15_r0_body.bodyStepA47 bodyTop172 (fun _ hm => bodyO170 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr170).trans bodyInactive0) (bodyBr172.trans bodyBr170.symm) bodyCnt170 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
