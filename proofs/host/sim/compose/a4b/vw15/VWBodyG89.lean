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

kernel_rfl bodyO860 : PRE_first_tail_x15_r0_body.S860.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S860.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr860 : bridgeOf PRE_first_tail_x15_r0_body.s860.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc860 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s860 PRE_first_tail_x15_r0_body.S860) = fun _ _ => true
kernel_rfl bodyAcc861 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s861 PRE_first_tail_x15_r0_body.S861) = fun _ _ => true
kernel_rfl bodyBr862 : bridgeOf PRE_first_tail_x15_r0_body.s862.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt861 : isHalt PRE_first_tail_x15_r0_body.s861.ctl = false
kernel_rfl bodyTop862 : noRetBlock PRE_first_tail_x15_r0_body.s862 = true
kernel_rfl bodyCnt860 : countersOkB PRE_first_tail_x15_r0_body.s860 PRE_first_tail_x15_r0_body.s862 = true

theorem bodyGlue89 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨33404, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s860 PRE_first_tail_x15_r0_body.S860)
      (bodyCut NB T tk π i x0 bodyΘ ⟨33404, 610, 0, 477⟩ bodyM PRE_first_tail_x15_r0_body.s862 PRE_first_tail_x15_r0_body.S862) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨33404, 610, 0, 477⟩) bodyAcc860 PRE_first_tail_x15_r0_body.bodyRunSeg232 bodyAcc861 bodyHalt861 PRE_first_tail_x15_r0_body.bodyStepA233 bodyTop862 (fun _ hm => bodyO860 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr860).trans bodyInactive0) (bodyBr862.trans bodyBr860.symm) bodyCnt860 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
