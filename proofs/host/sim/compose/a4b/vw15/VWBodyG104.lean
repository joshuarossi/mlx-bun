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

kernel_rfl bodyO1004 : PRE_first_tail_x15_r0_body.S1004.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1004.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1004 : bridgeOf PRE_first_tail_x15_r0_body.s1004.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1004 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.S1004) = fun _ _ => true
kernel_rfl bodyAcc1005 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1005 PRE_first_tail_x15_r0_body.S1005) = fun _ _ => true
kernel_rfl bodyBr1006 : bridgeOf PRE_first_tail_x15_r0_body.s1006.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1005 : isHalt PRE_first_tail_x15_r0_body.s1005.ctl = false
kernel_rfl bodyTop1006 : noRetBlock PRE_first_tail_x15_r0_body.s1006 = true
kernel_rfl bodyCnt1004 : countersOkB PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.s1006 = true

theorem bodyGlue104 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨38446, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1004 PRE_first_tail_x15_r0_body.S1004)
      (bodyCut NB T tk π i x0 bodyΘ ⟨38446, 712, 0, 558⟩ bodyM PRE_first_tail_x15_r0_body.s1006 PRE_first_tail_x15_r0_body.S1006) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨38446, 712, 0, 558⟩) bodyAcc1004 PRE_first_tail_x15_r0_body.bodyRunSeg271 bodyAcc1005 bodyHalt1005 PRE_first_tail_x15_r0_body.bodyStepA272 bodyTop1006 (fun _ hm => bodyO1004 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1004).trans bodyInactive0) (bodyBr1006.trans bodyBr1004.symm) bodyCnt1004 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
