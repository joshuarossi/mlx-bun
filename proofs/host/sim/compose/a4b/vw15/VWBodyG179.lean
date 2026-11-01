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

kernel_rfl bodyO1722 : PRE_first_tail_x15_r0_body.S1722.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1722.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1722 : bridgeOf PRE_first_tail_x15_r0_body.s1722.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1722 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1722 PRE_first_tail_x15_r0_body.S1722) = fun _ _ => true
kernel_rfl bodyAcc1723 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1723 PRE_first_tail_x15_r0_body.S1723) = fun _ _ => true
kernel_rfl bodyBr1724 : bridgeOf PRE_first_tail_x15_r0_body.s1724.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1723 : isHalt PRE_first_tail_x15_r0_body.s1723.ctl = false
kernel_rfl bodyTop1724 : noRetBlock PRE_first_tail_x15_r0_body.s1724 = true
kernel_rfl bodyCnt1722 : countersOkB PRE_first_tail_x15_r0_body.s1722 PRE_first_tail_x15_r0_body.s1724 = true

theorem bodyGlue179 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61968, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1722 PRE_first_tail_x15_r0_body.S1722)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61968, 1176, 0, 945⟩ bodyM PRE_first_tail_x15_r0_body.s1724 PRE_first_tail_x15_r0_body.S1724) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61968, 1176, 0, 945⟩) bodyAcc1722 PRE_first_tail_x15_r0_body.bodyRunSeg464 bodyAcc1723 bodyHalt1723 PRE_first_tail_x15_r0_body.bodyStepA465 bodyTop1724 (fun _ hm => bodyO1722 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1722).trans bodyInactive0) (bodyBr1724.trans bodyBr1722.symm) bodyCnt1722 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
