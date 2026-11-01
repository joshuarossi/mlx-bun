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

kernel_rfl bodyO285 : PRE_first_tail_x15_r0_body.S285.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S285.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr285 : bridgeOf PRE_first_tail_x15_r0_body.s285.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc285 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s285 PRE_first_tail_x15_r0_body.S285) = fun _ _ => true
kernel_rfl bodyAcc286 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s286 PRE_first_tail_x15_r0_body.S286) = fun _ _ => true
kernel_rfl bodyBr287 : bridgeOf PRE_first_tail_x15_r0_body.s287.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt286 : isHalt PRE_first_tail_x15_r0_body.s286.ctl = false
kernel_rfl bodyTop287 : noRetBlock PRE_first_tail_x15_r0_body.s287 = true
kernel_rfl bodyCnt285 : countersOkB PRE_first_tail_x15_r0_body.s285 PRE_first_tail_x15_r0_body.s287 = true

theorem bodyGlue29 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨14125, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s285 PRE_first_tail_x15_r0_body.S285)
      (bodyCut NB T tk π i x0 bodyΘ ⟨14125, 225, 0, 162⟩ bodyM PRE_first_tail_x15_r0_body.s287 PRE_first_tail_x15_r0_body.S287) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨14125, 225, 0, 162⟩) bodyAcc285 PRE_first_tail_x15_r0_body.bodyRunSeg77 bodyAcc286 bodyHalt286 PRE_first_tail_x15_r0_body.bodyStepA78 bodyTop287 (fun _ hm => bodyO285 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr285).trans bodyInactive0) (bodyBr287.trans bodyBr285.symm) bodyCnt285 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
