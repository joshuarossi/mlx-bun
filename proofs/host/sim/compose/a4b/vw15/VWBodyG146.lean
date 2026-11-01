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

kernel_rfl bodyO1406 : PRE_first_tail_x15_r0_body.S1406.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1406.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1406 : bridgeOf PRE_first_tail_x15_r0_body.s1406.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1406 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1406 PRE_first_tail_x15_r0_body.S1406) = fun _ _ => true
kernel_rfl bodyAcc1407 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1407 PRE_first_tail_x15_r0_body.S1407) = fun _ _ => true
kernel_rfl bodyBr1408 : bridgeOf PRE_first_tail_x15_r0_body.s1408.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1407 : isHalt PRE_first_tail_x15_r0_body.s1407.ctl = false
kernel_rfl bodyTop1408 : noRetBlock PRE_first_tail_x15_r0_body.s1408 = true
kernel_rfl bodyCnt1406 : countersOkB PRE_first_tail_x15_r0_body.s1406 PRE_first_tail_x15_r0_body.s1408 = true

theorem bodyGlue146 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨51531, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1406 PRE_first_tail_x15_r0_body.S1406)
      (bodyCut NB T tk π i x0 bodyΘ ⟨51531, 970, 0, 774⟩ bodyM PRE_first_tail_x15_r0_body.s1408 PRE_first_tail_x15_r0_body.S1408) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨51531, 970, 0, 774⟩) bodyAcc1406 PRE_first_tail_x15_r0_body.bodyRunSeg379 bodyAcc1407 bodyHalt1407 PRE_first_tail_x15_r0_body.bodyStepA380 bodyTop1408 (fun _ hm => bodyO1406 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1406).trans bodyInactive0) (bodyBr1408.trans bodyBr1406.symm) bodyCnt1406 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
