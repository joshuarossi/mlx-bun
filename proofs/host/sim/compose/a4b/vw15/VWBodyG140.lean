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

kernel_rfl bodyO1349 : PRE_first_tail_x15_r0_body.S1349.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1349.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1349 : bridgeOf PRE_first_tail_x15_r0_body.s1349.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1349 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.S1349) = fun _ _ => true
kernel_rfl bodyAcc1350 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1350 PRE_first_tail_x15_r0_body.S1350) = fun _ _ => true
kernel_rfl bodyBr1351 : bridgeOf PRE_first_tail_x15_r0_body.s1351.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1350 : isHalt PRE_first_tail_x15_r0_body.s1350.ctl = false
kernel_rfl bodyTop1351 : noRetBlock PRE_first_tail_x15_r0_body.s1351 = true
kernel_rfl bodyCnt1349 : countersOkB PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.s1351 = true

theorem bodyGlue140 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨49990, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.S1349)
      (bodyCut NB T tk π i x0 bodyΘ ⟨49990, 943, 0, 747⟩ bodyM PRE_first_tail_x15_r0_body.s1351 PRE_first_tail_x15_r0_body.S1351) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨49990, 943, 0, 747⟩) bodyAcc1349 PRE_first_tail_x15_r0_body.bodyRunSeg364 bodyAcc1350 bodyHalt1350 PRE_first_tail_x15_r0_body.bodyStepA365 bodyTop1351 (fun _ hm => bodyO1349 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1349).trans bodyInactive0) (bodyBr1351.trans bodyBr1349.symm) bodyCnt1349 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
