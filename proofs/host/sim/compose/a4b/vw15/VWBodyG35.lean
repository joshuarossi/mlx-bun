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

kernel_rfl bodyO342 : PRE_first_tail_x15_r0_body.S342.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S342.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr342 : bridgeOf PRE_first_tail_x15_r0_body.s342.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc342 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.S342) = fun _ _ => true
kernel_rfl bodyAcc343 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s343 PRE_first_tail_x15_r0_body.S343) = fun _ _ => true
kernel_rfl bodyBr344 : bridgeOf PRE_first_tail_x15_r0_body.s344.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt343 : isHalt PRE_first_tail_x15_r0_body.s343.ctl = false
kernel_rfl bodyTop344 : noRetBlock PRE_first_tail_x15_r0_body.s344 = true
kernel_rfl bodyCnt342 : countersOkB PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.s344 = true

theorem bodyGlue35 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨15648, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.S342)
      (bodyCut NB T tk π i x0 bodyΘ ⟨15648, 252, 0, 189⟩ bodyM PRE_first_tail_x15_r0_body.s344 PRE_first_tail_x15_r0_body.S344) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨15648, 252, 0, 189⟩) bodyAcc342 PRE_first_tail_x15_r0_body.bodyRunSeg92 bodyAcc343 bodyHalt343 PRE_first_tail_x15_r0_body.bodyStepA93 bodyTop344 (fun _ hm => bodyO342 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr342).trans bodyInactive0) (bodyBr344.trans bodyBr342.symm) bodyCnt342 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
