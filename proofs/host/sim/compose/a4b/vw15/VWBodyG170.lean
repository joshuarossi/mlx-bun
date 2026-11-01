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

kernel_rfl bodyO1636 : PRE_first_tail_x15_r0_body.S1636.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1636.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1636 : bridgeOf PRE_first_tail_x15_r0_body.s1636.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1636 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1636 PRE_first_tail_x15_r0_body.S1636) = fun _ _ => true
kernel_rfl bodyAcc1637 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1637 PRE_first_tail_x15_r0_body.S1637) = fun _ _ => true
kernel_rfl bodyBr1638 : bridgeOf PRE_first_tail_x15_r0_body.s1638.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1637 : isHalt PRE_first_tail_x15_r0_body.s1637.ctl = false
kernel_rfl bodyTop1638 : noRetBlock PRE_first_tail_x15_r0_body.s1638 = true
kernel_rfl bodyCnt1636 : countersOkB PRE_first_tail_x15_r0_body.s1636 PRE_first_tail_x15_r0_body.s1638 = true

theorem bodyGlue170 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨59257, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1636 PRE_first_tail_x15_r0_body.S1636)
      (bodyCut NB T tk π i x0 bodyΘ ⟨59257, 1124, 0, 900⟩ bodyM PRE_first_tail_x15_r0_body.s1638 PRE_first_tail_x15_r0_body.S1638) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨59257, 1124, 0, 900⟩) bodyAcc1636 PRE_first_tail_x15_r0_body.bodyRunSeg441 bodyAcc1637 bodyHalt1637 PRE_first_tail_x15_r0_body.bodyStepA442 bodyTop1638 (fun _ hm => bodyO1636 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1636).trans bodyInactive0) (bodyBr1638.trans bodyBr1636.symm) bodyCnt1636 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
