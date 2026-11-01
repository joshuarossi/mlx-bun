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

kernel_rfl bodyO1694 : PRE_first_tail_x15_r0_body.S1694.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1694.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1694 : bridgeOf PRE_first_tail_x15_r0_body.s1694.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1694 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1694 PRE_first_tail_x15_r0_body.S1694) = fun _ _ => true
kernel_rfl bodyAcc1695 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1695 PRE_first_tail_x15_r0_body.S1695) = fun _ _ => true
kernel_rfl bodyBr1696 : bridgeOf PRE_first_tail_x15_r0_body.s1696.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1695 : isHalt PRE_first_tail_x15_r0_body.s1695.ctl = false
kernel_rfl bodyTop1696 : noRetBlock PRE_first_tail_x15_r0_body.s1696 = true
kernel_rfl bodyCnt1694 : countersOkB PRE_first_tail_x15_r0_body.s1694 PRE_first_tail_x15_r0_body.s1696 = true

theorem bodyGlue176 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨61597, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1694 PRE_first_tail_x15_r0_body.S1694)
      (bodyCut NB T tk π i x0 bodyΘ ⟨61597, 1174, 0, 936⟩ bodyM PRE_first_tail_x15_r0_body.s1696 PRE_first_tail_x15_r0_body.S1696) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨61597, 1174, 0, 936⟩) bodyAcc1694 PRE_first_tail_x15_r0_body.bodyRunSeg457 bodyAcc1695 bodyHalt1695 PRE_first_tail_x15_r0_body.bodyStepA458 bodyTop1696 (fun _ hm => bodyO1694 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1694).trans bodyInactive0) (bodyBr1696.trans bodyBr1694.symm) bodyCnt1694 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
