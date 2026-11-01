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

kernel_rfl bodyO256 : PRE_first_tail_x15_r0_body.S256.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S256.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr256 : bridgeOf PRE_first_tail_x15_r0_body.s256.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc256 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s256 PRE_first_tail_x15_r0_body.S256) = fun _ _ => true
kernel_rfl bodyAcc257 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s257 PRE_first_tail_x15_r0_body.S257) = fun _ _ => true
kernel_rfl bodyBr258 : bridgeOf PRE_first_tail_x15_r0_body.s258.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt257 : isHalt PRE_first_tail_x15_r0_body.s257.ctl = false
kernel_rfl bodyTop258 : noRetBlock PRE_first_tail_x15_r0_body.s258 = true
kernel_rfl bodyCnt256 : countersOkB PRE_first_tail_x15_r0_body.s256 PRE_first_tail_x15_r0_body.s258 = true

theorem bodyGlue26 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨12964, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s256 PRE_first_tail_x15_r0_body.S256)
      (bodyCut NB T tk π i x0 bodyΘ ⟨12964, 200, 0, 144⟩ bodyM PRE_first_tail_x15_r0_body.s258 PRE_first_tail_x15_r0_body.S258) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨12964, 200, 0, 144⟩) bodyAcc256 PRE_first_tail_x15_r0_body.bodyRunSeg69 bodyAcc257 bodyHalt257 PRE_first_tail_x15_r0_body.bodyStepA70 bodyTop258 (fun _ hm => bodyO256 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr256).trans bodyInactive0) (bodyBr258.trans bodyBr256.symm) bodyCnt256 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
