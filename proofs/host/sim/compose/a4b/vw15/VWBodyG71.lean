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

kernel_rfl bodyO687 : PRE_first_tail_x15_r0_body.S687.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S687.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr687 : bridgeOf PRE_first_tail_x15_r0_body.s687.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc687 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.S687) = fun _ _ => true
kernel_rfl bodyAcc688 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s688 PRE_first_tail_x15_r0_body.S688) = fun _ _ => true
kernel_rfl bodyBr689 : bridgeOf PRE_first_tail_x15_r0_body.s689.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt688 : isHalt PRE_first_tail_x15_r0_body.s688.ctl = false
kernel_rfl bodyTop689 : noRetBlock PRE_first_tail_x15_r0_body.s689 = true
kernel_rfl bodyCnt687 : countersOkB PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.s689 = true

theorem bodyGlue71 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨27237, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.S687)
      (bodyCut NB T tk π i x0 bodyΘ ⟨27237, 483, 0, 378⟩ bodyM PRE_first_tail_x15_r0_body.s689 PRE_first_tail_x15_r0_body.S689) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨27237, 483, 0, 378⟩) bodyAcc687 PRE_first_tail_x15_r0_body.bodyRunSeg185 bodyAcc688 bodyHalt688 PRE_first_tail_x15_r0_body.bodyStepA186 bodyTop689 (fun _ hm => bodyO687 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr687).trans bodyInactive0) (bodyBr689.trans bodyBr687.symm) bodyCnt687 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
