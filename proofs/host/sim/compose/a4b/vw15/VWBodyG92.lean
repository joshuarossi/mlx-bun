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

kernel_rfl bodyO889 : PRE_first_tail_x15_r0_body.S889.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S889.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr889 : bridgeOf PRE_first_tail_x15_r0_body.s889.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc889 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s889 PRE_first_tail_x15_r0_body.S889) = fun _ _ => true
kernel_rfl bodyAcc890 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s890 PRE_first_tail_x15_r0_body.S890) = fun _ _ => true
kernel_rfl bodyBr891 : bridgeOf PRE_first_tail_x15_r0_body.s891.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt890 : isHalt PRE_first_tail_x15_r0_body.s890.ctl = false
kernel_rfl bodyTop891 : noRetBlock PRE_first_tail_x15_r0_body.s891 = true
kernel_rfl bodyCnt889 : countersOkB PRE_first_tail_x15_r0_body.s889 PRE_first_tail_x15_r0_body.s891 = true

theorem bodyGlue92 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨34574, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s889 PRE_first_tail_x15_r0_body.S889)
      (bodyCut NB T tk π i x0 bodyΘ ⟨34574, 635, 0, 495⟩ bodyM PRE_first_tail_x15_r0_body.s891 PRE_first_tail_x15_r0_body.S891) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨34574, 635, 0, 495⟩) bodyAcc889 PRE_first_tail_x15_r0_body.bodyRunSeg240 bodyAcc890 bodyHalt890 PRE_first_tail_x15_r0_body.bodyStepA241 bodyTop891 (fun _ hm => bodyO889 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr889).trans bodyInactive0) (bodyBr891.trans bodyBr889.symm) bodyCnt889 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
