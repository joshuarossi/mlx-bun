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

kernel_rfl bodyO1291 : PRE_first_tail_x15_r0_body.S1291.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1291.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1291 : bridgeOf PRE_first_tail_x15_r0_body.s1291.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1291 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.S1291) = fun _ _ => true
kernel_rfl bodyAcc1292 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1292 PRE_first_tail_x15_r0_body.S1292) = fun _ _ => true
kernel_rfl bodyBr1293 : bridgeOf PRE_first_tail_x15_r0_body.s1293.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1292 : isHalt PRE_first_tail_x15_r0_body.s1292.ctl = false
kernel_rfl bodyTop1293 : noRetBlock PRE_first_tail_x15_r0_body.s1293 = true
kernel_rfl bodyCnt1291 : countersOkB PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.s1293 = true

theorem bodyGlue134 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨47659, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.S1291)
      (bodyCut NB T tk π i x0 bodyΘ ⟨47659, 893, 0, 711⟩ bodyM PRE_first_tail_x15_r0_body.s1293 PRE_first_tail_x15_r0_body.S1293) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨47659, 893, 0, 711⟩) bodyAcc1291 PRE_first_tail_x15_r0_body.bodyRunSeg348 bodyAcc1292 bodyHalt1292 PRE_first_tail_x15_r0_body.bodyStepA349 bodyTop1293 (fun _ hm => bodyO1291 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1291).trans bodyInactive0) (bodyBr1293.trans bodyBr1291.symm) bodyCnt1291 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
