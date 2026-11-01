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

kernel_rfl bodyO371 : PRE_first_tail_x15_r0_body.S371.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S371.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr371 : bridgeOf PRE_first_tail_x15_r0_body.s371.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc371 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.S371) = fun _ _ => true
kernel_rfl bodyAcc372 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s372 PRE_first_tail_x15_r0_body.S372) = fun _ _ => true
kernel_rfl bodyBr373 : bridgeOf PRE_first_tail_x15_r0_body.s373.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt372 : isHalt PRE_first_tail_x15_r0_body.s372.ctl = false
kernel_rfl bodyTop373 : noRetBlock PRE_first_tail_x15_r0_body.s373 = true
kernel_rfl bodyCnt371 : countersOkB PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.s373 = true

theorem bodyGlue38 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨16818, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.S371)
      (bodyCut NB T tk π i x0 bodyΘ ⟨16818, 277, 0, 207⟩ bodyM PRE_first_tail_x15_r0_body.s373 PRE_first_tail_x15_r0_body.S373) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨16818, 277, 0, 207⟩) bodyAcc371 PRE_first_tail_x15_r0_body.bodyRunSeg100 bodyAcc372 bodyHalt372 PRE_first_tail_x15_r0_body.bodyStepA101 bodyTop373 (fun _ hm => bodyO371 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr371).trans bodyInactive0) (bodyBr373.trans bodyBr371.symm) bodyCnt371 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
