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

kernel_rfl bodyO1464 : PRE_first_tail_x15_r0_body.S1464.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1464.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1464 : bridgeOf PRE_first_tail_x15_r0_body.s1464.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1464 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.S1464) = fun _ _ => true
kernel_rfl bodyAcc1465 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1465 PRE_first_tail_x15_r0_body.S1465) = fun _ _ => true
kernel_rfl bodyBr1466 : bridgeOf PRE_first_tail_x15_r0_body.s1466.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1465 : isHalt PRE_first_tail_x15_r0_body.s1465.ctl = false
kernel_rfl bodyTop1466 : noRetBlock PRE_first_tail_x15_r0_body.s1466 = true
kernel_rfl bodyCnt1464 : countersOkB PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.s1466 = true

theorem bodyGlue152 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨53871, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.S1464)
      (bodyCut NB T tk π i x0 bodyΘ ⟨53871, 1020, 0, 810⟩ bodyM PRE_first_tail_x15_r0_body.s1466 PRE_first_tail_x15_r0_body.S1466) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨53871, 1020, 0, 810⟩) bodyAcc1464 PRE_first_tail_x15_r0_body.bodyRunSeg395 bodyAcc1465 bodyHalt1465 PRE_first_tail_x15_r0_body.bodyStepA396 bodyTop1466 (fun _ hm => bodyO1464 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1464).trans bodyInactive0) (bodyBr1466.trans bodyBr1464.symm) bodyCnt1464 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
