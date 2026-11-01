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

kernel_rfl bodyO1234 : PRE_first_tail_x15_r0_body.S1234.oracle = List.drop (PRE_first_tail_x15_r0_body.OR.length - PRE_first_tail_x15_r0_body.S1234.oracle.length) PRE_first_tail_x15_r0_body.OR
kernel_rfl bodyBr1234 : bridgeOf PRE_first_tail_x15_r0_body.s1234.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyAcc1234 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.S1234) = fun _ _ => true
kernel_rfl bodyAcc1235 : (fun (bs : List Byte) (rows : Nat) => VWFrames.bodyOk bs rows PRE_first_tail_x15_r0_body.s1235 PRE_first_tail_x15_r0_body.S1235) = fun _ _ => true
kernel_rfl bodyBr1236 : bridgeOf PRE_first_tail_x15_r0_body.s1236.ffi = bridgeOf PRE_first_tail_x15_r0_body.s0.ffi
kernel_rfl bodyHalt1235 : isHalt PRE_first_tail_x15_r0_body.s1235.ctl = false
kernel_rfl bodyTop1236 : noRetBlock PRE_first_tail_x15_r0_body.s1236 = true
kernel_rfl bodyCnt1234 : countersOkB PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.s1236 = true

theorem bodyGlue128 (NB T : Nat) (tk : Nat → Nat) (π : List Nat) (x0 : SegInst FF) {r : Row} {i : Cls.Inst}
    (hr : r ∈ fwdRows) (hi : InRow r i) :
    CutStep (bodyCut NB T tk π i x0 bodyΘ ⟨46136, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1234 PRE_first_tail_x15_r0_body.S1234)
      (bodyCut NB T tk π i x0 bodyΘ ⟨46136, 866, 0, 684⟩ bodyM PRE_first_tail_x15_r0_body.s1236 PRE_first_tail_x15_r0_body.S1236) 2950 :=
  (bodyToCall (NB := NB) (T := T) (tk := tk) (π := π) (i := i) (Θ := bodyΘ) (Tr := BodyTrail x0) (O := ⟨46136, 866, 0, 684⟩) bodyAcc1234 PRE_first_tail_x15_r0_body.bodyRunSeg333 bodyAcc1235 bodyHalt1235 PRE_first_tail_x15_r0_body.bodyStepA334 bodyTop1236 (fun _ hm => bodyO1234 ▸ bodyGoodDrop hr hi hm _) ((congrArg (fun b : Host.Mlx.FfiAne.St => b.active) bodyBr1234).trans bodyInactive0) (bodyBr1236.trans bodyBr1234.symm) bodyCnt1234 (BodyTrail.ofTrack x0)).cast rfl rfl rfl

end Host.Ts.Sim.Compose.VWFirst.VW15
