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

kernel_rfl bodyO1665 : PRE_first_tail_x15_r0_body.S1665.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1665.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1665 : bridgeOf PRE_first_tail_x15_r0_body.s1665.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1665 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1665 PRE_first_tail_x15_r0_body.S1665) = fun _ _ => true
kernel_rfl bodyAcc1666 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1666 PRE_first_tail_x15_r0_body.S1666) = fun _ _ => true
kernel_rfl bodyBr1667 : bridgeOf PRE_first_tail_x15_r0_body.s1667.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1666 : isHalt PRE_first_tail_x15_r0_body.s1666.ctl = false
kernel_rfl bodyTop1667 : noRetBlock PRE_first_tail_x15_r0_body.s1667 = true
kernel_rfl bodyCnt1665 : countersOkB PRE_first_tail_x15_r0_body.s1665 PRE_first_tail_x15_r0_body.s1667 = true

theorem bodyGlue173 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨60427, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1665 PRE_first_tail_x15_r0_body.S1665)
      (bodyCut NB T tk π i x0 bodyΘ ⟨60427, 1149, 0, 918⟩ bodyM PRE_first_tail_x15_r0_body.s1667 PRE_first_tail_x15_r0_body.S1667) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨60427, 1149, 0, 918⟩) bodyAcc1665 PRE_first_tail_x15_r0_body.bodyRunSeg449 bodyAcc1666 bodyHalt1666 PRE_first_tail_x15_r0_body.bodyStepA450 bodyTop1667 (fun _ hm => bodyO1665 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1665).trans bodyInactive0) (bodyBr1667.trans bodyBr1665.symm) bodyCnt1665 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
