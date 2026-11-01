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

kernel_rfl bodyO1435 : PRE_first_tail_x15_r0_body.S1435.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1435.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1435 : bridgeOf PRE_first_tail_x15_r0_body.s1435.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1435 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1435 PRE_first_tail_x15_r0_body.S1435) = fun _ _ => true
kernel_rfl bodyAcc1436 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1436 PRE_first_tail_x15_r0_body.S1436) = fun _ _ => true
kernel_rfl bodyBr1437 : bridgeOf PRE_first_tail_x15_r0_body.s1437.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1436 : isHalt PRE_first_tail_x15_r0_body.s1436.ctl = false
kernel_rfl bodyTop1437 : noRetBlock PRE_first_tail_x15_r0_body.s1437 = true
kernel_rfl bodyCnt1435 : countersOkB PRE_first_tail_x15_r0_body.s1435 PRE_first_tail_x15_r0_body.s1437 = true

theorem bodyGlue149 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨52701, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1435 PRE_first_tail_x15_r0_body.S1435)
      (bodyCut NB T tk π i x0 bodyΘ ⟨52701, 995, 0, 792⟩ bodyM PRE_first_tail_x15_r0_body.s1437 PRE_first_tail_x15_r0_body.S1437) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨52701, 995, 0, 792⟩) bodyAcc1435 PRE_first_tail_x15_r0_body.bodyRunSeg387 bodyAcc1436 bodyHalt1436 PRE_first_tail_x15_r0_body.bodyStepA388 bodyTop1437 (fun _ hm => bodyO1435 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1435).trans bodyInactive0) (bodyBr1437.trans bodyBr1435.symm) bodyCnt1435 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
