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

kernel_rfl bodyO572 : PRE_first_tail_x15_r0_body.S572.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S572.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr572 : bridgeOf PRE_first_tail_x15_r0_body.s572.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc572 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s572 PRE_first_tail_x15_r0_body.S572) = fun _ _ => true
kernel_rfl bodyAcc573 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s573 PRE_first_tail_x15_r0_body.S573) = fun _ _ => true
kernel_rfl bodyBr574 : bridgeOf PRE_first_tail_x15_r0_body.s574.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt573 : isHalt PRE_first_tail_x15_r0_body.s573.ctl = false
kernel_rfl bodyTop574 : noRetBlock PRE_first_tail_x15_r0_body.s574 = true
kernel_rfl bodyCnt572 : countersOkB PRE_first_tail_x15_r0_body.s572 PRE_first_tail_x15_r0_body.s574 = true

theorem bodyGlue59 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨23392, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s572 PRE_first_tail_x15_r0_body.S572)
      (bodyCut NB T tk π i x0 bodyΘ ⟨23392, 406, 0, 315⟩ bodyM PRE_first_tail_x15_r0_body.s574 PRE_first_tail_x15_r0_body.S574) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨23392, 406, 0, 315⟩) bodyAcc572 PRE_first_tail_x15_r0_body.bodyRunSeg154 bodyAcc573 bodyHalt573 PRE_first_tail_x15_r0_body.bodyStepA155 bodyTop574 (fun _ hm => bodyO572 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr572).trans bodyInactive0) (bodyBr574.trans bodyBr572.symm) bodyCnt572 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
